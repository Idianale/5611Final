class Agent{
  PVector pos; 
  PVector vel; 
  PVector acc; 
  float size;
  float dir;
  float[][] nodePos = new float[NODECOUNT][2];
  float[][] nodeCost = new float[NODECOUNT][NODECOUNT];
  IntList answer  = new IntList();
  boolean answerFound = false;
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
    if (dist < (agent.size/2+size/2)){
      return true;
    }
    else return false;
  }
  
  boolean validAgentCSpace(float x, float y){
    for (Obstacle obstacle : obstacles) {
      if (obstacle.obstacleCollision(x, y, this.size)){
        return false;
      }
    }
    return true;
  }
  
  void initializeNodes(float goalX, float goalY) {
    nodePos[0][0] = this.pos.x;
    nodePos[0][1] = this.pos.y;
    // Goal Nodes
    nodePos[NODECOUNT-1][0] = goalX;
    nodePos[NODECOUNT-1][1] = goalY;
    // Other Nodes
    float x, y;
    for (int i=1; i<(NODECOUNT-1); i++) {
      x = random(this.size, fieldWidth-this.size);
      y = random(this.size, fieldHeight-this.size);
      if (validAgentCSpace(x, y)) {
        nodePos[i][0] = x;
        nodePos[i][1] = y;
      } else { 
        i--;
      }
    }
  }
  
  // If a line from node i to j does not collide with anything in the agent C-Space, 
  // then nodeCost[i][j] contains the distance between i and j. Otherwise, nodeCost[i][j] contains Infinity.
  void calcNodeCostMatrix() {
    for (int i=0; i<NODECOUNT; i++) {
      for (int j=0; j<NODECOUNT; j++) {
        // Check for intersection
        nodeCost[i][j] = nodePathCollision(i, j, calcNodeCost(i, j));
      }
    }
  }
  float nodePathCollision(int i, int j, float dist) {
    int intervalCount = (int)(dist);
    float intervalDirX = (nodePos[j][0]-nodePos[i][0])/intervalCount;
    float intervalDirY = (nodePos[j][1]-nodePos[i][1])/intervalCount;
    float intervalPosX = nodePos[i][0];
    float intervalPosY = nodePos[i][1];
    for (int k=0; k<intervalCount; k++) {
      if (!validAgentCSpace(intervalPosX, intervalPosY)) return Float.POSITIVE_INFINITY;
      intervalPosX += intervalDirX;
      intervalPosY += intervalDirY;
    }
    return dist;
  }
  float calcNodeCost(int i, int j) {
    float dx = nodePos[i][0]-nodePos[j][0];
    float dy = nodePos[i][1]-nodePos[j][1];
    return sqrt(dx*dx + dy*dy);
  }
  
}

class WorldState{
  WorldState(){
  }; 
}

/*
=========================================
               ACQUISITION               
=========================================
*/

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
  
  // behaviors
  
  // Find and return the closest nondepleted resource
  Resource LocateResource(){
    float shortestDistance = Float.POSITIVE_INFINITY;
    Resource closestResource = null;
    float dist_x, dist_y, dist;
    for (Resource resource : resources) {
      if (resource.quantity > 0) {
        dist_x = this.pos.x - resource.position.x;
        dist_y = this.pos.y - resource.position.y;
        dist = sqrt((dist_x*dist_x) + (dist_y*dist_y));
        if (dist < shortestDistance){
          shortestDistance = dist;
          closestResource = resource;
        }
      }
    }
    return closestResource;
  }
  
  // Find path to resource
  void FindPathToResource(Resource resource){
    for (int i=0; i<5; i++) {
      initializeNodes(resource.position.x, resource.position.y);
      calcNodeCostMatrix();
      if (search(this)) {
        answerFound = true;
        break;
      }
    }
  }
  
  // Move to resource along path stored in this.answer
  void MoveToResource(){
    /*
    calculateNextNode();
    calculateForces();
    calculateVelocities(dt);
    calculatePositions(dt);
    calculateCollisions();
    calculateRotations(dt);
    */
  }
  
}

/*
===================================
               RECON               
===================================
*/

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

/*
======================================
               PREDATOR               
======================================
*/

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
      if (sqrt((dist_x*dist_x) + (dist_y*dist_y)) < minDistFromHerd) noCollision = false;
      // Check for collision with other predators
      if (noCollision){
        for (int i=0; i<agentSpawned; i++){
          if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, predator.get(i))){
            noCollision = false;
            break;
          }
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
