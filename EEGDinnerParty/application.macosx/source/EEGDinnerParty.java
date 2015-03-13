import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import com.google.gson.Gson; 
import com.google.gson.GsonBuilder; 
import java.util.Date; 

import com.google.gson.reflect.*; 
import com.google.gson.internal.*; 
import com.google.gson.stream.*; 
import com.google.gson.internal.bind.*; 
import com.google.gson.*; 
import com.google.gson.annotations.*; 

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
RecordPrefs prefs;

int numDevices = 4;
Boolean bDebugDisplay = false;

public void setup() {
  //size(1920,1080 );
  size(1920,1080, OPENGL );
 
  // comment out to see all our fonts
  //print(PFont.list());
  
  //savePrefs();
  loadPrefs();
 
  frameRate(60);

  //-- init headsets
  headsets = new MuseHeadset[numDevices];
  for( int i = 0; i < numDevices; i++ ) {
    int portNum = prefs.portNum + i;    // numbering starts at 5001 for 'muse1', etc
    headsets[i] = new  MuseHeadset(portNum, getHeadsetName(i));
    headsets[i].setPctWaves(prefs.pctAlpha, prefs.pctBeta, prefs.pctDelta, prefs.pctGamma, prefs.pctTheta );
    headsets[i].setTasteTopFilter(prefs.tasteIndexTopFilter);
    headsets[i].setTasteBottomFilter(prefs.tasteIndexBottomFilter);
  }
  
  debugDisplay = new DebugDisplay(prefs,numDevices,headsets);
  dinnerDisplay = new DinnerDisplay(prefs,numDevices,headsets);
  dinnerDisplay.toggleHelperImage();
}

public String getHeadsetName(int headsetNum) {
    if( headsetNum == 0 )
      return "Pig";
    else if( headsetNum == 1 )
     return "Martini";
    else if( headsetNum == 2 )
     return "Fire";
   else if( headsetNum == 3 )
     return "Beaker";
    else
      return "ERROR - getHeadsetName()";
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
  
  if( key == 'r' || key == 'R' )
    reloadPrefs();
    
  if( key == ' ' ) {
     if( bDebugDisplay == false ) {
        for( int i = 0; i < numDevices; i++ ) {
          if( headsets[i].isTouchingForehead() == true ) {
               dinnerDisplay.startPlot();
               break;
          }
        }
     }
  }
}

public void reloadPrefs() {
  int oldPortNum = prefs.portNum;
  
  loadPrefs();
  
  //-- we don't actually do anything here, maybe for the future
  /*println( "OLD PORT = " + str(oldPortNum));
  println( "NEW PORT = " + str(prefs.portNum));*/
  

  //-- reload percentage weighting values from prefs
  debugDisplay.setPrefs(prefs);
  for( int i = 0; i < numDevices; i++ ) {
    headsets[i].setPctWaves(prefs.pctAlpha, prefs.pctBeta, prefs.pctDelta, prefs.pctGamma, prefs.pctTheta );
    headsets[i].setTasteTopFilter(prefs.tasteIndexTopFilter);
    headsets[i].setTasteBottomFilter(prefs.tasteIndexBottomFilter);
  }
}

public void saveDefaultPrefs() {
  Gson gson = new GsonBuilder().serializeNulls().create();
   
  RecordPrefs prefs = new RecordPrefs();
  prefs.portNum = 5001;
  prefs.pctAlpha = .07f;
  prefs.pctBeta = .38f;
  prefs.pctDelta = .40f;
  prefs.pctGamma = .05f;
  prefs.pctTheta = .10f;
        
  PrintWriter writer = createWriter("preferences.json");
  writer.println(gson.toJson(prefs));
  writer.flush();
  writer.close();
}

public void loadPrefs() {
  println("LOAD PREFS");
  try {
    Gson gson = new GsonBuilder().serializeNulls().create(); 
    String [] fileStrings = loadStrings("preferences.json"); 
    if( fileStrings == null ) {
      println("NULL pointer in loadPrefs(), save from default");
      loadDefaultPrefs();
    }
    else {
      println( "SUCCESSFUL LOAD");
      println(fileStrings[0]);
      prefs = gson.fromJson(fileStrings[0], RecordPrefs.class);
      
      println("port num = " + str(prefs.portNum));
     println( "pct alpha = " + str(prefs.pctAlpha));
     println( "pct beta = " + str(prefs.pctBeta));
     println( "pct delta = " + str(prefs.pctDelta));
     println( "pct gamma = " + str(prefs.pctGamma));
      println( "pct theta = " + str(prefs.pctTheta));
 
 
    }
  }
  catch( Exception e ) {
     println("EXCEPTION in loadPrefs(), save from default");
     loadDefaultPrefs();
  }
}

