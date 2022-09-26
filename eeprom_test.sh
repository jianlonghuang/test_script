#!/bin/bash


echo "scan or enter pn,sn,pcb,bom,mac0,mac1"
echo "for example:"
echo "VF7110A1-2239-D004E000,00000001,B1,A,6CCF396CDE22,6CCF397CAE33"
read -ep "please input: " data

starttime=$(date +%s)
result_name=""

IFS=","
i=0
array_data=($data)

for var in ${array_data[@]}
do
	let i++
	echo $var
done

if [ $i -gt 5 ]
then
	pn=${array_data[0]}
	sn=${array_data[1]}
	psn=$pn"-"$sn
	pcb_version=${array_data[2]}
	bom_version=${array_data[3]}
	eth0_mac=${array_data[4]}
	str_eth0_mac=`echo "${eth0_mac:0:2}:${eth0_mac:2:2}:${eth0_mac:4:2}:${eth0_mac:6:2}:${eth0_mac:8:2}:${eth0_mac:10:2}"`
	echo "str_eth0_mac: $str_eth0_mac"
	eth1_mac=${array_data[5]}
	str_eth1_mac=`echo "${eth1_mac:0:2}:${eth1_mac:2:2}:${eth1_mac:4:2}:${eth1_mac:6:2}:${eth1_mac:8:2}:${eth1_mac:10:2}"`
	echo "str_eth1_mac: $str_eth1_mac"

	./enter_mac_sn/enter_mac_sn $psn $bom_version $pcb_version $str_eth0_mac $str_eth1_mac

	result_name=$psn-$pcb_version
	IFS=" "
else
	IFS=" "
	echo "input erro format"
	result_name="err"
fi

echo $result_name > result_name.log

cfg_section=EEPROM
log_suffix=".log"
log_file=$cfg_section$log_suffix

while true
do
	if [ -f $log_file ]
	then
		endtime=$(date +%s)
		runtime=$(($endtime-$starttime))
		runtime=$(echo "$runtime*1000" | bc)
		echo "$cfg_section running time: $runtime ms"
		str=$(sed -n '1p' $log_file)
		echo "EEPROM   $str"
		echo "$cfg_section:         $str" >> test_result.log
		echo $runtime >> $log_file
		break
	fi
done


