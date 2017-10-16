# Docker file to create an image that contains enough software to listen to events on the 345.00 Mhz band,
# loading the approprate packet decoding for Honeywell RF products; then publish them to a MQTT broker.
# The script resides in a volume and can be modified to meet your needs.

# IMPORTANT: The container needs priviliged access to /dev/bus/usb on the host.

FROM sysrun/rtl_433
MAINTAINER James Fry

LABEL Description="This image is used to start a script that will monitor for Current Cost Sensors events on 433.00 Mhz and send the data to an MQTT server"

#
# First install software packages needed to publish MQTT events
#
RUN apt-get update && \
    apt-get install mosquitto-clients -y

#
# Define an environment variable
#
# Use this variable when creating a container to specify the MQTT broker host.
ENV MQTT_HOST="hassio.local:1883"
ENV MQTT_USER="guest"
ENV MQTT_PASS="guest"
ENV MQTT_TOPIC="homeassistant/sensor/currentcost"

COPY ./rtl2mqtt.sh /
RUN chmod +x /rtl2mqtt.sh
ENTRYPOINT ["/rtl2mqtt.sh"]
#ENTRYPOINT ["/usr/local/bin/rtl_433"]
