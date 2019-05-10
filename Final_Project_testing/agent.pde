class Agent{
  PVector pos; 
  PVector vel; 
  PVector acc; 
  float size;
  float dir;
  WorldState ws; 
  
  Agent(){
    pos = new PVector(190,110,0);
    vel = new PVector(0,0,0); 
    acc = new PVector(0,0,0); 
    dir = r.nextFloat()*360;
  }
  
  public void run(){
    update(); 
    display(); 
  }
  
  void update(){
  }
  
  void display(){
  }
  
  // Return true if spawn coordinate collides with agent
  boolean spawnCollisionAgent(float x, float y, float size, Agent agent){
    float dist_x = x - agent.pos.x;
    float dist_y = y - agent.pos.y;
    float dist = sqrt( (dist_x*dist_x) + (dist_y*dist_y) );
    print (dist, agent.size, size, "\n"); // TODO: Remove this line
    print(x, y,"\n"); // TODO: Remove this line
    if (dist < (agent.size+size)){
      return true;
    }
    else return false;
  }
  
}

class WorldState{
  WorldState(){
  }; 
}


class Acquisition extends Agent{
  Acquisition(){
    this.size = 30;
    this.pos = new PVector(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight,0);
  }
  Acquisition(float x, float y, int agentSpawned, ArrayList<Acquisition> acquisition){
    this.size = 30;
    float spawn_at_x, spawn_at_y;
    // Check for collision with all recon and acquisition agents
    boolean noCollision = true;
    for (int s=1; s<10; s++){
      noCollision = true;
      spawn_at_x = (x-size*s)+(r.nextFloat()*size*2*s);
      spawn_at_y = (y-size*s)+(r.nextFloat()*size*2*s);
      for (int i=0; i<agentSpawned; i++){
        if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, acquisition.get(i))){
          noCollision = false;
          break;
        }
      }
      if (noCollision){
        this.pos = new PVector(spawn_at_x,spawn_at_y,0);
        print(agentSpawned,spawn_at_x, spawn_at_y,"\n"); // TODO: Remove this line
        break;
      }
    }
    if (!noCollision) this.pos = new PVector(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight,0);
  }  
  void display() {
    fill(50, 150, 50);
    ellipse(this.pos.x,this.pos.y,this.size,this.size);
    noFill();
  }
}


class Recon extends Agent{
  Recon(){
    this.size = 20;
    this.pos = new PVector(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight,0);
  }
  Recon(float x, float y, int agentSpawned, ArrayList<Recon> recon, ArrayList<Acquisition> acquisition){
    this.size = 20;
    float spawn_at_x, spawn_at_y;
    // Check for collision with all recon agents
    boolean noCollision = true;
    for (int s=5; s<15; s++){
      noCollision = true;
      spawn_at_x = (x-size*s)+(r.nextFloat()*size*2*s);
      spawn_at_y = (y-size*s)+(r.nextFloat()*size*2*s);
      for (int i=0; i<agentSpawned; i++){
        if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, recon.get(i))){
          noCollision = false;
          break;
        }
      }
      if (noCollision){
        for (int i=0; i<acquisition.size(); i++){
          if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, acquisition.get(i))){
            noCollision = false;
            break;
          }
        }
      }
      if (noCollision){
        this.pos = new PVector(spawn_at_x,spawn_at_y,0);
        print(agentSpawned,spawn_at_x, spawn_at_y,"\n"); // TODO: Remove this line
        break;
      }
    }
    if (!noCollision) this.pos = new PVector(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight,0);
  }
  void display() {
    fill(50, 50, 150);
    ellipse(this.pos.x,this.pos.y,this.size,this.size);
    noFill();
  }
}


class Predator extends Agent{
  Predator(){
    this.size = 20;
    this.pos = new PVector(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight,0);
  }
  void display() {
    fill(150, 50, 50);
    ellipse(this.pos.x,this.pos.y,this.size,this.size);
    noFill();
  }
}
