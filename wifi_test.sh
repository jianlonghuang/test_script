#!/bin/bash

function readINI()
{
 FILENAME=$1; SECTION=$2; KEY=$3
 RESULT=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEY'/{print $2;exit}' $FILENAME`
 echo $RESULT
}

cfg_name=cfg.ini
cfg_section=WLAN


str_vmip=$(readINI $cfg_name $cfg_section vmip)
vm_ip=$(echo $str_vmip | sed 's/\r//')
#echo $vm_ip

str_baud=$(readINI $cfg_name $cfg_section baud)
sbaud=$(echo $str_baud | sed 's/\r//')
#echo $sbaud

str_expectbaudtcp=$(readINI $cfg_name $cfg_section expectbaudtcp)
expect_baudtcp=$(echo $str_expectbaudtcp | sed 's/\r//')
#echo $expect_baudtcp

str_ssid=$(readINI $cfg_name $cfg_section ssid)
link_ssid=$(echo $str_ssid | sed 's/\r//')
#echo $link_ssid

str_psk=$(readINI $cfg_name $cfg_section psk)
link_psk=$(echo $str_psk | sed 's/\r//')
#echo $link_psk

ifconfig wlan0 down
sleep 1
ifconfig wlan0 up

echo "ctrl_interface=/var/run/wpa_supplicant" > /etc/wpa_supplicant.conf
echo "ap_scan=1" >> /etc/wpa_supplicant.conf
echo "network={" >> /etc/wpa_supplicant.conf
echo "    ssid=\"$link_ssid\"" >> /etc/wpa_supplicant.conf
echo "    psk=\"$link_psk\"" >> /etc/wpa_supplicant.conf
echo "}" >> /etc/wpa_supplicant.conf

wpa_supplicant -D nl80211 -i wlan0 -c /etc/wpa_supplicant.conf -d -f /var/log/wpa_supplicant.log &
udhcpc -i wlan0 -n

echo "******************WLAN0 PING testing..."
ping_cnt=3
ping_over=0
while ( [ $ping_cnt -gt 0 ] && [ $ping_over -eq 0 ] )
do
	echo "ping $vm_ip -w 5 -I wlan0"
	ping $vm_ip -w 5 -I wlan0 2>&1 | tee wlan_test.log
	while read line
	do
		result=$(echo $line | grep "time=")
		if [[ "$result" != "" ]]
		then
			ping_over=1
			echo "ping_over: $ping_over"
			break
		fi
	done < wlan_test.log
	let ping_cnt--
done

if [[ $ping_over != 0 ]]
then
	echo "WLAN0 PING PASS"
	echo "WLAN0 PING:     PASS" >> test_result.log
else
	echo "WLAN0 PING FAIL"
	echo "WLAN0 PING:     FAIL" >> test_result.log
fi

echo "******************WLAN0 TCP TX testing..."
iperf3 -c $vm_ip -b $sbaud 2>&1 | tee wlan_test.log

str=$(sed -n '16p' wlan_test.log)
#echo "string: $str"
index=`expr index "$str" /`
#echo "index: $index"
txspeed=${str:$index-12:6}
echo "txspeed: $txspeed"
tx_speed=${str:$index-12:17}
echo "tx speed: $tx_speed"

result=$(echo $txspeed $expect_baudtcp | awk '{if($1>$2) {printf 1} else {printf 0}}')
Mbits=`expr index "$str" M`
if [[ $result = 1 ]] && [[ $index != 0 ]] && [ $Mbits -gt 0 ]
then
	echo "WLAN0 TCP TX SPEED PASS"
	echo "WLAN0 TX:       PASS  tx speed: $tx_speed" >> test_result.log
else
	echo "WLAN0 TCP TX SPEED FAIL"
	echo "WLAN0 TX:       FAIL  tx speed: $tx_speed" >> test_result.log
fi

echo "******************WLAN0 TCP RX testing..."
iperf3 -c $vm_ip -b $sbaud -R 2>&1 | tee wlan_test.log

str=$(sed -n '18p' wlan_test.log)
#echo "string: $str"
index=`expr index "$str" /`
#echo "index: $index"
rxspeed=${str:$index-12:6}
#echo "rxspeed: $rxspeed"
rx_speed=${str:$index-12:17}
echo "rx speed: $rx_speed"

result=$(echo $rxspeed $expect_baudtcp | awk '{if($1>$2) {printf 1} else {printf 0}}')
Mbits=`expr index "$str" M`
if [[ $result = 1 ]] && [[ $index != 0 ]] && [ $Mbits -gt 0 ]
then
	echo "WLAN0 TCP RX SPEED PASS"
	echo "WLAN0 RX:       PASS  rx speed: $rx_speed" >> test_result.log
else
	echo "WLAN0 TCP RX SPEED FAIL"
	echo "WLAN0 RX:       FAIL  rx speed: $rx_speed" >> test_result.log
fi

killall wpa_supplicant
killall udhcpc


