#!/bin/bash

# These need to be configured for each client
IPERF_PORT="${IPERF_PORT:-10001}"
DEVICE_NUMBER="${DEVICE_NUMBER:-0001}"

MQTT_IP="${MQTT_IP:-192.5.87.221}"

PING_TARGET="${PING_TARGET:-google.com}"
SLEEP_TIME="${SLEEP_TIME:-1s}"
IPERF_TIME="${IPERF_TIME:-3}"
IPERF_TIMEOUT=$((IPERF_TIME + 5))

source ./.env.sh
if [ -z "${MQTT_USER}" ] || [ -z "${MQTT_PASSWORD}" ] ; then
  echo "Error: MQTT username and/or password not set! Create a .env.sh file to declare MQTT_USER and MQTT_PASSWORD"
  exit 1
fi

latency_topic="latency/${DEVICE_NUMBER}"
throughput_topic="throughput/${DEVICE_NUMBER}"
packet_loss_topic="packetloss/${DEVICE_NUMBER}"
downtime_topic="downtime/${DEVICE_NUMBER}"

echo "MQTT Broker: $MQTT_IP" 
echo "Iperf3 Server: $MQTT_IP:$IPERF_PORT"
echo "Ping target: $PING_TARGET"
echo "---------------------------------------"
echo "Topics:"
echo "Latency     -> '$latency_topic'"
echo "Throughput  -> '$throughput_topic'"
echo "Packet loss -> '$packet_loss_topic'"
echo "Availability -> '$downtime_topic'"
echo "---------------------------------------"

set -o pipefail

fails=0
first_fail=0


while true
do
  printf \\n
  failed=0

  latency=$(ping -c 3 $PING_TARGET | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
  if [ $? -eq 0 ] ; then
    mosquitto_pub -t $latency_topic -m $latency -h $MQTT_IP -u $MQTT_USER -P $MQTT_PASSWORD
    echo $latency ms to \'$latency_topic\'
  else
    failed=1
    echo "Ping failed!"
  fi

  throughput=$(timeout $IPERF_TIMEOUT iperf3 -c $MQTT_IP -t $IPERF_TIME -p $IPERF_PORT | tail -3 | head -1 | awk '{print $7}')
  if [ $? -eq 0 ] ; then
    mosquitto_pub -t $throughput_topic -m $throughput -h $MQTT_IP -u $MQTT_USER -P $MQTT_PASSWORD
    echo $throughput Mbits/sec to \'$throughput_topic\'
  else
    failed=1
    echo "iperf3 failed"
  fi

  packet_loss=$(ping -c 3 $PING_TARGET | tail -2 | head -1 | awk '{print $6}' | sed 's/.$//')
  if [ $? -eq 0 ] ; then
    mosquitto_pub -t $packet_loss_topic -m $packet_loss -h $MQTT_IP -u $MQTT_USER -P $MQTT_PASSWORD
    echo $packet_loss \% to \'$packet_loss_topic\'
  else
    failed=1
    echo "ping failed (PL)"
  fi

  if [ $failed -eq 1 ] ; then
    if [ $fails -eq 0 ] ; then
      # FIRST_FAIL=$(date +\"%Y-%m-%dT%H:%M:%S%z\")
      echo "Failed to connect!"
      first_fail=$(date +%s%3N)
    fi
    fails=$((fails+1))
  else
    if [ $fails -ne 0 ] ; then
      curr_time=$(date +%s%3N)
      down_time=$((curr_time - first_fail))
      echo Reconnected after $down_time ms and $fails fail\(s\)

      mosquitto_pub -t $downtime_topic -m $down_time -h $MQTT_IP -u $MQTT_USER -P $MQTT_PASSWORD
      echo $down_time ms to \'$downtime_topic\'

      first_fail=0
    fi
    fails=0
  fi
    
  sleep $SLEEP_TIME
done

set +o pipefail

