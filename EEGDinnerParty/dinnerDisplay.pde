/**
 * dinnerDisplay.pde
 */
 


class DinnerDisplay {
  RecordPrefs prefs;
  DinnerHeadsetDisplay[] displays;
  MuseHeadset [] headsets;
  int numDevices;
  PImage helperImage;
  PImage bannerImage;
  Boolean bDisplayHelperImage = true;
  Plotter plotter;
  PFont headingFont;    // "Live EEG Feed" and "BBQ Taste Index"
  PShape graySwatch;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  DinnerDisplay(RecordPrefs _prefs,int _numDevices, MuseHeadset [] _headsets) {
    prefs = _prefs;
    numDevices = _numDevices;
    headsets = _headsets;
    
    headingFont = createFont("Arial-Bold", 36 );  //-- XXX: this needs to be bold
    makeGraySwatch();
    
    displays = new DinnerHeadsetDisplay[numDevices];
    
    int tasteX = 294;
    int tasteXMargin = 433;
    int tasteY = 890;
    int iconX = 1538;
    int iconXMargin = 63;
    int iconY =  148;   //232;
    displays[0] = new DinnerHeadsetDisplay(headsets[0], "pig_icon.png", 132, 18, 37, tasteX, tasteY, iconX, iconY);
    tasteX = tasteX + tasteXMargin;
    iconX = iconX + iconXMargin;
    displays[1] = new DinnerHeadsetDisplay( headsets[1], "martini_icon.png", 89, 81, 148, tasteX, tasteY, iconX, iconY);
    tasteX = tasteX + tasteXMargin;
    iconX = iconX + iconXMargin;
    displays[2] = new DinnerHeadsetDisplay( headsets[2], "fire_icon.png", 255, 152, 33, tasteX, tasteY, iconX, iconY);
    tasteX = tasteX + tasteXMargin;
    iconX = iconX + iconXMargin;
    displays[3] = new DinnerHeadsetDisplay( headsets[3], "beaker_icon.png", 70, 173, 0, tasteX, tasteY, iconX, iconY);
    
    
    bannerImage = loadImage("banner.png");
    
    //-- allocate and initialize plotter
    float numMinutes = 5.0f;  // 1.0 is good for testing
    
    Boolean bSaveData = false;
    if( prefs.saveData != null && prefs.saveData.equals("true") ) 
      bSaveData = true;
    
    if( prefs.savePath == null )
      prefs.savePath = "";
      
    plotter = new Plotter(headsets, 162, 234, bSaveData, prefs.savePath );
    float numPixels = 1584;  // UI value
    numPixels = 1500;  // better test value
    plotter.initialize( numPixels, 344, numMinutes, 10, 5);
  }
  
  public void toggleHelperImage() {
     bDisplayHelperImage = !bDisplayHelperImage; 
     
     if( bDisplayHelperImage )
       helperImage = loadImage("background.jpg");
  }
  
  //-- draw 
  public void draw() {
    background(255);    
    ellipseMode(CENTER);  // Set ellipseMode to CENTER
    
    if( helperImage != null && bDisplayHelperImage == true ) {
      imageMode(CORNER);
      tint(255,128);
      image(helperImage,0,0);
      noTint();
    }
    
    drawGraySwatch();
    
    imageMode(CORNER);
    image(bannerImage,0,0);
    
    drawLabels();
    
    for( int i = 0; i < numDevices; i++ )
      displays[i].draw(headsets[i]); 
      
     plotter.draw();
     for( int i = 0; i < numDevices; i++ ) {
        displays[i].setFillColor();
        plotter.drawPlot(i);
     }
     
     for( int i = 0; i < numDevices; i++ )
        displays[i].drawIcons(); 
  }
  
  public void drawLabels() {
      textFont(headingFont);
      textAlign(CENTER);
      fill(0,0,0);
      text("Live EEG Feed", 355,210);
      text("BBQ Taster Index", width/2,750);
  }
  
  public void drawGraySwatch() {
      shape(graySwatch,0,0);
  }
  
  //-- we can also use this as a toggle button
  public void startPlot() {
      if( plotter.isPlotting() )
        plotter.finish();
      else { 
        plotter.clear();
        plotter.start();
      }
  }
  
  //-- we can also use this as a toggle button
  public void clearPlot() {
      plotter.clear();
  }
  
  private void makeGraySwatch() {
     graySwatch = loadShape("grayswatch.svg");
  }
}
  
  
 
