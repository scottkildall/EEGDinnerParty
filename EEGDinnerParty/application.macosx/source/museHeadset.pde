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
 
 
// globals for percentages
float pctAlpha = .05;  // spiky
float pctBeta = .40;    // looks good
float pctDelta = .40;    // also good
float pctGamma = .05; // spiky
float pctTheta = .10;  // ok

class MuseHeadset {
  int port;
  OscP5 osc;
  
  int touchingForehead = 0;
  
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
  
  ///float plotValue;
  boolean bRandomMode;    // XXX: we will remove this later
  ///boolean bRandomTasteIndex;
  
  float tasteIndex;
  float combinedQValue;
  long lastPacketMS = 0;
  long numQValues;    // how many times we've done a combined QValue plot
  String headsetName;  // used for data output
  Boolean connected = true;
  
  float topFilter;
  float bottomFilter;
  
  MuseHeadset(int thePort, String _headsetName) {
    port = thePort;
    osc = new OscP5(this,port);
    headsetName = new String(_headsetName);
    
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
    
    bRandomMode = false; 
    /// bRandomTasteIndex = false;
    numQValues = 0;
    resetData();
    lastPacketMS = millis();
    
    topFilter = 3.0;
    bottomFilter = 1.25;
  }
  
  void setTasteTopFilter(float _topFilter) {
    topFilter = _topFilter;
  }
  
  void setTasteBottomFilter(float _bottomFilter) {
    bottomFilter = _bottomFilter;
  }
  
  String getHeadsetName() {
    return headsetName;
  }
  
  void setConnected(Boolean _connected) {
    connected = _connected;
    String s = "TRUE";
    if(connected == false)
      s = "FALSE";
  }
  
  void setPctWaves(float _pctAlpha, float _pctBeta, float _pctDelta, float _pctGamma, float _pctTheta) {
      pctAlpha = _pctAlpha;
      pctBeta = _pctBeta;
      pctDelta = _pctDelta;
      pctGamma = _pctGamma;
      pctTheta = _pctTheta;
  }
  
  //-- called by draw() loop, will update internal data arrays
  Boolean isTouchingForehead() {
      return (touchingForehead == 1);
  }
  
  float getTasteIndex() {
    return tasteIndex; 
  }
  
  void resetData() {
     tasteIndex = 50;
     
     /*
     if( bRandomMode )
       plotValue = random(0,100);
     else
       plotValue = 50; 
       */
     combinedQValue = 50;
  }
  
  float getPlotValue() {
    numQValues = numQValues + 1;
    
    if( connected == false && touchingForehead == 1 ) {
       bRandomMode = true;
    }
      
    if( bRandomMode )
       return randomizePlotValue();
     else {
       //println( "CombinedQ Value = " + str(combinedQValue));
       
       float newQValue = (qAlpha * pctAlpha) + (qBeta * pctBeta) + (qDelta * pctDelta) + (qGamma * pctGamma) + (qTheta * pctTheta);
       
       if( newQValue <  combinedQValue+1 &&  newQValue >  combinedQValue-1 )
         combinedQValue = noiseFilter(newQValue);
      
       // println( "OLD TASTE INDEX: " + str(tasteIndex) );
          tasteIndex += addVolatility(newQValue,combinedQValue);
          tasteIndex = checkMaxMin(tasteIndex,3.0);
         //  println( "NEW TASTE INDEX: " + str(tasteIndex) );
           
            combinedQValue = checkMaxMin(newQValue,3.0);
       
       //println( "return QValue = " + str(combinedQValue) );
       return combinedQValue;
     } 
  }
  
  //-- still working out this formula...this gives us a range of -1 to 1
  //-- instance vars we are looking at:
  //-- numQValues: how many samples, will be 1-1500
  //--
   float addVolatility(float oldQ, float newQ ) {
     if( numQValues < 3 )
       return 0;
      
      float diff = abs(oldQ-newQ);
        
      if( diff > topFilter )
        diff = topFilter;
      
      float multiplier = 2.0;
       if( numQValues > 1200 )
        multiplier = 4.0;
      if( numQValues > 750 )
        multiplier = 3.0;
        
      return (diff-bottomFilter) * multiplier;
   }
   
  float getAlpha() {
    return qAlpha;
  }
  float getBeta() {
    return qBeta;
  }
  float getDelta() {
    return qDelta;
  }
  float getGamma() {
    return qGamma;
  }
  float getTheta() {
    return qTheta;
  }
   
