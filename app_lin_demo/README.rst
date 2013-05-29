
LIN Bus demonstration
=====================

:scope: Example
:description: LIN Bus master and slave demonstration
:keywords: LIN master slave uart
:boards: XP-SKC-L2 + XA-SK-ISBUS 


Key Features
============

* Utilises 1 x L16 core board and 2 x IS-BUS slices to show:
* One master & slave node
* One slave only node     

Demo Overview
=============

Simple demonstration that uses master/slave API to transmit random frame from the master to the slave and then request that the slave sends it back. This forms a simple loop  back test. Any bus errors are reported and discrepancies between sent and receive frames are show on the console.

This demo uses xscope and hence to see the console output, the xscope setting in the run command line (or eclipse run configuration) needs to be set.

To allow scope to work, the two IS-BUS slices are connected to core 1. The master goes into the square slot and the slave goes into the circle slot.
   
Required software (dependencies)
================================

* module_lin

