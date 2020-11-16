# Capstone Remote Control Vehicle

This is the code base (Arduino sketches) for the Capstone
RC project.

## Final Design Specs

### Packet Design
The libraries allow us to easily send over byte arrays over a UDP protocol. Specically, we can safely send 23 byte packets 50 times a second. 

These packets contain motor speeds, and because we only have to send data for 5 motors, all speeds can fit on one packet (1-2 bytes per motor). The packets being sent over the network look like this:

[Motor-Left, Motor-Right, Shovel-Servo, Shovel-Servo, Vision-Pan, Vision-Pan, Vision-Tilt, Vision-Tilt, ...]

-- or --

| byte index  |  motor |
| :------- | :-------- |
| 0 & 1 | Drive-left |
| 2 & 3 | Drive-right |
| 4 & 5 | Shovel-Servo |
| 6 & 7 | Vision-Pan |
| 8 & 9 | Vision-Tilt |

Although a short is technically overkill for the data ranges, it's good to allow for easier handling of negatives. Since packets are big enough, it'll simplify the coding (I don't really want to touch bit operations).



## Guidelines
**All Arduino code must be in files in their own folders**. This is because
the Arduino IDE only recognizes the code if its in its own folder. Processing
sketches or other miscellanous work ofc doesn't need to follow this rule.

Follow the pattern! If folders are named lowercase-with-dashes, make new folders in
the format of lowercase-with-dashes. We want one codebase, not a code mutant (*Sorry
that's a bad analogy*)

Generally prefer code that requires memorizing less. Write functions that check for
bad input and debug appropiately, prefer using enums instead of a state int, etc.

Producing code formatting guidelines would not be useful though, since we're a small
team & only writing 1000 lines max.


## Controller Requirements
### Xbox Controller
 - Signal/ pairing button
 - R & L Trigger
 - R & L Bumpers
 - L3 & R3 buttons
 - Menu & Windows button
 - D-Pad
 - 4 Letters (X, Y, A, B)
 - 2 Joysticks
 - Vibrator ;)

### Ideal Functionality
 - Driving direction
 - Forward & Reverse
 - Toggle / use pickup mechanism
 - Camera angle changing
 - Spinning in place
 - Some sort of speed control

### Mapping Functionality to xBox buttons
 - Driving direction -> Joystick
 - Forward vs reverse -> Button toggle
 - Spinning in place -> Button toggle, with direction from joystick (driving direction)
 - Toggle / use pickup mechanism -> Button? Depends on the mechanism honestly
 - Camera angle changing -> D-Pad L & R
 - Some sort of speed control -> D-Pad Up = faster, D-Pad Down = slower

### Robot Controller Bare Minimum
 1 Driving direction (Joystick)

 1 Forward & reverse
 
 1 Pickup Mechanism 

 2 Spinning in place (Button toggle for new driving mode)

 3 Camera angle changing

 4 Speed control - speed up & down

