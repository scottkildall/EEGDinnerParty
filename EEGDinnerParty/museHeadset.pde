 /**
 * MuseHeadset Class
 * Written by Scott Kildall
 * March 2014
 * 
 * Designed for use with multiple Muse headsets, will listen to OSC events
 * Headset should be hooked up to the same computer, network connections can be turned off.
 *
 * In Terminal Windows, type in, something like:
 * muse-io --preset 14 --device muse --osc osc.udp://localhost:5000
 * And in Processing, instatiate it such as:
 *    new  MyOSCListener(5000);
 *
 * Each headset needs its own unique port number and device name.
 * Device name can be changed in SystemPrefs->Bluetooth
 */
 
class MuseHeadset {
  int port;
  OscP5 osc;
  
  int touchingForehead = 0;
  float batteryPct = -1.0;    // NO READING
  int[] good; // num sensors
  
  float [] betaRelative;
  float [] thetaRelative;
  
  MuseHeadset(int thePort) {
    port = thePort;
    osc = new OscP5(this,port);
    good = new int[4];
    betaRelative = new float[4];
    thetaRelative = new float[4];
    
    float batteryPct;
  }
 
  // incoming osc message are forwarded to the oscEvent method, private to this class
  void oscEvent(OscMessage theOscMessage) {
    //print(theOscMessage);
    
    /* print the address pattern and the typetag of the received OscMessage */
    //print("### received an osc message.");
    String addrPattern = theOscMessage.addrPattern();
    //print (addrPattern);
    if( addrPattern.equals("/muse/elements/beta_absolute") ) {
      println( "BETA ABS");
      
      for( int i = 0; i < 4; i++ ) {
        betaRelative[i] = theOscMessage.get(i).floatValue();
        println(betaRelative[i]);
      }
    }
    else if( addrPattern.equals("/muse/elements/theta_absolute") ) {
      println( "THETA ABS");
      for( int i = 0; i < 4; i++ ) {
        thetaRelative[i] = theOscMessage.get(i).floatValue();
       println(thetaRelative[i]); 
      }
    }
    else if(  addrPattern.equals("/muse/elements/touching_forehead") ) {
      //println("touching forehead typetag: "+ theOscMessage.typetag());
      touchingForehead = theOscMessage.get(0).intValue();
    }  
    else if( addrPattern.equals("/muse/elements/is_good") ) {
      //println("touching forehead typetag: "+ theOscMessage.typetag());
      for(int i = 0; i <4;i++ ) {
        good[i] = theOscMessage.get(i).intValue();
      }
    }  
    else if( addrPattern.equals("/muse/batt")) {
        // State of Charge, Divide this by 100 to get percentage of charge remaining, (e.g. 5367 is 53.67%)
       batteryPct = float(theOscMessage.get(0).intValue()) / 100.0;
        //println(batteryPct);
   }
   else if( addrPattern.equals("/test")) 
     println("TEST @ Port: " + str(port));
      //println( "message = " + str(theOscMessage.get(0).intValue()));
  }
  

}
