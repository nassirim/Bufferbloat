#ifndef _TCP_BUFFERBLOAT_H
#define _TCP_BUFFERBLOAT_H

#define WINDOW_SIZE 40
#define BUFFERBLOAT_EFFECT_TIME 15 //30

/* store efficient mss size */
u32 mss_fragged_size = 60;

/* count down timer to force bufferbloat algorithm to wait some until she get her previouse operation effect */
u32 bla_effect_time = 0;

/* small tcp inject rate */
u32 tcp_inject_interval = 10;	// after this number of normal packets send a packet with mss_fragged_size size
u32 tcp_inject_counter = 0;

/* definition of an array as RTT window */
u32 bufferbloat_rtt_window[WINDOW_SIZE] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
					   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

/* store bufferbloat window index */
u32 rtt_window_pointer = -1;

/* two variables for determine that RTT is increasing or decreasing */
u32 rtt_old_point = 0;
u32 rtt_new_point = 0;

/* variables and constants to use in random method */
int mss_rnd_min_threshold = 600;
int mss_rnd_max_threshold = 900;

bool is_first_call = true;	// make sure that somethings will happen just in first call

#define MSS_RANDOM_STEP 40
#define MSS_RANDOM_BIG_STEP 80

#define MSS_RANDOM_MAX_THRESHOLD 1420
#define MSS_RANDOM_MIN_THRESHOLD 100

#endif
