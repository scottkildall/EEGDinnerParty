/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.util.Date;

MuseHeadset[] headsets;
DebugDisplay debugDisplay;
DinnerDisplay dinnerDisplay;
RecordPrefs prefs;

int numDevices = 4;
Boolean bDebugDisplay = false;

void setup() {
  //size(1920,1080 );
  size(1920,1080, OPENGL );
 
  // comment out to see all our fonts
  //print(PFont.list());
  
  //savePrefs();
  loadPrefs();
 
  frameRate(60);

  //-- init headsets
  headsets = new MuseHeadset[numDevices];
  for( int i = 0; i < numDevices; i++ ) {
    int portNum = prefs.portNum + i;    // numbering starts at 5001 for 'muse1', etc
    headsets[i] = new  MuseHeadset(portNum, getHeadsetName(i));
    headsets[i].setPctWaves(prefs.pctAlpha, prefs.pctBeta, prefs.pctDelta, prefs.pctGamma, prefs.pctTheta );
    headsets[i].setTasteTopFilter(prefs.tasteIndexTopFilter);
    headsets[i].setTasteBottomFilter(prefs.tasteIndexBottomFilter);
  }
  
  debugDisplay = new DebugDisplay(prefs,numDevices,headsets);
  dinnerDisplay = new DinnerDisplay(prefs,numDevices,headsets);
  dinnerDisplay.toggleHelperImage();
}

String getHeadsetName(int headsetNum) {
    if( headsetNum == 0 )
      return "Pig";
    else if( headsetNum == 1 )
     return "Martini";
    else if( headsetNum == 2 )
     return "Fire";
   else if( headsetNum == 3 )
     return "Beaker";
    else
      return "ERROR - getHeadsetName()";
}

void draw() {
  if( bDebugDisplay )
    debugDisplay.draw();
  else
    dinnerDisplay.draw();
}

void stop() {
    for( int i = 0; i < numDevices; i++ ) {
    headsets[i] = null;
  }
}

void keyPressed() {
   // SPACE = debug mode
   if( key == '1' )
      dinnerDisplay.toggleHelperImage();
      
  if (key == 'd' || key == 'D')
       bDebugDisplay = !bDebugDisplay;
       
    if (key == 'c' || key == 'C')
       dinnerDisplay.clearPlot();
  
  if( key == 'r' || key == 'R' )
    reloadPrefs();
    
  if( key == ' ' ) {
     if( bDebugDisplay == false ) {
        for( int i = 0; i < numDevices; i++ ) {
          if( headsets[i].isTouchingForehead() == true ) {
               dinnerDisplay.startPlot();
               break;
          }
        }
     }
  }
}

void reloadPrefs() {
  int oldPortNum = prefs.portNum;
  
  loadPrefs();
  
  //-- we don't actually do anything here, maybe for the future
  /*println( "OLD PORT = " + str(oldPortNum));
  println( "NEW PORT = " + str(prefs.portNum));*/
  

  //-- reload percentage weighting values from prefs
  debugDisplay.setPrefs(prefs);
  for( int i = 0; i < numDevices; i++ ) {
    headsets[i].setPctWaves(prefs.pctAlpha, prefs.pctBeta, prefs.pctDelta, prefs.pctGamma, prefs.pctTheta );
    headsets[i].setTasteTopFilter(prefs.tasteIndexTopFilter);
    headsets[i].setTasteBottomFilter(prefs.tasteIndexBottomFilter);
  }
}

void saveDefaultPrefs() {
  Gson gson = new GsonBuilder().serializeNulls().create();
   
  RecordPrefs prefs = new RecordPrefs();
  prefs.portNum = 5001;
  prefs.pctAlpha = .07;
  prefs.pctBeta = .38;
  prefs.pctDelta = .40;
  prefs.pctGamma = .05;
  prefs.pctTheta = .10;
        
  PrintWriter writer = createWriter("preferences.json");
  writer.println(gson.toJson(prefs));
  writer.flush();
  writer.close();
}

void loadPrefs() {
  println("LOAD PREFS");
  try {
    Gson gson = new GsonBuilder().serializeNulls().create(); 
    String [] fileStrings = loadStrings("preferences.json"); 
    if( fileStrings == null ) {
      println("NULL pointer in loadPrefs(), save from default");
      loadDefaultPrefs();
    }
    else {
      println( "SUCCESSFUL LOAD");
      println(fileStrings[0]);
      prefs = gson.fromJson(fileStrings[0], RecordPrefs.class);
      
      println("port num = " + str(prefs.portNum));
     println( "pct alpha = " + str(prefs.pctAlpha));
     println( "pct beta = " + str(prefs.pctBeta));
     println( "pct delta = " + str(prefs.pctDelta));
     println( "pct gamma = " + str(prefs.pctGamma));
      println( "pct theta = " + str(prefs.pctTheta));
 
 
    }
  }
  catch( Exception e ) {
     println("EXCEPTION in loadPrefs(), save from default");
     loadDefaultPrefs();
  }
}

//-- use to prevent recursion
RecordPrefs loadDefaultPrefs() {
  Gson gson = new GsonBuilder().serializeNulls().create(); 
  saveDefaultPrefs(); 
   String [] fileStrings = loadStrings("preferences.json"); 
   return( gson.fromJson(fileStrings[0], RecordPrefs.class) );
}



