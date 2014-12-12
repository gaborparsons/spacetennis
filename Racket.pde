class Racket {
  PVector position;
 
  Racket(float x, float r_) {
    position = new PVector(balls[0].position.x + x, balls[0].position.y);
 // r = r_;
  }
  
  void update(){
    position.add(balls[0].velocity);
  }
    
  void display() {
    noStroke();
    noFill();
    rectMode(CENTER);
    rect(position.x, position.y, 200, 40);
    
    //Racket 
    pushMatrix();
    translate(position.x, position.y);
    if(position.x > balls[0].position.x){
      rotate(PI);
    }
    imageMode(CENTER);
    image(racket, 0, 0, 200, 60);
    if(position.x > balls[0].position.x){
      rotate(-PI);
    }
    translate(-position.x, -position.y);
    popMatrix();
    //End Racket  
  }

}
