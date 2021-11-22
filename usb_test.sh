#!/bin/bash

function readINI()
{
 FILENAME=$1; SECTION=$2; KEY=$3
 RESULT=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEY'/{print $2;exit}' $FILENAME`
 echo $RESULT
}

cfg_name=cfg.ini
cfg_section=USB
failcnt=0
k_unit=1024

str_usbcnt=$(readINI $cfg_name $cfg_section usbcnt)
usb_cnt=$(echo $str_usbcnt | sed 's/\r//')
#echo $usb_cnt

str_usb1device=$(readINI $cfg_name $cfg_section usb1device)
usb1_device=$(echo $str_usb1device | sed 's/\r//')
#echo $usb1_device

str_usb2device=$(readINI $cfg_name $cfg_section usb2device)
usb2_device=$(echo $str_usb2device | sed 's/\r//')
#echo $usb2_device

str_usb3device=$(readINI $cfg_name $cfg_section usb3device)
usb3_device=$(echo $str_usb3device | sed 's/\r//')
#echo $usb3_device

str_usb4device=$(readINI $cfg_name $cfg_section usb4device)
usb4_device=$(echo $str_usb4device | sed 's/\r//')
#echo $usb4_device

str_blocksize=$(readINI $cfg_name $cfg_section blocksize)
block_size=$(echo $str_blocksize | sed 's/\r//')
#echo $block_size

k_index=`expr index "$str_blocksize" k`
if [ $k_index -gt 1 ]
then
	k_index=`expr $k_index - 1`
	int_block_size=${str_blocksize:0:$k_index}
	int_block_size=`echo "$int_block_size*$k_unit" |bc`
else
	int_block_size=$block_size
fi

str_blockcnt=$(readINI $cfg_name $cfg_section blockcnt)
block_cnt=$(echo $str_blockcnt | sed 's/\r//')
#echo $block_cnt

str_expectreadspeed=$(readINI $cfg_name $cfg_section expectreadspeed)
expect_readspeed=$(echo $str_expectreadspeed | sed 's/\r//')
#echo $expect_readspeed

cnt=1

while [ $cnt -le $usb_cnt ]
do
	echo "******************USB$cnt test..."
	
	case $cnt in
	1)
		usb_device=$usb1_device
		;;
	2)
		usb_device=$usb2_device
		;;
	3)
		usb_device=$usb3_device
		;;
	4)
		usb_device=$usb4_device
		;;
	esac
	
	echo "time dd if=/dev/$usb_device of=/dev/null bs=$block_size count=$block_cnt"
	time dd if=/dev/$usb_device of=/dev/null bs=$block_size count=$block_cnt 2>&1 | tee usb_test.log
	
	str=$(sed -n '4p' usb_test.log)
	#echo "string: $str"
	l_index=`expr index "$str" l`
	m_index=`expr index "$str" m`
	m_cnt=`expr $m_index - $l_index - 1`

	min=${str:$l_index:$m_cnt}
	#echo "min: $min"

	s_index=`expr index "$str" s`
	s_cnt=`expr $s_index - $m_index - 1`
	sec=${str:$m_index:$s_cnt}
	#echo "sec: $sec"

	time=`echo "$min*60+$sec" |bc`
	#echo "time: $time s"
	
	speed=$(echo "$int_block_size $block_cnt" | awk '{printf("%.2f",$1*$2)}')
	speed=$(echo "$speed $time" |awk '{printf("%.2f",$1/$2)}')
	speed=$(echo $speed $k_unit | awk '{printf("%.2f",$1/$2)}')
	speed=$(echo $speed $k_unit | awk '{printf("%.2f",$1/$2)}')
	echo "speed: $speed Mbit/s"

	result=$(echo $speed $expect_readspeed | awk '{if($1>$2) {printf 1} else {printf 0}}')
	#echo "result=$result"
	if [[ $result = 1 ]] && [[ $sec != 0 ]]
	then
		echo "USB$cnt PASS"
		echo "USB$cnt:           PASS  speed: $speed Mbit/s" >> test_result.log
	else
		echo "USB$cnt FAIL"
		echo "USB$cnt:             FAIL  speed: $speed Mbit/s" >> test_result.log
	fi
	
	let cnt++
done




