
class Obstacle{
  PVector position; 
  float size;
  
  Obstacle(){
    this.position = new PVector(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight,0);
    this.size = 50;
  }
  
  Obstacle(float x, float y, float size){
    this.position = new PVector(x,y,0);
    this.size = size;
  }
  
  void Draw() {
    fill(60,30,60);
    ellipse(this.position.x,this.position.y,this.size,this.size);
    noFill();
  }
  
  // Returns true if collision with obstacle
  boolean obstacleCollision(float x, float y, float objectSize){
    float dist_x = x - this.position.x;
    float dist_y = y - this.position.y;
    float dist = sqrt( (dist_x*dist_x) + (dist_y*dist_y) );
    if (dist < (objectSize/2+this.size/2)){
      return true;
    }
    else return false;
  }
}


class Resource {
  PVector position;
  float quantity;
  
  Resource() {
    this.quantity = 100;
    // Check for collision with obstacles
    float spawn_at_x, spawn_at_y;
    boolean isColliding;
    while(true){
      isColliding = false;
      spawn_at_x = fieldWidth*0.02 + r.nextFloat()*fieldWidth*0.96;
      spawn_at_y = fieldWidth*0.02 + r.nextFloat()*fieldHeight*0.96;
      for (Obstacle obstacle : obstacles) {
        if (obstacle.obstacleCollision(spawn_at_x,spawn_at_y,resourceSize)){
          isColliding = true;
          break;
        }
      }
      if (!isColliding){
        this.position = new PVector(spawn_at_x,spawn_at_y,0);
        break;
      }
    }
  }
  
  void Draw() {
    if (quantity>0){
      fill(100+15*quantity,100+15*quantity,100+15*quantity);
    } else {
      noFill();
    }
    ellipse(this.position.x,this.position.y,resourceSize,resourceSize);
    noFill();
  }
}
