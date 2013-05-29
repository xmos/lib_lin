#ifndef _lin_slave_client_h_
#define _lin_slave_client_h_

#include "lin_serial.h"

/**
 * First command of two part sequence. This tells the serial rx server
 * send the next received byte to the client. This command must
 * only be used with lin_rx_wait_for_byte called shortly afterwards otherwise
 * rx server will block until byte is read/accepted.
 *
 * /param c_a2s channel end over which to send the command
 * /returns lin_serial_rx_state - rx server status
 */
lin_serial_rx_state_t lin_rx_return_next_byte_cmd (chanend c_a2s);

/**
 * Second command of two part sequence. This function causes the client
 * to wait until the byte previously requested is received from the server.
 * Must only be used with lin_rx_return_next_byte_cmd called previously otherwise
 * this function will block, waiting for a byte to be sent.
 *
 * /param c_a2s channel end over which to send the command
 * /param rxw unsigned char to copy the byte value into
 * /returns lin_serial_rx_state - rx server status
 */
lin_serial_rx_state_t lin_rx_wait_for_byte (unsigned char &rxw, chanend c_a2s);

/**
 * First command of two part sequence. This tells the serial rx server
 * detect the next break symbol (ignoring the inevitable stop bit error) and notfiy
 * the client when this has happened. This command must only be used with
 * lin_rx_wait_for_break function called shortly afterwards otherwise the
 * rx server will block until break notification is read/accepted.
 *
 * /param c_a2s channel end over which to send the command
 * /returns lin_serial_rx_state - rx server status
 */
lin_serial_rx_state_t lin_rx_look_for_break_cmd (chanend c_a2s);

/**
 * Second command of two part sequence. This causes client
 * to wait until the previously requested break notificatio is received from the server.
 * Must only be used with lin_rx_look_for_break_cmd called previously otherwise
 * this function will block, waiting for a break notification to be sent.
 *
 * /param c_a2s channel end over which to send the command
 * /returns lin_serial_rx_state - rx server status
 */
lin_serial_rx_state_t lin_rx_wait_for_break (chanend c_a2s);

/**
 * Fetches the last received byte from the serial rx server.
 * Can be called at any time and will always return the last received byte,
 * regardless of start/stop bit errors. Non-blocking.
 * If called before any byte has been receieved, it will return an unitilialised value.
 * Can be called immediately after tx command as long as round trip latency through
 * physical later is less than half a bit period.
 * /param c_a2s channel end over which to send the command/return byte
 * /returns lin_serial_rx_state - rx server status
 */
lin_serial_rx_state_t lin_rx_get_last_byte (unsigned char &rxw, chanend c_a2s);

/**
 * Returns the state of the serial rx server state machine.
 * Non-blocking
 *
 * /param c_a2s channel end over which to send the command
 * /returns lin_serial_rx_state - rx server status
 */
lin_serial_rx_state_t lin_rx_get_status (chanend c_a2s);

/**
 * Aborts any bytes reception and resets rx server state machine.
 *
 * /param c_a2s channel end over which to send the command
 * /returns lin_serial_rx_state - rx server status
 */
lin_serial_rx_state_t lin_rx_reset (chanend c_a2s);

#endif
