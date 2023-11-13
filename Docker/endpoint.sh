#!/bin/sh
LD_LIBRARY_PATH=/usr/local/lib
export LD_LIBRARY_PATH
ldconfig
echo "nameserver 192.168.42.9" >> /etc/resolv.conf
tail -f /dev/null
#/root/main > /data/dvs/copy.log
