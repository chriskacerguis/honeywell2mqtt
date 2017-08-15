#!/bin/bash

# A simple script that will receive events from a RTL433 SDR
#
# Author: Chris Kacerguis <chriskacerguis@gmail.com>

export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

# Start the listener and enter an endless loop
/usr/local/bin/rtl_433 -f 345000000 -F json -R 70 -U |  while read line
do
  echo $line  | /usr/bin/mosquitto_pub -h $MQTT_HOST -u $MQTT_USER -P $MQTT_PASS -i RTL_433 -r -l -t $MQTT_TOPIC
done