#!/bin/bash



cfg_section=HDMI
log_suffix=".log"
log_file=$cfg_section$log_suffix
#echo $log_file
if [ -f $log_file ]
then
	rm $log_file
fi

starttime=$(date +%s)

while false
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

if false
then

	echo "******************HDMI testing..."

	echo "modetest -M starfive -D 0 -a -s 116@31:1920x1080 -P 39@31:1920x1080@RG16 -Ftiles"
	modetest -M starfive -D 0 -a -s 116@31:1920x1080 -P 39@31:1920x1080@RG16 -Ftiles

	read -p "please enter HDMI TEST OK(y/n?): " hdmi_test_result

	if [[ "$hdmi_test_result" == "y" ]]
	then
		echo "HDMI   PASS"
		echo "HDMI:           PASS" >> test_result.log
	else
		echo "HDMI   FAIL"
		echo "HDMI:           FAIL" >> test_result.log
	fi

fi

