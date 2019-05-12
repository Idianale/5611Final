class Agent {
  PVector pos; 
  PVector vel; 
  PVector acc; 
  float dir;
  float size;
  float maxVelocity;
  float visionLength;
  float visionX1, visionY1, visionX2, visionY2;
  float[][] nodePos = new float[NODECOUNT][2];
  float[][] nodeCost = new float[NODECOUNT][NODECOUNT];
  IntList answer  = new IntList();
  boolean answerFound = false;
  WorldState ws; 

  Agent() {
    pos = new PVector(190, 110, 0);
    vel = new PVector(0, 0, 0); 
    acc = new PVector(0, 0, 0); 
    dir = r.nextFloat()*360;
    size = 20;
    maxVelocity = 100;
  }

  public void run(float dt) {
    update(dt); 
    display();
  }

  void update(float dt) {
  }

  void display() {
  }

  // Return true if spawn coordinate collides with agent
  boolean spawnCollisionAgent(float x, float y, float size, Agent agent) {
    float dist_x = x - agent.pos.x;
    float dist_y = y - agent.pos.y;
    float dist = sqrt( (dist_x*dist_x) + (dist_y*dist_y) );
    if (dist < (agent.size/2+size/2)) {
      return true;
    } else return false;
  }

  boolean validAgentCSpace(float x, float y) {
    for (Obstacle obstacle : obstacles) {
      if (obstacle.obstacleCollision(x, y, this.size)) {
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


  // Calculates next node while moving along a path
  int nextNode;
  int nodeRadius = 5;
  void calculateNextNode() {
    float dx, dy;
    // If at goal, do nothing
    if (nextNode!=(answer.size()-1)) {
      // Change nextNode to furthest visible node 
      for (int j=(answer.size()-1); j>nextNode; j--) {
        dx = (pos.x-nodePos[answer.get(j)][0]);
        dy = (pos.y-nodePos[answer.get(j)][1]);
        if (!agentNodePathCollision(j, sqrt(dx*dx + dy*dy))) {
          nextNode = j;
          break;
        }
      }     

      // If agent is within nodeRadius of node, go to next node
      dx = (pos.x-nodePos[answer.get(nextNode)][0]);
      dy = (pos.y-nodePos[answer.get(nextNode)][1]);
      if ( (dx*dx + dy*dy) < (nodeRadius*nodeRadius) ) {
        nextNode++;
      }
    }
  }
  boolean agentNodePathCollision(int node, float dist) {
    int intervalCount = (int)(dist*10);
    float intervalDirX = (nodePos[answer.get(node)][0]-pos.x)/intervalCount;
    float intervalDirY = (nodePos[answer.get(node)][1]-pos.y)/intervalCount;
    float intervalPosX = pos.x;
    float intervalPosY = pos.y;
    for (int k=0; k<intervalCount; k++) {
      if (!validAgentCSpace(intervalPosX, intervalPosY)) return true;
      intervalPosX += intervalDirX;
      intervalPosY += intervalDirY;
    }
    return false;
  }


  // Calculates accelaration/forces
  float goalDistance = resourceSize/2 + size/2;
  void calculateForces() {
    // Calculate Force Towards Goal
    float tempGoalX = nodePos[answer.get(nextNode)][0];
    float tempGoalY = nodePos[answer.get(nextNode)][1];
    float tempX = dirX(pos.x, tempGoalX);
    float tempY = dirY(pos.y, tempGoalY);
    float tempTotal = sqrt(tempX*tempX + tempY*tempY);
    
    if (!withinArc(acc.x,acc.y,tempX,tempY,PI/8)){
      if (withinArc(acc.x,acc.y,tempX,tempY,PI)){
        acc.x = 0;
        acc.y = 0;
      }
      else if ((vel.x > (maxVelocity/5))||(vel.y > (maxVelocity/5))){
        acc.x = -vel.x/2;
        acc.y = -vel.y/2;
      }
      else{
        acc.x = 0;
        acc.y = 0;
      }
    }
    // If next node is the goal
    if (nextNode==(answer.size()-1)) {
      if (dist(tempGoalX, tempGoalY, pos.x, pos.y) > (goalDistance)) {
        if (tempTotal<(5/3)) {
          acc.x += tempX*3;
          acc.y += tempY*3;
        } else {
          acc.x += tempX/tempTotal*5;
          acc.y += tempY/tempTotal*5;
        }
      }
    } else {
      acc.x += tempX/tempTotal*5;
      acc.y += tempY/tempTotal*5;
    }
    // limit max accelaration
    //float totalAcc = sqrt(acc.x*acc.x + acc.y*acc.y);
    //if (totalAcc > maxVelocity){
    //  acc.x = acc.x*maxVelocity/totalAcc;
    //  acc.y = acc.y*maxVelocity/totalAcc;
    //}
  }
  float dirX(float x1, float x2) {
    return (x2-x1);
  }
  float dirY(float y1, float y2) {
    return (y2-y1);
  }
  boolean sameSign(float a, float b){
    if (a>=0) {
      if (b>=0){ return true;
      } else return false;
    }
    else{
      if (b<=0){ return true;
      } else return false;
    }
  }
  boolean withinArc(float x1, float y1, float x2, float y2, float arc){
    if ((atan2(x1,y1) - atan2(x2,y2)) < arc){
      if ((atan2(x1,y1) - atan2(x2,y2)) > -arc){
        return true;
      }
    }
    return false;
  }



  // Calculates velocities for movement (capped by maxVelocity)
  void calculateVelocities(float dt, boolean stopAtGoal) {
    vel.x += (acc.x*dt);
    vel.y += (acc.y*dt);

    float agentVelocity = sqrt(vel.x*vel.x + vel.y*vel.y);
    if (agentVelocity > maxVelocity) {
      vel.x = vel.x/agentVelocity*maxVelocity;
      vel.y = vel.y/agentVelocity*maxVelocity;
    }

    if (stopAtGoal) {
      if (nextNode==(answer.size()-1)) {
        float goalDistance = resourceSize/2 + size/2;
        float tempGoalX = nodePos[answer.get(nextNode)][0];
        float tempGoalY = nodePos[answer.get(nextNode)][1];
        float dist = dist(tempGoalX, tempGoalY, pos.x, pos.y);
        if (dist < goalDistance) {
          if (dist < (goalDistance*0.8)) {
            vel.x = 0;
            vel.y = 0;
          }
          vel.x = vel.x*0.5;
          vel.y = vel.y*0.5;
        }
      }
    }
  }

  // Calculate position for movement
  void calculatePositions(float dt) {
    pos.x += (vel.x*dt);
    pos.y += (vel.y*dt);
  }


  // Calculate collisions
  void calculateCollisions() {
    float dx, dy, CRadius;
    // Check for collision with obstacles
    // If collision with obstacle, move agent to edge of obstacle
    for (Obstacle obstacle : obstacles) {
      dx = (pos.x - obstacle.position.x);
      dy = (pos.y - obstacle.position.y);
      CRadius = (obstacle.size/2 + size/2);
      if ( (dx*dx + dy*dy) < (CRadius*CRadius) ) {
        // Move agent to edge of obstacle
        float tempX = pos.x - obstacle.position.x;
        float tempY = pos.y - obstacle.position.y;
        float totalTemp = sqrt(tempX*tempX + tempY*tempY);
        pos.x = obstacle.position.x + tempX/totalTemp*(obstacle.size/2+size/2+1);
        pos.y = obstacle.position.y + tempY/totalTemp*(obstacle.size/2+size/2+1);
      }
    }
    // Check for collision with walls
    if (pos.x < (size/2)) {  // Left Wall
      pos.x = size/2 + 1;
      if (vel.x < 0) vel.x = 1;
    }
    if (pos.x > (fieldWidth - size/2)) {  // Right Wall
      pos.x = fieldWidth - size/2 - 1;
      if (vel.x > 0) vel.x = -1;
    }
    if (pos.y < (size/2)) {  // Top Wall
      pos.y = size/2 + 1;
      if (vel.y < 0) vel.y = 1;
    }
    if (pos.y > (fieldHeight - size/2)) {  // Bottom Wall
      pos.y = fieldHeight - size/2 - 1;
      if (vel.y > 0) vel.y = -1;
    }
  }

  // Calculate agent direction
  void calculateRotations(float dt) {
    if ((vel.x!=0)&&(vel.y!=0)) dir = atan2(vel.x, vel.y);
    visionX1 = pos.x + sin(dir-PI/8)*visionLength;
    visionY1 = pos.y + cos(dir-PI/8)*visionLength;
    visionX2 = pos.x + sin(dir+PI/8)*visionLength;
    visionY2 = pos.y + cos(dir+PI/8)*visionLength;
    //// Commented out code is only for rendering agents as rolling spheres
    //float theta = atan2(vel.x, vel.y);
    //float phi = sqrt(vel.x*vel.x + vel.y*vel.y);
    //agentRotTheta[i]=theta; // TEST
    //agentRotSpeed[i]+=phi*dt/agentRadius/2;
    //if (agentRotSpeed[i] > radians(360)) agentRotSpeed[i] = agentRotSpeed[i] - radians(360);
  }
}

class WorldState {
  WorldState() {
  };
}

/*
=========================================
 ACQUISITION               
 =========================================
 */

class Acquisition extends Agent {
  Resource targetResource;

  Acquisition() {
    size = 30;
    maxVelocity = 100;
    this.pos = new PVector(r.nextFloat()*fieldWidth, r.nextFloat()*fieldHeight, 0);
    visionLength = 50;
    visionX1 = pos.x + sin(dir-PI/8)*visionLength;
    visionY1 = pos.y + cos(dir-PI/8)*visionLength;
    visionX2 = pos.x + sin(dir+PI/8)*visionLength;
    visionY2 = pos.y + cos(dir+PI/8)*visionLength;
  }
  Acquisition(float x, float y, int agentSpawned) {
    size = 30;
    maxVelocity = 100;
    float spawn_at_x, spawn_at_y;
    // Check for collision with previously spawned agents and obstacles
    boolean noCollision = true;
    for (int s=1; s<15; s++) {
      noCollision = true;
      spawn_at_x = (x-size/2*s)+(r.nextFloat()*size*s);
      spawn_at_y = (y-size/2*s)+(r.nextFloat()*size*s);
      // Check for collision with other acquisition agents
      for (int i=0; i<agentSpawned; i++) {
        if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, acquisition.get(i))) {
          noCollision = false;
          break;
        }
      }
      // Check for collision with obstacles
      if (noCollision) {
        for (int i=0; i<obstacles.size(); i++) {
          if (obstacles.get(i).obstacleCollision(spawn_at_x, spawn_at_y, this.size)) {
            noCollision = false;
            break;
          }
        }
      }
      if (noCollision) {
        this.pos = new PVector(spawn_at_x, spawn_at_y, 0);
        break;
      }
    }
    // If no viable position near herd, spawn location is random
    if (!noCollision) this.pos = new PVector(r.nextFloat()*fieldWidth, r.nextFloat()*fieldHeight, 0);
    visionLength = 50;
    visionX1 = pos.x + sin(dir-PI/8)*visionLength;
    visionY1 = pos.y + cos(dir-PI/8)*visionLength;
    visionX2 = pos.x + sin(dir+PI/8)*visionLength;
    visionY2 = pos.y + cos(dir+PI/8)*visionLength;
  } 

  void display() {
    // Draw Agent
    fill(50, 150, 50);
    ellipse(this.pos.x, this.pos.y, this.size, this.size);
    noFill();
  }
  void displayCone() {
    // Draw Vision Cone
    fill(50, 150, 50, 100);
    triangle(this.pos.x, this.pos.y, visionX1, visionY1, visionX2, visionY2);
    noFill();
  }

  // Behaviors

  // Find the closest nondepleted resource
  // Save the resource under variable targetResource
  // Find path to this resource using FindPathToResource
  void LocateResource() {
    float shortestDistance = Float.POSITIVE_INFINITY;
    Resource closestResource = null;
    float dist_x, dist_y, dist;
    for (Resource resource : resources) {
      if (resource.quantity > 0) {
        dist_x = this.pos.x - resource.position.x;
        dist_y = this.pos.y - resource.position.y;
        dist = sqrt((dist_x*dist_x) + (dist_y*dist_y));
        if (dist < shortestDistance) {
          shortestDistance = dist;
          closestResource = resource;
        }
      }
    }
    targetResource = closestResource;
  }

  // Find path to targetResource
  // Use LocateResource() set targetResource
  void FindPathToResource() {
    for (int i=0; i<10; i++) {
      initializeNodes(targetResource.position.x, targetResource.position.y);
      calcNodeCostMatrix();
      if (search(this)) {
        answerFound = true;
        break;
      }
    }
    nextNode = 0;
  }

  // Move to resource along path stored in this.answer
  // Call this function each frame while moving towards resource
  // Always call LocateResource() and FindPathToResource() before initially calling this function
  void MoveToResource(float dt) {
    calculateNextNode();
    calculateForces();
    calculateVelocities(dt, true);
    calculatePositions(dt);
    calculateCollisions();
    calculateRotations(dt);
  }

  // Gradually deplete resource
  // Call this function each frame while sitting at a resource
  void DepleteResource(float dt) {
    if (targetResource.quantity > 0) {
      targetResource.quantity = targetResource.quantity - 100*dt;
      // Note: Increase scoreboard count by dt
    } else {
      // Note: LocateResource
    }
  }
  
  // Moves away from predator
  // Call this function each frame while fleeing from predator
  void FleeFromPredator(float dt){
    calculateFleeForces();
    calculateVelocities(dt, true);
    calculatePositions(dt);
    calculateCollisions();
    calculateRotations(dt);
  }
  void calculateFleeForces(){
    float awayFromPredatorX = pos.x - predLastSeen.x;
    float awayFromPredatorY = pos.y - predLastSeen.y;
    if(awayFromPredatorX > 0) awayFromPredatorX = awayFromPredatorX/awayFromPredatorX*maxVelocity;
    if(awayFromPredatorX < 0) awayFromPredatorX = awayFromPredatorX/-awayFromPredatorX*maxVelocity;
    if(awayFromPredatorY > 0) awayFromPredatorY = awayFromPredatorY/awayFromPredatorY*maxVelocity;
    if(awayFromPredatorY < 0) awayFromPredatorY = awayFromPredatorY/-awayFromPredatorY*maxVelocity;
    
    if (!withinArc(acc.x,acc.y,awayFromPredatorX,awayFromPredatorY,PI)){
      acc.x = 0;
      acc.y = 0;
    }
    else {
      acc.x += awayFromPredatorX;
      acc.y += awayFromPredatorY;
    }
  }
  
  
}






/*
===================================
 RECON               
 ===================================
 */

class Recon extends Agent {
  Recon() {
    this.size = 20;
    maxVelocity = 100;
    this.pos = new PVector(r.nextFloat()*fieldWidth, r.nextFloat()*fieldHeight, 0);
    visionLength = 50;
    visionX1 = pos.x + sin(dir-PI/8)*visionLength;
    visionY1 = pos.y + cos(dir-PI/8)*visionLength;
    visionX2 = pos.x + sin(dir+PI/8)*visionLength;
    visionY2 = pos.y + cos(dir+PI/8)*visionLength;
  }
  Recon(float x, float y, int agentSpawned) {
    this.size = 20;
    float spawn_at_x, spawn_at_y;
    // Check for collision with previously spawned agents and obstacles
    boolean noCollision = true;
    for (int s=5; s<20; s++) {
      noCollision = true;
      spawn_at_x = (x-size/2*s)+(r.nextFloat()*size*s);
      spawn_at_y = (y-size/2*s)+(r.nextFloat()*size*s);
      // Check for collision with other recon agents
      for (int i=0; i<agentSpawned; i++) {
        if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, recon.get(i))) {
          noCollision = false;
          break;
        }
      }
      // Check for collision with acquisition agents
      if (noCollision) {
        for (int i=0; i<acquisition.size(); i++) {
          if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, acquisition.get(i))) {
            noCollision = false;
            break;
          }
        }
      }
      // Check for collision with obstacles
      if (noCollision) {
        for (int i=0; i<obstacles.size(); i++) {
          if (obstacles.get(i).obstacleCollision(spawn_at_x, spawn_at_y, this.size)) {
            noCollision = false;
            break;
          }
        }
      }
      if (noCollision) {
        this.pos = new PVector(spawn_at_x, spawn_at_y, 0);
        break;
      }
    }
    // If no viable position near herd, spawn location is random
    if (!noCollision) this.pos = new PVector(r.nextFloat()*fieldWidth, r.nextFloat()*fieldHeight, 0);
    visionLength = 50;
    visionX1 = pos.x + sin(dir-PI/8)*visionLength;
    visionY1 = pos.y + cos(dir-PI/8)*visionLength;
    visionX2 = pos.x + sin(dir+PI/8)*visionLength;
    visionY2 = pos.y + cos(dir+PI/8)*visionLength;
  }
  void display() {
    fill(50, 50, 150);
    ellipse(this.pos.x, this.pos.y, this.size, this.size);
    noFill();
  }
}

