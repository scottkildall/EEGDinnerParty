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
  
  // fill(r,g,b) should be called beforehand
  // startX = alphaX, betaX, etc
  // values[] should be an array of 4 elements, each such as headset.betaRelative, etc
  void drawHorseshoe(MuseHeadset headset) {
     fill(255, 255, 255);
     noStroke();
     textSize(12);
     
     for( int i = 0; i < 4; i++ ) 
       text( headset.horseshoeStrings[i], drawX + 30 + (i * 50), drawY + 60); 
  }
 
 
  void drawDeviceStats(MuseHeadset headset) {
     fill(255, 255, 255);
     noStroke();
     textSize(14);
     
     long packetConnectionTime = 10000;  // how much time before we deem a device is disconnected
     
     String connectedStr = "Connected: ";
     if( headset.lastPacketMS + packetConnectionTime > millis() )
      connectedStr = connectedStr + "YES";
     else
       connectedStr = connectedStr + "NO";
       
     String touchingStr = "Touching Forehead: ";
     if( headset.isTouchingForehead() )
       touchingStr = touchingStr + "YES";
     else
       touchingStr = touchingStr + "NO";
     
     text( connectedStr, drawX + 100 , drawY + 30); 
     text( touchingStr, drawX + 250, drawY + 30); 
  }

  ///REMOVE
  /*
  void drawPacketMS(MuseHeadset headset) {
    int elapsedMS = (millis() - headset.lastPacketTime);
    float elapsedSec = float(elapsedMS)/1000.0;
    
    fill(255, 255, 255);
    noStroke();
    textSize(12);
    text( "elapsed: " + str(elapsedSec) + " secs", drawX + 20, drawY + uiHeight - 30); 
  }
  */
}
