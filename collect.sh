#!/bin/bash

MQTT_IP=192.5.87.221

source ./.env.sh
if [ -z "${MQTT_USER}" ] || [ -z "${MQTT_PASSWORD}" ] ; then
  echo "Error: MQTT username and/or password not set! Create a .env.sh file to declare MQTT_USER and MQTT_PASSWORD"
  exit 1
fi

mkdir data -p

mosquitto_sub -h $MQTT_IP -t "#" -u $MQTT_USER -P $MQTT_PASSWORD -v | while read -r message; do
  echo "Message: $message"
  topic=$(echo $message | awk '{print $1}')
  payload=$(echo $message | awk '{print $2}')
  echo "Received message $payload on topic $topic"
  topic_file="data/${topic}.txt"
  if [[ $topic = downtime* ]] then # 
    echo -n "$(date +%s) " >> $topic_file
  fi
  echo $payload >> $topic_file
done

