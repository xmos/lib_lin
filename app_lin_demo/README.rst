
LIN Bus Master/Slave Loopback demo
==================================

:scope: Example
:description: LIN Bus master and slave demonstration
:keywords: LIN master slave uart
:boards: XP-SKC-L2 XA-SK-ISBUS 

Simple demonstration that uses master/slave API to transmit random
frame from the master to the slave and then request that the slave
sends it back. This forms a simple loop  back test. Any bus errors are
reported and discrepancies between sent and receive frames are show on
the console. The LEDs on the IS-BUS slice show real-time activity by sampling
the rxd and txd pins of both the master and slave.

This demo uses xscope and hence to see the console output, the xscope setting in the run command line (or eclipse run configuration) needs to be set.

To avoid conflicts with xscope (star slot), the two IS-BUS slices are
connected to core 1. The master is mapped to the square slot and the
slave is mapped to the circle slot.

Key Features
------------

* Utilises 1 x L16 core board and 2 x IS-BUS slices to show:
* One master & integrated slave node
* One slave only node     
