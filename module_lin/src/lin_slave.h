#ifndef _lin_slave_h_
#define _lin_slave_h_
#include "lin_types.h"
#include "lin_utils.h"
#include "lin_serial.h"

/**
 * Initialises the lin slave. Sets the txd pin to recessive and resets
 * the serial rx server.
 *
 * /param p_slave_txd is the slave tx port that transmits data.
 * /param c_a2rx is the channel for client communications with the rx sever
 * /returns lin_slave_error type
 */
lin_slave_error_t lin_slave_init(out port p_slave_txd, chanend c_a2rx);

/**
 * Waits for valid header consisting of break, synch and id.
 * Will keep listening until valid break/synch receieved. It will then receive
 * the id word and will copy it into the id argument passed to it.
 * Reports an error if there is a start/stop bit error, parity error or timeout
 *
 * /param c_a2rx is the channel for client communications with the rx sever
 * /param &id is the id word (lower 6 bits) which is received by this function
 * /returns lin_slave_error type
 */
lin_slave_error_t lin_slave_wait_for_header(chanend c_a2rx, unsigned char &id);

/**
 * Sends a response array consisting of data, inlcuding checksum, contained
 * in the lin_frame passed to it.
 * Listens to see if response section is correctly seen on bus and
 * returns an error code if not successful. Blocks until last bit transmitted.
 *
 * /param p_slave_txd is the slave tx port on which to transmit data.
 * /param c_a2rx is the channel for client communications with the rx sever
 * /param tx_response is the stucture to send containing bytes & checksum
 * /returns lin_slave_error type
 */
lin_slave_error_t lin_slave_send_response(out port p_slave_txd, chanend c_a2rx, lin_frame_t tx_response);

/**
 * Gets a response array consisting of data, inlcuding checksum, and
 * copies it into the lin_frame passed to it. Blocks until checksum received or timeout.
 * Reports an error if there is a start/stop bit error, parity error or timeout
 *
 * /param c_a2rx is the channel for client communications with the rx sever
 * /param rx_response is the stucture to copy the received bytes & checksum
 * /returns lin_slave_error type
 */
lin_slave_error_t lin_slave_get_response(chanend c_a2rx, lin_frame_t &rx_response);

#endif
