#! /bin/bash

if [ $# != 1 ]; then
echo 'usage: myip.sh <interface>'

else
ifconfig $1 |grep inet\ |sed -e s'/B.*$//g' |sed -e s'/^.*://g' |sed -e s'/\ .*$//g'
fi
