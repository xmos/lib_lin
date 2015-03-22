// Copyright (c) 2015, XMOS Ltd, All rights reserved
#include <xs1.h>
#include "lin_utils.h"
#include <print.h>

void lin_wait(unsigned int bit_periods) {
  int timer_trigger;
  timer t_wait;
  t_wait :> timer_trigger;
  timer_trigger += bit_periods * LIN_BIT_TIME;
  t_wait when timerafter(timer_trigger) :> int;
}

unsigned char lin_set_id_parity_bits (unsigned char id) {
  unsigned p0 = 0x00, p1 = 0x80;
  id &= 0x3f;
  for (int bit_ptr = 0; bit_ptr < 6; bit_ptr++) {
    if ((bit_ptr == 0) || (bit_ptr == 1) || (bit_ptr == 2) || (bit_ptr == 4)) {
      if ((0x1 << bit_ptr) & id) { p0 ^= 0x40; }
    }
    if ((bit_ptr == 1) || (bit_ptr == 3) || (bit_ptr == 4) || (bit_ptr == 5)) {
      if ((0x1 << bit_ptr) & id) { p1 ^= 0x80; }
    }
  }
  id |= p0;
  id |= p1;
  return id;
}

unsigned char lin_calculate_checksum (lin_frame_t response, lin_checksum_style_t style) {
  unsigned int checksum = 0;
  if (response.length > LIN_MAXIMUM_RESPONSE_LENGTH) { response.length = LIN_MAXIMUM_RESPONSE_LENGTH; }
  for (int byte_index = 0; byte_index < response.length; byte_index++) {
    checksum += response.data[byte_index];
    if (checksum >= 256) { checksum -= 255; }
  }
  if (style == LIN_CHECKSUM_ENHANCED) {
    checksum += response.id;
    if (checksum >= 256) { checksum -= 255; }
  }
  return (~(unsigned char)checksum);
}
