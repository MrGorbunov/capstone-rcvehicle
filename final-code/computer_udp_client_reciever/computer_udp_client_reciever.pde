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
import processing.net.*;
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
Knob leftMotorKnob;
Knob rightMotorKnob;
Knob averageMotorKnob;
Knob pickupKnob;
Slider mirrorPanSlider;
Slider mirrorTiltSlider;
Toggle virtualControlToggle;

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

ControlHat dPad;

float xJoy;
float yJoy;
float triggers;

//
// Drive Logic Globals
final double MAX_SPEED = 255; // Gets multiplied by nums on -1 to 1
double joyMagnitude = 0;
boolean spinningInPlace = false;
boolean reverseDirection = false;
boolean cruiseControl = false;

// Actual motor speeds
// _these get sent wirelessly to the esp_
int leftDriveSpeed = 0;   // 0-255
int rightDriveSpeed = 0;  // 0-255
int shovelServoAngle = 0; // 0-360
float avrMotor = 0;
// Pan is side to side, tilt is up & down
float visionPanAngle = 90;   // 0-180
float visionTiltAngle = 90;  // 0-180


//
// Networking Globals 
UDP udpClient;
Client remoteControl;
final String NODE_IP = "192.168.4.1";
// port constant needs to match on the cpp side
final int NODE_PORT = 6969; // Haha funny number
float virtualControl;
String input;
String[] data;

//
// Main Loops
//

void setup() {
  // Establishes the Serial Communication Connection
  myPort  =  new Serial (this, "COM5",  9600);
  myPort.bufferUntil( '\n' );

  // Initial call sets up the screen
  size(600,  500);
  initalizeGui();
  initializeSounds();
  initializeController();  // Order here matters
  
  // Networking
  frameRate(50); // 50 packets (draw calls) / second
  udpClient = new UDP(this, NODE_PORT);
  udpClient.log(true);  // Verbose output, helpful but not necessary
  remoteControl = new Client(this, "192.168.86.27", 12345); // Replace with your server's IP and port

  // Finally, play sound and get things started
  BOOTUP.play();
}

