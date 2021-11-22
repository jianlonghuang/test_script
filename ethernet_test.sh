#!/bin/bash

function readINI()
{
 FILENAME=$1; SECTION=$2; KEY=$3
 RESULT=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEY'/{print $2;exit}' $FILENAME`
 echo $RESULT
}

cfg_name=cfg.ini
cfg_section=ETHERNET
failcnt=0

str_boardip=$(readINI $cfg_name $cfg_section boardip)
board_ip=$(echo $str_boardip | sed 's/\r//')
#echo $board_ip

str_vmip=$(readINI $cfg_name $cfg_section vmip)
vm_ip=$(echo $str_vmip | sed 's/\r//')
#echo $vm_ip

str_baud=$(readINI $cfg_name $cfg_section baud)
sbaud=$(echo $str_baud | sed 's/\r//')
#echo $sbaud

str_expectbaudtcp=$(readINI $cfg_name $cfg_section expectbaudtcp)
expect_baudtcp=$(echo $str_expectbaudtcp | sed 's/\r//')
#echo $expect_baudtcp

echo "******************ETH0 PING testing..."
ifconfig eth0 $board_ip netmask 255.255.255.0

echo "ping $vm_ip -w 5"
ping $vm_ip -w 5 2>&1 | tee ethernet_test.log

str=$(sed -n '2p' ethernet_test.log)
#echo "string: $str"
#index=`expr index "$str" =`
#echo "index: $index"
#result=${str:$index+9:4}
#echo "result: $result"

result=$(echo $str | grep "time")

#if [[ "$result" = "time" ]] && [[ $index != 0 ]]
if [[ "$result" != "" ]]
then
	echo "ETH0 PING PASS"
	echo "ETH0 PING:      PASS" >> test_result.log
else
	echo "ETH0 PING FAIL"
	echo "ETH0 PING:        FAIL" >> test_result.log
fi

echo "******************ETH0 TCP TX testing..."
iperf3 -c $vm_ip -b $sbaud 2>&1 | tee ethernet_test.log

str=$(sed -n '16p' ethernet_test.log)
#echo "string: $str"
index=`expr index "$str" /`
#echo "index: $index"
txspeed=${str:$index-12:6}
#echo "txspeed: $txspeed"
tx_speed=${str:$index-12:17}
echo "tx speed: $tx_speed"

result=$(echo $txspeed $expect_baudtcp | awk '{if($1>$2) {printf 1} else {printf 0}}')
Mbits=`expr index "$str" M`
if [[ $result = 1 ]] && [[ $index != 0 ]] && [ $Mbits -gt 0 ]
then
	echo "ETH0 TCP TX SPEED PASS"
	echo "ETH0 TX:        PASS  tx speed: $tx_speed" >> test_result.log
else
	echo "ETH0 TCP TX SPEED FAIL"
	echo "ETH0 TX:          FAIL  tx speed: $tx_speed" >> test_result.log
fi

echo "******************ETH0 TCP RX testing..."
iperf3 -c $vm_ip -b $sbaud -R 2>&1 | tee ethernet_test.log

str=$(sed -n '18p' ethernet_test.log)
#echo "string: $str"
index=`expr index "$str" /`
#echo "index: $index"
rxspeed=${str:$index-12:6}
#echo "rxspeed: $rxspeed"
rx_speed=${str:$index-12:17}
echo "rx speed: $rx_speed"

result=$(echo $rxspeed $expect_baudtcp | awk '{if($1>$2) {printf 1} else {printf 0}}')
#echo "result=$result"
Mbits=`expr index "$str" M`
if [[ $result = 1 ]] && [[ $index != 0 ]] && [ $Mbits -gt 0 ]
then
	echo "ETH0 TCP RX SPEED PASS"
	echo "ETH0 RX:        PASS  rx speed: $rx_speed" >> test_result.log
else
	echo "ETH0 TCP RX SPEED FAIL"
	echo "ETH0 RX:          FAIL  rx speed: $rx_speed" >> test_result.log
fi


