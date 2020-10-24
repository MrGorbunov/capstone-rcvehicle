/*

  Servo Controller

  Just testing how to control a servo by Arduino

  Servos are position based. You specify an angle
  and the servos will spin to that angle. The servos
  with the library are limited to a 180 degree range.

  Min angle is 0, max is 180. Putting values above that
  doesn't break the motor but the behaviour is strange.

*/

#include<Servo.h> // Has the servo wrapper



const int PIN_SERVO = 9;

Servo servo;
int pos; // in degrees
const int STEP_DELAY = 50;
const int STEP_ANGLE = 15;



void setup() {
  pinMode(PIN_SERVO, OUTPUT);
  servo.attach(PIN_SERVO);
}

void loop() {
  for (pos=0; pos<180; pos++) {
    servo.write(pos);
    delay(STEP_DELAY);
  }
  delay(500);

  for (pos=180; pos>0; pos--) {
    servo.write(pos);
    delay(STEP_DELAY);
  }
}

