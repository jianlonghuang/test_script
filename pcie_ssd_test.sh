#!/bin/bash

function readINI()
{
 FILENAME=$1; SECTION=$2; KEY=$3
 RESULT=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEY'/{print $2;exit}' $FILENAME`
 echo $RESULT
}

cfg_name=cfg.ini
cfg_section=PCIE_SSD
k_unit=1024
log_suffix=".log"
log_file=$cfg_section$log_suffix
#echo $log_file
if [ -f $log_file ]
then
	rm $log_file
fi

starttime=$(date +%s)

echo "******************PCIE SSD testing..."

str_sddevice=$(readINI $cfg_name $cfg_section sddevice)
sd_device=$(echo $str_sddevice | sed 's/\r//')
#echo $sd_device

str_blocksize=$(readINI $cfg_name $cfg_section blocksize)
block_size=$(echo $str_blocksize | sed 's/\r//')
#echo $block_size

str_blockcnt=$(readINI $cfg_name $cfg_section blockcnt)
block_cnt=$(echo $str_blockcnt | sed 's/\r//')
#echo $block_cnt

str_expectspeed=$(readINI $cfg_name $cfg_section expectspeed)
expect_speed=$(echo $str_expectspeed | sed 's/\r//')
#echo $expect_speed

if [ -e "/dev/$sd_device" ]
then

	echo "time dd if=/dev/$sd_device of=/dev/null bs=$block_size count=$block_cnt"
	time dd if=/dev/$sd_device of=/dev/null bs=$block_size count=$block_cnt 2>&1 | tee pcie_ssd_test.log

	str=$(sed -n '3p' pcie_ssd_test.log)
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
		echo "PCIE SSD READ PASS"
		echo "PCIE SSD READ:  PASS  read speed: $rspeed" >> test_result.log
		echo "PASS: speed=$rspeed" > $log_file
	else
		echo "PCIE SSD READ FAIL"
		echo "PCIE SSD READ:  FAIL  read speed: $rspeed" >> test_result.log
		echo "FAIL: SPEED SLOW=$rspeed" > $log_file
	fi


	if false; then
		echo "time dd if=/dev/zero of=/dev/$sd_device bs=$block_size count=$block_cnt"
		time dd if=/dev/zero of=/dev/$sd_device bs=$block_size count=$block_cnt 2>&1 | tee pcie_ssd_test.log

		str=$(sed -n '3p' pcie_ssd_test.log)
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
			echo "PCIE SSD WRITE PASS"
			echo "PCIE SSD WRITE: PASS  write speed: $wspeed" >> test_result.log
		else
			echo "PCIE SSD WRITE FAIL"
			echo "PCIE SSD WRITE: FAIL  write speed: $wspeed" >> test_result.log
		fi
	fi

else
	echo "PCIE SSD FAIL"
	echo "PCIE SSD:       FAIL" >> test_result.log
	echo "FAIL: NO PCIE SSD DEVICE" > $log_file
fi

endtime=$(date +%s)
runtime=$(($endtime-$starttime))
runtime=$(echo "$runtime*1000" | bc)
echo "$cfg_section running time: $runtime ms"
echo $runtime >> $log_file


