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

if [ -e /etc/upstart ]; then
	logger "Enabling online screensaver auto-update"

	mntroot rw
	cp onlinescreensaver.conf /etc/upstart/
	mntroot ro

	start onlinescreensaver
else
	logger "Upstart folder not found. upstart file not copied - should implement classic startup script for this kindle"
	lipc-get-prop com.lab126.powerd status | grep "Screen Saver" 
	if [ $? -eq 1 ]
	then
		powerd_test -p
		# simulate power button to go into screensaver mode
	fi
	
	sleep 5
	/bin/sh /mnt/base-us/extensions/onlinescreensaver/bin/scheduler.sh &
	touch /mnt/us/extensions/onlinescreensaver/enabled
fi
