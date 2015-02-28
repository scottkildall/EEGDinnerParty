import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class EEGDinnerParty extends PApplet {

/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 



MuseHeadset[] headsets;
DebugDisplay debugDisplay;
DinnerDisplay dinnerDisplay;

int numDevices = 4;
Boolean bDebugDisplay = false;

public void setup() {
  //size(1920,1080 );
  size(1920,1080, OPENGL );
  // comment out to see all our fonts
  //print(PFont.list());
  
  frameRate(60);

  //-- init headsets
  headsets = new MuseHeadset[numDevices];
  for( int i = 0; i < numDevices; i++ ) {
    int portNum = 5004 + i + 1;    // numbering starts at 5001 for 'muse1', etc
    headsets[i] = new  MuseHeadset(portNum);
  }
  
  debugDisplay = new DebugDisplay(numDevices,headsets);
  dinnerDisplay = new DinnerDisplay(numDevices,headsets);
  dinnerDisplay.toggleHelperImage();
}

public void draw() {
  if( bDebugDisplay )
    debugDisplay.draw();
  else
    dinnerDisplay.draw();
}

public void stop() {
    for( int i = 0; i < numDevices; i++ ) {
    headsets[i] = null;
  }
}

public void keyPressed() {
   // SPACE = debug mode
   if( key == '1' )
      dinnerDisplay.toggleHelperImage();
      
  if (key == 'd' || key == 'D')
       bDebugDisplay = !bDebugDisplay;
       
    if (key == 'c' || key == 'C')
       dinnerDisplay.clearPlot();
  
  if( key == ' ' )
      dinnerDisplay.startPlot();
}





/*******************************************************************************************************************
//
//  Class: Timer
//
//  Written by Scott Kildall
//
//------------------------------------------------------------------------------------------------------------------
// - Very simple but incredibly useful timer class
// - Call start() whenever it expires to reset the time
// - Call expired() to check to see if timer is still active
//
*********************************************************************************************************************/

public class Timer {
  public Timer( long _duration ) {
      setTimer(_duration);
  }
  
  public void start() { 
    startTime = millis();
  }
  
  public void setTimer(long _duration) {
    duration = _duration;
  }
  
  public Boolean expired() {
    return ((startTime + duration) < millis());
  }
 
  //-------- PRIVATE VARIABLES --------/
  private long duration;
  protected long startTime = 0;	 	
}

/**
 * debugDisplay
 */
 


class DebugDisplay {
  MuseHeadset [] headsets;
  DebugHeadsetDisplay[] displays;
  int numDevices;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  DebugDisplay(int _numDevices, MuseHeadset [] _headsets) {
    numDevices = _numDevices;
    headsets = _headsets;
    
    displays = new DebugHeadsetDisplay[numDevices];
    displays[0] = new DebugHeadsetDisplay( 50, 50, "red");
    displays[1] = new DebugHeadsetDisplay( 1000, 50, "green");
    displays[2] = new DebugHeadsetDisplay( 50, 550, "blue");
    displays[3] = new DebugHeadsetDisplay( 1000, 550, "yellow");
  }
  
  //-- draw 
  public void draw() {
    background(0);    
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
  
  
    for( int i = 0; i < numDevices; i++ )
      displays[i].draw(headsets[i]); 
  }
}
  
  
 
/**
 * MuseHeadset Class
 * Written by Scott Kildall
 * March 2014
 * 
 * Designed for use with multiple Muse headsets, will listen to OSC events
 * Headset should be hooked up to the same computer, network connections can be turned off.
 *
 * In Terminal Windows, type in, something like:
 * muse-io --preset 14 --device muse --osc osc.udp://localhost:5000
 * And in Processing, instatiate it such as:
 *    new  MyOSCListener(5000);
 *
 * Each headset needs its own unique port number and device name.
 * Device name can be changed in SystemPrefs->Bluetooth
 */
 
//-- change these
Boolean uiDrawBattery = false;
Boolean uiDrawForeheadConnection = true;    // headset

//-- don't change these
static int uiHeight = 450;
static int uiWidth = 900;

static int uiBallHeight = 300;

class DebugHeadsetDisplay {
  float drawX = 0;
  float drawY = 0;
  int r = 255;
  int g = 255;
  int b = 255;
  
  float alphaX = 80;
  float betaX = 180;
  float deltaX = 280;
  float gammaX = 380;
  float thetaX = 480;
  
  float [] waveData;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  DebugHeadsetDisplay(int x, int y, String colorStr ) {
    drawX = x;
    drawY = y;
    setColor(colorStr);
    
    waveData = new float[4];
  }
  
  //-- draw 
  public void draw(MuseHeadset headset) {
    drawFrame();
    //drawDeviceStats(headset);
    
    noStroke();
   
    drawWaveBalls(prepareDrawAlpha(headset));
    drawWaveBalls(prepareDrawBeta(headset));
    drawWaveBalls(prepareDrawDelta(headset));
    drawWaveBalls(prepareDrawGamma(headset));
    drawWaveBalls(prepareDrawTheta(headset));
    drawHorseshoe(headset);
    
//    if (uiDrawBattery)
//      drawBatteryLife(headset);
      
      
    drawPacketMS(headset);
  }
  
  
  //---- private functions
  //-- set internal r,b,g values
  private void setColor(String colorStr) {
    if( colorStr.equals("red") ) {
      r = 255; g = 0; b = 0;
    }
    else if( colorStr.equals("green") ) {
      r = 0; g = 255; b = 0;
    }
    else if( colorStr.equals("blue") ) {
      r = 0; g = 0; b = 255;
    }
    else if( colorStr.equals("yellow") ) {
      r = 255; g = 255; b = 0;
    }
  }
  
  private void drawFrame() {
    noFill();
    stroke(r,g,b);
    strokeWeight(2);
    rect(drawX, drawY, uiWidth, uiHeight);
  }
  
  
  // Main draw function for each device
  private void drawDeviceStats(MuseHeadset headset) { 
    if( uiDrawForeheadConnection ) {
      drawForeheadConnection(headset);
      drawGoodConnection(headset);
    }
  }
  
  
   

  // Single indication as to whether or not the forehead is 'connected'
  private void drawForeheadConnection(MuseHeadset headset) {
    int diameter = 10;
    noStroke();
    /*
    if( headset.touchingForehead == 0 )
      fill(255,0,0);
    else {
      fill(0,255,0);
    }
    ellipse( drawX + diameter, drawY + diameter, diameter, diameter);  // Draw gray ellipse using CENTER mode
    */
  }

  // 4 connections for touching various points on forehead
  private void drawGoodConnection(MuseHeadset headset) {
    int diameter = 10;
    noStroke();
    /*
    for( int i = 0; i <4; i++ ) {
      if( headset.good[i] == 0 )
        fill(255,0,0);
      else 
        fill(0,255,0);
      
      ellipse(drawX+diameter + diameter * (i*2), drawY + diameter*3, diameter, diameter);  // Draw gray ellipse using CENTER mode
    }  
    */
  }

  // converts long decimal, i.e. .231 to float
  private String floatToPct(float n) {
     int rn = round(n *100);
     return str(rn) + "%";
  }
  
  public float prepareDrawAlpha(MuseHeadset headset) {
    fill(0,200,200);
    stroke(0,200,200);
    strokeWeight(1);
     
    waveData[0] = headset.alpha[0];
    waveData[1] = headset.alpha[1];
    waveData[2] = headset.alpha[2];
    waveData[3] = headset.alpha[3];
    
    return drawX + alphaX;
  }
  
  public float prepareDrawBeta(MuseHeadset headset) {
    fill(200,0,0);
    stroke(200,0,0);
    strokeWeight(1);
     
    waveData[0] = headset.beta[0];
    waveData[1] = headset.beta[1];
    waveData[2] = headset.beta[2];
    waveData[3] = headset.beta[3];
    
    return drawX + betaX;
  }
  
  public float prepareDrawDelta(MuseHeadset headset) {
    fill(0,200,0);
    stroke(0,200,0);
    strokeWeight(1);
     
    waveData[0] = headset.delta[0];
    waveData[1] = headset.delta[1];
    waveData[2] = headset.delta[2];
    waveData[3] = headset.delta[3];
    
    return drawX + deltaX;
  }
  
  public float prepareDrawGamma(MuseHeadset headset) {
    fill(0,0,200);
    stroke(0,0,200);
    strokeWeight(1);
     
    waveData[0] = headset.gamma[0];
    waveData[1] = headset.gamma[1];
    waveData[2] = headset.gamma[2];
    waveData[3] = headset.gamma[3];
    
    return drawX + gammaX;
  }
  
  public float prepareDrawTheta(MuseHeadset headset) {
    fill(200,0,200);
    stroke(200,0,200);
    strokeWeight(1);
     
    waveData[0] = headset.theta[0];
    waveData[1] = headset.theta[1];
    waveData[2] = headset.theta[2];
    waveData[3] = headset.theta[3];
    
    return drawX + thetaX;
  }
  
  // fill(r,g,b) should be called beforehand
  // startX = alphaX, betaX, etc
  // values[] should be an array of 4 elements, each such as headset.betaRelative, etc
  public void drawWaveBalls(float startX) {
     int  diameter = 10;
     float dy = 50 + drawY  + uiBallHeight;    // we will subtact from this:  -(float(uiBallHeight)*thetaRelative[i].mellow);
     
     float lastX = 0;
     float lastY = 0;
     
     for( int i = 0; i < 4; i++ ) { 
       float tx = startX + (i * (diameter*2));
       float ty = dy - (PApplet.parseFloat(uiBallHeight/2)*(waveData[i]/2));
       ellipse(tx, ty, diameter, diameter);  // Draw gray ellipse using CENTER mode
       
       if( i > 0 )
         line(lastX,lastY, tx, ty);
        
        lastX = tx;
        lastY = ty;
     }
  }
  
  // fill(r,g,b) should be called beforehand
  // startX = alphaX, betaX, etc
  // values[] should be an array of 4 elements, each such as headset.betaRelative, etc
  public void drawHorseshoe(MuseHeadset headset) {
     fill(255, 255, 255);
     noStroke();
     textSize(12);
     
     for( int i = 0; i < 4; i++ ) 
       text( headset.horseshoeStrings[i], drawX + 30 + (i * 50), drawY + 30); 
  }
 
 
/*
  // Draws mellow life as relative position, index = inde into array of headset
  void drawTheta(MuseHeadset headset) {
     int  diameter = 10;
     float thetaX = drawX + 300;
     float thetaY = 50 + drawY  + uiBallHeight;    // we will subtact from this:  -(float(uiBallHeight)*thetaRelative[i].mellow);
     
     stroke(15,245,145);
     strokeWeight(1);
     
     fill(15,245,145);
     
     
     float lastX = 0;
     float lastY = 0;
     
     for( int i = 0; i < 4; i++ ) { 
       float tx = thetaX + (i * (diameter*2));
       float ty = thetaY - (float(uiBallHeight/2)*(headset.thetaRelative[i]/2));
       ellipse(tx, ty, diameter, diameter);  // Draw gray ellipse using CENTER mode
       
        if( i > 0 ) {
        line(lastX,lastY, tx, ty);
        }
        lastX = tx;
        lastY = ty;
        
     }
     
      fill(200,200,200);
      textSize(12);
      //text( floatToPct(headset.mellow),mellowX + 20, mellowY+ 5); 
  }
*/
/*
  // Draws battery life as relative position, index = inde into array of headset
  void drawBatteryLife(MuseHeadset headset) {
     fill(255, 255, 255);
     noStroke();
     textSize(18);
     float batteryPct = headset.batteryPct;
     String batteryStr = (batteryPct < 0) ? "---" :  str(headset.batteryPct)+"%";
     text( batteryStr, drawX + uiWidth - 70, drawY + 30); 
  }
  */
  public void drawPacketMS(MuseHeadset headset) {
    int elapsedMS = (millis() - headset.lastPacketTime);
    float elapsedSec = PApplet.parseFloat(elapsedMS)/1000.0f;
    
    fill(255, 255, 255);
    noStroke();
    textSize(12);
    text( "elapsed: " + str(elapsedSec) + " secs", drawX + 20, drawY + uiHeight - 30); 
  }
}
/**
 * dinnerDisplay.pde
 */
 


class DinnerDisplay {
  DinnerHeadsetDisplay[] displays;
  MuseHeadset [] headsets;
  int numDevices;
  PImage helperImage;
  PImage bannerImage;
  Boolean bDisplayHelperImage = true;
  Plotter plotter;
  PFont headingFont;    // "Live EEG Feed" and "BBQ Taste Index"
  PShape graySwatch;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  DinnerDisplay(int _numDevices, MuseHeadset [] _headsets) {
    numDevices = _numDevices;
    headsets = _headsets;
    
    headingFont = createFont("Arial-Bold", 36 );  //-- XXX: this needs to be bold
    makeGraySwatch();
    
    displays = new DinnerHeadsetDisplay[numDevices];
    
    int tasteX = 294;
    int tasteXMargin = 433;
    int tasteY = 890;
    int iconX = 1538;
    int iconXMargin = 63;
    int iconY =  148;   //232;
    displays[0] = new DinnerHeadsetDisplay(headsets[0], "pig_icon.png", 132, 18, 37, tasteX, tasteY, iconX, iconY);
    tasteX = tasteX + tasteXMargin;
    iconX = iconX + iconXMargin;
    displays[1] = new DinnerHeadsetDisplay( headsets[1], "martini_icon.png", 89, 81, 148, tasteX, tasteY, iconX, iconY);
    tasteX = tasteX + tasteXMargin;
    iconX = iconX + iconXMargin;
    displays[2] = new DinnerHeadsetDisplay( headsets[2], "fire_icon.png", 255, 152, 33, tasteX, tasteY, iconX, iconY);
    tasteX = tasteX + tasteXMargin;
    iconX = iconX + iconXMargin;
    displays[3] = new DinnerHeadsetDisplay( headsets[3], "beaker_icon.png", 70, 173, 0, tasteX, tasteY, iconX, iconY);
    
    
    bannerImage = loadImage("banner.png");
    
    //-- allocate and initialize plotter
    float numMinutes = 5.0f;  // 1.0 is good for testing
    plotter = new Plotter(headsets, 162, 234 );
    plotter.initialize( 1584, 344, numMinutes, 10, 5);
  }
  
  public void toggleHelperImage() {
     bDisplayHelperImage = !bDisplayHelperImage; 
     
     if( bDisplayHelperImage )
       helperImage = loadImage("background.jpg");
  }
  
  //-- draw 
  public void draw() {
    background(255);    
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
    
    
    
    if( helperImage != null && bDisplayHelperImage == true ) {
      imageMode(CORNER);
      tint(255,128);
      image(helperImage,0,0);
      noTint();
    }
    
    drawGraySwatch();
    
    imageMode(CORNER);
    image(bannerImage,0,0);
    
    drawLabels();
    
    for( int i = 0; i < numDevices; i++ )
      displays[i].draw(headsets[i]); 
      
     plotter.draw();
     for( int i = 0; i < numDevices; i++ ) {
        displays[i].setFillColor();
        plotter.drawPlot(i);
     }
     
     for( int i = 0; i < numDevices; i++ )
        displays[i].drawIcons(); 
  }
  
  public void drawLabels() {
      textFont(headingFont);
      textAlign(CENTER);
      fill(0,0,0);
      text("Live EEG Feed", 355,210);
      text("BBQ Taster Index", width/2,750);
  }
  
  public void drawGraySwatch() {
      shape(graySwatch,0,0);
  }
  
  //-- we can also use this as a toggle button
  public void startPlot() {
      plotter.clear();
      plotter.start();
  }
  
  //-- we can also use this as a toggle button
  public void clearPlot() {
      plotter.clear();
  }
  
  private void makeGraySwatch() {
     graySwatch = loadShape("grayswatch.svg");
  }
}
  
  
 
/**
 * DinnerHeadsetDisplay
 * Written by Scott Kildall
 * March 2014
 * 
*/
 
class DinnerHeadsetDisplay {
  MuseHeadset headset;
  // colors for the graphing function
  int r;
  int g;
  int b;
  int tasteX;
  int tasteY;
  int iconX;
  int iconY;
  PImage tasteDialImage;
  PImage tasteBackgroundImage;
  PImage iconImage;
  float degreesMultiplier;
  
  PFont tasteIndexFont;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  DinnerHeadsetDisplay(MuseHeadset _headset, String iconFilename, int _r, int _g, int _b, int _tasteX, int _tasteY, int _iconX, int _iconY ) {
    headset = _headset;
    // Save local variables
    r = _r;
    g = _g;
    b = _b;
    tasteX = _tasteX;
    tasteY = _tasteY;
    iconX = _iconX;
    iconY = _iconY;
    
    //-- hardcoded. In an ideal world, these would be static variables, but memory isn't an issue here
    tasteBackgroundImage = loadImage("taste_index_background.png");
   // tasteDialImage = loadImage("taste_index_dial.png");
   // tasteDialImage = loadImage("gradient_testdial.jpg");
   tasteDialImage = loadImage("taste_index_dial_elongated.png");
    iconImage = loadImage(iconFilename);
    
    // for taste index, dial rotation
    degreesMultiplier = 180.0f/100.0f;
    
    tasteIndexFont = createFont("Arial", 14 );  //-- XXX: needs GE font, whatever this is
  }
  
  public void setFillColor() {
    fill(r,g,b);
    stroke(r,g,b);  
  }
  
  //-- draw 
  public void draw(MuseHeadset headset) {
    drawGraph();
    drawTasteIndex();
    drawTasteIndexLabels();
  }
  
  
  public void drawTasteIndex() {
    imageMode(CENTER);
    image(tasteBackgroundImage, tasteX, tasteY);
    image(iconImage, tasteX, tasteY + 130 );
    
    // rotation code for the dial indicator
    pushMatrix();
    translate( tasteX,tasteY+80);
    rotate(radians(degreesMultiplier*headset.getTasteIndex()));
    image(tasteDialImage,0,0);
    popMatrix();
    
    // shows taste index as a percentage
    /*
    fill(0,0,0);
    textSize(14);
    text( String.format("%.0f",headset.getTasteIndex()) + "%", tasteX, tasteY  );
    */
  }
  
  // hardcoded-labels
  public void drawTasteIndexLabels() {
    fill(0,0,0);
    textFont(tasteIndexFont);
    textAlign(CENTER);
    
    float xLowerOffset = 120;
    float xUpperOffset = 115;
    float yLowerOffset = 110;
    float yUpperOffset = -90;
    
    text(  "#Trainee", tasteX - xLowerOffset, tasteY + yLowerOffset );
     text(  "#SeriousFoodie", tasteX - xUpperOffset, tasteY + yUpperOffset );
      text(  "#TopChef", tasteX + xUpperOffset,tasteY + yUpperOffset );
      text(  "#PitMaster", tasteX + xLowerOffset, tasteY + yLowerOffset );
  }
  
  //-- this is a separate draw function since the icons should always be on top of the graph lines from other EEG data
  public void drawIcons() {
    imageMode(CENTER);  
    image(iconImage, iconX, iconY );
  }
  
  private void drawGraph() {
    noFill();
    stroke(r,g,b);
    strokeWeight(2);
  }
}
 /**
 * MuseHeadset Class
 * Written by Scott Kildall
 * March 2014
 * 
 * Designed for use with multiple Muse headsets, will listen to OSC events
 * Headset should be hooked up to the same computer, network connections can be turned off.
 *
 * In Terminal Windows, type in, something like:
 * muse-io --preset 14 --device muse --osc osc.udp://localhost:5000
 * And in Processing, instatiate it such as:
 *    new  MyOSCListener(5000);
 *
 * Each headset needs its own unique port number and device name.
 * Device name can be changed in SystemPrefs->Bluetooth
 */
 
class MuseHeadset {
  int port;
  OscP5 osc;
  
  //int touchingForehead = 0;
  //float batteryPct = -1.0;    // NO READING
  //int[] good; // num sensors
  
  // These are "absolute" rather than relative values
  float [] alpha;
  float [] beta;
  float [] delta;
  float [] gamma;
  float [] theta;
  float [] horseshoeValues;
  String [] horseshoeStrings;
  
  // quantization
  float qAlpha;
  float qBeta;
  float qDelta;
  float qGamma;
  float qTheta;
  
  int lastPacketTime;
  
  float plotValue;
  boolean bRandomMode;
  
  float tasteIndex;
  
  MuseHeadset(int thePort) {
    port = thePort;
    osc = new OscP5(this,port);
    
    //good = new int[4];
    alpha = new float[4];
    beta = new float[4];
    delta = new float[4];
    gamma = new float[4];
    theta = new float[4];
    horseshoeValues = new float[4];
    horseshoeStrings = new String[4];
    for( int i = 0; i < 4; i++ )
      horseshoeValues[i] = -1;    // not yet being used
      
    generateHorseShoeStrings();
    
    zeroQWaveValues();
    
    lastPacketTime = millis();
    
    bRandomMode = true;
    
    resetData();
  }
  
  public float getTasteIndex() {
    return tasteIndex; 
  }
  
  public void resetData() {
     tasteIndex = 50;
     plotValue = random(0,100);
  }
  
  public float getPlotValue() {
     return plotValue; 
  }
   
   public void nextPlotValue() {
      if( bRandomMode ) {
        plotValue = plotValue + random(-3,3);
        if( plotValue < 0 )
          plotValue = plotValue + random(-plotValue,3.5f);
        else if( plotValue > 100 )
          plotValue = plotValue - random((plotValue-100),3.5f);
          
        tasteIndex = tasteIndex + random(-1,1);
        if( tasteIndex < 0 )
          tasteIndex = 0;
        else if( tasteIndex > 100 )
          tasteIndex = 100;
      }
   }
             
  public void zeroQWaveValues() {
      qAlpha = 0.0f;
      qBeta = 0.0f;
      qDelta = 0.0f;
      qGamma = 0.0f;
      qTheta = 0.0f;
  }
  
  //-- based on horseshoe settings, will generate average qQave values
  public float generateQWaveValue(float [] waveValues) {
   
    for( int i = 0; i < 4; i++ ) {
       // generate qValue here 
    }
   
   return 0.0f;
  }
  public void generateHorseShoeStrings() {
    for( int i = 0; i < 4; i++ ) {
      if( horseshoeValues[i] == 4.0f )
        horseshoeStrings[i] = new String("none");
      else if( horseshoeValues[i] == 3.0f )
        horseshoeStrings[i] = new String("bad");
      else if( horseshoeValues[i] == 2.0f )
        horseshoeStrings[i] = new String("ok");
      else if( horseshoeValues[i] == 1.0f )
        horseshoeStrings[i] = new String("good");
       else
        horseshoeStrings[i] = new String("N/A");
    }
  }
  
  // incoming osc message are forwarded to the oscEvent method, private to this class
  public void oscEvent(OscMessage theOscMessage) {
    // Uncomment for "raw" debugging"
    //print (addrPattern);
    
    String addrPattern = theOscMessage.addrPattern();
    
    // ALPHA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/alpha_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        alpha[i] = theOscMessage.get(i).floatValue();
      }
      qAlpha = generateQWaveValue(alpha);
    }
    
    // BETA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/beta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        beta[i] = theOscMessage.get(i).floatValue();
      }
    }
   
   // DELTA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/delta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        delta[i] = theOscMessage.get(i).floatValue();
      }
    }
    
    // GAMMA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/gamma_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        gamma[i] = theOscMessage.get(i).floatValue();
      }
    }
    
    // THETA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/theta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        theta[i] = theOscMessage.get(i).floatValue();
      }
    }
    
    // HORSESHOE
    if( addrPattern.equals("/muse/elements/horseshoe") ) {
      for( int i = 0; i < 4; i++ ) {
        horseshoeValues[i] = theOscMessage.get(i).floatValue();
      }
      generateHorseShoeStrings();
    }
    
    ///REMOVE (LATER)
    /*
    else if(  addrPattern.equals("/muse/elements/touching_forehead") ) {
      //println("touching forehead typetag: "+ theOscMessage.typetag());
      touchingForehead = theOscMessage.get(0).intValue();
    }  
    else if( addrPattern.equals("/muse/elements/is_good") ) {
      //println("touching forehead typetag: "+ theOscMessage.typetag());
      for(int i = 0; i <4;i++ ) {
        good[i] = theOscMessage.get(i).intValue();
      }
    }  
    else if( addrPattern.equals("/muse/batt")) {
        // State of Charge, Divide this by 100 to get percentage of charge remaining, (e.g. 5367 is 53.67%)
       batteryPct = float(theOscMessage.get(0).intValue()) / 100.0;
        //println(batteryPct);
   }
   else if( addrPattern.equals("/test"))  {
     println("TEST @ Port: " + str(port));
      //println( "message = " + str(theOscMessage.get(0).intValue()));
      
   }
   */
   // last communication, whatever it might be
   lastPacketTime = millis();
  }
}
/**
 *   Plotter.pde
 *    
 *  Plots waveforms from headsets on the screen, using timer classes for callbacks
 */
 


