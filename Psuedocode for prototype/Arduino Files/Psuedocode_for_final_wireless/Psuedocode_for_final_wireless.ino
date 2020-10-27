/*
  This code is going to be used to convert the serial signals to output by the Arduino

  Here is a directory of the commands 
  1. Left Joystick Y Value - Forward/Reverse
  2. Left Joystick X Value - Left/Right
  3. RT/LT Value - Pickup 
  4. "X"/"B" Value - LeftCameraAngle/RightCameraAngle
  5. "Y"/"A" Value - IncreaseSpeed/DecreaseSpeed
  
  Here is a directory of the Serial Inputs
  1. "0" - Go forward
  2. "1" - Go backwards
  3. "2" - Go left
  4. "3" - Go right
  5. "4" - Go to neutral
  6. "5" - Pickup item from floor
  7. "6" - Throw item into containment area
  8. "7" - Move camera to the left
  9. "8" - Move camera to the right
  10. "9" - Increase speed
  11. "a" - Decrease speed

  Note - I left Serial Command "4" last to make sure that it doesn't get triggered all the time
*/

// RGB LED needs 3 pins
const int PIN_RGBLED_BLUE = 4;
const int PIN_RGBLED_GREEN = 5;
const int PIN_RGBLED_RED = 6;

void changeRGBLEDColor(int, int, int);

// Motors pins
const int PIN_LEFTREARMOTORINPUTONE = 9;
const int PIN_LEFTREARMOTORINPUTTWO = 10;
const int PIN_RIGHTREARMOTORINPUTONE = 11;
const int PIN_RIGHTREARMOTORINPUTTWO =  12;
const int PIN_FRONTMOTOR = 13;

void actuateMotors(int, int, int);



//
// Control flow
//

void setup() {
  // Enables Data Transfer at 9600
  Serial.begin(9600);
  
  // Sets the RGB LED DP to OUTPUT
  pinMode(PIN_RGBLED_BLUE, OUTPUT);
  pinMode(PIN_RGBLED_GREEN, OUTPUT);
  pinMode(PIN_RGBLED_RED, OUTPUT);

  // Sets the Motor DP to OUTPUT
  pinMode(PIN_LEFTREARMOTORINPUTONE, OUTPUT);
  pinMode(PIN_LEFTREARMOTORINPUTTWO, OUTPUT);
  pinMode(PIN_RIGHTREARMOTORINPUTONE, OUTPUT);
  pinMode(PIN_RIGHTREARMOTORINPUTTWO, OUTPUT);
  pinMode(PIN_FRONTMOTOR, OUTPUT);
}

void loop() {
  if (Serial.available ( ) > 0) {
    // Sets a variable to the signal from Processing
    char state = Serial.read();
    if(state == '0'){
      changeRGBLEDColor(0, 255, 0);
      actuateMotors(driveStyle, 0, joystickValue);
    }
    else if(state == '1'){
      changeRGBLEDColor(255, 0, 0);
      actuateMotors(driveStyle, 1, joystickValue);
    }
    else if(state == '2'){
      changeRGBLEDColor(125, 125, 0);
      actuateMotors(driveStyle, 2, joystickValue);
    }
    else if(state == '3'){
      changeRGBLEDColor(0, 125, 125);
      actuateMotors(driveStyle, 3, joystickValue);
    }
    else if(state == '5'){
      changeRGBLEDColor(255, 255, 0);
    }
    else if(state == '6'){
      changeRGBLEDColor(0, 255, 255);
    }
    else if(state == '7'){
      changeRGBLEDColor(100, 125, 125);
    }
    else if(state == '8'){
      changeRGBLEDColor(125, 125, 100);
    }
    else if(state == '9'){
      changeRGBLEDColor(125, 100, 100);
    }
    else if(state == 'a'){
      changeRGBLEDColor(100, 100, 125);
    }
    else if(state == '4'){
      changeRGBLEDColor(0, 0, 0);
      actuateMotors(2, 0, joystickValue);
    }
  }
}



//
// LED
//

// Void method for changing RGB LED color
void changeRGBLEDColor(int redVal, int greenVal, int blueVal){
  analogWrite(PIN_RGBLED_BLUE, blueVal);
  analogWrite(PIN_RGBLED_GREEN, greenVal);
  analogWrite(PIN_RGBLED_RED, redVal);
}



//
// Motor Methods
//

