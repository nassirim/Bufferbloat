#!/bin/bash
echo Reamoving boot
echo ================
rm -v /boot/*4.15.1*

echo

echo Removing modules
echo ================
rm -rv /lib/modules/4.15.1/
