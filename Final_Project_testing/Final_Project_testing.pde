// Testing before integrating into Final_Project

import java.util.*;

ArrayList<Obstacle> obstacles;
ArrayList<Resource> resources;
ArrayList<Recon> recon;
ArrayList<Acquisition> acquisition;
ArrayList<Predator> predator;

Random r = new Random();

float fieldHeight = 720;
float fieldWidth = 1000;
float resourceSize = 17;
int numObstacles = 3;
int numResources = 50;
int numRecon = 3;
int numAcquisition = 4;
int numPredator = 1;

void setup() {
  size(1000,720);
  
  // Initialize list of obstacles
  obstacles = new ArrayList<Obstacle>(numObstacles);
  for (int i = 0; i < numObstacles; i++) {
    obstacles.add(new Obstacle(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight, 100+r.nextFloat()*100 ));
  }
  
  // Initialize list of resources
  resources = new ArrayList<Resource>(numResources);
  for (int i = 0; i < numResources; i++) {
    resources.add(new Resource());
  }
  
  // Initialize Herd location - Herd cannot be placed inside an obstacle
  boolean isColliding;
  float spawnX, spawnY;
  while (true){
    isColliding = false;
    spawnX = (fieldWidth * 0.1) + (r.nextFloat() * fieldWidth * 0.8);
    spawnY = (fieldHeight * 0.1) + (r.nextFloat() * fieldHeight * 0.8);
    for (Obstacle obstacle : obstacles) {
      if (obstacle.obstacleCollision(spawnX,spawnY,0)){
        isColliding = true;
        break;
      }
    }
    if (!isColliding) break;
  }
  
  // Initialize list of acquisition agents
  acquisition = new ArrayList<Acquisition>(numAcquisition);
  for (int i = 0; i < numAcquisition; i++) {
    acquisition.add(new Acquisition(spawnX,spawnY,i));
  } 
  
  // Initialize list of recon agents
  recon = new ArrayList<Recon>(numRecon);
  for (int i = 0; i < numRecon; i++) {
    recon.add(new Recon(spawnX,spawnY,i));
  }
  
  // Initialize list of predator agents
  predator = new ArrayList<Predator>(numPredator);
  for (int i = 0; i < numPredator; i++) {
    predator.add(new Predator(spawnX,spawnY,i,400));
  }
  
}

void updateSim(double dt) {
}



void drawSim() {
  background(200,200,200);
  
  // TODO: REMOVE FOLLOWING DEBUG CODE
  for (Acquisition acquisition : acquisition){
    // Render Possible Paths
    strokeWeight(1);
    stroke(20, 50, 100);
    for (int i=0; i<NODECOUNT; i++) {
      for (int j=0; j<NODECOUNT; j++) {
        if (acquisition.nodeCost[i][j]!=Float.POSITIVE_INFINITY) {
          line(acquisition.nodePos[i][0], acquisition.nodePos[i][1], 
               acquisition.nodePos[j][0], acquisition.nodePos[j][1]);
        }
      }
    }
    for (int i=0; i<(acquisition.answer.size()-1); i++) {
      if (acquisition.answer.size() > 1){
        stroke(100, 150, 255);
        strokeWeight(3);
        line(acquisition.nodePos[acquisition.answer.get(i)][0],
             acquisition.nodePos[acquisition.answer.get(i)][1],
             acquisition.nodePos[acquisition.answer.get(i+1)][0],
             acquisition.nodePos[acquisition.answer.get(i+1)][1]);
      }
    }
  }
  // END DEBUG CODE
  
  // Display objects
  for (Resource resource : resources) {
    resource.Draw();
  }
  for (Acquisition acquisition : acquisition) {
    acquisition.display();
  }
  for (Recon recon : recon) {
    recon.display();
  }
  for (Predator predator : predator) {
    predator.display();
  }
  for (Obstacle obstacle : obstacles) {
    obstacle.Draw();
  }
  // Display 
  for (Acquisition acquisition : acquisition) {
    acquisition.displayCone();
  }
  for (Recon recon : recon) {
    recon.display();
  }
}

void draw() {
  updateSim(0.01);
  drawSim();
  //println("FPS: ",frameRate);
}

void keyPressed() {
  // Reset Simulation
  if (keyCode  == 'R') {
    reset();
  }
  
  // Acquisition Debug keyCodes
  if (keyCode  == 'Q') {
    for (Acquisition acquisition : acquisition) {
      acquisition.LocateResource();
      if (acquisition.targetResource != null) acquisition.FindPathToResource();
    }
  }
  if (keyCode  == 'W') {
    for (Acquisition acquisition : acquisition) {
      acquisition.MoveToResource(0.01);
    }
  }
  if (keyCode  == 'E') {
    for (Acquisition acquisition : acquisition) {
      if (acquisition.targetResource != null){
        if (acquisition.targetResource.quantity > 0) acquisition.DepleteResource(0.01);
      }
    }
  }
  if (keyCode  == 'T') {
    for (Acquisition acquisition : acquisition) {
      if (acquisition.targetResource != null){
        if (acquisition.targetResource.quantity > 0) acquisition.DepleteResource(1);
      }
    }
  }
  if (keyCode  == 'U') {
    predLastSeen.x = mouseX;
    predLastSeen.y = mouseY;
    predLastSeen.z = 0;
    for (Acquisition acquisition : acquisition) {
        acquisition.FleeFromPredator(0.01);
    }
  }
}

// Reset Simulation
void reset(){
  // Initialize list of obstacles
  obstacles = new ArrayList<Obstacle>(numObstacles);
  for (int i = 0; i < numObstacles; i++) {
    obstacles.add(new Obstacle(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight, 100+r.nextFloat()*100 ));
  }
  // Initialize list of resources
  resources = new ArrayList<Resource>(numResources);
  for (int i = 0; i < numResources; i++) {
    resources.add(new Resource());
  }
  // Initialize Herd location - Herd cannot be placed inside an obstacle
  boolean isColliding;
  float spawnX, spawnY;
  while (true){
    isColliding = false;
    spawnX = (fieldWidth * 0.1) + (r.nextFloat() * fieldWidth * 0.8);
    spawnY = (fieldHeight * 0.1) + (r.nextFloat() * fieldHeight * 0.8);
    for (Obstacle obstacle : obstacles) {
      if (obstacle.obstacleCollision(spawnX,spawnY,0)){
        isColliding = true;
        break;
      }
    }
    if (!isColliding) break;
  }
  // Initialize list of acquisition agents
  acquisition = new ArrayList<Acquisition>(numAcquisition);
  for (int i = 0; i < numAcquisition; i++) {
    acquisition.add(new Acquisition(spawnX,spawnY,i));
  } 
  // Initialize list of recon agents
  recon = new ArrayList<Recon>(numRecon);
  for (int i = 0; i < numRecon; i++) {
    recon.add(new Recon(spawnX,spawnY,i));
  }
  // Initialize list of predator agents
  predator = new ArrayList<Predator>(numPredator);
  for (int i = 0; i < numPredator; i++) {
    predator.add(new Predator(spawnX,spawnY,i,200));
  }
}
