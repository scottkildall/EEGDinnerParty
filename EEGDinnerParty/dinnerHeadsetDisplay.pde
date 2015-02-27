/**
 * DinnerHeadsetDisplay
 * Written by Scott Kildall
 * March 2014
 * 
*/
 
class DinnerHeadsetDisplay {
  // colors for the graphing function
  int r;
  int g;
  int b;
  int tasteX;
  int tasteY;
  int iconX;
  int iconY;
  PImage tasteDialImage;
  PImage tasteBackgroundImage;
  PImage iconImage;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  DinnerHeadsetDisplay(String iconFilename, int _r, int _g, int _b, int _tasteX, int _tasteY, int _iconX, int _iconY ) {
    // Save local variables
    r = _r;
    g = _g;
    b = _b;
    tasteX = _tasteX;
    tasteY = _tasteY;
    iconX = _iconX;
    iconY = _iconY;
    
    //-- hardcoded. In an ideal world, these would be static variables, but memory isn't an issue here
    tasteBackgroundImage = loadImage("taste_index_background.png");
    tasteDialImage = loadImage("taste_index_dial.png");
    iconImage = loadImage(iconFilename);
    
  }
  
  public void setFillColor() {
    fill(r,g,b);
    stroke(r,g,b);  
  }
  
  //-- draw 
  public void draw(MuseHeadset headset) {
    drawGraph();
    drawTasteIndex();
  }
  
  
  public void drawTasteIndex() {
    imageMode(CENTER);
    image(tasteBackgroundImage, tasteX, tasteY);
    image(iconImage, tasteX, tasteY + 130 );
    
    imageMode(CORNER);
    image(tasteDialImage,tasteX,tasteY + 70);
  }
  
  //-- this is a separate draw function since the icons should always be on top of the graph lines from other EEG data
  public void drawIcons() {
    imageMode(CENTER);  
    image(iconImage, iconX, iconY );
  }
  
  private void drawGraph() {
    noFill();
    stroke(r,g,b);
    strokeWeight(2);
  }
}
