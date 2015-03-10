import processing.video.*;
Capture video;
Pong pong;
Wall wall;
Confetti[] confetti;
int w = 75; //This is to set the width of the ball 
int threshold1 = 80; 
int threshold2 = 60; //This is the sensitivity for the detection of colors throught the camera
color currentBackground; //This is to save the color for which the background should be
int[] answers; //This array holds the answers that are randomly generated as well as the correct answer's index in the last index
int boxSize = 70; //This holds the size of the multiple choice boxes
int numAnswers = 2; //This sets the number of answers that should be randomly generated for the question
int answer; //This is the correct answer
String question = ""; //This is a string variable that holds the question
boolean turn; //This is a boolean variable for the direct that the ball is moving, false = left, true = right
color playerOneColor = color(211, 47, 111); //Pink highlighter, This is the color that player one uses to select an answer
color playerTwoColor = color(136, 243, 106); //Green highlighter, This is the color that player two uses to select an answer
int playerOneScore; //This is player one's score
int playerTwoScore;  //This is player two's score
boolean playerOneTurn; //This boolean variable says if player one can answer
boolean playerTwoTurn; //This boolean variable says if player two can answer
boolean didUpdateScore; //This flag is so that the score is not updated more than once per question
int currentTime; //This holds the current time in milliseconds
int startTime; //This is to hold the start time in milliseconds
boolean side;  //This is a boolean variable that holds which side should get a point added to their score
int result; //This is whether or not the player got the question right or wrong
int duration = -MAX_INT; //This is for how long a message should shown when a question is answered. 
boolean gameOver; //This is a boolean variable to check whether the game is over
int turnNumber; //This holds the numbers of turns that have ellapsed

void setup()
{
  size(1200, 800);
  video = new Capture(this, 640, 480, 15); 
  video.start(); 
  noStroke(); 
  newGame();
}

