// Copyright (c) 2013-2016, XMOS Ltd, All rights reserved
#ifndef _lin_conf_h_
#define _lin_conf_h_

#include <xs1.h>

#define LIN_BAUD_RATE 9600 // In bits per second
#define LIN_BIT_TIME (XS1_TIMER_HZ / LIN_BAUD_RATE) // In timer ticks
#if (LIN_BAUD_RATE > 38400 || LIN_BAUD_RATE < 2400) // Note rate is bounded by transceiver specification
//#error Baud rate out of range. Please check lin_conf.h
#endif

// Port values for high/low. Useful in cases where LIN ports are on >1b port widths
#if LIN_HW_PLATFORM != sliceKIT_ISBUS
#define TX_RECESSIVE                    0x1
#define TX_DOMINANT                     0x0
#define RX_RECESSIVE                    0x1
#define RX_DOMINANT                     0x0
#else
#define TX_RECESSIVE                    0xf // Bits 3..0 = 1
#define TX_DOMINANT                     0xb // Bits 3, 1..0 = 1, bit 2 (txd) = 0
#define RX_RECESSIVE                    0x1 // Bits 3..1 = 0, bit 0 (rxd) = 0
#define RX_DOMINANT                     0x0 // Bits 3..0 = 0
#endif


// LIN frame timing parameters units are bit times unless specified
#define LIN_RESPONSE_SPACE              0   // Must be non-negative according to LIN spec
#define LIN_INTERBYTE_SPACE             0   // Must be non-negative according to LIN spec
#define LIN_INTERFRAME_SPACE            0   // Must be non-negative according to LIN spec
#define LIN_SYNCH_BREAK_BITS_MASTER     13  // Number bit periods to be transmitted for break
#define LIN_SYNCH_BREAK_THRESHOLD_SLAVE 11  // Number that need to be seen for a break detect
#define LIN_SYNCH_BREAK_DELIMIT         1   // Must be at least 1 according to LIN spec
#define LIN_SLEEP_DELAY                 4000// Slave timeout for sleep in milliseconds
#define LIN_MESSAGE_TIMEOUT             100 // In milliseconds. How long to wait until giving up

// LIN Byte commands and descriptions
#define LIN_MAXIMUM_RESPONSE_LENGTH     8   // Maximum number of data bytes per LIN frame
#define LIN_SYNCH_BYTE                  0x55// Synch byte in header

#endif
