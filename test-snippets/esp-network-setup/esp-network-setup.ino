#include <ESP8266WiFi.h>

// In station mode, these refer to the actual wifi credentials
// As an access point, these become the login creds of the wifi
const char* ssid = "ESP8266-ohmero-group";  // ssid = network name
const char* pass = "AryanKindaPog";

void setup() {
  // This is to communicte over usb 
  // not necessary for actual wireless but good for debugging
  Serial.begin(115200);
  delay(10);
  Serial.println('\n');

  /*
    Connecting to an existing network (station mode)
  */
  // WiFi.begin(ssid, pass);  // ssid & pass must be of the network
  // Serial.print("Connecting to: ");
  // Serial.print(ssid);
  // Serial.println("...");

  // int secs = 0;
  // while (WiFi.status() != WL_CONNECTED) {
  //   delay(1000);
  //   secs++;
  //   Serial.print(secs);
  //   Serial.print(' ');
  // }

  // Serial.println("Connection Established woohoo!");
  // Serial.print("Local IP: ");
  // Serial.println(WiFi.localIP());

  /*
     Creating a local sub-net (acess point)
  */
  WiFi.softAP(ssid, pass);
  Serial.print("Access point started: ");
  Serial.println(ssid);

  Serial.print("IP Adress: ");
  Serial.println(WiFi.softAPIP()); // softAPIP = Soft Access Point IP

}

void loop() {

}
