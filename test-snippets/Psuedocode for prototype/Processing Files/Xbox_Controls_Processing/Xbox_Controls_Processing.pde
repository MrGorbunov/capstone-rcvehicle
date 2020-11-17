/*
  This code is going to be used to convert the xbox commands into arduino signals
  
  Here is a directory of the commands 
  1. Left Joystick Y Value - Forward/Reverse
  2. Left Joystick X Value - Left/Right
  3. RT/LT Value - Pickup 
  4. "X"/"B" Value - Cruise Control Off/On
  5. "Y"/"A" Value - IncreaseSpeed/DecreaseSpeed
  6. LB/RB - Two Wheel Drive/Four Wheel Drive
*/

// Import Statements for Serial Processing
import processing.serial.*;

// Import Statements for Arduino Compiling and Example Software 
import cc.arduino.*;
import org.firmata.*;

// Import Statements for Gaming Inputs
import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

// Import Statements for GUI Control
import controlP5.*;

// Import Statements for Sounds
import processing.sound.*;

// Networking Import Statement
import hypermedia.net.*;

// Import Statement for Java Arrays
import java.util.Arrays;
import java.nio.ByteBuffer;

// Serial Communication Variable
Serial myPort;

// Game controller variables
ControlDevice cont;
ControlIO control;

// Controller Button Variables
ControlButton increaseSpeed;
ControlButton decreaseSpeed;
ControlButton twoWheel;
ControlButton fourWheel;
ControlButton cruiseControlOn;
ControlButton cruiseControlOff;

// Current Drive Mode Variable(Used only for sound processing)
int driverMode = 5;

// Controller Value Holder Global Form
int forwardReverse;
int leftRight;
int pickup;
boolean increaseSpeedStatus;
boolean decreaseSpeedStatus;
boolean twoWheelStatus;
boolean fourWheelStatus;
boolean cruiseControlOnStatus;
boolean cruiseControlOffStatus;

// Speed Variable
int currentMotorSpeed = 128; 

// Drive Style Mode Variable -- When 0 then 4 wheel and when 1 then 2 wheel
int driveStyle = 0;

// Cruise Control Mode Variable -- When 0 then Off and when 1 then on
int cruiseControl = 0;

// GUI Control Variables
ControlP5 cp5;
Accordion accordion;

// Sound Control Variables
SoundFile BOOTUP;
SoundFile GOINGFORWARD;
SoundFile GOINGBACKWARDS;
SoundFile TURNINGLEFT;
SoundFile TURNINGRIGHT;
SoundFile NEUTRALMODE;

// Networking globals (port constant just needs to match on the cpp side)
UDP udpClient;
final String NODE_IP = "192.168.4.1";
final int NODE_PORT = 6969;

void setup ( ) {
  // Instantiates the controller 
  control = ControlIO.getInstance(this);
  
  // Looks for control file and reads the commands
  cont = control.getMatchedDevice("Xbox Controller Settings");
  
  // Makes sure that if there are any errors with the controller to terminate the code
  if (cont == null) {
    println("not today chump");
    System.exit(-1);
  }
  
  // Establishes the Serial Communication Connection
  myPort  =  new Serial (this, "COM5",  9600);
  myPort.bufferUntil ( '\n' );
  
  // Sets the canvas size for the color GUI
  size (500,  500);
  
  // Sets up the audio files
  BOOTUP = new SoundFile(this, "BOOTUPSOUND.wav");
  GOINGFORWARD = new SoundFile(this, "GOINGFORWARD.wav");
  GOINGBACKWARDS = new SoundFile(this, "GOINGBACKWARDS.wav");
  TURNINGLEFT = new SoundFile(this, "TURNLEFT.wav");
  TURNINGRIGHT = new SoundFile(this, "TURNRIGHT.wav");
  NEUTRALMODE = new SoundFile(this, "NEUTRALMODE.wav");
  
  // Sets up the intial GUI
  gui(0, 0, 0, 0);
  
  // 50 packets / second
  frameRate(50);
  
  // Networking
  udpClient = new UDP(this, NODE_PORT);
  udpClient.log(true); 
  
  // Plays boot up noice
  BOOTUP.play();
  delay(3000);
} 

// Control the GUI Configuration
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

void draw ( ) {
  // The background() method has the following parameters(Green, Red, Blue);
  
  // Resets Background
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
  sendPacket();
}

// Networking Methods
void sendPacket () {
  ByteBuffer packet = ByteBuffer.allocate(10); // 10 bytes long
  packet.putShort((short) (forwardReverse % 256));  // 255 is max value, so %256
  packet.putShort((short) (leftRight % 256));
  packet.putShort((short) (pickup % 256));
  packet.putShort((short) (currentMotorSpeed % 256));
  packet.putShort((short) (driveStyle % 2));
  packet.putShort((short) (cruiseControl % 2));
  
  udpClient.send(packet.array(), NODE_IP, NODE_PORT);
}
