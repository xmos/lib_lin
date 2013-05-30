#include "lin_master.h"
#include "lin_serial.h"
#include "lin_rx_client.h"
#include "lin_types.h"
#include "lin_utils.h"
#include "lin_conf.h"

lin_slave_error_t lin_master_init(out port p_master_txd, chanend c_a2rx){

  p_master_txd <: TX_RECESSIVE;
  return lin_rx_reset (c_a2rx);
}


lin_slave_error_t lin_master_send_frame(lin_frame_t tx_frame, out port p_master_txd, chanend c_a2rx){

  unsigned char rx_byte;
  lin_slave_error_t return_error = LIN_ERR_INVALID;
  lin_serial_rx_state_t rx_state;

  //send header. No error checking
  lin_tx_break(p_master_txd);
  lin_tx_byte (p_master_txd, LIN_SYNCH_BYTE);
  lin_wait(LIN_SYNCH_BREAK_DELIMIT);
  lin_tx_byte (p_master_txd, lin_set_id_parity_bits(tx_frame.id));

  lin_wait(LIN_RESPONSE_SPACE);

  //Send data/response, and check to see if the right values were seen on the lin bus
  for(int tx_counter = 0; tx_counter < tx_frame.length; tx_counter++){
    lin_tx_byte (p_master_txd, tx_frame.data[tx_counter]);
    rx_state = lin_rx_get_last_byte(rx_byte, c_a2rx);
    if ((rx_state == SLAVE_RX_START_BIT_ERROR) || (rx_state == SLAVE_RX_STOP_BIT_ERROR)){
      return_error = LIN_ERR_FRAMING;
      return return_error;
    }
    if (rx_byte != tx_frame.data[tx_counter]){
         return_error = LIN_ERR_READBACK;
         return return_error;
       }
    lin_wait(LIN_INTERBYTE_SPACE);
  }

  lin_tx_byte (p_master_txd, tx_frame.checksum);
  rx_state = lin_rx_get_last_byte (rx_byte, c_a2rx);
  if ((rx_state == SLAVE_RX_START_BIT_ERROR) || (rx_state == SLAVE_RX_STOP_BIT_ERROR))
    return_error = LIN_ERR_FRAMING;
  if (rx_state == SLAVE_RX_BYTE_OK){
    if (rx_byte!= tx_frame.checksum) return_error = LIN_ERR_READBACK;
    else return_error = LIN_SUCCESS;
  }
  return return_error;
}


lin_slave_error_t lin_master_request_frame(lin_frame_t &rx_frame, out port p_master_txd, chanend c_a2rx){

  unsigned char rx_byte;
  lin_slave_error_t return_error = LIN_ERR_INVALID;
  lin_serial_rx_state_t rx_state;

  lin_tx_break(p_master_txd);
  lin_tx_byte (p_master_txd, LIN_SYNCH_BYTE);
  lin_wait(LIN_SYNCH_BREAK_DELIMIT);
  lin_tx_byte (p_master_txd, lin_set_id_parity_bits(rx_frame.id));

  for(int rx_counter = 0; rx_counter < rx_frame.length; rx_counter++){
    lin_rx_return_next_byte_cmd (c_a2rx);
    rx_state = lin_rx_wait_for_byte (rx_byte, c_a2rx);
    if ((rx_state == SLAVE_RX_START_BIT_ERROR) || (rx_state == SLAVE_RX_STOP_BIT_ERROR)){
      return LIN_ERR_FRAMING;

    }
    if ((rx_state == SLAVE_RX_TIMEOUT) && (rx_counter == 0)) return LIN_ERR_NO_RESPONSE;
    if ((rx_state == SLAVE_RX_TIMEOUT) && (rx_counter > 0)) return LIN_ERR_LAST_FRAME_RESPONSE_TOO_SHORT;
    rx_frame.data[rx_counter] = rx_byte;
  }

  lin_rx_return_next_byte_cmd (c_a2rx);
  rx_state = lin_rx_wait_for_byte (rx_byte, c_a2rx);
  if ((rx_state == SLAVE_RX_START_BIT_ERROR) || (rx_state == SLAVE_RX_STOP_BIT_ERROR))
    return_error = LIN_ERR_FRAMING;
  if (rx_state == SLAVE_RX_TIMEOUT) return_error = LIN_ERR_LAST_FRAME_RESPONSE_TOO_SHORT;
  if (rx_state == SLAVE_RX_BYTE_OK){
    if (rx_byte!= lin_calculate_checksum(rx_frame, LIN_CHECKSUM_CLASSIC)) return_error = LIN_ERR_CHECKSUM;
    else return_error = LIN_SUCCESS;
    rx_frame.checksum = rx_byte;
  }
  return return_error;
}

