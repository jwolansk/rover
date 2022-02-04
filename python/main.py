from ride.umqttsimple import MQTTClient
from ride.rover import Rover
import ubinascii
import machine
import time
import json
import esp
esp.osdebug(None)
import gc
gc.collect()

mqtt_server = '192.168.1.253'
client_id = ubinascii.hexlify(machine.unique_id())
topic_sub = b'rover/ride/set'
topic_pub = b'rover/ride'

last_message = 0
message_interval = 5

rover = Rover()

def sub_cb(topic, msg):
    print((topic, msg))
    if topic == topic_sub:
        try:
            data = json.loads(msg)
            if "speed" in data and "turn" in data:
                rover.set_speed(data["speed"], data["turn"])
                notify_status()
        except ValueError as e:
            print(e)

def connect_and_subscribe():
    global client_id, mqtt_server, topic_sub
    client = MQTTClient(client_id, mqtt_server)
    client.set_callback(sub_cb)
    client.connect()
    client.subscribe(topic_sub)
    print('Connected to %s MQTT broker, subscribed to %s topic' % (mqtt_server, topic_sub))
    return client

def restart_and_reconnect():
    print('Failed to connect to MQTT broker. Reconnecting...')
    time.sleep(10)
    machine.reset()

def notify_status():
    msg = b'{"speed": %d, "turn": %d}' % (rover.speed, rover.turn)
    client.publish(topic_pub, msg)

try:
    client = connect_and_subscribe()

    while True:
        try:
            client.check_msg()
            if (time.time() - last_message) > message_interval:
                notify_status()
                last_message = time.time()
        except OSError as e:
            restart_and_reconnect()

except OSError as e:
    restart_and_reconnect()
