#
# Special attention is required to allow the container to access the USB device that is plugged into the host.
# The container needs priviliged access to /dev/bus/usb on the host.
# 
# docker run --name honeywell2mqtt -d -e MQTT_HOST=<mqtt-broker.example.com> [other ENV vars] --privileged -v /dev/bus/usb:/dev/bus/usb <image>

FROM alpine:3.6
MAINTAINER Chris Kacerguis

LABEL Description="This image is used to start a script that will monitor for events on 345.00 Mhz"

# Pull rtl-sdr source code from GIT, compile it and install it
RUN apk add --no-cache --virtual build-deps alpine-sdk cmake git libusb-dev && \
    mkdir /tmp/src && \
    cd /tmp/src && \
    git clone git://git.osmocom.org/rtl-sdr.git && \
    mkdir /tmp/src/rtl-sdr/build && \
    cd /tmp/src/rtl-sdr/build && \
    cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON -DCMAKE_INSTALL_PREFIX:PATH=/usr/local && \
    make && \
    make install && \
    apk del build-deps && \
    rm -r /tmp/src && \
    chmod +s /usr/local/bin/rtl_* && \
    apk add --no-cache libusb

# Pull RTL_433 source code from GIT, compile it and install it
RUN git clone https://github.com/merbanan/rtl_433.git \
  && cd rtl_433/ \
  && mkdir build \
  && cd build \
  && cmake ../ \
  && make \
  && make install 

# Define an environment variable
ENV MQTT_HOST=""
ENV MQTT_USER=""
ENV MQTT_PASS=""
ENV MQTT_TOPIC="homeassistant/sensor/honeywell"

# When running a container this script will be executed
ENTRYPOINT ["/scripts/entry.sh"]

# Copy my script and make it executable
COPY entry.sh /scripts/entry.sh
RUN chmod +x /scripts/entry.sh

# The script is in a volume (if you want to modify it)
VOLUME ["/scripts"]
