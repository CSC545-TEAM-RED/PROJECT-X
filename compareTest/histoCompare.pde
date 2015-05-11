PImage img1, img2;

// use histoCompare(img1, img2);

// make a histogram using an image, and three float arrays of size
//  256. Values in the histograms' arrays range from 0(none) to 1(highest)
void buildHisto(PImage img, float[] red, float[] green, float[] blue) {
  img.loadPixels();
  float redMax=0.0, greenMax=0.0, blueMax=0.0; // keep maxes
  int redTmp, greenTmp, blueTmp;
  color c;
  for(int i = 0; i < img.pixels.length; i++) {
    c = img.pixels[i];
    redTmp = int(red(c));
    greenTmp = int(green(c));
    blueTmp = int(blue(c));
    red[redTmp] ++;
    green[greenTmp]++;
    blue[blueTmp]++;
    redMax = max(red[redTmp],redMax);
    greenMax = max(green[greenTmp],greenMax);
    blueMax = max(blue[blueTmp],blueMax);
  }
  // use maxes to normalize values
  for(int i = 0; i < 256; i++) {
    red[i] = red[i] / redMax;
    green[i] = green[i] / greenMax;
    blue[i] = blue[i] / blueMax;
    
  }
  
  return;
}

// function to compare two images via histogram. returns difference from 0 to 1
float histoCompare(PImage img1, PImage img2) {
  float[] redOne = new float[256];
  float[] greenOne = new float[256];
  float[] blueOne = new float[256];
  float[] redTwo = new float[256];
  float[] greenTwo = new float[256];
  float[] blueTwo = new float[256];
  
  for(int i = 0; i < 256; i++) {
    redOne[i] = 0.0;
    greenOne[i] = 0.0;
    blueOne[i] = 0.0;
    redTwo[i] = 0.0;
    greenTwo[i] = 0.0;
    blueTwo[i] = 0.0;
  }
  
  buildHisto(img1,redOne,greenOne,blueOne);
  buildHisto(img2,redTwo,greenTwo,blueTwo);
  
  float error=0.0;
  for(int i = 0; i < 256; i++) {
    error += abs(redOne[i] - redTwo[i]);
    error += abs(greenOne[i] - greenTwo[i]);
    error += abs(blueOne[i] - blueTwo[i]);
  }
  
  error /= (768.0); // normalize error 
  
  return error;
}
