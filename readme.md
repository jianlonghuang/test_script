# Configure

[GMAC0]

enable=y                               #y: test; n: not test

boardip=192.168.1.11                   #visionfive IP

vmip=192.168.1.101                     #VM/PC IP

baud=1000M                             #speed: 100M, 1000M, 10M

expectbaudtcp=900                      #expect TCP speed(Mbit/s), to judge the test results



[GMAC1]

enable=y                               #y: test; n: not test

boardip=192.168.1.22                   #visionfive IP

vmip=192.168.1.101                     #VM/PC IP

baud=1000M                             #speed: 100M, 1000M, 10M

expectbaudtcp=900                      #expect TCP speed(Mbit/s), to judge the test results



[USB]

enable=y                               #y: test; n: not test

usbcnt=4                               #USB interface counts, max: 4

usb1device=sda1                        #usb device1 name

usb2device=sdb1                        #usb device2 name

usb3device=sdc1                        #usb device3 name

usb4device=sdd1                        #usb device4 name

blocksize=512k                         #blocksize to read

blockcnt=500                           #block count to read

expectspeed=20                         #expect USB read speed(Mbit/s), to judge the test results



[SD]

enable=y                               #y: test; n: not test

sddevice=mmcblk1p3                     #sd name

blocksize=512k                         #blocksize to read

blockcnt=100                           #block count to read

expectspeed=7                          #expect read speed(Mbit/s), to judge the test results



[EMMC]

enable=y                               #y: test; n: not test

sddevice=mmcblk0p1                     #emmc name

blocksize=512k                         #blocksize to read

blockcnt=500                           #block count to read

expectspeed=50                         #expect read speed(Mbit/s), to judge the test results



[PCIE_SSD]

enable=y                               #y: test; n: not test

sddevice=nvme0n1                       #ssd name

blocksize=512k                         #blocksize to read

blockcnt=5000                          #block count to read

expectspeed=200                        #expect read speed(Mbit/s), to judge the test results



[HDMI]

enable=y                               #y: test; n: not test



[CSI]

enable=y                               #y: test; n: not test



[PWMDAC]

enable=y                               #y: test; n: not test



[DSI]

enable=n                               #y: test; n: not test



[GPIO]

enable=y                               #y: test; n: not test

pins1=58,57                            #2 pin num

pins2=55,42

pins3=43,47

pins4=52,53

pins5=48,45

pins6=37,39

pins7=59,44

pins8=38,54

pins9=51,50

pins10=49,56

pins11=62,46

pins12=36,61

pins13=null



# Hardware Link

1. If enable to test USB, make sure plug the U disk first;

2. If enable to test SD, make sure plug the tf card to slot first;

3. If enable to test EMMC, make sure plug the emmc to slot first;

4. If enable to test SSD, make sure plug the ssd to pcie slot first;

5. If enable to test ETH0/1, make sure ETH0/1 connect to PC/VM through a network cable, the PC/VM IP and ETH0/1 IP are on the same network segment;

6. If enable to test HDMI/DSI, make sure connect to HDMI/MIPI DSI display first;

7. If enable to test PWMDAC, make sure connect to earphone first:

8. If enable to test CSI, make sure connect to imx219 sensor first;

9. If enable to test GPIO, make sure connect two pins as configure file, for example:

   pins1=58,57 means short circuit GPIO58 and GPIO57

**Most important:**

**Two USB to Serial Converters are needed, one for the terminal and the other to communicate with the PC.**

**Pin Num 8,10 for the terminal**

**Pin Num 35, 37 for the communicate**

|     Pin Name     | Pin Num | Pin Num |     Pin Name     |
| :--------------: | :-----: | :-----: | :--------------: |
|      +3.3V       |    1    |    2    |       +5V        |
|      GPIO58      |    3    |    4    |       +5V        |
|      GPIO57      |    5    |    6    |       GND        |
|      GPIO55      |    7    |    8    | GPIO41 (UART TX) |
|       GND        |    9    |   10    | GPIO40 (UART RX) |
|      GPIO42      |   11    |   12    |      GPIO38      |
|      GPIO43      |   13    |   14    |       GND        |
|      GPIO47      |   15    |   16    |      GPIO54      |
|      +3.3V       |   17    |   18    |      GPIO51      |
|      GPIO52      |   19    |   20    |       GND        |
|      GPIO53      |   21    |   22    |      GPIO50      |
|      GPIO48      |   23    |   24    |      GPIO49      |
|       GND        |   25    |   26    |      GPIO56      |
|      GPIO45      |   27    |   28    |      GPIO40      |
|      GPIO37      |   29    |   30    |       GND        |
|      GPIO39      |   31    |   32    |      GPIO46      |
|      GPIO59      |   33    |   34    |       GND        |
| GPIO63 (UART RX) |   35    |   36    |      GPIO36      |
| GPIO60 (UART TX) |   37    |   38    |      GPIO61      |
|       GND        |   39    |   40    |      GPIO44      |




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
   cd /test_script && chmod 777 * && sh main.sh
   ```

4. Test flow

   a. PWMDAC 5 seconds

   b. HDMI and MIPI DSI 6 seconds

   c. Run other test items parallel

   d. PWMDAC, HDMI, MIPI DSI, MIPI CSI need to enter test results manually



# EEPROM

There are two methods to write eeprom

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