void draw() 
{
  if (!gameOver) { //If the game is not over
    if (video.available()) video.read();  //If the video signal is available
    if (turn) currentBackground = color(#660000);  //If the ball is moving in the positive direction update the background color
    else currentBackground = color(#000066);  //Else make it the background the other color
    background(currentBackground);  //Apply the background
    titleScreen(); //This displays "MATH PONG" at the top
    currentTime = millis() - startTime; //Update the currentTime
    video.loadPixels(); //Load the video pixels
    drawBoxes(boxSize, numAnswers); //Draw the boxes for the given box size and number of answers
    drawPointer(); //This function draws the pixels on the screen that match the player colors from the camera
    boolean turnChange = turn(); //This boolean is true only when the turn changes
    didAnswer(); //Function for when the player answers
    if ( duration >= currentTime ) { //If a message or paddle should be showing
      showResult(side, result);  //This function shows a message
      if (result == 1) { //This means a player got a question correct
        wall.render(side); //The wall should appear on the correct side of the ball
        if ( wall.x > -1 && side == turn) pong.barBounce(); //If the wall is on the screen, the pong should be able to bounce off of it
      }
    } else wall.move(-MAX_INT); //This moves the wall object off the screen so the pong doesnt interact with it
    if (turnChange) turnChangeActions(); //This is true when the turn changes
    drawQuestion(); //Draws the question
    drawAnswers(boxSize, numAnswers); //Draws the answers
    drawScore(); //Draws the score
    pong.render(); //Draws the pong
    pong.move(); //Moves the pong
    pong.wallBounce(); //Bounces the pong off the edges of the screen
    isGameOver();//Checks if the game is over
  } else { //This occurs when the game is over
    textSize(50); 
    textAlign(CENTER); 
    if (playerOneScore == 16) { //Player one won
      background(#660000); //set the background color
      endGame(); //This plays the confetti
      fill(255); //The following is the end game text
      text("PLAYER 1 WINS!", this.width/2, (this.height - video.height)); 
      text(str(playerOneScore) + " - " + str(playerTwoScore), this.width/2, (this.height - video.height)+ 50); 
      textSize(30); 
      text("(Press any key to restart)", this.width/2, (this.height - video.height)+ 150);
    } else { //Player two won
      background(#000066); //Set the background color
      endGame(); //This plays the confetti
      fill(255); //The following is the end game text
      text("PLAYER 2 WINS!", this.width/2, (this.height - video.height)); 
      text(str(playerTwoScore) + " - " + str(playerOneScore), this.width/2, (this.height - video.height)+ 50); 
      textSize(30); 
      text("(Press any key to restart)", this.width/2, (this.height - video.height)+ 150);
    }
    textAlign(LEFT);
  }
}

void endGame() {
  for (int i = 0; i < 250; i++) {
    confetti[i].render(); //Draw all 250 confetti objects
    if (confetti[i].y > this.height + 15) confetti[i] = new Confetti(); //If the confetti goes below the screen, create a new object
  }
}

void keyPressed() {
  if (gameOver) newGame(); //When a key is pressed begin a new game
}

void newGame() { //New game initializations
  pong = new Pong(); //Create a new pong object
  startTime = millis(); //Set the start time
  if ( pong.xMove > 0 ) { //If the pong is going left
    turn = true; //Turn == turn signifies movement is going right
    playerTwoTurn = true; //It is player two's turn
    playerOneTurn = false;
  }
  if ( pong.xMove < 0 ) { //If the pong is going right
    turn = false; //Turn == false signifies movement is going left
    playerOneTurn = true; //It is player one's turn
    playerTwoTurn = false;
  }
  wall = new Wall(); //Create a new wall object
  wall.move(-MAX_INT); //Move the wall off the screen
  createQuestion(0); //This creates a new question before the game begins at difficulty 0
  createAnswers(numAnswers, 0); //Create answers for the created question
  playerOneScore = 0; //Set P1's score to 0
  playerTwoScore = 0; //Set P2's score to 0
  didUpdateScore = false; //The score should be able to be modified
  duration = -MAX_INT; //Initialize it to a negative number
  numAnswers = 2; //Start with the number of choices as 2
  turnNumber = 0; //The turn number starts at 0
  currentTime = millis() - startTime; //Set the current time
  if (!turn) currentBackground = color(#660000);  //If the ball is moving left, change the color of the background
  else currentBackground = color(#000066); //If the ball is moving right, change the color of the background
  gameOver = false; //Game over is not true
}

void titleScreen() { //This displays "MATH PONG" at the top of the screen
  fill(255);
  textSize(25);
  textAlign(CENTER);
  text("MATH PONG", width/2, 25);
  textAlign(LEFT);
}

void isGameOver() { //Checks if the game is over
  if ( playerOneScore == 16 || playerTwoScore == 16) { //If either player's score is 16
    gameOver = true; //Game over is true
    confetti = new Confetti[250]; //Initialize the confetti array
    for (int i = 0; i < 250; i++) { 
      confetti[i] = new Confetti(); //Create 250 objects within the confetti array
    }
  }
}

boolean turn() { //This function returns true if the turn has changes
  if (turn == false && pong.xMove > 0) { //Updates the turn boolean when the turn has changes
    turn = true; //Pong is now moving in the right direction
    turnNumber++; //turn number has increased
    return true; //Return true since the turn has changed
  } else if (turn == true && pong.xMove < 0) { //Updates the turn boolean when the turn has changes
    turn = false; //Pong is now moving in the left direction
    turnNumber++; //turn number has increased
    return true; //Return true since the turn has changed
  } else return false; //Return false if the turn has not changed
}

void turnChangeActions() { //Actions to perform on a change of turns
  didUpdateScore = false; //A new turn so the score should be able to be modified with this boolean being false
  resetTurn(); //This chooses whose turn it should be

  if ((turnNumber) == 6 && numAnswers < 3) { //On the 6th turn, raise the number of choices given and reduce the box size
    numAnswers++; 
    boxSize -= 5;
  }

  if ((turnNumber) == 12 && numAnswers < 4) { //On the 12th turn, raise the number of choices given and reduce the box size
    numAnswers++; 
    boxSize -= 5;
  }

  if (playerOneTurn) { //If it is player one's turn
    createQuestion(playerOneScore/2);  //Create a question with a difficulty based on his current score
    createAnswers(numAnswers, playerOneScore/2); //Create answers with the current number of answers and an interval based on his score
  } else createQuestion(playerTwoScore/2); //Create a question with a difficulty based on his current score
  createAnswers(numAnswers, playerTwoScore/2); //Create answers with the current number of answers and an interval based on his score

  if ((turnNumber) % 5 == 0 && turnNumber != 0) { //Every 5th turn, make the ball go faster
    if (turn) pong.xMove+=1; //If its going to the right, make it go faster
    else pong.xMove-=1; //If its going to the left, make it go faster
  }
}

void resetTurn() {
  if (!playerOneTurn && !playerTwoTurn && turn) { //It is neither player's turn and the ball is going right
    playerTwoTurn = true; //Set player two's turn to true
  }
  if ( !playerOneTurn && !playerTwoTurn && !turn) { //It is neither player's turn and the ball is going left
    playerOneTurn = true; //Set player one's turn to true
  }
}


void didAnswer() {
  if (correctAnswer() == 2 && playerOneTurn) { //Player 1 got it wrong
    playerOneTurn = false; //Player 1 got it wrong and can no longer answer
    //side = false;
    result = 2; //Result == 2 means the player inputted the incorrect answer
    duration = currentTime + 2000; //duration for text
    //updateScore(false);
  } else if (correctAnswer() == 2 && playerTwoTurn) { //Player 2 got it wrong
    playerTwoTurn = false; //Player 2 got it wrong and can no longer answer
    //side = true; 
    result = 2; //Result == 2 means the player inputted the incorrect answer
    duration = currentTime + 2000; //duration for text
    //updateScore(true);
  } else if (correctAnswer() == 1 && playerOneTurn) { //Player 1 got it right
    playerOneTurn = false; //Player 1 got it right and can no longer answer
    side = false; //The wall should appear on the left side of the pong 
    result = 1; //Result == 1 means the player inputted the correct answer
    duration = currentTime + 1500; //Duration for the text and wall
    wall = new Wall(); //Create a new wall object
    updateScore(true); //Update the score
  } else if (correctAnswer() == 1 && playerTwoTurn) { //Player 2 got it right
    playerTwoTurn = false; //Player 2 got it right and can no longer answer
    side = true; //The wall should appear on the right side of the pong
    result = 1; //Result == 1 means the player inputted the correct answer 
    duration = currentTime + 1500; //Duration for the text and wall
    wall = new Wall(); //Create a new wall object
    updateScore(false); //Update the score
  } else if ( playerOneTurn && turn) { //Player 1 didn't answer
    playerOneTurn = false; //Player 1 didn't answer and it is no longer their turn
    //side = false; 
    result = 0; //Result == 0 means the player did not answer
    duration = currentTime + 1500; //Duration for text
    //updateScore(false);
  } else if ( playerTwoTurn && !turn) { //Player 2 didnt Answer
    playerTwoTurn = false; //Player 2 didn't answer and it is no longer their turn
    //side = true; 
    result = 0; //Result == 0 means the player did not answer
    duration = currentTime + 1500; //Duration for text
    //updateScore(true);
  }
}

void updateScore(boolean playerOne) { //boolean playerOne signifies if the score should be increased for player one or not
  if (!didUpdateScore) { //If the score has not yet been increased
    if (playerOne) { //If player one should get a point
      playerOneScore++; //Add one to their total
    } else { //If player two should get a point
      playerTwoScore++; //Add one to their total
    }
  }
  didUpdateScore = true; //The score has been increased and should not be updated again until the next turn
}


void drawScore() {
  textSize(25); 
  fill(playerOneColor); //Set to the player's color
  text("Player 1", 30, 25); //Print Player 1 above their score
  fill(playerTwoColor); //Set to the player's color
  text("Player 2", this.width-130, 25); //Print Player 2 above their socre
  textSize(60); 
  fill(255);
  text(str(playerOneScore), 50, 75); //Prints player 1's score
  text(str(playerTwoScore), this.width-100, 75); //Prints player 2's score
}

void createQuestion(int difficulty) {
  int op = 0; 
  int numOne = 0; 
  int numTwo = 0; 
  String[] operator = {
    " + ", " - ", " * ", "*"
  }; //Array of operators, * has two for a 50% change of picking it at some difficulties
  while ( (numOne >= -1 && numOne <= 1) || (numTwo >= -1 && numTwo <= 1)) { //So the numbers are never between -1 and 1
    switch(difficulty) { //Pick a case based on difficulty, The following cases just pick an operator and two random numbers in a certain interval
    case 0 : 
      op = int(random(2));
      numOne = int(random(-10, 10)); 
      numTwo = int(random(-5, 5)); 
      break; 
    case 1 : 
      op = int(random(3)); 
      numOne = int(random(-15, 15)); 
      numTwo = int(random(-5, 5)); 
      break; 
    case 2 : 
      op = int(random(4)); 
      numOne = int(random(-20, 20)); 
      numTwo = int(random(-5, 5)); 
      break; 
    case 3 : 
      op = int(random(2)); 
      numOne = int(random(-25, 25)); 
      numTwo = int(random(-10, 10)); 
      break; 
    case 4 : 
      op = int(random(3)); 
      numOne = int(random(-30, 30)); 
      numTwo = int(random(-10, 10)); 
      break; 
    case 5 : 
      op = int(random(4)); 
      numOne = int(random(-35, 35)); 
      numTwo = int(random(-10, 10)); 
      break; 
    case 6 : 
      op = 3; 
      numOne = int(random(-40, 40)); 
      numTwo = int(random(-15, 15)); 
      break; 
    case 7 : 
      op = 3;
      numOne = int(random(-45, 45)); 
      numTwo = int(random(-15, 15)); 
      break; 
    case 8 : 
      op = 3;
      numOne = int(random(-50, 50)); 
      numTwo = int(random(-15, 15)); 
      break;
    }
  }
  if (op == 0) answer = numOne + numTwo; //Compute the answer for addition
  if (op == 1) answer = numOne - numTwo; //Compute the answer for subtraction
  if (op == 2) answer = numOne * numTwo; //Compute the answer for multiplication
  if (op == 3) answer = numOne * numTwo; //Compute the answer for multiplication
  if (numTwo >= 0) //If the second number is non-negative
    question = str(numOne) + operator[op] + str(numTwo); //Construct the question 
  else //If the second number is negative
  question = str(numOne) + operator[op] + "(" + str(numTwo) + ")"; //Construct the question with parenthesis around the second number
}

void drawQuestion() { //This just displays the question near the top of the screen
  textAlign(CENTER, CENTER); 
  textSize(100); 
  fill(255); 
  text(question, this.width/2, (this.height - video.height)/4); 
  textAlign(LEFT);
}

void drawAnswers(int boxSize, int numAnswers) { //This displays the answers on the player's side of the boxes
  textSize(boxSize);
  int offset = boxSize * 3; //Offset from the center
  if (!turn) offset *= -1; //Which side of the box
  float z = (video.height-boxSize*numAnswers)/numAnswers; //Precise spacing
  float x = this.width/2 - boxSize/2 + offset; //The x location
  float y = (this.height - video.height)/2; //The y location
  fill(255); 
  for (int i = 0; i < numAnswers; i++) { //A for loop for the number of answers
    text(str(answers[i]), x, i*(video.height/numAnswers) + y + i*(z/numAnswers) + z/(8*numAnswers), 
    (this.width - video.width)/2 + video.width, i*(video.height/numAnswers) + y + i*(z/numAnswers) + boxSize); //Display the answers next to the boxes
  }
}

void createAnswers(int numAnswers, int difficulty) {
  answers = new int[numAnswers+1]; //An array to hold the answers and the index of the correct answer in the last index
  int answerIndex = int(random(numAnswers));  //Answer index set to a random number before the last index
  answers[numAnswers] = answerIndex; //Set the last index to the number where the answer is held
  answers[answerIndex] = answer; //Set the array[answerIndex] to the answer
  for (int i = 0; i < numAnswers; i++) { //The following fills the array with random answers around the correct answer, none of the answers will be repeated
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

void showResult(boolean whichSide, int whatResult) { //Result meaning: 0 = DID NOT ANSWER, 1 = CORRECT, 2 = WRONG
  String[] strings = {
    "Time's up!", "Correct!", "Incorrect!"
  }; //Array of results
  fill(255, 255, 0); 
  textSize(50);
  textAlign(CENTER); 
  if (!whichSide) { //Which side of the screen to display the result on
    pushMatrix(); 
    translate(this.width/2 - video.width/1.75, (this.height - video.height)); 
    rotate(radians(-25)); 
    text(strings[whatResult], 0, 0); //Display the result of the player
    popMatrix();
  } else {
    pushMatrix(); 
    translate(this.width/2 + video.width/1.75, (this.height - video.height)); 
    rotate(radians(25)); 
    text(strings[whatResult], 0, 0); //Display the result of the player
    popMatrix();
  }
  textAlign(LEFT);
}

void drawBoxes(int boxSize, int numAnswers) {
  float z = (video.height-boxSize*numAnswers)/numAnswers; //Specific spacing
  float x = this.width/2 - boxSize/2; //X location
  float y = (this.height - video.height)/2 + z/8; //Y location
  fill(255);
  for (int i = 0; i < numAnswers; i++) rect(x, i*(video.height/numAnswers) + y + i*(z/numAnswers), boxSize, boxSize); //Draw the boxes
}

void drawPointer() {
  this.loadPixels(); 
  //The following get the RGB values of the player's respective object colors
  float r1 = red(playerOneColor); 
  float g1 = green(playerOneColor); 
  float b1 = blue(playerOneColor); 
  float r2 = red(playerTwoColor); 
  float g2 = green(playerTwoColor); 
  float b2 = blue(playerTwoColor); 
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int vidPos = y*video.width + x; //index with respect to the video frame
      int thisPos = (this.width-video.width)/2 + (video.width - x - 1) + ((this.height-video.height)/2 + y) * this.width; //index with respect to the window frame
      color videoColor = video.pixels[vidPos]; //Color of the current pixel from the camera
      float rv = red(videoColor); //Red value of camera color
      float gv = green(videoColor); //Green value of camera color
      float bv = blue(videoColor); //Blue value of camera color
      float diffOne = dist(rv, gv, bv, r1, g1, b1); //The difference between player 1's color and the camera's color
      float diffTwo = dist(rv, gv, bv, r2, g2, b2); //The difference between player 2's color and the camera's color
      if (diffOne < threshold1) pixels[thisPos] = playerOneColor; //If it is below the threshold, change the window's pixel to the player color
      if (diffTwo < threshold2) pixels[thisPos] = playerTwoColor; //If it is below the threshold, change the window's pixel to the player color
    }
  }
  this.updatePixels(); //Update the window's pixel array
}

int correctAnswer() {
  if (returnAnswer(boxSize, numAnswers) != -1) { //If an answer is selected
    if (returnAnswer(boxSize, numAnswers) == answers[numAnswers]) return 1; //If the correct answer is selected return 1 
    else return 2; //If any other answer is selected return 2
  } 
  return -1; //If an answer has not yet been selected return -1
 }

int returnAnswer(int boxSize, int numAnswers) {
  this.loadPixels(); //Load the window's pixel array
  float z = (video.height-boxSize*numAnswers)/numAnswers; //Specific spacing from between the boxes
  float x2 = this.width/2 - boxSize/2; //The x location of the boxes
  float y2 = (this.height - video.height)/2 + z/8; //The y location of the boxes
  int[] count = new int[numAnswers]; //Array to hold the number of player object pixels that are within the boxes
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      for (int i = 0; i < numAnswers; i++) { //To check each of the boxes
        int vidPos = y*this.width + x; //Position in the pixel array with respect to the camera's window
        int thisPos = (this.width-video.width)/2 + (video.width - x - 1) + ((this.height-video.height)/2 + y) * this.width; //Position in the pixel array with respect to the window
        color thisColor = this.pixels[thisPos]; //The color of the current pixel from the window
        int x1 = x + (this.width-video.width)/2;  //The x location with respect to the window
        int y1 = y + (this.height-video.height)/2; //The y location with respect to the window
        rectMode(CORNER); 
        if (x1 >= x2 && x1 <= x2 + boxSize && y1 >= i*(video.height/numAnswers) + y2 + i*(z/numAnswers) && y1 <= i*(video.height/numAnswers) + y2 + i*(z/numAnswers) + boxSize) { //Check if the player's object is within a box
          if (thisColor == playerOneColor && playerOneTurn) { //If it is player 1's turn and the current pixel matches their object color
            count[i]++; //Increment the count of pixels for the current box (i)
          }
          if (thisColor == playerTwoColor && playerTwoTurn) { //If it is player 2's turn and the current pixel matches their object color
            count[i]++; //Increment the count of pixels for the current box (i)
          }
        }
      }
    }
  }
  int max = -1; //Set the max to a negative number
  for (int i = 0; i < numAnswers; i++) {
    if (count[i] > max) max = i; //If the count of the array is greater than the max
  }
  if (count[max] >= 8) return max; //If the count is above a given number, return max which is select box (return the number of the box that has been selected)
  else return -1; //If no boxes have more than the given number of pixels, return -1 (nothing has been selected yet)
}

