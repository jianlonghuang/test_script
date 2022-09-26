#!/bin/bash


echo "******************MIPI DSI testing..."

echo "modetest -M starfive -D 0 -a -s 118@35:800x480 -P 74@35:800x480@RG16 -Ftiles"
modetest -M starfive -D 0 -a -s 118@35:800x480 -P 74@35:800x480@RG16 -Ftiles

read -ep "please enter MIPI DSI TEST OK(y/n?): " dsi_test_result

if [[ "$dsi_test_result" == "y" ]]
then
	echo "MIPI DSI   PASS"
	echo "MIPI DSI:       PASS" >> test_result.log
else
	echo "MIPI DSI   FAIL"
	echo "MIPI DSI:       FAIL" >> test_result.log
fi

