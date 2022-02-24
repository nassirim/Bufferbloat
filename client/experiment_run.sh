#!/bin/bash

source ../utils/utils.sh

# variable definations
CONFIG_FILE="config/experiment.conf"
RESULT_PLOT=""

UP_RTT_FILE="rawdata/up.rtt"
UP_THROUGHPUT_FILE="rawdata/up.tput"
UP_UTILIZATION_FILE="rawdata/up.util"

RTT_LARGE="rawdata/large_buffer.rtt"
RTT_WUDP=""
RTT_SMALL="rawdata/small_buffer.rtt"

UTILIZATION_LARGE="rawdata/large_buffer.util"
UTILIZATION_WUDP=""
UTILIZATION_SMALL="rawdata/small_buffer.util"

THROUGHPUT_LARGE="rawdata/large_buffer.tput"
THROUGHPUT_WUDP=""
THROUGHPUT_SMALL="rawdata/small_buffer.tput"

DOWN_RTT_FILE="rawdata/down.rtt"
DOWN_THROUGHPUT_FILE="rawdata/down.tput"
DOWN_UTILIZATION_FILE="rawdata/down.util"

PLOT_TITLE=""

MSS_DATA="rawdata/"
MSS_RESULT_PLOT="plot/"

CAP_FILE="rawdata/up.cap"

# read configuration from file
function get_config() {
	return_config=$( cat $CONFIG_FILE | grep "$1" | cut -d '=' -f 2 )
}

# generate traffic function via ipmt
function start_traffic() {

	typeset x_tics=$1

	typeset rtt_sum=0
	typeset throughput_sum=0
	typeset utilization_sum=0
	typeset udp_traffic=0

	for(( counter=0; counter < $run_count; counter++ )); do

		echo "=================| Run Number : $counter |================="
		if [ "$x_tics" == "UDPInjection" ]; then
			echo "UDP : $udp_rate"
                        udpmt -r $udp_rate -p $udp_port -d $time -s $udp_packetsize $server_ip &
			udp_traffic=0 # $( echo $udp_rate 1000 | awk '{ print( $1 * $2 ) }' )
                fi

		timeout $time tcpdump -i $if_name -w $CAP_FILE & 
		sleep 1

		tcpmt_out=$( tcpmt -t -d $time -s $tcp_packetsize -p $tcp_port $server_ip )
		trace_out=$( tcptrace -l -r $CAP_FILE )
		rtt_current=$( echo "$trace_out" | grep "RTT avg" | head -n 1 | awk '{ print $3 }' )
		utilization_current=$( echo "$trace_out" | grep "actual data bytes" | \
				       awk '{ tmp_sum += $4 } END { print tmp_sum }' )

		throughput_current=$( echo "$tcpmt_out" | grep "Avg throughput" | awk '{ print $4 }' )

		echo "RTT = $rtt_current  Utilization = $utilization_current  Throughput = $throughput_current"
		
		rtt_sum=$( echo "$rtt_sum $rtt_current" | awk '{print($1 + $2)}' )
		
		throughput_sum=$( echo "$throughput_sum $throughput_current" | awk '{print($1 + $2)}' )
		utilization_sum=$( echo "$utilization_sum $utilization_current" | awk '{print($1 + $2)}' )

		rm -v $CAP_FILE

		sleep 20
	done;

	# calculate average
	rtt_avg=$( echo "$rtt_sum $run_count" | awk '{print($1 / $2)}' )
	throughput_avg=$( echo "$throughput_sum $run_count" | awk '{print($1 / $2)}' )

	#                (utilization_sum * 8) + udp_traffic
	# Utilization = -------------------------------------- * 100
	#                  run_count * time * link_capacity

	utilization_avg=$( echo "$utilization_sum $udp_traffic $run_count $time $link_capacity" | \
			   awk '{print (((($1 * 8) + $2) / ($3 * $4 * $5)) * 100)}' )

echo "$x_tics       $rtt_avg" >> "$UP_RTT_FILE"
	echo "$x_tics       $throughput_avg" >> "$UP_THROUGHPUT_FILE"
	echo "$x_tics       $utilization_avg" >> "$UP_UTILIZATION_FILE"
}

