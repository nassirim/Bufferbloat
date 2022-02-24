#!/bin/bash

clear

if [ $# -ne 1 ]; then
        echo "Usage   : $0 <mss_now | tcp_inject_interval | mss_rand | mss_rnd_threshold >"
        echo "example : $0 mss_now"

        exit 1
fi

FLE_KERNEL_LOG="/var/log/messages"
FLE_BUFFERBLOAT_LOG="rawdata/bufferbloat_log.tmp"
FLE_BUFFERBLOAT_DATA="rawdata/${1}.dat"
FLE_OUTPUT_PLOT=""

function log_filter() 
{
	counter=0

	echo -e "\nWorking on it..."
	echo "==================="
	grep "tcp_bufferbloat" $FLE_KERNEL_LOG | grep "$1" | awk '{print $8, $9}' > $3 #$FLE_BUFFERBLOAT_LOG

	while IFS= read -r itm_line
	do
		itm_point=$( echo $itm_line | awk '{print $2}' | cut -d '=' -f 2 )

		if [ "$itm_point" == "" ]; then	
			itm_point=$( echo $itm_line | cut -d '=' -f 2 )
		fi

		echo "$counter       $itm_point" >> $2 #FLE_BUFFERBLOAT_DATA
		counter=$(($counter + 1))

		# shwo a dot progress every 100 iteration
		if [ $((counter % 100)) = 0 ]; then
        		echo -n "."
        	fi

	done < $3 #"$FLE_BUFFERBLOAT_LOG"

	echo -e "\n\nCleanning up ..."
        echo "==================="
	rm -v "$3"
}

function single_plotter()
{
	gnuplot -e "set terminal png size 2000,800;
                set output \"$FLE_OUTPUT_PLOT\";
                set title \"${plt_title}\" font \"arial,15\";
                set xlabel \"${x_label}\";
                set grid;
                set ylabel \"${y_label}\" font \"arial,14\";
                plot \"${FLE_BUFFERBLOAT_DATA}\" title \"Large Buffer\" with lines;
                exit"
}

function double_plotter()
{
	gnuplot -e "set terminal png size 2000,800;
                set output \"$FLE_OUTPUT_PLOT\";
                set title \"${plt_title}\" font \"arial,15\";
                set xlabel \"${x_lablel}\";
                set grid;
                set ylabel \"${y_lablel}\" font \"arial,14\";
                plot \"$1\" title \"Max Rand MSS Threshold\" with lines,
                     \"$2\" title \"Min Rand MSS Threshold\" with lines;
                exit"
}

if [ "$1" == "tcp_inject_interval" ]; then
	rm -v $FLE_BUFFERBLOAT_DATA

        fle_plot="TCPInjectInterval"
	plt_title="TCP Inject Interval Statistic"
	x_label="Time (second)"
	y_label="Interval (packet)"

	log_filter "$1" "$FLE_BUFFERBLOAT_DATA" "$FLE_BUFFERBLOAT_LOG"
	FLE_OUTPUT_PLOT="plot/${fle_plot}.png"
	single_plotter

elif [ "$1" == "mss_now" ]; then
	rm -v $FLE_BUFFERBLOAT_DATA

        fle_plot="TCPBufferbloatMSS"
	plt_title="TCP MSS Statistic"
	x_label="Time (second)"
	y_label="MSS (Byte)"

	log_filter "$1" "$FLE_BUFFERBLOAT_DATA" "$FLE_BUFFERBLOAT_LOG"
	FLE_OUTPUT_PLOT="plot/${fle_plot}.png"
	single_plotter

elif [ "$1" == "mss_rand" ]; then
	rm -v $FLE_BUFFERBLOAT_DATA

        fle_plot="TCPBufferbloatMSSRand"
	plt_title="TCP MSS Rand Statistic"
	x_label="Time (second)"
	y_label="MSS (Byte)"

	log_filter "$1" "$FLE_BUFFERBLOAT_DATA" "$FLE_BUFFERBLOAT_LOG"
	FLE_OUTPUT_PLOT="plot/${fle_plot}.png"
	single_plotter

elif [ "$1" == "mss_rnd_threshold" ]; then
	rm -v "rawdata/${1}_min.dat"
	rm -v "rawdata/${1}_max.dat"

        fle_plot="TCPBufferbloatMSSRandThreshold"
	plt_title="TCP MSS Rand Threshold Statistic"
	x_label="Time (second)"
	y_label="MSS (Byte)"

	log_filter "mss_rnd_min_threshold" "rawdata/${1}_min.dat" "${FLE_BUFFERBLOAT_LOG}"
	log_filter "mss_rnd_max_threshold" "rawdata/${1}_max.dat" "${FLE_BUFFERBLOAT_LOG}"

	FLE_OUTPUT_PLOT="plot/${fle_plot}.png"
	double_plotter "rawdata/${1}_min.dat" "rawdata/${1}_max.dat" 
fi


echo -e "\nOpenning up ..."
echo "==================="
gvfs-open "$FLE_OUTPUT_PLOT"
