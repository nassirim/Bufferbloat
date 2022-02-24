# Bufferbloat
Split TCP segments to overcome bufferbloat and latency problems

# DESCRIPTION
	The purpose of this project was implement the senario`s of the paper in Testbed to
	prove correctness of the suggested mechanisms to solve bufferbloat problem.

# TOPOLOGY
	        | (Client) |    Ethernet   | (Router) |   Ethernet    | (Server) |
		|  Linux   |---------------|   Unix   |---------------|  Linux   |
		|  Debian  |               |  FreeBSD |               |  Debian  |

# PRECONDITION
	You must install these package's on Testbed befor you can run experiments.
	CLIENT AND SERVER : ipmt (Traffic generator tool), tcpdump (Packet capture tool), 
	tcptrace (Packet analyzer tool), gnuplot (Plot draw tool), ssh (remote login shell)
	ROUTER : ipfw (dummynet tool)
	Prepare ssh : You must do some configs related to ssh. It necessery for run some ex_
	periments.

# CONFIGURATIONS
	You must follow bellow configurtion for you'r testbed`s machines we uesed these IP_
	`s in some scripts. Note that router machine has two interface.
 
                                                                                 
	|     (Client)     |            |     (Router)      |            
	| IP:192.168.10.10 |------------| IP-1:192.168.10.1 |            |     (Server)     |
	| User:tstclient   |            | IP-2:192.168.11.1 |------------| IP:192.168.11.10 |
					| User:tstrouter    |            | User:tstserver   |

	SSH CONFIG : You must enable root login permession on every machine to do this cha_
	nge "PermitRootLogin without-password yes" line to "PermitRootLogin yes" in ssh co_
	nfig file at /etc/ssh/sshd_config
	SSH SESSIONS : You must generate ssh key on every machine and copy the key to other
	machine's to able you create ssh connection without enter password. You can do this 
	with bellow commands.
		ssh-keygen -t ras             # generate ssh key
		ssh-copy-id root@<IP Address> # copy ssh key to other machine's
		# run this command on every matchin in testbed with another IP's


# PROJECT STRUCTUR
	client                        --> script`s and config file`s for client side
	  |
	  +------- validation_run.sh  --> script for run validation experiment in client side
	  |
	  +------- experiment_run.sh  --> script for run two experiment in client side
	  |
	  +------- dnld_clnt.sh       --> script for run downlaod response time experiment in client side
	  |
	  +------- tbl_luncher.sh     --> an auxiliary script for display result in a table
	  |
	  +------- config             --> this directory contains config file`s
	  |
	  +------- plot               --> this directory contains plot`s in png format
	  |
	  +------- rawdata            --> this directory contains raw information that gathered during run


	server                        --> script`s and config file`s for server side
	  |
	  +------- ipmt_srvr.sh       --> script for prepare server for run validation experiment
	  |
	  +------- dnld_srvr.sh       --> script for run download response time in server side
	  |
	  +------- config             --> this directory contains config file`s
	  |
	  +------- distributions      --> this directory contains tool`s and script`s for generate distributions number`s 
	  |
	  +------- log                --> script`s will generate some log`s that stored in this directory
	  |
	  +------- plot               --> this directory contains plot`s in png format
	  |
	  +------- rawdata            --> this directory contains raw information that gathered during run

	  
	router                        --> script and config file's for router side
	  |
	  +------- ipfw_luncher.sh    --> this script will run dummynet for config firewall and adjust link's
	  |
	  +------- config             --> this directory contains config file`s

# HOW TO RUN EXPERIMENT'S
COPY SCRIPT'S
	Copy scripts to correct directori`s
	CLIENT SIDE : Create a directory in home folder with name "Bufferbloat" then copy
	all content of "client" directory to that. 
	SERVER SIDE : Create a directory in home folder with name "Bufferbloat" then copy
        all content of "server" directory to that.
	ROUTER SIDE : Create a directory in home folder with name "Bufferbloat" then copy
        all content of "router" directory to that.

 VALIDATION RUN
	ROUTER SIDE : run "ipfw_luncher.sh" by "validation.conf" parameter with root access
	SERVER SIDE : run "ipmt_srvr.sh" by "validation" with root access to prepare server 
	CLIENT SIDE : run "validation_run.sh" with root access to generate traffic and display result's.

EXPERIMENT`S RUN
	ROUTER SIDE : run "ipfw_luncher.sh" by "small_run_1.conf" parameter with root access
	SERVER SIDE : run "ipmt_srvr.sh" by "experiment" with root access to prepare server
	CLIENT SIDE : run "experiment_run.sh" by "run_1" or "run_2" parameter to start experiment

DOWNLOAD RESPONSE TIME
	ROUTER SIDE : run "ipfw_luncher.sh" by "validation.conf" parameter with root access 
	SERVER SIDE : run "dnld_srvr.sh" by "WithoutUDP" or "WithUDP" parameter to start experiment
	Note that you don't need to run any script in client side because it will run by ssh from server side

# SUPPORT
	Let us know by bellow Email address`s if you have any problem with this project.
	Ali Ahmadi : g.ecs3d@gmail.com
	Parisa Abdolmaleki : -
