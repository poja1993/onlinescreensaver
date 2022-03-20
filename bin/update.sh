#!/bin/sh
#
##############################################################################
#
# Fetch weather screensaver from a configurable URL.

# change to directory of this script
cd "$(dirname "$0")"

# load configuration
if [ -e "config.sh" ]; then
	source ./config.sh
else
	TMPFILE=/tmp/tmp.onlinescreensaver.png
fi

# load utils
if [ -e "utils.sh" ]; then
	source ./utils.sh
else
	echo "Could not find utils.sh in `pwd`"
	exit
fi

# do nothing if no URL is set
if [ -z $IMAGE_URI ]; then
	logger "No image URL has been set. Please edit config.sh."
	return
fi

# enable wireless if it is currently off
if [ 0 -eq `lipc-get-prop com.lab126.cmd wirelessEnable` ]; then
	logger "WiFi is off, turning it on now"
	lipc-set-prop com.lab126.cmd wirelessEnable 1
	DISABLE_WIFI=1
fi

# wait for network to be up
TIMER=${NETWORK_TIMEOUT}     # number of seconds to attempt a connection
CONNECTED=0                  # whether we are currently connected
while [ 0 -eq $CONNECTED ]; do
	# test whether we can ping outside
	/bin/ping -c 1 $TEST_DOMAIN > /dev/null && CONNECTED=1

	# if we can't, checkout timeout or sleep for 1s
	if [ 0 -eq $CONNECTED ]; then
		TIMER=$(($TIMER-1))
		if [ 0 -eq $TIMER ]; then
			logger "No internet connection after ${NETWORK_TIMEOUT} seconds, aborting."
			break
		else
			sleep 1
		fi
	fi
done

if [ 1 -eq $CONNECTED ]; then
	if wget -q $IMAGE_URI -O $TMPFILE; then
		mv $TMPFILE $SCREENSAVERFILE
		logger "Screen saver image file updated"
                # refresh screen
                lipc-get-prop com.lab126.powerd status | grep "Screen Saver" && (
                     logger "Updating image on screen"
                     eips -f -g $SCREENSAVERFILE
                     batt=`powerd_test -s | awk -F: '/Battery Level/ {print substr($2,2,2)}'`
# Create json for POST
generate_post_data()
{
  cat<<EOF
{
  "kindle_battery":"$batt"
}
EOF
}
                     # If WEBHOOKADR has been defined, send data
					 if [ "" != $WEBHOOKADR ]; then
                       curl -X POST -k -d "$(generate_post_data)" -H 'Content-Type: application/json' $WEBHOOKADR
                     fi
                     eips 40 39 "Batt:${batt}%"
                )
	else
		logger "Error updating screensaver"
		if [ 1 -eq $DONOTRETRY ]; then
			touch $SCREENSAVERFILE
		fi
	fi
fi

# disable wireless if necessary
if [ 1 -eq $DISABLE_WIFI ]; then
	logger "Disabling WiFi"
	lipc-set-prop com.lab126.cmd wirelessEnable 0
fi
