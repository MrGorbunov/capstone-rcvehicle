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
  
  // Looks for controll file and reads the commands
  cont = control.getMatchedDevice("Xbox LED Color Change");
  
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
  // Reads the value of the Y-Axis on the Xbox Controller
  float ledColor = cont.getSlider("ledColor").getValue();
  
  // The value of the controller joystick range from -1 to  1
  
  // When the value is greater than 0.1 then it sends the serial com signal 1
  if (ledColor > 0.1){
    myPort.write ( '1' ) ;
  } 
  
  // When the value is less than -0.1 then it sends the serial com signal 0
  else if(ledColor < - 0.1){
    myPort.write ( '0' ) ;
  }
  
  // When the value is in between 0.1 and -0.1 then it  sends the serial com signal 2
  else{
    myPort.write('2');
  }
}
