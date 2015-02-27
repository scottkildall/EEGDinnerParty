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
  
  //int touchingForehead = 0;
  //float batteryPct = -1.0;    // NO READING
  //int[] good; // num sensors
  
  // These are "absolute" rather than relative values
  float [] alpha;
  float [] beta;
  float [] delta;
  float [] gamma;
  float [] theta;
  float [] horseshoeValues;
  String [] horseshoeStrings;
  
  // quantization
  float qAlpha;
  float qBeta;
  float qDelta;
  float qGamma;
  float qTheta;
  
  int lastPacketTime;
  
  MuseHeadset(int thePort) {
    port = thePort;
    osc = new OscP5(this,port);
    
    //good = new int[4];
    alpha = new float[4];
    beta = new float[4];
    delta = new float[4];
    gamma = new float[4];
    theta = new float[4];
    horseshoeValues = new float[4];
    horseshoeStrings = new String[4];
    for( int i = 0; i < 4; i++ )
      horseshoeValues[i] = -1;    // not yet being used
      
    generateHorseShoeStrings();
    
    zeroQWaveValues();
    
    lastPacketTime = millis();
  }
  
  void zeroQWaveValues() {
      qAlpha = 0.0;
      qBeta = 0.0;
      qDelta = 0.0;
      qGamma = 0.0;
      qTheta = 0.0;
  }
  
  //-- based on horseshoe settings, will generate average qQave values
  float generateQWaveValue(float [] waveValues) {
   
    for( int i = 0; i < 4; i++ ) {
       // generate qValue here 
    }
   
   return 0.0;
  }
  void generateHorseShoeStrings() {
    for( int i = 0; i < 4; i++ ) {
      if( horseshoeValues[i] == 4.0 )
        horseshoeStrings[i] = new String("none");
      else if( horseshoeValues[i] == 3.0 )
        horseshoeStrings[i] = new String("bad");
      else if( horseshoeValues[i] == 2.0 )
        horseshoeStrings[i] = new String("ok");
      else if( horseshoeValues[i] == 1.0 )
        horseshoeStrings[i] = new String("good");
       else
        horseshoeStrings[i] = new String("N/A");
    }
  }
  
  // incoming osc message are forwarded to the oscEvent method, private to this class
  void oscEvent(OscMessage theOscMessage) {
    // Uncomment for "raw" debugging"
    //print (addrPattern);
    
    String addrPattern = theOscMessage.addrPattern();
    
    // ALPHA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/alpha_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        alpha[i] = theOscMessage.get(i).floatValue();
      }
      qAlpha = generateQWaveValue(alpha);
    }
    
    // BETA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/beta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        beta[i] = theOscMessage.get(i).floatValue();
      }
    }
   
   // DELTA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/delta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        delta[i] = theOscMessage.get(i).floatValue();
      }
    }
    
    // GAMMA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/gamma_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        gamma[i] = theOscMessage.get(i).floatValue();
      }
    }
    
    // THETA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/theta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        theta[i] = theOscMessage.get(i).floatValue();
      }
    }
    
    // HORSESHOE
    if( addrPattern.equals("/muse/elements/horseshoe") ) {
      for( int i = 0; i < 4; i++ ) {
        horseshoeValues[i] = theOscMessage.get(i).floatValue();
      }
      generateHorseShoeStrings();
    }
    
    ///REMOVE (LATER)
    /*
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
   else if( addrPattern.equals("/test"))  {
     println("TEST @ Port: " + str(port));
      //println( "message = " + str(theOscMessage.get(0).intValue()));
      
   }
   */
   // last communication, whatever it might be
   lastPacketTime = millis();
  }
}
