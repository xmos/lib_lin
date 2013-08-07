LIN Bus Master/Slave Loopback demo
==================================

:scope: Example
:description: LIN Bus demonstration application
:keywords: LIN 
:boards: XP-SKC-L16, XA-SK-ISBUS 

Simple demonstration supporting either one or two IS-BUS slices. The single IS-BUS demo shows a master node and checks to see that frames written to the LIN bus correctly. Dual IS-BUS demo uses master/slave API to transmit random frame from the master to the slave and then request that the slave sends it back. This forms a simple loop back test. Any bus errors are reported and discrepancies between sent and received frames are show on the console. The LEDs on the IS-BUS slice(s) show real-time activity by sampling the rxd and txd pins of both the master and slave.

The demo uses xSCOPE and hence to see the console output, the xSCOPE setting in the run command line (or eclipse run configuration) needs to be set.

To avoid conflicts with xSCOPE (which is overlaid on the star slot), the two IS-BUS slices are connected to tile 1. The master is mapped to the square slot and the slave is mapped to the circle slot.

Key Features
------------

   * Utilises 1 x L16 core board and either 1 x or 2 x IS-BUS slices to show:
   * One master & integrated slave node
   * One slave only node     
