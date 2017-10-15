#!/bin/sh

# A simple script that will receive events from a RTL433 SDR
# It is tuned to listen to 433.00 MHz with the Current Cost driver

# Author: Chris Kacerguis <chriskacerguis@gmail.com> modified by James Fry

set -x

export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

touch /tmp/rtl_433.log

# Start the listener and enter an endless loop
echo "Starting RTL..."
/usr/local/bin/rtl_433 -p 25 -F json -R 43 | while read line
#/usr/local/bin/rtl_433 -G -p 25 | while read line
do
  # Create file with touch /tmp/rtl_433.log if logging is needed
  [ -w /tmp/rtl_433.log ] && echo $line >> rtl_433.log
  echo $line | /usr/bin/mosquitto_pub -h $MQTT_HOST -u $MQTT_USER -P $MQTT_PASS -i RTL_433 -r -l -t $MQTT_TOPIC
done
