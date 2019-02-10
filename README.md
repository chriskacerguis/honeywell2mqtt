# honeywell2mqtt
A Docker image for a software defined radio tuned to listen for Honeywell RF security sensors at 345Mhz.  This is based off of Marco Verleun's 
awesome rtl2mqtt image, but adpated just for Honeywell products and made to work with Home Assistant and MQTT Discovery.

## Usage

To run the container, use the following:

```
sudo docker run --name honeywell2mqtt -d \
-e MQTT_HOST=<mqtt-broker.example.com> \
--privileged chriskacerguis/honeywell2mqtt
```

## Name Mapping (OPTIONAL)

By default you the system will not set a friendlt name, and it will simply default to "MQTT Binary Sensor".  You can mount a map.json file will an ID to name map, and the friendly name will be set to the value.  Here is an example:

```json
{
    "648705": "Front Door",
    "648653": "Back Door"
}
```

Simple add the following line to the docker run command above:

```sh
-v ${pwd}/map.json:/app/map.json
```

## MQTT Topics

States will be posted to the topic homeassistant/binary_sensor/[id]/state

Where [id] is the sensor id from the each device

## Hardware

This has been tested and used with the following hardware (you can get it on Amazon)

- Honeywell Ademco 5818MNL Recessed Door Transmitter
- 5800MINI Wireless Door/Window Contact by Honeywell
- NooElec NESDR Nano 2+ Tiny Black RTL-SDR USB

However, it should work just fine with any Honeywell RF sensors transmitting on 345Mhz.


## Troubleshooting

If you see this error:

> Kernel driver is active, or device is claimed by second instance of librtlsdr.
> In the first case, please either detach or blacklist the kernel module
> (dvb_usb_rtl28xxu), or enable automatic detaching at compile time.

Then run the following command on the host

```bash
sudo rmmod dvb_usb_rtl28xxu rtl2832
```