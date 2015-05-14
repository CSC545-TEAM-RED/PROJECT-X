// Compares two PImages based on their histograms (uses cumulative histograms scaled by
// the total number of pixels) and returns a floating point number between 0 and 1 which 
// indicates their relative difference.

float histogramCompare(PImage targetImg, PImage img) {
  
  float[][] rCumulativeHistPercent = new float[2][256];
  float[][] gCumulativeHistPercent = new float[2][256];
  float[][] bCumulativeHistPercent = new float[2][256];
  
  createHistograms(targetImg, 0, rCumulativeHistPercent, gCumulativeHistPercent, bCumulativeHistPercent);
  createHistograms(img, 1, rCumulativeHistPercent, gCumulativeHistPercent, bCumulativeHistPercent);
  
  return compareCumulativeHistograms(rCumulativeHistPercent, gCumulativeHistPercent, 
      bCumulativeHistPercent) / 765;  // Divide by maximum difference (black & white).
}


void createHistograms(PImage img, int imgNum, float[][] rCumulativeHistPercent, 
                      float[][] gCumulativeHistPercent, float[][] bCumulativeHistPercent) { 
  // Index 0 is the histogram for the target image and index 1 for the other.
  int[][] rHist = new int[2][256];  // Java automatically initializes int arrays to 0
  int[][] gHist = new int[2][256];
  int[][] bHist = new int[2][256];
  
  int[][] rCumulativeHist = new int[2][256];
  int[][] gCumulativeHist = new int[2][256];
  int[][] bCumulativeHist = new int[2][256];
  
  // For each of RGB, accumulate number of pixels of each value, 0-255, in the image.
  color c;
  int redMax = 0, greenMax = 0, blueMax = 0;
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      c = img.get(x, y);
      rHist[imgNum][int(red(c))] += 1;
      gHist[imgNum][int(green(c))] += 1;
      bHist[imgNum][int(blue(c))] += 1;
      
      redMax = max(rHist[imgNum][int(red(c))], redMax);
      greenMax = max(gHist[imgNum][int(green(c))], greenMax);
      blueMax = max(bHist[imgNum][int(blue(c))], blueMax);
    }
  }
  
  // Create cumulative histograms.
  rCumulativeHist[imgNum][0] = rHist[imgNum][0];
  gCumulativeHist[imgNum][0] = gHist[imgNum][0];
  bCumulativeHist[imgNum][0] = bHist[imgNum][0];
  
  for (int i = 1; i < 256; i++) {
    rCumulativeHist[imgNum][i] = rCumulativeHist[imgNum][i-1] + rHist[imgNum][i];
    gCumulativeHist[imgNum][i] = gCumulativeHist[imgNum][i-1] + gHist[imgNum][i];
    bCumulativeHist[imgNum][i] = bCumulativeHist[imgNum][i-1] + bHist[imgNum][i];
  }
  
  // Calculate the percentage of the pixels that have values <= each RGB value.
  int pixelCount = img.width * img.height;
  for (int i = 0; i < 256; i++) {
    rCumulativeHistPercent[imgNum][i] = rCumulativeHist[imgNum][i] / float(pixelCount);
    gCumulativeHistPercent[imgNum][i] = gCumulativeHist[imgNum][i] / float(pixelCount);
    bCumulativeHistPercent[imgNum][i] = bCumulativeHist[imgNum][i] / float(pixelCount);
  }
}


float compareCumulativeHistograms(float[][] rCumulativeHistPercent, 
                      float[][] gCumulativeHistPercent, float[][] bCumulativeHistPercent) {
  // Compares histograms based on the percentage of the pixels that have values <= each 
  // RGB value.
  float redDiff = 0;
  float greenDiff = 0;
  float blueDiff = 0;
  for (int i = 0; i < 256; i++) {
    redDiff += abs(rCumulativeHistPercent[0][i] - rCumulativeHistPercent[1][i]);
    greenDiff += abs(gCumulativeHistPercent[0][i] - gCumulativeHistPercent[1][i]);
    blueDiff += abs(bCumulativeHistPercent[0][i] - bCumulativeHistPercent[1][i]);
  }
  return redDiff + greenDiff + blueDiff;
}
