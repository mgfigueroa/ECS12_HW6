public class Pong {
  public int length;
  public int x;
  public int y;
  public int xMove = 0;
  public int yMove = 0;

  public Pong() {
    x = width/2 - w/2; //X location (center of the screen)
    y = height/2 -w/2; //Y location (center of the screen)
    while (abs (xMove) < 6 || abs(yMove) < 6) { //So the ball is not too slow
      xMove = int(random(-7, 7)); //Random x movement
      if (xMove < 0) turn = false; //Sets turn to the direction the ball is moving
      else turn = true; //Set turn to the direction the ball is moving
      yMove = int(random(-7, 7)); //Random y movement
    }
  }
  public void wallBounce() { //This just negates the pong's x or y if it hits a wall
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
  public void barBounce() { //This just negates the pong's x if it hits the paddle
    //LEFT SIDE
    if ( x < wall.x - w + w/4) {
      xMove = -xMove;
    } 
    //RIGHT SIDE
    if (x > wall.x + w - w/4) {
      xMove = -xMove;
    }
  }

  public void move() { //This moves the pong
    x += xMove;
    y += yMove;
  }
  public void render() { //This draws the pong
    ellipseMode(CORNERS);
    ellipse(x, y, x+w, y+w);
  }
}