class Plotter {
  MuseHeadset [] headsets;
  int numHeadsets;
  
  Boolean bRunning = false;
  int numPlottedPixels;   // how many pixels we have plotted on the screen, we use this for drawing
  Timer plotTimer;    // this should be the duration of the dinner party
  Timer pixelTimer;    // this will get called for every pixel that we plot
  
  float drawX;
  float drawY;
  float w;  // width
  float h; // height
  int numPixels;  // same as width
  float numMinutes;
  int numTimeIncrements;
  int numHeightIncrements;
  long duration;
  
  // more drawing code
  float vLabelsOffset;  // how much space between each line or for text
  float vPlotMultiplier;  // how much we mutliply each data point by to match our vertical plot
  String [] vLabels;      // vertical labels, for BBQ Affinity
  
  float hLabelsOffset;  // how much horziontal space
  String [] hLabels;      // vertical labels, for BBQ Affinity
  

  PFont axesTextFont;
  PFont axesNumbersFont;
  
  //-- alloc this
  float [][] plotData;
  
  float lastMillis;
 
  //-- constructor, mostly empty
  Plotter(MuseHeadset [] _headsets, float _drawX, float _drawY) {
      headsets = _headsets;
      numHeadsets = headsets.length;
      drawX = _drawX;
      drawY = _drawY;
      
      numPlottedPixels = 0;
      plotTimer = null;
      
      //-- fonts for drawing
      axesTextFont = createFont("Arial", 28.3f );  
      axesNumbersFont = createFont("Arial", 14 );  //-- XXX: this needs to be updated
  }
  
  
  //-- must be called before start(), we pack the initialization code here, mostly for legibility
  //-- duration is in minutes and we will subdivide internally
  //-- time always starts at zero
  //-- height is always 0-100, for 0-100, num height increments = FIVE, [0,20,40,60,80,100]
  public void initialize( float _w, float _h, float _numMinutes, int _numTimeIncrements, int _numHeightIncrements) {
    //-- always have to have at least 2 increments: a start and front
    if( _numTimeIncrements < 1 || _numHeightIncrements < 1 ) {
       println( "error in plotter.initialize(): _numTimeIncrements and _numHeightIncrements must be > 1" );
       return; 
    }
    
    // VARIABLES FOR WIDTH / HORIZONTAL
    numPixels = (int)_w - 20;  // number of pixels is actually slightly less than the width
    println("num pixels = " + str(numPixels) );
    
    w = _w;
    numTimeIncrements = _numTimeIncrements;
    
    // Allocate receptors for pixels
    plotData = new float[numHeadsets][numPixels];
    numPlottedPixels = 0;
    
    //-- how much space between each horizontal line, used in drawAxes()
    hLabelsOffset = (float)numPixels/(float)(numTimeIncrements);
    
    // generate all the strings for drawing
    numMinutes = _numMinutes;
    hLabels = new String[numTimeIncrements+1];
    float incrementValue = numMinutes/numTimeIncrements;
    //println( "H plotter: increment value = " + str(incrementValue) );
    for( int i = 0; i < (numTimeIncrements+1); i++ ) {
      float fpLabel = 0.0f + (i*incrementValue);
      hLabels[i] = String.format("%.1f",fpLabel);
      
      // trim off extra ".0"
      int len = hLabels[i].length();
      if( len > 1  ) {
        String tailStr = hLabels[i].substring(len-2,len);
        if(tailStr.equals(".0"))
          hLabels[i] = hLabels[i].substring(0,len-2);
      }
       
      //println( "plotter: string label = " + hLabels[i] );
    }
    
    // VARIABLES FOR HEIGHT / VERTICAL
    h = _h;
    numHeightIncrements = _numHeightIncrements;
    vPlotMultiplier = h/100.0f;
    
    //-- how much space between each horizontal line, used in drawAxes()
    vLabelsOffset = h/(float)(numHeightIncrements);
    vLabels = new String[numHeightIncrements+1];
    int incrValue = 100/numHeightIncrements;
//    println( "V plotter: vLabelsOffset = " + str(vLabelsOffset) );
//    println( "V plotter: height = " + str(h) );
//    println( "V plotter: increment value = " + str(incrementValue) );
    for( int i = 0; i < (numHeightIncrements+1); i++ ) {
      int intLabel = 100 - (i*incrValue);
      vLabels[i] = str(intLabel);
      println( "plotter: string label = " + vLabels[i] );
    }
    
    
    duration = (long)numMinutes * 60 * 1000;
    println( "plotter.duration = " + str(duration) );
    
    plotTimer = new Timer(duration);
    
    
    long msAdjust = 10;
    long pixelTimerDuration = duration/numPixels - msAdjust;
    println( "duration = " + str(duration) );
    println( "numPixels = " + str(numPixels) );
    println( "plotter.pixelTimerDuration = " + str(pixelTimerDuration) );
    
    pixelTimer = new Timer(pixelTimerDuration);
  }
  
