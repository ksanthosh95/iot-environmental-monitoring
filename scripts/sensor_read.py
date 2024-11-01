#This file should be placed in the pico w with name "main.py" to auto start.
import network
import time
import dht
import machine
from umqtt.simple import MQTTClient  # This should now work without error

# DHT11 setup
sensor = dht.DHT11(machine.Pin(15))  # Use GPIO 15 for data pin

# LED setup (built-in LED on GPIO 25)
led = machine.Pin("LED", machine.Pin.OUT)

# Wi-Fi setup //both your server and the pico w should be connected in the same network.
ssid = 'YourWifiName'
password = 'YourWifiPassword'

# MQTT setup
mqtt_server = '192.168.31.183'  # Replace with your Raspberry Pi 5 IP
client_id = 'pico_w_dht11'
topic_pub_temp = 'sensor/dht11/temperature'
topic_pub_humidity = 'sensor/dht11/humidity'

# Connect to Wi-Fi
def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect(ssid, password)

    while wlan.isconnected() == False:
        print('Connecting to Wi-Fi...')
        time.sleep(1)
    
    print('Connected to Wi-Fi')
    print(wlan.ifconfig())

# MQTT publish function
def mqtt_connect():
    client = MQTTClient(client_id, mqtt_server, port=1883)
    client.connect()
    print(f'Connected to {mqtt_server} MQTT broker')
    return client

# Blink the LED
def blink_led(dur_ms):
    led.on()  # Turn on the LED
    time.sleep(dur_ms)  # Keep it on for 'dur_ms' milliseconds
    led.off()  # Turn off the LED

# Read DHT11 and publish data
def read_and_publish(client):
    while True:
        try:
            sensor.measure()
            temp = sensor.temperature()
            humidity = sensor.humidity()

            # Publish to MQTT broker
            client.publish(topic_pub_temp, str(temp))
            client.publish(topic_pub_humidity, str(humidity))

            print(f'Temperature: {temp}Â°C, Humidity: {humidity}%')

            # Blink LED to indicate successful data publish
            blink_led(0.2)  # Blink for 200ms to show successful publish
            #time.sleep(1)

        except OSError as e:
            print(f'Failed to read sensor: {e}')

        time.sleep(10)  # Adjust delay for how often to send data

# Main execution
try:
    connect_wifi()
    client = mqtt_connect()
    read_and_publish(client)
except KeyboardInterrupt:
    print('Script interrupted')
