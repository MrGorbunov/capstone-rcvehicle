/*
Capstone RC-Vehicle Code
Computer UDP Client
Demo Code

This code:
1 - Reads processing inputs
2 - Sends packets over the internet to the server
*/

import processing.net.*;   // Networking
import controlP5.*;        // GUI Library





//
// GUI 
ControlP5 cp5;


//
// Actual motor speeds
// _these get sent wirelessly to the esp_
int leftDriveSpeed = 0;   // -255 to 255
int rightDriveSpeed = 0;  // -255 to 255
int shovelServoAngle = 0; // -255 to 255
// Pan is side to side, tilt is up & down
int visionPanAngle = 0;   // 0-180
int visionTiltAngle = 0;  // 0-180


//
// Networking Globals 
Client c;
// This is literally my home IP, so it's taken at runtime
String SERVER_IP; 
// port constant needs to match on the cpp side
final int SERVER_PORT = 6969;

// Used for user input gathering
boolean firstFrame = true;
char previousKey = 'a';
StringBuilder ipBuilder = new StringBuilder();

boolean gatheringIP = true;
boolean waitingForResponse = true;





//
// Main Loops
//

void setup() {
  // Initial call sets up the screen
  size(1000,  1000);
  background(0);

  frameRate(50); // 50 packets (draw calls) / second

  previousKey = key;
}

void transitionToWait() {
  c = new Client(this, SERVER_IP, SERVER_PORT);
}

void transitionToNormal() {
  initializeGUI();
}



void draw() {
  if (gatheringIP)
     gatherIPLoop();
  else if (waitingForResponse)
     waitForResponseLoop();
  else
     normalLoop(); 
}

void gatherIPLoop() {
  readKeyPresses();

  background(50, 50, 100);
  textSize(50);
  text(ipBuilder.toString(), 10, 200);
}

void waitForResponseLoop() {
  background(100);

  sendPacket();

  if (c.available() > 0) {
    waitingForResponse = false;
    transitionToNormal();
  }
}

void normalLoop() {
  background(10);

  // Value updating is handled by GUI
  sendPacket();
}





//
// Networking Methods
//

void readKeyPresses () {
  if ((key != previousKey) || (keyPressed && firstFrame)) {
    if (key == BACKSPACE) {
      if (ipBuilder.length() > 0)
        ipBuilder.deleteCharAt(ipBuilder.length() - 1); 
    
    } else if (key == ENTER) {
      transitionToWait();
      SERVER_IP = ipBuilder.toString();
      gatheringIP = false;
      
    } else
      ipBuilder.append(key);
  }
  previousKey = key;
  firstFrame = !keyPressed;
}

void sendPacket () {
  // Value sanitization happens on the server
  // (still wouldn't hurt to do it here too)
  c.write(leftDriveSpeed + "," + rightDriveSpeed + "," + shovelServoAngle + "," + visionPanAngle + "," + visionTiltAngle + "\n");
}





//
// GUI Methods
//

void initializeGUI () {
  cp5 = new ControlP5(this);

  cp5.addKnob("shovelServoAngle")
     .setRange(0, 180)
     .setValue(0)
     .setPosition(60, 140)
     .setRadius(100)
     .setDragDirection(Knob.VERTICAL);

  cp5.addKnob("visionPanAngle")
     .setRange(0, 180)
     .setValue(0)
     .setPosition(60, 400)
     .setRadius(100)
     .setDragDirection(Knob.VERTICAL);

  cp5.addKnob("visionTiltAngle")
     .setRange(0, 180)
     .setValue(0)
     .setPosition(60, 660)
     .setRadius(100)
     .setDragDirection(Knob.VERTICAL);

  cp5.addSlider("leftDriveSpeed")
    .setRange(-255, 255)
    .setValue(0)
    .setPosition(460, 80)
    .setSize(100, 800);

  cp5.addSlider("rightDriveSpeed")
    .setRange(-255, 255)
    .setValue(0)
    .setPosition(600, 80)
    .setSize(100, 800);
}
