#!/bin/bash


echo "******************HDMI PWMADC testing..."

aplay -Dhw:0,0 audio8k16S.wav

read -p "please enter HDMI TEST OK(y/n?): " hdmi_test_result
read -p "please enter PWMADC TEST OK(y/n?): " pwmadc_test_result

if [[ "$hdmi_test_result" == "y" ]]
then
	echo "HDMI   PASS"
	echo "HDMI:           PASS" >> test_result.log
else
	echo "HDMI   FAIL"
	echo "HDMI:           FAIL" >> test_result.log
fi

if [[ "$pwmadc_test_result" == "y" ]]
then
	echo "PWMADC PASS"
	echo "PWMADC:         PASS" >> test_result.log
else
	echo "PWMADC FAIL"
	echo "PWMADC:         FAIL" >> test_result.log
fi