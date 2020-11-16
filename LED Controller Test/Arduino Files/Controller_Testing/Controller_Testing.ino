// RGB LED DP
int blue = 3;
int green = 5;
int red = 6;

// Forward declaration
void RGB(int, int, int);

void setup() {  
  // Enables Data Transfer at 9600
  Serial.begin(9600);

  // All DPs on RGB are OUTPUT
  pinMode(blue, OUTPUT);
  pinMode(green, OUTPUT);
  pinMode(red, OUTPUT);
}

void loop() {
  // Checks to see if Processing has sent any signals
  if (Serial.available ( ) > 0) {
    // Sets a variable to the serial com signal from Processing
    // 0 = < - 0.1 on Y-Axis
    // 
    char state = Serial.read ( );

    // If the signal is 1, then set the RGB LED to 255 on Red
    if(state == '1'){ 
      RGB(225, 0, 0); 
    }  

    // If the signal is 0, then set the RGB LED to 255 on Blue
    else if (state == '0') {
      RGB(0, 255, 0);
    } 

    // If the signal is 2, then set the RGB LED to 0 on Blue, Red, and Green
    else if(state == '2'){
      RGB(0, 0, 0);
    }
  }
}

// This is the void method that controls the RGB color
void RGB(int redVal, int greenVal, int blueVal){
  analogWrite(red, redVal);
  analogWrite(green, greenVal);
  analogWrite(blue, blueVal);
}
