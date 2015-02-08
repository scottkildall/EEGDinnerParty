/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;

MuseHeadset[] headsets;
UI[] ui;

int numDevices = 4;

void setup() {
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

void draw() {
  background(0);    
  ellipseMode(CENTER);  // Set ellipseMode to CENTER
  
  for( int i = 0; i < numDevices; i++ )
    ui[i].draw(headsets[i]); 
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





