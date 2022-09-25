#!/bin/bash



cfg_section=EEPROM
log_suffix=".log"
log_file=$cfg_section$log_suffix

starttime=$(date +%s)

while true
do
	if [ -f $log_file ]
	then
		endtime=$(date +%s)
		runtime=$(($endtime-$starttime))
		runtime=$(echo "$runtime*1000" | bc)
		echo "$cfg_section running time: $runtime ms"
		str=$(sed -n '1p' $log_file)
		echo "$cfg_section:         $str" >> test_result.log
		echo $runtime >> $log_file
		break
	fi
done


