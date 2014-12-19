
LIN Bus Programming Guide
=========================

This section provides information on how to program applications using the LIN Bus module.

Source code structure
---------------------

Directory Structure
+++++++++++++++++++

A typical LIN Bus application will have at least two top level directories. The application will be contained in a directory starting with ``app_``, the LIN Bus module source is in the ``module_lin`` directory which contains library files required to build the application. ::
    
    app_[my_app_name]/
    module_lin/

The application may use other modules which can also be directories at this level. The modules compiled into the application are set by the ``USED_MODULES`` define in the application Makefile.

Key Files
+++++++++

The following header file contains prototypes of all functions required to use the LIN Bus 
module. The API is described in :ref:`sec_api`.

.. list-table:: Key Files
  :header-rows: 1

  * - File
    - Description
  * - ``lin_master.h``
    - LIN bus master API header file
  * - ``lin_slave.h``
    - LIN bus slave API header file


Module Usage
------------

To use the LIN bus module first set up the directory structure as shown above. Create a file in the ``app`` folder called ``lin_conf.h`` and modify the ``LIN_BAUD_RATE`` setting is set according to your needs.

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

To setup a LIN slave within the application, follow exactly the same procedure as above, changing the port and channel names as appropriate. The main statement may look like this::

	int main() {
	  chan c_app_to_lin_slave;
	  par {
	    lin_rx_server(p_slave_rxd, c_app_to_lin_slave);
	    application(c_app_to_lin_slave);
	  }
	  return 0;
	}
 

Software Requirements
---------------------

The component is built on xTIMEcomposer Tools version 12.2.0
The component can be used in version 12.2.0 or any higher version of xTIMEcomposer Tools.
