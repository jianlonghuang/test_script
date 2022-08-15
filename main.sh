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
	time=`date +%Y-%m-%d" "%H:%M:%S`
	#echo $time
	frame={@$fun_3_heart,$time}
	send_data $frame
}


function test_init()
{
	vesion_date="2022-08-12"
	version_mds="7aa73a5c05a44a053baa7508f4bcdfc0"
	version > version.log

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

function killmodetest()
{
	result=`ps | grep "modetest" | grep -v "grep"`
	if [ "$result" != "" ]
	then
		killall modetest
	fi
}

function send_frame()
{
	data=$1
	
	result1=$(echo $data | grep "${str_head}")
	result2=`expr index "$data" $str_tail`
	item_index=`expr index "$data" $str_test_num_flag`
	let comma_last_index=`echo "$data" | awk -F '','' '{printf "%d", length($0)-length($NF)}'`
	#echo "result1: $result1"
	#echo "result2: $result2"
	#echo "item_index: $item_index"
	#echo "comma_last_index: $comma_last_index"
	if [[ "$result1" != "" ]] && [[ $result2 -gt $comma_last_index ]] && [[ $comma_last_index -gt $item_index ]]
	then
		len=`expr $comma_last_index - $item_index - 1`
		test_num=${data:$item_index:$len}
		#echo "test_num: $test_num"

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

function dsi_process()
{
	sh killmodetest.sh &
	sh dsi_init.sh
	dsi_test_num=$(get_test_item_num "DSI")
	echo "dsi_test_num: $dsi_test_num"
	if [[ $dsi_test_num -lt $test_enable_num ]] && [[  ${test_enable_parallel_list[$dsi_test_num]} = "0" ]]
	then
		test_enable_parallel_list[$dsi_test_num]=1
		echo "sh ${test_enable_fun_list[$dsi_test_num]}"
		sh ${test_enable_fun_list[$dsi_test_num]} &
	fi
}

function all_test_over()
{
	test_over_cnt=0
	for ((i=0;i<test_enable_num;i++))
	do
		if [[ ${test_enable_parallel_list[i]} = "1" ]] && [[ ${test_over_list[i]} = "1" ]]
		then
			let test_over_cnt++
		fi
	done

	#echo "test_over_cnt: $test_over_cnt"
	if [[ $test_over_cnt -eq $test_enable_num ]]
	then
		let waite_count++
		if [ $waite_count -gt 200 ]
		then
			waite_count=0
			echo "all test over"
			killall cat
			exit
		fi
		
	fi
}


set_date
uart3_init
uart3_open

test_init
test_list_init

dsi_process
test_process

old_info=$(recv_data)


while true
do
	
	is_recv_data 5
	
	test_result_upload

	let ms_count++
	if [ $ms_count -gt 50 ]
	then
		ms_count=0
		heart
	fi

	msleep 10

	all_test_over
	
done
