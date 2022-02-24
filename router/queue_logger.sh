#!/bin/sh

HOME_DIR="/home/tstrouter/Bufferbloat/"

. "${HOME_DIR}config/validation.conf"

LOG_FILE="${HOME_DIR}rawdata/output.log"

rm -v $LOG_FILE

if [ $# -eq 0 ]; then
	echo "Usage : $0 <experiment> <time>" >> $LOG_FILE
	exit 1
else
	experiment=$1
	time=$2
	echo launching $0 to $experiment for $time socends >> $LOG_FILE
	echo  
fi

DATA_FILE="${HOME_DIR}rawdata/queue_${experiment}.drp"
step_timer=0
cumulative_drop=0
current_drop=0
previous_drop=$(sysctl net.inet.ip.dummynet.io_pkt_drop | cut -f 2 -d ':')

echo -e "\nCleaning up data ..." >> $LOG_FILE
echo "=============================" >> $LOG_FILE
rm -v $DATA_FILE >> $LOG_FILE

send_data() {
	echo -e "\n\nSending data to $clnt_ip" >> $LOG_FILE
	echo "===========================" >> $LOG_FILE
	scp $DATA_FILE root@$clnt_ip:/home/tstclient/Bufferbloat/router/rawdata/
}

echo -e "\nStaring drops statistic ..." >> $LOG_FILE
echo "=============================" >> $LOG_FILE
echo "    Time            drops" >> $LOG_FILE
echo "-----------------------------" >> $LOG_FILE

time=$(($time / 5))
for i in $(seq $time)
do
	cumulative_drop=$(sysctl net.inet.ip.dummynet.io_pkt_drop | cut -f 2 -d ':')
	current_drop=$(($cumulative_drop - $previous_drop))

	echo "$step_timer   $current_drop" >> $DATA_FILE
	step_timer=$(($step_timer + 5))
	echo "    $step_timer              $current_drop" >> $LOG_FILE

	previous_drop=$cumulative_drop

	sleep 5
done

send_data
