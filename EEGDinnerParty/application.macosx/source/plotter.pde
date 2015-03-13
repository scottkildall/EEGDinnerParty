/**
 *   Plotter.pde
 *    
 *  Plots waveforms from headsets on the screen, using timer classes for callbacks
 */
 


class Plotter {
  MuseHeadset [] headsets;
  int numHeadsets;
  
  Boolean bSaveData;
  long saveDataTimerDuration;
  int numSavedDataSamples;
  int saveDataBufferSize;
  
  Boolean bRunning = false;
  int numPlottedPixels;   // how many pixels we have plotted on the screen, we use this for drawing
  Timer plotTimer;    // this should be the duration of the dinner party
  Timer pixelTimer;    // this will get called for every pixel that we plot
  Timer saveDataTimer;    // for JSON data output
  Timer allDoneTimer;  // for displaying an "ALL DONE" message
  Boolean bDisplayAllDone;
  
  float drawX;
  float drawY;
  float w;  // width
  float h; // height
  int numPixels;  // same as width
  float numMinutes;
  int numTimeIncrements;
  int numHeightIncrements;
  long duration;
  
  // more drawing code
  float vLabelsOffset;  // how much space between each line or for text
  float vPlotMultiplier;  // how much we mutliply each data point by to match our vertical plot
  String [] vLabels;      // vertical labels, for BBQ Affinity
  
  float hLabelsOffset;  // how much horziontal space
  String [] hLabels;      // vertical labels, for BBQ Affinity

  PFont axesTextFont;
  PFont axesNumbersFont;
  PFont allDoneFont;
  
  //-- alloc this
  float [][] plotData;
  Boolean [][] touchingForehead;
  
  
  float lastMillis;
 
   // saving data
   DataSample [][] dataSamples;
   Boolean [] headsetsOn;
   DataSample [][] outputDataSamples;
   
   RecordSavedSession savedSession;
   String savePath;
   
  //-- constructor, mostly empty
  Plotter(MuseHeadset [] _headsets, float _drawX, float _drawY, Boolean _bSaveData, String _savePath) {
      headsets = _headsets;
      numHeadsets = headsets.length;
      drawX = _drawX;
      drawY = _drawY;
      bSaveData = _bSaveData;
      savePath = new String(_savePath);
      
      saveDataTimerDuration = (2*1000); // 2 seconds
      
      ///XXX: remove
      /*
      if( bSaveData == true )
        println( "SAVING DATA");
     else
       println("NO SAVE DATA");
       */
       
      numPlottedPixels = 0;
      plotTimer = null;
      
       allDoneTimer = new Timer(5000);  // for displaying an "ALL DONE" message
       bDisplayAllDone = false;
  
      //-- fonts for drawing
      axesTextFont = createFont("Arial", 28.3 );  
      axesNumbersFont = createFont("Arial", 14 );  //-- XXX: this needs to be updated
      allDoneFont = createFont("Arial", 32 );
  }
  
