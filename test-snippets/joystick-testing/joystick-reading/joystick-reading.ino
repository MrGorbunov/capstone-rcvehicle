/**

  Joystick Testing

  This program reads x & y inputs from joystick and just 
  prints them out.

  There ~~is~~ will be an accompanying Processing sketch that will
  graph it. The processing sketch is not in this same dir.
*/

const byte PIN_X = A0;
const byte PIN_Y = A1;
// Switch is a boolean, but its voltage is not correct
// to trigger digital pin so instead an analog is used.
// Some kind of Elec 1 solution would free up the analog pin.
const byte PIN_SWITCH = A2;
const int SWITCH_THRESHOLD = 10; // when pressed, analog goes to 0, so this allows for some tolerance

const int samplePeriod = 50;
int switchDown;
int x, y;



void setup() {
  Serial.begin(9600);
  Serial.println();

  // Analog pins don't require pinMode()
}

void loop() {
  x = analogRead(PIN_X);
  y = analogRead(PIN_Y);
  switchDown = 0;
  if (analogRead(PIN_SWITCH) < SWITCH_THRESHOLD)
    switchDown = 1;

  Serial.print(x);
  Serial.print(",");
  Serial.print(y);
  Serial.print(",");
  Serial.println(switchDown);

  delay(samplePeriod);
}
