
from ride.motor import Motor


class Rover:

    def __init__(self):
        self.right = Motor(0, 5)
        self.left = Motor(2, 4)
        self.left.set_reversed(True)
        self.speed = 0
        self.turn = 0
        self.left_correction = 10

    def set_speed(self, forward, turn):
        self.speed = forward
        self.turn = turn

        left = forward
        right = forward

        if forward < 10:
            right = right - turn
            left = left + turn
        else:
            if turn > 0:
                right = right - turn / 5
            elif turn < 0:
                left = left + turn / 5
        self.left.set_speed(left)
        self.right.set_speed(right)

    def stop(self):
        self.left.set_speed(0)
        self.right.set_speed(0)