  //-- must be called before start(), we pack the initialization code here, mostly for legibility
  //-- duration is in minutes and we will subdivide internally
  //-- time always starts at zero
  //-- height is always 0-100, for 0-100, num height increments = FIVE, [0,20,40,60,80,100]
  void initialize( float _w, float _h, float _numMinutes, int _numTimeIncrements, int _numHeightIncrements) {
    //-- always have to have at least 2 increments: a start and front
    if( _numTimeIncrements < 1 || _numHeightIncrements < 1 ) {
       println( "error in plotter.initialize(): _numTimeIncrements and _numHeightIncrements must be > 1" );
       return; 
    }
    
    // VARIABLES FOR WIDTH / HORIZONTAL
    numPixels = (int)_w - 20;  // number of pixels is actually slightly less than the width
    println("num pixels = " + str(numPixels) );
    
    w = _w;
    numTimeIncrements = _numTimeIncrements;
    
    // Allocate receptors for pixels
    plotData = new float[numHeadsets][numPixels];
    touchingForehead = new Boolean[numHeadsets][numPixels];
    numPlottedPixels = 0;
    
    //-- how much space between each horizontal line, used in drawAxes()
    hLabelsOffset = (float)numPixels/(float)(numTimeIncrements);
    
    // generate all the strings for drawing
    numMinutes = _numMinutes;
    hLabels = new String[numTimeIncrements+1];
    float incrementValue = numMinutes/numTimeIncrements;
    //println( "H plotter: increment value = " + str(incrementValue) );
    for( int i = 0; i < (numTimeIncrements+1); i++ ) {
      float fpLabel = 0.0f + (i*incrementValue);
      hLabels[i] = String.format("%.1f",fpLabel);
      
      // trim off extra ".0"
      int len = hLabels[i].length();
      if( len > 1  ) {
        String tailStr = hLabels[i].substring(len-2,len);
        if(tailStr.equals(".0"))
          hLabels[i] = hLabels[i].substring(0,len-2);
      }
       
      //println( "plotter: string label = " + hLabels[i] );
    }
    
    // VARIABLES FOR HEIGHT / VERTICAL
    h = _h;
    numHeightIncrements = _numHeightIncrements;
    vPlotMultiplier = h/100.0f;
    
    //-- how much space between each horizontal line, used in drawAxes()
    vLabelsOffset = h/(float)(numHeightIncrements);
    vLabels = new String[numHeightIncrements+1];
    int incrValue = 100/numHeightIncrements;
//    println( "V plotter: vLabelsOffset = " + str(vLabelsOffset) );
//    println( "V plotter: height = " + str(h) );
//    println( "V plotter: increment value = " + str(incrementValue) );
    for( int i = 0; i < (numHeightIncrements+1); i++ ) {
      int intLabel = 100 - (i*incrValue);
      vLabels[i] = str(intLabel);
      println( "plotter: string label = " + vLabels[i] );
    }
    
    
    duration = (long)numMinutes * 60 * 1000;
    println( "plotter.duration = " + str(duration) );
    
    plotTimer = new Timer(duration);
    
    
    long msAdjust = 10;
    long pixelTimerDuration = duration/numPixels - msAdjust;
    println( "duration = " + str(duration) );
    println( "numPixels = " + str(numPixels) );
    println( "plotter.pixelTimerDuration = " + str(pixelTimerDuration) );
    
    pixelTimer = new Timer(pixelTimerDuration);
    
    saveDataTimer = new Timer(saveDataTimerDuration);
    
    numSavedDataSamples = 0;
     println( "pixeltimerduration = " + str(pixelTimerDuration) );
      println( "saveDataTimerDuration = " + str(saveDataTimerDuration) );
    saveDataBufferSize = int(duration/saveDataTimerDuration);
    println( "savedatabuffersize = " + str(saveDataBufferSize) );
    if( bSaveData )
      allocateSaveDataBuffers(saveDataBufferSize);
  
  }
  
  Boolean isPlotting() {
    return bRunning;
  }
  
  //-- begins a new plot: initializes plotter, clears old values
  void start() {
    //-- plotTimer is null if initialize() hasn't been called
    if( plotTimer == null ) {
      println("plotter.initialize() must be called before plotter.start()");  
      return;
    }
    numPlottedPixels = 0;
    println( "start millis() = " + millis() );
    plotTimer.start();
    pixelTimer.start();
    if( bSaveData ) {
      //-- check headsets on for each on
      for(int i = 0; i < numHeadsets; i++ )
        headsetsOn[i] = headsets[i].isTouchingForehead();  
      saveDataTimer.start();
    }
    
    bDisplayAllDone = false;
    bRunning = true;
  }  
  
  void finish() {
      bRunning = false;
      if( bSaveData ) {
        copySaveDataBuffers();
        //printSavedData(); 
        
        writeSavedData();
        println( "DONE WRITING DATA");
      }     
      
      bDisplayAllDone = true;
      allDoneTimer.start(); 
  }
  
  void clear() {
    println( "CLEAR");
      numPlottedPixels = 0;
  }
  
  boolean isDone() {
     return (bRunning == false);
  }
  
  void draw() {
    drawAxes();
    drawLabels();
    updatePlot();
    updateAllDone();
  }
  
