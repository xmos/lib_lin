#include "lin_slave.h"
#include "lin_conf.h"
#include "lin_rx_client.h"
#include "lin_utils.h"
#include "lin_serial.h"

lin_slave_error_t lin_slave_init(out port p_slave_txd, chanend c_a2rx){

  p_slave_txd <: TX_RECESSIVE;
  if (lin_rx_reset (c_a2rx) == SLAVE_RX_RESET) return LIN_SUCCESS;
  else return LIN_ERR_NO_RESPONSE;
}



lin_slave_error_t lin_slave_wait_for_header(chanend c_a2rx, unsigned char &id){

  lin_slave_error_t return_error = LIN_ERR_NO_RESPONSE;
  lin_slave_state_t lin_slave_state = LIN_SLAVE_IDLE;
  lin_serial_rx_state_t rx_state;
  unsigned char rx_byte;

  while (lin_slave_state != LIN_SLAVE_SYNCH_BREAK_OK){
    switch (lin_slave_state){
    case LIN_SLAVE_IDLE:
    lin_rx_look_for_break_cmd (c_a2rx);
    lin_rx_wait_for_break (c_a2rx);
    lin_rx_return_next_byte_cmd (c_a2rx);
    rx_state = lin_rx_wait_for_byte (rx_byte, c_a2rx);
      if ((rx_state == SLAVE_RX_START_BIT_ERROR) || (rx_state == SLAVE_RX_STOP_BIT_ERROR)
         || (rx_byte != LIN_SYNCH_BYTE)) {
        lin_slave_state = LIN_SLAVE_IDLE;
        break;
      }
    lin_slave_state = LIN_SLAVE_RECEIVE_PID;
    break;

    case LIN_SLAVE_RECEIVE_PID:
      lin_rx_return_next_byte_cmd (c_a2rx);
      rx_state = lin_rx_wait_for_byte (rx_byte, c_a2rx);
      if ((rx_state == SLAVE_RX_START_BIT_ERROR) || (rx_state == SLAVE_RX_STOP_BIT_ERROR)){
        return_error = LIN_ERR_FRAMING;
        lin_slave_state = LIN_SLAVE_IDLE;
        break;
      }
      if (rx_state == SLAVE_RX_TIMEOUT) {
        return_error = LIN_ERR_NO_RESPONSE;
        lin_slave_state = LIN_SLAVE_IDLE;
        break;
      }
      if (rx_byte != lin_set_id_parity_bits(rx_byte)){
        return_error = LIN_ERR_ID_PARITY;
        lin_slave_state = LIN_SLAVE_IDLE;
        break;
      }
      id = (rx_byte & 0x3f);
      return_error = LIN_SUCCESS;
      lin_slave_state = LIN_SLAVE_SYNCH_BREAK_OK;
      break;
    }
  }
  return return_error;
}

lin_slave_error_t lin_slave_send_response(out port p_slave_txd, chanend c_a2rx, lin_frame_t tx_response){

  lin_slave_error_t return_error = LIN_ERR_NO_RESPONSE;
  lin_slave_state_t lin_slave_state = LIN_SLAVE_TX_DATA;
  lin_serial_rx_state_t rx_state;
  unsigned char rx_byte;

  while ((lin_slave_state == LIN_SLAVE_TX_DATA) || (lin_slave_state == LIN_SLAVE_TX_CHECKSUM)){
    switch (lin_slave_state){
    case LIN_SLAVE_TX_DATA:
      lin_wait(LIN_RESPONSE_SPACE);
      for(int tx_counter = 0; tx_counter < tx_response.length; tx_counter++){
        lin_tx_byte (p_slave_txd, tx_response.data[tx_counter]);
        rx_state = lin_rx_get_last_byte (rx_byte, c_a2rx); //new
        if ((rx_state == SLAVE_RX_START_BIT_ERROR) || (rx_state == SLAVE_RX_STOP_BIT_ERROR)){
           return_error = LIN_ERR_FRAMING;
           lin_slave_state = LIN_SLAVE_IDLE;
           break;
        }
        if (rx_byte != tx_response.data[tx_counter]){
          return_error = LIN_ERR_READBACK;
          lin_slave_state = LIN_SLAVE_IDLE;
          break;
        }
        lin_wait(LIN_INTERBYTE_SPACE);
      }
      lin_slave_state = LIN_SLAVE_TX_CHECKSUM;
      break;

    case LIN_SLAVE_TX_CHECKSUM:
      lin_tx_byte (p_slave_txd, tx_response.checksum);
      rx_state = lin_rx_get_last_byte (rx_byte, c_a2rx);
      if ((rx_state == SLAVE_RX_START_BIT_ERROR) || (rx_state == SLAVE_RX_STOP_BIT_ERROR)){
        return_error = LIN_ERR_FRAMING;
        lin_slave_state = LIN_SLAVE_IDLE;
        break;
      }
      if (rx_byte != tx_response.checksum){
        return_error = LIN_ERR_READBACK;
        lin_slave_state = LIN_SLAVE_IDLE;
        break;
      }
      lin_slave_state = LIN_SLAVE_IDLE;
      return_error = LIN_SUCCESS;
      break;
    }
  }
  return return_error;
}


