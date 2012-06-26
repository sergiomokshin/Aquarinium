 
#define REDPIN 5
#define GREENPIN 6
#define BLUEPIN 3
 
#define FADESPEED 5
 
void setup() {
  pinMode(REDPIN, OUTPUT);
  pinMode(GREENPIN, OUTPUT);
  pinMode(BLUEPIN, OUTPUT);
}
 
 
void loop() {
  fade();  
  change();
}

void change(){
   analogWrite(REDPIN, 0);
   analogWrite(BLUEPIN, 0);
   analogWrite(GREENPIN, 0);
   delay(500);
   
   analogWrite(REDPIN, 50);
   analogWrite(BLUEPIN, 50);
   analogWrite(GREENPIN, 50);
   delay(1000);      
   
   analogWrite(REDPIN, 255);
   analogWrite(BLUEPIN, 255);
   analogWrite(GREENPIN, 255);
   delay(1000);
  
}


void fade(){
 int r, g, b;
 
  // fade from blue to violet
  for (r = 0; r < 256; r++) { 
    analogWrite(REDPIN, r);
    delay(FADESPEED);
  } 
  // fade from violet to red
  for (b = 255; b > 0; b--) { 
    analogWrite(BLUEPIN, b);
    delay(FADESPEED);
  } 
  // fade from red to yellow
  for (g = 0; g < 256; g++) { 
    analogWrite(GREENPIN, g);
    delay(FADESPEED);
  } 
  // fade from yellow to green
  for (r = 255; r > 0; r--) { 
    analogWrite(REDPIN, r);
    delay(FADESPEED);
  } 
  // fade from green to teal
  for (b = 0; b < 256; b++) { 
    analogWrite(BLUEPIN, b);
    delay(FADESPEED);
  } 
  // fade from teal to blue
  for (g = 255; g > 0; g--) { 
    analogWrite(GREENPIN, g);
    delay(FADESPEED);
  }  
  
}
