#include <ESP8266WiFi.h>
#include <WiFiUdp.h>

//
// Network Values
const char SSID[] = "Ohmero Group - Capstone";
const char PASS[] = "JoinTheResistance";

// UDP Server configuration, must match with the processing sketch
WiFiUDP UDP;
IPAddress local_IP(192,168,4,1);
IPAddress gateway(192,168,4,1);
IPAddress subnet(255,255,255,0);
const int UDP_PORT = 6969;

char packetBuffer[UDP_TX_PACKET_MAX_SIZE];


//
// Motor Values
int leftDriveSpeed = 0;   // Even though these are ints,
int rightDriveSpeed = 0;  // The values should all be very low
int shovelServoAngle = 0; // 0-360 for angles, and 0-255 for drives
int visionPanAngle = 0;   
int visionTiltAngle = 0;  





//
// Main Loops
//

void setup() {
  Serial.begin(9600);
  delay(1000); // Otherwise these messages in setup dont send
  Serial.println('\n');

  // Setup Access point
  Serial.print("Starting Soft AP... ");

  WiFi.softAPConfig(local_IP, gateway, subnet);
  WiFi.softAP(SSID, PASS);

  Serial.print("Soft AP ");
  Serial.print(SSID);
  Serial.print(" started at ");
  Serial.println(WiFi.softAPIP());

  // Begin listening for UDP packets
  UDP.begin(UDP_PORT);
  Serial.print("Listening for UDP packets on port ");
  Serial.println(UDP_PORT);
}

void loop() {
  delay(10);

  // If no new packet, stop and keep looping
  if (!readPacket())
    return;
}





//
// Networking Code
//

bool readPacket() {
  int packetSize = UDP.parsePacket();
  if (packetSize == 0)
    return false;

  // Now we have to actually parse the packet
  UDP.read(packetBuffer, UDP_TX_PACKET_MAX_SIZE);  
  
  /* 
     Every 2 chars represents 1 short for 1 motorspeed/ angle.

     Lets look at 1027 as an example. In the processing code, it
     get split up as such.

     1027 = (4)*256  +  (3)*1
     1027 => [4, 3]

     To reconstruct the 1027, we need to multiply index 0 by 256,
     and add it to index 1. Additionally, there is some fancy casting
     needed to convert the signed characters into unsigned ints.
  */

  int reconstructedValues[5] = { };

  for (int i=0; i<10; i+=2) {
    int intCast1 = (int) (u_char) packetBuffer[i];
    int intCast2 = (int) (u_char) packetBuffer[i+1];

    int reconstructedValues[i/2] = intCast1 * 256 + intCast2;
  }

  // This specific pairing can be found in the README
  leftDriveSpeed =   reconstructedValues[0];
  rightDriveSpeed =  reconstructedValues[1];
  shovelServoAngle = reconstructedValues[2];
  visionPanAngle =   reconstructedValues[3];
  visionTiltAngle =  reconstructedValues[4];
  return true;
}





