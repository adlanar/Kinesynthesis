//M. Adlan Ramly
//Credits to: Daniel Shiffman
// http://www.learningprocessing.com

//CONTROLS:
//Wave Motion Mode: 'z'
//Motion Tracker Mode: 'x'
//Monochrome Mode: 'c'

import processing.video.*;

//Wave variables
int xspacing = 16;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave
float theta = 0.0;  // Start angle at 0
float amplitude = 75.0;  // Height of wave
float period = 500.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] yvalues;  // Using an array to store height values for the wave
float avgMotion;
color bgColor = color(0,255,0,25);

float avgX;
float avgY;
int loc;

// Variable for capture device
Capture video;

// Previous Frame
PImage prevFrame;

// How different must a pixel be to be a "motion" pixel
float threshold = 50;

//Mode States
boolean waveModeIsOn = true;
boolean mTrackerModeIsOn = false;
boolean bwModeIsOn = false;

void setup() {
  size(320, 240);
  // Using the default capture device
  video = new Capture(this, width, height);
  video.start();

  // Create an empty image the same size as the video
  prevFrame = createImage(video.width, video.height, RGB);
}

// New frame available from camera
void captureEvent(Capture video) {
  // Save previous frame for motion detection!!
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  prevFrame.updatePixels();  //Read image from camera
  video.read();
}


void draw() {
  //background(0);
  
  image(video, 0, 0);

  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();

  float sumX = 0;
  float sumY = 0;
  int motionCount = 0;
  int totalMotion = 0;

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      //Where is the average pixel location
      loc = x + y*video.width;
      // What is the current color
      color current = video.pixels[x+y*video.width];
      // What is the previous color
      color previous = prevFrame.pixels[x+y*video.width];

      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); 
      float g1 = green(current);
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous);
      float b2 = blue(previous);

      // Motion for an individual pixel is the difference between the previous color and current color.
      float diff = dist(r1, g1, b1, r2, g2, b2);
      
      totalMotion += diff;
      
      avgMotion = totalMotion / video.pixels.length;

      // If it's a motion pixel add up the x's and the y's
      if (diff > threshold) {
        sumX += x;
        sumY += y;
        motionCount++;
        if (bwModeIsOn) {
          wRender();
        }
      }
      else {
        if (bwModeIsOn) {
        bRender();
        }
      }
    }
  }
  
  updatePixels();

  // average location is total location divided by the number of motion pixels.
  avgX = sumX / motionCount; 
  avgY = sumY / motionCount; 
  
  if (waveModeIsOn) {
    waveMode();
  }
  else if (mTrackerModeIsOn) {
  motionTrackerMode();
  }
  else if (bwModeIsOn) {
  bRender();
  wRender();
  }
  
}

//MODES
void waveMode() {
  calcWave();
  renderWave();
}

void motionTrackerMode(){
  renderPointer();
}

void bRender(){
  pixels[loc] = color(0);
}

void wRender(){
  pixels[loc] = color(255);
}

void calcWave() {
  //Sine wave values
  w = width+16;
  dx = (TWO_PI / period) * xspacing;
  yvalues = new float[w/xspacing];

  // Increment theta (try different values for 'angular velocity' here
  theta += 0.02;

  // For every x value, calculate a y value with sine function
  float xWave = theta;
  for (int i = 0; i < yvalues.length; i++) {
    yvalues[i] = sin(xWave)*avgMotion*5;
    xWave+=dx;
  }
}

void renderWave() {
  noStroke();
  fill(255);
  // A simple way to draw the wave with an ellipse at each location
  for (int x = 0; x < yvalues.length; x++) {
    ellipse(x * xspacing, height/2 + yvalues[x], 16, 16);
  }
}

void renderPointer() {
  // Draw a circle based on average motion
  smooth();
  noStroke();
  fill(255);
  ellipse(avgX, avgY, 16, 16);
  System.out.println("X: " + avgX + ", Y: " + avgY);
}


void keyPressed(){
  if(key == 'z') {
  waveModeIsOn = true;
  mTrackerModeIsOn = false;
  bwModeIsOn = false;
  }
  if(key == 'x') {
  mTrackerModeIsOn = true;
  waveModeIsOn = false;
  bwModeIsOn = false;
  }
  if(key == 'c') {
  waveModeIsOn = false;
  mTrackerModeIsOn = false;
  bwModeIsOn = true;
  }
}