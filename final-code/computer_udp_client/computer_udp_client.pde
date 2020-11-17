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

double joyAngle = 0;
double joyMagnitude = 0;
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

  BOOTUP = new SoundFile(this, "BOOTUPSOUND.wav");
  GOINGFORWARD = new SoundFile(this, "GOINGFORWARD.wav");
  GOINGBACKWARDS = new SoundFile(this, "GOINGBACKWARDS.wav");
  TURNINGLEFT = new SoundFile(this, "TURNLEFT.wav");
  TURNINGRIGHT = new SoundFile(this, "TURNRIGHT.wav");
  NEUTRALMODE = new SoundFile(this, "NEUTRALMODE.wav");


  // Find controller
  control = ControlIO.getInstance(this);
  // Setup reader with settings in file "Xbox Controller Settings"
  cont = control.getMatchedDevice("Xbox Controller Settings");
  
  if (cont == null) {
    println("Error connecting with controller");
    System.exit(-1);
  }

  initializeControllerReaders();
  
  
  // Networking
  frameRate(50); // 50 packets (draw calls) / second
  udpClient = new UDP(this, NODE_PORT);
  udpClient.log(true);  // Verbose output, not necessary
  

  // Finally, play sound to get things started
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
}

void calculateMotorSpeeds () {


}





//
// Networking Methods
//

void sendPacket () {
  ByteBuffer packet = ByteBuffer.allocate(10); // 10 bytes long

  packet.putShort((short) (leftDriveSpeed % 256));  // 255 is max value, so %256
  packet.putShort((short) (rightDriveSpeed % 256));
  packet.putShort((short) (shovelServoAngle % 361));
  packet.putShort((short) (visionPanAngle % 361));
  packet.putShort((short) (visionTiltAngle % 361));

  udpClient.send(packet.array(), NODE_IP, NODE_PORT);
}



