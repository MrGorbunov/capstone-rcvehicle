/*
Capstone RC-Vehicle Code
Computer UDP Client

This code:
1 - Takes in controller inputs
2 - Computes motor speeds for differential drive
3 - Sends packets over UDP to the NodeMCU
(in that order)

At a high level the main loop looks like this:

readControllerInputs()
computeMotorSpeeds()
sendPackets()

Although using global variables does not scale nicely,
because this program is so small, we can get away
with using globals (maybe 40 vars max).

This means we write functions with side effects!!! 
(I.e. they change global variables)
*/

import hypermedia.net.*;    // For networking
import java.nio.ByteBuffer; // Used for packet building
import java.util.Arrays; 

import processing.serial.*; // Arduino interfacing (not necessary)
import cc.arduino.*;
import org.firmata.*;

import net.java.games.input.*; // Controller reading
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

import controlP5.*;        // GUI Library
import processing.sound.*; // Sound (who woulda guessed)





//
// General globals
Serial myPort;


//
// GUI & Sound Globals
ControlP5 cp5;
Accordion accordion;

SoundFile BOOTUP;         // Sounds get loaded in setup
SoundFile GOINGFORWARD;   
SoundFile GOINGBACKWARDS;
SoundFile TURNINGLEFT;
SoundFile TURNINGRIGHT;
SoundFile NEUTRALMODE;


//
// Controller Reading
ControlIO control;
ControlDevice cont;

ControlButton yButton; // Buttons
ControlButton xButton; 
ControlButton bButton;
ControlButton aButton; 

ControlButton lBumper;
ControlButton rBumper;

ControlSlider xJoy;
ControlSlider yJoy;

ControlSlider triggers;




//
// Drive Logic Globals
final double MAX_SPEED = 255; // Gets multiplied by nums on -1 to 1

double joyMagnitude = 0;
double joyXAmount = 0;
boolean spinningInPlace = false;
boolean reverseDirection = false;

// Actual motor speeds
// _these get sent wirelessly to the esp_
int leftDriveSpeed = 0;   // 0-255
int rightDriveSpeed = 0;  // 0-255
int shovelServoAngle = 0; // 0-360
// Pan is side to side, tilt is up & down
int visionPanAngle = 0;   // 0-360
int visionTiltAngle = 0;  // 0-360


//
// Networking Globals 
UDP udpClient;
final String NODE_IP = "192.168.4.1";
// port constant needs to match on the cpp side
final int NODE_PORT = 6969; // Haha funny number





//
// Main Loops
//

void setup() {
  // Establishes the Serial Communication Connection
  myPort  =  new Serial (this, "COM5",  9600);
  myPort.bufferUntil( '\n' );

  // Initial call sets up the screen
  size(500,  500);
  gui(0, 0, 0, 0);
  initializeSounds();

  initializeController();  // Order here matters
  initializeControllerReaders();
  
  // Networking
  frameRate(50); // 50 packets (draw calls) / second
  udpClient = new UDP(this, NODE_PORT);
  udpClient.log(true);  // Verbose output, helpful but not necessary



  // Finally, play sound and get things started
  BOOTUP.play();
  delay(3000);
}

void draw ( ) {
  background(186, 252, 3); // This should really go into GUI

  readControllerInputs();
  calculateMotorSpeeds();
  sendPacket();

  // GUI needs a re-write because of how this is working
  gui(forwardReverse*-1, leftRight *-1, pickup*-1, currentMotorSpeed/255);
}





//
// GUI Methods
//

void initializeSounds () {
  BOOTUP = new SoundFile(this, "BOOTUPSOUND.wav");
  GOINGFORWARD = new SoundFile(this, "GOINGFORWARD.wav");
  GOINGBACKWARDS = new SoundFile(this, "GOINGBACKWARDS.wav");
  TURNINGLEFT = new SoundFile(this, "TURNLEFT.wav");
  TURNINGRIGHT = new SoundFile(this, "TURNRIGHT.wav");
  NEUTRALMODE = new SoundFile(this, "NEUTRALMODE.wav");
}

void gui(float forwardReverse, float leftRight, float pickup, float currentMotorSpeed) {
  cp5 = new ControlP5(this);

  // group number 3, contains a bang and a slider
  Group g3 = cp5.addGroup("Controller Information")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(150)
                ;
  
  // Shows the value of the Y - Axis| Forward and Reverse Directiom
  cp5.addSlider("Forward and Reverse")
     .setPosition(60,20)
     .setSize(100,20)
     .setRange(-1,1)
     .setValue(forwardReverse)
     .moveTo(g3)
     ;
  
  // Shows the value of the X-Axis| Left and Right Direction
  cp5.addSlider("Left and Right")
     .setPosition(60,50)
     .setSize(100,20)
     .setRange(-1, 1)
     .setValue(leftRight)
     .moveTo(g3)
     ;
   
  // Shows the value of the LT/RT| Pickup Servo Level
  cp5.addSlider("Pickup")
    .setPosition(60,80)
    .setSize(100, 20)
    .setRange(-1, 1)
    .setValue(pickup)
    .moveTo(g3)
    ;
  
  // Shows the value of the LT/RT| Pickup Servo Level
  cp5.addSlider("Motor Speed")
    .setPosition(60,110)
    .setSize(100, 20)
    .setRange(0, 1)
    .setValue(currentMotorSpeed)
    .moveTo(g3)
    ;
  
  // Allows Menu to Be Collapsed
  accordion = cp5.addAccordion("acc")
                 .setPosition(94,125)
                 .setWidth(300)
                 .addItem(g3)
                 ;
                 
  // Some GUI Code(I copied form online)              
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(0,1,2);}}, 'o');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.close(0,1,2);}}, 'c');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setWidth(300);}}, '1');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setPosition(0,0);accordion.setItemHeight(190);}}, '2'); 
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.ALL);}}, '3');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.SINGLE);}}, '4');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {cp5.remove("myGroup1");}}, '0');
  
  // Allows one section to be open at a time
  accordion.open(0,1,2);
  accordion.setCollapseMode(Accordion.SINGLE);
}





