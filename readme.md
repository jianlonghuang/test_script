# Configure



> [ETHERNET]
>
> enable=y									#y: test; n: not test
>
> boardip=192.168.120.214	  #visionfive IP
>
> vmip=192.168.120.33		     #VM/PC IP
>
> baud=1000M				            #speed: 100M, 1000M, 10M
>
> expectbaudtcp=50		          #expect TCP speed(Mbit/s), to judge the test results
>
> 
>
> [USB]
>
> enable=y				                   #y: test; n: not test
>
> usbcnt=3				                   #USB interface counts, max: 4
>
> usb1device=sda1			         #usb device1 name
>
> usb2device=sdb1			        #usb device2 name
>
> usb3device=sdc1			         #usb device3 name
>
> usb4device=sdd1			        #usb device4 name
>
> blocksize=512k			             #blocksize to read
>
> blockcnt=100			                 #block count to read
>
> expectreadspeed=20		       #expect USB read speed(Mbit/s), to judge the test results
>
> 
>
> [SD]
>
> enable=y				                   #y: test; n: not test
>
> sddevice=mmcblk0p3		    #sd name
>
> blocksize=512k			            #blocksize to read
>
> blockcnt=100			                #block count to read
>
> expectreadspeed=3		         #expect SD read speed(Mbit/s), to judge the test results
>
> 
>
> [WLAN]
>
> enable=y				                   #y: test; n: not test
>
> vmip=192.168.50.11		       #VM/PC IP
>
> baud=1000M				           #speed: 100M, 1000M, 10M
>
> expectbaudtcp=50		         #expect TCP speed(Mbit/s), to judge the test results
>
> ssid=sdstarfive			            #Wifi name
>
> psk=sd22979600			        #WiFi password
>
> 
>
> [BLUETOOTH]
>
> enable=y				                    #y: test; n: not test
>
> devmac=B4:EE:25:EB:B8:E0    #bluetooth device MAC addr
>
> 
>
> [HDMI_PWMADC]
>
> enable=y					                 #y: test; n: not test



# Run

1. modify the configure file **cfg.ini** as required

2. copy the folder **test_script** to board catalogue **/**

   If you have built TF Card Booting Image, you can see two partitions as follows:

   ```
   /dev/sdb1       130M   65M   66M  50% /media/jianlong/4B80-BB12
   /dev/sdb3        29G  162M   27G   1% /media/jianlong/465a8d4f-31fe-40c3-951e-4a565bd3a620
   ```

   copy the folder to /dev/sdb3

   ```
   sudo cp -r test_script/ /media/jianlong/465a8d4f-31fe-40c3-951e-4a565bd3a620/ && sync
   ```

3. plug the tf card to slot,  power on, execute the command to run test script

   ```
   cd /test_script && chmod 777 * && sh product_test.sh
   ```

4. if enable to test USB, make sure plug the U disk first;
   
4. if enable to test SD, make sure plug the tf card to slot;
   
4. if enable to test ETH0, make sure ETH0 connect to PC/VM through a network cable, the PC/VM IP and ETH0 IP are on the same network segment, PC/VM open the iperf3 service, such as **iperf3 -s**;
   
4. if enable to test WIFI, make sure the different network card of PC/VM connect to router, PC/VM open the iperf3 service, such as **iperf3 -s**
   
4. if enable to test BLUETOOTH, make sure the device can be scanned during test
   
4. if enable to test HDMI/PWMADC, make sure input the result manually during test
   
   



