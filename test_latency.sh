#!/bin/bash

IP="${IP:-129.114.34.225}"
TOPIC="${TOPIC:-latency}"
TARGET="${TARGET:-google.com}"
SLEEP_TIME="${SLEEP_TIME:-10s}"

echo Sending messages to $IP on topic \'$TOPIC\'...

while true
do
   LATENCY=$(ping $TARGET -c 3 | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
   mqtt pub -t $TOPIC -m $LATENCY -h $IP
   echo Published $LATENCY ms to \'$TOPIC\'
   sleep $SLEEP_TIME
done

