#!/bin/bash

echo "************************************************"
echo "******************Product Test******************"
echo "************************************************"

rm *.log
chmod 777 *
cfg_name=cfg.ini

function readINI()
{
 FILENAME=$1; SECTION=$2; KEY=$3
 RESULT=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEY'/{print $2;exit}' $FILENAME`
 echo $RESULT
}


cfg_section=USB
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
usb_pid=0
if [[ "$test_item" = "y" ]]
then
	sh usb_test.sh &
	usb_pid=${!}
fi

cfg_section=SD
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
sd_pid=0
if [[ "$test_item" = "y" ]]
then
	sh sd_test.sh &
	sd_pid=${!}
fi

cfg_section=ETHERNET
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
ethernet_pid=0
if [[ "$test_item" = "y" ]]
then
	sh ethernet_test.sh &
	ethernet_pid=${!}
fi


cfg_section=BLUETOOTH
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
bluetooth_pid=0
if [[ "$test_item" = "y" ]]
then
	sh bluetooth.sh &
	bluetooth_pid=${!}
fi


cfg_section=WLAN
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
wifi_pid=0
if [[ "$test_item" = "y" ]]
then
	sh wifi_test.sh &
	wifi_pid=${!}
fi

if [[ $usb_pid != 0 ]]
then
	wait ${usb_pid}
fi

if [[ $sd_pid != 0 ]]
then
	wait ${sd_pid}
fi

if [[ $ethernet_pid != 0 ]]
then
	wait ${ethernet_pid}
fi

if [[ $bluetooth_pid != 0 ]]
then
	wait ${bluetooth_pid}
fi

if [[ $wifi_pid != 0 ]]
then
	wait ${wifi_pid}
fi

cfg_section=HDMI_PWMADC
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')

if [ "$test_item" = "y" ]
then
	sh hdmi_pwmadc_test.sh
fi


echo "************************************************"
echo "*********************Result*********************"
echo "************************************************"
cat test_result.log

rm *.log












