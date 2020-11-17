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
Accordion accordion;




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
  size(500,  500);

  // Networking
  frameRate(50); // 50 packets (draw calls) / second
  udpClient = new UDP(this, NODE_PORT);
  udpClient.log(true);  // Verbose output, helpful but not necessary
}

void draw ( ) {
  background(186, 252, 3); // This should really go into GUI

  leftDriveSpeed += 1;
  rightDriveSpeed -= 1;
  
  shovelServoAngle++;
  
  visionPanAngle++;
  visionTiltAngle++;

  sendPacket();
}





//
// Networking Methods
//

void sendPacket () {
  ByteBuffer packet = ByteBuffer.allocate(10); // 10 bytes long

  packet.putShort((short) ( constrain(leftDriveSpeed, -255, 255) + 255));  // drive speeds are from -255 to 255, but 
  packet.putShort((short) ( constrain(rightDriveSpeed, -255, 255) + 255)); // sending negatives in packets is a pain
  packet.putShort((short) (shovelServoAngle % 181));                       // so the esp code does - 255 of what it recieves
  packet.putShort((short) (visionPanAngle % 181));
  packet.putShort((short) (visionTiltAngle % 181));

  udpClient.send(packet.array(), NODE_IP, NODE_PORT);
}





//
// GUI Methods
//

// void gui(float forwardReverse, float leftRight, float pickup, float currentMotorSpeed) {
//   cp5 = new ControlP5(this);
// 
//   // group number 3, contains a bang and a slider
//   Group g3 = cp5.addGroup("Controller Information")
//                 .setBackgroundColor(color(0, 64))
//                 .setBackgroundHeight(150)
//                 ;
//   
//   // Shows the value of the Y - Axis| Forward and Reverse Directiom
//   cp5.addSlider("Forward and Reverse")
//      .setPosition(60,20)
//      .setSize(100,20)
//      .setRange(-1,1)
//      .setValue(forwardReverse)
//      .moveTo(g3)
//      ;
//   
//   // Shows the value of the X-Axis| Left and Right Direction
//   cp5.addSlider("Left and Right")
//      .setPosition(60,50)
//      .setSize(100,20)
//      .setRange(-1, 1)
//      .setValue(leftRight)
//      .moveTo(g3)
//      ;
//    
//   // Shows the value of the LT/RT| Pickup Servo Level
//   cp5.addSlider("Pickup")
//     .setPosition(60,80)
//     .setSize(100, 20)
//     .setRange(-1, 1)
//     .setValue(pickup)
//     .moveTo(g3)
//     ;
//   
//   // Shows the value of the LT/RT| Pickup Servo Level
//   cp5.addSlider("Motor Speed")
//     .setPosition(60,110)
//     .setSize(100, 20)
//     .setRange(0, 1)
//     .setValue(currentMotorSpeed)
//     .moveTo(g3)
//     ;
//   
//   // Allows Menu to Be Collapsed
//   accordion = cp5.addAccordion("acc")
//                  .setPosition(94,125)
//                  .setWidth(300)
//                  .addItem(g3)
//                  ;
//                  
//   // Some GUI Code(I copied form online)              
//   cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(0,1,2);}}, 'o');
//   cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.close(0,1,2);}}, 'c');
//   cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setWidth(300);}}, '1');
//   cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setPosition(0,0);accordion.setItemHeight(190);}}, '2'); 
//   cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.ALL);}}, '3');
//   cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.SINGLE);}}, '4');
//   cp5.mapKeyFor(new ControlKey() {public void keyEvent() {cp5.remove("myGroup1");}}, '0');
//   
//   // Allows one section to be open at a time
//   accordion.open(0,1,2);
//   accordion.setCollapseMode(Accordion.SINGLE);
// }
