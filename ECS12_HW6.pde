
import processing.video.*;

Capture video;
Pong pong;

int w = 75;
int threshold = 30;
color currentBackground;

public class Pong {
  public int length;
  public int x;
  public int xr;
  public int y;
  public int yl;
  public int xMove = 0;
  public int yMove = 0;
  public boolean existence;
  public Pong() {
    existence = false;
  }
  public Pong(int sideLength) {
    if (!existence) {
      x = width/2;
      y = height/2;
      if (xMove == 0 || yMove == 0) {
        xMove = int(random(-5, 5));
        yMove = int(random(-5, 5));
      }
    }
    existence = true;
    //rect(x, y, w, w);
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
  if (video.available()) {
    video.read();
  }
  video.loadPixels();
  loadPixels();
  

  if(pong.xMove < 0){
    currentBackground = color(#660000);
    background(currentBackground);
  }
  else{
    currentBackground = color(#000066);
    background(currentBackground);
  }
//b = 0;
for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      
      int vidPos = y*video.width + x; 
 
      //println(b);
      int thisPos = (this.width-video.width)/2 + (video.width - x - 1) + ((this.height-video.height)/2 + y) * this.width;
      
      color videoColor = video.pixels[vidPos];
      this.pixels[thisPos] = video.pixels[vidPos];
      
      float rv = red(videoColor);
      float gv = green(videoColor);
      float bv = blue(videoColor);

      float diff = dist(rv, gv, bv, 255, 255, 255);
      if (diff < threshold) pixels[thisPos] = color(255);
      else pixels[thisPos] = currentBackground;
      //else pixels[loc] = videoColor;

      
    }//end inner for
  }//end outer for








  updatePixels();

  pong.render();
  pong.move();
  pong.wallBounce();
}

