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

**Step2:** you can see `Please enter ETH0 mac address: (xx-xx-xx-xx-xx-xx)`

input ETH0 mac address, such as `f9-e8-d7-c6-b5-a4`

**Step3:** you can see `Please enter SN: (XXXXXXXX-XXXXX-XXXX-XXXXXXX)`

input product information, such as `VF7100A1-21W60-D8E0-1001001;`

**Example:**

```
# ./enter_mac_sn 
Please enter ETH0 mac address: (xx-xx-xx-xx-xx-xx)
f9-e8-d7-c6-b5-a4
Please enter SN: (XXXXXXXX-XXXXX-XXXX-XXXXXXX)
VF7100A1-21W60-D8E0-1001001;
eeplen = 128
eeprom_header = 12
atom1_info = 96
atom4_info = 20

53 46 56 53 01 00 02 00 80 00 00 00 01 00 01 00 
58 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 00 20 20 53 74 61 72 46 69 
76 65 20 54 65 63 68 6e 6f 6c 6f 67 79 20 43 6f 
2e 2c 20 4c 74 64 2e 00 00 00 56 46 37 31 30 30 
41 31 2d 32 31 57 36 30 2d 44 38 45 30 2d 31 30 
30 31 30 30 31 3b 00 00 00 00 32 e3 04 00 02 00 
0c 00 00 00 01 00 f9 e8 d7 c6 b5 a4 00 00 7b 3b 
```

**EEPROM format:**

| Field  | items       | items         | Byte Length | Description                                                  | VisionFive  V1(JH7100)             |
| ------ | ----------- | ------------- | ----------- | ------------------------------------------------------------ | ---------------------------------- |
| Header | Signature   |               | 4           | signature:  “SFVF”                                           | "SFVF" =  0x53 0x46 0x56 0x46      |
|        | Version     |               | 1           | EEPROM  data format version (0x00 reserved, 0x01 = first version) | 0x01                               |
|        | Reversed    |               | 1           | 0x00,  Reserved field                                        | 0x00                               |
|        | NumAtoms    |               | 2           | total  atoms in EEPROM                                       | 0x0002                             |
|        | EEPLen      |               | 4           | total  length in bytes of all eeprom data (including this header) | 0x00000080                         |
| ATOM1  | type        |               | 2           | 0x0001：vendor info                                          | 0x0001                             |
|        | count       |               | 2           | 0x0001：incrementing atom count                              | 0x0001                             |
|        | dlen        |               | 4           | length  in bytes of data+CRC                                 | 0x00000060                         |
|        | Vendor info | uuid          | 16          | 0x0,  Reserved field                                         | 0x00000000000000000000000000000000 |
|        |             | pid           | 2           | 0x0,  Reserved field                                         | 0x0000                             |
|        |             | pver          | 2           | 0x0,  Reserved field                                         | 0x0000                             |
|        |             | vslen         | 1           | 0x20                                                         | 0x20                               |
|        |             | pslen         | 1           | 0x20                                                         | 0x20                               |
|        |             | vstr          | 32          | “StarFive  Technology Co., Ltd.\0\0”                         |                                    |
|        |             | pstr          | 32          | “VF7100A1-2150-D008E000-00000001;”                           | The red part is  variable          |
|        | crc16       |               | 2           |                                                              |                                    |
| ATOM4  | type        |               | 2           | 0x0004：manufacturer custom data                             | 0x0004                             |
|        | count       |               | 2           | 0x0002：incrementing atom count                              | 0x0002                             |
|        | dlen        |               | 4           | length  in bytes of data+CRC                                 | 0x00000014                         |
|        | custom data | Version       | 2           | 0x01: StarFive manufacturer data format version              | 0x0001                             |
|        |             | Ether  MAC    | 6           | xx-xx-xx-xx-xx-xx                                            | The red part is  variable          |
|        |             | Reversed      | 2           | 0x0,  Reserved field                                         | 0x0000                             |
|        | crc16       |               | 2           |                                                              |                                    |
|        |             | TOTAL  LENGTH | 128         |                                                              |                                    |

