#
# Docker file to create an image that contains enough software to listen to events on the 345.00 Mhz band,
# loading the approprate packet decoding for Honeywell RF products; then publish them to a MQTT broker.
#
# The script resides in a volume and can be modified to meet your needs.
#
# IMPORTANT: The container needs priviliged access to /dev/bus/usb on the host.
# 
# docker run --name rtl_433 -d -e MQTT_HOST=<mqtt-broker.example.com> --privileged -v /dev/bus/usb:/dev/bus/usb <image>
#
# Optionally you can also pass -e MQTT_USER=username -e MQTT_PASS=password -e MQTT_TOPIC=your/topic/name

FROM ubuntu:16.04
MAINTAINER Chris Kacerguis

LABEL Description="This image is used to start a script that will monitor for Honeywell Sensors events on 345.00 Mhz and send the data to an MQTT server"

#
# First install software packages needed to compile rtl_433 and to publish MQTT events
#
RUN apt-get update && apt-get install -y \
  rtl-sdr \
  librtlsdr-dev \
  librtlsdr0 \
  git \
  automake \
  libtool \
  cmake \
  mosquitto-clients
  
#
# Pull RTL_433 source code from GIT, compile it and install it
#
RUN git clone https://github.com/merbanan/rtl_433.git \
  && cd rtl_433/ \
  && mkdir build \
  && cd build \
  && cmake ../ \
  && make \
  && make install 

#
# Define environment variables
#
ENV MQTT_TOPIC="homeassistant/sensor/honeywell"

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]