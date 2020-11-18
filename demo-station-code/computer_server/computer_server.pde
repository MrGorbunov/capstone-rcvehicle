/*
Capstone RC-Vehicle Code
Computer UDP Client
Demo Code

This code:
1 - Recieves packets over internet
2 - Sends packets to the ESP
*/

import processing.net.*;   // Over Internet Networking
import hypermedia.net.*;   // ESP Networking
import java.nio.ByteBuffer;// For packet prep




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
// Networking 
UDP udpClient;
String NODE_IP = "192.168.1.101";
final int NODE_PORT = 12345;

Server s;
Client c;
final int SERVER_PORT = 6969;

// When the client first connects, we send a packet for
// the next 100 loops
final int TOTAL_RESPONSE_INTERVAL = 100; // # of loops
int currentLoop = 0;
boolean recievedSignal = false;







//
// Main Loops
//

void setup() {
  // Initial call sets up the screen
  size(100,  100);

  frameRate(50); // 50 packets (draw calls) / second

  udpClient = new UDP(this, NODE_PORT);
  s = new Server(this, SERVER_PORT);
}

void draw() {
  if (recievedSignal)
    background(50, 150, 50);
  else
    background(150, 50, 50);
  
  readIncomingTraffic();
  sendToESP();

  // Sending a response back
  if (recievedSignal && currentLoop < TOTAL_RESPONSE_INTERVAL) {
    currentLoop++;
    s.write("Signal Recieved");
  }
}





//
// Networking Methods
//

void readIncomingTraffic () {
  c = s.available();
  if (c == null) { return; }

  recievedSignal = true;

  String msg = c.readString();
  msg = msg.substring(0, msg.indexOf("\n"));
  int[] recievedVals = int(split(msg, ','));

  leftDriveSpeed = recievedVals[0];
  rightDriveSpeed = recievedVals[1];
  shovelServoAngle = recievedVals[2];
  visionPanAngle = recievedVals[3];
  visionTiltAngle = recievedVals[4];
  
}

void sendToESP () {
  ByteBuffer packet = ByteBuffer.allocate(10); // 10 bytes long

  packet.putShort((short) ( constrain(leftDriveSpeed, -255, 255) + 255));  // drive speeds are from -255 to 255, but 
  packet.putShort((short) ( constrain(rightDriveSpeed, -255, 255) + 255)); // sending negatives in packets is a pain
  packet.putShort((short) (shovelServoAngle % 361));                        // so the esp code does - 255 of what it recieves
  packet.putShort((short) (visionPanAngle % 361));
  packet.putShort((short) (visionTiltAngle % 361));

  udpClient.send(packet.array(), NODE_IP, NODE_PORT);
}





