#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <Servo.h>
#include <math.h>


// TODO: Add easing to this (esp) and take it off the controller (processing client)


//
// Hardware constants
// Storing with variables was being weird :(
#define PIN_VISION_PAN D2
#define PIN_VISION_TILT D1
#define PIN_SHOVEL_MASTER D3
#define PIN_SHOVEL_SLAVE CompilationErrorMakeSureToSetShovelServoSlave

#define PIN_MOTOR_LEFT_POS D5
#define PIN_MOTOR_LEFT_NEG D6
#define PIN_MOTOR_RIGHT_POS D7
#define PIN_MOTOR_RIGHT_NEG D8

// Servo shovelServo_master;
// Servo shovelServo_slave;
Servo visionServo_tilt;
Servo visionServo_pan;


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
int shovelServoAngle = 0; // 0-180 for angles, and -255 to 255 for drives
int visionPanAngle = 90;   
int visionTiltAngle = 60;  


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
  // pinMode(PIN_SHOVEL_MASTER, OUTPUT); // Shovel Servo
  pinMode(PIN_VISION_PAN, OUTPUT); // Vision Pan
  pinMode(PIN_VISION_TILT, OUTPUT); // Vision Tilt

  visionServo_tilt.attach(PIN_VISION_TILT);
  visionServo_pan.attach(PIN_VISION_PAN);

  // TODO: Motor Control

  Serial.print("Pins Configured");
  delay(100);


  //
  // Network Setup
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
  // This doesn't mess with packet reading :D
  delay(10); 

  if (activeBlinkCycle >= BLINK_CYCLE_TOTAL) {
    activeBlinkCycle = 0;
    blink = !blink;
  }

  activeBlinkCycle++;
  LEDOutput(blink);
  updateMotorOutput();

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

void updateMotorOutput () {
  visionServo_tilt.write(visionTiltAngle);
  visionServo_pan.write(visionPanAngle);
}

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


  // Servo Output
  analogWrite(PIN_VISION_PAN, pwmLogVal(scaledAngle(visionPanAngle)));
  analogWrite(PIN_VISION_TILT, pwmLogVal(scaledAngle(visionTiltAngle)));

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


