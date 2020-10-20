/**

  Driver Control

  This code contains the logic for converting driver input
  into motor rotation. Physically, we can rotate the wheels
  on both sides seperately, i.e. tank control. However, when
  controlling the vehicle it can be more natural to do arcade
  control or something similar. That's what this code does.

  Specifically, there are 2 control modes.
  ARCADE_DRIVE
    The car will drive forward, and turn left or right
    while doing so. Similar to driving a car.

  PIVOT
    The car will remain in one location and rotate or pivot
    in place. This is achieved by having the two sides rotate
    equal and opposite.

  Because the physical controller is not yet built, I am
  assuming that we will have a joystick input and a button.
  The joystick will be used for direction & strength, while
  the button will toggle between the two control modes.

*/



// Controller Inputs
int xInput; // on range [-255, 255]
int yInput;
boolean buttonPressed;

// Movement Tuning
const double speedCoef = 0.2;
const double arcadeDriveMaxDiff = 0.7; // Rotation speed in arcade drive
const double rotationCoef = 0.5;
const double maxSpeed = 5;

const double rotationThreshold = 0.1; // Amount of input rotation before rotation actually begins happening.




//
// Physical Funcitons
//

// These guys aren't implemented because they're specific to how input & motor control will work
// Speed is presumed to be on [-1, 1]
void spinLeftMotor(double speed) { }

void spinRightMotor(double speed) { }

// Reads controller input, then updates xInput, yInput, buttonPressed
void readInputAndUpdateVars() { }






//
// Flow logic
//

void setup() {
  // Just to avoid initialization errors
  xInput = 0;
  yInput = 0;
  buttonPressed = false;
}

void loop() {
  readInputAndUpdateVars();

  if (buttonPressed)
    movePivot();
  else
    moveArcadeDrive();
}






//
// Control Modes
//

void movePivot() {
  // xInput = 0  =>  no rotatoin
  // xInput = -255  =>  counter clockwise
  // xInput = 255  =>  clockwise
  int rotationAmount = xInput * rotationCoef;

  if (abs(rotationAmount) < rotationThreshold)
      return;

  // Equal & opposite = rotating in place
  spinRightMotor(rotationAmount);
  spinLeftMotor(-rotationAmount);
}

void moveArcadeDrive() {
  double inputSpeed = sqrt(xInput * xInput + yInput * yInput) * speedCoef;

  // If inputDirection is completey to the left or right,
  // the vehicle should still drive forward.
  // So, one of the sides is simply slower, but non-0, meaning
  // that the vehicle still drives forward.

  // As rotationAmount increases, rotSpeedDifference increases
  // because one motor is getting slower and slower.
  double rotationAmount = xInput * rotationCoef;
  double rotSpeedDifference = rotationAmount * arcadeDriveMaxDiff;

  double rightSpeed = inputSpeed;
  double leftSpeed = -inputSpeed;

  // Counter clockwise
  if (rotationAmount < -rotationThreshold)
    leftSpeed *= 1 - rotSpeedDifference;
  // Clockwise
  else if (rotationAmount > rotationThreshold)
    rightSpeed *= 1 - rotSpeedDifference;
  
  spinRightMotor(rightSpeed);
  spinLeftMotor(leftSpeed);
}

