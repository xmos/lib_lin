
sc_lin
............

:Latest release: 1.0.0alpha2
:Maintainer: XMOS
:Description: LIN master and slave software components


Description
===========

LIN master and slave software components

Key Features
============

* LIN 2.1 master and slave protocol components
* 2400 to 115200 baud operation (limited by physical layer)
* Integrated frame processing with simple application API
* Single logical core per slave receive function

To Do
=====

* Break detection mid data transfer

Firmware Overview
=================

The LIN components include master and slave peripherals. Master component automatically includes slave functionality. 50MIPS is required for the baud rate of 115Kbps. Connects directly to LIN transceiver using Rxd and Txd pins.
Each peripheral uses a client server architecture where the server consists of a custom UART function, extended with timeout and break detect. The client C functions are exposed a simple API.

Known Issues
============

 * Autobaud function in the slave is not implemented. xCORE systems have a precise reference clock removing the need for this feature
 * LIN Rx pin requires it's own logical port (eg. 1b port or 4b port). In the case where a >1b port is used, the other signals must be static at runtime
 * This component assumes the bit time is greater than 2 * LIN propagation time

Required software (dependencies)
================================

  * None