lin_slave_error_t lin_slave_get_response(chanend c_a2rx, lin_frame_t &rx_response){

  lin_slave_error_t return_error = LIN_ERR_NO_RESPONSE;
  lin_slave_state_t lin_slave_state = LIN_SLAVE_RX_DATA;
  lin_serial_rx_state_t rx_state;
  unsigned char rx_byte;

  while ((lin_slave_state == LIN_SLAVE_RX_DATA) || (lin_slave_state == LIN_SLAVE_RX_CHECKSUM)){
    switch (lin_slave_state){
    case LIN_SLAVE_RX_DATA:
       for(int rx_counter = 0; rx_counter < rx_response.length; rx_counter++){
         lin_rx_return_next_byte_cmd (c_a2rx);
         rx_state = lin_rx_wait_for_byte (rx_byte, c_a2rx);
         if ((rx_state == SLAVE_RX_START_BIT_ERROR) || (rx_state == SLAVE_RX_STOP_BIT_ERROR)){
           return_error = LIN_ERR_FRAMING;
           lin_slave_state = LIN_SLAVE_IDLE;
           break;
         }
         if ((rx_state == SLAVE_RX_TIMEOUT) && (rx_counter == 0)) {
           return_error = LIN_ERR_NO_RESPONSE;
           lin_slave_state = LIN_SLAVE_IDLE;
           break;
         }
         if ((rx_state == SLAVE_RX_TIMEOUT) && (rx_counter > 0)) {
           return_error = LIN_ERR_LAST_FRAME_RESPONSE_TOO_SHORT;
           lin_slave_state = LIN_SLAVE_IDLE;
           break;
         }
         rx_response.data[rx_counter] = rx_byte;
       }
       lin_slave_state = LIN_SLAVE_RX_CHECKSUM;
       break;

     case LIN_SLAVE_RX_CHECKSUM:
       lin_rx_return_next_byte_cmd (c_a2rx);
       rx_state = lin_rx_wait_for_byte (rx_byte, c_a2rx);
       if ((rx_state == SLAVE_RX_START_BIT_ERROR) || (rx_state == SLAVE_RX_STOP_BIT_ERROR)){
         return_error = LIN_ERR_FRAMING;
         lin_slave_state = LIN_SLAVE_IDLE;
         break;
       }
       if (rx_state == SLAVE_RX_TIMEOUT) {
         return_error = LIN_ERR_LAST_FRAME_RESPONSE_TOO_SHORT;
         lin_slave_state = LIN_SLAVE_IDLE;
         break;
       }
       if (lin_calculate_checksum (rx_response, LIN_CHECKSUM_CLASSIC) != rx_byte){
         return_error = LIN_ERR_CHECKSUM;
         lin_slave_state = LIN_SLAVE_IDLE;
         break;
       }
       rx_response.checksum = rx_byte;

       lin_slave_state = LIN_SLAVE_IDLE;
       return_error = LIN_SUCCESS;
       break;
    }
  }
  return return_error;
}



