#!/bin/bash

function readINI()
{
 FILENAME=$1; SECTION=$2; KEY=$3
 RESULT=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEY'/{print $2;exit}' $FILENAME`
 echo $RESULT
}

cfg_name=cfg.ini
cfg_section=USB

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

str_blockcnt=$(readINI $cfg_name $cfg_section blockcnt)
block_cnt=$(echo $str_blockcnt | sed 's/\r//')
#echo $block_cnt

str_expectspeed=$(readINI $cfg_name $cfg_section expectspeed)
expect_speed=$(echo $str_expectspeed | sed 's/\r//')
#echo $expect_speed

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
	
	if [ -e "/dev/$usb_device" ]
	then

		echo "time dd if=/dev/$usb_device of=/dev/null bs=$block_size count=$block_cnt"
		time dd if=/dev/$usb_device of=/dev/null bs=$block_size count=$block_cnt 2>&1 | tee usb_test.log
		
		str=$(sed -n '3p' usb_test.log)
		#echo "string: $str"
		index=`expr index "$str" /`
		#echo "index: $index"
		let comma_last_index=`echo "$str" | awk -F '','' '{printf "%d", length($0)-length($NF)}'`
		#echo $comma_last_index
		len=`expr $index - $comma_last_index - 4`
		fspeed=${str:$comma_last_index+1:$len}
		#echo "fspeed: $fspeed"
		len=`expr $index - $comma_last_index`
		rspeed=${str:$comma_last_index+1:$len}
		echo "speed: $rspeed"

		result=$(echo $fspeed $expect_speed | awk '{if($1>$2) {printf 1} else {printf 0}}')
		#echo "result=$result"
		if [[ $result = 1 ]] && [[ $fspeed != 0 ]] && [[ $fspeed != "" ]]
		then
			echo "USB$cnt READ PASS"
			echo "USB$cnt READ:      PASS  read speed: $rspeed" >> test_result.log
		else
			echo "USB$cnt READ FAIL"
			echo "USB$cnt READ:      FAIL  read speed: $rspeed" >> test_result.log
		fi
		

		if false; then
			echo "time dd if=/dev/zero of=/dev/$usb_device bs=$block_size count=$block_cnt"
			time dd if=/dev/zero of=/dev/$usb_device bs=$block_size count=$block_cnt 2>&1 | tee usb_test.log

			str=$(sed -n '3p' usb_test.log)
			#echo "string: $str"
			index=`expr index "$str" /`
			#echo "index: $index"
			let comma_last_index=`echo "$str" | awk -F '','' '{printf "%d", length($0)-length($NF)}'`
			#echo $comma_last_index
			len=`expr $index - $comma_last_index - 4`
			fspeed=${str:$comma_last_index+1:$len}
			#echo "fspeed: $fspeed"
			len=`expr $index - $comma_last_index`
			wspeed=${str:$comma_last_index+1:$len}
			echo "speed: $wspeed"
				
			result=$(echo $fspeed $expect_speed | awk '{if($1>$2) {printf 1} else {printf 0}}')
			#echo "result=$result"
			if [[ $result = 1 ]] && [[ $fspeed != 0 ]] && [[ $fspeed != "" ]]
			then
				echo "USB$cnt WRITE PASS"
				echo "USB$cnt WRITE:     PASS  write speed: $wspeed" >> test_result.log
			else
				echo "USB$cnt WRITE FAIL"
				echo "USB$cnt WRITE:     FAIL  write speed: $wspeed" >> test_result.log
			fi
		fi

	else
		echo "USB$cnt FAIL"
		echo "USB$cnt:           FAIL" >> test_result.log
	fi

	let cnt++
done




