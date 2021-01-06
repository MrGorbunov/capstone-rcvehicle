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
String status;
String leftDriveSpeed;   // 0-255S
String rightDriveSpeed;  // 0-255
String shovelServoAngle; // 0-360
String avrMotor;
String driveMode;
// Pan is side to side, tilt is up & down
String visionPanAngle;   // 0-180
String visionTiltAngle;  // 0-180
String sender;
String msg;
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
  sendValue();
}
void readIncomingTraffic () {
  virtualControlClient = virtualControl.available();
  if (virtualControlClient == null) { return; }

  if(virtualControlClient != null){
    recievedSignal = true;
    msg = virtualControlClient.readString();
    msg = msg.substring(0, msg.indexOf("\n"));
    String[] recievedVals = split(msg, ' ');
    try{
      if(recievedVals[6].equals("c")){
        leftDriveSpeed = recievedVals[0];
        rightDriveSpeed = recievedVals[1];
        shovelServoAngle = recievedVals[2];
        visionPanAngle = recievedVals[3];
        visionTiltAngle = recievedVals[4];
        sender = recievedVals[5];
        driveMode = recievedVals[7];
      }
    }
    catch(Exception e){
      if(recievedVals[0].equals("Sender")){
        virtualControlClient.write("Sender" + "\n");  
        sender = "b";
      }
    }
  }
}
void sendValue(){
  if(leftDriveSpeed != null){
    String msgSend;
    if(sender.equals("a")){
      msgSend = leftDriveSpeed + ' ' + rightDriveSpeed + ' ' + shovelServoAngle + ' ' + visionPanAngle + ' '+ visionTiltAngle + ' ' + "b" + ' ' + "" + ' ' + driveMode +"\n";
      virtualControl.write(msgSend);
    }
    else{
      msgSend = leftDriveSpeed + ' ' + rightDriveSpeed + ' ' + shovelServoAngle + ' ' + visionPanAngle + ' '+ visionTiltAngle + ' ' + "a" + ' ' + "" + ' ' + driveMode +"\n";
      virtualControl.write(msgSend);
    }
  }
}
