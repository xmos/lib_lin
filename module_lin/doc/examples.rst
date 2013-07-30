Example Application
===================

This tutorial describes the demo applications included in the XMOS sc_lin software component. 

Demonstration Applications
==========================

app_lin_demo
------------


This simple LIN bus demonstration uses xTIMEcomposer Studio tools and targets the XP-SKC-L2 slice kit core board with one or two XA-SK-ISBUS industrial serial bus I/O slices, including a LIN transceiver. The demonstration with one ISBUS slice implements a master system only. It allows the user to check that transmitted frames are present on the LIN bus, thanks to read-back verification within the master. An optional two ISBUS slice demonstration implements both a master and a separate slave node and shows the round-trip passage of a frame from the master, to the slave and back to the master.

Notes
+++++
 - The demo can run with a single ISBUS slice as a master only, but it is recommended to use two slices tow demonstrate master and slave nodes running concurrently


 
