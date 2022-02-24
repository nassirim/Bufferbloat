#!/bin/bash

# variable definations
CONFIG_FILE="config/validation.conf"
RESULT_PLOT="plot/"
MSS_RESULT_PLOT="plot/"
RTT_DATA="rawdata/validation.rtt"
THROUGHPUT_DATA="rawdata/validation.tput"
UTILIZATION_DATA="rawdata/validation.util"
MSS_DATA="rawdata/"
TCPDUMP_FILE="rawdata/validation.cap"


source ../utils/utils.sh

# read configuration from file
function get_config() {
	return_config=$( cat $CONFIG_FILE | grep "$1" | cut -d '=' -f 2 )
}

# generate udp traffic via ipmt
function start_traffic() {

	x_tics=$1

	typeset rtt_sum=0
	typeset throughput_sum=0
	typeset utilization_sum=0

	# generate tcp traffic via ipmt
	for(( counter=0; counter < $run_count; counter++ )); do

		echo "=======================| Run Number : $counter |======================="

		if [ "$1" == "UDPInjection" ]; then
                        udpmt -r "$udp_rate" -p "$udp_port" -d "$time" -s "$udp_packetsize" "$server_ip" &
                fi

		timeout $time tcpdump -i $if_name -w $TCPDUMP_FILE & 
		sleep 1
		echo "Rate : $tcp_rate  Time:$time  Port:$tcp_port  Packetsize:$tcp_packetsize   IP:$server_ip"
		tcpmt_out=$( tcpmt -p "$tcp_port" -d $time -r "$tcp_rate" -s $tcp_packetsize "$server_ip" )
		sleep 2

		trace_out=$( tcptrace -l -r $TCPDUMP_FILE )
		rtt_current=$( echo "$trace_out" | grep "RTT avg" | head -n 1 | awk '{ print $3 }' )
		utilization_current=$( echo "$trace_out" | grep "actual data bytes" | awk '{ tmp_sum += $4 } END { print tmp_sum }' )
		
		tcpmt_out=$( echo "$tcpmt_out" | grep "Avg throughput" | awk '{ print $4 }' )
		
		rtt_sum=$( echo "$rtt_sum $rtt_current" | awk '{print($1 + $2)}' )
		throughput_sum=$( echo "$throughput_sum $tcpmt_out" | awk '{print($1 + $2)}' )
		utilization_sum=$( echo "$utilization_sum $utilization_current" | awk '{print($1 + $2)}' )

		rm -v $TCPDUMP_FILE
	done;

	# calculate average
	rtt_avg=$( echo "$rtt_sum $run_count" | awk '{print($1 / $2)}' )
	throughput_avg=$( echo "$throughput_sum $run_count" | awk '{print($1 / $2)}' )
	utilization_avg=$( echo "$utilization_sum $run_count $time $link_capacity" | \
			   awk '{print((($1 * 8) / ($2 * $3 * $4)) * 100)}' )	

	echo "$x_tics       $rtt_avg" >> "$RTT_DATA"
	echo "$x_tics       $throughput_avg" >> "$THROUGHPUT_DATA"
	echo "$x_tics       $utilization_avg" >> "$UTILIZATION_DATA"
}

#==============================
#	script start point
#==============================

clear

