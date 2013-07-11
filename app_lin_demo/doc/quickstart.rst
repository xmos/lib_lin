.. _lin_demo_Quickstart:

LIN Bus Demo Quickstart Guide
=============================

sc_lin demo : Quick Start Guide
-------------------------------

This simple LIN bus demonstration uses xTIMEcomposer Studio tools and targets the XP-SKC-L2 slice kit core board with one or two XA-SK-ISBUS industrial serial bus I/O slices, each of which include a LIN transceiver. The demonstration with one ISBUS slice implements a master system only. It allows the user to verify that transmitted response frames are present on the LIN bus thanks to read-back verification within the master. The demonstration with two ISBUS slices implements both a master and a separate slave node and shows the round-trip passage of a frame from the master, to the slave and back to the master. 

.. figure:: images/lin_system.*
   :width: 75mm
   :align: center

   LIN bus demonstation architecture

Hardware Setup
++++++++++++++

The XP-SKC-L2 Slicekit Core board has four slots with edge connectors: ``SQUARE``, ``CIRCLE``, ``TRIANGLE`` and ``STAR``. 

To setup up the system demonstrating just the LIN master using one ISBUS slice:

   #. Connect XA-SK-ISBUS Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``SQUARE``.
   #. Ensure jumpers are fitted to the ISBUS slice as follows. Header P3 connected between 1 & 2 (provides 5V to LIN bus VBAT). Header P4 connected between 1 & 2 (master pull up resistor & diode enabled).
   #. Connect the XTAG Adapter to Slicekit Core board, and connect XTAG-2 to the Adapter. 
   #. Set the ``XMOS LINK`` to ``ON`` on the XTAG Adapter. This enables the debug XMOS Link and allows XScope functionality.
   #. Connect the XTAG-2 to host PC. Note that the USB extension cable shown is not provided with the Slicekit starter kit.
   #. Switch on the power supply to the Slicekit Core board.

.. figure:: images/hardware_setup_single.*
   :width: 75mm
   :align: center

   Hardware Setup for LIN bus demo using one ISBUS slice

To setup up the system demonstrating a LIN master and separate slave node, using two ISBUS slices:

   #. Setup the system as above for the single ISBUS demonstration.
   #. Add a second ISBUS slice to the XP-SKC-L2 Slicekit Core board using the connector marked with the ``CIRCLE``.
   #. Ensure a jumper is fitted to the second ISBUS slice are fitted as follows. Header P3 is connected between 1 & 2 (provides 5V to LIN bus VBAT).
   #. Connect a flying lead between pin 4 of P6 of both ISBUS slices3. This connects the LIN bus line between the two nodes.


