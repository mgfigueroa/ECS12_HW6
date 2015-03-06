
import processing.video.*;

Capture video;
Pong pong;

int w = 75;
int strk = 5;
int b = 0;

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
  loadPixels();
  
  if(pong.xMove < 0) background(#660000);
  else background(#000066);

b = 0;
for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      
      int vidPos = y*video.width + x; 
      if(x == video.width-1){
        b += 560;
        println(b);
      }
      int thisPos = (1200*160) - 640 - 280 + x + b;
      
      color videoColor = video.pixels[vidPos];
      this.pixels[thisPos] = video.pixels[vidPos];
      
      
      
      //float rv = red(videoColor);
      //float gv = green(videoColor);
      //float bv = blue(videoColor);

      //float diff = dist(rv, gv, bv, 0, 0, 0);
      //int newPos = y+110*video.width + x+280; 
      //if ((diffOne > threshold) && (diffTwo > threshold)) pixels[loc] = videoColor; 
      //if (diff < threshold) pixels[loc] = colorOne;
      //else pixels[loc] = videoColor;

      
    }//end inner for
  }//end outer for








  this.updatePixels();






  pong.render();
  pong.move();
  pong.wallBounce();
}