   // makes sure we don't go over 100 or less than 0, does some randomization goodies
   float checkMaxMin(float qValue, float bumpRange) {
      if( qValue > 100 )
         qValue = 100 - random(.5,bumpRange+.5);  
      else if( qValue < 0 )
        qValue = 0 + random(.5,bumpRange+.5);
        
      return qValue;
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
   
   private float randomizePlotValue() {
     println( "RANDOM MODE -- randomizePlotValue()");
     /// if( bRandomMode && touchingForehead == 1) {
        float randRange = 3.0;
        float oldQValue = combinedQValue;
        combinedQValue = combinedQValue + random(-randRange,randRange);
        if( combinedQValue < 0 )
          combinedQValue = combinedQValue + random(-combinedQValue,randRange+.5);
        else if( combinedQValue > 100 )
          combinedQValue = combinedQValue - random((combinedQValue-100),randRange+.5);
         /* 
        tasteIndex = tasteIndex + random(-1,1);
        if( tasteIndex < 0 )
          tasteIndex = 0;
        else if( tasteIndex > 100 )
          tasteIndex = 100;
          */
          
          // println( "OLD TASTE INDEX: " + str(tasteIndex) );
          tasteIndex += addVolatility(oldQValue,combinedQValue);
          tasteIndex = checkMaxMin(tasteIndex,3.0);
           //println( "NEW TASTE INDEX: " + str(tasteIndex) );
           
          return combinedQValue;
      }
   ///}
             
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
    
    float goodDivisor = 7;
    float okDivisor = 3;
    float badDivisor = 1;
       
    
    for( int i = 0; i < 4; i++ ) {
      
       if( horseshoeValues[i] == 1.0 ) {
         qValue = map(waveValues[i],-1.0,0.0,0,100) * goodDivisor;    // 9x factor for a good connection
         divisor = divisor + goodDivisor;
       }
       else if( horseshoeValues[i] == 2.0 ) {
         qValue = map(waveValues[i],-1.0,0.0,0,100) * okDivisor;    // 3x factor for a ok connection
         divisor = divisor + okDivisor;
       }
       else if( horseshoeValues[i] == 3.0 ) {
         qValue =map(waveValues[i],-1.0,0.0,0,100) * badDivisor;    // 1x factor for a bad connection
         divisor = divisor + badDivisor;
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
    
    // FAIL SAFE
    if( qValue > 100 )
      qValue = 0;
    else if( qValue < 0 )
      qValue = 0;
     
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
      
      //println( "ALPHA: " );
      qAlpha = generateQWaveValue(alpha,qAlpha);  
    }
    
    // BETA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/beta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        beta[i] = theOscMessage.get(i).floatValue();
      }
      
      //println( "BETA" );
      qBeta = generateQWaveValue(beta,qBeta); 
    }
   
   // DELTA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/delta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        delta[i] = theOscMessage.get(i).floatValue();
      }
      //println( "DETLA :" );
       qDelta = generateQWaveValue(delta,qDelta);
       
    }
    
    // GAMMA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/gamma_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        gamma[i] = theOscMessage.get(i).floatValue();
      }
      
      //println( "GAMMA: " );
      qGamma = generateQWaveValue(gamma,qGamma); 
    }
    
    // THETA (ABSOLUTE)
    if( addrPattern.equals("/muse/elements/theta_absolute") ) {
      for( int i = 0; i < 4; i++ ) {
        theta[i] = theOscMessage.get(i).floatValue();
      }
      
      //println( "THETA: " );
      qTheta = generateQWaveValue(theta,qTheta); 
    }
    
    // HORSESHOE
    if( addrPattern.equals("/muse/elements/horseshoe") ) {
      for( int i = 0; i < 4; i++ ) {
        horseshoeValues[i] = theOscMessage.get(i).floatValue();
      }
      generateHorseShoeStrings();
    }
    
    // TOUCHING FOREHEAD
    if(  addrPattern.equals("/muse/elements/touching_forehead") ) {
      //println("touching forehead typetag: "+ theOscMessage.typetag());
      touchingForehead = theOscMessage.get(0).intValue();
      //println( "TOUCHING FOREHEAD = " + str(touchingForehead) );
      
    } 
    
    lastPacketMS = millis();
  }
}