# function for mix upload and download data
function mix_data() {
	large_up=$( cat $1 | grep "LargeBuffer" | awk '{ print $2 }' )
	if [ $method == "inject_udp" ]; then
		wudp_up=$( cat $1 | grep "UDPInjection" | awk '{ print $2 }' )
	elif [ $method == "segment_tcp" ]; then
		wudp_up=$( cat $1 | grep "TCPSegmentation" | awk '{ print $2 }' )
	fi
	small_up=$( cat $1 | grep "SmallBuffer" | awk '{ print $2 }' )

	large_down=$( cat $2 | grep "LargeBuffer" | awk '{ print $2 }' )
	wudp_down=$( cat $2 | grep "ProposalMethod" | awk '{ print $2 }' )
	small_down=$( cat $2 | grep "SmallBuffer" | awk '{ print $2 }' )

	echo "UP $large_up" > $3
	echo "DOWN $large_down" >> $3

	echo "UP $wudp_up" > $4
	echo "DOWN $wudp_down" >> $4

	echo "UP $small_up" > $5
	echo "DOWN $small_down" >> $5	
}

# function for find maximux value for y vector range
function find_max() {
	max_up=$( cat $1 | awk '$2 > max { max = $2 } END { print max }' )
	max_down=$( cat $2 | awk '$2 > max { max = $2 } END { print max }' )

	max_value=$( echo $max_up $max_down | awk '{ if ($1 >= $2) print $1; else print $2 }' )
}


#==============================
#	script start point
#==============================

clear

