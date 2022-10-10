#!/bin/bash


cfg_section=CSI
log_suffix=".log"
log_file=$cfg_section$log_suffix
#echo $log_file
if [ -f $log_file ]
then
	rm $log_file
fi

starttime=$(date +%s)

echo "******************MIPI CSI testing..."

echo "media-ctl-pipeline.sh -d /dev/media0 -i csiphy0 -s ISP0 -a start"
media-ctl-pipeline.sh -d /dev/media0 -i csiphy0 -s ISP0 -a start

echo "v4l2test -d /dev/v4l-subdev3 -l stf_isp0_fw.bin"
v4l2test -d /dev/v4l-subdev3 -l stf_isp0_fw.bin

echo "v4l2test -d /dev/video1 -f 5 -c -W 1920 -H 1080 -m 0 -t 2"
v4l2test -d /dev/video1 -f 5 -c -W 1920 -H 1080 -m 0 -t 2 -C 0 &


while false
do
	if [ -f $log_file ]
	then
		endtime=$(date +%s)
		runtime=$(($endtime-$starttime))
		runtime=$(echo "$runtime*1000" | bc)
		echo "$cfg_section running time: $runtime ms"
		echo $runtime >> $log_file
		result=`ps | grep "v4l2test" | grep -v "grep"`
		if [ "$result" != "" ]
		then
			killall v4l2test
		fi
		break
	fi
done


if false
then

	sleep 2

	read -p "please enter MIPI CSI TEST OK(y/n?): " csi_test_result

	if [[ "$csi_test_result" == "y" ]]
	then
		echo "MIPI CSI   PASS"
		echo "MIPI CSI:       PASS" >> test_result.log
	else
		echo "MIPI CSI   FAIL"
		echo "MIPI CSI:       FAIL" >> test_result.log
	fi
	killall v4l2test

fi
