#include "lin_utils.h"
#include "lin_conf.h"
#include <print.h>

void lin_wait(unsigned int bit_periods){
  int timer_trigger;
  timer t_wait;
  t_wait :> timer_trigger;
  timer_trigger += bit_periods * LIN_BIT_TIME;
  t_wait when timerafter(timer_trigger) :> int;
}

unsigned char lin_set_id_parity_bits (unsigned char id){
  unsigned p0 = 0x00, p1 = 0x80;
  id &= 0x3f;
  for (int bit_ptr = 0; bit_ptr < 6; bit_ptr++){
    if ((bit_ptr == 0) || (bit_ptr == 1) || (bit_ptr == 2) || (bit_ptr == 4))
      if ((0x1 << bit_ptr) & id) p0 ^= 0x40;
    if ((bit_ptr == 1) || (bit_ptr == 3) || (bit_ptr == 4) || (bit_ptr == 5))
      if ((0x1 << bit_ptr) & id) p1 ^= 0x80;
  }
  id |= p0;
  id |= p1;
  return id;
}

unsigned char lin_calculate_checksum (lin_frame_t response, lin_checksum_style_t style){
  unsigned int checksum = 0;
  if (response.length > LIN_MAXIMUM_RESPONSE_LENGTH) response.length = LIN_MAXIMUM_RESPONSE_LENGTH;
  for (int byte_index = 0; byte_index < response.length; byte_index++){
    checksum += response.data[byte_index];
    if (checksum >= 256) checksum -= 255;
  }
  if (style == LIN_CHECKSUM_ENHANCED){
    checksum += response.id;
    if (checksum >= 256) checksum -= 255;
  }
  return (~(unsigned char)checksum);
}

static unsigned int super_pattern(unsigned int &m) {
  crc32(m, 0xf, 0x82F63B78);
  return m;
}

void lin_make_random_frame(lin_frame_t &response, unsigned int seed){
  unsigned char length = LIN_MAXIMUM_RESPONSE_LENGTH;
  response.length = length; //maximum length response
  for (int i = 0; i < length; i++) response.data[i] = super_pattern(seed) % 256;
  response.id = super_pattern(seed) % 60;
  response.checksum = lin_calculate_checksum(response, LIN_CHECKSUM_CLASSIC);
}

static void print_error(lin_slave_error_t slave_err){
  switch (slave_err){
  case LIN_SUCCESS:
     break; //Only print if not successful
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

void print_slave_error(lin_slave_error_t slave_err){
  if (slave_err != LIN_SUCCESS){
    printstr("Slave error = ");
    print_error(slave_err);
  }
}

void print_master_error(lin_slave_error_t master_err){
  if (master_err != LIN_SUCCESS){
    printstr("Master error = ");
    print_error(master_err);
  }
}

void print_frame(lin_frame_t resp){
  int c;
  printstr("Frame ID = ");
  printhex(resp.id);
  printstr(", len = ");
  printhex(resp.length);
  printstr(",  d[0..");
  printhex(resp.length-1);
  printstr("] = ");
  for (c=0; c<resp.length; c++){
    printhex(resp.data[c]);
    printstr(", ");
  }
  printstr("chk = ");
  printhexln(resp.checksum);
}

int compare_frames(lin_frame_t frame_a, lin_frame_t frame_b){
  int same = 1;
  if (frame_a.length != frame_b.length) same = 0;
  for (int i=0; i < (frame_a.length > frame_b.length ? frame_a.length : frame_b.length); i++)
    if (frame_a.data[i] != frame_b.data[i]) same = 0;
  if (frame_a.checksum != frame_b.checksum) same = 0;
  return same;
}
