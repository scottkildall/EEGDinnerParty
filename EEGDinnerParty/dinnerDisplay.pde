/**
 * dinnerDisplay.pde
 */
 


class DinnerDisplay {
  DinnerHeadsetDisplay[] displays;
  int numDevices;
  PImage helperImage;
  PImage bannerImage;
  Boolean bDisplayHelperImage = true;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  DinnerDisplay(int _numDevices) {
    numDevices = _numDevices;
    
    displays = new DinnerHeadsetDisplay[numDevices];
    
    int tasteX = 294;
    int tasteXMargin = 433;
    int tasteY = 890;
    int iconX = 1538;
    int iconXMargin = 63;
    int iconY = 232;
    displays[0] = new DinnerHeadsetDisplay("pig_icon.png", 132, 18, 37, tasteX, tasteY, iconX, iconY);
    tasteX = tasteX + tasteXMargin;
    iconX = iconX + iconXMargin;
    displays[1] = new DinnerHeadsetDisplay( "martini_icon.png", 89, 81, 148, tasteX, tasteY, iconX, iconY);
    tasteX = tasteX + tasteXMargin;
    iconX = iconX + iconXMargin;
    displays[2] = new DinnerHeadsetDisplay( "fire_icon.png", 255, 152, 33, tasteX, tasteY, iconX, iconY);
    tasteX = tasteX + tasteXMargin;
    iconX = iconX + iconXMargin;
    displays[3] = new DinnerHeadsetDisplay( "beaker_icon.png", 70, 173, 0, tasteX, tasteY, iconX, iconY);
    
    helperImage = loadImage("background.jpg");
    bannerImage = loadImage("banner.png");
  }
  
  public void toggleHelperImage() {
     bDisplayHelperImage = !bDisplayHelperImage; 
  }
  
  //-- draw 
  public void draw(MuseHeadset [] headsets) {
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
      
     for( int i = 0; i < numDevices; i++ )
        displays[i].drawIcons(); 
  }
}
  
  
 
