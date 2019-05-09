class Agent{
  PVector pos; 
  PVector vel; 
  PVector acc; 
  WorldState ws; 
  
  Agent(){
    pos = new PVector(190,110,0);
    vel = new PVector(0,0,0); 
    acc = new PVector(0,0,0); 
  }
  
  public void run(){
    update(); 
    display(); 
  }
  
  void update(){
  }
  
  void display(){
  }
}

class WorldState{
  WorldState(){
  }; 
}
