# Configure



> [ETHERNET]
> enable=y									#y: test; n: not test
> boardip=192.168.120.214	  #visionfive IP
> vmip=192.168.120.33		     #VM/PC IP
> baud=1000M				            #speed: 100M, 1000M, 10M
> expectbaudtcp=50		          #expect TCP speed(Mbit/s), to judge the test results
>
> [USB]
> enable=y				                   #y: test; n: not test
> usbcnt=3				                   #USB interface counts, max: 4
> usb1device=sda1			         #usb device1 name
> usb2device=sdb1			        #usb device2 name
> usb3device=sdc1			         #usb device3 name
> usb4device=sdd1			        #usb device4 name
> blocksize=512k			             #blocksize to read
> blockcnt=100			                 #block count to read
> expectreadspeed=20		       #expect USB read speed(Mbit/s), to judge the test results
>
> [SD]
> enable=y				                   #y: test; n: not test
> sddevice=mmcblk0p3		    #sd name
> blocksize=512k			            #blocksize to read
> blockcnt=100			                #block count to read
> expectreadspeed=3		         #expect SD read speed(Mbit/s), to judge the test results
>
> [WLAN]
> enable=y				                   #y: test; n: not test
> vmip=192.168.50.11		       #VM/PC IP
> baud=1000M				           #speed: 100M, 1000M, 10M
> expectbaudtcp=50		         #expect TCP speed(Mbit/s), to judge the test results
> ssid=sdstarfive			            #Wifi name
> psk=sd22979600			        #WiFi password
>
> [BLUETOOTH]
> enable=y				                    #y: test; n: not test
> devmac=B4:EE:25:EB:B8:E0    #bluetooth device MAC addr
>
> [HDMI_PWMADC]
> enable=y					                 #y: test; n: not test



# Run

1. modify the configure as required

2. copy the folder **test_script** to board catalogue **/**

   If you have built TF Card Booting Image, you can see two partitions as follows:

   ![tf_card](D:\work\VisionFive\20211116_product_test\image\tf_card.png)

   

   copy the folder to /dev/sdb3

   ```
   sudo cp -r test_script/ /media/jianlong/465a8d4f-31fe-40c3-951e-4a565bd3a620/ && sync
   ```

3. plug the tf card to slot,  power on, execute the command to run test script

   ```
   cd /test_script && chmod 777 * && sh product_test.sh
   ```

4. if enable to test USB, make sure plug the U disk first;
   if enable to test SD, make sure plug the tf card to slot;
   
   if enable to test ETH0, make sure the PC IP and start iperf3 server
   
   > iperf3 -s
   
   if enable to test WIFI, make sure the PC link to route, and start iperf3 server
   
   > iperf3 -s
   
   if enable to test BLUETOOTH, make sure the device can be scanned during test
   if enable to test HDMI/PWMADC, make sure input the result manually during test



