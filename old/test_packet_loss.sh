#!/bin/bash

TARGET="${TARGET:-google.com}"
SLEEP_TIME="${SLEEP_TIME:-1s}"

echo Testing latency...

while true
do
   PACKET_LOSS=$(ping $TARGET -c 3 | tail -2 | head -1 | awk '{print $6}')
   echo $PACKET_LOSS
   sleep $SLEEP_TIME
done

