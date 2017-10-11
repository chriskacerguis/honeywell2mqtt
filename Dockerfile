# Docker file to create an image that contains enough software to listen to events on the 345.00 Mhz band,
# loading the approprate packet decoding for Honeywell RF products; then publish them to a MQTT broker.
# The script resides in a volume and can be modified to meet your needs.

# IMPORTANT: The container needs priviliged access to /dev/bus/usb on the host.

FROM alpine:3.6
MAINTAINER Chris Kacerguis

LABEL Description="This image is used to start a script that will monitor for Honeywell Sensors events on 345.00 Mhz and send the data to an MQTT server"

#
# First install software packages needed to compile rtl_433 and to publish MQTT events
#
RUN apk add --no-cache --virtual build-deps alpine-sdk cmake git libusb-dev && \
    mkdir /tmp/src && \
    cd /tmp/src && \
    git clone git://git.osmocom.org/rtl-sdr.git && \
    mkdir /tmp/src/rtl-sdr/build && \
    cd /tmp/src/rtl-sdr/build && \
    cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON -DCMAKE_INSTALL_PREFIX:PATH=/usr/local && \
    make && \
    make install && \
    chmod +s /usr/local/bin/rtl_* && \
    cd /tmp/src/ && \
    git clone https://github.com/merbanan/rtl_433.git && \
    cd rtl_433/ && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make && \
    make install && \
    apk del build-deps && \
    rm -r /tmp/src && \
    apk add --no-cache libusb mosquitto-clients

#
# Define an environment variable
#
# Use this variable when creating a container to specify the MQTT broker host.
ENV MQTT_HOST="localhost"
ENV MQTT_USER="guest"
ENV MQTT_PASS="guest"
ENV MQTT_TOPIC="homeassistant/sensor/honeywell"

COPY ./rtl2mqtt.sh /
RUN chmod +x /rtl2mqtt.sh
#ENTRYPOINT ["/rtl2mqtt.sh"]
ENTRYPOINT ["/usr/local/bin/rtl_433"]
