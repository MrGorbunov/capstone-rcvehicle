import processing.serial.*;
Serial myPort;


double x_pos;    // 0 to 1
double y_pos;    // 0 to 1
boolean pressed;

int INNER_SIZE = 200;


void setup () {
  size(600, 600);
  myPort = new Serial(this, Serial.list()[0], 9600);
}


void draw () {
  if (!readSerialAndUpdateVars())
    return;
  
  drawInputs();
}


/**
  Returns true if succesful
  */
boolean readSerialAndUpdateVars () {
  if (myPort.available() <= 0)
    return false;

  String serialString = myPort.readStringUntil((int) '\n');
  if (serialString == null)
    return false;
  // The new line at the end screws up parsing
  serialString = serialString.substring(0, serialString.length()-2);

  String[] dataVals = serialString.split(",");
  if (dataVals.length != 3)
    return false;
  

  // Put the values into variables
  x_pos = (double) Integer.parseInt(dataVals[0]) / 1024.0;
  y_pos = (double) Integer.parseInt(dataVals[1]) / 1024.0;
  pressed = Integer.parseInt(dataVals[2]) == 1;


  return true;
}


void drawInputs () {
  background(255);

  // Inner square
  int hfSize = INNER_SIZE / 2;
  int hfWidth = width / 2;
  int hfHeight = height / 2;
  fill(200);
  stroke(150);
  strokeWeight(4);
  rect(hfWidth - hfSize, hfHeight - hfSize, INNER_SIZE, INNER_SIZE);

  // Center circle & gridlines
  stroke(120);
  strokeWeight(2);
  circle(width / 2, height / 2, 10);
  line(hfWidth - hfSize, hfHeight, hfWidth + hfSize, hfHeight);
  line(hfWidth, hfHeight - hfSize, hfWidth, hfHeight + hfSize);

  // Joystick
  if (pressed)
    fill(100, 150, 50);
  else
    fill(100, 50, 10);
  int x_pxpos = (int) (x_pos * INNER_SIZE) + hfWidth - hfSize;
  int y_pxpos = (int) (y_pos * INNER_SIZE) + hfHeight - hfSize;
  circle(x_pxpos, y_pxpos, 30);
}

