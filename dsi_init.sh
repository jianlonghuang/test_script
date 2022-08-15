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


echo "******************MIPI DSI testing..."

echo "modetest -M starfive -a -s 116@31:1920x1080 -s 118@35:800x480 -P 39@31:1920x1080 -P 74@35:800x480 -F tiles,tiles"
modetest -M starfive -a -s 116@31:1920x1080 -s 118@35:800x480 -P 39@31:1920x1080 -P 74@35:800x480 -F tiles,tiles

