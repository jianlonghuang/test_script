#!/usr/bin/bash
#!/bin/bash

function readINI()
{
 FILENAME=$1; SECTION=$2; KEY=$3
 RESULT=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEY'/{print $2;exit}' $FILENAME`
 echo $RESULT
}

cfg_name=cfg.ini
cfg_section=BLUETOOTH

str_devmac=$(readINI $cfg_name $cfg_section devmac)
dev_mac=$(echo $str_devmac | sed 's/\r//')
echo $dev_mac

scan_cnt=3
scan_over=0

hciconfig hci0 up

bluetoothctl -- remove $dev_mac

while ( [ $scan_cnt -gt 0 ] && [ $scan_over -eq 0 ] )
do
	echo "$scan_cnt"
	{
		printf 'scan on\n\n' 
		sleep 20 
	}| bluetoothctl 2>&1 | tee bluetooth.log
	while read line
	do
		result1=$(echo $line | grep "$dev_mac")
		result2=$(echo $line | grep "NEW")
		if [[ "$result1" != "" ]] && [[ "$result2" != "" ]]
		then
			scan_over=1
			echo "scan_over: $scan_over"
			break
		fi
	done < bluetooth.log
	let scan_cnt--
done

suc_flag=0
str_suc="Connection successful"
bluetoothctl -- pair $dev_mac
bluetoothctl -- trust $dev_mac
bluetoothctl -- connect $dev_mac 2>&1 | tee bluetooth.log
while read line
do
	result=$(echo $line | grep "$str_suc")
	echo "result: $result"
	if [[ "$result" != "" ]]
	then
		suc_flag=1
		echo "suc_flag: $suc_flag"
		break
	fi
done < bluetooth.log


if [ $suc_flag -eq 0 ]
then
	echo "BLUETOOTH FAIL"
	echo "BLUETOOTH:        FAIL  connect fail" >> test_result.log
else
	echo "BLUETOOTH PASS"
	echo "BLUETOOTH:      PASS" >> test_result.log
fi



