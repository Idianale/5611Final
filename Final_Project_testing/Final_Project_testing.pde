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
int numRecon = 4;
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
  for (Resource resource : resources) {
    resource.Draw();
  }
  for (Recon recon : recon) {
    recon.display();
  }
  for (Acquisition acquisition : acquisition) {
    acquisition.display();
  }
  for (Predator predator : predator) {
    predator.display();
  }
  for (Obstacle obstacle : obstacles) {
    obstacle.Draw();
  }
  
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
  
  // Debug keyCodes
  if (keyCode  == 'Q') {
    for (Acquisition acquisition : acquisition) {
      Resource resource = acquisition.LocateResource();
      if (resource != null) acquisition.FindPathToResource(resource);
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
