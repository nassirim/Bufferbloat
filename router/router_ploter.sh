#!/bin/bash

source ../utils/utils.sh

clear

if [ $# -ne 2 ]; then
	echo "Usage : $0 erun1 [ inject_udp | segment_tcp ] -- for the first experiment"
	echo "                           erun2 [ inject_udp | segment_tcp ] -- for the second experiment"
	echo "                           valdiation [ inject_udp | segment_tcp ] -- for validation experiments"

	exit 1
fi

# router_stat.sh erun1 inject_udp

RESULT_PLOT="plot/queue_${1}_${2}.png"
DROP_LARGE="rawdata/queue_${1}_large.drp"
DROP_METHOD="rawdata/queue_${1}_${2}.drp"
DROP_SMALL="rawdata/queue_${1}_small.drp"

gecho "\nDraw plots ..."
echo "================="

if [[ $1 == "erun1" || $1 == "erun2" ]]; then
	gnuplot -e "set terminal png size 1500,800;
		set output \"$RESULT_PLOT\";
		set title \"Drop Statistic\" font \"arial,15\";
		set xlabel \"Time (second)\";
		set grid;
		set ylabel \"Dorps\" font \"arial,14\";
		plot \"$DROP_LARGE\" title \"Large Buffer\" with linespoints,
	     		\"$DROP_METHOD\" title \"UDP Inject/TCP Segment\" with linespoints,
	     		\"$DROP_SMALL\" title \"Small Buffer\" with linespoints; 
		exit"
elif [ $1 == "validation" ]; then

	echo "Large : $DROP_LARGE"
	echo "Method : $DROP_METHOD"
	echo =========================

	gnuplot -e "set terminal png size 1500,800;
                set output \"$RESULT_PLOT\";
                set title \"Drop Statistic\" font \"arial,15\";
                set xlabel \"Time (second)\";
                set grid;
                set ylabel \"Dorps\" font \"arial,14\";
                plot \"$DROP_LARGE\" title \"Large Buffer\" with linespoints,
                      \"$DROP_METHOD\" title \"UDP Inject/TCP Segment\" with linespoints;
                exit"
fi

gecho "Created -> plot/${RESULT_PLOT}"

gecho -e "\nOpen plots ..."
echo "================="
gvfs-open "$RESULT_PLOT"
