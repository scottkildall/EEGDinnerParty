/**
 * DinnerHeadsetDisplay
 * Written by Scott Kildall
 * March 2014
 * 
*/
 
class DinnerHeadsetDisplay {
  MuseHeadset headset;
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
  float degreesMultiplier;
  
  PFont tasteIndexFont;
  
  //-- color is a name, like "yellow", "red", "green", blue"
  DinnerHeadsetDisplay(MuseHeadset _headset, String iconFilename, int _r, int _g, int _b, int _tasteX, int _tasteY, int _iconX, int _iconY ) {
    headset = _headset;
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
   // tasteDialImage = loadImage("taste_index_dial.png");
   // tasteDialImage = loadImage("gradient_testdial.jpg");
   tasteDialImage = loadImage("taste_index_dial_elongated.png");
    iconImage = loadImage(iconFilename);
    
    // for taste index, dial rotation
    degreesMultiplier = 180.0/100.0;
    
    tasteIndexFont = createFont("Arial", 14 );  //-- XXX: needs GE font, whatever this is
  }
  
  public void setFillColor() {
    fill(r,g,b);
    stroke(r,g,b);  
  }
  
  //-- draw 
  public void draw(MuseHeadset headset) {
    drawGraph();
    drawTasteIndex();
    drawTasteIndexLabels();
    checkConnection();
  }
  
  
  public void drawTasteIndex() {
    imageMode(CENTER);
    image(tasteBackgroundImage, tasteX, tasteY);
    image(iconImage, tasteX, tasteY + 130 );
    
    if(headset.isTouchingForehead()) {
      // rotation code for the dial indicator
      pushMatrix();
      translate( tasteX,tasteY+80);
      rotate(radians(degreesMultiplier*headset.getTasteIndex()));
      image(tasteDialImage,0,0);
      popMatrix();
    }
    
    // shows taste index as a percentage
    /*
    fill(0,0,0);
    textSize(14);
    text( String.format("%.0f",headset.getTasteIndex()) + "%", tasteX, tasteY  );
    */
  }
  
  // hardcoded-labels
  void drawTasteIndexLabels() {
    fill(0,0,0);
    textFont(tasteIndexFont);
    textAlign(CENTER);
    
    float xLowerOffset = 120;
    float xUpperOffset = 115;
    float yLowerOffset = 110;
    float yUpperOffset = -70;
    
    text(  "Low", tasteX - xLowerOffset, tasteY + yLowerOffset );
     text(  "Medium", tasteX - xUpperOffset, tasteY + yUpperOffset );
      text(  "High", tasteX + xUpperOffset,tasteY + yUpperOffset );
      text(  "Very High", tasteX + xLowerOffset, tasteY + yLowerOffset );
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
  
  private void checkConnection() {
     long packetConnectionTime = 3000;  // how much time before we deem a device is disconnected
     
     String connectedStr = "Connected: ";
     if( headset.lastPacketMS + packetConnectionTime > millis() ) {
      headset.setConnected(true);
    }
     else {
        headset.setConnected(false);
    } 
  }
}
