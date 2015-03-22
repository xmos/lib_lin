// Copyright (c) 2015, XMOS Ltd, All rights reserved
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
 * the LIN parity calculation standard.
 *
 * /param id - byte to check party of
 * /returns the same bottom 6 bits with two top bits set by parity calculation
 */
unsigned char lin_set_id_parity_bits (unsigned char id);

/**
 * Reads number of bytes (set by .length) in data field and calculates
 * the LIN checksum according to standard. Returns 8b checksum.
 * Will include/not include .id byte depending on checksum style
 *
 * /param response - frame containing data and length to pass into calculation
 * /param style - classic or enhanced. Classic means don't include id, enhanced means include it
 * /returns the calculated checksum
 */
unsigned char lin_calculate_checksum (lin_frame_t response, lin_checksum_style_t style);

#endif // _lin_utils_h_
