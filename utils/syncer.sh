#!/bin/bash

source utils.sh

LINUX_SRC_ROOT="/usr/src/linux-4.15.1/"

src_files=(
"net/ipv4/tcp.c" \
"net/ipv4/tcp_output.c" \
"net/ipv4/tcp_output_random.c" \
"net/ipv4/tcp_output_interval.c" \
"net/ipv4/tcp_output_fragged.c" \
"net/ipv4/tcp_input.c" \
"net/ipv4/tcp_metrics.c" \
"net/ipv4/tcp_ipv4.c" \
"net/ipv4/sysctl_net_ipv4.c" \
"kernel/sysctl_binary.c" \
"include/uapi/linux/sysctl.h" \
"include/net/tcp.h" \
"include/net/netns/ipv4.h" \
"include/linux/tcp.h" \
"include/net/tcp_bufferbloat.h" \
)

gecho "Syncing src ..."
echo =================
sleep 2

for(( i=0; i < ${#src_files[@]}; i++ )); do
	cp --parents -v "${LINUX_SRC_ROOT}${src_files[$i]}" "../src/"
done

if [ $? -eq 0 ]; then 
	gecho "\n${#src_files[@]} files copied"
	exit
else
	recho "\nSomething went wrong!"
	exit
fi

gecho "\nPushing client scrips ..."
echo =================
sleep 2

# scp -r ../client/* tstclient@192.168.11.10:/home/tstclient/Bufferbloat/client/

gecho "\nPushing linux srcs ..."
echo =================
sleep 2

#scp -r ../src/* tstclient@192.168.11.10:/home/tstclient/Bufferbloat/src/

gecho "\nPushing utils ..."
echo =================
sleep 2
#scp -r * tstclient@192.168.11.10:/home/tstclient/Bufferbloat/utils/

