/*
Capstone RC-Vehicle Code
Computer UDP Client
Demo Code

This code:
1 - Reads processing inputs
2 - Sends packets over UDP to the NodeMCU

At a high level the main loop looks like this:
*/

import hypermedia.net.*;    // For networking
import java.nio.ByteBuffer; // Used for packet building
import java.util.Arrays; 

import controlP5.*;        // GUI Library





//
// Networking Globals 
UDP udpClient;
final String NODE_IP = "192.168.4.1";
// port constant needs to match on the cpp side
final int NODE_PORT = 6969; // Haha funny number


//
// Actual motor speeds
// _these get sent wirelessly to the esp_
int leftDriveSpeed = 0;   // -255 to 255
int rightDriveSpeed = 0;  // -255 to 255

final int SHOVEL_MAX = 170; // As a matter of hardware safety
final int SHOVEL_MIN = 10;  // the full range is not used
int shovelServoAngle = SHOVEL_MIN;

// Pan is side to side, tilt is up & down
final int PAN_MAX = 170;
final int PAN_MIN = 10;
int visionPanAngle = (PAN_MIN + PAN_MAX) / 2;

final int TILT_MAX = 150;
final int TILT_MIN = 60;
int visionTiltAngle = TILT_MAX;


//
// User Input & PID controls 
final float P_COEF = 0.2;
final int MIN_ADJUSTMENT_DELTA = 1; // adj = adjustment
final int MIN_ABSOLUTE_DELTA = 1;
// TODO: Do a derivative based controller for trapezoidal profile
final int MAX_ADJUSTMENT_DELTA = 15;

final int TURN_SPEED = 30;
final int TURN_IN_PLACE_SPEED = 150;
boolean turnInPlace = false;
int targetLeftMotorSpeed = 0;
int targetRightMotorSpeed = 0;
int driveSpeed = 0;
int turn = 0; // -255 = left, 0 = straight, 255 = right


// Servo values are stored directly within globals
// from 'Actual motor speeds'
final int SHOVEL_SPEED = 1;
final int PAN_SPEED = 1;
final int TILT_SPEED = 1;
int targetShovel = 0;
int targetPan = 0;
int targetTilt = 80; // 60-150


//
// GUI Variables
ControlP5 cp5;

// These values get updated by the GUI
int GUILeftDriveSpeed = leftDriveSpeed;
int GUIRightDriveSpeed = rightDriveSpeed;
int GUIShovelServo = shovelServoAngle;
// Pan is side to side, tilt is up & down
int GUIVisionPan = visionPanAngle;
int GUIVisionTilt = visionTiltAngle;















//
// Main Loops
//

void setup() {
  // Initial call sets up the screen
  size(1000,  1000);
  background(0);

  // Networking
  frameRate(50); // 50 packets (draw calls) / second
  udpClient = new UDP(this, NODE_PORT);
  udpClient.log(false);  // Verbose output, helpful but not necessary

  // GUI setup
  initializeGUI();
}

void draw ( ) {
  background(10);

  // GUI Updating is handled by processKeyboardInput
  processKeyboardInput();
  checkGUIValuesForChanges();

  doPIDLogic();

  sendPacket();
}











//
// Networking Methods
//

void sendPacket () {
  ByteBuffer packet = ByteBuffer.allocate(10); // 10 bytes long

  packet.putShort((short) ( constrain(leftDriveSpeed, -255, 255) + 255));  // drive speeds are from -255 to 255, but 
  packet.putShort((short) ( constrain(rightDriveSpeed, -255, 255) + 255)); // sending negatives in packets is a pain
  packet.putShort((short) (shovelServoAngle % 361));                        // so the esp code does - 255 of what it recieves
  packet.putShort((short) (visionPanAngle % 361));
  packet.putShort((short) (visionTiltAngle % 361));

  udpClient.send(packet.array(), NODE_IP, NODE_PORT);

  // System.out.println("Sent packet: " + shovelServoAngle);
}













//
// Taking User Input
//

/*
User Input Scheme
=================
Arrow Keys -> Steering
 - Left/Right > Rotation
 - Up/Down > Forward Backwards

WASD -> Vision
 - A/D > Pan (left & right)
 - W/S > Tilt (up & down)

Q&E -> Shovel
 - Q > Bring Shovel Down
 - E > Lift Shovel Up
*/

