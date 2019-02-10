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
  var fName = `Honeywell ${packet.id}`
  if(jsonNameMap.hasOwnProperty(packet.id)){
    fName = jsonNameMap[packet.id]
  }

  // Set base topic
  let baseTopic = `${discoveryPrefix}/binary_sensor/${packet.id}`

  // Send the discovery message
  let configPayload = `{"name": "${fName}", "uniq_id": "${packet.id}", "stat_t": "${baseTopic}/state", "qos": 1, "pl_on": "open", "pl_off": "closed", "dev_cla": "opening"}`
  client.publish(`${baseTopic}/config`, configPayload, {qos: 1, retain: true})

  console.log(`T: ${baseTopic}/config`)
  console.log(`P: ${configPayload}`)
  console.log('--')
  client.publish(`${baseTopic}/state`, packet.state, {qos: 1, retain: true})
  console.log(`T: ${baseTopic}/state`)
  console.log(`P: ${packet.state}`)
  client.end()
})