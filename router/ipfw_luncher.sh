#!/bin/sh

if [ $# -eq 0 ]; then
	CONFIG_FILE="config/validation.conf"
else
	CONFIG_FILE=$1
fi


#read configuration from file
#============================

get_config() {
	return_config=$( cat "$CONFIG_FILE" | grep "$1" | cut -d '=' -f 2 )
}

#initialize configuration
#============================

return_config=""
get_config "srvr_ip"
srvr_ip=$return_config
get_config "srvr_gate"
srvr_gate=$return_config
get_config "clnt_ip"
clnt_ip=$return_config
get_config "clnt_gate"
clnt_gate=$return_config
get_config "up_queue"
up_queue=$return_config
get_config "down_queue"
down_queue=$return_config
get_config "up_delay"
up_delay=$return_config
get_config "down_delay"
down_delay=$return_config
get_config "up_bw"
up_bw=$return_config
get_config "down_bw"
down_bw=$return_config

echo "Configuring interfaces"
echo "========================"
ifconfig em0 $clnt_gate netmask 255.255.255.0
ifconfig em1 $srvr_gate netmask 255.255.255.0
echo "em0 -> $clnt_gate"
echo "em1 -> $srvr_gate"

echo -e "\nEnabling forwarding"
echo "========================"
sysctl net.inet.ip.forwarding=1
sysctl net.inet.ip.dummynet.pipe_slot_limit=150
sleep 3

echo -e "\nSetting rules by $1"
echo "========================"
kldload dummynet
#ipfw -f flush

ipfw add 1000 allow tcp from any to any

ipfw add 1000 allow ip from any to any

ipfw add 1000 allow icmp from $clnt_ip to $srvr_ip
ipfw add 1000 allow icmp from $srvr_ip to $clnt_ip

ipfw add 1000 allow icmp from $clnt_ip to $clnt_gate
ipfw add 1000 allow icmp from $clnt_gate to $clnt_ip

#ipfw add 1000 allow ip from $clnt_ip to $srvr_ip
#ipfw add 1000 allow ip from $srvr_ip to $clnt_ip

#ipfw add 1000 allow tcp from $clnt_ip to $srvr_ip
#ipfw add 1000 allow tcp from $srvr_ip to $clnt_ip

#ipfw add 1000 allow tcp from $clnt_ip to $srvr_gate
#ipfw add 1000 allow tcp from $clnt_gate to $clnt_ip

#ipfw add 1000 allow tcp from $srvr_ip to $srvr_gate
#ipfw add 1000 allow tcp from $srvr_gate to $srvr_ip

#ipfw add 1000 allow tcp from $clnt_ip to $clnt_gate 22
#ipfw add 1000 allow tcp from $clnt_gate to $clnt_ip 22 

#ipfw add 1000 allow tcp from any to any

ipfw add 1000 allow udp from $clnt_ip to $srvr_ip
ipfw add 1000 allow udp from $srvr_ip to $clnt_ip

ipfw add 100 pipe 1 ip from $clnt_ip to $srvr_ip out
ipfw add 100 pipe 2 ip from $srvr_ip to $clnt_ip in

ipfw pipe 1 config bw $up_bw queue $up_queue delay $up_delay
ipfw pipe 2 config bw $down_bw queue $down_queue delay $down_delay

echo -e "\ndummynet config done."
