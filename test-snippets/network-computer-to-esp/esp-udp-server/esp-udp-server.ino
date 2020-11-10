#include <ESP8266WiFi.h>
#include <WiFiUdp.h>

const char SSID[] = "Ohmero Group - Capstone";
const char PASS[] = "JoinTheResistance";

// UDP Server configuration
WiFiUDP UDP;
IPAddress local_IP(192,168,4,1);
IPAddress gateway(192,168,4,1);
IPAddress subnet(255,255,255,0);

const int UDP_PORT = 6969;

// This holds incoming packets
char packetBuffer[UDP_TX_PACKET_MAX_SIZE];

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
  delay(1000);

  // Handle incoming packet
  int packetSize = UDP.parsePacket();
  
  if (packetSize == 0)
    return;

  UDP.read(packetBuffer, UDP_TX_PACKET_MAX_SIZE);
  Serial.print("New Packet: ");
  Serial.println(packetBuffer);
}
