.. _sec_api:

LIN Bus API
===========

.. _sec_conf_defines:

Configuration Defines
---------------------

The file ``lin_conf.h`` must be provided in the application source code, and it must define:

LIN_BAUD_RATE

in order to set the speed of the LIN bus communication. It can also be used to modify frame timing parameters and port values for high and low (useful in the case of multi bit ports being used instead of 1b ports).

``LIN_BAUD_RATE``
     - Baud rate in bits per second.

``TX_RECESSIVE``
     - Port value for recessive bit on Tx

``TX_DOMINANT``
     - Port value for dominant bit on Tx

``RX_RECESSIVE``
     - Port value for recessive bit on Rx

``RX_DOMINANT``
     - Port value for dominant bit on Rx

``LIN_RESPONSE_SPACE``
     - Gap between ID and response in bit periods

``LIN_INTERBYTE_SPACE``
     - Gap between bytes in bit periods

``LIN_INTERFRAME_SPACE``
     - Gap between LIN frames in bit periods

``LIN_SYNCH_BREAK_BITS_MASTER``
     - Number of break bit periods (13 normally)

``LIN_SYNCH_BREAK_THRESHOLD_SLAVE``
     - Number of bits before slave sees a break

``LIN_SYNCH_BREAK_DELIMIT``
     - Gap between synch and break in bit periods

``LIN_MESSAGE_TIMEOUT``
     - Maximum time in milliseconds before master gives up on slave

``LIN_MAXIMUM_RESPONSE_LENGTH``
     - Maximum number of data bytes in a frame

``LIN_SYNCH_BYTE``
     - Synch byte value - normally 0x55


Port Config
+++++++++++

Ports are declared within the main application and are passed to the master/slave function calls and associated lin_rx_server. Each node requires a lin_rx_server core/task to handle receive, timeout and break detection.

LIN Bus API - Master
--------------------

These are the functions that are called from the application and are included in ``lin_master.h``.

.. doxygenfunction:: lin_master_init
.. doxygenfunction:: lin_master_send_frame
.. doxygenfunction:: lin_master_request_frame
.. doxygenfunction:: lin_rx_server




LIN Bus API - Slave
--------------------

These are the functions that are called from the application and are included in ``lin_slave.h``.

.. doxygenfunction:: lin_slave_init
.. doxygenfunction:: lin_slave_wait_for_header
.. doxygenfunction:: lin_slave_send_response
.. doxygenfunction:: lin_slave_get_response
.. doxygenfunction:: lin_rx_server

