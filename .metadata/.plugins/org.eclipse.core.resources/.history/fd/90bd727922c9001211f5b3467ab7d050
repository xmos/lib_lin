#ifndef _lin_master_h_
#define _lin_master_h_
#include "lin_types.h"
#include "lin_utils.h"
#include "lin_serial.h"

/**
 * Initialises the lin master. Sets the txd pin to recessive and resets
 * the serial rx server.
 *
 * /param p_master_txd is the master tx port on which to transmit both
 * headers and data.
 * /param c_a2rx is the channel for client communications with the rx sever
 * /returns lin_slave_error type
 */
lin_slave_error_t lin_master_init(out port p_master_txd, chanend c_a2rx);

/**
 * Sends a header consistig of break, synch and id. Then sends the array
 * of data, inlcuding checksum, contained in the lin_frame passed to it.
 * Listens to see if response section is correctly seen on bus and
 * returns an error code if not successful. Blocks until last bit transmitted
 *
 * /param tx_response is the stucture to send containing id, bytes & checksum
 * /param p_master_txd is the master tx port on which to transmit both
 *  headers and data.
 * /param c_a2rx is the channel for client communications with the rx sever
 * /returns lin_slave_error type
 */
lin_slave_error_t lin_master_send_frame(lin_frame_t tx_response, out port p_master_txd, chanend c_a2rx);

/**
 * Sends a header consistig of break, synch and id. Then receives an array
 * of data, including checksum and copies that into the lin_frame passed to it.
 * Note that the number of bytes expected must be setup in tx_response.length
 * before hand to allow this function to know how many bytes to receive.
 * Checks for start/stop bit errors, incorrect checksum and timeout
 * returns an error code as appropriate. Blocks until last bit is received, or
 * a time out occurs
 *
 * /param tx_response is the stucture conytaining id, byte,
 * /param p_master_txd is the master tx port on which to transmit both
 *  headers and data.
 * /param c_a2rx is the channel for client communications with the rx sever
 * /returns lin_slave_error type
 */
lin_slave_error_t lin_master_request_frame(lin_frame_t &rx_response, out port p_master_txd, chanend c_a2rx);
#endif

