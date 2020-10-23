/**

  Joystick Testing

  This program reads x & y inputs from joystick and just 
  prints them out.

  There ~~is~~ will be an accompanying Processing sketch that will
  graph it. The processing sketch is not in this same dir.
*/

const byte PIN_X = A0;
const byte PIN_Y = A1;
const byte PIN_SWITCH = 4;

const int samplePeriod = 1000;
int switchDown;
int x, y;



void setup() {
  Serial.begin(9600);
  Serial.println();

  pinMode(PIN_SWITCH, INPUT);
  // Analog pins don't require pinMode()
}

void loop() {
  x = analogRead(PIN_X);
  y = analogRead(PIN_Y);
  switchDown = digitalRead(PIN_SWITCH);

  Serial.print(x);
  Serial.print(",");
  Serial.print(y);
  Serial.print(",");
  Serial.println(switchDown);

  delay(samplePeriod);
}
