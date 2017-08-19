# Docker file to create an image that contains enough software to listen to events on the 345.00 Mhz band,
# loading the approprate packet decoding for Honeywell RF products; then publish them to a MQTT broker.
# The script resides in a volume and can be modified to meet your needs.

# IMPORTANT: The container needs priviliged access to /dev/bus/usb on the host.

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
# Define an environment variable
# 
# Use this variable when creating a container to specify the MQTT broker host.
ENV MQTT_HOST="localhost"
ENV MQTT_USER="guest"
ENV MQTT_PASS="guest"
ENV MQTT_TOPIC="homeassistant/sensor/honeywell"

COPY rtl2mqtt.sh /
CMD ["/rtl2mqtt.sh"]