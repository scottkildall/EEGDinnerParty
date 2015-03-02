/**
 * debugDisplay
 */
 


class DebugDisplay {
  MuseHeadset [] headsets;
  DebugHeadsetDisplay[] displays;
  int numDevices;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  DebugDisplay(int _numDevices, MuseHeadset [] _headsets) {
    numDevices = _numDevices;
    headsets = _headsets;
    
    displays = new DebugHeadsetDisplay[numDevices];
    displays[0] = new DebugHeadsetDisplay( 50, 50, 132, 18, 37);
    displays[1] = new DebugHeadsetDisplay( 1000, 50, 89, 81, 148);
    displays[2] = new DebugHeadsetDisplay( 50, 550, 255, 152, 33);
    displays[3] = new DebugHeadsetDisplay( 1000, 550, 70, 173, 0);
  }
  
  //-- draw 
  public void draw() {
    background(0);    
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
  
  
    for( int i = 0; i < numDevices; i++ )
      displays[i].draw(headsets[i]); 
  }
}
  
  
 
