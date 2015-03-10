public class Confetti {
  float x;
  float y;
  float fallSpeed;
  color col;
  int size;

  public Confetti() {
    x = random(width); //Give the confetti a random x location within the screen
    y = random(-height); //Give the confetti a random y location above the screen
    size = 8; //Size of the confetti
    fallSpeed = random(1, 5); //A random fall speed
    col = color(random(255), random(255), random(255)); //A random color
  }

  void render() {
    fill(col); //Fill with the color
    rect(x, y, size, size); //Draw the square
    y += fallSpeed; //Update the y location with the fall speed
  }
}

