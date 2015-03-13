// Copyright (c) 2015, XMOS Ltd, All rights reserved
#include <platform.h>
#include <xscope.h>
#include <print.h>

#define ISBUS_NODE_COUNT 1  // Number of ISBUS slices connected.
                            // Choose 1 for master only demo, 2 for master & slave
#include "lin_master.h"
#include "lin_serial.h"
#include "lin_utils.h"
#if ISBUS_NODE_COUNT == 2
#include "lin_slave.h"
#endif


#define USE_XSCOPE 1

on tile[1]: out port p_master_txd = XS1_PORT_4A;
on tile[1]: in port p_master_rxd = XS1_PORT_4B;
#if ISBUS_NODE_COUNT == 2
on tile[1]: out port p_slave_txd = XS1_PORT_4E;
on tile[1]: in port p_slave_rxd = XS1_PORT_4F;
#endif

#if USE_XSCOPE
void xscope_user_init(void) {
  xscope_config_io(XSCOPE_IO_BASIC); // Fast, low intrusive printing via xSCOPE
  xscope_register(1, XSCOPE_CONTINUOUS, "LIN bus master node port", XSCOPE_UINT, "Port val");
}
#endif

static unsigned int super_pattern(unsigned int &m) {
  crc32(m, 0xf, 0x82F63B78);
  return m;
}

/**
 * Generates a random frame of length LIN_MAXIMUM_RESPONSE_LENGTH based on a random seed
 * Also initialises length and checksum fields so frames are valid.
 *
 * /param response - frame variable to copy calculated random into
 * /param seed - initial value for the random number generator
 */
static void make_random_frame(lin_frame_t &response, unsigned int seed) {
  unsigned char length = LIN_MAXIMUM_RESPONSE_LENGTH;
  response.length = length; // Maximum length response
  for (int i = 0; i < length; i++) response.data[i] = super_pattern(seed) % 256;
  response.id = super_pattern(seed) % 60;
  response.checksum = lin_calculate_checksum(response, LIN_CHECKSUM_CLASSIC);
}

static void print_error(lin_slave_error_t slave_err) {
  switch (slave_err) {
  case LIN_SUCCESS:
    break; // Only print if not successful
  case LIN_ERR_READBACK:
    printstrln("LIN_ERR_READBACK");
    break;
  case LIN_ERR_CHECKSUM:
    printstrln("LIN_ERR_CHECKSUM");
    break;
  case LIN_ERR_ID_PARITY:
    printstrln("LIN_ERR_ID_PARITY");
     break;
  case LIN_ERR_NO_RESPONSE:
    printstrln("LIN_ERR_NO_RESPONSE");
    break;
  case LIN_ERR_LAST_FRAME_RESPONSE_TOO_SHORT:
    printstrln("LIN_ERR_LAST_FRAME_RESPONSE_TOO_SHORT");
    break;
  case LIN_ERR_BAD_SYNCH:
    printstrln("LIN_ERR_BAD_SYNCH");
    break;
  case LIN_ERR_UNKNOWN_PID:
    printstrln("LIN_ERR_UNKNOWN_PID");
    break;
  case LIN_ERR_FRAMING:
    printstrln("LIN_ERR_FRAMING");
    break;
  default:
    printstr(" other error code 0x");
    printhexln(slave_err);
    break;
  }
}

/**
 * Prints error code to console if it isn't "LIN_SUCCESS". Prefixes with "slave"
 *
 * /param slave_err - LIN error code as defined in lin_types
 */
void print_slave_error(lin_slave_error_t slave_err) {
  if (slave_err != LIN_SUCCESS) {
    printstr("Slave error = ");
    print_error(slave_err);
  }
}

/**
 * Prints error code to console if it isn't "LIN_SUCCESS". Prefixes with "master"
 *
 * /param master_err - LIN error code as defined in lin_types
 */
void print_master_error(lin_slave_error_t master_err) {
  if (master_err != LIN_SUCCESS) {
    printstr("Master error = ");
    print_error(master_err);
  }
}

/**
 * Prints a frame to console
 *
 * /param response - frame to print
 */
void print_frame(lin_frame_t resp) {
  int c;
  printstr("Frame ID = ");
  printhex(resp.id);
  printstr(", len = ");
  printhex(resp.length);
  printstr(",  d[0..");
  printhex(resp.length-1);
  printstr("] = ");
  for (c=0; c<resp.length; c++) {
    printhex(resp.data[c]);
    printstr(", ");
  }
  printstr("chk = ");
  printhexln(resp.checksum);
}

/**
 * Compares contents of two LIN frames, not including ID
 *
 * /param frame_a frame to compare
 * /param frame_b frame to compare
 * /retruns result of comparison 0 = false, 1 = true
 */
int compare_frames(lin_frame_t frame_a, lin_frame_t frame_b) {
  int same = 1;
  if (frame_a.length != frame_b.length) { same = 0; }
  for (int i=0; i < (frame_a.length > frame_b.length ? frame_a.length : frame_b.length); i++) {
    if (frame_a.data[i] != frame_b.data[i]) { same = 0; }
  }
  if (frame_a.checksum != frame_b.checksum) { same = 0; }
  return same;
}

