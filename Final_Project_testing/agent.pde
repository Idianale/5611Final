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
  Acquisition(float x, float y, int agentSpawned){
    this.size = 30;
    float spawn_at_x, spawn_at_y;
    // Check for collision with previously spawned agents and obstacles
    boolean noCollision = true;
    for (int s=1; s<15; s++){
      noCollision = true;
      spawn_at_x = (x-size/2*s)+(r.nextFloat()*size*s);
      spawn_at_y = (y-size/2*s)+(r.nextFloat()*size*s);
      // Check for collision with other acquisition agents
      for (int i=0; i<agentSpawned; i++){
        if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, acquisition.get(i))){
          noCollision = false;
          break;
        }
      }
      // Check for collision with obstacles
      if (noCollision){
        for (int i=0; i<obstacles.size(); i++){
          if (obstacles.get(i).obstacleCollision(spawn_at_x, spawn_at_y, this.size)){
            noCollision = false;
            break;
          }
        }
      }
      if (noCollision){
        this.pos = new PVector(spawn_at_x,spawn_at_y,0);
        break;
      }
    }
    // If no viable position near herd, spawn location is random
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
  Recon(float x, float y, int agentSpawned){
    this.size = 20;
    float spawn_at_x, spawn_at_y;
    // Check for collision with previously spawned agents and obstacles
    boolean noCollision = true;
    for (int s=5; s<20; s++){
      noCollision = true;
      spawn_at_x = (x-size/2*s)+(r.nextFloat()*size*s);
      spawn_at_y = (y-size/2*s)+(r.nextFloat()*size*s);
      // Check for collision with other recon agents
      for (int i=0; i<agentSpawned; i++){
        if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, recon.get(i))){
          noCollision = false;
          break;
        }
      }
      // Check for collision with acquisition agents
      if (noCollision){
        for (int i=0; i<acquisition.size(); i++){
          if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, acquisition.get(i))){
            noCollision = false;
            break;
          }
        }
      }
      // Check for collision with obstacles
      if (noCollision){
        for (int i=0; i<obstacles.size(); i++){
          if (obstacles.get(i).obstacleCollision(spawn_at_x, spawn_at_y, this.size)){
            noCollision = false;
            break;
          }
        }
      }
      if (noCollision){
        this.pos = new PVector(spawn_at_x,spawn_at_y,0);
        break;
      }
    }
    // If no viable position near herd, spawn location is random
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
  Predator(float herdX, float herdY, int agentSpawned, float minDistFromHerd){
    this.size = 20;
    
    float spawn_at_x, spawn_at_y, dist_x, dist_y;
    // Check for collision with previously spawned agents and obstacles
    boolean noCollision = true;
    for (int s=0; s<20; s++){
      noCollision = true;
      spawn_at_x = r.nextFloat()*fieldWidth;
      spawn_at_y = r.nextFloat()*fieldHeight;
      // Check for minimum distance from herd
      dist_x = spawn_at_x - herdX;
      dist_y = spawn_at_y - herdY;
      if (((dist_x*dist_x) + (dist_y*dist_y)) < minDistFromHerd) noCollision = false;
      // Check for collision with other predators
      for (int i=0; i<agentSpawned; i++){
        if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, predator.get(i))){
          noCollision = false;
          break;
        }
      }
      // Check for collision with acquisition agents
      if (noCollision){
        for (int i=0; i<acquisition.size(); i++){
          if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, acquisition.get(i))){
            noCollision = false;
            break;
          }
        }
      }
      // Check for collision with recon agents
      if (noCollision){
        for (int i=0; i<recon.size(); i++){
          if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, recon.get(i))){
            noCollision = false;
            break;
          }
        }
      }
      // Check for collision with obstacles
      if (noCollision){
        for (int i=0; i<obstacles.size(); i++){
          if (obstacles.get(i).obstacleCollision(spawn_at_x, spawn_at_y, this.size)){
            noCollision = false;
            break;
          }
        }
      }
      if (noCollision){
        this.pos = new PVector(spawn_at_x,spawn_at_y,0);
        break;
      }
    }
  }
  
  void display() {
    fill(150, 50, 50);
    ellipse(this.pos.x,this.pos.y,this.size,this.size);
    noFill();
  }
}
