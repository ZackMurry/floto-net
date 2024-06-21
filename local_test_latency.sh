#!/bin/bash

TARGET="${TARGET:-google.com}"
SLEEP_TIME="${SLEEP_TIME:-1s}"

echo Testing latency...

while true
do
   LATENCY=$(ping $TARGET -c 3 | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
   echo $LATENCY >> data.txt
   sleep $SLEEP_TIME
done

