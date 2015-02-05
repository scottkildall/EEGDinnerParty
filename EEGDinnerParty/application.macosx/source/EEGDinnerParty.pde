/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;
  
MuseHeadset[] headsets;
int numDevices = 2;

Boolean drawForeheadConnection = true;    // headset
Boolean drawGoodConnection = true;        // 4 nodes
Boolean drawBattery = false;

void setup() {
  size(1280,720);
  frameRate(60);

  headsets = new MuseHeadset[numDevices];
  for( int i = 0; i < numDevices; i++ ) {
    int portNum = 5000 + i + 1;    // numbering starts at 5001 for 'muse1', etc
    headsets[i] = new  MuseHeadset(portNum);
  }
}

void draw() {
  background(0);    
  ellipseMode(CENTER);  // Set ellipseMode to CENTER
  
  for( int i = 0; i < numDevices; i++ )
    drawDeviceStats(i);
}

void stop() {
    for( int i = 0; i < numDevices; i++ ) {
    headsets[i] = null;
  }
}

void keyPressed() {
  // B = battery display, toggle
  if (key == 'b' || key == 'B')
      drawBattery = !drawBattery;
      
   // C = connection display, toggle
  if (key == 'c' || key == 'C') {
       drawGoodConnection = !drawGoodConnection;
       drawForeheadConnection = !drawForeheadConnection;
  }
}

// Main draw function for each device
void drawDeviceStats(int index) { 
  int drawX = 100 + (index*200); 
  int drawY = 50;  
  
  if( drawForeheadConnection )
    drawForeheadConnection(index, drawX, drawY);
  if( drawGoodConnection)
    drawGoodConnection(index, drawX, drawY);
    
  drawStress(index, drawX, drawY);
  drawMellow(index, drawX, drawY);
  
  if (drawBattery)
    drawBatteryLife(index, drawX, drawY);
}

// Single indication as to whether or not the forehead is 'connected'
void drawForeheadConnection(int index, float drawX, float drawY) {
  int diameter = 10;
  
  if( headsets[index].touchingForehead == 0 )
    fill(255,0,0);
  else {
    fill(0,255,0);
  }
  ellipse( drawX + diameter, diameter, diameter, diameter);  // Draw gray ellipse using CENTER mode
}

// 4 connections for touching various points on forehead
void drawGoodConnection(int index, float drawX, float drawY) {
  int diameter = 10;
  
  for( int i = 0; i <4; i++ ) {
    if( headsets[index].good[i] == 0 )
      fill(255,0,0);
    else 
      fill(0,255,0);
      
      ellipse(drawX+diameter + diameter * (i*2), diameter*3, diameter, diameter);  // Draw gray ellipse using CENTER mode
  }  
}


// Draws mellow life as relative position, index = inde into array of headset
void drawStress(int index, float drawX, float drawY) {
   int  diameter = 25;
    fill(255,0,0);
    ellipse(drawX + 100, height - (float(height)*headsets[index].concentration), diameter, diameter);  // Draw gray ellipse using CENTER mode
}

// Draws mellow life as relative position, index = inde into array of headset
void drawMellow(int index, float drawX, float drawY) {
   int  diameter = 25;
   fill(255,255,0);
   ellipse(drawX + 100 + 50, height - (float(height)*headsets[index].mellow), diameter, diameter);  // Draw gray ellipse using CENTER mode
}

// Draws battery life as relative position, index = inde into array of headset
void drawBatteryLife(int index, float drawX, float drawY) {
   fill(255, 255, 255);
   textSize(32);
   float batteryPct = headsets[index].batteryPct;
   String batteryStr = (batteryPct < 0) ? "---" :  str(headsets[index].batteryPct)+"%";
   text( batteryStr, drawX + 10, drawY + 50); 
}




