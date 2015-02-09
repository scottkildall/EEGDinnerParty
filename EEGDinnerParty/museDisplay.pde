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
static int uiHeight = 450;
static int uiWidth = 900;

static int uiBallHeight = 300;

class MuseDisplay {
  float drawX = 0;
  float drawY = 0;
  int r = 255;
  int g = 255;
  int b = 255;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  MuseDisplay(int x, int y, String colorStr ) {
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

  // converts long decimal, i.e. .231 to float
  private String floatToPct(float n) {
     int rn = round(n *100);
     return str(rn) + "%";
  }
  // Draws mellow life as relative position, index = inde into array of headset
  private void drawStress(MuseHeadset headset) {
     int  diameter = 25;
     float stressX = drawX + 200;
     float stressY = 50 + drawY  + uiBallHeight -  (float(uiBallHeight)*headset.concentration);
     
     noStroke();
     fill(139,0,0);
    //ellipse(stressX, stressY, diameter, diameter);  // Draw gray ellipse using CENTER mode
    triangle(stressX, stressY+10, stressX + 10, stressY -15, stressX + 20, stressY+10);  // Draw gray ellipse using CENTER mode


     fill(200,200,200);
      textSize(12);
      
      
      text( floatToPct(headset.concentration),stressX + 30, stressY + 5);   
 }

  // Draws mellow life as relative position, index = inde into array of headset
  void drawMellow(MuseHeadset headset) {
     int  diameter = 25;
     float mellowX = drawX + 300;
     float mellowY = 50 + drawY  + uiBallHeight -  (float(uiBallHeight)*headset.mellow);
     
     noStroke();
     fill(15,245,145);
     ellipse(mellowX, mellowY, diameter, diameter);  // Draw gray ellipse using CENTER mode
      
      fill(200,200,200);
      textSize(12);
      text( floatToPct(headset.mellow),mellowX + 20, mellowY+ 5); 
  }

  // Draws battery life as relative position, index = inde into array of headset
  void drawBatteryLife(MuseHeadset headset) {
     fill(255, 255, 255);
     noStroke();
     textSize(18);
     float batteryPct = headset.batteryPct;
     String batteryStr = (batteryPct < 0) ? "---" :  str(headset.batteryPct)+"%";
     text( batteryStr, drawX + uiWidth - 70, drawY + 30); 
  }
}
