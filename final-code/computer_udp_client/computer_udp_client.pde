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

SoundFile BOOTUP;         // Sounds get loaded in setup()
SoundFile GOINGFORWARD;
SoundFile GOINGBACKWARDS;
SoundFile TURNINGLEFT;
SoundFile TURNINGRIGHT;
SoundFile NEUTRALMODE;


//
// Controller Reading
ControlDevice cont;
ControlIO control;

ControlButton increaseSpeed;
ControlButton decreaseSpeed;
ControlButton twoWheel;
ControlButton fourWheel;
ControlButton cruiseControlOn;
ControlButton cruiseControlOff;


//
// Drive Logic Globals
int driverMode = 5;

int forwardReverse; // Command-esque inputs
int leftRight;
int pickup;
boolean increaseSpeedStatus = false;
boolean decreaseSpeedStatus = false;
boolean twoWheelStatus = true;
boolean fourWheelStatus = false;
boolean cruiseControlOnStatus = false;
boolean cruiseControlOffStatus = true;

int currentMotorSpeed = 128; // Control variables
int driveStyle = 0;    // 0 = 4wd, 1 = 2wd
int cruiseControl = 0; // 0 = off, 1 = on

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
  myPort.bufferUntil ( '\n' );


  // Initial call sets up the screen
  size (500,  500);
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
  
  
  // Networking
  frameRate(50); // 50 packets (draw calls) / second
  udpClient = new UDP(this, NODE_PORT);
  udpClient.log(true);  // Verbose output, not necessary
  

  // Finally, play sound to get things started
  BOOTUP.play();
  delay(3000);
}

void draw ( ) {
  background(186, 252, 3);
  
  // The value of the controller joystick range from -1 to  1
  
  // Reads the value of the Y-Axis on the Xbox Controller
  forwardReverse = Math.round(cont.getSlider("YAxis").getValue()* -255);

  // Reads the value of the X-Axis on the Xbox Controller
  leftRight = Math.round(cont.getSlider("YAxis").getValue()* -255);
  
  // Read the value of the Z-Axis(RT/LT) on the Xbox Controller
  pickup = Math.round(cont.getSlider("ZAxis").getValue()* -255);
  
  // Read to see what the status of the "Y" button on the Xbox Controller
  increaseSpeed = cont.getButton("YButton");
  increaseSpeedStatus = increaseSpeed.pressed();
  
  // Read to see what the status of the "A" button on the Xbox Controller
  decreaseSpeed = cont.getButton("AButton");
  decreaseSpeedStatus = decreaseSpeed.pressed();
  
  // Read to see what the status of the LB button on the Xbox Controller
  twoWheel = cont.getButton("LBButton");
  twoWheelStatus = twoWheel.pressed();
  
  // Read to see what the status of the RB button on the Xbox Controller
  fourWheel = cont.getButton("RBButton");
  fourWheelStatus = fourWheel.pressed();
  
  // Read to see what the status of the left button underneath Xbox Logo on the Xbox Controller
  cruiseControlOn = cont.getButton("XButton");
  cruiseControlOnStatus = cruiseControlOn.pressed();
  
  // Read to see what the status of the right button underneath Xbox Logo on the Xbox Controller
  cruiseControlOff = cont.getButton("BButton");
  cruiseControlOffStatus = cruiseControlOff.pressed();
  
  // Updates the GUI
  gui(forwardReverse*-1, leftRight *-1, pickup*-1, currentMotorSpeed/255);
  
  if(forwardReverse > 0.1 && abs(leftRight) < abs(forwardReverse)){  
    if(driverMode != 0){
      GOINGFORWARD.play();
      driverMode = 0;
    }
  }
  else if(forwardReverse < -0.1 && abs(leftRight) < abs(forwardReverse)){
    if(driverMode != 1){
      GOINGBACKWARDS.play();
      driverMode = 1;
    }
  }
  else if(leftRight > 0.1 && abs(leftRight) > abs(forwardReverse)){
    if(driverMode != 2){
      TURNINGRIGHT.play();
      driverMode = 2;
    }
  }
  else if(leftRight < -0.1 && abs(leftRight) > abs(forwardReverse)){
    if(driverMode != 3){
      TURNINGLEFT.play();
      driverMode = 3;
    }
  }
  else if(forwardReverse < 0.1 && forwardReverse > -0.1 && leftRight < 0.1 && leftRight > -0.1){
    if(driverMode != 4){
      NEUTRALMODE.play();
      driverMode = 4;
    }
  }
  if(increaseSpeedStatus){
    background(100, 100, 100);
    if(currentMotorSpeed <= 255){
      currentMotorSpeed += 5;
    }
    else if(currentMotorSpeed >= 255){
      currentMotorSpeed = 255;
    }
  }
  else if(decreaseSpeedStatus){
    background(200, 200, 200);
    if(currentMotorSpeed >= 0){
      currentMotorSpeed -= 5;
    }
    else if(currentMotorSpeed <= 0){
      currentMotorSpeed = 0;
    }
  }
  if(twoWheelStatus){
    background (125, 125, 125);
    driveStyle = 1;
  }
  else if(fourWheelStatus){
    background (150, 150, 150);
    driveStyle = 0;
  }
  if(cruiseControlOnStatus){
    background (225, 225, 0);
    cruiseControl = 1;
  }
  else if(cruiseControlOffStatus){
    background (225, 0, 225);
    cruiseControl = 0;
  }
  // readControllerInputs();
  // calculateMotorSpeeds();
  sendPacket();
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



