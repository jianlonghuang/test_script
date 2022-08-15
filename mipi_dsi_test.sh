#!/bin/bash



cfg_section=DSI
log_suffix=".log"
log_file=$cfg_section$log_suffix
#echo $log_file
if [ -f $log_file ]
then
	rm $log_file
fi

starttime=$(date +%s)

while true
do
	if [ -f $log_file ]
	then
		endtime=$(date +%s)
		runtime=$(($endtime-$starttime))
		runtime=$(echo "$runtime*1000" | bc)
		echo "$cfg_section running time: $runtime ms"
		echo $runtime >> $log_file
		break
	fi
done


