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

// RGB LED DP
const int BLUERGBLEDDP = 4;
const int GREENRGBLEDDP = 5;
const int REDRGBLEDDP = 6;

// RGB LED Method Forward Declaration
void changeRGBLEDColor(int, int, int);

// Rear Motors DP
const int LEFTREARMOTORINPUTONE = 9;
const int LEFTREARMOTORINPUTTWO = 10;
const int RIGHTREARMOTORINPUTONE = 11;
const int RIGHTREARMOTORINPUTTWO =  12;

// Front Motor DP
const int FRONTMOTOR = 13;

// Configuration Motor Methods Forward Declaration
void configureMotors(int, int, int);

void setup() {
  // Enables Data Transfer at 9600
  Serial.begin(9600);
  
  // Sets the RGB LED DP to OUTPUT
  pinMode(BLUERGBLEDDP, OUTPUT);
  pinMode(GREENRGBLEDDP, OUTPUT);
  pinMode(REDRGBLEDDP, OUTPUT);

  // Sets the Motor DP to OUTPUT
  pinMode(LEFTREARMOTORINPUTONE, OUTPUT);
  pinMode(LEFTREARMOTORINPUTTWO, OUTPUT);
  pinMode(RIGHTREARMOTORINPUTONE, OUTPUT);
  pinMode(RIGHTREARMOTORINPUTTWO, OUTPUT);
  pinMode(FRONTMOTOR, OUTPUT);
}

void loop() {
  if (Serial.available ( ) > 0) {
    // Sets a variable to the signal from Processing
    char state = Serial.read();
    if(state == '0'){
      changeRGBLEDColor(0, 255, 0);
      configureMotors(driveStyle, 0, joystickValue);
    }
    else if(state == '1'){
      changeRGBLEDColor(255, 0, 0);
      configureMotors(driveStyle, 1, joystickValue);
    }
    else if(state == '2'){
      changeRGBLEDColor(125, 125, 0);
      configureMotors(driveStyle, 2, joystickValue);
    }
    else if(state == '3'){
      changeRGBLEDColor(0, 125, 125);
      configureMotors(driveStyle, 3, joystickValue);
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
      configureMotors(2, 0, joystickValue);
    }
  }
}

// Void method for changing RGB LED color
void changeRGBLEDColor(int redVal, int greenVal, int blueVal){
  analogWrite(BLUERGBLEDDP, blueVal);
  analogWrite(GREENRGBLEDDP, greenVal);
  analogWrite(REDRGBLEDDP, redVal);
}
/*
  Void method for configuring the motors 

  Directory of Drive Style
    1. When 0, it activates Two Wheel Drive
    2. When 1, it activate Four Wheel Drive
    3. When >= 2, it activates Neutral Drive 

  Directory of Drive Direction
    1. When 0, motors go in a forward motion
    2. When 1, motors go in a reverse motion
    3. When 2, motors go in a left motion
    4. When >= 3, motrs go in a right motion
*/
void configureMotors(int driveStyle, int driveDirection, int joystickSpeed){
  // This calculate the speed at which the motors need to run
  int finalSpeed = abs(joystickSpeed * 255)
  
  if(driveStyle  == 0){
    // Ensures that the front motor is off
    analogWrite(FRONTMOTOR,0);
    
    if(driveDirection == 0){
      analogWrite(LEFTREARMOTORINPUTONE,finalSpeed);
      analogWrite(LEFTREARMOTORINPUTTWO,0);
      analogWrite(RIGHTREARMOTORINPUTONE,finalSpeed);
      analogWrite(RIGHTREARMOTORINPUTTWO,0);
    }
    else if(driveDirection == 1){
      analogWrite(LEFTREARMOTORINPUTONE,0);
      analogWrite(LEFTREARMOTORINPUTTWO,finalSpeed);
      analogWrite(RIGHTREARMOTORINPUTONE,0);
      analogWrite(RIGHTREARMOTORINPUTTWO,finalSpeed);
    }
    else if(driveDirection == 2){
      analogWrite(LEFTREARMOTORINPUTONE,finalSpeed);
      analogWrite(LEFTREARMOTORINPUTTWO,0);
      analogWrite(RIGHTREARMOTORINPUTONE,0);
      analogWrite(RIGHTREARMOTORINPUTTWO,0);
    }
    else {
      analogWrite(LEFTREARMOTORINPUTONE,0);
      analogWrite(LEFTREARMOTORINPUTTWO,0);
      analogWrite(RIGHTREARMOTORINPUTONE, finalSpeed);
      analogWrite(RIGHTREARMOTORINPUTTWO,0);
    }
  }
  else if(driveStyle == 1){
    if(driveDirection == 0){
      analogWrite(LEFTREARMOTORINPUTONE,finalSpeed);
      analogWrite(LEFTREARMOTORINPUTTWO,0);
      analogWrite(RIGHTREARMOTORINPUTONE,finalSpeed);
      analogWrite(RIGHTREARMOTORINPUTTWO,0);
      analogWrite(FRONTMOTOR, finalSpeed);
    }
    else if(driveDirection == 1){
      analogWrite(LEFTREARMOTORINPUTONE,0);
      analogWrite(LEFTREARMOTORINPUTTWO,finalSpeed);
      analogWrite(RIGHTREARMOTORINPUTONE,0);
      analogWrite(RIGHTREARMOTORINPUTTWO,finalSpeed);
      analogWrite(FRONTMOTOR,0);
    }
    else if(driveDirection == 2){
      analogWrite(LEFTREARMOTORINPUTONE,finalSpeed);
      analogWrite(LEFTREARMOTORINPUTTWO,0);
      analogWrite(RIGHTREARMOTORINPUTONE,0);
      analogWrite(RIGHTREARMOTORINPUTTWO,0);
      analogWrite(FRONTMOTOR,0);
    }
    else {
      analogWrite(LEFTREARMOTORINPUTONE,0);
      analogWrite(LEFTREARMOTORINPUTTWO,0);
      analogWrite(RIGHTREARMOTORINPUTONE, finalSpeed);
      analogWrite(RIGHTREARMOTORINPUTTWO,0);
      analogWrite(FRONTMOTOR,0);
    }
  }
  else{
    analogWrite(LEFTREARMOTORINPUTONE,0);
    analogWrite(LEFTREARMOTORINPUTTWO,0);
    analogWrite(RIGHTREARMOTORINPUTONE,0);
    analogWrite(RIGHTREARMOTORINPUTTWO,0);
    analogWrite(FRONTMOTOR,0);
  }
}