void draw ( ) {
  if(virtualControl == 0.0){
    virtualControl();
    if(!cruiseControl)
      background(186, 252, 3); // This should really go into GUI
    else
      background(115, 187, 255);
    
    initializeControllerReaders();
    readControllerInputs();
    calculateMotorSpeeds();
    //sendPacket();
    // GUI needs a re-write because of how this is working
    updateGui();
  }
  else {
    virtualControl();
    if(!cruiseControl)
      background(186, 252, 3); // This should really go into GUI
    else
      background(115, 187, 255);
    //sendPacket();
    updateGui();
  }
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

void initalizeGui() {
  cp5 = new ControlP5(this);

  // group number 3, contains a bang and a slider
  Group g3 = cp5.addGroup("Drive Information")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(500)
                ;
  
  // Shows the value of the Left Motor
  leftMotorKnob = cp5.addKnob("Left Motor Speed")
    .setRange(0,255)
    .setValue(0)
    .setPosition(30,10)
    .setRadius(50)
    .setDragDirection(Knob.VERTICAL)
    .moveTo(g3)
    ;
    
  // Switch for remote control
  virtualControlToggle = cp5.addToggle("Remote Control")
     .setPosition(175,30)
     .setSize(50,20)
     .setValue(false)
     .setMode(ControlP5.SWITCH)
     .moveTo(g3)
     ;
    
  // Shows the value of the Right Motor
  rightMotorKnob = cp5.addKnob("Right Motor Speed")
    .setRange(0,255)
    .setValue(0)
    .setPosition(270,10)
    .setRadius(50)
    .setDragDirection(Knob.VERTICAL)
    .moveTo(g3)
    ;
  
  // Shows the value of the average motors
  averageMotorKnob = cp5.addKnob("Average Motor Speed")
    .setRange(0,255)
    .setValue(0)
    .setPosition(150, 130)
    .setRadius(50)
    .setDragDirection(Knob.VERTICAL)
    .moveTo(g3)
    ;
  
  // Shows the value of the Pickup Level
  pickupKnob = cp5.addKnob("Pickup Level")
    .setRange(0,180)
    .setValue(0)
    .setPosition(150, 250)
    .setRadius(50)
    .setDragDirection(Knob.VERTICAL)
    .moveTo(g3)
    ;
  
  // Shows the pan angle value
  mirrorPanSlider = cp5.addSlider("Mirror Pan Value")
    .setSize(300, 20)
    .setRange(0, 180)
    .setValue(0)
    .setPosition(13, 390)
    .moveTo(g3)
    ;
    
  // Shows the tilt angle value
  mirrorTiltSlider = cp5.addSlider("Mirror Tilt Value")
    .setSize(300, 20)
    .setRange(0, 180)
    .setValue(0)
    .setPosition(13, 420)
    .moveTo(g3)
    ;
  
  // Allows Menu to Be Collapsed
  accordion = cp5.addAccordion("acc")
                 .setPosition(100,0)
                 .setWidth(400)
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

void updateGui(){
  leftMotorKnob.setValue(leftDriveSpeed);
  rightMotorKnob.setValue(rightDriveSpeed);
  averageMotorKnob.setValue(avrMotor);
  pickupKnob.setValue(shovelServoAngle);
  mirrorPanSlider.setValue(visionPanAngle);
  mirrorTiltSlider.setValue(visionTiltAngle);
  virtualControl = virtualControlToggle.getValue();
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
  // Setup reader with settings in file "Wireless Robot Controls"
  cont = control.getMatchedDevice("Wireless Robot Xbox Controls");
  
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

  yButton = cont.getButton("YBUTTON");
  xButton = cont.getButton("XBUTTON");
  bButton = cont.getButton("BBUTTON");
  aButton = cont.getButton("ABUTTON");

  lBumper = cont.getButton("LBUMPER");
  rBumper = cont.getButton("RBUMPER");
  
  dPad = cont.getHat("MIRRORANGLE");

  xJoy = cont.getSlider("XAXIS2").getValue();
  yJoy = cont.getSlider("YAXIS1").getValue();

  triggers = cont.getSlider("TRIGGERS").getValue() * -1;
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
  if(rBumper.pressed()){
    delay(100);
    cruiseControl = !cruiseControl;
    delay(100);
  }

  //
  // Vision Control
  if(dPad.left()){
    visionPanAngle -= 2.5;
    delay(100);
    if(visionPanAngle <= 0)
      visionPanAngle = 0;
  }else if(dPad.right()){
    visionPanAngle += 2.5;
    delay(100);
    if(visionPanAngle >= 180)
      visionPanAngle = 180;
  }
  else if(dPad.up()){
    visionTiltAngle -= 2.5;
    delay(100);
    if(visionTiltAngle <= 0)
      visionTiltAngle = 0;
  }else if(dPad.down()){
    visionTiltAngle += 2.5;
    delay(100);
    if(visionTiltAngle >= 180)
      visionTiltAngle = 180;
  }


  //
  // Pickup Mechanism
  if(triggers >= 0)
    triggers = triggers + 1;
  else
    triggers =  1 - abs(triggers);
  shovelServoAngle = Math.round((180 * triggers) / 2);
  
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
  if(!cruiseControl){
      leftDriveSpeed = Math.round(abs(yJoy) * 255);
      rightDriveSpeed = Math.round(abs(yJoy) * 255);
      if(xJoy * -1 >= 0.15){
        leftDriveSpeed -= Math.round(abs(xJoy) * 255);
        rightDriveSpeed += Math.round(abs(xJoy) * 255);
        if(leftDriveSpeed < 0)
          leftDriveSpeed = 0;
        else if(rightDriveSpeed > 255)
          rightDriveSpeed = 255;
      }else if(xJoy * -1 <= -0.15){
        leftDriveSpeed += Math.round(abs(xJoy) * 255);
        rightDriveSpeed -= Math.round(abs(xJoy) * 255);
        if(leftDriveSpeed > 255)
          leftDriveSpeed = 255;
        else if(rightDriveSpeed < 0)
          rightDriveSpeed = 0;
      }
  }
  avrMotor = (abs(leftDriveSpeed) + abs(rightDriveSpeed))/ 2;
}

// Virtual Control
void virtualControl(){
  if(virtualControl == 1.0){
    remoteControl.write("Sender" + "\n");
    if (remoteControl.available() > 0) {
      input = remoteControl.readString();
      input = input.substring(0, input.indexOf("\n"));
      data = split(input, ' '); // Split values into an array
    }
    if(data.length > 1){
      if(data[5].equals("a")){
        leftDriveSpeed = int(data[0]);
        rightDriveSpeed = int(data[1]);
        shovelServoAngle = int(data[2]);
        visionPanAngle = int(data[3]);
        visionTiltAngle = int(data[4]);
        avrMotor = (abs(leftDriveSpeed) + abs(rightDriveSpeed))/2;
      }
    }
  }else{
    String msgSend = Integer.toString(leftDriveSpeed) + ' ' + Integer.toString(rightDriveSpeed) + ' ' + Integer.toString(shovelServoAngle) + ' ' + Float.toString(visionPanAngle) + ' '+ Float.toString(visionTiltAngle) + ' ' + "a" + ' ' + "c" + "\n";
    remoteControl.write(msgSend);
   }
}



//
// Networking Methods
//
/*
void sendPacket () {
  ByteBuffer packet = ByteBuffer.allocate(10); // 10 bytes long

  packet.putShort((short) ( constrain(leftDriveSpeed, -255, 255) ));  // drive speeds are from -255 to 255,
  packet.putShort((short) ( constrain(rightDriveSpeed, -255, 255) )); // so we can't just modulo
  packet.putShort((short) (shovelServoAngle % 361));
  packet.putShort((short) (visionPanAngle % 361));
  packet.putShort((short) (visionTiltAngle % 361));

  udpClient.send(packet.array(), NODE_IP, NODE_PORT);
}
*/
