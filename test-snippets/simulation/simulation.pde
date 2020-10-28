/*
Driving Simulation

This is currently 2D, but turning it 3D will not be too hard.

Also, as of now this assuems 4 wheels with 2 wheel drive.
*/




//
// Utility Functions & Classes
// - Transform & ChildTransform are for simpler position keeping
// - drawRect(transform) will draw a rectangle
//

class Transform {
  protected float x, y;
  protected float rotation;
  
  public Transform(float x, float y) {
     this.x = x;
     this.y = y;
     rotation = 0;
  }
  
  /**
  Returns an array of all rotation values,
  float[] {x, y, rotation}
  */
  public float[] getTransformArray () {
    return new float[] {x, y, rotation};
  }
  public float getAngle() { return rotation; }
  public float getX() { return x; }
  public float getY() { return y; }
  
  public void rotate(float deltaRot) {
    rotation += deltaRot;
    rotation %= 360;
  }
  public void moveOnX(float deltaX) { this.x += deltaX; }
  public void moveOnY(float deltaY) { this.y += deltaY; }

  public void moveLocalX(float deltaX) {
    this.y += deltaX * sin(rotation);
    this.x += deltaX * cos(rotation);
  }
  public void moveLocalY(float deltaY) {
    this.y += deltaY * cos(rotation);
    this.x += -deltaY * sin(rotation);
  }
  
  public void setAngle(float rotation) { this.rotation = rotation % 360; }
  public void setX(float x) { this.x = x; }
  public void setY(float y) { this.y = y; }
}

class ChildTransform extends Transform {
  Transform parent;
  float xOff;
  float yOff;
  
  public ChildTransform(Transform parentTransform, float x, float y) {
    super(x, y);
    parent = parentTransform;
    // Even when x & y change (translation) xOff & yOff stay constant
    xOff = x;
    yOff = y;
  }
  
  @Override
  public float getAngle() { return (rotation + parent.getAngle()) % 360; }
  // These require transformation because of offset
  // The actual equations come from transformation matricies
  public float getX() { 
    float pAng = parent.getAngle();
    float pX = parent.getX();
    return xOff * cos(pAng) - yOff * sin(pAng) + pX;
  }
  public float getY() { 
    float pAng = parent.getAngle();
    float pY = parent.getY();
    return xOff * sin(pAng) + yOff * cos(pAng) + pY;
  }
}



public void drawRect(Transform transform, float w, float h) {
  pushMatrix();
  translate(transform.getX(), transform.getY());
  rotate(transform.getAngle()); // radian conversion
  rect(-w/2, -h/2, w, h);
  popMatrix();
}

public void drawArrow(Transform transform, float arrowLength) {
  drawArrow(transform.getX(), transform.getY(), transform.getAngle(), arrowLength);
}

public void drawArrow(float x, float y, float angle, float arrowLength) {
  float x2 = x - arrowLength * sin(angle);
  float y2 = y + arrowLength * cos(angle);

  circle(x, y, 3);
  line(x, y, x2, y2);
}





//
// Flow
//

Transform center = new Transform(200, 200);

float carWidth = 40;
float carHeight = 80;
float tireWidth = 10;
float tireHeight = 20;

Transform[] children = new ChildTransform[] {
  new ChildTransform(center, 0, -10),   // Camera

  new ChildTransform(center, -carWidth/2 - tireWidth/2, -carHeight/2 + tireHeight/2),
  new ChildTransform(center, -carWidth/2 - tireWidth/2, carHeight/2 - tireHeight/2),
  new ChildTransform(center, carWidth/2 + tireWidth/2, -carHeight/2 + tireHeight/2),
  new ChildTransform(center, carWidth/2 + tireWidth/2, carHeight/2 - tireHeight/2),
};

void setup () {
  size(500, 500);
  
  stroke(150);
  strokeWeight(2);
  frameRate(30);
}

void draw () {
  background(255);
  stroke(80);

  drawRect(center, carWidth, carHeight);

  drawRect(children[1], tireWidth, tireHeight);
  drawRect(children[2], tireWidth, tireHeight);
  drawRect(children[3], tireWidth, tireHeight);
  drawRect(children[4], tireWidth, tireHeight);

  drawArrow(center, 10);

  center.rotate(0.1);
  center.moveLocalY(3);
}