/*
  Void method for actuating the motors

  Drive Style
    0 => Two Wheel Drive
    1 => Four Wheel Drive
    2 => Neutral Drive 

  Drive Direction
    0 => go forward
    1 => go reverse
    2 => go left
    3 => go right

  driveSpeed
    Must be on range [-255, 255]
    Determines the speed of driving
*/
void actuateMotors(int driveStyle, int driveDirection, int driveSpeed){
  // Signage of speed is controlled by driveDirection
  int finalSpeed = abs(driveSpeed)
  
  if(driveStyle  == 0){
    actuateTwoWheelDrive(driveDiretion, finalSpeed);
  }
  else if(driveStyle == 1){
    actuateFourWheelDrive(driveDirection, finalSpeed);
  }
  else{
    actuateNeutralDrive(driveDirection);
  }
}

void actuateTwoWheelDrive (int driveDirection, int speed) {
  // Ensures that the front motor is off
  analogWrite(PIN_FRONTMOTOR,0);
  
  if(driveDirection == 0){
    analogWrite(PIN_LEFTREARMOTORINPUTONE,speed);
    analogWrite(PIN_LEFTREARMOTORINPUTTWO,0);
    analogWrite(PIN_RIGHTREARMOTORINPUTONE,speed);
    analogWrite(PIN_RIGHTREARMOTORINPUTTWO,0);
  }
  else if(driveDirection == 1){
    analogWrite(PIN_LEFTREARMOTORINPUTONE,0);
    analogWrite(PIN_LEFTREARMOTORINPUTTWO,speed);
    analogWrite(PIN_RIGHTREARMOTORINPUTONE,0);
    analogWrite(PIN_RIGHTREARMOTORINPUTTWO,speed);
  }
  else if(driveDirection == 2){
    analogWrite(PIN_LEFTREARMOTORINPUTONE,speed);
    analogWrite(PIN_LEFTREARMOTORINPUTTWO,0);
    analogWrite(PIN_RIGHTREARMOTORINPUTONE,0);
    analogWrite(PIN_RIGHTREARMOTORINPUTTWO,0);
  }
  else {
    analogWrite(PIN_LEFTREARMOTORINPUTONE,0);
    analogWrite(PIN_LEFTREARMOTORINPUTTWO,0);
    analogWrite(PIN_RIGHTREARMOTORINPUTONE,speed);
    analogWrite(PIN_RIGHTREARMOTORINPUTTWO,0);
  }
}

void actuateFourWheelDrive (int driveDirection, int speed) {
  if(driveDirection == 0){
    analogWrite(PIN_LEFTREARMOTORINPUTONE,speed);
    analogWrite(PIN_LEFTREARMOTORINPUTTWO,0);
    analogWrite(PIN_RIGHTREARMOTORINPUTONE,speed);
    analogWrite(PIN_RIGHTREARMOTORINPUTTWO,0);
    analogWrite(PIN_FRONTMOTOR, finalSpeed);
  }
  else if(driveDirection == 1){
    analogWrite(PIN_LEFTREARMOTORINPUTONE,0);
    analogWrite(PIN_LEFTREARMOTORINPUTTWO,speed);
    analogWrite(PIN_RIGHTREARMOTORINPUTONE,0);
    analogWrite(PIN_RIGHTREARMOTORINPUTTWO,speed);
    analogWrite(PIN_FRONTMOTOR,0);
  }
  else if(driveDirection == 2){
    analogWrite(PIN_LEFTREARMOTORINPUTONE,speed);
    analogWrite(PIN_LEFTREARMOTORINPUTTWO,0);
    analogWrite(PIN_RIGHTREARMOTORINPUTONE,0);
    analogWrite(PIN_RIGHTREARMOTORINPUTTWO,0);
    analogWrite(PIN_FRONTMOTOR,0);
  }
  else {
    analogWrite(PIN_LEFTREARMOTORINPUTONE,0);
    analogWrite(PIN_LEFTREARMOTORINPUTTWO,0);
    analogWrite(PIN_RIGHTREARMOTORINPUTONE, speed);
    analogWrite(PIN_RIGHTREARMOTORINPUTTWO,0);
    analogWrite(PIN_FRONTMOTOR,0);
  }
}

void actuateNeutralDrive (int driveDirection) {
  analogWrite(PIN_LEFTREARMOTORINPUTONE,0);
  analogWrite(PIN_LEFTREARMOTORINPUTTWO,0);
  analogWrite(PIN_RIGHTREARMOTORINPUTONE,0);
  analogWrite(PIN_RIGHTREARMOTORINPUTTWO,0);
  analogWrite(PIN_FRONTMOTOR,0);
}

