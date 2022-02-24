all : test_agent.c
	make -C /lib/modules/`uname -r`/build M=$(PWD) modules

clean : 
	make -C /lib/modules/`uname -r`/build M=$(PWD) clean

obj-m := test_agent.o
