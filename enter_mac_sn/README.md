# Compile

```
riscv64-linux-gnu-gcc enter_mac_sn.c -o enter_mac_sn
```

output: `enter_mac_sn`

> Note: if you have not compiler, you can do `sudo apt-get install gcc-riscv64-linux-gnu` to install 



# Run

**Step1:** Execute the following command to run:

```
./enter_mac_sn
```

**Step2:** you can see `Use default value(y/n)?`

input  `y` use the default value, input `n` , then excute step 3/4/5 to input mac address and sn

**Step3:** you can see `Please enter ETH0 mac address: (xx-xx-xx-xx-xx-xx)`

input ETH0 mac address, such as `6c-cf-39-6c-de-12`

**Step4:** you can see `Please enter ETH1 mac address: (xx-xx-xx-xx-xx-xx)`

input ETH1 mac address, such as `6c-cf-39-7c-ae-13`

**Step5:** you can see `Please enter SN: (XXXXXXXX-XXXXX-XXXX-XXXXXXX)`

input product information, such as `VF7110A1-2228-D008E000-00000001`

**Example:**

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

**EEPROM format:**

| **Field**  | **items**   | **items**    | **Byte Length** | **Description**                                              | **VisionFive V2(JH7110)**                                    |
| ---------- | ----------- | ------------ | --------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Header** | Signature   |              | 4               | signature: “SFVF”                                            | "SFVF" = 0x53 0x46 0x56 0x46                                 |
|            | Version     |              | 1               | EEPROM data format version (0x00 reserved, 0x01 = first version) | 0x02                                                         |
|            | Reversed    |              | 1               | 0x00, Reserved field                                         | 0x00                                                         |
|            | NumAtoms    |              | 2               | total atoms in EEPROM                                        | 0x0002                                                       |
|            | EEPLen      |              | 4               | total length in bytes of all eeprom data (including this header) | 0x00000088                                                   |
| **ATOM1**  | type        |              | 2               | 0x0001：vendor info                                          | 0x0001                                                       |
|            | count       |              | 2               | 0x0001：incrementing atom count                              | 0x0001                                                       |
|            | dlen        |              | 4               | length in bytes of data+CRC                                  | 0x00000058                                                   |
|            | Vendor info | uuid         | 16              | 0x0, Reserved field                                          | 0x00000000000000000000000000000000                           |
|            |             | pid          | 2               | 0x0, Reserved field                                          | 0x0000                                                       |
|            |             | pver         | 2               | 0x0, Reserved field                                          | 0x0000                                                       |
|            |             | vslen        | 1               | 0x20                                                         | 0x20                                                         |
|            |             | pslen        | 1               | 0x20                                                         | 0x20                                                         |
|            |             | vstr         | 32              | "StarFive Technology Co., Ltd.\0\0\0"                        | 53 74 61 72 46 69 76 65 20 54 65 63 68 6e 6f 6c 6f 67 79 20 43 6f 2e 2c 20 4c 74 64 2e 00 00 00 |
|            |             | pstr         | 32              | “VF7110A1-2228-D008E000-00000001\0”                          | The red part is variable the last 8 digits are Hex.          |
|            | crc16       |              | 2               | crc-16 of entire atom (type, count, dlen, data)              |                                                              |
| **ATOM4**  | type        |              | 2               | 0x0004：manufacturer custom data                             | 0x0004                                                       |
|            | count       |              | 2               | 0x0002：incrementing atom count                              | 0x0002                                                       |
|            | dlen        |              | 4               | length in bytes of data+CRC                                  | 0x00000014                                                   |
|            | custom data | Version      | 2               | StarFive manufacturer data format version                    | 0x0002                                                       |
|            |             | PCB version  | 1               | 0x01                                                         | The red part is variable, 0x01 means first initial PCB layout |
|            |             | BOM version  | 1               | 'A'                                                          | The red part is variable, 'A' means first initial BOM list   |
|            |             | Ether MAC1   | 6               | 6C-CF-39-xx-xx-xx                                            | The red part is variable                                     |
|            |             | Ether MAC2   | 6               | 6C-CF-39-xx-xx-xx                                            | The red part is variable                                     |
|            |             | Reversed     | 2               | 0x0000                                                       | 0x0000                                                       |
|            | crc16       |              | 2               | crc-16 of entire atom (type, count, dlen, data)              |                                                              |
|            |             | TOTAL LENGTH | 136             |                                                              |                                                              |
