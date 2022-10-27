#!/bin/bash



cfg_section=USB_DEVICE
log_suffix=".log"
log_file=$cfg_section$log_suffix
#echo $log_file
if [ -f $log_file ]
then
	rm $log_file
fi

starttime=$(date +%s)

echo "******************USB DEVICE testing..."

echo "/root/usb_device.sh mass_storage create 200"
/root/usb_device.sh mass_storage create 30

echo "/root/usb_device.sh mass_storage start"
/root/usb_device.sh mass_storage start

state_file=/sys/class/udc/10100000.usb/state

if [[ -f $state_file ]]
then
	sleep 3
	state=`cat $state_file`
	echo "usb device state: $state"
	if [[ $state = "configured" ]]
	then
		echo "$cfg_section PASS"
		echo "$cfg_section:     PASS" >> test_result.log
		echo "PASS" > $log_file
	else
		echo "$cfg_section FAIL"
		echo "$cfg_section:     FAIL" >> test_result.log
		echo "FAIL: $state" > $log_file
	fi
else
	echo "$cfg_section FAIL"
	echo "$cfg_section:     FAIL" >> test_result.log
	echo "FAIL: NO state file" > $log_file

fi

endtime=$(date +%s)
runtime=$(($endtime-$starttime))
runtime=$(echo "$runtime*1000" | bc)
echo "$cfg_section running time: $runtime ms"
echo $runtime >> $log_file
