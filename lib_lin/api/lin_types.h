#ifndef _lin_types_h_
#define _lin_types_h_
#include "lin_conf.h"

//response section of frame structure
typedef struct {
  unsigned char data[LIN_MAXIMUM_RESPONSE_LENGTH];
  unsigned char length;
  unsigned char checksum;
  unsigned char id;
} lin_frame_t;

//Checksum style. Classic checks data response bytes only.
//Enhanced checks data bytes and also ID byte
typedef enum {
  LIN_CHECKSUM_CLASSIC,
  LIN_CHECKSUM_ENHANCED
} lin_checksum_style_t;


//Lin slave state machine states
typedef enum {
  LIN_SLAVE_IDLE = 0,
  LIN_SLAVE_RECEIVE_PID,
  LIN_SLAVE_SYNCH_BREAK_OK,
  LIN_SLAVE_RX_DATA,
  LIN_SLAVE_RX_CHECKSUM,
  LIN_SLAVE_TX_DATA,
  LIN_SLAVE_TX_CHECKSUM
} lin_slave_state_t;

//Lin slave state machine error codes
typedef enum {
  LIN_SUCCESS = 0,
  LIN_ERR_READBACK,
  LIN_ERR_CHECKSUM,
  LIN_ERR_ID_PARITY,
  LIN_ERR_NO_RESPONSE,
  LIN_ERR_LAST_FRAME_RESPONSE_TOO_SHORT,
  LIN_ERR_BAD_SYNCH,
  LIN_ERR_UNKNOWN_PID,
  LIN_ERR_FRAMING,
  LIN_ERR_INVALID //for debugging. Illegal error should never be returned
} lin_slave_error_t;

#endif




