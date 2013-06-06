
LIN Bus Module
==============

:scope: Early Development
:description: LIN Bus master and slave component
:keywords: LIN master slave uart bus automotive industrial
:boards: XP-SKC-L2 XA-SK-ISBUS 



Key Features
============

   * LIN 2.1 master and slave protocol components
   * 2400 to 115200 baud operation (limited by physical layer)
   * Integrated frame processing with simple application API
   * Single logical core per slave receive function
    

Firmware Overview
=================

The LIN components include master and slave peripherals. Master component automatically includes slave functionality. 50MIPS is required for the baud rate of 115Kbps. Connects directly to LIN transceiver using Rxd and Txd pins.
Each peripheral uses a client server architecture where the server consists of a custom UART receive function, extended with timeout and break detect features required for LIN. The UART receive client C functions are exposed via an API, which are further abstracted by simple LIN master/slave send/receive APIs.

Known Issues
============

   * Autobaud function in the slave is not implemented. xCORE systems
     have a precise reference clock removing the need for this feature
   * LIN Rx pin requires it's own logical port (eg. 1b port or 4b port). In the case where a >1b port is used, the other signals must be static at runtime
   * This component assumes the bit time is greater than 2 * LIN propagation time (txd to rxd pin round trip delay)

   
Required software (dependencies)
================================

   * None