//-- use to prevent recursion
public RecordPrefs loadDefaultPrefs() {
  Gson gson = new GsonBuilder().serializeNulls().create(); 
  saveDefaultPrefs(); 
   String [] fileStrings = loadStrings("preferences.json"); 
   return( gson.fromJson(fileStrings[0], RecordPrefs.class) );
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

/*******************************************************************************************************************
//
//  Class: DataSample
//
//  Written by Scott Kildall
//
//  Simple storage mechanism
//------------------------------------------------------------------------------------------------------------------
//
*********************************************************************************************************************/

public class DataSample {
  long ms;      // from starting point
  float alpha;
  float beta;
  float delta;
  float gamma;
  float theta;
}

/**
 * debugDisplay
 */
 


class DebugDisplay {
  MuseHeadset [] headsets;
  DebugHeadsetDisplay[] displays;
  int numDevices;
  RecordPrefs prefs;
  //-- color is a name, like "yellow", "red", "green", blue"
  
  DebugDisplay(RecordPrefs _prefs, int _numDevices, MuseHeadset [] _headsets) {
    prefs = _prefs;
    numDevices = _numDevices;
    headsets = _headsets;
    
    displays = new DebugHeadsetDisplay[numDevices];
    displays[0] = new DebugHeadsetDisplay( 50, 150, 132, 18, 37);
    displays[1] = new DebugHeadsetDisplay( 1000, 150, 89, 81, 148);
    displays[2] = new DebugHeadsetDisplay( 50, 550, 255, 152, 33);
    displays[3] = new DebugHeadsetDisplay( 1000, 550, 70, 173, 0);
  }
  
  public void setPrefs( RecordPrefs _prefs ) {
    prefs = _prefs;  
  }
  
  //-- draw 
  public void draw() {
    background(0);    
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
  
  
    for( int i = 0; i < numDevices; i++ )
      displays[i].draw(headsets[i]); 
      
    // Debug info at top of screen
    textAlign(LEFT);
    textSize(14);
    fill(255,255,255);
    
    float waveXOffset = 120;
    
    text( "Port Num: " + str(prefs.portNum), 100, 40 );
    text( "Save Data: " + prefs.saveData, 100+waveXOffset, 40 );
    float waveY = 80;
    float waveX = 100;
    
     //text( "Alpha Pct: " + str(prefs.pctAlpha * 100) + "%", waveX, waveY );
     text( "Alpha Pct: " + String.format("%.0f",prefs.pctAlpha * 100) + "%", waveX, waveY );
     waveX = waveX + waveXOffset;
     text( "Beta Pct: " + String.format("%.0f",prefs.pctBeta * 100) + "%", waveX, waveY );
      waveX = waveX + waveXOffset;
     text( "Delta Pct: " + String.format("%.0f",prefs.pctDelta * 100) + "%", waveX, waveY );
      waveX = waveX + waveXOffset;
     text( "Gamma Pct: " +  String.format("%.0f",prefs.pctGamma * 100) + "%", waveX, waveY );
      waveX = waveX + waveXOffset;
     text( "Theta Pct: " + String.format("%.0f",prefs.pctTheta * 100) + "%", waveX, waveY );
      waveX = waveX + waveXOffset;
      float totalPct = prefs.pctAlpha + prefs.pctBeta + prefs.pctDelta + prefs.pctGamma + prefs.pctTheta;
     text( "Total Pct: " + String.format("%.0f",totalPct * 100) + "%", waveX, waveY );
     
     waveX = 100;
     text( "Taste Index Top Filter: " + String.format("%.2f",prefs.tasteIndexTopFilter), waveX, waveY+40 );
     text( "Taste Index Bottom Filter: " + String.format("%.2f",prefs.tasteIndexBottomFilter), waveX + (2*waveXOffset), waveY+40 );
    
     
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
static int uiHeight = 350;
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
  DebugHeadsetDisplay(int x, int y, int _r, int _g, int _b ) {
    drawX = x;
    drawY = y;
    r = _r;
    g = _g;
    b = _b;
    
    waveData = new float[4];
  }
  
  //-- draw 
  public void draw(MuseHeadset headset) {
    drawFrame();
    
    noStroke();
    
    drawDeviceStats(headset);
    drawHorseshoe(headset);
    
    
    drawWaveBalls(prepareDrawAlpha(headset));
    drawWaveBalls(prepareDrawBeta(headset));
    drawWaveBalls(prepareDrawDelta(headset));
    drawWaveBalls(prepareDrawGamma(headset));
    drawWaveBalls(prepareDrawTheta(headset));  
  }
  
  private void drawFrame() {
    noFill();
    stroke(r,g,b);
    strokeWeight(2);
    rect(drawX, drawY, uiWidth, uiHeight);
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
     float dy = -50 + drawY  + uiBallHeight;    // we will subtact from this:  -(float(uiBallHeight)*thetaRelative[i].mellow);
     
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
       text( headset.horseshoeStrings[i], drawX + 30 + (i * 50), drawY + 60); 
  }
 
 
  public void drawDeviceStats(MuseHeadset headset) {
     fill(255, 255, 255);
     noStroke();
     textSize(14);
     
     long packetConnectionTime = 5000;  // how much time before we deem a device is disconnected
     
     String connectedStr = "Connected: ";
     if( headset.lastPacketMS + packetConnectionTime > millis() ) {
      connectedStr = connectedStr + "YES";
    }
     else {
       connectedStr = connectedStr + "NO";
    }
       
     String touchingStr = "Touching Forehead: ";
     if( headset.isTouchingForehead() )
       touchingStr = touchingStr + "YES";
     else
       touchingStr = touchingStr + "NO";
     
     text( connectedStr, drawX + 100 , drawY + 30); 
     text( touchingStr, drawX + 250, drawY + 30); 
  }
}
/**
 * dinnerDisplay.pde
 */
 


class DinnerDisplay {
  RecordPrefs prefs;
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
  DinnerDisplay(RecordPrefs _prefs,int _numDevices, MuseHeadset [] _headsets) {
    prefs = _prefs;
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
    
    Boolean bSaveData = false;
    if( prefs.saveData != null && prefs.saveData.equals("true") ) 
      bSaveData = true;
    
    if( prefs.savePath == null )
      prefs.savePath = "";
      
    plotter = new Plotter(headsets, 162, 234, bSaveData, prefs.savePath );
    float numPixels = 1584;  // UI value
    numPixels = 1500;  // better test value
    plotter.initialize( numPixels, 344, numMinutes, 10, 5);
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
      text("BoBBQ Variance Meter", width/2,750);
  }
  
  public void drawGraySwatch() {
      shape(graySwatch,0,0);
  }
  
  //-- we can also use this as a toggle button
  public void startPlot() {
      if( plotter.isPlotting() )
        plotter.finish();
      else { 
        for( int i = 0; i < numDevices; i++ ) 
          headsets[i].resetData();
        plotter.clear();
        plotter.start();
      }
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
    checkConnection();
  }
  
  
  public void drawTasteIndex() {
    imageMode(CENTER);
    image(tasteBackgroundImage, tasteX, tasteY);
    image(iconImage, tasteX, tasteY + 130 );
    
    if(headset.isTouchingForehead()) {
      // rotation code for the dial indicator
      pushMatrix();
      translate( tasteX,tasteY+80);
      rotate(radians(degreesMultiplier*headset.getTasteIndex()));
      image(tasteDialImage,0,0);
      popMatrix();
    }
    
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
    float yUpperOffset = -70;
    
    text(  "Low", tasteX - xLowerOffset, tasteY + yLowerOffset );
     text(  "Medium", tasteX - xUpperOffset, tasteY + yUpperOffset );
      text(  "High", tasteX + xUpperOffset,tasteY + yUpperOffset );
      text(  "Very High", tasteX + xLowerOffset, tasteY + yLowerOffset );
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
  
  private void checkConnection() {
     long packetConnectionTime = 3000;  // how much time before we deem a device is disconnected
     
     String connectedStr = "Connected: ";
     if( headset.lastPacketMS + packetConnectionTime > millis() ) {
      headset.setConnected(true);
    }
     else {
        headset.setConnected(false);
    } 
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
 
 
// globals for percentages
float pctAlpha = .05f;  // spiky
float pctBeta = .40f;    // looks good
float pctDelta = .40f;    // also good
float pctGamma = .05f; // spiky
float pctTheta = .10f;  // ok

class MuseHeadset {
  int port;
  OscP5 osc;
  
  int touchingForehead = 0;
  
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
  
  ///float plotValue;
  boolean bRandomMode;    // XXX: we will remove this later
  ///boolean bRandomTasteIndex;
  
  float tasteIndex;
  float combinedQValue;
  long lastPacketMS = 0;
  long numQValues;    // how many times we've done a combined QValue plot
  String headsetName;  // used for data output
  Boolean connected = true;
  
  float topFilter;
  float bottomFilter;
  
  MuseHeadset(int thePort, String _headsetName) {
    port = thePort;
    osc = new OscP5(this,port);
    headsetName = new String(_headsetName);
    
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
    
    bRandomMode = false; 
    /// bRandomTasteIndex = false;
    numQValues = 0;
    resetData();
    lastPacketMS = millis();
    
    topFilter = 3.0f;
    bottomFilter = 1.25f;
  }
  
  public void setTasteTopFilter(float _topFilter) {
    topFilter = _topFilter;
  }
  
  public void setTasteBottomFilter(float _bottomFilter) {
    bottomFilter = _bottomFilter;
  }
  
  public String getHeadsetName() {
    return headsetName;
  }
  
  public void setConnected(Boolean _connected) {
    connected = _connected;
    String s = "TRUE";
    if(connected == false)
      s = "FALSE";
  }
  
  public void setPctWaves(float _pctAlpha, float _pctBeta, float _pctDelta, float _pctGamma, float _pctTheta) {
      pctAlpha = _pctAlpha;
      pctBeta = _pctBeta;
      pctDelta = _pctDelta;
      pctGamma = _pctGamma;
      pctTheta = _pctTheta;
  }
  
  //-- called by draw() loop, will update internal data arrays
  public Boolean isTouchingForehead() {
      return (touchingForehead == 1);
  }
  
  public float getTasteIndex() {
    return tasteIndex; 
  }
  
  public void resetData() {
     tasteIndex = 50;
     
     /*
     if( bRandomMode )
       plotValue = random(0,100);
     else
       plotValue = 50; 
       */
     combinedQValue = 50;
  }
  
  public float getPlotValue() {
    numQValues = numQValues + 1;
    
    if( connected == false && touchingForehead == 1 ) {
       bRandomMode = true;
    }
      
    if( bRandomMode )
       return randomizePlotValue();
     else {
       //println( "CombinedQ Value = " + str(combinedQValue));
       
       float newQValue = (qAlpha * pctAlpha) + (qBeta * pctBeta) + (qDelta * pctDelta) + (qGamma * pctGamma) + (qTheta * pctTheta);
       
       if( newQValue <  combinedQValue+1 &&  newQValue >  combinedQValue-1 )
         combinedQValue = noiseFilter(newQValue);
      
       // println( "OLD TASTE INDEX: " + str(tasteIndex) );
          tasteIndex += addVolatility(newQValue,combinedQValue);
          tasteIndex = checkMaxMin(tasteIndex,3.0f);
         //  println( "NEW TASTE INDEX: " + str(tasteIndex) );
           
            combinedQValue = checkMaxMin(newQValue,3.0f);
       
       //println( "return QValue = " + str(combinedQValue) );
       return combinedQValue;
     } 
  }
  
  //-- still working out this formula...this gives us a range of -1 to 1
  //-- instance vars we are looking at:
  //-- numQValues: how many samples, will be 1-1500
  //--
   public float addVolatility(float oldQ, float newQ ) {
     if( numQValues < 3 )
       return 0;
      
      float diff = abs(oldQ-newQ);
        
      if( diff > topFilter )
        diff = topFilter;
      
      float multiplier = 2.0f;
       if( numQValues > 1200 )
        multiplier = 4.0f;
      if( numQValues > 750 )
        multiplier = 3.0f;
        
      return (diff-bottomFilter) * multiplier;
   }
   
  public float getAlpha() {
    return qAlpha;
  }
  public float getBeta() {
    return qBeta;
  }
  public float getDelta() {
    return qDelta;
  }
  public float getGamma() {
    return qGamma;
  }
  public float getTheta() {
    return qTheta;
  }
   
   // makes sure we don't go over 100 or less than 0, does some randomization goodies
   public float checkMaxMin(float qValue, float bumpRange) {
      if( qValue > 100 )
         qValue = 100 - random(.5f,bumpRange+.5f);  
      else if( qValue < 0 )
        qValue = 0 + random(.5f,bumpRange+.5f);
        
      return qValue;
   }
   
   public float noiseFilter(float qValue) {
     float filterRange = 2.0f;
     float retValue = qValue + random(-filterRange,filterRange);
     if( retValue < 0 )
        retValue = 0 + random(.5f,filterRange+.5f);
     else if( retValue > 100 )
        retValue = 100 - random(.5f,filterRange+.5f);  
        
      return retValue;
   }
   
   private float randomizePlotValue() {
     println( "RANDOM MODE -- randomizePlotValue()");
     /// if( bRandomMode && touchingForehead == 1) {
        float randRange = 3.0f;
        float oldQValue = combinedQValue;
        combinedQValue = combinedQValue + random(-randRange,randRange);
        if( combinedQValue < 0 )
          combinedQValue = combinedQValue + random(-combinedQValue,randRange+.5f);
        else if( combinedQValue > 100 )
          combinedQValue = combinedQValue - random((combinedQValue-100),randRange+.5f);
         /* 
        tasteIndex = tasteIndex + random(-1,1);
        if( tasteIndex < 0 )
          tasteIndex = 0;
        else if( tasteIndex > 100 )
          tasteIndex = 100;
          */
          
          // println( "OLD TASTE INDEX: " + str(tasteIndex) );
          tasteIndex += addVolatility(oldQValue,combinedQValue);
          tasteIndex = checkMaxMin(tasteIndex,3.0f);
           //println( "NEW TASTE INDEX: " + str(tasteIndex) );
           
          return combinedQValue;
      }
   ///}
             
  public void zeroQWaveValues() {
      //-- set to reasonable defaults for these
      qAlpha = 50.0f;
      qBeta = 50.0f;
      qDelta = 50.0f;
      qGamma = 50.0f;
      qTheta = 50.0f;
  }
  
  //-- based on horseshoe settings, will generate average qQave values
    // scale is -1.0 to 0?

  public float generateQWaveValue(float [] waveValues, float previousQValue) {
    float qValue = -10000;    // impossibly low number, set as flag
    float divisor = 0;
    
    float goodDivisor = 7;
    float okDivisor = 3;
    float badDivisor = 1;
       
    
    for( int i = 0; i < 4; i++ ) {
      
       if( horseshoeValues[i] == 1.0f ) {
         qValue = map(waveValues[i],-1.0f,0.0f,0,100) * goodDivisor;    // 9x factor for a good connection
         divisor = divisor + goodDivisor;
       }
       else if( horseshoeValues[i] == 2.0f ) {
         qValue = map(waveValues[i],-1.0f,0.0f,0,100) * okDivisor;    // 3x factor for a ok connection
         divisor = divisor + okDivisor;
       }
       else if( horseshoeValues[i] == 3.0f ) {
         qValue =map(waveValues[i],-1.0f,0.0f,0,100) * badDivisor;    // 1x factor for a bad connection
         divisor = divisor + badDivisor;
       }
    }
    
    if( qValue == -10000 ) {
       float qRandRange = 1.0f;
       qValue = previousQValue + random(-qRandRange,qRandRange);
       if( qValue > 100 )
         qValue =  previousQValue - random(qRandRange/2, qRandRange*2);
       else if( qValue < 0 )
         qValue =  previousQValue + random(qRandRange/2, qRandRange*2);
    }
    else {
      qValue = qValue/divisor;
      //println( "ACTUAL Q Value = " + str(qValue));
     // println( "Divisor = " + str(divisor) );
    }
    
    // FAIL SAFE
    if( qValue > 100 )
      qValue = 0;
    else if( qValue < 0 )
      qValue = 0;
     
   return qValue;
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
      
      //println( "ALPHA: " );
      qAlpha = generateQWaveValue(alpha,qAlpha);  
    }
    
    // BETA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/beta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        beta[i] = theOscMessage.get(i).floatValue();
      }
      
      //println( "BETA" );
      qBeta = generateQWaveValue(beta,qBeta); 
    }
   
   // DELTA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/delta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        delta[i] = theOscMessage.get(i).floatValue();
      }
      //println( "DETLA :" );
       qDelta = generateQWaveValue(delta,qDelta);
       
    }
    
    // GAMMA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/gamma_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        gamma[i] = theOscMessage.get(i).floatValue();
      }
      
      //println( "GAMMA: " );
      qGamma = generateQWaveValue(gamma,qGamma); 
    }
    
    // THETA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/theta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        theta[i] = theOscMessage.get(i).floatValue();
      }
      
      //println( "THETA: " );
      qTheta = generateQWaveValue(theta,qTheta); 
    }
    
    // HORSESHOE
    if( addrPattern.equals("/muse/elements/horseshoe") ) {
      for( int i = 0; i < 4; i++ ) {
        horseshoeValues[i] = theOscMessage.get(i).floatValue();
      }
      generateHorseShoeStrings();
    }
    
    // TOUCHING FOREHEAD
    if(  addrPattern.equals("/muse/elements/touching_forehead") ) {
      //println("touching forehead typetag: "+ theOscMessage.typetag());
      touchingForehead = theOscMessage.get(0).intValue();
      //println( "TOUCHING FOREHEAD = " + str(touchingForehead) );
      
    } 
    
    lastPacketMS = millis();
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
  
  Boolean bSaveData;
  long saveDataTimerDuration;
  int numSavedDataSamples;
  int saveDataBufferSize;
  
  Boolean bRunning = false;
  int numPlottedPixels;   // how many pixels we have plotted on the screen, we use this for drawing
  Timer plotTimer;    // this should be the duration of the dinner party
  Timer pixelTimer;    // this will get called for every pixel that we plot
  Timer saveDataTimer;    // for JSON data output
  Timer allDoneTimer;  // for displaying an "ALL DONE" message
  Boolean bDisplayAllDone;
  
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
  PFont allDoneFont;
  
  //-- alloc this
  float [][] plotData;
  Boolean [][] touchingForehead;
  
  
  float lastMillis;
 
   // saving data
   DataSample [][] dataSamples;
   Boolean [] headsetsOn;
   DataSample [][] outputDataSamples;
   
   RecordSavedSession savedSession;
   String savePath;
   
  //-- constructor, mostly empty
  Plotter(MuseHeadset [] _headsets, float _drawX, float _drawY, Boolean _bSaveData, String _savePath) {
      headsets = _headsets;
      numHeadsets = headsets.length;
      drawX = _drawX;
      drawY = _drawY;
      bSaveData = _bSaveData;
      savePath = new String(_savePath);
      
      saveDataTimerDuration = (2*1000); // 2 seconds
      
      ///XXX: remove
      /*
      if( bSaveData == true )
        println( "SAVING DATA");
     else
       println("NO SAVE DATA");
       */
       
      numPlottedPixels = 0;
      plotTimer = null;
      
       allDoneTimer = new Timer(5000);  // for displaying an "ALL DONE" message
       bDisplayAllDone = false;
  
      //-- fonts for drawing
      axesTextFont = createFont("Arial", 28.3f );  
      axesNumbersFont = createFont("Arial", 14 );  //-- XXX: this needs to be updated
      allDoneFont = createFont("Arial", 32 );
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
    touchingForehead = new Boolean[numHeadsets][numPixels];
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
    
    saveDataTimer = new Timer(saveDataTimerDuration);
    
    numSavedDataSamples = 0;
     println( "pixeltimerduration = " + str(pixelTimerDuration) );
      println( "saveDataTimerDuration = " + str(saveDataTimerDuration) );
    saveDataBufferSize = PApplet.parseInt(duration/saveDataTimerDuration);
    println( "savedatabuffersize = " + str(saveDataBufferSize) );
    if( bSaveData )
      allocateSaveDataBuffers(saveDataBufferSize);
  
  }
  
  public Boolean isPlotting() {
    return bRunning;
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
    if( bSaveData ) {
      //-- check headsets on for each on
      for(int i = 0; i < numHeadsets; i++ )
        headsetsOn[i] = headsets[i].isTouchingForehead();  
      saveDataTimer.start();
    }
    
    bDisplayAllDone = false;
    bRunning = true;
  }  
  
  public void finish() {
      bRunning = false;
      if( bSaveData ) {
        copySaveDataBuffers();
        //printSavedData(); 
        
        writeSavedData();
        println( "DONE WRITING DATA");
      }     
      
      bDisplayAllDone = true;
      allDoneTimer.start(); 
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
    updateAllDone();
  }
  
  private void drawLabels() { 
    textFont(axesTextFont);
    textAlign(CENTER);
    
    text( "Time (minutes ago)", width/2 -20, 660 );
     
    pushMatrix();
    translate( width/2 -900, height/2 - 140);
    rotate(radians(270));
    text( "Brain Wave Composite", 0,0);
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
    //-- point plots
    /*
     for( int i = 0; i < numPlottedPixels; i++ ) {
       point( drawX + i, drawY + h - plotData[headsetNum][i]);
     }
     */
     float lastX = 0;
     float lastY = 0;
     
      for( int i = 0; i < numPlottedPixels; i = i + 1 ) {
        float x = drawX + i;
          float y = drawY + h - plotData[headsetNum][i];
          
        if( i > 0 ) {
          if( touchingForehead[headsetNum][i] )
            line( lastX, lastY, x, y );
          
          
        }
        lastX = x;
        lastY = y;
     } 
  }
  
  private void updateAllDone() {
    if( bRunning == false && bDisplayAllDone == true ) {
      textAlign(CENTER);
      textFont(allDoneFont);
      fill( 132, 18, 37);
      text( "All Done!", width/2,170 );
      if( allDoneTimer.expired() )
        bDisplayAllDone = false; 
    }
  }
  
   private void updatePlot() {
     if( bRunning ) {
       if( pixelTimer.expired()) {
         pixelTimer.start();
         
         for( int i = 0; i < numHeadsets; i++ ) {
             plotData[i][numPlottedPixels] = headsets[i].getPlotValue() * vPlotMultiplier;
             touchingForehead[i][numPlottedPixels] = headsets[i].isTouchingForehead();
             ///headsets[i].nextPlotValue(); 
          }
          
         // prevent overflow, in case plot pixels exceeds buffer
          if( numPlottedPixels < numPixels-1 )
            numPlottedPixels = numPlottedPixels + 1; 
       }
       if( plotTimer.expired()) {
           println("DONE: Plot time expired");
           println("pixeltimer, num Plotted pixels: " + str(numPlottedPixels) );
           
           println( "end millis() = " + millis() );
           finish();
           
       }
       
       if( bSaveData && saveDataTimer.expired() ) {
          if( bSaveData && saveDataTimer.expired() ) {
             saveDataSample(numSavedDataSamples);
             if( numSavedDataSamples < saveDataBufferSize ) {
               numSavedDataSamples = numSavedDataSamples + 1;
               saveDataTimer.start();
             }
          }
       }
      }
   }


