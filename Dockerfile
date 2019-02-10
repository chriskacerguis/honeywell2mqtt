# Docker file to create an image that contains enough software to listen to events on the 345.00 Mhz band,
# loading the approprate packet decoding for Honeywell RF products; then publish them to a MQTT broker.
# The script resides in a volume and can be modified to meet your needs.

# IMPORTANT: The container needs priviliged access or access to /dev/bus/usb on the host.

FROM node:11-alpine
LABEL maintainer="Chris Kacerguis <chris@fuzzyblender.com>"

LABEL Description="This image will monitor for Honeywell Sensors message at 345.00 Mhz and send the data to an MQTT server"

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

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . /app

ENTRYPOINT ["/app/listen.sh"]