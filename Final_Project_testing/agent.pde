class Agent { //<>//
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
    // Collision with Obstacle
    for (Obstacle obstacle : obstacles) {
      if (obstacle.obstacleCollision(x, y, this.size)) {
        return false;
      }
    }
    // Collision with Wall
    if (x < (this.size)) return false;  // Left Wall
    if (x > (fieldWidth - this.size)) return false;  // Right Wall
    if (y < (this.size)) return false;  // Top Wall
    if (y > (fieldHeight - this.size)) return false;  // Bottom Wall
    // If no collisions, return true (valid state)
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
      if (nextNode!=(answer.size()-1)) {
        dx = (pos.x-nodePos[answer.get(nextNode)][0]);
        dy = (pos.y-nodePos[answer.get(nextNode)][1]);
        if ( (dx*dx + dy*dy) < (nodeRadius*nodeRadius) ) {
          nextNode++;
        }
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
  float goalDistanceThreshold = resourceSize/2 + size/2;
  void calculateForces() {
    // Calculate Force Towards Goal
    float tempGoalX = nodePos[answer.get(nextNode)][0];
    float tempGoalY = nodePos[answer.get(nextNode)][1];
    float tempX = dirX(pos.x, tempGoalX);
    float tempY = dirY(pos.y, tempGoalY);
    float tempTotal = sqrt(tempX*tempX + tempY*tempY);

    if (!withinArc(acc.x, acc.y, tempX, tempY, PI/8)) {
      if (withinArc(acc.x, acc.y, tempX, tempY, PI)) {
        acc.x = 0;
        acc.y = 0;
      } else if ((vel.x > 15)||(vel.y > 15)) {
        acc.x = -vel.x;
        acc.y = -vel.y;
      } else {
        acc.x = 0;
        acc.y = 0;
        vel.x = vel.x * 0.1;
        vel.y = vel.y * 0.1;
        ;
      }
    }
    // If next node is the goal
    if (nextNode==(answer.size()-1)) {
      if (dist(tempGoalX, tempGoalY, pos.x, pos.y) > (goalDistanceThreshold)) {
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
  boolean sameSign(float a, float b) {
    if (a>=0) {
      if (b>=0) { 
        return true;
      } else return false;
    } else {
      if (b<=0) { 
        return true;
      } else return false;
    }
  }
  boolean withinArc(float x1, float y1, float x2, float y2, float arc) {
    if (abs(atan2(y1, x1) - atan2(y2, x2)) < arc) {
      return true;
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
      if (acc.x < 0) acc.x = 0;
      if (vel.x < 0) vel.x = 1;
      //if ((dir > PI/2)&&(dir <= PI)) dir = PI/2;
      //if ((dir > -PI)&&(dir < -PI/2)) dir = -PI/2;
    }
    if (pos.x > (fieldWidth - size/2)) {  // Right Wall
      pos.x = fieldWidth - size/2 - 1;
      if (acc.x > 0) acc.x = 0;
      if (vel.x > 0) vel.x = -1;
      //if ((dir > -PI/2)&&(dir < 0)) dir = -PI/2;
      //if ((dir >= 0)&&(dir < PI/2)) dir = PI/2;
    }
    if (pos.y < (size/2)) {  // Top Wall
      pos.y = size/2 + 1;
      if (acc.y < 0) acc.y = 0;
      if (vel.y < 0) vel.y = 5;
      //if ((dir > 0)&&(dir <= PI/2)) dir = 0;
      //if ((dir > PI/2)&&(dir <= PI)) dir = PI;
    }
    if (pos.y > (fieldHeight - size/2)) {  // Bottom Wall
      pos.y = fieldHeight - size/2 - 1;
      if (acc.y > 0) acc.y = 0;
      if (vel.y > 0) vel.y = -1;
      //if ((dir > -PI)&&(dir <= -PI/2)) dir = PI;
      //if ((dir > PI/2)&&(dir <= PI)) dir = 0;
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

  boolean trianglePointCollision(float tx1, float ty1, float tx2, float ty2, 
    float tx3, float ty3, float px, float py) {
    float trianglePoint1 = abs((tx1-px)*(ty2-py) - (tx2-px)*(ty1-py));
    float trianglePoint2 = abs((tx2-px)*(ty3-py) - (tx3-px)*(ty2-py));
    float trianglePoint3 = abs((tx3-px)*(ty1-py) - (tx1-px)*(ty3-py));
    float triangleArea = abs((tx2-tx1)*(ty3-ty1) - (tx3-tx1)*(ty2-ty1)); // Heron's Formula
    if (int(trianglePoint1 + trianglePoint2 + trianglePoint3) == int(triangleArea)) {
      return true;
    } else return false;
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
  // Saves the resource under variable targetResource
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
      if (search(this,3)) {
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
    calculateAcquisitionForces();
    calculateVelocities(dt, true);
    calculatePositions(dt);
    calculateCollisions();
    calculateRotations(dt);
  }
  void calculateAcquisitionForces() {
    calculateForces();
    // Force away from nearby acquisiton agents
    for (Acquisition acquisition : acquisition) {
      if (acquisition!=this) {
        if (dist(pos.x, pos.y, acquisition.pos.x, acquisition.pos.y)<size) {
          float dir_x = pos.x - acquisition.pos.x;
          if (dir_x > 0) dir_x = dir_x/dir_x;
          if (dir_x < 0) dir_x = dir_x/-dir_x;
          float dir_y = pos.y - acquisition.pos.y;
          if (dir_y > 0) dir_y = dir_y/dir_y;
          if (dir_y < 0) dir_y = dir_y/-dir_y;
          acc.x+=dir_x*maxVelocity;
          acc.y+=dir_y*maxVelocity;
        }
      }
    }
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

  // Moves away from predator's last seen location
  // Call this function each frame while fleeing from predator
  void FleeFromPredator(float dt) {
    calculateFleeForces();
    calculateVelocities(dt, true);
    calculatePositions(dt);
    calculateCollisions();
    calculateRotations(dt);
  }
  void calculateFleeForces() {
    float awayFromPredatorX = pos.x - predLastSeen.x;
    float awayFromPredatorY = pos.y - predLastSeen.y;
    if (awayFromPredatorX > 0) awayFromPredatorX = awayFromPredatorX/awayFromPredatorX*maxVelocity;
    if (awayFromPredatorX < 0) awayFromPredatorX = awayFromPredatorX/-awayFromPredatorX*maxVelocity;
    if (awayFromPredatorY > 0) awayFromPredatorY = awayFromPredatorY/awayFromPredatorY*maxVelocity;
    if (awayFromPredatorY < 0) awayFromPredatorY = awayFromPredatorY/-awayFromPredatorY*maxVelocity;
    if (!withinArc(acc.x, acc.y, awayFromPredatorX, awayFromPredatorY, PI)) {
      acc.x = 0;
      acc.y = 0;
    } else {
      acc.x += awayFromPredatorX;
      acc.y += awayFromPredatorY;
    }
    // Collision Avoidance Forces
    collisionForce(50);
    // If agent will soon collide with wall, force away from wall
    if (pos.x < (5 + size/2)) {  // Left Wall
      if (vel.x < 0) acc.x += maxVelocity*10;
    }
    if (pos.x > (fieldWidth -5 - size/2)) {  // Right Wall
      if (vel.x > 0) acc.x -= maxVelocity*10;
    }
    if (pos.y < (5 + size/2)) {  // Top Wall
      if (vel.y < 0) acc.y += maxVelocity*10;
    }
    if (pos.y > (fieldHeight - 5 - size/2)) {  // Bottom Wall
      if (vel.y > 0) acc.y -= maxVelocity*10;
    }
  }
  void collisionForce(float collisionDistance) {  // Collision Avoidance Forces
    float totalVelocity = sqrt(vel.x*vel.x + vel.y*vel.y);
    if (totalVelocity == 0) totalVelocity = 0.01;
    float aheadX = pos.x + (vel.x/totalVelocity*collisionDistance);
    float aheadY = pos.y + (vel.y/totalVelocity*collisionDistance);
    Obstacle obstacle = aheadCollision(pos.x, pos.y, aheadX, aheadY, collisionDistance);
    if (obstacle != null) {
      float tempX = aheadX - obstacle.position.x;
      float tempY = aheadY - obstacle.position.y;
      float tempTotal = sqrt(tempX*tempX + tempY*tempY);
      acc.x += tempX/tempTotal*maxVelocity*10;
      acc.y += tempY/tempTotal*maxVelocity*10;
    }
  }
  Obstacle aheadCollision(float agentX, float agentY, float aheadX, float aheadY, float collisionDistance) {
    int intervalCount = (int)(collisionDistance*10);
    float intervalDirX = (aheadX - agentX)/intervalCount;
    float intervalDirY = (aheadY - agentY)/intervalCount;
    float intervalPosX = agentX;
    float intervalPosY = agentY;
    for (int k=0; k<intervalCount; k++) {
      // Check if a collision occurs between agent position and ahead position
      // If a collision occurs, obstacle = obstacle number, else obstacle = -1
      float dx, dy, CRadius;
      for (Obstacle obstacle : obstacles) {
        dx = (intervalPosX-obstacle.position.x);
        dy = (intervalPosY-obstacle.position.y);
        CRadius = (obstacle.size/2 + size);
        if ( (dx*dx + dy*dy) < (CRadius*CRadius) ) {
          return obstacle;
        }
      }
      intervalPosX += intervalDirX;
      intervalPosY += intervalDirY;
    }
    return null;
  }
  
  
  // Note: Not called by anything
  // Boolean check for whether predator is in Acquisition vision cone
  // Can be used if we only want this single agent to run away instead of setting DANGER
  boolean predatorSpottedAcquisition(){
    for (Predator predator : predator){
      for (float i=0; i<(2*PI); i+=(PI/8)){
        if (predator.trianglePointCollision(
              pos.x,    pos.y,
              visionX1, visionY1,
              visionX2, visionY2,
              predator.pos.x+(cos(predator.dir)*predator.size/2),
              predator.pos.y+(sin(predator.dir)*predator.size/2))) return true;
      }
    }
    return false;
  }

}





/*
===================================
 RECON               
 ===================================
 */

class Recon extends Agent {  

  PVector targetDestination = new PVector();

  Recon() {
    this.size = 20;
    maxVelocity = 200;
    this.pos = new PVector(r.nextFloat()*fieldWidth, r.nextFloat()*fieldHeight, 0);
    visionLength = 150;
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
    visionLength = 150;
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
  void displayCone() {
    // Draw Vision Cone
    fill(50, 50, 150, 100);
    triangle(this.pos.x, this.pos.y, visionX1, visionY1, visionX2, visionY2);
    noFill();
  }

  // Behaviors

  // Find a "good" patrol destination
  // Call once before FindPatrolPath();
  // Prioritizes location near gatherers but further from other recon agents
  void FindPatrolDestination() {
    float potentialX, potentialY;
    boolean locationFound;
    float maxAcquisitionDistance = 300;
    float minReconDistance = 200;
    while (true) {
      locationFound = true;
      potentialX = r.nextFloat()*fieldWidth;
      potentialY = r.nextFloat()*fieldHeight;
      // Check if in valid space 
      if (!validAgentCSpace(potentialX, potentialY)) locationFound = false;
      // Check if at least min distance from other recon
      if (locationFound) {
        for (Recon recon : recon) {
          if (recon!=this) {
            if (dist(potentialX, potentialY, recon.pos.x, recon.pos.y) < minReconDistance) {
              locationFound = false;
              minReconDistance -= 5;
              break;
            }
          }
        }
      }
      // Check if within max distance from acquisition
      if (locationFound) {
        boolean withinRangeTemp = false;
        for (Acquisition acquisition : acquisition) {
          if (dist(potentialX, potentialY, acquisition.pos.x, acquisition.pos.y) < maxAcquisitionDistance) {
            withinRangeTemp = true;
            break;
          }
        }
        if (!withinRangeTemp) locationFound = false;
      }
      if (locationFound) {
        targetDestination = new PVector(potentialX, potentialY, 0);
        break;
      }
    }
  }


  // Find path to targetDestination
  // Call once after FindPatrolDestination() (which sets the targetDestination)
  void FindPatrolPath() {
    for (int i=0; i<10; i++) {
      initializeNodes(targetDestination.x, targetDestination.y);
      calcNodeCostMatrix();
      if (search(this,3)) {
        answerFound = true;
        break;
      }
    }
    nextNode = 0;
  }


  // Move to targetDestination along path stored in this.answer
  // Call this function each frame while moving towards targetDestination
  // Always call FindPatrolDestination() and FindPatrolPath() before initially calling this function
  // Note: Once agent arrives at targetDestination, call FindPatrolDestination() for a new destination
  void MoveToDestination(float dt) {
    calculateNextNode();
    calculatePatrolForces();
    calculateVelocities(dt, true);
    calculatePositions(dt);
    calculateCollisions();
    calculateRotations(dt);
  }
  void calculatePatrolForces() {
    calculateForces();
    collisionForce(10);
  }
  void collisionForce(float collisionDistance) {  // Collision Avoidance Forces
    float totalVelocity = sqrt(vel.x*vel.x + vel.y*vel.y);
    if (totalVelocity == 0) totalVelocity = 0.01;
    float aheadX = pos.x + (vel.x/totalVelocity*collisionDistance);
    float aheadY = pos.y + (vel.y/totalVelocity*collisionDistance);
    Obstacle obstacle = aheadCollision(pos.x, pos.y, aheadX, aheadY, collisionDistance);
    if (obstacle != null) {
      float tempX = aheadX - obstacle.position.x;
      float tempY = aheadY - obstacle.position.y;
      float tempTotal = sqrt(tempX*tempX + tempY*tempY);
      acc.x += tempX/tempTotal*maxVelocity*5;
      acc.y += tempY/tempTotal*maxVelocity*5;
    }
  }
  Obstacle aheadCollision(float agentX, float agentY, float aheadX, float aheadY, float collisionDistance) {
    int intervalCount = (int)(collisionDistance*10);
    float intervalDirX = (aheadX - agentX)/intervalCount;
    float intervalDirY = (aheadY - agentY)/intervalCount;
    float intervalPosX = agentX;
    float intervalPosY = agentY;
    for (int k=0; k<intervalCount; k++) {
      // Check if a collision occurs between agent position and ahead position
      // If a collision occurs, obstacle = obstacle number, else obstacle = -1
      float dx, dy, CRadius;
      for (Obstacle obstacle : obstacles) {
        dx = (intervalPosX-obstacle.position.x);
        dy = (intervalPosY-obstacle.position.y);
        CRadius = (obstacle.size/2 + size);
        if ( (dx*dx + dy*dy) < (CRadius*CRadius) ) {
          return obstacle;
        }
      }
      intervalPosX += intervalDirX;
      intervalPosY += intervalDirY;
    }
    return null;
  }


  // Create path to last known predator location
  // Call once when predator is located, then chase predator with MoveToDestination()
  void FindPathToPredator() {
    for (int i=0; i<10; i++) {
      initializeNodes(predLastSeen.x, predLastSeen.y);
      calcNodeCostMatrix();
      if (search(this,3)) {
        answerFound = true;
        break;
      }
    }
    nextNode = 0;
  }


  // Search for Predator when in WARNING status but predator location is unknown
  // Call once per search attempt
  // Call MoveToDestination() after running this function
  // Note: Default Radius 300? Maybe only attempt so acquisition agents aren't left alone
  void SearchForPredator(float searchRadius) {
    boolean locationSelected;
    float potentialX, potentialY;
    while (true) {
      locationSelected = true;
      potentialX = r.nextFloat()*fieldWidth;
      potentialY = r.nextFloat()*fieldHeight;
      // Check if in valid space 
      if (!validAgentCSpace(potentialX, potentialY)) locationSelected = false;
      // Check if within radius of predLastSeen
      if (locationSelected) {
        if (dist(potentialX, potentialY, predLastSeen.x, predLastSeen.y) > searchRadius) {
          locationSelected = false;
        }
      }
      if (locationSelected) {
        // If location is selected, create path to location
        for (int i=0; i<10; i++) {
          initializeNodes(potentialX, potentialY);
          calcNodeCostMatrix();
          if (search(this,3)) {
            answerFound = true;
            break;
          }
        }
        nextNode = 0;
        break;
      }
    }
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
    maxVelocity = 200;
    this.pos = new PVector(r.nextFloat()*fieldWidth, r.nextFloat()*fieldHeight, 0);
  }
  Predator(float herdX, float herdY, int agentSpawned, float minDistFromHerd) {
    this.size = 20;
    maxVelocity = 200;

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
        if (!validAgentCSpace(spawn_at_x, spawn_at_y)) {
          noCollision = false;
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

  // Behavior

  // Chooses target acquision agent
  // Call once every handful of frames (once per second?) or if rechoosePath == true
  Acquisition target = null;
  Acquisition prevTarget = null;
  boolean rechoosePath = true;
  void ChooseTargetAndPath() {
    // Shallow copy acquisition
    ArrayList<Acquisition> sortedAcquisition =  (ArrayList<Acquisition>) acquisition.clone();
    // First element = closest acquisition agent
    Acquisition closestAcquisition = null;
    float closestDist = Float.POSITIVE_INFINITY;
    for (Acquisition acquisition : sortedAcquisition){
      float dist = dist(pos.x,pos.y,acquisition.pos.x,acquisition.pos.y);
      if (dist < closestDist)
      {
        closestAcquisition = acquisition;
        closestDist = dist;
      }
    }
    sortedAcquisition.add(0,closestAcquisition);
    
    rechoosePath = false;
    // Starting from the closest acquisition agent
    // For each acquisition, check if safe path to acquisition exists, break if safe path found
    for (Acquisition acquisition : sortedAcquisition) {
      for (int i=0; i<3; i++) {
        initializePredatorNodes(acquisition.pos.x, acquisition.pos.y);
        calcPredatorNodeCostMatrix();
        if (search(this,2)) {
          answerFound = true;
          prevTarget = target;
          target = acquisition;
          break;
        }
        else {
          answerFound = false;
        }
      }
      nextNode = 0;
      if (answerFound) break;
    }
  }
  void initializePredatorNodes(float goalX, float goalY) {
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
      if ( (validAgentCSpace(x, y) && (predatorSafeCSpace(x,y))) ) {
        nodePos[i][0] = x;
        nodePos[i][1] = y;
      } else { 
        i--;
      }
    }
  }
  boolean predatorSafeCSpace(float x, float y) {
    for (Recon recon : recon) {
      //Triangle Point Collision
      /*
      visionX1 = pos.x + sin(dir-PI/8)*visionLength;
      visionY1 = pos.y + cos(dir-PI/8)*visionLength;
      visionX2 = pos.x + sin(dir+PI/8)*visionLength;
      visionY2 = pos.y + cos(dir+PI/8)*visionLength;
      */
      if (trianglePointCollision(recon.pos.x - sin(dir)*25,    recon.pos.y - cos(dir)*25,
                                 recon.visionX1 + sin(dir-PI/8)*35, recon.visionY1 + cos(dir-PI/8)*35, 
                                 recon.visionX2 + sin(dir+PI/8)*35, recon.visionY2 + cos(dir+PI/8)*35,
                                 x, y)) {
        return false;
      }
    }
    return true;
  }
  void calcPredatorNodeCostMatrix() {
    for (int i=0; i<NODECOUNT; i++) {
      for (int j=0; j<NODECOUNT; j++) {
        // Check for intersection
        nodeCost[i][j] = predatorNodePathCollision(i, j, calcNodeCost(i, j));
      }
    }
  }
  float predatorNodePathCollision(int i, int j, float dist) {
    int intervalCount = (int)(dist);
    float intervalDirX = (nodePos[j][0]-nodePos[i][0])/intervalCount;
    float intervalDirY = (nodePos[j][1]-nodePos[i][1])/intervalCount;
    float intervalPosX = nodePos[i][0];
    float intervalPosY = nodePos[i][1];
    for (int k=0; k<intervalCount; k++) {
      if (!validAgentCSpace(intervalPosX, intervalPosY)) return Float.POSITIVE_INFINITY;
      if (!predatorSafeCSpace(intervalPosX, intervalPosY)) return Float.POSITIVE_INFINITY;
      intervalPosX += intervalDirX;
      intervalPosY += intervalDirY;
    }
    return dist;
  }


  // Follow path to target
  // Call every frame when following path to target
  // Can also be called when no target is chosen, in which case doNothing() is called
  // Note: doNothing() can be called directly instead of this function if (answerFound==false)
  void FollowPathToTarget(float dt) {
    if (answerFound) {
      if (SafePath()) {
        calculateNextPredatorNode();
        calculatePredatorForces();
        calculatePredatorVelocities(dt);
        calculatePositions(dt);
        calculateCollisions();
        calculateRotations(dt);
      } else rechoosePath = true;
    } else {
      doNothing();
    }
  }
  void calculateNextPredatorNode() {
    float dx, dy;
    // If at goal, do nothing
    if (nextNode<(answer.size()-1)) {
      // Change nextNode to furthest visible node 
      for (int j=(answer.size()-1); j>nextNode; j--) {
        dx = (pos.x-nodePos[answer.get(j)][0]);
        dy = (pos.y-nodePos[answer.get(j)][1]);
        if (!agentPredatorNodePathCollision(j, sqrt(dx*dx + dy*dy))) {
          nextNode = j;
          break;
        }
      }
      // If agent is within nodeRadius of node, go to next node
      if (nextNode<(answer.size()-1)) {
        dx = (pos.x-nodePos[answer.get(nextNode)][0]);
        dy = (pos.y-nodePos[answer.get(nextNode)][1]);
        if ( (dx*dx + dy*dy) < (nodeRadius*nodeRadius) ) {
        }
      }
    }
  }
  boolean agentPredatorNodePathCollision(int node, float dist) {
    int intervalCount = (int)(dist);
    float intervalDirX = (nodePos[answer.get(node)][0]-pos.x)/intervalCount;
    float intervalDirY = (nodePos[answer.get(node)][1]-pos.y)/intervalCount;
    float intervalPosX = pos.x;
    float intervalPosY = pos.y;
    for (int k=0; k<intervalCount; k++) {
      if (!validAgentCSpace(intervalPosX, intervalPosY)) return true;
      if (!predatorSafeCSpace(intervalPosX, intervalPosY)) return true;
      intervalPosX += intervalDirX;
      intervalPosY += intervalDirY;
    }
    return false;
  }
  void calculatePredatorForces(){
    // Calculate Force Towards Goal
    float tempGoalX = nodePos[answer.get(nextNode)][0];
    float tempGoalY = nodePos[answer.get(nextNode)][1];
    float tempX = dirX(pos.x, tempGoalX);
    float tempY = dirY(pos.y, tempGoalY);
    float tempTotal = sqrt(tempX*tempX + tempY*tempY);
    if (!withinArc(acc.x,acc.y,tempX,tempY,PI/8)){
      if (withinArc(acc.x,acc.y,tempX,tempY,PI/4)){
        acc.x = 0;
        acc.y = 0;
      }
      //else if ((vel.x > 15)||(vel.y > 15)){
        //acc.x = -1 * vel.x;
        //acc.y = -1 * vel.y;
      //}
      else{
        acc.x = 0;
        acc.y = 0;
      }
    }
    // If next node is the goal
    if (nextNode==(answer.size()-1)) {
      if (dist(tempGoalX, tempGoalY, pos.x, pos.y) > (goalDistanceThreshold)) {
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
  }
  void calculatePredatorVelocities(float dt) {
    if (!withinArc(acc.x, acc.y, vel.x, vel.y, PI/8)) {
      float ratioAccX, ratioAccY, totalAcc;
      float agentVelocity = sqrt(vel.x*vel.x + vel.y*vel.y);
      totalAcc = sqrt(acc.x*acc.x + acc.y*acc.y);
      if (totalAcc > 0) {
        ratioAccX = (acc.x/totalAcc);
        ratioAccY = (acc.y/totalAcc);
        vel.x = (agentVelocity*ratioAccX);
        vel.y = (agentVelocity*ratioAccY);
      }
    }
    vel.x += (acc.x*dt);
    vel.y += (acc.y*dt);
  
    float agentVelocity = sqrt(vel.x*vel.x + vel.y*vel.y);
    if (agentVelocity > maxVelocity) {
      vel.x = vel.x/agentVelocity*maxVelocity;
      vel.y = vel.y/agentVelocity*maxVelocity;
    }
  }
  // Is the probability of getting caught by recon on the chosen path low enough?
  boolean SafePath() {
    return true;
  }
  // Do nothing, only slow down
  void doNothing() {
    acc.x = 0;
    acc.y = 0;
    if (vel.x < 1) {
      vel.x = vel.x * 0.5;
    } else vel.x = 0;
    if (vel.y < 1) {
      vel.y = vel.y * 0.5;
    } else vel.y = 0;
  }
  
  // Flee from all nearby recon agents
  // Call every frame once detected
  // Return to normal behavior once at reasonable distance from all recon agents (1.25*recon.visionLength?)
  void FleeFromRecon(float dt) {
    calculateFleeForces();
    calculateVelocities(dt, true);
    calculatePositions(dt);
    calculateCollisions();
    calculateRotations(dt);
  }
  void calculateFleeForces(){
    // Avoid Recon
    for (Recon recon : recon) {
      float maxDist = (1.25 * recon.visionLength);
      if (dist(pos.x,pos.y,recon.pos.x,recon.pos.y) < maxDist){
        acc.x += (pos.x - recon.pos.x)*50;
        acc.y += (pos.y - recon.pos.y)*50;
      }
    }
    // Collision Avoidance Forces
    collisionForce(50);
    // If agent will soon collide with wall, force away from wall
    if (pos.x < (5 + size/2)) {  // Left Wall
      if (vel.x < 0) acc.x += maxVelocity*10;
    }
    if (pos.x > (fieldWidth -5 - size/2)) {  // Right Wall
      if (vel.x > 0) acc.x -= maxVelocity*10;
    }
    if (pos.y < (5 + size/2)) {  // Top Wall
      if (vel.y < 0) acc.y += maxVelocity*10;
    }
    if (pos.y > (fieldHeight - 5 - size/2)) {  // Bottom Wall
      if (vel.y > 0) acc.y -= maxVelocity*10;
    }
  }
  void collisionForce(float collisionDistance) {  // Collision Avoidance Forces
    float totalVelocity = sqrt(vel.x*vel.x + vel.y*vel.y);
    if (totalVelocity == 0) totalVelocity = 0.01;
    float aheadX = pos.x + (vel.x/totalVelocity*collisionDistance);
    float aheadY = pos.y + (vel.y/totalVelocity*collisionDistance);
    Obstacle obstacle = aheadCollision(pos.x, pos.y, aheadX, aheadY, collisionDistance);
    if (obstacle != null) {
      float tempX = aheadX - obstacle.position.x;
      float tempY = aheadY - obstacle.position.y;
      float tempTotal = sqrt(tempX*tempX + tempY*tempY);
      acc.x += tempX/tempTotal*maxVelocity*10;
      acc.y += tempY/tempTotal*maxVelocity*10;
    }
  }
  Obstacle aheadCollision(float agentX, float agentY, float aheadX, float aheadY, float collisionDistance) {
    int intervalCount = (int)(collisionDistance*10);
    float intervalDirX = (aheadX - agentX)/intervalCount;
    float intervalDirY = (aheadY - agentY)/intervalCount;
    float intervalPosX = agentX;
    float intervalPosY = agentY;
    for (int k=0; k<intervalCount; k++) {
      // Check if a collision occurs between agent position and ahead position
      // If a collision occurs, obstacle = obstacle number, else obstacle = -1
      float dx, dy, CRadius;
      for (Obstacle obstacle : obstacles) {
        dx = (intervalPosX-obstacle.position.x);
        dy = (intervalPosY-obstacle.position.y);
        CRadius = (obstacle.size/2 + size);
        if ( (dx*dx + dy*dy) < (CRadius*CRadius) ) {
          return obstacle;
        }
      }
      intervalPosX += intervalDirX;
      intervalPosY += intervalDirY;
    }
    return null;
  }

}
