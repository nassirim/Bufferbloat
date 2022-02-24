#!/bin/bash

VALIDATION_FILE="plot/Validation${1}.tbl"
RTT_DATA="rawdata/validation.rtt"
THROUGHPUT_DATA="rawdata/validation.tput"
UTILIZATION_DATA="rawdata/validation.util"

>$VALIDATION_FILE

if [ "$1" == "UDP" ]; then
	column_name="UDPInject"
elif [ "$1" == "TCP" ]; then
	column_name="TCPSegmentation"
fi

echo -e "\n                         Validation Results" >> $VALIDATION_FILE
echo " ------------------------------------------------------------------------" >> $VALIDATION_FILE
printf "  %-18s \t %-19s \t\t %-19s \n" "Gauge" "Large Buffer" "$column_name" >> $VALIDATION_FILE
echo " ------------------------------------------------------------------------" >> $VALIDATION_FILE

tcp_rtt=$( cat $RTT_DATA | grep "LargeBuffer" | awk '{print $2}' )
tcpudp_rtt=$( cat $RTT_DATA | grep "$column_name" | awk '{print $2}' )

tcp_throughput=$( cat $THROUGHPUT_DATA | grep "LargeBuffer" | awk '{print $2}' )
tcpudp_throughput=$( cat $THROUGHPUT_DATA | grep "$column_name" | awk '{print $2}' )

tcp_utilization=$( cat $UTILIZATION_DATA | grep "LargeBuffer" | awk '{print $2}' )
tcpudp_utilization=$( cat $UTILIZATION_DATA | grep "$column_name" | awk '{print $2}' )

printf "  %-18s \t %-19s \t\t %-19s \n" \
       "TCP goodput" "$tcp_throughput Kbit/s" "$tcpudp_throughput Kbit/s" >> $VALIDATION_FILE
printf "  %-18s \t %-19s \t\t %-19s \n" \
       "Link utilization" "$tcp_utilization %" "$tcpudp_utilization %" >> $VALIDATION_FILE
printf "  %-18s \t %-19s \t\t %-19s \n" \
       "RTT" "$tcp_rtt ms" "$tcpudp_rtt ms" >> $VALIDATION_FILE
echo -e " ------------------------------------------------------------------------\n" >> $VALIDATION_FILE