  private void drawLabels() { 
    textFont(axesTextFont);
    textAlign(CENTER);
    
    text( "Time (minutes ago)", width/2 -20, 660 );
     
    pushMatrix();
    translate( width/2 -900, height/2 - 140);
    rotate(radians(270));
    text( "Brain Wave Composite", 0,0);
    popMatrix();
     
  }
  private void drawAxes() {
      // draw the numbers here
      textFont(axesNumbersFont);
      textAlign(CENTER);
      
      // gray color for the lines
      fill(0,0,0);
      stroke(202,205,208);
      strokeWeight(2);
      
      // draw horizontal stuff
      for( int i = 0; i < (numTimeIncrements+1); i++ )  {
          text( hLabels[i], drawX + (i * hLabelsOffset), drawY + h + 28 );
      }
      
      // draw veritcal stuff
       for( int i = 0; i < (numHeightIncrements+1); i++ )  {
           text( vLabels[i], drawX - 30, drawY + (i * vLabelsOffset) + 6 );
           
           line(drawX,drawY + (i * vLabelsOffset) ,drawX + w, drawY + (i * vLabelsOffset) );
       }
     
     //    line(drawX,drawY+h,drawX + w, drawY+h );
     
  }
  
  void drawPlot(int headsetNum) {
    //-- point plots
    /*
     for( int i = 0; i < numPlottedPixels; i++ ) {
       point( drawX + i, drawY + h - plotData[headsetNum][i]);
     }
     */
     float lastX = 0;
     float lastY = 0;
     
      for( int i = 0; i < numPlottedPixels; i = i + 1 ) {
        float x = drawX + i;
          float y = drawY + h - plotData[headsetNum][i];
          
        if( i > 0 ) {
          if( touchingForehead[headsetNum][i] )
            line( lastX, lastY, x, y );
          
          
        }
        lastX = x;
        lastY = y;
     } 
  }
  
  private void updateAllDone() {
    if( bRunning == false && bDisplayAllDone == true ) {
      textAlign(CENTER);
      textFont(allDoneFont);
      fill( 132, 18, 37);
      text( "All Done!", width/2,170 );
      if( allDoneTimer.expired() )
        bDisplayAllDone = false; 
    }
  }
  
