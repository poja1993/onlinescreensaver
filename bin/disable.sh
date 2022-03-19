#!/bin/sh

# change to directory of this script
cd "$(dirname "$0")"

# load configuration
if [ -e "config.sh" ]; then
	source ./config.sh
fi

# load utils
if [ -e "utils.sh" ]; then
	source ./utils.sh
else
	echo "Could not find utils.sh in `pwd`"
	exit
fi

# forever and ever, try to update the screensaver
logger "Disabling online screensaver auto-update"

#stop onlinescreensaver || true      
PID=`ps xa | grep "/bin/sh /mnt/base-us/extensions/onlinescreensaver/bin/scheduler.sh" | awk '{ print $1 }'`
logger "killing scheduler process: $PID"
kill $PID || true

#lipc-set-prop com.lab126.cmd wirelessEnable 1
rm /mnt/us/extensions/onlinescreensaver/enabled
#rm /etc/upstart/onlinescreensaver.conf
