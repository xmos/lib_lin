LIN library
===========

.. rheader::

   LIN |version|

Summary
-------

.. TODO: one or two paragraphs describing the library

The LIN components include master and slave peripherals. Master component automatically includes slave functionality. 50MIPS is required for the baud rate of 115Kbps. Connects directly to LIN transceiver using Rxd and Txd pins.

Each LIN node uses a client server architecture where the server consists of a custom UART receive function, extended with timeout and break detect features required for LIN. The UART receive client C functions are exposed via an API, which are further abstracted by simple LIN master/slave send/receive APIs.

Features
........

 * LIN 2.1 master and slave protocol components
 * 2400 to 115200 baud operation (often limited by physical layer to 20000 baud - please check the data she on your hardware)
 * Timeout and break detection
 * Integrated frame processing with simple application API
 * Single logical core usage per LIN node

Components
..........

.. TODO: * component 1
.. TODO: * component 2

Resource usage
..............

.. TODO: table describing resource usage

Software version and dependencies
.................................

This document pertains to version |version| of the LIN library. It is
intended to be used with version 13.x of the xTIMEcomposer studio tools.

Related application notes
.........................

The following application notes use this library:

.. TODO:  * ANxxxx - [App note title 1]

.. TODO: move known issues section elsewhere
Known Issues
------------

   * Autobaud function in the slave is not implemented. xCORE systems include a precise reference clock removing the need for this feature
   * LIN Rx pin requires it's own logical port (eg. 1b port or 4b port). In the case where a >1b port width is used, the other signals must be static at runtime
   * This component assumes the bit time is greater than 2 * LIN propagation time (txd to rxd pin round trip delay)

