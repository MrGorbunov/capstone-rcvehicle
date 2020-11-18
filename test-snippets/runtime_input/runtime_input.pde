
boolean gatheringIP = true;

boolean firstFrame = true;
char previousKey = 'a';
StringBuilder ipBuilder = new StringBuilder();
String NODE_IP;


void setup () {
  size(400,400);
  
  previousKey = key;
}

void draw () {
  if (gatheringIP) {
     gatherIPLoop();
  } else {
     normalDraw(); 
  }
}

void normalDraw () {
   background(100); 
}

void gatherIPLoop () {
    background(0);
    
    if ((key != previousKey) || (keyPressed && firstFrame)) {
      if (key == BACKSPACE)
        ipBuilder.deleteCharAt(ipBuilder.length() - 1); 
      
      else if (key == ENTER) {
        NODE_IP = ipBuilder.toString();
        gatheringIP = false;
        
      } else
        ipBuilder.append(key);
    }
    previousKey = key;
    firstFrame = !keyPressed;

    
    textSize(50);
    text(ipBuilder.toString(), 10, 200);
}
