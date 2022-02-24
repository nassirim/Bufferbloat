#!/bin/bash

clear

tcpdump -i eth0 'tcp and (src 192.168.11.10)' | grep length | awk '{ $1=$2=$3=$4=$5=$6=$7=$8=$9=$10=$11="";print}'

