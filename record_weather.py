import sys
import time
from araweather import weather
import paho.mqtt.client as mqtt
from time import sleep


broker = 'ara.zackmurry.com'
port = 80
topic_prefix = 'weather/'
client_id = 'ara-weather'
username = 'zack'
password = 'Caeyah-v6Ahghi2eesho'
interval = 10

sites = ['AgronomyFarm', 'WilsonHall']
measurements = [
    'Humidity',
    'PrecipitationCumulative',
    'RainRate',
    'Pressure',
    'RainRate',
    'Temperature',
    'WindDirection',
    'WindSpeed'
    'RadarReflectivity',
    'MORVisibility',
    'RainIntensity'
]

def connect_mqtt():
    def on_connect(client, userdata, flags, rc, properties):
        if rc == 0:
            print("Connected to MQTT broker")
        else:
            print("Failed to connect, return code %d\n", rc)

    ST_RECONNECT_DELAY = 1
    RECONNECT_RATE = 2
    MAX_RECONNECT_COUNT = 12
    MAX_RECONNECT_DELAY = 60

    def on_disconnect(client, userdata, rc):
        logging.info("Disconnected with result code: %s", rc)
        reconnect_count, reconnect_delay = 0, FIRST_RECONNECT_DELAY
        while reconnect_count < MAX_RECONNECT_COUNT:
            logging.info("Reconnecting in %d seconds...", reconnect_delay)
            time.sleep(reconnect_delay)

            try:
                client.reconnect()
                logging.info("Reconnected successfully!")
                return
            except Exception as err:
                logging.error("%s. Reconnect failed. Retrying...", err)

            reconnect_delay *= RECONNECT_RATE
            reconnect_delay = min(reconnect_delay, MAX_RECONNECT_DELAY)
            reconnect_count += 1
        logging.info("Reconnect failed after %s attempts. Exiting...", reconnect_count)


    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.connect(broker, port)
    sleep(5)
    return client

mq = connect_mqtt()

if __name__ == '__main__':
    print(f'Measurement started. Press Ctrl-C to stop.')
    while True:
        # Extract weather data into a dictionary
        weather_data = weather.get_current_weather(sites)
        #print(weather_data)
        if weather_data:
            for site in sites:
                for measurement in measurements:
                    if measurement in weather_data[site]:
                        mq.publish(f"{topic_prefix}{measurement}/{site}", weather_data[site][measurement])
        else:
            break
        time.sleep(interval)
#    except IndexError:
#        print(f'No measurement time given')
#    except ValueError:
#        print(f'Invalid measurement interval. Interval should be an integer.')
#    except KeyboardInterrupt:
#        print(f'Measurement terminated.')
#    except Exception as e:
#        print(f'Exception: {e}')

