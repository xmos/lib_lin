LIN Bus Component
=================

:scope: Early Development
:description: LIN Bus master and slave components
:keywords: LIN
:boards: XP-SKC-L16, XA-SK-ISBUS 

The LIN components include master and slave peripherals. Master component automatically includes slave functionality. 50MIPS is required for the baud rate of 115Kbps. Connects directly to LIN transceiver using Rxd and Txd pins.

Each LIN node uses a client server architecture where the server consists of a custom UART receive function, extended with timeout and break detect features required for LIN. The UART receive client C functions are exposed via an API, which are further abstracted by simple LIN master/slave send/receive APIs.

Key Features
------------

   * LIN 2.1 master and slave protocol components
   * 2400 to 115200 baud operation (often limited by physical layer to 20000 baud - please check the data sheet on your hardware)
   * Timeout and break detection
   * Integrated frame processing with simple application API
   * Single logical core usage per LIN node

Known Issues
------------

   * Autobaud function in the slave is not implemented. xCORE systems include a precise reference clock removing the need for this feature
   * LIN Rx pin requires it's own logical port (eg. 1b port or 4b port). In the case where a >1b port width is used, the other signals must be static at runtime
   * This component assumes the bit time is greater than 2 * LIN propagation time (txd to rxd pin round trip delay)

