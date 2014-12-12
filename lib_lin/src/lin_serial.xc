/*
 * lin_serial.xc
 *
 *  Created on: May 9, 2013
 *      Author: Ed
 */

#include "lin_serial.h"
#include "lin_conf.h"
#include "lin_types.h"

//convert byte to a 10 bit serial frame (add start/stop bits)
static unsigned int format_tx_byte (unsigned char tx){
  unsigned int to_tx;
  to_tx = 0x300 | (unsigned int) tx; //set stop bit and post stop bit (idle state)
  to_tx <<= 1;
  return to_tx;
}

//covert serial frame to byte - strip start/stop bits
static unsigned int unformat_rx_byte (unsigned int rx)
{
  rx >>= 1;
  rx &= 0xff; //mask off start bit
  return rx;
}


//Uart Tx. Send up to a 32 bit serial word, LSB first.
//This function requires you to add start/stop bits to the Tx frame
static void lin_tx_raw(out port txd, unsigned int tx_word, int n_bits)
{
  int next_bit_tmr_tx;
  unsigned int bit_counter;
  timer tx_bit_timer;

  bit_counter = n_bits;

  if (tx_word & 0x1) txd <: TX_RECESSIVE;       //output bit 0, start bit
  else txd <: TX_DOMINANT;
  tx_bit_timer :> next_bit_tmr_tx;              //read timer time
  tx_word >>= 1;
  next_bit_tmr_tx += LIN_BIT_TIME;

  // Output data bits in turn, LSB first.
  while(bit_counter > 0) {
    tx_bit_timer when timerafter(next_bit_tmr_tx) :> int;
    if (tx_word & 0x1) txd <: TX_RECESSIVE;
    else txd <: TX_DOMINANT;
    tx_word >>= 1;
    next_bit_tmr_tx += LIN_BIT_TIME;
    bit_counter--;
  }
}

void lin_tx_byte(out port txd, unsigned char tx_byte){
  lin_tx_raw(txd, format_tx_byte(tx_byte), 10);
}

void lin_tx_break(out port txd){
  lin_tx_raw(txd, (0xffffffff << LIN_SYNCH_BREAK_BITS_MASTER),
               LIN_SYNCH_BREAK_BITS_MASTER + LIN_SYNCH_BREAK_DELIMIT);
}

