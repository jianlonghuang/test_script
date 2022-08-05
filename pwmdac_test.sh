#!/bin/bash


echo "******************PWMADC testing..."

echo "aplay -Dhw:0,0 audio8k16S.wav"
aplay -Dhw:0,0 audio8k16S.wav

read -p "please enter PWMADC TEST OK(y/n?): " pwmadc_test_result

if [[ "$pwmadc_test_result" == "y" ]]
then
	echo "PWMADC PASS"
	echo "PWMADC:         PASS" >> test_result.log
else
	echo "PWMADC FAIL"
	echo "PWMADC:         FAIL" >> test_result.log
fi
