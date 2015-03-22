LIN library
===========

Summary
-------

A software defined LIN bus library. The LIN library include master
and slave peripherals. Master component automatically includes slave
functionality. 50MIPS is required for the baud rate of
115Kbps. Connects directly to LIN transceiver using Rxd and Txd pins.

Each peripheral uses a client server architecture where the server
consists of a custom UART function, extended with timeout and break
detect. The client C functions are exposed as a simple API.

Features
........

* LIN 2.1 master and slave protocol components
* 2400 to 115200 baud operation (limited by physical layer)
* Integrated frame processing with simple application API
* Timeout and mid-frame break detection
* Integrated frame processing with simple application API
* Single logical core per LIN node (either slave or master)


Typical Resource Usage
......................

.. resusage::

  * - configuration: Master
    - target: STARTKIT
    - flags: -DLIN_MAXIMUM_RESPONSE_LENGTH=8 -DTX_RECESSIVE=1 -DTX_DOMINANT=0 -DRX_RECESSIVE=1 -DRX_DOMINANT=0 -DLIN_RESPONSE_SPACE=0 -DLIN_INTERBYTE_SPACE=0 -DLIN_INTERFRAME_SPACE=0 -DLIN_SYNCH_BREAK_BITS_MASTER=13 -DLIN_SYNCH_BREAK_THRESHOLD_SLAVE=11 -DLIN_SYNCH_BREAK_DELIMIT=1 -DLIN_MESSAGE_TIMEOUT=100 -DLIN_MAXIMUM_RESPONSE_LENGTH=8 -DLIN_SYNCH_BYTE=0x55 -DLIN_BIT_TIME=800
    - globals: out port p_tx = XS1_PORT_4A; in port p_rx = XS1_PORT_4B; lin_frame_t tx_frame;
    - locals: chan c;
    - fn: par {{lin_master_init(p_tx, c); lin_master_send_frame(tx_frame, p_tx, c);}lin_rx_server(p_rx, c);}
    - pins: 2
    - ports: 2
    - cores: 1
  * - configuration: Slave
    - target: STARTKIT
    - flags: -DLIN_MAXIMUM_RESPONSE_LENGTH=8 -DTX_RECESSIVE=1 -DTX_DOMINANT=0 -DRX_RECESSIVE=1 -DRX_DOMINANT=0 -DLIN_RESPONSE_SPACE=0 -DLIN_INTERBYTE_SPACE=0 -DLIN_INTERFRAME_SPACE=0 -DLIN_SYNCH_BREAK_BITS_MASTER=13 -DLIN_SYNCH_BREAK_THRESHOLD_SLAVE=11 -DLIN_SYNCH_BREAK_DELIMIT=1 -DLIN_MESSAGE_TIMEOUT=100 -DLIN_MAXIMUM_RESPONSE_LENGTH=8 -DLIN_SYNCH_BYTE=0x55 -DLIN_BIT_TIME=800
    - globals: out port p_tx = XS1_PORT_4A; in port p_rx = XS1_PORT_4B; lin_frame_t slave_frame;
    - locals: chan c;
    - fn: par {{char id;lin_slave_init(p_tx, c); lin_slave_wait_for_header(c, id);lin_slave_get_response(c, slave_frame);lin_slave_send_response(p_tx, c, slave_frame);}lin_rx_server(p_rx, c);}
    - pins: 2
    - ports: 2
    - cores: 1


Software version and dependencies
.................................

.. libdeps::



