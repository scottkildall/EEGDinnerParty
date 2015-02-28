/**
 * dinnerDisplay.pde
 */
 


class DinnerDisplay {
  DinnerHeadsetDisplay[] displays;
  MuseHeadset [] headsets;
  int numDevices;
  PImage helperImage;
  PImage bannerImage;
  Boolean bDisplayHelperImage = true;
  Plotter plotter;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  DinnerDisplay(int _numDevices, MuseHeadset [] _headsets) {
    numDevices = _numDevices;
    headsets = _headsets;
    
    displays = new DinnerHeadsetDisplay[numDevices];
    
    int tasteX = 294;
    int tasteXMargin = 433;
    int tasteY = 890;
    int iconX = 1538;
    int iconXMargin = 63;
    int iconY = 232;
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
    float numMinutes = 1.0f;  // 1.0 is good for testing
    plotter = new Plotter(headsets, 162, 234 );
    plotter.initialize( 1584, 344, numMinutes, 10, 5);
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
    imageMode(CORNER);
     image(bannerImage,0,0);
    
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
  
  //-- we can also use this as a toggle button
  public void startPlot() {
      plotter.clear();
      plotter.start();
  }
  
  //-- we can also use this as a toggle button
  public void clearPlot() {
      plotter.clear();
  }
}
  
  
 
