
import network
import time

station = network.WLAN(network.STA_IF)

station.active(True)
station.connect('piratespaceninja', 'attillathehun')

while station.isconnected() == False:
    print('connecting')
    time.sleep(1)

print('Connection successful')
print(station.ifconfig())