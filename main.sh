#!/bin/bash


uart_dev=/dev/ttyS3
baurd=115200
dtbo=vf2-overlay-uart3-i2c.dtbo
ms_count=0
fun_0_init=0
fun_1_item=1
fun_3_heart=3
fun_4_result=4
uart_recv_data=ttytemp.dat
eeprom_data=eeprom.eep
str_head="{@"
str_tail="}"
str_test_num_flag="#"
log_suffix=".log"
cfg_name=cfg.ini
test_list=(GPIO GMAC0 GMAC1 USB SD EMMC PCIE_SSD HDMI CSI PWMDAC DSI)
test_fun_list=("gpio_test.sh" "gmac0_test.sh" "gmac1_test.sh" "usb_test.sh" "sd_test.sh" "emmc_test.sh" "pcie_ssd_test.sh" "hdmi_test.sh" "mipi_csi_test.sh" "pwmdac_test.sh" "mipi_dsi_test.sh")
test_parallel_list=(1 1 1 1 1 1 1 1 1 1 0)
test_auto_list=(1 1 1 1 1 1 1 0 0 0 0)

test_enable_list=(GPIO GMAC0 GMAC1 USB SD EMMC PCIE_SSD HDMI CSI PWMDAC DSI)
test_enable_fun_list=("gpio_test.sh" "gmac0_test.sh" "gmac1_test.sh" "usb_test.sh" "sd_test.sh" "emmc_test.sh" "pcie_ssd_test.sh" "hdmi_test.sh" "mipi_csi_test.sh" "pwmdac_test.sh" "mipi_dsi_test.sh")
test_enable_parallel_list=(1 1 1 1 1 1 1 1 1 1 0)
test_enable_pid_list=(0 0 0 0 0 0 0 0 0 0 0)
test_over_list=(0 0 0 0 0 0 0 0 0 0 0)
test_enable_auto_list=(1 1 1 1 1 1 1 0 0 0 0)
test_over_cnt=0
heart_flag=0
heart_log=heart.log
get_module_info=0
init_first=0
init_overtime=0
outcome_overtime=0

month=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

