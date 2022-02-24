#!/bin/bash

GREEN_CODE='\033[1;32m'
RESET_CODE='\e[0m'

# variable definations
CONFIG_FILE="/home/tstclient/Bufferbloat/config/dnld_traffic.conf"

# read configuration from file
function get_config() {
	return_config=$( cat $CONFIG_FILE | grep "$1" | cut -d '=' -f 2 )
}

# initialize configurations
return_config=""
get_config "server_ip"
server_ip=$return_config
get_config "upload_port"
upload_port=$return_config
get_config "udp_port"
udp_port=$return_config
get_config "udp_rate"
udp_rate=$return_config
get_config "upload_time"
upload_time=$return_config
get_config "port_num"
port_num=$return_config
get_config "udp_packetsize"
udp_packetsize=$return_config
get_config "start_port"
start_port=$return_config

if [ $1 == "WithUDP" ]; then

	echo -e "${GREEN_CODE}TCP UDP Traffic start... ${RESET_CODE}"	
	echo -e "===================="
	udpmt -r $udp_rate -p $udp_port -d $upload_time -s $udp_packetsize $server_ip &
fi

# setting congestion control algorithm 
echo $2 > /proc/sys/net/ipv4/tcp_congestion_control
echo -e "${GREEN_CODE}TCP congestion control algorithm changed : $2 ${RESET_CODE}"

tcpmt -d $upload_time -p $upload_port "$server_ip" &

for(( port=$start_port; port < $(( $start_port + $port_num )); port++ )); do
	tcptarget -p $port &
done