if [ $# -ne 1 ]; then
        echo "Usage : $0 inject_udp -- run validation with udp injection method"
        echo -e "                             segment_tcp -- run validation with tcp segmentation method\n"

        exit 1
else
        method=$1

	if [[ $method != "inject_udp" && $method != "segment_tcp" ]]; then	
		recho "Invalid method : $0 $method"
		gecho "Available methods : inject_udp , segment_tcp"
		exit 1
	fi
fi

# initialize configurations
return_config=""
get_config "server_ip"
server_ip=$return_config
get_config "tcp_port"
tcp_port=$return_config
get_config "udp_port"
udp_port=$return_config
get_config "validation_link_capacity"
link_capacity=$return_config
get_config "router_ip"
router_ip=$return_config
get_config "router_home"
router_home=$return_config
get_config "udp_rate"
udp_rate=$return_config
get_config "tcp_rate"
tcp_rate=$return_config
get_config "time"
time=$return_config
get_config "run_count"
run_count=$return_config
get_config "paralell"
paralell=$return_config
get_config "tcp_packetsize"
tcp_packetsize=$return_config
get_config "udp_packetsize"
udp_packetsize=$return_config
get_config "cc_algorithm"
cc_algo=$return_config
get_config "interface_name"
if_name=$return_config

read -p "Do you want to run script now? (y/n) : " user_ans
if [ $user_ans == 'y' ]; then

	# clean old data
	gecho "\nClear data ..."
	echo "=================="
	rm -v $RTT_DATA;
	rm -v $THROUGHPUT_DATA;
	rm -v $UTILIZATION_DATA;
	rm -v $TCPDUMP_FILE;
	rm -v $MSS_DATA/*.mss

	# running ipfw with ssh on router
        gecho "\nSetting dummynet parameters..."
        echo "================="
	ssh root@$router_ip "$router_home/ipfw_luncher.sh \
                             $router_home/config/validation.conf"

	# setting congestion control algorithm 
	gecho "\nChanging TCP type..."
	echo "================="
	echo $cc_algo > /proc/sys/net/ipv4/tcp_congestion_control
	echo "TCP congestion control algorithm changed : $cc_algo"

	# call start traffic function
        gecho "\nRunning large buffer..."
        echo "================="
	turnoff_tso_gso $if_name

	ssh root@$router_ip "$router_home/queue_logger.sh" "validation_large_${method}" $(($time * $run_count + 3)) &
	timeout $(($time * $run_count + 3)) ./mss_logger.sh 2 $if_name $server_ip "${MSS_DATA}validation_large_${method}.mss" &

	start_traffic "LargeBuffer"
	
	sleep 10
	ssh root@$router_ip "$router_home/queue_logger.sh" "validation_${method}" $(($time * $run_count)) &
	timeout $(($time * $run_count + 3)) ./mss_logger.sh 2 $if_name $server_ip "${MSS_DATA}validation_${method}.mss" &

	if [ $method == "inject_udp" ]; then
       		gecho "\nRunning with udp injection..."
        	echo "================="
		RESULT_PLOT="${RESULT_PLOT}ValidationUDP.png"
		MSS_RESULT_PLOT="${MSS_RESULT_PLOT}MSSValidationUDP.png"
		start_traffic "UDPInjection"
	elif [ $method == "segment_tcp" ]; then
        	gecho "\nRunning tcp segmentation..."
        	echo "================="
		RESULT_PLOT="${RESULT_PLOT}ValidationTCP.png"
		MSS_RESULT_PLOT="${MSS_RESULT_PLOT}MSSValidationTCP.png"
		echo 1 > /proc/sys/net/ipv4/tcp_flg_bufferbloat
		start_traffic "TCPSegmentation"
	fi

	turnon_tso_gso $if_name
	echo 0 > /proc/sys/net/ipv4/tcp_flg_bufferbloat
fi

gecho "\nDraw plots ..."
echo "================="
rm -v $RESULT_PLOT

gnuplot -e "set terminal png size 800,1000;
	set output \"$RESULT_PLOT\";
	set multiplot layout 3,1 title \"Results\" font \"arial,18\";
	unset key;
	set xtics nomirror rotate by -45 font \"arial,15\";

	set bmargin 4;
	set tmargin 4;
	set lmargin 14;
	
	set style line 1 lc rgb \"red\";
	set style line 2 lc rgb \"blue\";
        set style line 3 lc rgb \"green\";

	set title \"RTT\" font \"arial,15\";
	set boxwidth 0.5;
	set style fill solid;
	set yrange [0: ];
	set ylabel \"RTT (ms)\" font \"arial,14\";
	plot \"$RTT_DATA\" using 2:xtic(1) with boxes ls 1;

	set title \"Throughput\" font \"arial,15\";
	set boxwidth 0.5;
	set style fill solid;
	set yrange [0: ];
	set ylabel \"Throughput (Kbits)\" font \"arial,14\";
	plot \"$THROUGHPUT_DATA\" using 2:xtic(1) with boxes ls 2;

        set title \"Utilization\" font \"arial,15\";
	set boxwidth 0.5;
	set style fill solid;
	set yrange [0: ];
	set ylabel \"Utilization (%)\" font \"arial,14\";
	plot \"$UTILIZATION_DATA\" using 2:xtic(1) with boxes ls 3;

	unset multiplot;
	exit"

	gnuplot -e "set terminal png size 1500,800;
                set output \"$MSS_RESULT_PLOT\";
                set title \"MSS Statistic\" font \"arial,15\";
                set xlabel \"Time (second)\";
                set grid;
                set ylabel \"Byte\" font \"arial,14\";
                plot \"${MSS_DATA}validation_large_${method}.mss\" title \"Large Buffer\" with linespoints,
                      \"${MSS_DATA}validation_${method}.mss\" title \"UDP Inject/TCP Segment\" with linespoints;
                exit"

gecho "\nCreated -> plot/${RESULT_PLOT}"
gecho "\nCreated -> plot/${MSS_RESULT_PLOT}"

gecho "\nOpen plots ..."
echo "================="
gvfs-open "$RESULT_PLOT"

gecho "\nExprement Data ..."
echo "================="
if [ $method == "inject_udp" ];then
	./tbl_luncher.sh "UDP"
elif [ $method == "segment_tcp" ];then
	./tbl_luncher.sh "TCP"
fi