/*
======================================
 PREDATOR               
 ======================================
 */

class Predator extends Agent {
  Predator() {
    this.size = 20;
    maxVelocity = 100;
    this.pos = new PVector(r.nextFloat()*fieldWidth, r.nextFloat()*fieldHeight, 0);
  }
  Predator(float herdX, float herdY, int agentSpawned, float minDistFromHerd) {
    this.size = 20;
    maxVelocity = 100;

    float spawn_at_x, spawn_at_y, dist_x, dist_y;
    // Check for collision with previously spawned agents and obstacles
    boolean noCollision = true;
    for (int s=0; s<20; s++) {
      noCollision = true;
      spawn_at_x = r.nextFloat()*fieldWidth;
      spawn_at_y = r.nextFloat()*fieldHeight;
      // Check for minimum distance from herd
      dist_x = spawn_at_x - herdX;
      dist_y = spawn_at_y - herdY;
      if (sqrt((dist_x*dist_x) + (dist_y*dist_y)) < minDistFromHerd) noCollision = false;
      // Check for collision with other predators
      if (noCollision) {
        for (int i=0; i<agentSpawned; i++) {
          if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, predator.get(i))) {
            noCollision = false;
            break;
          }
        }
      }
      // Check for collision with acquisition agents
      if (noCollision) {
        for (int i=0; i<acquisition.size(); i++) {
          if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, acquisition.get(i))) {
            noCollision = false;
            break;
          }
        }
      }
      // Check for collision with recon agents
      if (noCollision) {
        for (int i=0; i<recon.size(); i++) {
          if (this.spawnCollisionAgent(spawn_at_x, spawn_at_y, this.size, recon.get(i))) {
            noCollision = false;
            break;
          }
        }
      }
      // Check for collision with obstacles
      if (noCollision) {
        for (int i=0; i<obstacles.size(); i++) {
          if (obstacles.get(i).obstacleCollision(spawn_at_x, spawn_at_y, this.size)) {
            noCollision = false;
            break;
          }
        }
      }
      if (noCollision) {
        this.pos = new PVector(spawn_at_x, spawn_at_y, 0);
        break;
      }
    }
  }

  void display() {
    fill(150, 50, 50);
    ellipse(this.pos.x, this.pos.y, this.size, this.size);
    noFill();
  }
}