public void allocateSaveDataBuffers(int dataBufferSize) {
  println("ALLOCATING DATA BUFFERS, size = " + str(dataBufferSize));
     dataSamples = new DataSample[numHeadsets][dataBufferSize];
     for( int i = 0; i < numHeadsets; i++ ) {
        for( int j = 0; j < dataBufferSize; j++ )
           dataSamples[i][j] = new DataSample();
     }
     headsetsOn = new Boolean[numHeadsets];
}

//-- makes a duplciate of save data buffers, which we use for output
//-- relay on the instance var: numSavedDataSamples
public void copySaveDataBuffers() {
  int numActiveHeadsets = 0;
  for( int i = 0; i < numHeadsets; i++ ) {
     if( headsetsOn[i] )
       numActiveHeadsets = numActiveHeadsets + 1;
  }
  println( "NUM ACTIVE HEADSETS: " + str(numActiveHeadsets) );
  
  savedSession = new RecordSavedSession();
  savedSession.timestamp = getUnixTimestamp();
  savedSession.savedData = new RecordSavedData[numActiveHeadsets];
  
  int headsetIndex = 0;  // for active headset count
  for( int i = 0; i < numHeadsets; i++ ) {
     if( headsetsOn[i] == false )
       continue;
       
     savedSession.savedData[headsetIndex] = new RecordSavedData();
     savedSession.savedData[headsetIndex].headsetName = headsets[i].getHeadsetName();
     savedSession.savedData[headsetIndex].data = new DataSample[numSavedDataSamples];
      for( int j = 0; j < numSavedDataSamples; j++ ) {
        
           savedSession.savedData[headsetIndex].data[j] = new DataSample();
           //REMOVE
           /*
           println( "MS COPY = " + str(dataSamples[i][j].ms) );
           println( "MS SAVED = " + str(savedSession.savedData[i].data[j].ms) );
           */
           savedSession.savedData[headsetIndex].data[j].ms = dataSamples[i][j].ms;
           savedSession.savedData[headsetIndex].data[j].alpha = dataSamples[i][j].alpha;
           savedSession.savedData[headsetIndex].data[j].beta = dataSamples[i][j].beta;
           savedSession.savedData[headsetIndex].data[j].delta = dataSamples[i][j].delta;
           savedSession.savedData[headsetIndex].data[j].gamma = dataSamples[i][j].gamma;
           savedSession.savedData[headsetIndex].data[j].theta = dataSamples[i][j].theta;
      }
      
      headsetIndex = headsetIndex + 1;
  }
}

