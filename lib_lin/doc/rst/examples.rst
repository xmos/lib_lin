
Demonstration Applications
==========================

app_lin_demo
------------

The ``LIN Bus Master/Slave Loopback demo`` is a simple LIN bus demonstration that uses xTIMEcomposer Studio tools and targets the XP-SKC-L16 sliceKIT core board with one or two XA-SK-ISBUS industrial serial bus I/O sliceCARDS, including a LIN transceiver. The demonstration with one ISBUS slice implements a master system only. It allows the user to check that transmitted frames are present on the LIN bus, thanks to read-back verification within the master. An optional two ISBUS slice demonstration implements both a master and a separate slave node and shows the round-trip passage of a frame from the master, to the slave and back to the master.

Notes
+++++
Note that the demo can run with a single IS-BUS slice as a master only, but it is recommended to use two slices to demonstrate master and slave nodes running concurrently and the round trip passage of control data.
