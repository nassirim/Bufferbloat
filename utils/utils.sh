#!/bin/bash

GREEN_CODE='\033[1;32m'
RED_CODE='\033[1;31m'
RESET_CODE='\e[0m'

function gecho() 
{
	echo -e "${GREEN_CODE}${1}${RESET_CODE}"	
}

function recho()
{
	echo -e "${RED_CODE}${1}${RESET_CODE}"	
}

function turnoff_tso_gso() 
{
	gecho "\nDiabling tcp offerload on $1"
	echo "======================"
	ethtool -K "$1" tso off gso off
	echo 1 > /proc/sys/net/ipv4/tcp_low_latency
}

function turnon_tso_gso()
{
        gecho "\nEnabling tcp offerload on $1"
        echo "======================"
        ethtool -K "$1" tso on gso on
        echo 0 > /proc/sys/net/ipv4/tcp_low_latency
}

