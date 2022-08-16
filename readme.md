# Configure

[GMAC0]

enable=y								#y: test; n: not test

boardip=192.168.1.11		#visionfive IP

vmip=192.168.1.101			#VM/PC IP

baud=1000M						#speed: 100M, 1000M, 10M

expectbaudtcp=900			#expect TCP speed(Mbit/s), to judge the test results



[GMAC1]

enable=y

boardip=192.168.1.22		#y: test; n: not test

vmip=192.168.1.101			#visionfive IP

baud=1000M						#speed: 100M, 1000M, 10M

expectbaudtcp=900			#expect TCP speed(Mbit/s), to judge the test results



[USB]

enable=y		#y: test; n: not test

usbcnt=4		#USB interface counts, max: 4

usb1device=sda1		#usb device1 name

usb2device=sdb1		#usb device2 name

usb3device=sdc1		#usb device3 name

usb4device=sdd1		#usb device4 name

blocksize=512k		#blocksize to read

blockcnt=500		#block count to read

expectspeed=20		#expect USB read speed(Mbit/s), to judge the test results



[SD]

enable=y		#y: test; n: not test

sddevice=mmcblk1p3	#sd name

blocksize=512k		#blocksize to read

blockcnt=100		#block count to read

expectspeed=7		#expect read speed(Mbit/s), to judge the test results



[EMMC]

enable=y		#y: test; n: not test

sddevice=mmcblk0p1	#emmc name

blocksize=512k		#blocksize to read

blockcnt=500		#block count to read

expectspeed=50		#expect read speed(Mbit/s), to judge the test results



[PCIE_SSD]

enable=y		#y: test; n: not test

sddevice=nvme0n1	#ssd name

blocksize=512k		#blocksize to read

blockcnt=5000		#block count to read

expectspeed=200		#expect read speed(Mbit/s), to judge the test results



[HDMI]

enable=y		#y: test; n: not test



[CSI]

enable=y



[PWMDAC]

enable=y		#y: test; n: not test



[DSI]

enable=n		#y: test; n: not test




# Run

1. Modify the configure file **cfg.ini** as required

