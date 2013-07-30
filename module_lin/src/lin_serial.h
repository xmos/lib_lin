#ifndef _lin_serial_h_
#define _lin_serial_h_

//Slave rx serial state machine states
typedef enum {
  SLAVE_RX_RESET = 0,
  SLAVE_RX_WAITING,
  SLAVE_RX_IN_PROGRESS,
  SLAVE_RX_START_BIT_ERROR,
  SLAVE_RX_STOP_BIT_ERROR,
  SLAVE_RX_BREAK_OK,
  SLAVE_RX_BYTE_OK,
  SLAVE_RX_TIMEOUT
} lin_serial_rx_state_t;

//Commands that can be sent to rx serial state machine core
typedef enum {
  SLAVE_RX_NO_COMMAND = 0,
  SLAVE_RX_RESET_COMMAND,
  SLAVE_RX_GET_STATUS_COMMAND,
  SLAVE_RX_GET_LAST_BYTE_COMMAND,
  SLAVE_RX_GET_NEXT_BYTE_COMMAND,
  SLAVE_RX_GET_BREAK_COMMAND
} lin_serial_rx_command_t;


/**
 * Send a break. This function will block until all bits have been transmitted
 * References lin_conf.h for length of break
 *
 * /param txd is the port on which to send the break
 * /no return value
 */
void lin_tx_break(out port txd);

/**
 * Send a byte. This function will block until all bits have been transmitted.
 * Automatically pads byte with start and stop bit, so 10 bits are sent.
 *
 * /param txd is the port on which to send the break.
 * /param tx_byte, byte to send
 * /no return value
 */
void lin_tx_byte(out port txd, unsigned char tx_byte);

/**
 * This is the serial rx server. Runs in it's own core and continuously looks
 * for bytes/break symbols. Communication is over channels to client functions
 * contained within lin_rx_client.
 * This function must be run in it's own core (within scope of a par).
 * One rx_server is required per node, either master or slave.
 *
 * /param rxd is the receieve port on which to listen for lin frames
 * /param c_a2rx is the channel over which the client communicates with the sever
 */
void lin_rx_server(in port rxd, chanend c_a2rx);

//Note all other serial rx functions accessed via lin_rx_client

#endif
