#!/bin/bash

# A simple script that will receive events from a RTL433 SDR
# It is tuned to listen to 345.00 MHz with the Honeywell driver
#
# Author: Chris Kacerguis <chriskacerguis@gmail.com>

export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

# Start the listener and enter an endless loop
/usr/local/bin/rtl_433 -f 345000000 -F json -R 70 -U | while read line
do
  # Create file with touch /tmp/rtl_433.log if logging is needed
  [ -w /tmp/rtl_433.log ] && echo $line >> rtl_433.log
  echo $line | /usr/bin/mosquitto_pub -h localhost -u guest -P guest -r -l -t "homeassistant/sensor/honeywell"
done