
Demonstration Applications
==========================

app_lin_demo
------------

This simple LIN bus demonstration uses xTIMEcomposer Studio tools and targets the XP-SKC-L2 slice kit core board with one or two XA-SK-ISBUS industrial serial bus I/O slices, including a LIN transceiver. The demonstration with one ISBUS slice implements a master system only. It allows the user to check that transmitted frames are present on the LIN bus, thanks to read-back verification within the master. An optional two ISBUS slice demonstration implements both a master and a separate slave node and shows the round-trip passage of a frame from the master, to the slave and back to the master.

For a full step-by-step walkthrough usage of ``module_lin``, please consult the quick-start guide provided with ``app_lin_demo``.

Notes
+++++
 - The demo can run with a single IS-BUS slice as a master only, but it is recommended to use two slices to demonstrate master and slave nodes running concurrently and the round trip passage of control data.


 