  //-- begins a new plot: initializes plotter, clears old values
  public void start() {
    //-- plotTimer is null if initialize() hasn't been called
    if( plotTimer == null ) {
      println("plotter.initialize() must be called before plotter.start()");  
      return;
    }
    numPlottedPixels = 0;
    println( "start millis() = " + millis() );
    plotTimer.start();
    pixelTimer.start();
    
    bRunning = true;
  }  
  
  public void clear() {
    println( "CLEAR");
      numPlottedPixels = 0;
  }
  
  public boolean isDone() {
     return (bRunning == false);
  }
  
  public void draw() {
    drawAxes();
    drawLabels();
    updatePlot();
  }
  
  private void drawLabels() { 
    textFont(axesTextFont);
    textAlign(CENTER);
    
    text( "Time (minutes ago)", width/2 -20, 660 );
     
    pushMatrix();
    translate( width/2 -900, height/2 - 140);
    rotate(radians(270));
    text( "BBQ Affinity (%)", 0,0);
    popMatrix();
     
  }
  private void drawAxes() {
      // draw the numbers here
      textFont(axesNumbersFont);
      textAlign(CENTER);
      
      // gray color for the lines
      fill(0,0,0);
      stroke(202,205,208);
      strokeWeight(2);
      
      // draw horizontal stuff
      for( int i = 0; i < (numTimeIncrements+1); i++ )  {
          text( hLabels[i], drawX + (i * hLabelsOffset), drawY + h + 28 );
      }
      
      // draw veritcal stuff
       for( int i = 0; i < (numHeightIncrements+1); i++ )  {
           text( vLabels[i], drawX - 30, drawY + (i * vLabelsOffset) + 6 );
           
           line(drawX,drawY + (i * vLabelsOffset) ,drawX + w, drawY + (i * vLabelsOffset) );
       }
     
     //    line(drawX,drawY+h,drawX + w, drawY+h );
     
  }
  
  public void drawPlot(int headsetNum) {
     for( int i = 0; i < numPlottedPixels; i++ ) {
       point( drawX + i, drawY + h - plotData[headsetNum][i]);
     }
  }
  
   private void updatePlot() {
     if( bRunning ) {
       if( pixelTimer.expired()) {
         
         //lastMillis = millis();

         pixelTimer.start();
         
         for( int i = 0; i < numHeadsets; i++ ) {
             plotData[i][numPlottedPixels] = headsets[i].getPlotValue() * vPlotMultiplier;
             headsets[i].nextPlotValue(); 
          }
          
         // prevent overflow, in case plot pixels exceeds buffer
          if( numPlottedPixels < numPixels-1 )
            numPlottedPixels = numPlottedPixels + 1; 
       }
       if( plotTimer.expired()) {
           println("DONE: Plot time expired");
           println("pixeltimer, num Plotted pixels: " + str(numPlottedPixels) );
           bRunning = false;
           println( "end millis() = " + millis() );
       }
     }
   }
   
   
}
  
  
 
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "EEGDinnerParty" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
