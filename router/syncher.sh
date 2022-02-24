#!/bin/sh

echo "File Transfer Started ..."
echo "============================"

scp *.sh root@192.168.10.10:/home/tstclient/Bufferbloat/router/
scp -r config root@192.168.10.10:/home/tstclient/Bufferbloat/router/

echo -e "\ndone."