void master_application(out port p_txd, chanend c_ma2s) {
  lin_frame_t tx_frame;                         // Declare a LIN frame for tx
#if ISBUS_NODE_COUNT == 2
  lin_frame_t rx_frame;                         // Declare a LIN frame for rx
#endif
  unsigned int seed = 0x55378008;               // Random number seed
  lin_slave_error_t msg_error;                  // Error code from frame transfer
  int next_frame_time, done_once = 0;
  timer t;

  lin_master_init(p_txd, c_ma2s);               // Initialise TX pin (RX already done by rx_sever core)
  t :> next_frame_time;                         // Get current time
#if ISBUS_NODE_COUNT == 2
  printstrln("LIN bus master and slave, 2 x ISBUS slices, demo app started.");
#else
  printstrln("LIN bus master, 1 x ISBUS slice, demo app started.");
#endif

  while(1) {
    make_random_frame(tx_frame, seed);          // Create data to send to slave
    tx_frame.id = 0x19;                         // Set ID to instruct slave to receive data

    t when timerafter(next_frame_time) :> void; // Wait for next slot
    msg_error = lin_master_send_frame(tx_frame, p_txd, c_ma2s); // Send frame
    print_master_error(msg_error);              // Print if error
    if ((msg_error == LIN_SUCCESS) && !done_once) {
      printstrln("First master frame sent with no payload errors detected");
    }
    done_once = 1;
    next_frame_time += 25000000;                // Add 250ms

#if ISBUS_NODE_COUNT == 2
    make_random_frame(rx_frame, ~seed);         // Create data to overwrite on receive, including setting length field
    rx_frame.id = 0x24;                         // Set ID to instruct slave to send response

    t when timerafter(next_frame_time) :> void; // Wait for next slot
    print_master_error(lin_master_request_frame(rx_frame, p_txd, c_ma2s)); //get response from slave and print if error
    next_frame_time += 25000000;                // Add 250ms
    seed++;                                     // Make sure the next random frame is different

    if (! compare_frames(rx_frame, tx_frame)) { // Check to see the frame made the round trip
      printstr("Sent buffer    - ");            // If they are different, show tx and rx frames
      print_frame(tx_frame);
      printstr("Receive buffer - ");
      print_frame(rx_frame);                    // Note that rx frame is initialised to random
    }
#endif
  }
}

#if ISBUS_NODE_COUNT == 2
void slave_application (out port p_txd, chanend c_sa2s) {
  unsigned char id;
  lin_frame_t slave_frame;                      // Declare a LIN frame
  unsigned int seed = 0x33357406;               // Random number seed

  make_random_frame(slave_frame, seed);         // Initialise frame with random contents
  lin_slave_init(p_txd, c_sa2s);                // Initialise slave tx port and rx server

  while(1) {
    print_slave_error(lin_slave_wait_for_header(c_sa2s, id)); // Wait until header received and get id

    switch(id) {                                // Either receive or transmit frame depending on id

    case 0x19:                                  // 0x19 means receieve data
      print_slave_error(lin_slave_get_response(c_sa2s, slave_frame)); //Get response section of frame
      break;

    case 0x24:                                  // 0x24 means transmit data
      print_slave_error(lin_slave_send_response(p_txd, c_sa2s, slave_frame)); //Send it back to master
      break;
    }
  }
}
#endif

// Non-intrusive sniffer task to monitor rxd & txd for master and slave pin activity
// Samples ports overlaid with rx and tx and sends to xSCOPE and LEDs on ISBUS boards
on tile[1]: in port p_master_shadow = XS1_PORT_8A;
on tile[1]: in port p_slave_shadow = XS1_PORT_8C;
on tile[1]: out port p_led0_slave = XS1_PORT_1K;
on tile[1]: out port p_led0_master = XS1_PORT_1C;
on tile[1]: out port p_led1_slave = XS1_PORT_1M;
on tile[1]: out port p_led1_master = XS1_PORT_4C;

void dso_led_app() {
  unsigned masterp, slavep;
  unsigned time;
  timer tmr;

  tmr :> time;
  while(1)
  {
    time += LIN_BIT_TIME / 10;              // Oversample by 10x. This is the limit for xSCOPE at 19.2Kbps
    masterp = peek(p_master_shadow);        // Read the master's port (8b port includes txd & rxd)
    slavep = peek(p_slave_shadow);
#if USE_XSCOPE
    xscope_int(0, masterp);                 // Send data to xSCOPE
#endif
    if (masterp & 0x04) p_led0_master <: 1; // Poll txd and rxd activity pins and echo to LEDs
    else p_led0_master <: 0;
    if (masterp & 0x40) p_led1_master <: 1;
    else p_led1_master <: 0;

    if (slavep & 0x04) p_led0_slave <: 1;   // Poll txd and rxd activity pins and echo to LEDs
    else p_led0_slave <: 0;
    if (slavep & 0x40) p_led1_slave <: 1;
    else p_led1_slave <: 0;

    tmr when timerafter(time) :> void;      // Wait until the next sample period
  }
}

int main() {
  chan c_ma2s;                              // Channel connecting master application to master LIN node
#if ISBUS_NODE_COUNT == 2
  chan c_sa2s;                              // Channel connecting slave application to slave LIN node
#endif                                      //Note - no channel connection between master and slave apps
  par {
    on tile[1]: master_application(p_master_txd, c_ma2s);
    on tile[1]: lin_rx_server(p_master_rxd, c_ma2s);
#if ISBUS_NODE_COUNT == 2
    on tile[1]: slave_application(p_slave_txd, c_sa2s);
    on tile[1]: lin_rx_server(p_slave_rxd, c_sa2s);
#endif
    on tile[1]: dso_led_app();              // Optional monitor task for debug purposes
  }
  return 0;
}
