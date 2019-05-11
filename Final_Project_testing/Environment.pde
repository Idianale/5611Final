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


class Obstacle{
  PVector pos; 
  float size;
  
  Obstacle(){
    this.pos = new PVector(r.nextFloat()*fieldWidth,r.nextFloat()*fieldHeight,0);
    this.size = 50;
  }
  
  Obstacle(float x, float y, float size){
    this.pos = new PVector(x,y,0);
    this.size = size;
  }
  
  // Returns true if collision with obstacle
  boolean obstacleCollision(float x, float y, float size){
    float dist_x = x - this.pos.x;
    float dist_y = y - this.pos.y;
    float dist = sqrt( (dist_x*dist_x) + (dist_y*dist_y) );
    if (dist < (size+this.size)){
      return true;
    }
    else return false;
  }
}