.. figure:: images/hardware_setup_dual.*
   :width: 75mm
   :align: center

   Hardware Setup for LIN bus demo using two ISBUS slices

	
Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTIMEcomposer and check that it is operating in online mode. Open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``'LIN Bus demonstration application'`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTIMEcomposer. This will also cause the modules on which this application depends (in this case, module_lin) to be imported as well. 
   #. Ensure that the application is set to build for the number of ISBUS slices you have connected (either 1 or 2). To do this, locate and modify the following line in app_lin_demo.xc::

      #define ISBUS_NODE_COUNT 1

   #. Click on the app_lin_demo item in the Project Explorer pane then click on the build icon (hammer) in xTIMEcomposer. Check the console window to verify that the application has built successfully.

For help using xTIMEcomposer, try the xTIMEcomposer tutorial, which you can find by selecting Help->Tutorials from the xTIMEcomposer menu.

Note that the Developer Column in the xTIMEcomposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select the module_lin component in the Project Explorer, and you will see its description together with API documentation. Having done this, click the `back` icon until you return to this quickstart guide within the Developer Column.

Run the Application
+++++++++++++++++++

Now that the application has been compiled, the next step is to run it on the Slicekit Core Board using the tools to load the application over JTAG (via the XTAG2 and XTAG Adapter card) into the xCORE multicore microcontroller.

   #. Select the file ``app_lin_demo.xc`` in the ``app_lin_demo`` project from the Project Explorer. This resides in the /src directory.
   #. Click on the ``Run`` icon (the white arrow in the green circle). 
   #. At the ``Select Device`` dialog select ``XMOS XTAG-2 connect to L1[0..1]`` and click ``OK``. If you only see ``Simulator`` as the available target then please check to ensure the XTAG-2 debug adapter is properly connected to your PC. 
   #. Proper operation of the application can be verified by observing the LEDs on the ISBUS slices. They should be flashing briefly every 250ms, indicating activity on the UART pins that are connected to the transceiver. Where the second ISBUS slice is fitted, you may notice that LED1 (p_slave_txd) flashes at 500ms because it is only active every other LIN frame.
    
Next Steps
++++++++++

  #. Enable XScope real-time debug printing. From the ``Run`` pull down menu, select ``Run Configurations``. In the left hand pane of the run configurations dialogue, you will see the ``xCORE Application -> app_lin_demo_Debug.xe`` tree. Select  ``app_lin_demo_Debug.xe``, and in the ``Main`` tab of the right hand pane, choose ``Run XScope output server``. This will enable collection of fast debug print lines from the application.
  #. Now run the application again by click on the ``Run`` icon (the white arrow in the green circle). When the application is running, click on the ``Console`` tab a the bottom of xTIMEcomposer. You should see the text ``LIN bus .. demo app started``
  #. Examine the application code. In xTIMEcomposer navigate to the ``src`` directory under app_lin_demo and double click on the ``app_lin_demo.xc`` file within it. The file will open in the central editor window.
  #. Try changing the line from:

     ``next_frame_time += 25000000;``

     to:

     ``next_frame_time += 15000000;``

     This will cause the master to schedule LIN frames every 150ms instead of 250ms, causing the LEDs to flash faster.
  #. Reduce the baud rate. Open lin_conf.h, locate the baud rate setting line and modify as follows::

     #define LIN_BAUD_RATE 2400

  #. Run the demonstration again and observe the brightness of the LEDs compared with before. The txd and red pins remain active for longer periods due to the slower baud rate, causing them to be illuminated for more time, increasing the brightness.
  #. Inject bus errors into the system. On either ISBUS slice, try shorting the connections of P2 together. This holds the LIN bus at ground (dominant) and prevents correct transmission of frames. Note this is not dangerous since the LIN bus is pulled up via a 1K resistor. In the console you will see master and/or slave errors reported. Depending on the timing of the fault relative to the data, you may see a variety of error types. In the case of dual ISBUS master & slave setup, you will also see the difference between the sent and returned frame buffer contents. 

Try the real-time debugging tools
.................................

xTIMEcomposer includes XScope, a tool for instrumenting your program with real-time probes. This tool allows you to collect data and display it within xTIMEcomposer. This allows both a graphical output and as well as very low intrusiveness console printing. 

  #. Enable real-time XScope. From the ``Run`` pull down menu, select ``Run Configurations``. In the left hand pane of the run configurations dialogue, you will see the ``xCORE Application -> app_lin_demo_Debug.xe`` tree. Select  ``app_lin_demo_Debug.xe``, and in the ``XScope`` tab, select ``Real-Time [XRTScope] Mode``. This will instruct the tool to be render received XScope data in real time. Click ``Apply`` followed by ``Run``.
  #. View the master txd & rxd within XScope. After running the program again, select the ``Real-time Scope`` window at the bottom and click on ``auto``, followed by square to the left of the signal ``Lin bus master node``, followed by ``Falling`` and finally click on the trace display window to set the trigger time and level. You should see a LIN bus frame as below, clearly showing the break, synch and ID symbols followed by response data. 


.. figure:: images/xscope.*
   :width: 75mm
   :align: center

   Real-time XScope display from LIN master


For further details about real-time, in circuit debugging with XScope, please refer to `xTIMEcomposer User Guide
<http://www.xmos.com/trace-data-xscope-0/>`_.