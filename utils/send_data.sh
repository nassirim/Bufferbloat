#!/bin/bash

IF_NAME="eth0"
PORT_NUM="1234"
IP_ADDRESS="192.168.11.10"

dmesg --clear

if [ $# -ne 1 ]; then
	echo "Usage : $0 file"
	exit
fi

echo "Diabling tso and gso"
echo "======================"
#ethtool -K $IF_NAME tso off gso off
echo 1 > /proc/sys/net/ipv4/tcp_low_latency

sleep 3

echo -e "\nStart sending data"
echo "======================"
echo -n "Data size : "
du -h $1
nc -w 3 -v $IP_ADDRESS $PORT_NUM < $1
echo -e "\ndone."
