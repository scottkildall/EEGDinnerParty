/**
 * debugDisplay
 */
 


class DebugDisplay {
  DebugHeadsetDisplay[] displays;
  int numDevices;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  DebugDisplay(int _numDevices) {
    numDevices = _numDevices;
    
    displays = new DebugHeadsetDisplay[numDevices];
    displays[0] = new DebugHeadsetDisplay( 50, 50, "red");
    displays[1] = new DebugHeadsetDisplay( 1000, 50, "green");
    displays[2] = new DebugHeadsetDisplay( 50, 550, "blue");
    displays[3] = new DebugHeadsetDisplay( 1000, 550, "yellow");
  }
  
  //-- draw 
  public void draw(MuseHeadset [] headsets) {
    background(0);    
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
  
  
    for( int i = 0; i < numDevices; i++ )
      displays[i].draw(headsets[i]); 
  }
}
  
  
 
