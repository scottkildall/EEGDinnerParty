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
  
  float plotValue;
  boolean bRandomMode;
  
  float tasteIndex;
  float combinedQValue;
  
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
    
    if( thePort == 5006 )
      bRandomMode = false;
    else
      bRandomMode = true;
    resetData();
  }
  
  //-- called by draw() loop, will update internal data arrays
  void update() {
    
  }
  
  float getTasteIndex() {
    return tasteIndex; 
  }
  
  void resetData() {
     tasteIndex = 50;
     
     if( bRandomMode )
       plotValue = random(0,100);
     else
       plotValue = 50; 
       
     combinedQValue = 50;
  }
  
  float getPlotValue() {
    if( bRandomMode )
       return plotValue;
     else {
       //println( "CombinedQ Value = " + str(combinedQValue));
       
       float newQValue = (qAlpha * 0.2) + (qBeta * 0.2) + (qDelta * 0.2) + (qGamma * 0.2) + (qTheta * 0.2);
       
       if( newQValue <  combinedQValue+1 &&  newQValue >  combinedQValue-1 )
         combinedQValue = noiseFilter(newQValue);
         
       combinedQValue = newQValue;
       //println( "return QValue = " + str(combinedQValue) );
       return combinedQValue;
     } 
  }
   
   float noiseFilter(float qValue) {
     float filterRange = 2.0;
     float retValue = qValue + random(-filterRange,filterRange);
     if( retValue < 0 )
        retValue = 0 + random(.5,filterRange+.5);
     else if( retValue > 100 )
        retValue = 100 - random(.5,filterRange+.5);  
        
      return retValue;
   }
   
   void nextPlotValue() {
      if( bRandomMode ) {
        float randRange = 3.0;
        plotValue = plotValue + random(-randRange,randRange);
        if( plotValue < 0 )
          plotValue = plotValue + random(-plotValue,randRange+.5);
        else if( plotValue > 100 )
          plotValue = plotValue - random((plotValue-100),randRange+.5);
          
        tasteIndex = tasteIndex + random(-1,1);
        if( tasteIndex < 0 )
          tasteIndex = 0;
        else if( tasteIndex > 100 )
          tasteIndex = 100;
      }
   }
             
  void zeroQWaveValues() {
      //-- set to reasonable defaults for these
      qAlpha = 50.0;
      qBeta = 50.0;
      qDelta = 50.0;
      qGamma = 50.0;
      qTheta = 50.0;
  }
  
  //-- based on horseshoe settings, will generate average qQave values
    // scale is -1.0 to 0?

  float generateQWaveValue(float [] waveValues, float previousQValue) {
    float qValue = -10000;    // impossibly low number, set as flag
    float divisor = 0;
    
   
    for( int i = 0; i < 4; i++ ) {
      
       if( horseshoeValues[i] == 1.0 ) {
         qValue = map(waveValues[i],-1.0,0.0,0,100) * 8;    // 8x factor for a good connection
         divisor = divisor + 8;
       }
       else if( horseshoeValues[i] == 2.0 ) {
         qValue = map(waveValues[i],-1.0,0.0,0,100) * 3;    // 3x factor for a ok connection
         divisor = divisor + 3;
       }
       else if( horseshoeValues[i] == 3.0 ) {
         qValue =map(waveValues[i],-1.0,0.0,0,100) * 1;    // 1x factor for a bad connection
         divisor = divisor + 1;
       }
    }
    
    if( qValue == -10000 ) {
       float qRandRange = 1.0;
       qValue = previousQValue + random(-qRandRange,qRandRange);
       if( qValue > 100 )
         qValue =  previousQValue - random(qRandRange/2, qRandRange*2);
       else if( qValue < 0 )
         qValue =  previousQValue + random(qRandRange/2, qRandRange*2);
    }
    else {
      qValue = qValue/divisor;
      //println( "ACTUAL Q Value = " + str(qValue));
     // println( "Divisor = " + str(divisor) );
    }
    
   return qValue;
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
      
      print( "ALPHA: " );
      qAlpha = generateQWaveValue(alpha,qAlpha);  
    }
    
    // BETA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/beta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        beta[i] = theOscMessage.get(i).floatValue();
      }
      
      print( "BETA" );
      qBeta = generateQWaveValue(beta,qBeta); 
    }
   
   // DELTA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/delta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        delta[i] = theOscMessage.get(i).floatValue();
      }
      print( "DETLA :" );
       qDelta = generateQWaveValue(delta,qDelta);
       
    }
    
    // GAMMA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/gamma_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        gamma[i] = theOscMessage.get(i).floatValue();
      }
      
      print( "GAMMA: " );
      qGamma = generateQWaveValue(gamma,qGamma); 
    }
    
    // THETA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/theta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        theta[i] = theOscMessage.get(i).floatValue();
      }
      
      print( "THETA: " );
      qTheta = generateQWaveValue(theta,qTheta); 
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
    if(  addrPattern.equals("/muse/elements/touching_forehead") ) {
      //println("touching forehead typetag: "+ theOscMessage.typetag());
      touchingForehead = theOscMessage.get(0).intValue();
    }  
    */
    
   // last communication, whatever it might be
   lastPacketTime = millis();
  }
}
