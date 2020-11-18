#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <math.h>

//
// Network Values
const char SSID[] = "******";
const char PASS[] = "******";

// UDP Server configuration, must match with the processing sketch
WiFiUDP UDP;
const int UDP_PORT = 12345;

char packetBuffer[UDP_TX_PACKET_MAX_SIZE];

//
// Motor Values
int leftDriveSpeed = 0;   // Even though these are ints,
int rightDriveSpeed = 0;  // The values should all be very low
int shovelServoAngle = 0; // 0-180 for angles, and -255 to 255 for drives
int visionPanAngle = 0;   
int visionTiltAngle = 0;  


//
// Temp for LED Output
const int BLINK_CYCLE_TOTAL = 20;
int activeBlinkCycle = 0;
bool blink = false;






//
// Main Loops
//

void setup() {
  Serial.begin(9600);
  delay(1000); // Otherwise these messages in setup dont send
  Serial.println('\n');


  //
  // Hardware Setup
  pinMode(D1, OUTPUT); // Shovel Servo
  pinMode(D2, OUTPUT); // Vision Pan
  pinMode(D3, OUTPUT); // Vision Tilt

  pinMode(D5, OUTPUT); // DC Motor Data
  pinMode(D7, OUTPUT);

  Serial.print("Pins Configured");
  delay(100);


  //
  // Network Setup
  Serial.print("Starting Soft AP... ");

  WiFi.begin(SSID, PASS);

  Serial.print("Connecting to Wifi");
  Serial.print(SSID);
  Serial.print(" started at ");

  // Begin listening for UDP packets
  UDP.begin(UDP_PORT);
  Serial.print("Listening for UDP packets on port ");
  Serial.println(UDP_PORT);
}

void loop() {
  // This doesn't mess with packet reading :D
  delay(10); 

  if (activeBlinkCycle >= BLINK_CYCLE_TOTAL) {
    activeBlinkCycle = 0;
    blink = !blink;
  }

  activeBlinkCycle++;
  LEDOutput(blink);


  // If no new packet, terminate loop
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

  int reconstructedValues[5] = { 0 };

  for (int i=0; i<10; i+=2) {
    int intCast1 = (int) (u_char) packetBuffer[i];
    int intCast2 = (int) (u_char) packetBuffer[i+1];

    reconstructedValues[i/2] = intCast1 * 256 + intCast2;
  }

  // This specific pairing can be found in the README
  leftDriveSpeed =   reconstructedValues[0] - 255; // Instead of dealing with 2's complement,
  rightDriveSpeed =  reconstructedValues[1] - 255; // 255 is added to the values before sending
  shovelServoAngle = reconstructedValues[2];
  visionPanAngle =   reconstructedValues[3];
  visionTiltAngle =  reconstructedValues[4];
  return true;
}





//
// Hardware Output
//

void LEDOutput (bool blink) {
  // if blink, then negative motor speeds should be off
  int leftDrivePWM = pwmLogVal((int) abs(leftDriveSpeed));
  int rightDrivePWM = pwmLogVal((int) abs(rightDriveSpeed));
  if (blink) {
    if (leftDriveSpeed < 0)
      leftDrivePWM = 0;
    if (rightDriveSpeed < 0)
      rightDrivePWM = 0;
  }

  analogWrite(D5, leftDrivePWM);
  analogWrite(D7, rightDrivePWM);


  // Servo Output
  analogWrite(D1, pwmLogVal(scaledAngle(shovelServoAngle)));
  analogWrite(D2, pwmLogVal(scaledAngle(visionPanAngle)));
  analogWrite(D3, pwmLogVal(scaledAngle(visionTiltAngle)));

}

/*
 * Scales inputAngle 0-180 to be 0-255
 */
int scaledAngle (int inputAngle) {
  return (int) (((double) inputAngle) * 255.0 / 180.0);
}

/*
 * PWM Logarithmic Value
 * Put values from 0-256 (linearly) and it will return
 * values on a logarithmic scale from 0-1024
 */
int pwmLogVal (int inputVal) {
  if (inputVal <= 1)
    return 0;

  double power = ((double) inputVal) * 5 / 128;
  return (int) exp2(power);
}


