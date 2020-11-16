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


// Motor speeds
// Pan is left to right, tilt is up & down
// TODO: How is this supposed to ever go backwards?
int leftDriveSpeed = 0;   // 0-255
int rightDriveSpeed = 0;  // 0-255
int shovelServoAngle = 0; // 0-360
int visionPanAngle = 0;   // 0-360
int visionTiltAngle = 0;  // 0-360


// Networking globals (port constant just needs to match on the cpp side)
UDP udpClient;
final String NODE_IP = "192.168.4.1";
final int NODE_PORT = 6969; // Haha funny number





//
// Main Loops
//

void setup() {
  size(400, 400);
  frameRate(50);   // 50 packets / second

  // Networking
  udpClient = new UDP(this, NODE_PORT);
  udpClient.log(true); // More info in console but not necessary
}

void draw() {
  // readControllerInputs();
  // calculateMotorSpeeds();
  sendPacket();
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



