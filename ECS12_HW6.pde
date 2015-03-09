import processing.video.*;
Capture video;
Pong pong;
Wall wall;
int w = 75;
int threshold = 5;
color currentBackground;
int[] answers;
int boxSize = 50;
int numAnswers = 4;
int answer;
String question = "";
boolean turn;
color playerOneColor = color(109, 150, 166);
color playerTwoColor = color(255, 153, 0);
int playerOneScore = 0;
int playerTwoScore = 0;
boolean playerOneTurn = false;
boolean playerTwoTurn = false;
boolean didUpdateScore = false;
int currentTime;
int startTime;
boolean side; 
int result;
int duration = -MAX_INT;


public class Pong {
  public int length;
  public int x;
  public int y;
  public int xMove = 0;
  public int yMove = 0;

  public Pong(int sideLength) {
    x = width/2 - w/2;
    y = height/2 -w/2;
    while (abs (xMove) < 6 || abs(yMove) < 6) {
      xMove = int(random(-7, 7));
      if (xMove < 0) turn = false;
      else turn = true;
      yMove = int(random(-7, 7));
    }
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
  public void barBounce() {
    //LEFT SIDE
    if ( x < wall.x - w + w/4) {
      xMove = -xMove;
    } 
    //RIGHT SIDE
    if (x > wall.x + w + w - w/4) {
      xMove = -xMove;
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

public class Wall {
  public int x;

  public Wall() {
    x = pong.x;
  }

  public void render(boolean side) {
    rectMode(CENTER);
    fill(255);
    stroke(0);
    strokeWeight(2);
    if (side) {
      rect(x + w + w, pong.y + w/2, w/4, 2*w);
    } else { 
      rect(x - w, pong.y + w/2, w/4, w*2);
    }
    noStroke();
    rectMode(CORNER);
  }
  public void move(int x) {
    this.x = x;
  }
}

void setup()
{
  size(1200, 800);
  video = new Capture(this, 640, 480, 15);
  video.start();
  background(0);

  noStroke();
  startTime = millis();
  pong = new Pong(5);
  if ( pong.xMove > 0 ) {
    turn = true;
    playerTwoTurn = true;
  }
  if ( pong.xMove < 0 ) {
    turn = false;
    playerOneTurn = true;
  }
  wall = new Wall();
  wall.move(-MAX_INT);
  createQuestion(0);
  createAnswers(numAnswers, 0);
}

void draw() 
{
  currentTime = millis() - startTime;
  if (video.available()) video.read();

  if (pong.xMove < 0) currentBackground = color(#660000);
  else currentBackground = color(#000066);
  background(currentBackground);
  video.loadPixels();
  drawBoxes(boxSize, numAnswers);
  drawPointer();
  boolean turnReturn = turn();
  didAnswer();
  if ( duration >= currentTime ) {
    showResult(side, result);
    if (result == 1) {
      wall.render(side);
      if ( wall.x > -1 && side == turn) pong.barBounce();
    }
  } else wall.move(-MAX_INT);
  if (turnReturn) {    
    didUpdateScore = false;
    resetTurn();
    if (playerOneTurn) {
      createQuestion(playerOneScore/2);
      createAnswers(numAnswers, playerOneScore/2);
    } else createQuestion(playerTwoScore/2);
    createAnswers(numAnswers, playerTwoScore/2);

    if ((playerOneScore + playerTwoScore) % 2 == 0) {
      if (turn) pong.xMove+=1;
      else pong.xMove-=1;
    }
  }

  if ((playerOneScore + playerTwoScore) == 6 && numAnswers < 5) {
    numAnswers++;
    boxSize-=5;
  }
  if ((playerOneScore + playerTwoScore) == 12 && numAnswers < 6) { 
    numAnswers++;
    boxSize-=5;
  }

println(pong.xMove);
  textAlign(CENTER, CENTER);
  textSize(100);
  fill(255);
  text(question, this.width/2, (this.height - video.height)/4);
  textAlign(LEFT);
  drawAnswers(boxSize, numAnswers);
  drawScore();
  noFill();
  stroke(255);
  rect(280, 160, 640, 480);
  noStroke();
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

void didAnswer() {
  //if (playerOneTurn || playerTwoTurn) {
  if (correctAnswer() == 2 && playerOneTurn) { //Player 1 got it wrong
    playerOneTurn = false; 
    side = false;
    result = 2;
    duration = currentTime + 2000;
    updateScore(false);
  } else if (correctAnswer() == 2 && playerTwoTurn) { //Player 2 got it wrong
    playerTwoTurn = false;
    side = true;
    result = 2;
    duration = currentTime + 2000;
    updateScore(true);
  } else if (correctAnswer() == 1 && playerOneTurn) { //Player 1 got it right
    playerOneTurn = false;
    side = false;
    result = 1;
    duration = currentTime + 2000;
    wall = new Wall();
    updateScore(true);
  } else if (correctAnswer() == 1 && playerTwoTurn) { //Player 2 got it right
    playerTwoTurn = false;
    side = true;
    result = 1;
    duration = currentTime + 2000;
    wall = new Wall();
    updateScore(false);
  } else if ( playerOneTurn && turn ) { //Player 1 didn't answer
    playerOneTurn = false; 
    side = false;
    result = 0;
    duration = currentTime + 2000;
    updateScore(false);
  } else if ( playerTwoTurn && !turn ) { //Player 2 didnt Answer
    playerTwoTurn = false;
    side = true;
    result = 0;
    duration = currentTime + 2000;
    updateScore(true);
  }
  // }
}

void resetTurn() {
  if (!playerOneTurn && !playerTwoTurn && turn) {
    playerTwoTurn = true;
  }
  if ( !playerOneTurn && !playerTwoTurn && !turn) {
    playerOneTurn = true;
  }
}

void showResult(boolean whichSide, int whatResult) { //Result meaning: 0 = DID NOT ANSWER, 1 = CORRECT, 2 = WRONG
  String[] strings = {
    "Time's up!", "Correct!", "Incorrect!"
  };
  fill(255, 255, 0);
  textAlign(CENTER);
  if (!whichSide) {
    pushMatrix();
    translate(this.width/2 - video.width/2, (this.height - video.height)/2);
    rotate(radians(-25));
    text(strings[whatResult], 0, 0);
    popMatrix();
  } else {
    pushMatrix();
    translate(this.width/2 + video.width/2, (this.height - video.height)/2);
    rotate(radians(25));
    text(strings[whatResult], 0, 0);
    popMatrix();
  }
  textAlign(LEFT);
}


void updateScore(boolean playerOne) {
  if (!didUpdateScore) {
    if (playerOne) {
      playerOneScore++;
    } else {
      playerTwoScore++;
    }
  }
  didUpdateScore = true;
}


void drawScore() {
  text(str(playerOneScore), 15, 50);
  textAlign(RIGHT);
  text(str(playerTwoScore), this.width-50, 50);
  textAlign(LEFT);
}

void drawAnswers(int boxSize, int numAnswers) {
  textSize(boxSize);
  int offset = boxSize*2;
  if (!turn) offset *= -1;
  float z = (video.height-boxSize*numAnswers)/numAnswers;
  float x = this.width/2 - boxSize/2 + offset;//(this.width - video.width)/2 + 2*(z/(2*numAnswers)) + boxSize;
  float y = (this.height - video.height)/2; //+ z/(2*numAnswers);
  fill(255);
  for (int i = 0; i < numAnswers; i++) { 
    text(str(answers[i]), x, i*(video.height/numAnswers) + y + i*(z/numAnswers) + 3, //+ z/(2*numAnswers), 
    (this.width - video.width)/2 + video.width, i*(video.height/numAnswers) + y + i*(z/numAnswers) + boxSize);
  }
}

void createQuestion(int difficulty) {
  int op = 0;
  int numOne = 0;
  int numTwo = 0;
  String[] operator = {
    " + ", " - ", " * ", "*"
  };
  switch(difficulty) {
  case 0:
    op = int(random(2));
    numOne = int(random(10));
    numTwo = int(random(5));
    break;
  case 1:
    op = int(random(3));
    numOne = int(random(10));
    numTwo = int(random(5));
    break;
  case 2:
    op = int(random(4));
    numOne = int(random(10));
    numTwo = int(random(5));
    break;
  case 3:
    op = int(random(2));
    numOne = int(random(50));
    numTwo = int(random(25));
    break;
  case 4:
    op = int(random(3));
    numOne = int(random(50));
    numTwo = int(random(25));
    break;
  case 5:
    op = int(random(4));
    numOne = int(random(50));
    numTwo = int(random(25));
    break;
  case 6:
    op = int(random(2));
    numOne = int(random(100));
    numTwo = int(random(50));
    break;
  case 7:
    op = int(random(3));
    numOne = int(random(100));
    numTwo = int(random(50));
    break;
  case 8:
    op = int(random(4));
    numOne = int(random(100));
    numTwo = int(random(100));
    break;
  }
  if (op == 0) answer = numOne + numTwo;
  if (op == 1) answer = numOne - numTwo;
  if (op == 2) answer = numOne * numTwo;
  if (op == 3) answer = numOne * numTwo;
  question = str(numOne) + operator[op] + str(numTwo);
}

void createAnswers(int numAnswers, int difficulty) {
  answers = new int[numAnswers+1];
  int answerIndex = int(random(numAnswers));
  answers[numAnswers] = answerIndex;
  answers[answerIndex] = answer;
  for (int i = 0; i < numAnswers; i++) {
    if (i != answerIndex) {
      answers[i] = answer + int(random(-5, 5));
      while (answers[i] == answer) answers[i] = answer + int(random(-10 - difficulty, 10 + difficulty));
      for (int j = 0; j < i; j++) {
        while (answers[i] == answer || answers[i] == answers[j]) {
          answers[i] = answer + int(random(-10, 10));
          j = 0;
        }
      }
    }
  }
}

void drawBoxes(int boxSize, int numAnswers) {
  float z = (video.height-boxSize*numAnswers)/numAnswers;
  float x = this.width/2 - boxSize/2;//(this.width - video.width)/2 + z/8;
  float y = (this.height - video.height)/2 + z/8;
  fill(255);
  for (int i = 0; i < numAnswers; i++) rect(x, i*(video.height/numAnswers) + y + i*(z/numAnswers), boxSize, boxSize);
}

void drawPointer() {
  this.loadPixels();
  float r1 = red(playerOneColor);
  float g1 = green(playerOneColor);
  float b1 = blue(playerOneColor);
  float r2 = red(playerTwoColor);
  float g2 = green(playerTwoColor);
  float b2 = blue(playerTwoColor);
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int vidPos = y*video.width + x;
      int thisPos = (this.width-video.width)/2 + (video.width - x - 1) + ((this.height-video.height)/2 + y) * this.width;
      color videoColor = video.pixels[vidPos];
      float rv = red(videoColor);
      float gv = green(videoColor);
      float bv = blue(videoColor);
      float diffOne = dist(rv, gv, bv, r1, g1, b1);
      float diffTwo = dist(rv, gv, bv, r2, g2, b2);
      if (diffOne < threshold) pixels[thisPos] = playerOneColor;
      if (diffTwo < threshold) pixels[thisPos] = playerTwoColor;
    }
  }
  this.updatePixels();
}

int correctAnswer() {
  if (returnAnswer(boxSize, numAnswers) != -1) { 
    if (returnAnswer(boxSize, numAnswers) == answers[numAnswers]) return 1;
    //if (returnAnswer(boxSize, numAnswers) > -1) return 2;
    else return 2;
  }
  return -1;
}

int returnAnswer(int boxSize, int numAnswers) {
  this.loadPixels();
  float z = (video.height-boxSize*numAnswers)/numAnswers;
  float x2 = this.width/2 - boxSize/2;
  float y2 = (this.height - video.height)/2 + z/8;

  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      for (int i = 0; i < numAnswers; i++) {
        //int vidPos = y*this.width + x;
        int thisPos = (this.width-video.width)/2 + (video.width - x - 1) + ((this.height-video.height)/2 + y) * this.width;
        color thisColor = this.pixels[thisPos];
        int x1 = x + (this.width-video.width)/2;
        int y1 = y + (this.height-video.height)/2;
        rectMode(CORNER);
        if (x1 >= x2 && x1 <= x2 + boxSize && y1 >= i*(video.height/numAnswers) + y2 + i*(z/numAnswers) && y1 <= i*(video.height/numAnswers) + y2 + i*(z/numAnswers) + boxSize) {
          if (thisColor == playerOneColor && playerOneTurn) {
            return i;
          }
          if (thisColor == playerTwoColor && playerTwoTurn) {
            return i;
          }
        }
      }
    }
  }
  this.updatePixels();
  return -1;
}

