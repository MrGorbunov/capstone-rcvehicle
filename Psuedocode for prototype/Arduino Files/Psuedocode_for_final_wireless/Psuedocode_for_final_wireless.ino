/*
  This code is going to be used to convert the serial signals to output by the Arduino
  
  Here is a directory of the commands 
  1. Left Joystick Y Value - Forward/Reverse
  2. Left Joystick X Value - Left/Right
  3. RT/LT Value - Pickup 
  4. "X"/"B" Value - LeftCameraAngle/RightCameraAngle
  5. "Y"/"A" Value - IncreaseSpeed/DecreaseSpeed
  6. LB/RB - Two Wheel Drive/Four Wheel Drive
  7. The buttons underneath XBOX Logo(Left & Right) - Cruise control on/off
  
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
  12. "b" - Two Wheel Drive
  13. "c" - Four Wheel Drive
  14. "d" - Cruise Control On
  15. "e" - Cruise Control Off

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
void configureMotors(int, int, int, bool);

// Global status variables
int motorSpeed = 127.5;
int driveStyle = 0;
bool cruiseControl = false;

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
      configureMotors(driveStyle, 0, motorSpeed, cruiseControl);
    }
    else if(state == '1'){
      configureMotors(driveStyle, 1, motorSpeed, cruiseControl);
    }
    else if(state == '2'){
      configureMotors(driveStyle, 2, motorSpeed, cruiseControl);
    }
    else if(state == '3'){
      configureMotors(driveStyle, 3, motorSpeed, cruiseControl);
    }
    else if(state == '5'){
    }
    else if(state == '6'){
    }
    else if(state == '7'){
    }
    else if(state == '8'){
    }
    else if(state == '9'){
      if(motorSpeed >= 0){
        motorSpeed -= 5;
      }
      else if(motorSpeed <= 0){
        motorSpeed = 0;
      }
    }
    else if(state == 'a'){
      if(motorSpeed <= 255){
        motorSpeed -= 5;
      }
      else if(motorSpeed >= 255){
        motorSpeed = 255;
      }
    }
    else if(state == 'b'){
      driveStyle = 0;
    }
    else if(state == 'c'){
      driveStyle = 1;
    }
    else if(state == 'd'){
      cruiseControl = true;
    }
    else if(state == 'e'){
      cruiseControl = false;
    }
    else if(state == '4'){
      configureMotors(2, 0, motorSpeed, cruiseControl);
    }
  }
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

   Note - When cruise control is on, the robot continues to follow in the direction it was before without Joystick Input
*/
void configureMotors(int driveStyle, int driveDirection, int joystickSpeed, bool cruiseControl){
  // This calculate the speed at which the motors need to run
  int finalSpeed = abs(joystickSpeed * 255);
  
  if(!cruiseControl){
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
  else{
      analogWrite(LEFTREARMOTORINPUTONE,finalSpeed);
      analogWrite(LEFTREARMOTORINPUTTWO,0);
      analogWrite(RIGHTREARMOTORINPUTONE,finalSpeed);
      analogWrite(RIGHTREARMOTORINPUTTWO,0);
      analogWrite(FRONTMOTOR, finalSpeed);
  }
}
