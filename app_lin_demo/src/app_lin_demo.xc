#include <platform.h>
#include <xscope.h>
#include <print.h>

#define ISBUS_NODE_COUNT 2	//Number of ISBUS slices connected.
							//Choose 1 for master only demo, 2 for master & slave

#include "lin_conf.h"
#include "lin_master.h"
#if ISBUS_NODE_COUNT == 2
#include "lin_slave.h"
#endif
#include "lin_utils.h"

#define USE_XSCOPE 1

on tile[1]: out port p_master_txd = XS1_PORT_4A;
on tile[1]: in port p_master_rxd = XS1_PORT_4B;
#if ISBUS_NODE_COUNT == 2
on tile[1]: out port p_slave_txd = XS1_PORT_4E;
on tile[1]: in port p_slave_rxd = XS1_PORT_4F;
#endif

#if USE_XSCOPE
void xscope_user_init(void) {
  xscope_config_io(XSCOPE_IO_BASIC);	//Fast, low intrusive printing via xscope
  xscope_register(1, XSCOPE_CONTINUOUS, "Lin bus master node", XSCOPE_UINT, "Port val");
}
#endif


void master_application(chanend c_ma2s) {

  lin_frame_t tx_frame;                               //Declare a lin frame for tx
#if ISBUS_NODE_COUNT == 2
  lin_frame_t rx_frame;                               //Declare a lin frame for rx
#endif
  unsigned int seed = 0x55378008;                     //random number seed
  int next_frame_time;
  timer t;

  lin_master_init(p_master_txd, c_ma2s);              //Initialise TX pin (RX already done by rx_sever core)
  t :> next_frame_time;                               //Get current time
  printstrln("Demo app started");

  while(1){
    lin_make_random_frame(tx_frame, seed);            //Create data to send to slave
    tx_frame.id = 0x19;                               //Set ID to instruct slave to receive data

    t when timerafter(next_frame_time) :> void;       //wait for next slot
    print_master_error(lin_master_send_frame(tx_frame, p_master_txd, c_ma2s));//send frame to slave and print if error
    next_frame_time += 25000000;                      //Add 250ms

#if ISBUS_NODE_COUNT == 2
    lin_make_random_frame(rx_frame, ~seed);           //Create data to overwrite on receive, including setting length
    rx_frame.id = 0x24;                               //Set ID to instruct slave to send repsonse

    t when timerafter(next_frame_time) :> void;       //wait for next slot
    print_master_error(lin_master_request_frame(rx_frame, p_master_txd, c_ma2s)); //get response from slave and print if error
    next_frame_time += 25000000;                      //Add 250ms
    seed++;                                           //make sure the next random frame is different

    if (! compare_frames(rx_frame, tx_frame)){		  //Check to see the frame made the round trip
      printstr("Sent     - ");
      print_frame(tx_frame);
      printstr("Received - ");
      print_frame(rx_frame);
    }
#endif
  }
}

#if ISBUS_NODE_COUNT == 2
void slave_application (chanend c_sa2s) {
  unsigned char id;
  lin_frame_t slave_frame;                                          //Declare a lin frame
  unsigned int seed = 0x33357406;                                   //random number seed

  lin_make_random_frame(slave_frame, seed);                         //Initialise frame with random contents
  lin_slave_init(p_slave_txd, c_sa2s);                              //Initialise slave tx port and rx server

  while(1){
    print_slave_error(lin_slave_wait_for_header(c_sa2s, id));       //Wait until header receieved and get id

    switch(id){														//Either receive or transmit frame depending on id

    case 0x19:                                                      //0x19 means receieve data
      print_slave_error(lin_slave_get_response(c_sa2s, slave_frame)); //Get response section of frame
      break;

    case 0x24:                                                      //0x24 means transmit data
      print_slave_error(lin_slave_send_response(p_slave_txd, c_sa2s, slave_frame));//Send it back to master
      break;
    }
  }
}
#endif


//Non-intrusive sniffer task to monitor rxd & txd for master and slave pin activity
//Samples overlaid ports and sends to xScope and LEDs board to show activity
on tile[1]: in port p_master_shadow = XS1_PORT_8A;
on tile[1]: in port p_slave_shadow = XS1_PORT_8C;
on tile[1]: out port p_led0_slave = XS1_PORT_1K;
on tile[1]: out port p_led0_master = XS1_PORT_1C;
on tile[1]: out port p_led1_slave = XS1_PORT_1M;
on tile[1]: out port p_led1_master = XS1_PORT_4C;

void dso_led_app(){
  unsigned masterp, slavep;
  unsigned time;
  timer tmr;

  tmr :> time;
  while(1)
  {
    time += LIN_BIT_TIME / 10; //oversample by x10. About the limit for xscope at 19.2Kbps LIN baud rate
    masterp = peek(p_master_shadow);
    slavep = peek(p_slave_shadow);
#if USE_XSCOPE
    xscope_int(0, masterp);
#endif
    if (masterp & 0x04) p_led0_master <: 1;	//Poll txd and rxd activity pins and echo to LEDs
    else p_led0_master <: 0;
    if (masterp & 0x40) p_led1_master <: 1;
    else p_led1_master <: 0;

    if (slavep & 0x04) p_led0_slave <: 1;   //Poll txd and rxd activity pins and echo to LEDs
    else p_led0_slave <: 0;
    if (slavep & 0x40) p_led1_slave <: 1;
    else p_led1_slave <: 0;

    tmr when timerafter(time) :> void; //Wait until the next sample period
  }
}


int main() {
  chan c_ma2s;
#if ISBUS_NODE_COUNT == 2
  chan c_sa2s;
#endif
  par {
    on tile[1]: master_application(c_ma2s);
    on tile[1]: lin_rx_server(p_master_rxd, c_ma2s);
#if ISBUS_NODE_COUNT == 2
    on tile[1]: slave_application(c_sa2s);
    on tile[1]: lin_rx_server(p_slave_rxd, c_sa2s);
#endif
    on tile[1]: dso_led_app();
  }
  return 0;
}