private void saveDataSample(int index) { 
  if( index > (saveDataBufferSize-1) ) {
    println( "Overflow, not saving data samples" );
    println( "Index = " + str(index) );
    println( "numSavedDataSamples = " + str(numSavedDataSamples) ); 
   return;
  }
    
  for( int i = 0; i < numHeadsets; i++ ) { 
    if( headsetsOn[i] ) {
       dataSamples[i][index].ms = (index+1) * saveDataTimerDuration;
       dataSamples[i][index].alpha = headsets[i].getAlpha();
       dataSamples[i][index].beta = headsets[i].getBeta();
       dataSamples[i][index].delta = headsets[i].getDelta();
       dataSamples[i][index].gamma = headsets[i].getGamma();
       dataSamples[i][index].theta = headsets[i].getTheta();
    }
  }
}

private void printSavedData() {
  for( int i = 0; i < numHeadsets; i++ ) {
  
    
    if( headsetsOn[i] ) {
      println( "--------------------------------" );
      println( "HEADSET: " + headsets[i].getHeadsetName() + ":" ); 
      for( int j = 0; j < numSavedDataSamples; j++ ) {
        
       println( "time: " + str(dataSamples[i][j].ms) );
       println( "alpha: " + str(dataSamples[i][j].alpha) );
       println( "beta: " + str(dataSamples[i][j].beta) );
       println( "delta: " + str(dataSamples[i][j].delta) );
       println( "gamma: " + str(dataSamples[i][j].gamma) );
       println( "theta: " + str(dataSamples[i][j].theta) );
       println( "--" );
      }
      println( "--------------------------------" );
    }
    else {
      println( "--------------------------------" );
       println( "Headest: " + headsets[i].getHeadsetName() + " Not connected " ); 
       println( "--------------------------------" );
    }
  }
} 