if [ $# -ne 2 ]; then
        echo "Usaged : $0 erun1 [inject_udp | segment_tcp] -- for first experiment run"
	echo -e "                             erun2 [inject_udp | segment_tcp] -- for second experiment run\n"

	exit 1
else
	if [[ $2 != "inject_udp" && $2 != "segment_tcp" ]]; then
        	recho "Invalid method : $0 $1 $2"
	        gecho "Available methods : inject_udp , segment_tcp"
        	exit 1
        fi

	method=$2
	experiment=$1	

	RTT_WUDP="rawdata/${method}.rtt"
	UTILIZATION_WUDP="rawdata/${method}.util"
	THROUGHPUT_WUDP="rawdata/${method}.tput"
fi

# initialize configurations
return_config=""
get_config "server_ip"
server_ip=$return_config
get_config "router_ip"
router_ip=$return_config
get_config "router_home"
router_home=$return_config
get_config "tcp_port"
tcp_port=$return_config
get_config "udp_port"
udp_port=$return_config
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
get_config "${1}_link_capacity"
link_capacity=$return_config

read -p "Do you want to run script now? (y/n) : " user_ans
if [ $user_ans == 'y' ]; then

	# clean old data
	echo -e "\n${GREEN_CODE}Clear data ...${RESET_CODE}"
	echo "================="
	rm -v $CAP_FILE
	rm -v $UP_RTT_FILE
	rm -v $UP_THROUGHPUT_FILE
	rm -v $UP_UTILIZATION_FILE

	rm -v $RTT_LARGE
	rm -v $RTT_WUDP
	rm -v $RTT_SMALL

	rm -v $UTILIZATION_LARGE
	rm -v $UTILIZATION_WUDP
	rm -v $UTILIZATION_SMALL

	rm -v $THROUGHPUT_LARGE
	rm -v $THROUGHPUT_WUDP
	rm -v $THROUGHPUT_SMALL

	rm -v $DOWN_RTT_FILE
	rm -v $DOWN_THROUGHPUT_FILE
	rm -v $DOWN_UTILIZATION_FILE

	rm -v "$MSS_DATA*.mss"

	turnoff_tso_gso $if_name

	# setting congestion control algorithm 
	echo -e "\n${GREEN_CODE}Changing tcp type...${RESET_CODE}"
	echo "================="
	echo $cc_algo > /proc/sys/net/ipv4/tcp_congestion_control
	echo "TCP congestion control algorithm changed : $cc_algo"

	# call start traffic function
	echo -e "\n${GREEN_CODE}Running large buffer...${RESET_CODE}"
	echo "================="

	ssh root@$router_ip "$router_home/ipfw_luncher.sh \
                             $router_home/config/large_${experiment}.conf"

	ssh root@$router_ip "$router_home/queue_logger.sh" "${experiment}_large" $(($time * $run_count + 106)) &\
	#./mss_logger.sh $(($time * $run_count)) $if_name $server_ip "${MSS_DATA}experiment_large_${method}" &

	start_traffic "LargeBuffer"
	sleep 5

	if [ $method == "inject_udp" ]; then
                gecho "\nRunning with udp injection..."
                echo "================="
		RESULT_PLOT="plot/ExprementUDP_${experiment}.png"
		MSS_RESULT_PLOT="${MSS_RESULT_PLOT}MSSExperimentUDP_${experiment}.png"
		PLOT_TITLE="UDPInjection"
        elif [ $method == "segment_tcp" ]; then
                gecho "\nRunning tcp segmentation..."
                echo "================="
                RESULT_PLOT="plot/ExprementTCP_${experiment}.png"
		MSS_RESULT_PLOT="${MSS_RESULT_PLOT}MSSExperimentTCP_${experiment}.png"
                # turnoff_tso_gso $if_name
                echo 1 > /proc/sys/net/ipv4/tcp_flg_bufferbloat
		PLOT_TITLE="TCPSegmentation"
        fi

	ssh root@$router_ip "$router_home/queue_logger.sh" "${experiment}_${method}" $((time * $run_count + 106)) &
	#./mss_logger.sh $(($time * $run_count)) $if_name $server_ip "${MSS_DATA}experiment_${method}" &
	start_traffic $PLOT_TITLE

	# turnon_tso_gso $if_name
        echo 0 > /proc/sys/net/ipv4/tcp_flg_bufferbloat

	sleep 5

	echo -e "\n${GREEN_CODE}Running small buffer...${RESET_CODE}"
        echo "================="
	ssh root@$router_ip "$router_home/ipfw_luncher.sh \
			     $router_home/config/small_${experiment}.conf"

	ssh root@$router_ip "$router_home/queue_logger.sh" "${experiment}_small" $((time * $run_count + 106)) &
	#./mss_logger.sh $(($time * $run_count)) $if_name $server_ip "${MSS_DATA}experiment_small_${method}" &
	start_traffic "SmallBuffer"

	sleep 20 # wait for server data (dwon traffic)
fi

echo -e "\n${GREEN_CODE}Mixing data...${RESET_CODE}"
echo "================="
mix_data $UP_RTT_FILE $DOWN_RTT_FILE $RTT_LARGE $RTT_WUDP $RTT_SMALL
mix_data $UP_UTILIZATION_FILE $DOWN_UTILIZATION_FILE $UTILIZATION_LARGE $UTILIZATION_WUDP $UTILIZATION_SMALL
mix_data $UP_THROUGHPUT_FILE $DOWN_THROUGHPUT_FILE $THROUGHPUT_LARGE $THROUGHPUT_WUDP $THROUGHPUT_SMALL

echo -e "\n${GREEN_CODE}Draw plots ...${RESET_CODE}"
echo "================="
find_max $UP_RTT_FILE $DOWN_RTT_FILE
rtt_range=$max_value
find_max $UP_UTILIZATION_FILE $DOWN_UTILIZATION_FILE
utilization_range=$max_value
find_max $UP_THROUGHPUT_FILE $DOWN_THROUGHPUT_FILE 
throughput_range=$max_value

gnuplot -e "set terminal png size 900, 900;
	set output \"$RESULT_PLOT\";
	set multiplot layout 3,3 title \"Results\" font \"arial,18\";
	unset key;
	set xtics nomirror rotate by -90 font \"arial,12\";

	set bmargin 4;
	set tmargin 4;
	set lmargin 14;
	
	set style line 1 lc rgb \"red\";
	set style line 2 lc rgb \"blue\";
        set style line 3 lc rgb \"green\";

	set title \"Large Buffer\" font \"arial,15\";
	set boxwidth 0.4;
	set style fill solid;
	set yrange [0: $rtt_range];
	set ylabel \"RTT (ms)\" font \"arial,14\";
	plot \"$RTT_LARGE\" using 2:xtic(1) with boxes ls 1;

	set title \"$PLOT_TITLE\" font \"arial,15\";
	set boxwidth 0.4;
	set style fill solid;
	set yrange [0: $rtt_range];
	set ylabel \"RTT (ms)\" font \"arial,14\";
	plot \"$RTT_WUDP\" using 2:xtic(1) with boxes ls 1;

	set title \"Small Buffer\" font \"arial,15\";
	set boxwidth 0.4;
	set style fill solid;
	set yrange [0: $rtt_range];
	set ylabel \"RTT (ms)\" font \"arial,14\";
	plot \"$RTT_SMALL\" using 2:xtic(1) with boxes ls 1;

	set title \"Large Buffer\" font \"arial,15\";
	set boxwidth 0.4;
	set style fill solid;
	set yrange [0: $utilization_range];
	set ylabel \"Utilization (%)\" font \"arial,14\";
	plot \"$UTILIZATION_LARGE\" using 2:xtic(1) with boxes ls 2;

	set title \"$PLOT_TITLE\" font \"arial,15\";
	set boxwidth 0.4;
	set style fill solid;
	set yrange [0: $utilization_range];
	set ylabel \"Utilization (%)\" font \"arial,14\";
	plot \"$UTILIZATION_WUDP\" using 2:xtic(1) with boxes ls 2;

	set title \"Small Buffer\" font \"arial,15\";
	set boxwidth 0.4;
	set style fill solid;
	set yrange [0: $utilization_range];
	set ylabel \"Utilization (%)\" font \"arial,14\";
	plot \"$UTILIZATION_SMALL\" using 2:xtic(1) with boxes ls 2;

        set title \"Large Buffer\" font \"arial,15\";
	set boxwidth 0.4;
	set style fill solid;
	set yrange [0: $throughput_range];
	set ylabel \"Throughput (Kbps)\" font \"arial,14\";
	plot \"$THROUGHPUT_LARGE\" using 2:xtic(1) with boxes ls 3;

        set title \"$PLOT_TITLE\" font \"arial,15\";
	set boxwidth 0.4;
	set style fill solid;
	set yrange [0: $throughput_range];
	set ylabel \"Throughput (Kbps)\" font \"arial,14\";
	plot \"$THROUGHPUT_WUDP\" using 2:xtic(1) with boxes ls 3;

	set title \"Small Buffer\" font \"arial,15\";
	set boxwidth 0.4;
	set style fill solid;
	set yrange [0: $throughput_range];
	set ylabel \"Throughput (Kbps)\" font \"arial,14\";
	plot \"$THROUGHPUT_SMALL\" using 2:xtic(1) with boxes ls 3;

	unset multiplot;
	exit"

	gnuplot -e "set terminal png size 1500,800;
                set output \"$MSS_RESULT_PLOT\";
                set title \"MSS Statistic\" font \"arial,15\";
                set xlabel \"Time (second)\";
                set grid;
                set ylabel \"Byte\" font \"arial,14\";
                plot \"${MSS_DATA}experiment_large_${method}.mss\" title \"Large Buffer\" with lines,
		     \"${MSS_DATA}experiment_${method}.mss\" title \"$PLOT_TITLE\" with lines,
                     \"${MSS_DATA}experiment_small_${method}.mss\" title \"Small Buffer\" with lines;
                exit"

echo -e "${GREEN_CODE}Created -> ${RESULT_PLOT} ${RESET_CODE}"

echo -e "\n${GREEN_CODE}Open plots ...${RESET_CODE}"
echo "================="
gvfs-open "$RESULT_PLOT"
