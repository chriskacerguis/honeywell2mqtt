#!/usr/bin/env node

const program = require('commander')
const mqtt = require('mqtt')

program
  .version('0.1.0')
  .option('-p, --packet <item>', 'JSON packet data (as string)')
  .parse(process.argv)

const client  = mqtt.connect('mqtt://' + process.env.MQTT_HOST)

client.on('connect', function () {
  let packet = JSON.parse(program.packet)
  let topic = `home/sensor/${packet.id}`
  client.publish(topic, program.packet, {qos: 1, retain: true})
  client.end()
})