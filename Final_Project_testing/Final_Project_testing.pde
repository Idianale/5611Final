// Testing before integrating into Final_Project

import java.util.*;

ArrayList<Resource> resources;
ArrayList<Recon> recon;

Random r = new Random();

float fieldHeight = 747;
float fieldWidth = 747;
float resourceSize = 17;
float reconSize = 20;
int numResources = 100;
int numRecon = 4;

class Resource {
  PVector position;
  float quantity;
  
  Resource() {
    this.position = new PVector(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight,0);
    this.quantity = 100;
  }
  
  void Draw() {
    ellipse(this.position.x,this.position.y,resourceSize,resourceSize);
  }
}


class Recon {
  PVector position;
  float quantity;
  
  Recon() {
    this.position = new PVector(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight,0);
    this.quantity = 4;
  }
  
  void Draw() {
    fill(50, 50, 150)
    ellipse(this.position.x,this.position.y,reconSize,reconSize);
    noFill();
  }
}


void setup() {
  size(600,600);
  
  // Initialize list of resources
  resources = new ArrayList<Resource>(numResources);
  for (int i = 0; i < numResources; i++) {
    resources.add(new Resource());
  }
  
  // Initialize list of recon agents
  recon = new ArrayList<Recon>(numRecon);
  for (int i = 0; i < numRecon; i++) {
    recon.add(new Recon());
  }
  
}

void updateSim(double dt) {
}

void drawSim() {
  for (Resource resource : resources) {
    resource.Draw();
  }
  for (Recon recon : recon) {
    recon.Draw();
  }
}

void draw() {
  updateSim(0.01);
  
  drawSim();
}
