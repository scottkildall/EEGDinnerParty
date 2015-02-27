/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;

MuseHeadset[] headsets;
DebugDisplay debugDisplay;
DinnerDisplay dinnerDisplay;

int numDevices = 4;
Boolean bDebugDisplay = false;

void setup() {
  size(1920,1080);
  print(PFont.list());
  
  frameRate(60);

  //-- init headsets
  headsets = new MuseHeadset[numDevices];
  for( int i = 0; i < numDevices; i++ ) {
    int portNum = 5004 + i + 1;    // numbering starts at 5001 for 'muse1', etc
    headsets[i] = new  MuseHeadset(portNum);
  }
  
  debugDisplay = new DebugDisplay(numDevices);
  dinnerDisplay = new DinnerDisplay(numDevices);
}

void draw() {
  if( bDebugDisplay )
    debugDisplay.draw(headsets);
  else
    dinnerDisplay.draw(headsets);
}

void stop() {
    for( int i = 0; i < numDevices; i++ ) {
    headsets[i] = null;
  }
}

void keyPressed() {
   // SPACE = debug mode
  if (key == ' ' || key == ' ') {
       bDebugDisplay = !bDebugDisplay;
  }
  
  if( key == '1' )
      dinnerDisplay.toggleHelperImage();
}





