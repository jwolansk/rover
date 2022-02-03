from machine import Pin
import machine

# Micropython | Board
# 0|D3
# 2|D4 (also Led1 but inverse)*
# 4|D2
# 5|D1
# 9|SD2
# 10|SD3
# 12|D6
# 13|D7
# 14|D5
# 15|D8
# 16|D0 (also Led2 but inverse)*

# right: Motor(0, 5)
# left: Motor(2, 4)


class Motor:

    def __init__(self, forward_pin, enable_pin):
        self.direction = False
        self.forward = 1
        self.backward = 0

        self.pwm_speed = 0
        self.forward_pin = Pin(forward_pin, Pin.OUT)
        self.enable_pin = Pin(enable_pin, Pin.OUT)
        self.enable_pwm = machine.PWM(self.enable_pin)
        self.enable_pwm.freq(500)  # period 2000us

    def set_reversed(self, is_reversed):
        self.forward = 0 if is_reversed else 1
        self.backward = 1 if is_reversed else 0

    def set_speed(self, pwm_speed):
        self.pwm_speed = pwm_speed
        self.set_forward(pwm_speed > 0)

        self.enable_pwm.duty(abs(int(pwm_speed)))

    def set_forward(self, forward):
        if forward:  # forward
            self.forward_pin.value(self.forward)
        else:
            self.forward_pin.value(self.backward)