test_enable_num=${#test_enable_list[@]}

function readINI()
{
 FILENAME=$1; SECTION=$2; KEY=$3
 RESULT=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$KEY'/{print $2;exit}' $FILENAME`
 echo $RESULT
}

function uart3_init()
{
	mount -t configfs none /sys/kernel/config
	mkdir -p /sys/kernel/config/device-tree/overlays/dtoverlay
	cat $dtbo > /sys/kernel/config/device-tree/overlays/dtoverlay/dtbo
}

function uart3_open()
{
	stty -F $uart_dev $baurd
}

function send_data()
{
	echo $* > $uart_dev
}

function set_date()
{
	date -s 2022-08-12
	date -s 09:00:00
}


function heart()
{
	send_flag=$1

	while true
	do
		time=`date +%Y-%m-%d" "%H:%M:%S`
		heart_frame={@$fun_3_heart,$time}
		if [ "$send_flag" = "1" ]
		then
			send_data $heart_frame
		fi
		echo "1" > $heart_log
		echo $heart_frame >> $heart_log
		sleep 1
	done
}

function heart_burning()
{
	if [ -f "heart.log" ]
	then
		line=$(sed -n '1p' $heart_log)
		if [ "$line" = "1" ]
		then
			line=$(sed -n '2p' $heart_log)
			send_data $line
			cat /dev/null > $heart_log
		fi
	fi
}

function module_info()
{
	data=$1
	IFS=","
	i=0
	array_data=($data)

	for var in ${array_data[@]}
	do
		let i++
		echo $var
	done

	if [ $i -gt 5 ]
	then
		pn=${array_data[2]}
		sn=${array_data[3]}
		sn=$pn"-"$sn
		pcb_version=${array_data[4]}
		bom_version=${array_data[5]}
		eth0_mac=${array_data[6]}
		str_eth0_mac=`echo "${eth0_mac:0:2}:${eth0_mac:2:2}:${eth0_mac:4:2}:${eth0_mac:6:2}:${eth0_mac:8:2}:${eth0_mac:10:2}"`
		echo "str_eth0_mac: $str_eth0_mac"
		eth1_mac=${array_data[7]}
		str_eth1_mac=`echo "${eth1_mac:0:2}:${eth1_mac:2:2}:${eth1_mac:4:2}:${eth1_mac:6:2}:${eth1_mac:8:2}:${eth1_mac:10:2}"`
		echo "str_eth1_mac: $str_eth1_mac"

		./enter_mac_sn/enter_mac_sn $sn $bom_version $pcb_version $str_eth0_mac $str_eth1_mac

		IFS=" "
		frame="{@5,#0,"$pn,$sn,$eth0_mac,$eth1_mac
		echo "frame: $frame"
		send_data $frame
	fi

	IFS=" "
}

function get_version_date()
{
	version_data=$*
	date_day=1
	date_month=1
	date_year=2022
	IFS=" "

	for ((i=0;i<12;i++))
	do
		result=$(echo $version_data | grep "${month[$i]}")
		if [[ "$result" != "" ]]
		then
			date_month=i
			let date_month++
		fi
	done

	result=$(echo $version_data | grep "CST")
	if [[ "$result" != "" ]]
	then
		array_date=($result)
		count=0
		for var in ${array_date[@]}
		do
			let count++
		done
	fi
	
	if [ $count -gt 4 ]
	then
		year_index=`expr $count - 1`
		day_index=`expr $count - 4`
		date_year=${array_date[$year_index]}
		date_day=${array_date[$day_index]}
	fi
	
	str_date=$date_year"-"$date_month"-"$date_day
	echo $str_date
	
}

function test_init()
{
	version_mds=$(echo `md5sum main.sh`)
	array_version_mds=($version_mds)
	version_mds=${array_version_mds[0]}
	echo "version_mds: $version_mds"
	version > version.log

	line=$(sed -n '1p' version.log)
	vesion_date=$(get_version_date $line)
	line=$(sed -n '2p' version.log)
	#echo $line
	result=$(echo $line | grep "VF2_51")
	if [ $result != "" ]
	then
		v_index=`expr index "$line" v`
		str_len=${#line}
		len=`expr $str_len - $v_index`
		if [ $v_index -gt 6 ]
		then
			str_version=${line:$v_index:$len}
			#echo "str_version: $str_version"
		fi
	fi

	init_frame="{@0,#main,"$str_version,$vesion_date,$version_mds$str_tail
	#echo "init_frame: $init_frame"
	send_data $init_frame
}


function test_list_init()
{
	test_enable_num=0
	for ((i=0;i<${#test_list[@]};i++))
	do
		cfg_section=${test_list[i]}
		str_testitem=$(readINI $cfg_name $cfg_section enable)
		test_item=$(echo $str_testitem | sed 's/\r//')
		#echo "$cfg_section: $test_item"
		if [[ "$test_item" = "y" ]]
		then
			test_enable_list[test_enable_num]=$cfg_section
			test_enable_fun_list[test_enable_num]=${test_fun_list[i]}
			test_enable_parallel_list[test_enable_num]=${test_parallel_list[i]}
			test_enable_auto_list[test_enable_num]=${test_auto_list[i]}
			echo "test_enable_fun_list$i: ${test_enable_fun_list[test_enable_num]}: ${test_enable_parallel_list[test_enable_num]}"
			let test_enable_num++
		fi
	done

	#echo "test_enable_num: $test_enable_num"
	str_test_list=${test_enable_list[0]}
	for ((i=1;i<test_enable_num;i++))
	do
		test_list_tmp=${test_enable_list[i]}
		str_test_list=$str_test_list,$test_list_tmp
		#echo "test_enable_list: $str_test_list"
	done

	test_list_frame="{@1,#"$test_enable_num,$str_test_list$str_tail
	#echo "test_list_frame: $test_list_frame"
	send_data $test_list_frame
}

function get_run_time()
{
	log_file=$1
	while read -r line
	do
		result=$(echo $line | grep "real")
		if [ "$result" != "" ]
		then
			m_index=`expr index "$line" m`
			s_index=`expr index "$line" s`
			if [[ $s_index -gt m_index ]] && [[ $m_index -ne 0 ]] && [[ $s_index -ne 0 ]]
			then
				len=`expr $s_index - $m_index - 1`
				run_time=${line:$m_index:$len}
				run_time=$(echo "$run_time*1000" | bc)
				echo $run_time
			fi
		fi
		
	done < $log_file

}

function get_test_item_num()
{
	for ((i=0;i<test_enable_num;i++))
	do
		test_list_tmp=${test_enable_list[i]}
		if [ "$test_list_tmp" = "$1" ]
		then
			echo $i
			break
		fi
	done
}

function rm_recv_data()
{
	if [ -f $uart_recv_data ]
	then
		rm $uart_recv_data
		new_info=null
		old_info=null
	fi
}

function get_recv_file_info()
{
	if [ -f $uart_recv_data ]
	then
		info=`ls -l "$uart_recv_data"`
	else
		info="null"
	fi
	echo $info
}

function recv_data()
{
	rm_recv_data
	cat $uart_dev >> $uart_recv_data &
	info=$(get_recv_file_info)
	echo $info
}

function send_frame()
{
	data=$1
	
	result1=$(echo $data | grep "${str_head}")
	result2=`expr index "$data" $str_tail`
	item_index=`expr index "$data" $str_test_num_flag`
	let comma_last_index=`echo "$data" | awk -F '','' '{printf "%d", length($0)-length($NF)}'`
	comma_first_index=`expr index "$data" ,`
	func_index=`expr index "$data" @`
	#echo "comma_first_index: $comma_first_index"
	#echo "func_index: $func_index"
	echo "result1: $result1"
	#echo "result2: $result2"
	#echo "item_index: $item_index"
	#echo "comma_last_index: $comma_last_index"
	if [[ "$result1" != "" ]] && [[ $result2 -gt $comma_last_index ]] && [[ $comma_last_index -gt $item_index ]] && [[ $comma_first_index -gt $func_index ]]
	then
		len=`expr $comma_last_index - $item_index - 1`
		test_num=${data:$item_index:$len}
		#echo "test_num: $test_num"
		len=`expr $comma_first_index - $func_index - 1`
		func_num=${data:$func_index:$len}
		#echo "func_num: $func_num"
		if [ "$func_num" = "5" ]
		then
			module_info $data
			get_module_info=1
		elif [ "$func_num" = "4" ]
		then
			if [ $test_num -lt $test_enable_num ]
			then
				len=`expr $result2 - $comma_last_index - 1`
				test_result=${data:$comma_last_index:$len}
				#echo "test_result: $test_result"

				frame=${data:0:$comma_last_index}
				test_name=${test_enable_list[$test_num]}

				if [ $test_result = "1" ]
				then
					str_result="PASS"
				else
					str_result="FAIL"
				fi

				log_file=$test_name$log_suffix
				echo $str_result > $log_file
				test_enable_auto_list[$test_num]=1
			else
				echo "recv wrong test_num: $test_num"
			fi
		else
			echo "recv wrong func_num: $func_num"
		fi
	else
		echo "recv wrong data"
	fi

}

function recv_data_deal()
{
	while read -r line
	do
		echo $line
		send_frame $line
	done < $uart_recv_data

	cat /dev/null > $uart_recv_data
}

function is_recv_data()
{
	new_info=$(get_recv_file_info)
	#echo $new_info
	if [ "$new_info" != "$old_info" ]
	then
		recv=1;
		recv_idle_count=0
	fi

	if [ "$recv" = "1" ]
	then
		if [ "$new_info" = "$old_info" ]
		then
			let recv_idle_count++
			if [ $recv_idle_count -gt $1 ]
			then
				recv_over=1
			fi
		fi
		
	fi

	if [ "$recv_over" = "1" ]
	then
		recv_over=0
		recv=0
		recv_idle_count=0
		#echo "recv_over"
		recv_data_deal
		new_info=$(get_recv_file_info)
	fi

	old_info=$new_info
}


function test_process()
{
	for ((i=0;i<test_enable_num;i++))
	do
		if [ ${test_enable_parallel_list[i]} = "1" ]
		then
			sh ${test_enable_fun_list[i]} &
			test_enable_pid_list[i]=$!
			echo "${test_enable_fun_list[i]}: ${test_enable_pid_list[i]}"
		fi
	done
}


function is_process_over()
{
	result=`ps | grep $1 | grep -v "grep"`
	if [ "$result" != "" ]
	then
		echo "runing"
	else
		echo "over"
	fi
}

function test_result_upload()
{
	for ((i=0;i<test_enable_num;i++))
	do
		if [[ ${test_enable_parallel_list[i]} = "1" ]] && [[ ${test_over_list[i]} = "0" ]]
		then
			status=$(is_process_over ${test_enable_pid_list[i]})
			#echo "${test_enable_list[i]} ${test_enable_pid_list[i]} $status"
			if [[ $status = "over" ]] && [[ ${test_enable_auto_list[i]} = "1" ]]
			then
				test_over_list[i]=1
				log_suffix=".log"
				log_file=${test_enable_list[i]}$log_suffix
				if [ -f $log_file ]
				then
					test_num=$(get_test_item_num ${test_enable_list[i]})
					str_test_des=$(sed -n '1p' $log_file)
					str_test_time=$(sed -n '2p' $log_file)
					result=$(echo $str_test_des | grep "PASS")
					if [ "$result" != "" ]
					then
						str_test_result=1
					else
						str_test_result=0
					fi
					frame="{@4,#"$test_num,${test_enable_list[i]},$str_test_result,$str_test_time,$str_test_des$str_tail
					#echo $frame
					send_data $frame
				fi
			fi
		fi
	done
}

function get_dsi_result()
{
	starttime=$(date +%s)
	while true
	do
		endtime=$(date +%s)
		runtime=$(($endtime-$starttime))
		if [ $runtime -gt 8 ]
		then
			echo -ne "\n"
			break
		fi
	done
}

function dsi_process()
{
	test_num=$(get_test_item_num "DSI")
	echo "dsi_test_num: $test_num"
	if [[ $test_num -lt $test_enable_num ]] && [[  ${test_enable_parallel_list[$test_num]} = "0" ]]
	then
		get_dsi_result | modetest -M starfive -a -s 116@31:1920x1080 -s 118@35:800x480 -P 39@31:1920x1080 -P 74@35:800x480 -F tiles,tiles

		test_enable_parallel_list[$test_num]=1
	fi
}

function pwmdac_process()
{
	test_num=$(get_test_item_num "PWMDAC")
	echo "PWMDAC_test_num: $test_num"
	if [[ $test_num -lt $test_enable_num ]] && [[  ${test_enable_parallel_list[$test_num]} = "0" ]]
	then
		test_enable_parallel_list[$test_num]=1
		aplay -Dhw:0,0 audio.wav
	fi
}

function manual_outcome_overtime()
{
	endtime=$(date +%s)
	runtime=$(($endtime-$starttime))
	echo "manual_outcome_overtime: $runtime"
	if [[ $runtime -gt 60 ]] && [[ $outcome_overtime -eq 0 ]]
	then
		outcome_overtime=1
		for ((i=0;i<test_enable_num;i++))
		do
			if [ ${test_enable_auto_list[$i]} = "0" ]
			then
				test_name=${test_enable_list[$i]}
				log_file=$test_name$log_suffix
				#echo "log_file:$log_file"
				echo "FAIL" > $log_file
				test_enable_auto_list[$i]=1
			fi
		done
	fi
}

function all_test_over()
{
	if [ "$init_first" = "0" ]
	then
		endtime=$(date +%s)
		runtime=$(($endtime-$starttime))
		echo "init_overtime: $runtime"
		if [ $runtime -gt 60 ]
		then
			init_overtime=1
		fi
	else
		manual_outcome_overtime
	fi

	test_over_cnt=0
	for ((i=0;i<test_enable_num;i++))
	do
		if [[ ${test_enable_parallel_list[i]} = "1" ]] && [[ ${test_over_list[i]} = "1" ]]
		then
			let test_over_cnt++
		fi
	done

	#echo "test_over_cnt: $test_over_cnt"
	if [[ $test_over_cnt -eq $test_enable_num ]] || [[ "$init_overtime" = "1" ]]
	then
		echo "all test over"
		killall cat
		kill $heart_pid
		exit
	fi
}

function init_process()
{
	test_init
	test_list_init
	#pwmdac_process
	dsi_process
	test_process
}

set_date
uart3_init
uart3_open

old_info=$(recv_data)

#module_info

heart 0 &
heart_pid=$!
starttime=$(date +%s)

while true
do
	if [[ "$init_first" = "0" ]] && [[ "$get_module_info" = "1" ]]
	then
		init_process
		init_first=1
		starttime=$(date +%s)
	fi
	
	is_recv_data 5
	
	test_result_upload

	heart_burning

	all_test_over

	msleep 10
	
done
