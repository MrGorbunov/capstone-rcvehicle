import processing.net.*;

Server virtualControl;

void setup(){
  size(450, 255);
  background(204);
  stroke(0);
  frameRate(5); // Slow it down a little
  virtualControl = new Server(this, 12345); // Start a simple server on a port
}
