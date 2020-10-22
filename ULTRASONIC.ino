const int trigPin = 7; 
const int echoPin = 8;
float duration, distance;


void setup() {
  pinMode(trigPin, OUTPUT); 
  pinMode(echoPin, INPUT); 
  Serial.begin(9600); 
}

void loop() {
   digitalWrite(trigPin, LOW); 
   delayMicroseconds(2); 
   digitalWrite(trigPin, HIGH); 
   delayMicroseconds(10); 
   digitalWrite(trigPin, LOW); 
   duration = pulseIn(echoPin, HIGH); 
   distance = (duration*0.5) * 0.03; 
   Serial.print("Distance: "); 
   Serial.println(distance); 
   delay(100); 
}
