/**
 * debugDisplay
 */
 


class DebugDisplay {
  MuseHeadset [] headsets;
  DebugHeadsetDisplay[] displays;
  int numDevices;
  RecordPrefs prefs;
  //-- color is a name, like "yellow", "red", "green", blue"
  
  DebugDisplay(RecordPrefs _prefs, int _numDevices, MuseHeadset [] _headsets) {
    prefs = _prefs;
    numDevices = _numDevices;
    headsets = _headsets;
    
    displays = new DebugHeadsetDisplay[numDevices];
    displays[0] = new DebugHeadsetDisplay( 50, 150, 132, 18, 37);
    displays[1] = new DebugHeadsetDisplay( 1000, 150, 89, 81, 148);
    displays[2] = new DebugHeadsetDisplay( 50, 550, 255, 152, 33);
    displays[3] = new DebugHeadsetDisplay( 1000, 550, 70, 173, 0);
  }
  
  public void setPrefs( RecordPrefs _prefs ) {
    prefs = _prefs;  
  }
  
  //-- draw 
  public void draw() {
    background(0);    
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
  
  
    for( int i = 0; i < numDevices; i++ )
      displays[i].draw(headsets[i]); 
      
    // Debug info at top of screen
    textAlign(LEFT);
    textSize(14);
    fill(255,255,255);
    
    float waveXOffset = 120;
    
    text( "Port Num: " + str(prefs.portNum), 100, 40 );
    text( "Save Data: " + prefs.saveData, 100+waveXOffset, 40 );
    float waveY = 80;
    float waveX = 100;
    
     //text( "Alpha Pct: " + str(prefs.pctAlpha * 100) + "%", waveX, waveY );
     text( "Alpha Pct: " + String.format("%.0f",prefs.pctAlpha * 100) + "%", waveX, waveY );
     waveX = waveX + waveXOffset;
     text( "Beta Pct: " + String.format("%.0f",prefs.pctBeta * 100) + "%", waveX, waveY );
      waveX = waveX + waveXOffset;
     text( "Delta Pct: " + String.format("%.0f",prefs.pctDelta * 100) + "%", waveX, waveY );
      waveX = waveX + waveXOffset;
     text( "Gamma Pct: " +  String.format("%.0f",prefs.pctGamma * 100) + "%", waveX, waveY );
      waveX = waveX + waveXOffset;
     text( "Theta Pct: " + String.format("%.0f",prefs.pctTheta * 100) + "%", waveX, waveY );
      waveX = waveX + waveXOffset;
      float totalPct = prefs.pctAlpha + prefs.pctBeta + prefs.pctDelta + prefs.pctGamma + prefs.pctTheta;
     text( "Total Pct: " + String.format("%.0f",totalPct * 100) + "%", waveX, waveY );
     
  }
}
  
  
 
