//Audio
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
 
Minim minim;
AudioInput in;
FFT fft;
AudioPlayer player;
//End Audio

//Images
PImage moon, stars, racket;

//Fonts
PFont ubuntuMono;
PFont ubuntuMonoSmall;

float gra = 0.05;
float reb = 0.8;
int bounce, bounceSame = 0;
int turn, previousTurn = 0;
int score1, score2, previousScore1, previousScore2 = 0;
int end, timer = 0;
int gameOver=0;

PVector netPosition;

Ball[] balls = { 
  new Ball(1280, 820, 400, 0, 0, 0, reb), 
  new Ball(800, 740, 10, 2, 2, gra, reb),
};

Racket[] rackets = { 
  new Racket(-520, 150), 
  new Racket(520, 150), 
};

void setup() {
  size(2848, 1600);
  
  //Audio
  minim = new Minim(this);  
  in = minim.getLineIn(Minim.MONO, 1024);
  fft = new FFT(in.bufferSize(), in.sampleRate());

  player = minim.loadFile("slice-short.mp3", 1024);

  //End Audio
  moon = loadImage("moon.png");
  stars = loadImage("stars.png");
  racket = loadImage("racket.png");
  
  //Fonts
  ubuntuMono = createFont("UbuntuMono-B.ttf", 300);
  ubuntuMonoSmall = createFont("UbuntuMono-B.ttf", 150);

}

void draw() {
  
  if(gameOver == 0){
    background(stars);
  
    //Text
    fill(255, 70);
    textFont(ubuntuMono);
    textAlign(CENTER, CENTER);
    text(score1 + " : " + score2, width/2, 120);
    //End Text
  
    for (Ball b : balls) {
      b.update();
      b.display();
      //b.checkBoundaryCollision();
    }
  
    balls[0].checkCollision(balls[1]);
    balls[0].checkBoundaryCollision();
    
    for (Racket r : rackets) {
      r.update();
      r.display();
    }
    
    imageMode(CENTER);
    image(moon, balls[0].position.x, balls[0].position.y, 815, 815);
    
    //Hit
    float strength = 0;  
    //Sound
    stroke(255, 90);
    // draw the waveforms so we can see what we are monitoring
    pushMatrix();
    translate((width/2-500), 50);
    for(int i = 0; i < in.bufferSize() - 1; i++)
    {
      line( i, 50 + in.left.get(i)*50, i+1, 50 - in.left.get(i+1)*50 );
      line( i, 150 + in.right.get(i)*50, i+1, 150 - in.right.get(i+1)*50 );
      
      float soundVolume = in.right.get(i)*100;
      rackets[0].position.y = balls[0].position.y+soundVolume;
      rackets[1].position.y = balls[0].position.y+soundVolume;
      strength = abs(soundVolume)/25;
  //    strength = abs(soundVolume)/25+0.5;
    }
    translate(-(width/2-550), -50);
    popMatrix();
  
    //End Sound  
  
    float testDistance0 = rackets[0].position.dist(balls[1].position);
    float testDistance1 = rackets[1].position.dist(balls[1].position);
  
    if(testDistance0 < 120){
      balls[1].velocity.y = -strength*5;
      balls[1].velocity.x = 0;
      bounce = 0;
      println(bounce);
      turn = 1;
      player.play(0);
  
    }
    if(testDistance1 < 120){
      balls[1].velocity.y = -strength*5;
      balls[1].velocity.x = 0;
      bounce = 0;
      println(bounce);
      turn = 2;
      player.play(0);
    }
    
    //Net
    fill(220);
    netPosition = new PVector(balls[0].position.x - 7, balls[0].position.y - balls[0].r - 40);
    rect(netPosition.x, netPosition.y, 14, 80); 
    float netDistance = netPosition.dist(balls[1].position);
    if(netDistance < 40){
      balls[1].velocity.x *= -1;
  
    }
    //End Net
      
    //Double bouncing
    if(turn == 1){
      //double bouncing on my side
      if(balls[1].position.x < balls[0].position.x){
        bounceSame = bounce;
      }
      if(bounceSame >= 2){
        turn = 0; 
        score2 ++;
      }
      if(bounce - bounceSame >= 2){
        turn = 0; 
        score1 ++;
      }
    } 
    if(turn == 2){
      //double bouncing on my side
      if(balls[1].position.x > balls[0].position.x){
        bounceSame = bounce;
      }
      if(bounceSame >= 2){
        turn = 0; 
        score1 ++;
      }
      if(bounce - bounceSame >= 2){
        turn = 0; 
        score2 ++;
      }
    } 
    
    //Overhit = doesn't bounce on other side
    if(bounce - bounceSame == 0 && turn != previousTurn && previousTurn != 0){
      if(turn == 1){
        score1 ++;
        balls[1].position.x = rackets[0].position.x;
        balls[1].position.y = rackets[0].position.y - 200;
      } 
      if(turn == 2){ 
        score2 ++;
        balls[1].position.x = rackets[1].position.x;
        balls[1].position.y = rackets[1].position.y - 200;
      }
    }
    previousTurn = turn;
  
    if((score1 >= 3 && score1-score2 > 1) || score2 >=3 && score2-score1 >1){
      end = 1;
      gameOver = 1;
    }
  }
  if(gameOver == 1){
    background(stars);
    fill(255);
    textFont(ubuntuMonoSmall);
    textAlign(CENTER, CENTER);
    if(score1 > score2){
      text("PLAYER 1 WINS! ", width/2, height/2 - 130);
      text(score1 + " VS. " + score2, width/2, height/2);
    }else{
      text("PLAYER 2 WINS! ", width/2, height/2 - 130);
      text(score2 + " VS. " + score1, width/2, height/2);
    }
    text("CLICK TO RESTART", width/2, height/2 + 130);
  }

}

void mouseClicked()
{
   balls[1].velocity.mult(0);
   balls[1].position.x = mouseX;
   balls[1].position.y = mouseY;
   turn = 0;
   if(gameOver == 1){
    score1 = 0;
    score2 = 0;
    balls[1].position.x = rackets[0].position.x;
    balls[1].position.y = rackets[0].position.y - 200;
   }
   gameOver = 0;
}

void gameOverSplash()
{
  gameOver = 1;
}

void stop()
{
  in.close();
  minim.stop();
  super.stop();
}
