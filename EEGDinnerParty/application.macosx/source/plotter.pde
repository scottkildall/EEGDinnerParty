/**
 *   Plotter.pde
 *    
 *  Plots waveforms from headsets on the screen, using timer classes for callbacks
 */
 


class Plotter {
  MuseHeadset [] headsets;
  int numHeadsets;
  
  Boolean bRunning = false;
  int numPlottedPixels;   // how many pixels we have plotted on the screen, we use this for drawing
  Timer plotTimer;    // this should be the duration of the dinner party
  Timer pixelTimer;    // this will get called for every pixel that we plot
  
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
  
  //-- alloc this
  float [][] plotData;
  
  float lastMillis;
 
  //-- constructor, mostly empty
  Plotter(MuseHeadset [] _headsets, float _drawX, float _drawY) {
      headsets = _headsets;
      numHeadsets = headsets.length;
      drawX = _drawX;
      drawY = _drawY;
      
      numPlottedPixels = 0;
      plotTimer = null;
      
      //-- fonts for drawing
      axesTextFont = createFont("Arial", 28.3 );  
      axesNumbersFont = createFont("Arial", 14 );  //-- XXX: this needs to be updated
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
    
    bRunning = true;
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
  }
  
  private void drawLabels() { 
    textFont(axesTextFont);
    textAlign(CENTER);
    
    text( "Time (minutes ago)", width/2 -20, 660 );
     
    pushMatrix();
    translate( width/2 -900, height/2 - 140);
    rotate(radians(270));
    text( "BBQ Affinity (%)", 0,0);
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
     for( int i = 0; i < numPlottedPixels; i++ ) {
       point( drawX + i, drawY + h - plotData[headsetNum][i]);
     }
  }
  
   private void updatePlot() {
     if( bRunning ) {
       if( pixelTimer.expired()) {
         
         //lastMillis = millis();

         pixelTimer.start();
         
         for( int i = 0; i < numHeadsets; i++ ) {
             plotData[i][numPlottedPixels] = headsets[i].getPlotValue() * vPlotMultiplier;
             headsets[i].nextPlotValue(); 
          }
          
         // prevent overflow, in case plot pixels exceeds buffer
          if( numPlottedPixels < numPixels-1 )
            numPlottedPixels = numPlottedPixels + 1; 
       }
       if( plotTimer.expired()) {
           println("DONE: Plot time expired");
           println("pixeltimer, num Plotted pixels: " + str(numPlottedPixels) );
           bRunning = false;
           println( "end millis() = " + millis() );
       }
     }
   }
   
   
}
  
  
 
