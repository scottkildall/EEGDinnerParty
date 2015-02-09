/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;

MuseHeadset[] headsets;
MuseDisplay[] displays;

int numDevices = 4;

void setup() {
  size(1920,1080);
  frameRate(60);

  //-- init headsets
  headsets = new MuseHeadset[numDevices];
  for( int i = 0; i < numDevices; i++ ) {
    int portNum = 5000 + i + 1;    // numbering starts at 5001 for 'muse1', etc
    headsets[i] = new  MuseHeadset(portNum);
  }
  
  displays = new MuseDisplay[numDevices];
  displays[0] = new MuseDisplay( 50, 50, "red");
  displays[1] = new MuseDisplay( 1000, 50, "green");
  displays[2] = new MuseDisplay( 50, 550, "blue");
  displays[3] = new MuseDisplay( 1000, 550, "yellow");
  
}

void draw() {
  background(0);    
  ellipseMode(CENTER);  // Set ellipseMode to CENTER
  
  for( int i = 0; i < numDevices; i++ )
    displays[i].draw(headsets[i]); 
}

void stop() {
    for( int i = 0; i < numDevices; i++ ) {
    headsets[i] = null;
  }
}

void keyPressed() {
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





