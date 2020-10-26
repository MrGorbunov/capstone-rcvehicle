/*
  This code is going to be used to convert the xbox commands into arduino signals
  
  Here is a directory of the commands 
  1. Left Joystick Y Value - Forward/Reverse
  2. Left Joystick X Value - Left/Right
  3. RT/LT Value - Pickup 
  4. "X"/"B" Value - LeftCameraAngle/RightCameraAngle
  5. "Y"/"A" Value - IncreaseSpeed/DecreaseSpeed
  
  Here is a directory of the Serial Inputs
  1. "0" - Go forward
  2. "1" - Go backwards
  3. "2" - Go left
  4. "3" - Go right
  5. "4" - Go to neutral
  6. "5" - Pickup item from floor
  7. "6" - Throw item into containment area
  8. "7" - Move camera to the left
  9. "8" - Move camera to the right
  10. "9" - Increase speed
  11. "a" - Decrease speed
*/
// Import statement for Serial Processing
import processing.serial.*;

// Import Statements for Gaming Inputs
import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

// Import Statements for Arduino Compiling and Example Software 
import cc.arduino.*;
import org.firmata.*;

// Game controller variables
ControlDevice cont;
ControlIO control;

// Serial Communication Variable
Serial myPort;

void setup ( ) {
  // Instantiates the controller 
  control = ControlIO.getInstance(this);
  
  // Looks for control file and reads the commands
  cont = control.getMatchedDevice("Xbox Controller Settings");
  
  // Makes sure that if there are any errors with the controller to terminate the code
  if (cont == null) {
    println("not today chump");
    System.exit(-1);
  }
  
  // Establishes the Serial Communication Connection
  myPort  =  new Serial (this, "COM3",  9600);
  myPort.bufferUntil ( '\n' );
} 

void draw ( ) {
  // Defines the button variables for checking status
  ControlButton leftCameraAngle;
  ControlButton rightCameraAngle;
  ControlButton increaseSpeed;
  ControlButton decreaseSpeed;
  
  // The value of the controller joystick range from -1 to  1
  
  // Reads the value of the Y-Axis on the Xbox Controller
  float forwardReverse = cont.getSlider("forwardreverse").getValue();
  
  // Reads the value of the X-Axis on the Xbox Controller
  float leftRight = cont.getSlider("leftright").getValue();
  
  // Read the value of the Z-Acis(RT/LT) on the Xbox Controller
  float pickup = cont.getSlider("pickup").getValue();
  
  // Read to see what the status of the "X" button on the Xbox Controller
  leftCameraAngle = cont.getButton("leftcameraangle");
  boolean leftCameraAngleStatus = leftCameraAngle.pressed();
  
  // Read to see what the status of the "B" button on the Xbox Controller
  rightCameraAngle = cont.getButton("rightcameraangle");
  boolean rightCameraAngleStatus = rightCameraAngle.pressed();
  
  // Read to see what the status of the "Y" button on the Xbox Controller
  increaseSpeed = cont.getButton("increasespeed");
  boolean increaseSpeedStatus = increaseSpeed.pressed();
  
  // Read to see what the status of the "A" button on the Xbox Controller
  decreaseSpeed = cont.getButton("decreasespeed");
  boolean decreaseSpeedStatus = decreaseSpeed.pressed();
  
  if(forwardReverse > 0.1){
    myPort.write ( '0' ) ;
  }
  else if(forwardReverse < -0.1){
    myPort.write ( '1' ) ;
  }
  else if(leftRight > 0.1){
    myPort.write ( '2' ) ;
  }
  else if(leftRight < -0.1){
    myPort.write ( '3' ) ;
  }
  else if(forwardReverse < 0.1 && forwardReverse > -0.1 && leftRight < 0.1 && leftRight > -0.1){
    myPort.write ( '4' ) ;
  }
  else if(pickup > 0.1){
    myPort.write ( '5' ) ;
  }
  else if(pickup < -0.1){
    myPort.write ( '6' ) ;
  }
  else if(leftCameraAngleStatus){
    myPort.write ( '7' ) ;
  }
  else if(rightCameraAngleStatus){
    myPort.write ( '8' ) ;
  }
  else if(increaseSpeedStatus){
    myPort.write ( '9' ) ;
  }
  else if(decreaseSpeedStatus){
    myPort.write ( 'a' ) ;
  }
}
