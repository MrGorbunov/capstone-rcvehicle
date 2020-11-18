import controlP5.*;

ControlP5 cp5;
int v1;

void setup () { 
  size(800, 400);
  noStroke();

  cp5 = new ControlP5(this);
  cp5.addSlider("v1")
     .setPosition(40, 40)
     .setSize(200, 20)
     .setRange(0, 255)
     .setValue(100);
}

void draw () {
  background(0);
  circle(v1, 100, 20);
}

