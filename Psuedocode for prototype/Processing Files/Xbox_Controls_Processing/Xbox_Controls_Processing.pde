/*
  This code is going to be used to convert the xbox commands into arduino signals
  
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

// Import Statment for GUI Control
import controlP5.*;

// Import statement for Serial Processing
import processing.serial.*;

// Import Statements for Gaming Inputs
import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

// Import Statements for Arduino Compiling and Example Software 
import cc.arduino.*;
import org.firmata.*;

// Game controller variables
ControlDevice cont;
ControlIO control;

// Serial Communication Variable
Serial myPort;

// GUI Control Variables
ControlP5 cp5;
Accordion accordion;

// Speed Variable(used later for GUI only)
float currentMotorSpeed = 128; 

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
  myPort  =  new Serial (this, "COM3",  9600);
  myPort.bufferUntil ( '\n' );
  
  // Sets the canvas size for the color GUI
  size (500,  500);
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

  // create a new accordion
  // add g1, g2, and g3 to the accordion.
  accordion = cp5.addAccordion("acc")
                 .setPosition(94,125)
                 .setWidth(300)
                 .addItem(g3)
                 ;
                 
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(0,1,2);}}, 'o');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.close(0,1,2);}}, 'c');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setWidth(300);}}, '1');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setPosition(0,0);accordion.setItemHeight(190);}}, '2'); 
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.ALL);}}, '3');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.SINGLE);}}, '4');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {cp5.remove("myGroup1");}}, '0');
  
  accordion.open(0,1,2);
  
  // use Accordion.MULTI to allow multiple group 
  // to be open at a time.
  accordion.setCollapseMode(Accordion.MULTI);
  
  // when in SINGLE mode, only 1 accordion  
  // group can be open at a time.  
  // accordion.setCollapseMode(Accordion.SINGLE);
}

void draw ( ) {
  // The background() method has the following parameters(Green, Red, Blue);
  
  // Resets Background
  background(186, 252, 3);
  
  // Defines the button variables for checking status
  ControlButton leftCameraAngle;
  ControlButton rightCameraAngle;
  ControlButton increaseSpeed;
  ControlButton decreaseSpeed;
  ControlButton twoWheel;
  ControlButton fourWheel;
  ControlButton cruiseControlOn;
  ControlButton cruiseControlOff;
  
  // The value of the controller joystick range from -1 to  1
  
  // Reads the value of the Y-Axis on the Xbox Controller
  float forwardReverse = cont.getSlider("forwardreverse").getValue();
  
  // Reads the value of the X-Axis on the Xbox Controller
  float leftRight = cont.getSlider("leftright").getValue();
  
  // Read the value of the Z-Acis(RT/LT) on the Xbox Controller
  float pickup = cont.getSlider("pickup").getValue();
  
  // Read to see what the status of the "X" button on the Xbox Controller
  leftCameraAngle = cont.getButton("leftcameraangle");
  boolean leftCameraAngleStatus = leftCameraAngle.pressed();
  
  // Read to see what the status of the "B" button on the Xbox Controller
  rightCameraAngle = cont.getButton("rightcameraangle");
  boolean rightCameraAngleStatus = rightCameraAngle.pressed();
  
  // Read to see what the status of the "Y" button on the Xbox Controller
  increaseSpeed = cont.getButton("increasespeed");
  boolean increaseSpeedStatus = increaseSpeed.pressed();
  
  // Read to see what the status of the "A" button on the Xbox Controller
  decreaseSpeed = cont.getButton("decreasespeed");
  boolean decreaseSpeedStatus = decreaseSpeed.pressed();
  
  // Read to see what the status of the LB button on the Xbox Controller
  twoWheel = cont.getButton("TwoWheel");
  boolean twoWheelStatus = twoWheel.pressed();
  
  // Read to see what the status of the RB button on the Xbox Controller
  fourWheel = cont.getButton("FourWheel");
  boolean fourWheelStatus = fourWheel.pressed();
  
  // Read to see what the status of the left button underneath Xbox Logo on the Xbox Controller
  cruiseControlOn = cont.getButton("CruiseControlOn");
  boolean cruiseControlOnStatus = cruiseControlOn.pressed();
  
  // Read to see what the status of the right button underneath Xbox Logo on the Xbox Controller
  cruiseControlOff = cont.getButton("CruiseControlOff");
  boolean cruiseControlOffStatus = cruiseControlOff.pressed();
  
  // Updates the GUI
  gui(forwardReverse*-1, leftRight *-1, pickup*-1, currentMotorSpeed/255);
  
  if(forwardReverse > 0.1 && abs(leftRight) < abs(forwardReverse)){  
    myPort.write ( '0' ) ;
  }
  else if(forwardReverse < -0.1 && abs(leftRight) < abs(forwardReverse)){
    myPort.write ( '1' ) ;
  }
  else if(leftRight > 0.1 && abs(leftRight) > abs(forwardReverse)){
    myPort.write ( '2' ) ;
  }
  else if(leftRight < -0.1 && abs(leftRight) > abs(forwardReverse)){
    myPort.write ( '3' ) ;
  }
  else if(pickup > 0.1){
    myPort.write ( '5' ) ;
  }
  else if(pickup < -0.1){
    myPort.write ( '6' ) ;
  }
  else if(leftCameraAngleStatus){
    background (200, 200, 100);
    myPort.write ( '7' ) ;
  }
  else if(rightCameraAngleStatus){
    background (100, 200, 200);
    myPort.write ( '8' ) ;
  }
  else if(increaseSpeedStatus){
    if(currentMotorSpeed <= 255){
      currentMotorSpeed += 5;
    }
    else if(currentMotorSpeed >= 255){
      currentMotorSpeed = 255;
    }
    myPort.write ( '9' ) ;
  }
  else if(decreaseSpeedStatus){
    if(currentMotorSpeed >= 0){
      currentMotorSpeed -= 5;
    }
    else if(currentMotorSpeed <= 0){
      currentMotorSpeed = 0;
    }
    myPort.write ( 'a' ) ;
  }
  else if(twoWheelStatus){
    background (125, 125, 125);
    delay(750);
    myPort.write( 'b' );
  }
  else if(fourWheelStatus){
    background (150, 150, 150);
    delay(750);
    myPort.write( 'c' );
  }
  else if(cruiseControlOnStatus){
    background (225, 225, 0);
    delay(750);
    myPort.write( 'd' );
  }
  else if(cruiseControlOffStatus){
    background (225, 0, 225);
    delay(750);
    myPort.write( 'e' );
  }
  else if(forwardReverse < 0.1 && forwardReverse > -0.1 && leftRight < 0.1 && leftRight > -0.1){
    myPort.write ( '4' ) ;
  }
}
