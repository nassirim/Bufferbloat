#!/bin/bash

CONFIG_FILE="config/$( echo $1 | cut -d '_' -f1 ).conf"
echo $CONFIG_FILE
CAP_FILE="rawdata/down.cap"
RTT_DATA_FILE="rawdata/down.rtt"
THROUGHPUT_DATA_FILE="rawdata/down.tput"
UTILIZATION_DATA_FILE="rawdata/down.util"

GREEN_CODE='\033[1;32m'
RESET_CODE='\e[0m'

# read configuration from file
function get_config() {
        return_config=$( cat $CONFIG_FILE | grep "$1" | cut -d '=' -f 2 )
}

# listen for traffic and generate traffic with ipmt
function start_traffic() {

	typeset rtt_sum=0
	typeset throughput_sum=0
	typeset utilization_sum=0

	x_tics=$1

	for(( counter=0; counter < $run_count; counter++ )); do
		echo "======================| Run Number : $counter |======================"
    		tcpdump -i $if_name -w $CAP_FILE &
    		tcpmt_out=$( tcpmt -p $tcp_port -t -P )
    		killall -v tcpdump

    		trace_out=$( tcptrace -l -r $CAP_FILE )
		rtt_current=$( echo "$trace_out" | grep "RTT avg" | head -n 1 | awk '{ print $7 }' )
		throughput_current=$(echo "$tcpmt_out" | tail -n +5 | \
				     awk '{ tmp_tput += $6 } END { print tmp_tput/NR }' )

    		utilization_current=$( echo "$trace_out" | grep "actual data bytes" | \
				       awk '{ tmp_util += $8 } END { print tmp_util }' )

		rtt_sum=$( echo "$rtt_sum $rtt_current" | awk '{print($1 + $2)}' )
		throughput_sum=$( echo "$throughput_sum $throughput_current" | awk '{print($1 + $2)}' )
		utilization_sum=$( echo "$utilization_sum $utilization_current" | awk '{print($1 + $2)}' )

		#rm -v $CAP_FILE

    		#echo "=============== RTT:$rtt_current  sum:$rtt_sum ==============="    
	    	#echo "=============== TPUT:$throughput_current  sum:$throughput_sum ==============="    
    		#echo "=============== UTIL:$utilization_current  sum:$utilization_sum ==============="  
	done

	# calculate average
	rtt_avg=$( echo "$rtt_sum $run_count" | awk '{print($1 / $2)}' )
	throughput_avg=$( echo "$throughput_sum $run_count" | awk '{print($1 / $2)}' )

	#  			  ($utilization_sum * 8)
	# Utilization = ---------------------------------------- * 100
	# 		 ($run_count * $time * $link_capacity)

	utilization_avg=$( echo "$utilization_sum $run_count $time $link_capacity" | \
			   awk '{print ((($1 * 8) / ($2 * $3 * $4)) * 100)}' )

	echo "$x_tics       $rtt_avg" >> "$RTT_DATA_FILE"
	echo "$x_tics       $throughput_avg" >> "$THROUGHPUT_DATA_FILE"
	echo "$x_tics       $utilization_avg" >> "$UTILIZATION_DATA_FILE"
}

#==============================
#       script start point
#==============================

clear

if [ $# -eq 0 ]; then
        echo "Usage : ./ipmt_srvr.sh validation           -- for validation run"
        echo "                       experiment_run1      -- for experiment first run"
        echo -e "                       experiment_run2      -- for experiment second run\n"
	
	exit 1
else
        experiment=$1
        get_config "${1}_link_capacity"
        link_capacity=$return_config
fi

# initialize configurations
return_config=""
get_config "tcp_port"
tcp_port=$return_config
get_config "run_count"
run_count=$return_config
get_config "interface_name"
if_name=$return_config
get_config "cc_algorithm"
cc_algo=$return_config
get_config "time"
time=$return_config

echo -e "${GREEN_CODE}Cleaning data${RESET_CODE}"
echo "==================="
rm -v $CAP_FILE
rm -v $RTT_DATA_FILE
rm -v $THROUGHPUT_DATA_FILE
rm -v $UTILIZATION_DATA_FILE
echo

# setting tcp congestion control algorighm
echo -e "\n${GREEN_CODE}Changing tcp type...${RESET_CODE}"
echo "==================="
echo $cc_algo > /proc/sys/net/ipv4/tcp_congestion_control
echo -e "TCP congestion algorithm changed : $cc_algo"

if [ $experiment == "validation" ]; then
	
	echo -e "\n${GREEN_CODE}Running Validation...${RESET_CODE}"
        echo "======================"

	while true
	do
		tcptarget -p "$tcp_port"
	done
elif [[ $experiment == "experiment_run1" || $experiment == "experiment_run2" ]]; then

	echo -e "\n${GREEN_CODE}Running large buffer...${RESET_CODE}"
	echo "======================"
	start_traffic "LargeBuffer"

	echo -e "\n${GREEN_CODE}Running with Proposal...${RESET_CODE}"
	echo "======================"
	start_traffic "ProposalMethod"

	echo -e "\n${GREEN_CODE}Running small buffer...${RESET_CODE}"
	echo "======================"
	start_traffic "SmallBuffer"

	echo -e "\n${GREEN_CODE}Transfering data ...${RESET_CODE}"
	echo "======================"

	scp $RTT_DATA_FILE $THROUGHPUT_DATA_FILE $UTILIZATION_DATA_FILE \
	    root@192.168.10.10:/home/tstclient/Bufferbloat/client/rawdata
fi
