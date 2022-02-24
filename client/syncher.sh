#!/bin/bash

echo "File Transfer Started ..."
echo "============================"

scp *.sh boolean@192.168.10.20:/home/boolean/Workspace/Bufferbloat/client/
scp config/* boolean@192.168.10.20:/home/boolean/Workspace/Bufferbloat/client/config/
scp plot/* boolean@192.168.10.20:/home/boolean/Workspace/Bufferbloat/client/plot/
scp rawdata/*  boolean@192.168.10.20:/home/boolean/Workspace/Bufferbloat/client/rawdata/

echo -e "\ndone."
