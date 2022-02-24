#!/bin/bash

PACKET_COUNT=1
counter=0

if [ $# -ne 4 ]; then
	echo "Usage : $0 <timeout> <interface> <destination ip> <output file>"
	echo "example : $0 30  eth0 192.168.11.10 validation.mss"

	exit 1
fi

> "${4}.tmp"
> "${4}.mss"

output=$(timeout $1 tcpdump -i $2 "tcp and (dst $3)")
output=$(echo -e "$output" | grep length | awk '{ print $21 }')

echo "$output" > "${4}.tmp"

while IFS= read -r itm_line
do
	if [[ "$itm_line" != "" && "$itm_line" != "0" && $itm_line == ?(-)+([0-9]) ]]; then
		echo "$counter		$itm_line" >> "${4}.mss"
		counter=$(($counter + 1))
	fi

	if [ $counter -eq 10000 ]; then
		break;
	fi
 
done < "${4}.tmp"

rm "${4}.tmp"

