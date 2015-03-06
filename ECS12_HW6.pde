import processing.video.*;
Capture video;
Pong pong;
int w = 75;
int threshold = 30;
color currentBackground;
String[] answers;
int boxSize = 50;
int numAnswers = 4;
float answer;
String question = "";
boolean turn;

public class Pong {
  public int length;
  public int x;
  public int y;
  public int xMove = 0;
  public int yMove = 0;
  public boolean existence;
  public Pong() {
    existence = false;
  }
  public Pong(int sideLength) {
    if (!existence) {
      x = width/2 - w/2;
      y = height/2 -w/2;
      while (abs (xMove) < 3 || abs(yMove) < 3) {
        xMove = int(random(-4, 4));
        if (xMove < 0) turn = false;
        else turn = true;
        yMove = int(random(-4, 4));
      }
    }
    existence = true;
  }
  public void wallBounce() {
    //LEFT SIDE
    if (x <= 0) {
      xMove = -xMove;
    } 
    //BOTTOM SIDE
    if ( (y + w >= (height)) ) {
      yMove = -yMove;
    }
    //RIGHT SIDE
    if (x >= (width-w)) {
      xMove = -xMove;
    } 
    //TOP SIDE
    if (y <= 0) {
      yMove = -yMove;
    }
  }
  public void move() {
    x += xMove;
    y += yMove;
  }
  public void render() {
    ellipseMode(CORNERS);
    ellipse(x, y, x+w, y+w);
  }
}


void setup()
{
  size(1200, 800);
  video = new Capture(this, 640, 480, 15);
  video.start();
  background(0);
  pong = new Pong(5);
  createAnswers(numAnswers);
}

void draw() 
{
  if (video.available()) video.read();

  if (pong.xMove < 0) currentBackground = color(#660000);
  else currentBackground = color(#000066);
  background(currentBackground);

  video.loadPixels();
  this.loadPixels();
  drawPointer();
  this.updatePixels();
  drawBoxes(boxSize, numAnswers);
  if (turn()) {
    //text(question, (this.width - video.width)/2 + 2*((video.height-boxSize*numAnswers)/numAnswers/(2*numAnswers)) + boxSize, (this.height - video.height)/4);
    text("what the niggeR", 50, 50);
    createAnswers(numAnswers);
  }
  drawAnswers(boxSize, numAnswers);
  noFill();
  stroke(255);
  rect(280, 160, 640, 480);
  fill(255);

  pong.render();
  pong.move();
  pong.wallBounce();
}

boolean turn() {
  if (turn == false && pong.xMove > 0) {
    turn = true;
    return true;
  } else if (turn == true && pong.xMove < 0) {
    turn = false;
    return true;
  } else return false;
}

void drawAnswers(int boxSize, int numAnswers) {
  textSize(boxSize/2);
  float z = (video.height-boxSize*numAnswers)/numAnswers;
  float x = (this.width - video.width)/2 + 2*(z/(2*numAnswers)) + boxSize;
  float y = (this.height - video.height)/2 + z/(2*numAnswers);
  for (int i = 0; i < numAnswers; i++) { 
    text(answers[i], x, i*(video.height/numAnswers) + y + i*(z/numAnswers) + z/(2*numAnswers), 
    (this.width - video.width)/2 + video.width, i*(video.height/numAnswers) + y + i*(z/numAnswers) + boxSize);
  }
}

String createQuestion(int difficulty) {
  int op = 0;
  int numOne = 0;
  int numTwo = 0;
  String[] operator = {
    " + ", " - ", " * ", " / ", "^", "!"
  };
  switch(difficulty) {
  case 0:
    op = int(random(2));
    numOne = int(random(10));
    numTwo = int(random(5));
  case 1:
    op = int(random(4));
    numOne = int(random(10));
    numTwo = int(random(5));
  case 2:
    op = int(random(6));
    numOne = int(random(10));
    numTwo = int(random(5));
  case 3:
    op = int(random(2));
    numOne = int(random(50));
    numTwo = int(random(25));
  case 4:
    op = int(random(4));
    numOne = int(random(50));
    numTwo = int(random(25));
  case 5:
    op = int(random(6));
    numOne = int(random(50));
    numTwo = int(random(25));
  case 6:
    op = int(random(2));
    numOne = int(random(100));
    numTwo = int(random(50));
  case 7:
    op = int(random(4));
    numOne = int(random(100));
    numTwo = int(random(50));
  case 8:
    op = int(random(6));
    numOne = int(random(100));
    numTwo = int(random(100));
  }
  if (op == 0) answer = numOne + numTwo;
  if (op == 1) answer = numOne - numTwo;
  if (op == 2) answer = numOne * numTwo;
  if (op == 3) answer = numOne / (numTwo * 1.0);
  if (op == 4) answer = numOne ^ numTwo;
  if (op == 5) answer = factorial(numOne);

  question = str(numOne) + operator[op] + str(numTwo);
  return question;
}

int factorial(int numOne) {
  int fact = 1;
  for (int i = 1; i <= numOne; i++) {
    fact *= i;
  }
  return fact;
}

void createAnswers(int numAnswers) {
  answers = new String[numAnswers+1];
  int answerIndex = int(random(4));
  answers[4] = str(answerIndex);
  answers[answerIndex] = str(answer);
  for (int i = 0; i < numAnswers; i++) {
    if (i != answerIndex) answers[i] = str(answer + int(random(-10, 10)));
  }
}

void drawBoxes(int boxSize, int numAnswers) {
  float z = (video.height-boxSize*numAnswers)/numAnswers;
  float x = (this.width - video.width)/2 + z/8;
  float y = (this.height - video.height)/2 + z/8;
  for (int i = 0; i < numAnswers; i++) rect(x, i*(video.height/numAnswers) + y + i*(z/numAnswers), boxSize, boxSize);
}


void drawPointer() {
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      int vidPos = y*video.width + x;
      int thisPos = (this.width-video.width)/2 + (video.width - x - 1) + ((this.height-video.height)/2 + y) * this.width;
      color videoColor = video.pixels[vidPos];
      this.pixels[thisPos] = video.pixels[vidPos];
      float rv = red(videoColor);
      float gv = green(videoColor);
      float bv = blue(videoColor);
      float diff = dist(rv, gv, bv, 255, 255, 255);
      if (diff < threshold) pixels[thisPos] = color(255);
      else pixels[thisPos] = currentBackground;
    }
  }
}

