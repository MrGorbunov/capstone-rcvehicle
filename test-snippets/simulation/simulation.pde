/*
Driving Simulation

This is currently 2D, but turning it 3D will not be too hard.

Also, as of now this assuems 4 wheels with 2 wheel drive.
*/




//
// Classes 
// - Transform & ChildTransform are for simpler position keeping
// - Rect makes drawing much simpler
// - VehicleComponent combines a rect and a transform
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
  
  public void rotateSelf(float deltaRot) {
    rotation += deltaRot;
    rotation %= 360;
  }
  public void moveOnX(float deltaX) { this.x += deltaX; }
  public void moveOnY(float deltaY) { this.y += deltaY; }
  
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

//
// Rect

public class ShapeRect {
  float w, h;

  public ShapeRect(float width, float height) {
    w = width;
    h = height;
  }

  public void drawSelf(Transform trans) {
    float[] center = new float[] {trans.getX(), trans.getY()};
    return;
  }
}





//
// Flow
//

float rotation = 0;

void setup () {
  size(500, 500);
  
}

void draw () {
  background(255);
  stroke(50);
  strokeWeight(7);

  Transform parent = new Transform(50, 50);
  Transform[] children = new ChildTransform[] {
    new ChildTransform(parent, -10, -30),
    new ChildTransform(parent, -10, 30),
    new ChildTransform(parent, 10, -30),
    new ChildTransform(parent, 10, 30),
  };
  
  parent.rotateSelf(rotation);
  rotation += 0.01;


  point(parent.getX(), parent.getY());
  stroke(150);
  strokeWeight(4);
  for (Transform child : children) {
    point(child.getX(), child.getY());
  }
}


