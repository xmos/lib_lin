Overview
========

LIN Bus Controller Component
----------------------------

LIN bus is a single-master serial shared bus standard designed for automotive and other safety conscious, noisy applications. Based on UART serial communications with a single wire physical layer, it operates up to 19200 baud (using standard LIN transceivers) and is designed for low speed deterministic control networking with up to 16 slaves.
The LIN Bus module is designed so that xCORE devices to interface directly with a LIN transceiver in order to communicate on a LIN bus. The module requires two pins per node (rx and tx), and fits in around 2KB of memory. 


LIN Bus Component Features
++++++++++++++++++++++++++

The LIN Bus component has the following features:

   * LIN 2.1 master and slave protocol components
   * 2400 to 115200 baud operation of software IP (limited by physical layer to between 2400 and 20000 baud)
   * Timeout and mid-frame break detection
   * Integrated frame processing with simple application API
   * Single logical core usage per master or slave node

Memory requirements for Master
++++++++++++++++++++++++++++++

+------------------+----------------------------------------+
| Resource         | Usage                                  |
+==================+========================================+
| Stack            | 142 bytes                              |
+------------------+----------------------------------------+
| Program          | 2126 bytes                             |
+------------------+----------------------------------------+

Memory requirements for Slave
+++++++++++++++++++++++++++++

+------------------+----------------------------------------+
| Resource         | Usage                                  |
+==================+========================================+
| Stack            | 146 bytes                              |
+------------------+----------------------------------------+
| Program          | 1962 bytes                             |
+------------------+----------------------------------------+

Resource requirements per node
++++++++++++++++++++++++++++++

+---------------+-------+
| Resource      | Usage |
+===============+=======+
| 1b or 4b ports|   2   |
+---------------+-------+
| Channels      |   1   |
+---------------+-------+
| Timers        |   2   |
+---------------+-------+
| Clocks        |   0   |
+---------------+-------+
| Logical Cores |   1   |
+---------------+-------+


