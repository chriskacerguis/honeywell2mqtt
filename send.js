#!/usr/bin/env node

const program = require('commander')
const mqtt = require('mqtt')
const fs = require("fs")

program
  .version('0.2.0')
  .option('-p, --packet <item>', 'JSON packet data (as string)')
  .parse(process.argv)

const client  = mqtt.connect('mqtt://' + process.env.MQTT_HOST)

const discoveryPrefix = 'homeassistant'

client.on('connect', function () {
  let packet = JSON.parse(program.packet)

  // Send the discovery message
  let configPayload = `{
    "stat_t": "${discoveryPrefix}/binary_sensor/${packet.id}/state",
    "qos": 1,
    "pl_on": "open",
    "pl_off": "closed",
    "dev_cla": "opening"
  }`
  client.publish(`${discoveryPrefix}/binary_sensor/${packet.id}/config`, configPayload.replace(/\s/g,''))
  


  let topic = `${discoveryPrefix}/binary_sensor/${packet.id}/state`
  client.publish(topic, packet.state, {qos: 1, retain: true})
  client.end()
})