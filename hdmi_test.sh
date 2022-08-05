#!/bin/bash


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

