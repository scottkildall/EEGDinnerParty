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
int numDevices = 2;

Boolean drawForeheadConnection = true;    // headset
Boolean drawGoodConnection = true;        // 4 nodes
Boolean drawBattery = false;

public void setup() {
  size(1280,720);
  frameRate(60);

  headsets = new MuseHeadset[numDevices];
  for( int i = 0; i < numDevices; i++ ) {
    int portNum = 5000 + i + 1;    // numbering starts at 5001 for 'muse1', etc
    headsets[i] = new  MuseHeadset(portNum);
  }
}

public void draw() {
  background(0);    
  ellipseMode(CENTER);  // Set ellipseMode to CENTER
  
  for( int i = 0; i < numDevices; i++ )
    drawDeviceStats(i);
}

public void stop() {
    for( int i = 0; i < numDevices; i++ ) {
    headsets[i] = null;
  }
}

public void keyPressed() {
  // B = battery display, toggle
  if (key == 'b' || key == 'B')
      drawBattery = !drawBattery;
      
   // C = connection display, toggle
  if (key == 'c' || key == 'C') {
       drawGoodConnection = !drawGoodConnection;
       drawForeheadConnection = !drawForeheadConnection;
  }
}

// Main draw function for each device
public void drawDeviceStats(int index) { 
  int drawX = 100 + (index*200); 
  int drawY = 50;  
  
  if( drawForeheadConnection )
    drawForeheadConnection(index, drawX, drawY);
  if( drawGoodConnection)
    drawGoodConnection(index, drawX, drawY);
    
  drawStress(index, drawX, drawY);
  drawMellow(index, drawX, drawY);
  
  if (drawBattery)
    drawBatteryLife(index, drawX, drawY);
}

// Single indication as to whether or not the forehead is 'connected'
public void drawForeheadConnection(int index, float drawX, float drawY) {
  int diameter = 10;
  
  if( headsets[index].touchingForehead == 0 )
    fill(255,0,0);
  else {
    fill(0,255,0);
  }
  ellipse( drawX + diameter, diameter, diameter, diameter);  // Draw gray ellipse using CENTER mode
}

// 4 connections for touching various points on forehead
public void drawGoodConnection(int index, float drawX, float drawY) {
  int diameter = 10;
  
  for( int i = 0; i <4; i++ ) {
    if( headsets[index].good[i] == 0 )
      fill(255,0,0);
    else 
      fill(0,255,0);
      
      ellipse(drawX+diameter + diameter * (i*2), diameter*3, diameter, diameter);  // Draw gray ellipse using CENTER mode
  }  
}


// Draws mellow life as relative position, index = inde into array of headset
public void drawStress(int index, float drawX, float drawY) {
   int  diameter = 25;
    fill(255,0,0);
    ellipse(drawX + 100, height - (PApplet.parseFloat(height)*headsets[index].concentration), diameter, diameter);  // Draw gray ellipse using CENTER mode
}

// Draws mellow life as relative position, index = inde into array of headset
public void drawMellow(int index, float drawX, float drawY) {
   int  diameter = 25;
   fill(255,255,0);
   ellipse(drawX + 100 + 50, height - (PApplet.parseFloat(height)*headsets[index].mellow), diameter, diameter);  // Draw gray ellipse using CENTER mode
}

// Draws battery life as relative position, index = inde into array of headset
public void drawBatteryLife(int index, float drawX, float drawY) {
   fill(255, 255, 255);
   textSize(32);
   float batteryPct = headsets[index].batteryPct;
   String batteryStr = (batteryPct < 0) ? "---" :  str(headsets[index].batteryPct)+"%";
   text( batteryStr, drawX + 10, drawY + 50); 
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "EEGDinnerParty" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
