# Capstone Remote Control Vehicle

This is the code base (Arduino sketches) for the Capstone
RC project.

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

