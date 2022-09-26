#!/bin/bash


function get_dsi_result()
{
	starttime=$(date +%s)
	while true
	do
		endtime=$(date +%s)
		runtime=$(($endtime-$starttime))
		if [ $runtime -gt 10 ]
		then
			echo -ne "\n"
			break
		fi
	done
}

echo "******************HDMI testing..."

echo "get_dsi_result | modetest -M starfive -a -s 116@31:1920x1080 -s 118@35:800x480 -P 39@31:1920x1080 -P 74@35:800x480 -F tiles,tiles"
get_dsi_result | modetest -M starfive -a -s 116@31:1920x1080 -s 118@35:800x480 -P 39@31:1920x1080 -P 74@35:800x480 -F tiles,tiles

read -ep "please enter HDMI TEST OK(y/n?): " hdmi_test_result

if [[ "$hdmi_test_result" == "y" ]]
then
	echo "HDMI   PASS"
	echo "HDMI:           PASS" >> test_result.log
else
	echo "HDMI   FAIL"
	echo "HDMI:           FAIL" >> test_result.log
fi

sleep 1

read -ep "please enter MIPI DSI TEST OK(y/n?): " dsi_test_result

if [[ "$dsi_test_result" == "y" ]]
then
	echo "MIPI DSI   PASS"
	echo "MIPI DSI:       PASS" >> test_result.log
else
	echo "MIPI DSI   FAIL"
	echo "MIPI DSI:       FAIL" >> test_result.log
fi
