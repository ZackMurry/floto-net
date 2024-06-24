#!/bin/bash

MQTT_IP="${MQTT_IP:-192.5.87.221}"

LATENCY_TOPIC="${LATENCY_TOPIC:-latency}"
THROUGHPUT_TOPIC="${THROUGHPUT_TOPIC:-throughput}"
PACKET_LOSS_TOPIC="${PACKET_LOSS_TOPIC:-packetloss}"
AVAILABILITY_TOPIC="${AVAILABILITY_TOPIC:-downtime}"

PING_TARGET="${PING_TARGET:-google.com}"
SLEEP_TIME="${SLEEP_TIME:-1s}"
IPERF_TIME="${IPERF_TIME:-3}"
IPERF_TIMEOUT=$((IPERF_TIME + 5))

echo Sending messages to $IP and pings to $PING_TARGET...
echo "Topics:"
echo "Latency     -> 'latency'"
echo "Throughput  -> 'throughput'"
echo "Packet loss -> 'packetloss'"
echo "Availability -> 'downtime'"

set -o pipefail

FAILS=0
FIRST_FAIL=0

while true
do
  printf \\n
  FAILED=0

  LATENCY=$(ping $PING_TARGET -c 3 | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
  if [ $? -eq 0 ] ; then
    mosquitto_pub -t $LATENCY_TOPIC -m $LATENCY -h $MQTT_IP
    echo $LATENCY ms to \'$LATENCY_TOPIC\'
  else
    FAILED=1
    echo "Ping failed!"
  fi

  THROUGHPUT=$(timeout $IPERF_TIMEOUT iperf3 -c $MQTT_IP -t $IPERF_TIME | tail -3 | head -1 | awk '{print $7}')
  if [ $? -eq 0 ] ; then
    mosquitto_pub -t $THROUGHPUT_TOPIC -m $THROUGHPUT -h $MQTT_IP
    echo $THROUGHPUT Mbits/sec to \'$THROUGHPUT_TOPIC\'
  else
    FAILED=1
    echo "iperf3 failed"
  fi

  PACKET_LOSS=$(ping $PING_TARGET -c 3 | tail -2 | head -1 | awk '{print $6}' | sed 's/.$//')
  if [ $? -eq 0 ] ; then
    mosquitto_pub -t $PACKET_LOSS_TOPIC -m $PACKET_LOSS -h $MQTT_IP
    echo $PACKET_LOSS \% to \'$PACKET_LOSS_TOPIC\'
  else
    FAILED=1
    echo "ping failed (PL)"
  fi

  if [ $FAILED -eq 1 ] ; then
    if [ $FAILS -eq 0 ] ; then
      # FIRST_FAIL=$(date +\"%Y-%m-%dT%H:%M:%S%z\")
      echo "Failed to connect!"
      FIRST_FAIL=$(date +%s%3N)
    fi
    FAILS=$((FAILS+1))
  else
    if [ $FAILS -ne 0 ] ; then
      CURR_TIME=$(date +%s%3N)
      DOWN_TIME=$((CURR_TIME - FIRST_FAIL))
      echo Reconnected after $DOWN_TIME ms and $FAILS fail\(s\)

      mosquitto_pub -t $AVAILABILITY_TOPIC -m $DOWN_TIME -h $MQTT_IP
      echo $DOWN_TIME ms to \'$AVAILABILITY_TOPIC\'

      FIRST_FAIL=0
    fi
    FAILS=0
  fi
    
  sleep $SLEEP_TIME
done

set +o pipefail

