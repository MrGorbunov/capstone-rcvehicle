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
const int BLUERGBLEDDP = 3;
const int GREENRGBLEDDP = 5;
const int REDRGBLEDDP = 6;

// RGB LED Method Forward Declaration
void changeRGBLEDColor(int, int, int);

void setup() {
  // Enables Data Transfer at 9600
  Serial.begin(9600);
  
  // Sets the RGB LED DP to OUTPUT
  pinMode(BLUERGBLEDDP, OUTPUT);
  pinMode(GREENRGBLEDDP, OUTPUT);
  pinMode(REDRGBLEDDP, OUTPUT);
}

void loop() {
  if (Serial.available ( ) > 0) {
    // Sets a variable to the signal from Processing
    char state = Serial.read();
    if(state == '0'){
      changeRGBLEDColor(0, 255, 0);
    }
    else if(state == '1'){
      changeRGBLEDColor(255, 0, 0);
    }
    else if(state == '2'){
      changeRGBLEDColor(125, 125, 0);
    }
    else if(state == '3'){
      changeRGBLEDColor(0, 125, 125);
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
    }
  }
}

void changeRGBLEDColor(int redVal, int greenVal, int blueVal){
  analogWrite(BLUERGBLEDDP, blueVal);
  analogWrite(GREENRGBLEDDP, greenVal);
  analogWrite(REDRGBLEDDP, redVal);
}
