#!/bin/bash

FLE_ECONDITION='plot/EConditions.tbl'
FLE_VALIDATION_CLIENT='config/validation.conf'
FLE_EXPERIMENT_CLIENT='config/experiment.conf'

FLE_VALIDATION_ROUTER='../router/config/validation.conf'
FLE_EXPERIMENT_LARGE_RUN1='../router/config/large_erun1.conf'
FLE_EXPERIMENT_LARGE_RUN2='../router/config/large_erun2.conf'
FLE_EXPERIMENT_SMALL_RUN1='../router/config/small_erun1.conf'
FLE_EXPERIMENT_SMALL_RUN2='../router/config/small_erun2.conf'

# read configuration from file
function get_config() {
        return_config=$( cat $1 | grep "$2" | cut -d '=' -f 2 )
}

> $FLE_ECONDITION

printf "\n                            Experiment Conditions\n" >> $FLE_ECONDITION
printf " ---------------------------------------------------------------------------------\n" >> $FLE_ECONDITION
printf "  %-20s %-17s %-23s %s\n"  "Parameter" "Validation" "Experiemnt Run 1" "Experiment Run 2" >> $FLE_ECONDITION
printf " ---------------------------------------------------------------------------------\n" >> $FLE_ECONDITION

get_config $FLE_VALIDATION_ROUTER up_bw
v_up_bw=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN1 up_bw
er1_up_bw=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN2 up_bw
er2_up_bw=$return_config

printf "  %-21s %-17s %-23s %s\n" "Uplink Capacity" \
       "$v_up_bw" "$er1_up_bw" "$er2_up_bw" >> $FLE_ECONDITION

get_config $FLE_VALIDATION_ROUTER down_bw
v_down_bw=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN1 down_bw
er1_down_bw=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN2 down_bw
er2_down_bw=$return_config
 
printf "  %-21s %-17s %-23s %s\n" "Downlink Capacity" \
       "$v_down_bw" "$er1_down_bw" "$er2_down_bw" >> $FLE_ECONDITION

get_config $FLE_VALIDATION_ROUTER up_delay
v_up_delay=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN1 up_delay
er1_up_delay=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN2 up_delay
er2_up_delay=$return_config

printf "  %-21s %-17s %-23s %s\n" "Uplink Delay" \
       "$v_up_delay" "$er1_up_delay" "$er2_up_delay" >> $FLE_ECONDITION

get_config $FLE_VALIDATION_ROUTER down_delay
v_down_delay=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN1 down_delay
er1_down_delay=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN2 down_delay
er2_down_delay=$return_config

printf "  %-21s %-17s %-23s %s\n" "Downlink Delay" \
       "$v_down_delay" "$er1_down_delay" "$er2_down_delay" >> $FLE_ECONDITION

get_config $FLE_VALIDATION_ROUTER up_queue
v_up_queue=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN1 up_queue
er1_s_up_queue=$return_config
get_config $FLE_EXPERIMENT_LARGE_RUN1 up_queue
er1_l_up_queue=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN2 up_queue
er2_s_up_queue=$return_config
get_config $FLE_EXPERIMENT_LARGE_RUN2 up_queue
er2_l_up_queue=$return_config

printf "  %-21s %-17s %s - %-17s %s - %s\n" "Uplink Buffer" \
       "${v_up_queue}S" "${er1_s_up_queue}S" "${er1_l_up_queue}S" \
       "${er2_s_up_queue}S" "${er2_l_up_queue}S" >> $FLE_ECONDITION

get_config $FLE_VALIDATION_ROUTER down_queue
v_down_queue=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN1 down_queue
er1_s_down_queue=$return_config
get_config $FLE_EXPERIMENT_LARGE_RUN1 down_queue
er1_l_down_queue=$return_config
get_config $FLE_EXPERIMENT_SMALL_RUN2 down_queue
er2_s_down_queue=$return_config
get_config $FLE_EXPERIMENT_LARGE_RUN2 down_queue
er2_l_down_queue=$return_config


printf "  %-21s %-17s %s - %-17s %s - %s\n" "Downlink Buffer" \
       "${v_down_queue}S" "${er1_s_down_queue}S" "${er1_l_down_queue}S" \
       "${er2_s_down_queue}S" "${er2_l_down_queue}S"  >> $FLE_ECONDITION

get_config $FLE_VALIDATION_CLIENT "tcp_rate"
v_conf=$return_config
get_config $FLE_EXPERIMENT_CLIENT "tcp_rate"
e_conf=$return_config

printf "  %-21s %-17s %-23s %s\n" \
       "TCP Rate" "${v_conf}Kbps" "${e_conf}Kbps" "${e_conf}Kbps" >> $FLE_ECONDITION

get_config $FLE_VALIDATION_CLIENT "run_count"
v_conf=$return_config
get_config $FLE_EXPERIMENT_CLIENT "run_count"
e_conf=$return_config

printf "  %-21s %-17s %-23s %s\n" "Run Count" "$v_conf" "$e_conf" "$e_conf" >> $FLE_ECONDITION

get_config $FLE_VALIDATION_CLIENT "time"
v_conf=$return_config
get_config $FLE_EXPERIMENT_CLIENT "time"
e_conf=$return_config

printf "  %-21s %-17s %-23s %s\n" "Time" "${v_conf}s" "${e_conf}s" "${e_conf}s" >> $FLE_ECONDITION

get_config $FLE_VALIDATION_CLIENT "tcp_packetsize"
v_conf=$return_config
get_config $FLE_EXPERIMENT_CLIENT "tcp_packetsize"
e_conf=$return_config

printf "  %-21s %-17s %-23s %s\n" \
       "TCP Packet Size" "${v_conf}B" "${e_conf}B" "${e_conf}B" >> $FLE_ECONDITION

get_config $FLE_VALIDATION_CLIENT "udp_packetsize"
v_conf=$return_config
get_config $FLE_EXPERIMENT_CLIENT "udp_packetsize"
e_conf=$return_config

printf "  %-21s %-17s %-23s %s\n" \
       "UDP Packet Size" "${v_conf}B" "${e_conf}B" "${e_conf}B" >> $FLE_ECONDITION

get_config $FLE_VALIDATION_CLIENT "cc_algorithm"
v_conf=$return_config
get_config $FLE_EXPERIMENT_CLIENT "cc_algorithm"
e_conf=$return_config

printf "  %-21s %-17s %-23s %s\n" "TCP Variant" "$v_conf" "$e_conf" "$e_conf" >> $FLE_ECONDITION

printf " ---------------------------------------------------------------------------------\n" \
       >> $FLE_ECONDITION

printf "  s : Second , B : Byte , S : Slot , ms : Mili Second\n" >> $FLE_ECONDITION

printf " ---------------------------------------------------------------------------------\n\n" \
       >> $FLE_ECONDITION

clear
cat $FLE_ECONDITION