//
// Reading Controller & Motor Speed Logic
//

/**
 * Initializes the controller instance, and exits
 * the program if no valid instance is found
 */
void initializeController () {
  // Find controller
  control = ControlIO.getInstance(this);
  // Setup reader with settings in file "Xbox Controller Settings"
  cont = control.getMatchedDevice("Xbox Controller Settings");
  
  if (cont == null) {
    println("Error connecting with controller");
    System.exit(-1);
  }
}

/**
 * Initializes ControllerButton & ControllerSlider classes,
 * because doing so in the draw call is suboptimal.
 */
void initializeControllerReaders () {
  /*
    Hardware Inputs

    Y, X, B, & A Button
    ---
    The 4 buttons on the controller are fairly straightforward,
    just remember it's an XBox cont so buttons are:
                        Y
                      X   B
                        A


    LB & RB Button
    ---
    Lastly, the top 2 bumped buttons are RightBumper (RB) & LeftBumped (LB)


    XAxis & YAxis
    ---
    Joystick has X & Y axese, corresponding to where the
    joystick is pointed. Both values are confined to a 
    circle, i.e. x^2 + y^2 <= 1 AND magnitude is meaningful.


    ZAxis
    ---
    Left & Right triggers do something weird, wherein they add
    together. Right trigger = -1, Left trigger = +1. If both are
    held down the ZAxis returns 0. Note this does return inbetween
    values (ex: 0.6).
  */

  yButton = cont.getButton("YButton");
  xButton = cont.getButton("XButton");
  bButton = cont.getButton("BButton");
  aButton = cont.getButton("AButton");

  lBumper = cont.getButton("LBButton");
  rBumper = cont.getButton("RBButton");

  xJoy = cont.getSlider("XAxis");
  yJoy = cont.getSlider("YAxis");

  triggers = cont.getSlider("ZAxis");

  // This means that values on -0.1 to 0.1 are read in as 0s
  xJoy.setTolerance(0.1);
  yJoy.setTolerance(0.1);
  triggers.setTolerance(0.1);
}



/**
 * Converts the raw controller values into higher level
 * variables, which get converted to motor speeds in
 * calculateMotorSpeeds
 */
void readControllerInputs () {
  /*
     Control Scheme
     ---
     Drive Logic  -  Joystick, A Button
  */

  //
  // Drive Logic
  double joyX = xJoy.getValue();
  double joyY = yJoy.getValue();

  if (joyY <= 0)
    spinningInPlace = true;
  joyXAmount = joyX;
  joyMagnitude = sqrt((float) (joyX*joyX + joyY*joyY));
  reverseDirection = aButton.pressed();

  // And imma leave everything else to you Aryan <3
  //
  // Vision Control



  //
  // Pickup Mechanism

}



/**
 * Determines the actual motor values based on the higher
 * level globals set in readControllerInputs()
 */
void calculateMotorSpeeds () {
  /*
    Drive Logic
    -----------
    The joystick's top & bottom halfs operate very differently
    and so are split up.

    The top half of the joystick does what you'd expect, driving
    the vehicle forward while turning. The more to the right
    or left the more intense the turn.

    The bottom half of the joystick however, turns in place,
    and as you pull the joystick closer and closer to the bottom (0, -1),
    the rate of turning slows down.

    This allows for fine tuning for turning in place AND for driving forward.
  */

  if (spinningInPlace) {
    double spinSpeed = joyXAmount;
    // Parentheses keep the cast as the last operation, prevents rounding errors
    int motorSpeed = (int) (MAX_SPEED * spinSpeed * joyMagnitude);

    // Spinning in place, so both sides spin opposite each other
    leftDriveSpeed = motorSpeed;
    rightDriveSpeed = -motorSpeed;

  } else {
    /*
      With this differential drive, the faster motor stays at 
      a constant speed while the slower motor changes from 
      speed to -speed, as the turn intensity increases.
    */
    double spinAmount = abs((float) joyXAmount);
    // TODO: Test this mapping
    double slowerWheelTurnSpeed = map((float) spinAmount, 0f, 1f, (float) MAX_SPEED, (float) -MAX_SPEED);

    boolean clockwise = joyXAmount > 0;
    double speed = joyMagnitude * MAX_SPEED;

    if (clockwise) {
      leftDriveSpeed = (int) speed;
      rightDriveSpeed = (int) slowerWheelTurnSpeed;
    } else {
      rightDriveSpeed = (int) speed;
      leftDriveSpeed = (int) slowerWheelTurnSpeed;
    }
  }

  /*
    To reverse direction, make the motor speeds negative
  */
  if (reverseDirection) {
    leftDriveSpeed *= -1;
    rightDriveSpeed *= -1;
  }



  /*
     Vision Logic
     ------------



   */





  /*
     Pickup Logic
     ------------



   */

}





//
// Networking Methods
//

void sendPacket () {
  ByteBuffer packet = ByteBuffer.allocate(10); // 10 bytes long

  packet.putShort((short) ( constrain(leftDriveSpeed, -255, 255) ));  // drive speeds are from -255 to 255,
  packet.putShort((short) ( constrain(rightDriveSpeed, -255, 255) )); // so we can't just modulo
  packet.putShort((short) (shovelServoAngle % 361));
  packet.putShort((short) (visionPanAngle % 361));
  packet.putShort((short) (visionTiltAngle % 361));

  udpClient.send(packet.array(), NODE_IP, NODE_PORT);
}
