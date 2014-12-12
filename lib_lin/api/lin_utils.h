#ifndef _lin_utils_h_
#define _lin_utils_h_
#include "lin_types.h"

/**
 * Waits for a number of bit periods. Blocks until done.
 *
 * /param bit_periods number of bit periods to wait
 */
void lin_wait(unsigned int bit_periods);

/**
 * Reads bottom 6 bits of id byte and sets the two top bits according to
 * the lin parity calculation standard.
 *
 * /param id - byte to check party of
 * /returns the same bottom 6 bits with two top bits set by parity calculation
 */
unsigned char lin_set_id_parity_bits (unsigned char id);

/**
 * Reads number of bytes (set by .length) in data field and calculates
 * the lin checksum according to standard. Returns 8b checksum.
 * Will include/not include .id byte depending on checksum style
 *
 * /param response - frame containing data and length to pass into calculation
 * /param style - classic or enhanced. Classic means don't include id, enhanced means include it
 * /returns the calculated checksum
 */
unsigned char lin_calculate_checksum (lin_frame_t response, lin_checksum_style_t style);

/**
 * Generates a random frame of length LIN_MAXIMUM_RESPONSE_LENGTH based on a random seed
 * Also initialises length and checksum fields so frames are valid.
 *
 * /param response - frame variable to copy calculated random into
 * /param seed - initial value for the random number generator
 */
void lin_make_random_frame(lin_frame_t &response, unsigned int seed);

/**
 * Prints error code to console if it isn't "LIN_SUCCESS". Prefixes with "slave"

 * /param slave_err - lin error code as defined in lin_types
 */
void print_slave_error(lin_slave_error_t slave_err);

/**
 * Prints error code to console if it isn't "LIN_SUCCESS". Prefixes with "master"

 * /param master_err - lin error code as defined in lin_types
 */
void print_master_error(lin_slave_error_t master_err);

/**
 * Prints a frame to console

 * /param response - frame to print
 */
void print_frame(lin_frame_t resp);

/**
 * Compares contents of two lin frames, not including ID

 * /param frame_a frame to compare
 * /param frame_b frame to compare
 * /retruns result of comparison 0 = false, 1 = true
 */
int compare_frames(lin_frame_t frame_a, lin_frame_t frame_b);


#endif
