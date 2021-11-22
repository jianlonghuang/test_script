#!/bin/bash

echo "************************************************"
echo "****************enter mac and sn****************"
echo "************************************************"


function is_mac_addr_valid()
{
	if echo "$mac_addr" | grep -q '[^A-F0-9-]'; 
	then
		mac_addr_valid=0
	else
		mac_addr_valid=1
	fi
}

function is_sn_valid()
{
	if echo "$sn" | grep -q '[^A-Z0-9-]'; 
	then
		sn_valid=0
	else
		sn_valid=1
	fi
}


separator=";"
separator_len=1
eeprom_size=512
sn_offset=256
sn_name="SN:"
sn_name_len=3
sn_valid=0

while [ $sn_valid == 0 ]
do
	stty erase ^h
	read -p "please enter sn(XXXXXXXX-XXXXX-XXXX-XXXXXXX): " sn
	is_sn_valid
	if [ $sn_valid == 0 ]
	then
		echo "bad sn"
	fi
done

sn_len=$(echo -n $sn | wc -m)
echo "sn_len:$sn_len"
sn_totla_len=$sn_name_len+$sn_len+$separator_len

mac_offset=$sn_totla_len+$sn_offset
mac_len=17
eth0_name="ETH0:"
eth0_name_len=5
mac_addr_valid=0
mac_total_len=$eth0_name_len+$mac_len+$separator_len
mac_end_offset=$mac_total_len+$mac_offset

other2_len=$eeprom_size-$mac_end_offset

while [ $mac_addr_valid == 0 ]
do
	stty erase ^h
	read -p "please enter ETH0 mac addr(XX-XX-XX-XX-XX-XX): " mac_addr
	is_mac_addr_valid
	if [ $mac_addr_valid == 0 ]
	then
		echo "bad mac addr"
	fi
done


data_src=$(cat /sys/bus/i2c/drivers/at24/0-0050/eeprom)
#echo "src: "
#echo $data_src

data_other1=${data_src:0:$sn_offset}
#echo "other1: "
#echo $data_other1
data_other2=${data_src:$mac_end_offset:$other2_len}
#echo "other2: "
#echo $data_other2


mac_addr=${mac_addr:0:$mac_len}
mac_addr=$eth0_name$mac_addr
mac_addr=$mac_addr$separator

sn=${sn:0:$sn_len}
sn=$sn_name$sn
sn=$sn$separator

str=$data_other1$sn$mac_addr$data_other2
#echo "str: "
#echo $str

echo -n $str > /sys/bus/i2c/drivers/at24/0-0050/eeprom

data_result=$(cat /sys/bus/i2c/drivers/at24/0-0050/eeprom)

sn=${data_result:$sn_offset:$sn_totla_len}
echo $sn

mac_addr=${data_result:$mac_offset:$mac_total_len}
echo $mac_addr









