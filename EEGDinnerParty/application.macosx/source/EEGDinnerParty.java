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
UI[] ui;

int numDevices = 4;

public void setup() {
  size(1280,720);
  frameRate(60);

  //-- init headsets
  headsets = new MuseHeadset[numDevices];
  for( int i = 0; i < numDevices; i++ ) {
    int portNum = 5000 + i + 1;    // numbering starts at 5001 for 'muse1', etc
    headsets[i] = new  MuseHeadset(portNum);
  }
  
  ui = new UI[numDevices];
  ui[0] = new UI( 100, 100, "red");
  ui[1] = new UI( 600, 100, "green");
  ui[2] = new UI( 100, 400, "blue");
  ui[3] = new UI( 600, 400, "yellow");
  
}

public void draw() {
  background(0);    
  ellipseMode(CENTER);  // Set ellipseMode to CENTER
  
  for( int i = 0; i < numDevices; i++ )
    ui[i].draw(headsets[i]); 
}

public void stop() {
    for( int i = 0; i < numDevices; i++ ) {
    headsets[i] = null;
  }
}

public void keyPressed() {
   // SPACE = debug mode
  if (key == ' ' || key == ' ') {
       uiDebugMode = !uiDebugMode;
  }
  
  // B = battery display, toggle
  if (key == 'b' || key == 'B')
      uiDrawBattery = !uiDrawBattery;
      //drawBattery = !drawBattery;
      
   // C = connection display, toggle
  if (key == 'c' || key == 'C') 
       uiDrawForeheadConnection = !uiDrawForeheadConnection;
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
  
  float mellow = 0.0f;
  float concentration = 0.0f;
  int touchingForehead = 0;
  float batteryPct = -1.0f;    // NO READING
  int[] good; // num sensors

  MuseHeadset(int thePort) {
    port = thePort;
    osc = new OscP5(this,port);
    good = new int[4];
    float batteryPct;
  }
 
  // incoming osc message are forwarded to the oscEvent method, private to this class
  public void oscEvent(OscMessage theOscMessage) {
    /* print the address pattern and the typetag of the received OscMessage */
    //print("### received an osc message.");
    String addrPattern = theOscMessage.addrPattern();
    //print (addrPattern);
    if (addrPattern.equals("/muse/elements/experimental/concentration") ) {
      concentration = theOscMessage.get(0).floatValue() ;
       //print ("CONCENTRATION: " + str(concentration) + "\n");
    }
    else if( addrPattern.equals("/muse/elements/experimental/mellow") ) {
      mellow = theOscMessage.get(0).floatValue();
      //print ("MELLOW: " + str(mellow) + "\n");
    }
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
       batteryPct = PApplet.parseFloat(theOscMessage.get(0).intValue()) / 100.0f;
        println(batteryPct);
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
 
//-- change these
Boolean uiDrawBattery = false;
Boolean uiDrawForeheadConnection = true;    // headset
Boolean uiDebugMode = false;

//-- don't change these
static int uiHeight = 250;
static int uiWidth = 450;

class UI {
  float drawX = 0;
  float drawY = 0;
  int r = 255;
  int g = 255;
  int b = 255;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  UI(int x, int y, String colorStr ) {
    drawX = x;
    drawY = y;
    setColor(colorStr);
  }
  
  //-- draw 
  public void draw(MuseHeadset headset) {
    drawFrame();
    drawDeviceStats(headset);
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
  
    drawStress(headset);
    drawMellow(headset);
    if (uiDrawBattery)
      drawBatteryLife(headset);
}

  // Single indication as to whether or not the forehead is 'connected'
  private void drawForeheadConnection(MuseHeadset headset) {
    int diameter = 10;
    noStroke();
  
    if( headset.touchingForehead == 0 )
      fill(255,0,0);
    else {
      fill(0,255,0);
    }
    ellipse( drawX + diameter, drawY + diameter, diameter, diameter);  // Draw gray ellipse using CENTER mode
  }

  // 4 connections for touching various points on forehead
  private void drawGoodConnection(MuseHeadset headset) {
    int diameter = 10;
    noStroke();
    
    for( int i = 0; i <4; i++ ) {
      if( headset.good[i] == 0 )
        fill(255,0,0);
      else 
        fill(0,255,0);
      
      ellipse(drawX+diameter + diameter * (i*2), drawY + diameter*3, diameter, diameter);  // Draw gray ellipse using CENTER mode
    }  
  }

  // Draws mellow life as relative position, index = inde into array of headset
  private void drawStress(MuseHeadset headset) {
     int  diameter = 25;
     noStroke();
     fill(255,0,0);
     ellipse(drawX + 100, drawY + uiHeight - (PApplet.parseFloat(uiHeight)*headset.concentration), diameter, diameter);  // Draw gray ellipse using CENTER mode
  }

  // Draws mellow life as relative position, index = inde into array of headset
  public void drawMellow(MuseHeadset headset) {
     int  diameter = 25;
     noStroke();
     fill(255,255,0);
     ellipse(drawX + 100 + 50, drawY  + uiHeight -  (PApplet.parseFloat(uiHeight)*headset.mellow), diameter, diameter);  // Draw gray ellipse using CENTER mode
  }

  // Draws battery life as relative position, index = inde into array of headset
  public void drawBatteryLife(MuseHeadset headset) {
     fill(255, 255, 255);
     noStroke();
     textSize(18);
     float batteryPct = headset.batteryPct;
     String batteryStr = (batteryPct < 0) ? "---" :  str(headset.batteryPct)+"%";
     text( batteryStr, drawX + uiWidth - 70, drawY + 30); 
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
