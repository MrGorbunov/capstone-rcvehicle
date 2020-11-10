/*
Computer UDP Client

This code works in tandem with the .ino
sketch for the NodeMCU.

The computer send signals to the NodeMCU
over the UDP protocol. This is literally all
the program does because that is what is
being tested.
*/

import hypermedia.net.*;

UDP udpClient;
final String NODE_IP = "192.168.4.1";
final int NODE_PORT = 6969; // Haha funny number

String message = "Good news everybody!";
boolean black;

void setup () {
  size(400, 400);
  udpClient = new UDP(this, NODE_PORT);
  udpClient.log(true);
}

void draw () {
  if (black)
    background(140);
  else
    background(0);
  delay(1000);
  black = !black;

  udpClient.send(message, NODE_IP, NODE_PORT);
}
