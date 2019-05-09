import java.util.*;

ArrayList<Resource> resources;

Random r = new Random();

float fieldHeight = 1000;
float fieldWidth = 720;
float resourceSize = 17;
int numResources = 10;

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

void setup() {
  size(1000,720);
  
  // Initialize list of resources
  resources = new ArrayList<Resource>(numResources);
  for (int i = 0; i < numResources; i++) {
    resources.add(new Resource());
  }
}

void updateSim(double dt) {
}

void drawSim() {
  for (Resource resource : resources) {
    resource.Draw();
  }
}

void draw() {
  updateSim(0.01);
  
  drawSim();
}
