.. include:: ../../../README.rst

Usage
-----

The following header file contains prototypes of all functions
required to use the LIN Bus  module. The API is described in :ref:`lin_api`.

.. list-table:: Key Files
  :header-rows: 1

  * - File
    - Description
  * - ``lin_master.h``
    - LIN bus master API header file
  * - ``lin_slave.h``
    - LIN bus slave API header file


Create a file in the ``app`` folder called ``lin_conf.h`` and modify
the ``LIN_BAUD_RATE`` setting is set according to your needs.

Next, if the ports you are using are wider than 1b (ie. 4b ports), set the appropriate bit fields defining which pin is connected to rxd/txd on the transceiver. This should be done within ``lin_conf.h`` and can look like this::

      #define TX_RECESSIVE 0xf //bits 3..0 = 1
      #define TX_DOMINANT 0xb  //bits 3, 1..0 = 1, bit 2 (txd) = 0
      #define RX_RECESSIVE 0x1 //bits 3..1 = 0, bit 0 (rxd) = 0
      #define RX_DOMINANT 0x0  //bits 3..0 = 0

Declare the ports used by the LIN bus API and ``lin_rx_server`` in the main application code. This may look something like this (1b ports shown for master and slave)::

      out port p_master_txd = XS1_PORT_1A;
      in port  p_master_rxd = XS1_PORT_1B;

      out port  p_slave_txd = XS1_PORT_1C;
      in port   p_slave_rxd = XS1_PORT_1D;

Next create a ``main`` function with a par of both the ``lin_server`` task and an application task. These will require a channel to connect them for communication. For example::

	int main() {
	  chan c_app_to_lin_master;
	  par {
	    lin_rx_server(p_master_rxd, c_app_to_lin_master);
	    application(c_app_to_lin_master);
	  }
	  return 0;
	}

Now the ``application`` task is able to use the LIN bus master receive task, as well as call tx functions.

|newpage|

To setup a LIN slave within the application, follow exactly the same procedure as above, changing the port and channel names as appropriate. The main statement may look like this::

	int main() {
	  chan c_app_to_lin_slave;
	  par {
	    lin_rx_server(p_slave_rxd, c_app_to_lin_slave);
	    application(c_app_to_lin_slave);
	  }
	  return 0;
	}

.. _lin_api:

API
---

Each LIN bus node is presented via a simple API allowing the transmission and reception of frames. Receive functions are presented via a wrapper that handles communication to a dedicated core that deals with LIN specific UART Rx task. Consequently each node requires an instance of lin_rx_server is required within an XC par statement.

Configuration Defines
.....................

The file ``lin_conf.h`` must be included in the application source code, and it must define::

 LIN_BAUD_RATE

in order to set the speed of the LIN bus communication. The file ``lin_conf.h`` can also be used to modify frame timing parameters as well port values for high and low. Defining port values is useful in the case of multi bit ports being used instead of 1b ports.

**LIN_BAUD_RATE**: Baud rate in bits per second

**TX_RECESSIVE**: Port value for recessive bit on Tx

**TX_DOMINANT**: Port value for dominant bit on Tx

**RX_RECESSIVE**: Port value for recessive bit on Rx

**RX_DOMINANT**: Port value for dominant bit on Rx

**LIN_RESPONSE_SPACE**: Gap between ID and response in bit periods

**LIN_INTERBYTE_SPACE**: Gap between bytes in bit periods

**LIN_INTERFRAME_SPACE**: Gap between LIN frames in bit periods

**LIN_SYNCH_BREAK_BITS_MASTER**: Number of break bit periods sent

**LIN_SYNCH_BREAK_THRESHOLD_SLAVE**: Number of bits before slave sees a break 

**LIN_SYNCH_BREAK_DELIMIT**: Gap between synch and break in bit periods

**LIN_MESSAGE_TIMEOUT**: Maximum time in milliseconds before master gives up on slave

**LIN_MAXIMUM_RESPONSE_LENGTH**: Maximum number of data bytes in a frame

**LIN_SYNCH_BYTE**: Synch byte value - 0x55 as per the LIN spec

Port Configuration
..................

Ports are declared within the main application and are passed to the master/slave function calls and lin_rx_server. Each node requires a lin_rx_server core/task to handle receive, timeout and break detection.

|newpage|

Master API
..........

These are the functions that are called from the application and are included in ``lin_master.h``.

.. doxygenfunction:: lin_master_init
.. doxygenfunction:: lin_master_send_frame
.. doxygenfunction:: lin_master_request_frame
.. doxygenfunction:: lin_rx_server

|newpage|

Slave API
.........

These are the functions that are called from the application and are included in ``lin_slave.h``.

.. doxygenfunction:: lin_slave_init
.. doxygenfunction:: lin_slave_wait_for_header
.. doxygenfunction:: lin_slave_send_response
.. doxygenfunction:: lin_slave_get_response
.. doxygenfunction:: lin_rx_server

|appendix|

Known Issues
------------

 * Autobaud function in the slave is not implemented.
   xCORE systems have a precise reference clock removing the need for
   this feature
 * LIN Rx pin requires it's own logical port (eg. 1b port or 4b
   port).  In the case where a >1b port is used, the other signals
   must be static at runtime
 * This component assumes the bit time is greater than 2 * LIN
   propagation time

.. include:: ../../../CHANGELOG.rst