   private void updatePlot() {
     if( bRunning ) {
       if( pixelTimer.expired()) {
         pixelTimer.start();
         
         for( int i = 0; i < numHeadsets; i++ ) {
             plotData[i][numPlottedPixels] = headsets[i].getPlotValue() * vPlotMultiplier;
             touchingForehead[i][numPlottedPixels] = headsets[i].isTouchingForehead();
             ///headsets[i].nextPlotValue(); 
          }
          
         // prevent overflow, in case plot pixels exceeds buffer
          if( numPlottedPixels < numPixels-1 )
            numPlottedPixels = numPlottedPixels + 1; 
       }
       if( plotTimer.expired()) {
           println("DONE: Plot time expired");
           println("pixeltimer, num Plotted pixels: " + str(numPlottedPixels) );
           
           println( "end millis() = " + millis() );
           finish();
           
       }
       
       if( bSaveData && saveDataTimer.expired() ) {
          if( bSaveData && saveDataTimer.expired() ) {
             saveDataSample(numSavedDataSamples);
             if( numSavedDataSamples < saveDataBufferSize ) {
               numSavedDataSamples = numSavedDataSamples + 1;
               saveDataTimer.start();
             }
          }
       }
      }
   }


public void allocateSaveDataBuffers(int dataBufferSize) {
  println("ALLOCATING DATA BUFFERS, size = " + str(dataBufferSize));
     dataSamples = new DataSample[numHeadsets][dataBufferSize];
     for( int i = 0; i < numHeadsets; i++ ) {
        for( int j = 0; j < dataBufferSize; j++ )
           dataSamples[i][j] = new DataSample();
     }
     headsetsOn = new Boolean[numHeadsets];
}

//-- makes a duplciate of save data buffers, which we use for output
//-- relay on the instance var: numSavedDataSamples
public void copySaveDataBuffers() {
  int numActiveHeadsets = 0;
  for( int i = 0; i < numHeadsets; i++ ) {
     if( headsetsOn[i] )
       numActiveHeadsets = numActiveHeadsets + 1;
  }
  println( "NUM ACTIVE HEADSETS: " + str(numActiveHeadsets) );
  
  savedSession = new RecordSavedSession();
  savedSession.timestamp = getUnixTimestamp();
  savedSession.savedData = new RecordSavedData[numActiveHeadsets];
  
  int headsetIndex = 0;  // for active headset count
  for( int i = 0; i < numHeadsets; i++ ) {
     if( headsetsOn[i] == false )
       continue;
       
     savedSession.savedData[headsetIndex] = new RecordSavedData();
     savedSession.savedData[headsetIndex].headsetName = headsets[i].getHeadsetName();
     savedSession.savedData[headsetIndex].data = new DataSample[numSavedDataSamples];
      for( int j = 0; j < numSavedDataSamples; j++ ) {
        
           savedSession.savedData[headsetIndex].data[j] = new DataSample();
           //REMOVE
           /*
           println( "MS COPY = " + str(dataSamples[i][j].ms) );
           println( "MS SAVED = " + str(savedSession.savedData[i].data[j].ms) );
           */
           savedSession.savedData[headsetIndex].data[j].ms = dataSamples[i][j].ms;
           savedSession.savedData[headsetIndex].data[j].alpha = dataSamples[i][j].alpha;
           savedSession.savedData[headsetIndex].data[j].beta = dataSamples[i][j].beta;
           savedSession.savedData[headsetIndex].data[j].delta = dataSamples[i][j].delta;
           savedSession.savedData[headsetIndex].data[j].gamma = dataSamples[i][j].gamma;
           savedSession.savedData[headsetIndex].data[j].theta = dataSamples[i][j].theta;
      }
      
      headsetIndex = headsetIndex + 1;
  }
}

private void saveDataSample(int index) { 
  if( index > (saveDataBufferSize-1) ) {
    println( "Overflow, not saving data samples" );
    println( "Index = " + str(index) );
    println( "numSavedDataSamples = " + str(numSavedDataSamples) ); 
   return;
  }
    
  for( int i = 0; i < numHeadsets; i++ ) { 
    if( headsetsOn[i] ) {
       dataSamples[i][index].ms = (index+1) * saveDataTimerDuration;
       dataSamples[i][index].alpha = headsets[i].getAlpha();
       dataSamples[i][index].beta = headsets[i].getBeta();
       dataSamples[i][index].delta = headsets[i].getDelta();
       dataSamples[i][index].gamma = headsets[i].getGamma();
       dataSamples[i][index].theta = headsets[i].getTheta();
    }
  }
}

private void printSavedData() {
  for( int i = 0; i < numHeadsets; i++ ) {
  
    
    if( headsetsOn[i] ) {
      println( "--------------------------------" );
      println( "HEADSET: " + headsets[i].getHeadsetName() + ":" ); 
      for( int j = 0; j < numSavedDataSamples; j++ ) {
        
       println( "time: " + str(dataSamples[i][j].ms) );
       println( "alpha: " + str(dataSamples[i][j].alpha) );
       println( "beta: " + str(dataSamples[i][j].beta) );
       println( "delta: " + str(dataSamples[i][j].delta) );
       println( "gamma: " + str(dataSamples[i][j].gamma) );
       println( "theta: " + str(dataSamples[i][j].theta) );
       println( "--" );
      }
      println( "--------------------------------" );
    }
    else {
      println( "--------------------------------" );
       println( "Headest: " + headsets[i].getHeadsetName() + " Not connected " ); 
       println( "--------------------------------" );
    }
  }
} 

//-- note: savePath = "" if local
  
private void writeSavedData() {
  Gson gson = new GsonBuilder().serializeNulls().create();
  
  //String path = "/Users/edp_2/Dropbox/EEGDinnerParty/";
  //String path = "outputs/";
  
  String ts = String.format("%d",getUnixTimestamp());
  PrintWriter writer = createWriter(savePath + "data_" +  ts + ".json");
  writer.println(gson.toJson(savedSession));
  writer.flush();
  writer.close();
} 

private long getUnixTimestamp() {
    Date d = new Date();
  return d.getTime()/1000; 
}
}
  

  
 
