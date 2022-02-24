#!/bin/bash

CONFIG_FILE="/home/tstserver/Bufferbloat/config/dnld_traffic.conf"
fle_result="plot/DnldTime_"
fle_time="rawdata/download.tim"
fle_size="rawdata/download.siz"
cubic_cubic="rawdata/cubic-cubic.txt"
cubic_reno="rawdata/cubic-reno.txt"
cubic_vegas="rawdata/cubic-vegas.txt"
reno_cubic="rawdata/reno-cubic.txt"
reno_reno="rawdata/reno-reno.txt"
reno_vegas="rawdata/reno-vegas.txt"
vegas_cubic="rawdata/vegas-cubic.txt"
vegas_reno="rawdata/vegas-reno.txt"
vegas_vegas="rawdata/vegas-vegas.txt"
fle_algo="log/cc_algorithms.log"
fle_download="log/download.log"

GREEN_CODE='\033[1;32m'
RESET_CODE='\e[0m'

cc_files=($cubic_cubic $cubic_reno $cubic_vegas $reno_cubic $reno_reno $reno_vegas $vegas_cubic $vegas_reno $vegas_vegas)
cc_algorithms_down=(cubic cubic cubic reno reno reno vegas vegas vegas)
cc_algorithms_up=(cubic reno vegas cubic reno vegas cubic reno vegas)

# read configuration from file
function get_config() {
        return_config=$( cat $CONFIG_FILE | grep "$1" | cut -d '=' -f 2 )
}

function ctrl_catcher() {
	echo -e  "\n\nCtrl + C signal catched!"

	ssh root@$clnt_ip killall tcptarget
	killall tcptarget
	killall 'ssh'
	ssh root@$clnt_ip killall tcpmt
	killall tcpmt
	
	exit
}

function start_dnld() {

	connection_size=$(( ${dnld_size[$ptr_size]} + $min_size ))
	echo -e "Download count : ${dnld_arrival[$ptr_size]}" >> $fle_download

	for(( poisson=0; poisson < ${dnld_arrival[$ptr_size]}; poisson++ )); do
		/usr/bin/time -f "%e" -a -o $fle_time tcpmt -p $port -n $connection_size $clnt_ip &
		echo "$connection_size" >> $fle_size
		echo "       Size : $connection_size  Port : $port" >> $fle_download
		echo -e "${GREEN_CODE}A connection started --> [ size : $connection_size  port : $port ]${RESET_CODE}"
		port=$(( port + 1 ))
	done

	ptr_size=$(( ptr_size + 1 ))
}

function arrange_data() {

	> $1

	readarray arr_times < $fle_time
	readarray arr_sizes < $fle_size

	for(( pointer=0; pointer < ${#arr_sizes[@]}; pointer++ )); do

		point_size=${arr_sizes[$pointer]}
		point_time=${arr_times[$pointer]}

		if [ $point_size -ne -1 ]; then
			counter=1
			for(( iterator=$(( pointer + 1 )); iterator < ${#arr_sizes[@]}; iterator++ )); do
				if [ $point_size -eq ${arr_sizes[$iterator]} ]; then
					point_time=$( echo $point_time ${arr_times[$iterator]} | awk '{printf $1 + $2}' )
					arr_sizes[$iterator]=-1
					counter=$(( $counter + 1 ))
				fi
			done

			point_time=$( echo $point_time $counter | awk '{print $1 / $2}' )
			point_size=$( echo $point_size | tr -d '\n' )
			point_time=$( echo $point_time | tr -d '\n' )

        		echo "$point_size      $point_time" >> $1
		fi
	done

	sort $1 --output=$1
}

function ploter() {
	echo -e "\n${GREEN_CODE}Draw plots ...${RESET_CODE}"
	echo "================="

	for fle_name in $(ls rawdata/*.txt); do
		plt_title=$( echo $fle_name | cut -d '.' -f 1 )
		plt_dnld="\"$fle_name\" using 1:2 title '$plt_title' with lines,$plt_dnld";
	done

	gnuplot -e "set terminal png size 900,400;
		set output \"$fle_result${1}.png\";
		set title \"Download Response Time\";
		set key outside;
		set xlabel \"Size (Byte)\";
		set ylabel \"Time To Complete\";
		plot $plt_dnld;
		exit"

	echo -e "\n${GREEN_CODE}Created -> $fle_result${1}.png ${RESET_CODE}"
	echo -e "\nOpen plots ..."
	echo "================="
	gnome-open "$fle_result${1}.png"
}

function start_experiment()
{
	for(( n=0 ; n < ${#cc_files[@]} ; n++ )); do
		> ${cc_files[$n]}
	done

	> $fle_download
	> $fle_algo

	for(( i=0; i < ${#cc_algorithms_down[@]}; i++ )); do

		echo "$i  Download(${cc_algorithms_down[i]}) -- Uplaod(${cc_algorithms_up[i]})" >> $fle_algo

		# setting congestion control algorithm 
		echo ${cc_algorithms_down[$i]} > /proc/sys/net/ipv4/tcp_congestion_control
	
		tcptarget -p $upload_port &

		if [ $1 == "WithUDP" ]; then
			udptarget -p $udp_port &
		fi

		ssh root@$clnt_ip /home/tstclient/Bufferbloat/dnld_clnt.sh $1 ${cc_algorithms_up[$i]} &	

		sleep 15

		echo -e "\n${GREEN_CODE}Downloads start ...${RESET_CODE}"
		echo "================="

		> $fle_time
		> $fle_size

		ptr_size=0

		for(( k=0; k < $total_time; k++ )); do
			start_dnld
			sleep 1
		done
	
		arrange_data ${cc_files[$i]}

		ssh root@$clnt_ip killall tcptarget

		sleep 7
	done

	killall tcptarget
	killall tcpmt

	if [ "$1"=="WithUDP" ]; then
		killall udptarget 
	fi

	ploter $1
}

#==============================
#       script start point
#==============================

clear

# initialize configurations
return_config=""
get_config "upload_port"
upload_port=$return_config
get_config "udp_port"
udp_port=$return_config
get_config "start_port"
start_port=$return_config
get_config "minimum_size"
min_size=$return_config
get_config "total_time"
total_time=$return_config
get_config "client_ip"
clnt_ip=$return_config

port=$start_port
ptr_size=0

readarray dnld_arrival < distributions/poisson-values
readarray dnld_size < distributions/zipf-values

trap "ctrl_catcher" 2

if [ $# -eq 0 ]; then
        type_of_run="WithoutUDP"
else
        type_of_run=$1
fi

start_experiment $type_of_run