void processKeyboardInput () {
  if (keyPressed) {
    if (key == CODED) {
      // Non-letter inputs (shift, alt, etc)
      // see https://processing.org/reference/key.html

      if (keyCode == UP)
        driveSpeed = 255;
      else if (keyCode == DOWN)
        driveSpeed = -255;
      else if (keyCode == LEFT)
        turn = -255;
      else if (keyCode == RIGHT)
        turn = 255;
    } else {
      // Pan
      if (key == 'd')
        targetPan = PAN_MAX;
      else if (key == 'a')
        targetPan = PAN_MIN;

      // Tilt
      else if (key == 'w')
        targetTilt = TILT_MAX;
      else if (key == 's')
        targetTilt = TILT_MIN;

      // Shovel
      else if (key == 'e')
        targetShovel = SHOVEL_MAX;
      else if (key == 'q')
        targetShovel = SHOVEL_MIN;

      // Drive control
      else if (key == 't')
        turnInPlace = !turnInPlace;
    }
  } else {
    // This should all reset once buttons are no longer down
    driveSpeed = 0;
    turn = 0;

    // We want servos to freeze in place after adjustment
    targetPan = visionPanAngle;
    targetTilt = visionTiltAngle;
    targetShovel = shovelServoAngle;
  }
}











//
// PID Logic
//

void doPIDLogic () {
  //
  // Vision + Shovel (servos)
  int newShovelAngle = constController(shovelServoAngle, targetShovel, SHOVEL_SPEED);
  int newPanAngle = constController(visionPanAngle, targetPan, PAN_SPEED);
  int newTiltAngle = constController(visionTiltAngle, targetTilt, TILT_SPEED);
  setShovelServoAngle(newShovelAngle);
  setVisionPanAngle(newPanAngle);
  setVisionTiltAngle(newTiltAngle);

  //
  // Driving Control
  if (turnInPlace)
    setMotorTargetsTurningInPlace();
  else
    setMotorTargetsNormally();

  int newLeftSpeed = propController(leftDriveSpeed, targetLeftMotorSpeed);
  int newRightSpeed = propController(rightDriveSpeed, targetRightMotorSpeed);
  setLeftDriveSpeed(newLeftSpeed);
  setRightDriveSpeed(newRightSpeed);
}


void setMotorTargetsTurningInPlace () {
  int actualTurn = turn;

  if (Math.abs(turn) >= TURN_IN_PLACE_SPEED) {
    if (turn > 0)
      actualTurn = TURN_IN_PLACE_SPEED;
    else
      actualTurn = -TURN_IN_PLACE_SPEED;
  }

  targetLeftMotorSpeed = actualTurn;
  targetRightMotorSpeed = -actualTurn;
}


void setMotorTargetsNormally () {
  /*
    Driving and Turning at the same time 
    ------------------------------------
    If turn is at extremes (-255 or 255), then that
    means that one motor goes to max and the other
    is stationary.

    No motor will ever go against the motorSpeed.

    This means that determining motorSpeeds is actually
    very simple. The motor that is supposed to go forward
    is set to driveSpeed, and mulyiply the other by
    (255 - |turn|) / 255.
  */

  int turnMotorSpeed = (int) (driveSpeed * (255.0 - (float) Math.abs(turn)) / 255.0);

  if (turn < 0) {
    // Turn Left
    targetRightMotorSpeed = driveSpeed;
    targetLeftMotorSpeed = turnMotorSpeed;
  } else {
    // Turn Right
    targetRightMotorSpeed = turnMotorSpeed;
    targetLeftMotorSpeed = driveSpeed;
  }
}


/**
 * Does logic for a proportional controller,
 * returning what the new value should be.
 *
 * Tuned with global PID constants
 */
int propController (int value, int target) {
  // absolute as in without scaling. absolute =/= absolute value
  int absoluteDelta = target - value; 
  if (Math.abs(absoluteDelta) <= MIN_ABSOLUTE_DELTA) {
    return target;
  }

  int adjDelta = (int) (P_COEF * ((float) absoluteDelta));
  if (Math.abs(adjDelta) <= MIN_ADJUSTMENT_DELTA) {
    if (absoluteDelta < 0)
      adjDelta = -MIN_ADJUSTMENT_DELTA;
    else
      adjDelta = MIN_ADJUSTMENT_DELTA;
  } else if (Math.abs(adjDelta) >= MAX_ADJUSTMENT_DELTA) {
    if (absoluteDelta < 0)
      adjDelta = -MAX_ADJUSTMENT_DELTA;
    else
      adjDelta = MAX_ADJUSTMENT_DELTA;
  }

  return value + adjDelta;
}


