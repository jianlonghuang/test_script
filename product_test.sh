#!/bin/bash

echo "************************************************"
echo "****************VF2 Product Test****************"
echo "************************************************"

starttime=$(date +%s)

rm *.log
chmod 777 *
cfg_name=cfg.ini

function readINI()
{
 FILENAME=$1; SECTION=$2; KEY=$3
 RESULT=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEY'/{print $2;exit}' $FILENAME`
 echo $RESULT
}

cfg_section=EEPROM
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
if [[ "$test_item" = "y" ]]
then
	./eeprom_test.sh
fi

cfg_section=GPIO
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
gpio_pid=0
if [[ "$test_item" = "y" ]]
then
	sh gpio_test.sh &
	gpio_pid=${!}
fi

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

cfg_section=EMMC
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
emmc_pid=0
if [[ "$test_item" = "y" ]]
then
	sh emmc_test.sh &
	emmc_pid=${!}
fi

cfg_section=PCIE_SSD
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
pcie_ssd_pid=0
if [[ "$test_item" = "y" ]]
then
	sh pcie_ssd_test.sh &
	pcie_ssd_pid=${!}
fi

cfg_section=GMAC0
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
gmac0_pid=0
if [[ "$test_item" = "y" ]]
then
	#gmac0 gmac1 serial excute
	sh gmac0_test.sh
	gmac0_pid=${!}
fi


cfg_section=GMAC1
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
gmac1_pid=0
if [[ "$test_item" = "y" ]]
then
	sh gmac1_test.sh
	gmac1_pid=${!}
fi

cfg_section=HDMI
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
hdmi_pid=0
if [[ "$test_item" = "y" ]]
then
	sh hdmi_test.sh
	hdmi_pid=${!}
fi

cfg_section=PWMDAC
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
pwmdac_pid=0
if [[ "$test_item" = "y" ]]
then
	sh pwmdac_test.sh
	pwmdac_pid=${!}
fi

cfg_section=CSI
str_testitem=$(readINI $cfg_name $cfg_section enable)
test_item=$(echo $str_testitem | sed 's/\r//')
csi_pid=0
if [[ "$test_item" = "y" ]]
then
	sh mipi_csi_test.sh
	csi_pid=${!}
fi

if [[ $gpio_pid != 0 ]]
then
	wait ${gpio_pid}
fi

if [[ $usb_pid != 0 ]]
then
	wait ${usb_pid}
fi

if [[ $sd_pid != 0 ]]
then
	wait ${sd_pid}
fi

if [[ $gmac0_pid != 0 ]]
then
	wait ${gmac0_pid}
fi

if [[ $gmac1_pid != 0 ]]
then
	wait ${gmac1_pid}
fi

if [[ $emmc_pid != 0 ]]
then
	wait ${emmc_pid}
fi

if [[ $pcie_ssd_pid != 0 ]]
then
	wait ${pcie_ssd_pid}
fi

if [[ $hdmi_pid != 0 ]]
then
	wait ${hdmi_pid}
fi

if [[ $pwmdac_pid != 0 ]]
then
	wait ${pwmdac_pid}
fi

if [[ $csi_pid != 0 ]]
then
	wait ${csi_pid}
fi

endtime=$(date +%s)
runmin=$(($endtime-$starttime))
echo "running time: $runmin s"

year=$(date +%y)
mon=$(date +%m)
day=$(date +%d)
result_log=$year-$mon-$day-$endtime
if [ -f result_name.log ]
then
	str=$(sed -n '1p' result_name.log)
	result_log=$result_log-$str.log
fi

if [ ! -d log ]
then
	mkdir log
fi
result_log=log/$result_log
echo $result_log

echo "************************************************"
echo "*********************Result*********************"
echo "************************************************"
#cat test_result.log
IFS=''
while read line
do
	result=$(echo $line | grep "PASS")
	if [[ "$result" != "" ]]
	then
		echo $line
		echo $line >> $result_log
	fi
done < test_result.log

while read line
do
	result=$(echo $line | grep "FAIL")
	if [[ "$result" != "" ]]
	then
		echo $line
		echo $line >> $result_log
	fi
done < test_result.log













