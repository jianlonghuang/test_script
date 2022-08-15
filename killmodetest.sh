#! /bin/bash

starttime=$(date +%s)


while true
do
	endtime=$(date +%s)
	runtime=$(($endtime-$starttime))
	if [ $runtime -gt 10 ]
	then
		killall modetest
		break
	fi
done
