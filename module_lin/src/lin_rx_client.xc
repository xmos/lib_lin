#include "lin_rx_client.h"
#include "lin_types.h"

lin_serial_rx_state_t lin_rx_reset (chanend c_a2s)
  {
    lin_serial_rx_state_t serial_rx_state;
    c_a2s <: SLAVE_RX_RESET_COMMAND;
    c_a2s :> serial_rx_state;
    return serial_rx_state;
  }

lin_serial_rx_state_t lin_rx_return_next_byte_cmd (chanend c_a2s)
{
  lin_serial_rx_state_t serial_rx_state;
  c_a2s <: SLAVE_RX_GET_NEXT_BYTE_COMMAND;
  c_a2s :> serial_rx_state;
  return serial_rx_state;
}

lin_serial_rx_state_t lin_rx_look_for_break_cmd (chanend c_a2s)
{
  lin_serial_rx_state_t serial_rx_state;
  c_a2s <: SLAVE_RX_GET_BREAK_COMMAND;
  c_a2s :> serial_rx_state;
  return serial_rx_state;
}

lin_serial_rx_state_t lin_rx_wait_for_byte (unsigned char &rxw, chanend c_a2s)
{
  lin_serial_rx_state_t serial_rx_state;
  c_a2s :> serial_rx_state;
  c_a2s :> rxw;
  return serial_rx_state;
}

lin_serial_rx_state_t lin_rx_wait_for_break (chanend c_a2s)
{
  lin_serial_rx_state_t serial_rx_state;
  c_a2s :> serial_rx_state;
  return serial_rx_state;
}

lin_serial_rx_state_t lin_rx_get_last_byte (unsigned char &rxw, chanend c_a2s)
{
  lin_serial_rx_state_t serial_rx_state;
  c_a2s <: SLAVE_RX_GET_LAST_BYTE_COMMAND;
  c_a2s :> rxw;
  c_a2s :> serial_rx_state;
  return serial_rx_state;
}

lin_serial_rx_state_t lin_rx_get_status (chanend c_a2s)
{
  lin_serial_rx_state_t serial_rx_state;
  c_a2s <: SLAVE_RX_GET_STATUS_COMMAND;
  c_a2s :> serial_rx_state;
  return serial_rx_state;
}


