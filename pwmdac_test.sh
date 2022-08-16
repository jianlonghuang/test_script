#!/bin/bash


cfg_section=PWMDAC
log_suffix=".log"
log_file=$cfg_section$log_suffix
#echo $log_file
if [ -f $log_file ]
then
	rm $log_file
fi

starttime=$(date +%s)

echo "******************PWMADC testing..."

echo "aplay -Dhw:0,0 audio8k16S.wav"
#aplay -Dhw:0,0 audio.wav &


while true
do
	if [ -f $log_file ]
	then
		endtime=$(date +%s)
		runtime=$(($endtime-$starttime))
		runtime=$(echo "$runtime*1000" | bc)
		echo "$cfg_section running time: $runtime ms"
		echo $runtime >> $log_file

		result=`ps | grep "aplay" | grep -v "grep"`
		if [ "$result" != "" ]
		then
			killall aplay
		fi
		break
	fi
done


if false
then

	read -p "please enter PWMADC TEST OK(y/n?): " pwmadc_test_result

	if [[ "$pwmadc_test_result" == "y" ]]
	then
		echo "PWMADC PASS"
		echo "PWMADC:         PASS" >> test_result.log
	else
		echo "PWMADC FAIL"
		echo "PWMADC:         FAIL" >> test_result.log
	fi

fi