//UART Rx server core with continuous break detection and timeout
void lin_rx_server(in port rxd, chanend c)
{
  int transition_to_recessive_rx, transition_to_dominant_rx,
      next_rx_sample_time, break_start_time,
      rx_port_val, lin_bus_next, time_out_trigger;
  lin_serial_rx_state_t current_state, previous_state;
  lin_serial_rx_command_t command;
  unsigned int bit_counter, rx_word;
  unsigned char rx_last_received_byte;
  timer rx_bit_timer, rx_timeout_timer;

  set_port_pull_down(rxd);//enable pull downs on port (pull unused pins on >1b port to low)
                          //Needed for slice kit with IS-BUS slice since RXD is on 4b port

  //Set initial conditions for state machine. Assume waiting at recessive level
  command = SLAVE_RX_NO_COMMAND;
  current_state =  SLAVE_RX_WAITING;
  previous_state = SLAVE_RX_WAITING;
  bit_counter = 0;
  lin_bus_next = RX_DOMINANT;

  while(1){
    rx_word = 0x00000000;
    while ((current_state == SLAVE_RX_WAITING) || (current_state == SLAVE_RX_IN_PROGRESS)){

#pragma ordered

      select{
        //Looks for specific signal level on lin bus. Used to detect transition from high/low/high
        case rxd when pinseq(lin_bus_next) :> int:
          if (lin_bus_next == RX_DOMINANT){
            rx_bit_timer :> transition_to_dominant_rx;
            if (previous_state != SLAVE_RX_STOP_BIT_ERROR) break_start_time = transition_to_dominant_rx;
            if (bit_counter == 0){
              next_rx_sample_time = transition_to_dominant_rx + (LIN_BIT_TIME / 2);
              current_state = SLAVE_RX_IN_PROGRESS;
            }
            lin_bus_next = RX_RECESSIVE;
            break;
          }

          else if (lin_bus_next == RX_RECESSIVE){
            rx_bit_timer :> transition_to_recessive_rx;
            if((transition_to_recessive_rx - break_start_time)
                > (LIN_BIT_TIME * LIN_SYNCH_BREAK_THRESHOLD_SLAVE)){
              current_state = SLAVE_RX_BREAK_OK;
            }
            lin_bus_next = RX_DOMINANT;
          }
        break;

        //Samples the level on the rx pin periodically for serial receive
        case (current_state == SLAVE_RX_IN_PROGRESS) => rx_bit_timer when timerafter(next_rx_sample_time) :> int:
          rxd :> rx_port_val;
          if (rx_port_val == RX_RECESSIVE) rx_word |= (0x01 << bit_counter);

          if ((bit_counter == 0) && (rx_port_val != RX_DOMINANT)){
            current_state = SLAVE_RX_START_BIT_ERROR;
          }

          if ((bit_counter == 9) && (rx_port_val == RX_RECESSIVE)){
            rx_last_received_byte = (unsigned char)unformat_rx_byte(rx_word);
            current_state = SLAVE_RX_BYTE_OK;
          }

          if ((bit_counter == 9) && (rx_port_val != RX_RECESSIVE)){
            current_state = SLAVE_RX_STOP_BIT_ERROR;
          }

          next_rx_sample_time += LIN_BIT_TIME;
          bit_counter++;
          break;


        //Timer for detecting time out after get byte blocking command
        case (command == SLAVE_RX_GET_NEXT_BYTE_COMMAND) => rx_timeout_timer when timerafter(time_out_trigger) :> int:
          current_state = SLAVE_RX_TIMEOUT;
          break;

        //Comms handler from client API. Handles commands given
        case c :> command:
          switch (command){
          case SLAVE_RX_RESET_COMMAND:
            current_state = SLAVE_RX_RESET;
            c <: current_state;
            command = SLAVE_RX_NO_COMMAND;
            break;

          case SLAVE_RX_GET_STATUS_COMMAND:
            c <: current_state;
            command = SLAVE_RX_NO_COMMAND;
            break;

          case SLAVE_RX_GET_LAST_BYTE_COMMAND:
            c <: rx_last_received_byte;
            c <: previous_state;
            command = SLAVE_RX_NO_COMMAND;
            break;

          case SLAVE_RX_GET_NEXT_BYTE_COMMAND:
            rx_timeout_timer :> time_out_trigger; //get current time
            time_out_trigger += (LIN_MESSAGE_TIMEOUT * XS1_TIMER_KHZ); //set timeout to correct number of milliseconds
            c <: current_state;
            break; //Transmission handled below after full word recieved

          case SLAVE_RX_GET_BREAK_COMMAND:
            c <: current_state;
            break; //handled below after stop bit error then break received

          case SLAVE_RX_NO_COMMAND:
            break;
          }
        break; //next RX sample time
      }//select
    }//rx loop (while waiting or receieving)

    if(command == SLAVE_RX_GET_NEXT_BYTE_COMMAND){
      c <: current_state;
      c <: (unsigned char)unformat_rx_byte(rx_word);
      command = SLAVE_RX_NO_COMMAND;
    }

    if ((command == SLAVE_RX_GET_BREAK_COMMAND) && (current_state == SLAVE_RX_BREAK_OK)){
      c <: current_state;
      command = SLAVE_RX_NO_COMMAND;
    }

    bit_counter = 0;
    lin_bus_next = RX_DOMINANT;
    previous_state = current_state;
    current_state = SLAVE_RX_WAITING;
  }//while (1)
}


