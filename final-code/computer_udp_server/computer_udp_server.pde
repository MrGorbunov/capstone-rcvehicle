import processing.net.*;

Server virtualControl;
Client virtualControlClient;


// When the client first connects, we send a packet for
// the next 100 loops
final int TOTAL_RESPONSE_INTERVAL = 100; // # of loops
int currentLoop = 0;
boolean recievedSignal = false;
// Actual motor speeds
// _these get sent wirelessly to the esp_
int leftDriveSpeed = 0;   // 0-255
int rightDriveSpeed = 0;  // 0-255
int shovelServoAngle = 0; // 0-360
float avrMotor = 0;
// Pan is side to side, tilt is up & down
float visionPanAngle = 90;   // 0-180
float visionTiltAngle = 90;  // 0-180

void setup(){
  // Initial call sets up the screen
  size(300,  300);

  frameRate(50); // 50 packets (draw calls) / second
  virtualControl = new Server(this, 12345); // Start a simple server on a port
}
void draw(){
  if (recievedSignal)
    background(50, 150, 50);
  else
    background(150, 50, 50);
  
  readIncomingTraffic();
}
void readIncomingTraffic () {
  virtualControlClient = virtualControl.available();
  if (virtualControlClient == null) { return; }

  recievedSignal = true;

  String msg = virtualControlClient.readString();
  println(msg);
  msg = msg.substring(0, msg.indexOf("\n"));
  int[] recievedVals = int(split(msg, ' '));
  println(recievedVals);
  leftDriveSpeed = recievedVals[0];
  println(leftDriveSpeed);
  rightDriveSpeed = recievedVals[1];
  println(rightDriveSpeed);
  shovelServoAngle = recievedVals[2];
  println(shovelServoAngle);
  visionPanAngle = recievedVals[3];
  println(visionPanAngle);
  visionTiltAngle = recievedVals[4];
  println(visionTiltAngle);
}
