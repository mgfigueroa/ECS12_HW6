import processing.video.*;
Capture video;
Pong pong;
int w = 75;
int threshold = 30;
color currentBackground;

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
  drawBoxes();
  drawQuestions();
  noFill();
  stroke(255);
  rect(280, 160, 640, 480);
  fill(255);

  pong.render();
  pong.move();
  pong.wallBounce();
}

void drawQuestions() {
  int boxSize = 50;
  int numQuestions = 4;
  textSize(boxSize/2);
  float z = (video.height-boxSize*numQuestions)/numQuestions;
  float x = (this.width - video.width)/2 + 2*(z/(2*numQuestions)) + boxSize;
  float y = (this.height - video.height)/2 + z/(2*numQuestions);
  
  for (int i = 0; i < numQuestions; i++) { 
    str = createQuestion();
    text(str, x, i*(video.height/numQuestions) + y + i*(z/numQuestions) + z/(2*numQuestions), 
    (this.width - video.width)/2 + video.width, i*(video.height/numQuestions) + y + i*(z/numQuestions) + boxSize);
  }
}

void drawBoxes() {
  int boxSize = 50;
  int numQuestions = 4;
  float z = (video.height-boxSize*numQuestions)/numQuestions;
  float x = (this.width - video.width)/2 + z/8;
  float y = (this.height - video.height)/2 + z/8;
  for (int i = 0; i < numQuestions; i++) rect(x, i*(video.height/numQuestions) + y + i*(z/numQuestions), boxSize, boxSize);
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

