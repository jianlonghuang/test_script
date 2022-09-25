#!/bin/bash

echo "####################gpio test start:"
#source common.sh
function readINI()
{
 FILENAME=$1; SECTION=$2; KEY=$3
 RESULT=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEY'/{print $2;exit}' $FILENAME`
 echo $RESULT
}
cfg_name=cfg.ini
cfg_section=GPIO
log_suffix=".log"
log_file=$cfg_section$log_suffix
#echo $log_file
if [ -f $log_file ]
then
	rm $log_file
fi

starttime=$(date +%s)

failcnt=0
level=-1
gpiochip=0
high=1
low=0
i=0
result_des="FAIL:"

while :
do
	pinnum1_fail=0
	pinnum2_fail=0
	let i++
	str_pinnum=$(readINI $cfg_name $cfg_section pins$i)
	pinnum=$(echo $str_pinnum | sed 's/\r//')
	index=`expr index "$pinnum" ,`
	if [ "$index" = "0" ]
	then
		break
	fi

	pinnum1=${pinnum:0:2}
	#echo $pinnum1
	pinnum2=${pinnum:$index:2}
	#echo $pinnum2
	
	echo "gpio$pinnum1 testing..."

	gpioset $gpiochip $pinnum1=$high
	level=-1
	level=`gpioget $gpiochip $pinnum2`
	if [ "$level" != $high ]
	then
		echo "gpio$pinnum1 set $high fail"
		let failcnt++
		let pinnum1_fail++
	fi

	gpioset $gpiochip $pinnum1=$low
	level=-1
	level=`gpioget $gpiochip $pinnum2`
	if [ "$level" != $low ]
	then
		echo "gpio$pinnum1 set $low fail"
		let failcnt++
		let pinnum1_fail++
	fi

	gpioset $gpiochip $pinnum2=$high
	level=-1
	level=`gpioget $gpiochip $pinnum1`
	if [ "$level" != $high ]
	then
		echo "gpio$pinnum1 get $high fail"
		let failcnt++
		let pinnum1_fail++
	fi

	gpioset $gpiochip $pinnum2=$low
	level=-1
	level=`gpioget $gpiochip $pinnum1`
	if [ "$level" != $low ]
	then
		echo "gpio$pinnum1 get $low fail"
		let failcnt++
		let pinnum1_fail++
	fi

	if [ $pinnum1_fail = 0 ]
	then
		echo "gpio$pinnum1 test pass"
	else
		echo "gpio$pinnum1 test fail"
		des_tmp="gpio"$pinnum1"; "
		result_des=$result_des$des_tmp
	fi

	echo "gpio$pinnum2 testing..."

	gpioset $gpiochip $pinnum2=$high
	level=-1
	level=`gpioget $gpiochip $pinnum1`
	if [ "$level" != $high ]
	then
		echo "gpio$pinnum2 set $high fail"
		let failcnt++
		let pinnum2_fail++
	fi

	gpioset $gpiochip $pinnum2=$low
	level=-1
	level=`gpioget $gpiochip $pinnum1`
	if [ "$level" != $low ]
	then
		echo "gpio$pinnum2 set $low fail"
		let failcnt++
		let pinnum2_fail++
	fi
	
	gpioset $gpiochip $pinnum1=$high
	level=-1
	level=`gpioget $gpiochip $pinnum2`
	if [ "$level" != $high ]
	then
		echo "gpio$pinnum2 get $high fail"
		let failcnt++
		let pinnum2_fail++
	fi

	gpioset $gpiochip $pinnum1=$low
	level=-1
	level=`gpioget $gpiochip $pinnum2`
	if [ "$level" != $low ]
	then
		echo "gpio$pinnum2 get $low fail"
		let failcnt++
		let pinnum2_fail++
	fi

	if [ $pinnum2_fail = 0 ]
	then
		echo "gpio$pinnum2 test pass"
	else
		echo "gpio$pinnum2 test fail"
		des_tmp="gpio"$pinnum2"; "
		result_des=$result_des$des_tmp
	fi
done


if [ $failcnt = 0 ]
then
	echo "GPIO:           PASS"
	echo "GPIO:           PASS" >> test_result.log
	echo "PASS" > $log_file
else
	echo "GPIO:           FAIL"
	echo "GPIO:           FAIL" >> test_result.log
	echo $result_des > $log_file
fi

endtime=$(date +%s)
runtime=$(($endtime-$starttime))
runtime=$(echo "$runtime*1000" | bc)
echo "$cfg_section running time: $runtime ms"
echo $runtime >> $log_file

