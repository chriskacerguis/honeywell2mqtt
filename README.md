# honeywell2mqtt
A Docker image for a software defined radio tuned to listen for Honeywell RF security sensors at 345Mhz.  This is based off of Marco Verleun's 
awesome rtl2mqtt image, but adpated just for Honeywell products (and working with Home Assistant)

## Usage

To run the container, use the following:

```
sudo docker run --name rtl_433 -d \
-e MQTT_HOST=<mqtt-broker.example.com> \
--privileged -v /dev/bus/usb:/dev/bus/usb \
--name honeywell2mqtt chriskacerguis/honeywell2mqtt
```

Optionally, you can pass in the MQTT username, password, and topic using the following:

```
sudo docker run --name rtl_433 -d \
-e MQTT_HOST=<mqtt-broker.example.com> \
-e MQTT_USER=username \
-e MQTT_PASS=password \
-e MQTT_TOPIC=your/topic/name \
--privileged -v /dev/bus/usb:/dev/bus/usb \
--name honeywell2mqtt chriskacerguis/honeywell2mqtt
```

## MQTT Data

Data to the MQTT server will look like this

```json
{"time" : "2017-08-17' '13:18:58", "model" : "Honeywell' Door/Window 'Sensor", "id" : 547651, "channel" : 8, "event" : 4, "state" : "closed", "heartbeat" : "yes"}
```

**The default topic is:** homeassistant/sensor/honeywell

## Hardware

This has been tested and used with the following hardware (you can get it on Amazon)

- Honeywell Ademco 5818MNL Recessed Door Transmitter
- 5800MINI Wireless Door/Window Contact by Honeywell
- NooElec NESDR Nano 2+ Tiny Black RTL-SDR USB

It should work just fine with any Honeywell RF sensors.