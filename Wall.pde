public class Wall {
  public int x;

  public Wall() {
    x = pong.x; //When constructed, set the x to the pong's x location
  }

  public void render(boolean side) {
    rectMode(CENTER);
    fill(255);
    stroke(0);
    strokeWeight(2);
    if (side) { //This draws the paddle on the correct side it should be on
      rect(x + w + w, pong.y + w/2, w/4, 2*w);
    } else { 
      rect(x - w, pong.y + w/2, w/4, w*2);
    }
    noStroke();
    rectMode(CORNER);
  }
  public void move(int x) { //This moves the paddle to the given x location
    this.x = x;
  }
}