/**
 * Moves in the the direction of target by CON_COEF
 * every call, or by the difference if its less than CON_COEF.
 */
int constController (int value, int target, int delta) {
  int diff = target - value;

  if (Math.abs(diff) < delta)
    return target;

  if (diff < 0)
    return value - delta;
  else
    return value + delta;
}












//
// GUI Methods
//

void setLeftDriveSpeed (int speed) {
  if (speed < -255 || speed > 255)
    throw new IllegalArgumentException("Speed of left motor must be within -255 to 255. Cannot be " + speed);
  
  leftDriveSpeed = speed;
  GUILeftDriveSpeed = speed;
  cp5.getController("GUILeftDriveSpeed").changeValue(speed);
}

void setRightDriveSpeed (int speed) {
  if (speed < -255 || speed > 255)
    throw new IllegalArgumentException("Speed of right motor must be within -255 to 255. Cannot be " + speed);
  
  rightDriveSpeed = speed;
  GUIRightDriveSpeed = speed;
  cp5.getController("GUIRightDriveSpeed").changeValue(speed);
}

void setShovelServoAngle (int angle) {
  if (angle < SHOVEL_MIN || angle > SHOVEL_MAX)
    throw new IllegalArgumentException("Illegal Shovel Servo angle. Cannot be " + angle);
  
  shovelServoAngle = angle;
  GUIShovelServo = angle;
  cp5.getController("GUIShovelServo").changeValue(angle);
}

void setVisionPanAngle (int angle) {
  if (angle < PAN_MIN || angle > PAN_MAX)
    throw new IllegalArgumentException("Illegal Vision Pan Servo angle. Cannot be " + angle);
  
  visionPanAngle = angle;
  GUIVisionPan = angle;
  cp5.getController("GUIVisionPan").changeValue(angle);
}

void setVisionTiltAngle (int angle) {
  if (angle < TILT_MIN || angle > TILT_MAX)
    throw new IllegalArgumentException("Illegal Vision Tilt Servo angle. Cannot be " + angle);
 
  visionTiltAngle = angle;
  GUIVisionTilt = angle;
  cp5.getController("GUIVisionTilt").changeValue(angle);
}


void checkGUIValuesForChanges () {
  // Basically, these two values only ever de-sync when the values
  // are updated via the GUI. If they're updated by the setters
  // then they stay in sync.

  if (GUILeftDriveSpeed != leftDriveSpeed)
    setLeftDriveSpeed(GUILeftDriveSpeed);
  if (GUIRightDriveSpeed != rightDriveSpeed)
    setRightDriveSpeed(GUIRightDriveSpeed);

  if (GUIShovelServo != shovelServoAngle)
    setShovelServoAngle(GUIShovelServo);

  if (GUIVisionPan != visionPanAngle)
    setVisionPanAngle(GUIVisionPan);
  if (GUIVisionTilt != visionTiltAngle)
    setVisionTiltAngle(GUIVisionTilt);
}


void initializeGUI () {
  cp5 = new ControlP5(this);

  // addKnob parameters are dummy because they're handled by
  // the above methods;
  cp5.addKnob("GUIShovelServo") 
     .setLabel("Shovel Servo")
     .setRange(SHOVEL_MIN, SHOVEL_MAX)
     .setValue(GUIShovelServo)
     .setPosition(60, 140)
     .setRadius(100)
     .setDragDirection(Knob.VERTICAL);

  cp5.addKnob("GUIVisionPan")
     .setLabel("Vision Pan")
     .setRange(PAN_MIN, PAN_MAX)
     .setValue(GUIVisionPan)
     .setPosition(60, 400)
     .setRadius(100)
     .setDragDirection(Knob.VERTICAL);

  cp5.addKnob("GUIVisionTilt")
     .setLabel("Vision Tilt")
     .setRange(TILT_MIN, TILT_MAX)
     .setValue(GUIVisionTilt)
     .setPosition(60, 660)
     .setRadius(100)
     .setDragDirection(Knob.VERTICAL);

  cp5.addSlider("GUILeftDriveSpeed")
    .setLabel("Left Drive Speed")
    .setRange(-255, 255)
    .setValue(0)
    .setPosition(460, 80)
    .setSize(100, 800);

  cp5.addSlider("GUIRightDriveSpeed")
    .setLabel("Right Drive Speed")
    .setRange(-255, 255)
    .setValue(0)
    .setPosition(600, 80)
    .setSize(100, 800);
}

