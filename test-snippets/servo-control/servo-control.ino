/*

  Servo Controller

  Just testing how to control a servo by Arduino

  Servos are position based. You specify an angle
  and the servos will spin to that angle. The servos
  with the library are limited to a 180 degree range.

  Min angle is 0, max is 180. All inputs are clamped
  to that range. 
   - 200, 360, 400 are treated as 180 deg
   - negativea are treated as 0 deg

*/

#include<Servo.h> // Has the servo wrapper



const int PIN_SERVO = 9;

Servo servo;
int pos; // in degrees
const int STEP_DELAY = 50;
const int STEP_ANGLE = 15;



void setup() {
  pinMode(PIN_SERVO, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  servo.attach(PIN_SERVO);
}

void loop() {
  for (pos=0; pos<90; pos++) {
    servo.write(pos);
    delay(STEP_DELAY);
  }

  delay(500);
  // The servo treats 200 as 180
  servo.write(200);
  delay(500);
  // 370 = 180
  servo.write(370);
  delay(500);

  digitalWrite(LED_BUILTIN, HIGH);
  // -30 = 0 deg
  servo.write(-30);
  delay(500);
  digitalWrite(LED_BUILTIN, LOW);

  delay(1000);
}
