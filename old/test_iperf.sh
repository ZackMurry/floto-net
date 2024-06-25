#!/bin/bash

TARGET="${TARGET:-192.5.87.221}"
IPERF_TIME="${IPERF_TIME:-3}"
SLEEP_TIME="${SLEEP_TIME:-1s}"

echo Testing throughput...

while true
do
   THROUGHPUT=$(iperf3 -c $TARGET -t $IPERF_TIME | tail -3 | head -1 | awk '{print $7" "$8}')
   echo $THROUGHPUT
   #echo $LATENCY >> data.txt
   sleep $SLEEP_TIME
done

