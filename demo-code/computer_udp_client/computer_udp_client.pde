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
UDP udpClient;
final String NODE_IP = "192.168.4.1";
// port constant needs to match on the cpp side
final int NODE_PORT = 6969; // Haha funny number





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

  // Value updating is handled by GUI

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

