set -o nounset

DEVICE="0187"
SLEEP_TIME="5s"
MQTT_HOST="192.5.87.221"

source ./.env.sh
if [ -z "${MQTT_USER}" ] || [ -z "${MQTT_PASSWORD}" ] ; then
  echo "Error: MQTT username and/or password not set! Create a .env.sh file to declare MQTT_USER and MQTT_PASSWORD"
  exit 1
fi

while true
do
  lat="42.013684772642655"
  lon="-93.65109325197827"

  mosquitto_pub -t location/$DEVICE -m "{\"lat\": $lat, \"lon\": $lon}" -h $MQTT_HOST -u $MQTT_USER -P $MQTT_PASSWORD
  echo "Position: $lat, $lon"

  sleep $SLEEP_TIME
done

