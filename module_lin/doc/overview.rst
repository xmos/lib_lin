Overview
========

LIN bus is a single-master serial shared bus standard designed for automotive and other safety conscious, noisy applications. Based on UART serial communications with a single wire physical layer, it operates up to 19200 baud and is designed for low speed control networking with up to 16 slaves.
The LIN Bus module is designed so that xCORE devices to interface directly with a LIN transceiver in order to communicate on a LIN bus. The module requires two pins per node (rx and tx), and fits in around 3KB of memory. 


Features
--------

The LIN Bus component has the following features:

   * LIN 2.1 master and slave protocol components
   * 2400 to 115200 baud operation (limited by physical layer to between 2400 and 38400)
   * Timeout and mid-frame break detection
   * Integrated frame processing with simple application API
   * Single logical core usage per master or slave node
