#include <linux/init.h>
#include <linux/module.h>
#include <linux/sched.h>
#include <linux/random.h>
//#include <net/tcp_bufferbloat.h>

MODULE_LICENSE("GPL"); 
MODULE_DESCRIPTION("sample code for DebugFS functionality");
MODULE_AUTHOR("Surya Prabhakar <surya_prabhakar@dell.com>"); 

int init_agent(void)
{
	printk("In begin");
	//int mss_rand = 0;
	//int i;
	//s32 mss_min_threshold = 50;
	//s32 mss_rnd_max_threshold = 1400;
	//s32 mss_rnd_min_threshold = 80;	

	//s32 MSS_RANDOM_STEP;
	//s32 MSS_RANDOM_MIN_THRESHOLD = 5;	

	/*for(i = 0; i < 5; i++)
	{
		get_random_bytes(&mss_rand, sizeof(int) - 1);		
		mss_rand %= 1000;
		printk("Random number : %d\n", mss_rand);
	}*/

	//printk("In begin : %d", MSS_RANDOM_STEP);
	//printk("agent_sign mss_min_threshold=%d, MSS_RANDOM_STEP=%d, %d > %d", mss_min_threshold, MSS_RANDOM_STEP, (mss_min_threshold - MSS_RANDOM_STEP), MSS_RANDOM_MIN_THRESHOLD);

        //if((mss_min_threshold - MSS_RANDOM_STEP) > MSS_RANDOM_MIN_THRESHOLD)
        //{
	//	printk("In begin 3");
	//   	mss_rnd_min_threshold -= MSS_RANDOM_STEP;
  	//	mss_rnd_max_threshold -= MSS_RANDOM_STEP;
	//	printk("In begin 4");
        //        printk("agent_sign mss_rnd_max_threshold = %d, mss_rnd_max_threshold = %d", mss_rnd_max_threshold, mss_rnd_min_threshold);
        //}
	printk("In begin end");

	return 0;
}

void cleanup_agent(void)
{
	printk("In cleanup");
}

module_init(init_agent);
module_exit(cleanup_agent);