//-- note: savePath = "" if local
  
private void writeSavedData() {
  Gson gson = new GsonBuilder().serializeNulls().create();
  
  //String path = "/Users/edp_2/Dropbox/EEGDinnerParty/";
  //String path = "outputs/";
  
  String ts = String.format("%d",getUnixTimestamp());
  PrintWriter writer = createWriter(savePath + "data_" +  ts + ".json");
  writer.println(gson.toJson(savedSession));
  writer.flush();
  writer.close();
} 

private long getUnixTimestamp() {
    Date d = new Date();
  return d.getTime()/1000; 
}
}
  

  
 
/*******************************************************************************************************************
//
//  Class: RecordPregs
//
//  Written by Scott Kildall
//
//------------------------------------------------------------------------------------------------------------------
// - Very simple but incredibly useful timer class
// - Call start() whenever it expires to reset the time
// - Call expired() to check to see if timer is still active
//
*********************************************************************************************************************/

public class RecordPrefs {
  int portNum;      // starting port num
  float pctAlpha;
  float pctBeta;
  float pctDelta;
  float pctGamma;
  float pctTheta;
  String saveData;
  String savePath;  // if none or empty, save to local
  float tasteIndexTopFilter;
  float tasteIndexBottomFilter;
}

/*******************************************************************************************************************
//
//  Class: RecordSavedSession
//
//  Written by Scott Kildall
//
//
*********************************************************************************************************************/

public class RecordSavedData {
  String headsetName;
  DataSample [] data;
}

/*******************************************************************************************************************
//
//  Class: RecordSavedSession
//
//  Written by Scott Kildall
//
//
*********************************************************************************************************************/

public class RecordSavedSession {
  long timestamp;
  RecordSavedData [] savedData;
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
