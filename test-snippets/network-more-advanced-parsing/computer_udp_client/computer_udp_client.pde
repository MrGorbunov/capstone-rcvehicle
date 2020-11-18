/*
Computer UDP Client

This processing code takes in user input and 
sends it the NodeMCU.

Packet Structure:
byte[] { LED STATE }
*/

import hypermedia.net.*;

UDP udpClient;
final String NODE_IP = "192.168.4.1";
final int NODE_PORT = 6969; // Haha funny number

boolean ledOn;

void setup () {
  ledOn = false;

  udpClient = new UDP(this, NODE_PORT);
  udpClient.log(true);

  size(400, 400);
}



void mousePressed () {
  ledOn = true;
}

void mouseReleased () {
  ledOn = false;
}

void draw () {
  
  // User input is handled by mousePressed() & mouseReleased()

  // Send User Input
  byte msg = ledOn ? 1 : 0;
  UDP.send(msg, NODE_IP, NODE_PORT);

  // Draw User Input
  background(100);
  square(
}
