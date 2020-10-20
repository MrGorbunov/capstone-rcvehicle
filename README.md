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

