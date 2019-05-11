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
  
  // Initialize list of resources
  resources = new ArrayList<Resource>(numResources);
  for (int i = 0; i < numResources; i++) {
    resources.add(new Resource());
  }
  
  
  // Initialize list of obstacles
  obstacles = new ArrayList<Obstacle>(numObstacles);
  for (int i = 0; i < numObstacles; i++) {
    obstacles.add(new Obstacle(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight, 100+r.nextFloat()*100 ));
  }
  
  // Initialize list of acquisition agents
  acquisition = new ArrayList<Acquisition>(numAcquisition);
  float spawnX = (fieldWidth * 0.1) + (r.nextFloat() * fieldWidth * 0.8);
  float spawnY = (fieldHeight * 0.1) + (r.nextFloat() * fieldHeight * 0.8);
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
    predator.add(new Predator());
  }
  
}

void updateSim(double dt) {
}

void drawSim() {
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
}

void draw() {
  updateSim(0.01);
  
  drawSim();
}
