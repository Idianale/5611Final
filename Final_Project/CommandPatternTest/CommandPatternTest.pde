Light lamp; 
Light lamp2; 
static final int SAFE = 0, WARNING = 1, DANGER = 2; 
void setup(){
  size(640, 360); 
  background(255); 
  lamp = new Light(); 
  lamp2 = new Light(400,100); 
  
}

void draw(){
  background(255);
  lamp.lightSwitch(); 
  lamp.display();
  delay(500); 
  //lamp2.lightSwitch(); 
  lamp2.display(); 
  delay(500);   
}