2. Copy the folder **test_script** to board catalogue **/**

   If you have built TF Card Booting Image, you can see two partitions as follows:

   ```
   /dev/sdb3       292M   58M  234M  20% /media/jianlong/0A72-5EE2
   /dev/sdb4        56G   99M   53G   1% /media/jianlong/rootfs
   ```

   copy the folder to /dev/sdb4

   ```
   sudo cp -r test_script/ /media/jianlong/rootfs/ && sync
   ```

3. Plug the tf card to slot,  power on, execute the command to run test script

   ```
   cd /test_script && chmod 777 * && sh product_test.sh
   ```

4. If enable to test USB, make sure plug the U disk first;
   
5. If enable to test SD, make sure plug the tf card to slot;

6. If enable to test EMMC, make sure plug the emmc to slot;

7. If enable to test SSD, make sure plug the ssd to pcie slot;
   
8. If enable to test ETH0/1, make sure ETH0/1 connect to PC/VM through a network cable, the PC/VM IP and ETH0/1 IP are on the same network segment, PC/VM open the iperf3 service, such as **iperf3 -s**;
   
9. If enable to test HDMI/DSI, when you see some log as follow, take a few second, then press **Enter**;

   ```
   [   27.890839] innohdmi-rockchip 29590000.hdmi: inno_hdmi_config_pll 299 reg[1ad],val[01]
   [   27.898745] innohdmi-rockchip 29590000.hdmi: inno_hdmi_config_pll 299 reg[1aa],val[0e]
   [   27.906664] innohdmi-rockchip 29590000.hdmi: inno_hdmi_config_pll 299 reg[1a0],val[00]
   
   ```

   then show you to input the test result as follow:

   ```
   please enter HDMI TEST OK(y/n?): y
   
   ```

   if the hdmi/dsi display can display, then input **y**, otherwise input **n**;

10. If enable to test PWMDAC, it will play a few second audio, then show you to input the test result as follow:

   ```
   ******************PWMADC testing...
   aplay -Dhw:0,0 audio8k16S.wav
   Playing WAVE 'audio8k16S.wav' : Signed 16 bit Little Endian, Rate 8000 Hz, Stereo
   [  670.987352] dma: failed to stop
   [  671.000517] dma dma2chan0: dma2chan0 failed to stop
   please enter PWMADC TEST OK(y/n?): 
   
   ```

   if you can listen the sound, then input **y**, otherwise input **n**;

11. If enable to test CSI, it will show the video of imx219 sensor to hdmi display, then show you to input the test result as follow:

   ```
   [   45.570559] innohdmi-rockchip 29590000.hdmi: inno_hdmi_config_pll 299 reg[1aa],val[0e]
   [   45.572513] [st_vin] error: vin_change_buffer: output state no ready 5!, 1
   [   45.578466] innohdmi-rockchip 29590000.hdmi: inno_hdmi_config_pll 299 reg[1a0],val[00]
   [   45.605842] [st_vin] error: vin_change_buffer: output state no ready 5!, 1
   please enter MIPI CSI TEST OK(y/n?):
   
   ```

   if the hdmi display show the imx219 sensor video, then input **y**, otherwise input **n**;

12. There are two methods to write eeprom

   **The 1st**
   If you have the file of eeprom data **eeprom.eep**, you can execute the follow command to write data to eeprom device

   ```
   sh enter_mac_sn.sh eeprom.eep
   ```

   **The 2nd**
   You can execute the follow command to write default value or input mac/sn by yourself

   ```
   cd enter_mac_sn && chmod 777 * && ./enter_mac_sn
   ```

   The output as follow:
   ```
   # ./enter_mac_sn
   Use default value(y/n)?
   y
   eeplen = 136
   eeprom_header = 12
   atom1_info = 96
   atom4_info = 28
   
   53 46 56 46 02 00 02 00 88 00 00 00 01 00 01 00 
   58 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
   00 00 00 00 00 00 00 00 20 20 53 74 61 72 46 69 
   76 65 20 54 65 63 68 6e 6f 6c 6f 67 79 20 43 6f 
   2e 2c 20 4c 74 64 2e 00 00 00 56 46 37 31 31 30 
   41 31 2d 32 32 32 38 2d 44 30 30 38 45 30 30 30 
   2d 30 30 30 30 30 30 30 31 00 da e6 04 00 02 00 
   14 00 00 00 02 00 01 41 6c cf 39 6c de 12 6c cf 
   39 7c ae 13 00 00 00 df 
   ```

   ```
   # ./enter_mac_sn
   Use default value(y/n)?
   n
   Please enter ETH0 mac address: (xx-xx-xx-xx-xx-xx)
   6c-cf-39-6c-de-11
   Please enter ETH0 mac address: (xx-xx-xx-xx-xx-xx)
   6c-cf-39-6c-de-22
   Please enter SN: (XXXXXXXX-XXXXX-XXXX-XXXXXXX)
   VF7110B1-2235-D008E000-10101010
   eeplen = 136
   eeprom_header = 12
   atom1_info = 96
   atom4_info = 28
   
   53 46 56 46 02 00 02 00 88 00 00 00 01 00 01 00 
   58 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
   00 00 00 00 00 00 00 00 20 20 53 74 61 72 46 69 
   76 65 20 54 65 63 68 6e 6f 6c 6f 67 79 20 43 6f 
   2e 2c 20 4c 74 64 2e 00 00 00 56 46 37 31 31 30 
   42 31 2d 32 32 33 35 2d 44 30 30 38 45 30 30 30 
   2d 31 30 31 30 31 30 31 30 00 9c ab 04 00 02 00 
   14 00 00 00 02 00 01 41 6c cf 39 6c de 11 6c cf 
   39 6c de 22 00 00 9e e3 
   ```



