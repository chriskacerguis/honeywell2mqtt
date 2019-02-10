#!/usr/bin/env node

const program = require('commander')
const mqtt = require('mqtt')
const fs = require('fs')

program
  .version('0.2.0')
  .option('-p, --packet <item>', 'JSON packet data (as string)')
  .parse(process.argv)

const client  = mqtt.connect('mqtt://' + process.env.MQTT_HOST)

const discoveryPrefix = 'homeassistant'

var nameMap = fs.readFileSync('map.json')
var jsonNameMap = JSON.parse(nameMap)

client.on('connect', function () {
  let packet = JSON.parse(program.packet)

  // See if there is a name map
  var fName = 'MQTT Binary sensor'
  if(jsonNameMap.hasOwnProperty(packet.id)){
    fName = jsonNameMap[packet.id]
  }

  // Send the discovery message
  let configTopic = `${discoveryPrefix}/binary_sensor/${packet.id}/state`
  let configPayload = `{"name": "${fName},"stat_t": "${configTopic}","qos": 1,"pl_on": "open","pl_off": "closed","dev_cla": "opening"}`
  client.publish(`${discoveryPrefix}/binary_sensor/${packet.id}/config`, configPayload)
  
  let stateTopic = `${discoveryPrefix}/binary_sensor/${packet.id}/state`
  client.publish(stateTopic, packet.state, {qos: 1, retain: true})
  client.end()
})