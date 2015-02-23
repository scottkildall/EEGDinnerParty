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
  
  float alphaX = 80;
  float betaX = 180;
  float deltaX = 280;
  float gammaX = 380;
  float thetaX = 480;
  
  float [] waveData;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  MuseDisplay(int x, int y, String colorStr ) {
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
  
  float prepareDrawAlpha(MuseHeadset headset) {
    fill(0,200,200);
    stroke(0,200,200);
    strokeWeight(1);
     
    waveData[0] = headset.alpha[0];
    waveData[1] = headset.alpha[1];
    waveData[2] = headset.alpha[2];
    waveData[3] = headset.alpha[3];
    
    return drawX + alphaX;
  }
  
  float prepareDrawBeta(MuseHeadset headset) {
    fill(200,0,0);
    stroke(200,0,0);
    strokeWeight(1);
     
    waveData[0] = headset.beta[0];
    waveData[1] = headset.beta[1];
    waveData[2] = headset.beta[2];
    waveData[3] = headset.beta[3];
    
    return drawX + betaX;
  }
  
  float prepareDrawDelta(MuseHeadset headset) {
    fill(0,200,0);
    stroke(0,200,0);
    strokeWeight(1);
     
    waveData[0] = headset.delta[0];
    waveData[1] = headset.delta[1];
    waveData[2] = headset.delta[2];
    waveData[3] = headset.delta[3];
    
    return drawX + deltaX;
  }
  
  float prepareDrawGamma(MuseHeadset headset) {
    fill(0,0,200);
    stroke(0,0,200);
    strokeWeight(1);
     
    waveData[0] = headset.gamma[0];
    waveData[1] = headset.gamma[1];
    waveData[2] = headset.gamma[2];
    waveData[3] = headset.gamma[3];
    
    return drawX + gammaX;
  }
  
  float prepareDrawTheta(MuseHeadset headset) {
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
  void drawWaveBalls(float startX) {
     int  diameter = 10;
     float dy = 50 + drawY  + uiBallHeight;    // we will subtact from this:  -(float(uiBallHeight)*thetaRelative[i].mellow);
     
     float lastX = 0;
     float lastY = 0;
     
     for( int i = 0; i < 4; i++ ) { 
       float tx = startX + (i * (diameter*2));
       float ty = dy - (float(uiBallHeight/2)*(waveData[i]/2));
       ellipse(tx, ty, diameter, diameter);  // Draw gray ellipse using CENTER mode
       
       if( i > 0 )
         line(lastX,lastY, tx, ty);
        
        lastX = tx;
        lastY = ty;
     }
  }
  /*
   void drawBeta(MuseHeadset headset) {
     int  base = 10;
     float betaY = 50 + drawY  + uiBallHeight;    // we will subtact from this:  -(float(uiBallHeight)*thetaRelative[i].mellow);
     
     noStroke();
     fill(240,0,0);
     
     float lastX = 0;
     float lastY = 0;
     
     stroke(240,0,0);
     strokeWeight(1);
     
     for( int i = 0; i < 4; i++ ) {
       float bx = drawX + betaX + (i * (base*2));
       float by = betaY - (float(uiBallHeight/2)*(headset.betaRelative[i]/2));
       triangle(bx, by+base/2, bx + base/2, by - (base/2 + base), bx + base, by+base/2);  // Draw gray ellipse using CENTER mode
  
       if( i > 0 ) {
        line(lastX,lastY, bx, by);
        }
        lastX = bx;
        lastY = by;
     }
     
      fill(200,200,200);
      textSize(12);
      //text( floatToPct(headset.mellow),mellowX + 20, mellowY+ 5); 
  }
  
 

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
  void drawPacketMS(MuseHeadset headset) {
    int elapsedMS = (millis() - headset.lastPacketTime);
    float elapsedSec = float(elapsedMS)/1000.0;
    
    fill(255, 255, 255);
    noStroke();
    textSize(12);
    text( "elapsed: " + str(elapsedSec) + " secs", drawX + 20, drawY + uiHeight - 30); 
  }
}
