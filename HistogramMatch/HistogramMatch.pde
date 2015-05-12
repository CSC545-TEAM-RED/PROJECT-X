
// Compares images using their histograms.  Image files to be compared are listed at the top
// of the program, a target and up to 10 images to compare it to.  Several variations are
// implemented, and can be viewed using the following keys:
// p: For each value of RGB, compares the percent of each image's pixels which have that value.
// c: Uses the cumulative histograms.
// n: Rather than using percentages, normalizes the histograms by dividing by the maximum
//    number of pixels of any one value.
//
// 0-9: Pressing a number key displays the target image with one of the comparison images.
//      These are in the order that the files are listed.
// h: Shows the histogram of the target image and the image which was last displayed.


import java.util.Arrays;    // for sort()

//String targetFile = "black.png";
//String[] compareFiles = {"white.png"};

//String targetFile = "red-green.png";
//String[] compareFiles = {"red-green.jpg", "yellow-black.png"};

//String targetFile = "maroon.png";
//String[] compareFiles = {"maroon1.png", "black.png"};

String targetFile = "Corgi.jpg";
String[] compareFiles = {"Corgi-3.jpg", "Corgi-5.jpg", "Corgi-mirror.jpg", 
"Corgi-verydark.png", "Corgi3.jpg", "Corgi4.jpg", "Corgi5.jpg", "Corgi7.jpg",
"parrot-small.jpg", "ocean.png"};

//String targetFile = "Corgi-3.jpg";
//String[] compareFiles = {"Corgi.jpg", "Corgi-4.jpg", "Corgi-5.jpg"};


int imgCount = compareFiles.length;
PImage targetImg;
// img will always keep the order the files are listed in;
// imgArray will be reordered based on comparisons of the histograms.
PImage[] img = new PImage[imgCount];
Image[] imgArray = new Image[imgCount];
int currentIndex = 0;

// The histograms need to be of type 'PGraphics' because we can't draw lines on a PImage.
PGraphics targetHist, hist, rankImg; 

int histWidth = 808;  // [0-9][10-265][266-275][276-531][532-541][542-797][798-807]
int histHeight = 300;  // arbitrary

// Used for setting correct width and height in frame.setSize()
int imgWidth, imgHeight, histWindowWidth, histWindowHeight, matchesWidth, matchesHeight;

boolean histShown = false;
boolean matchesShown = true;

// Arrays for storing the histograms (and all the variations). 
// Index 0 is the histogram for the target image, and all others are shifted by 1.
int[][] rHist = new int[imgCount + 1][256];  // Java automatically initializes int arrays to 0
int[][] gHist = new int[imgCount + 1][256];
int[][] bHist = new int[imgCount + 1][256];

float[][] rHistPercent = new float[imgCount + 1][256];
float[][] gHistPercent = new float[imgCount + 1][256];
float[][] bHistPercent = new float[imgCount + 1][256];

int[][] rCumulativeHist = new int[imgCount + 1][256];
int[][] gCumulativeHist = new int[imgCount + 1][256];
int[][] bCumulativeHist = new int[imgCount + 1][256];

float[][] rCumulativeHistPercent = new float[imgCount + 1][256];
float[][] gCumulativeHistPercent = new float[imgCount + 1][256];
float[][] bCumulativeHistPercent = new float[imgCount + 1][256];

float[][] rHistNormalized = new float[imgCount + 1][256];
float[][] gHistNormalized = new float[imgCount + 1][256];
float[][] bHistNormalized = new float[imgCount + 1][256];

// Comparison methods:
// 0: percentages
// 1: cumulative
// 2: normalized
int comparisonMethod = 0;


void setup() {
  targetImg = loadImage(targetFile);
  for (int i = 0; i < imgCount; i++) {
    img[i] = loadImage(compareFiles[i]);
    imgArray[i] = new Image(compareFiles[i]);
  }
  
  if (frame != null) {
    frame.setResizable(true);    // so we can resize the window to display the histograms
  }
  
  histWindowWidth = histWidth + frame.getInsets().top + frame.getInsets().bottom;
  histWindowHeight = 2 * histHeight + frame.getInsets().top + frame.getInsets().bottom;
  matchesWidth = 1000 + frame.getInsets().left + frame.getInsets().right;
  matchesHeight = 700 + frame.getInsets().top + frame.getInsets().bottom;
    
  // Create all histograms and compute difference values.
  createHistograms(targetImg, 0);
  for (int i = 0; i < imgCount; i++) {
    createHistograms(imgArray[i].getImage(), i + 1);
    imgArray[i].setDiff(0, compareHistograms(i));
    imgArray[i].setDiff(1, compareCumulativeHistograms(i));
    imgArray[i].setDiff(2, compareNormalizedHistograms(i));
  }
  
  targetHist = drawHistograms(0);
  hist = drawHistograms(1);
  
  rankImg = showMatches();
  
  size(1000, 700);
  image(rankImg, 0, 0);
}


void draw() {
  if (histShown) {
    background(32);
    image(targetHist, 0, 0);
    image(hist, 0, histHeight);
    printPixelCounts(currentIndex);
  } else if (matchesShown) {
    image(rankImg, 0, 0);
  } else {
    background(200);
    image(targetImg, 0, 0);
    image(img[currentIndex], targetImg.width + 2, 0);
  }
}


void keyReleased() {
  if (key == 'h') {
    histShown = true;  
    matchesShown = false; 
    frame.setSize(histWindowWidth, histWindowHeight);
    //save("hist.png");
  } else if (key == 'p') {
    comparisonMethod = 0;
    rankImg = showMatches();
    histShown = false;
    matchesShown = true;
    frame.setSize(matchesWidth, matchesHeight);
  } else if (key == 'c') {
    comparisonMethod = 1;
    rankImg = showMatches();
    histShown = false;
    matchesShown = true;
    frame.setSize(matchesWidth, matchesHeight);
  } else if (key == 'n') {
    comparisonMethod = 2;
    rankImg = showMatches();
    histShown = false;
    matchesShown = true;
    frame.setSize(matchesWidth, matchesHeight);
  } else {
    int k = parseInt(str(key));
    if (k >= 0 && k < imgCount) {
      histShown = false;
      matchesShown = false;
      currentIndex = k;
      hist = drawHistograms(k+1);
      imgWidth = targetImg.width + img[k].width + 2 
                + frame.getInsets().left + frame.getInsets().right;
      imgHeight = max(targetImg.height, img[k].height) 
                + frame.getInsets().top + frame.getInsets().bottom;
      frame.setSize(imgWidth, imgHeight);
      //save("img" + str(k) + ".png");
    }
  }
}
    

void createHistograms(PImage img, int imgNum) { 
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
  
  // Calculate the percentage of the pixels that have each RGB value.
  int pixelCount = img.width * img.height;
  for (int i = 0; i < 256; i++) {
    rHistPercent[imgNum][i] = rHist[imgNum][i] / float(pixelCount);
    gHistPercent[imgNum][i] = gHist[imgNum][i] / float(pixelCount);
    bHistPercent[imgNum][i] = bHist[imgNum][i] / float(pixelCount);
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
  for (int i = 0; i < 256; i++) {
    rCumulativeHistPercent[imgNum][i] = rCumulativeHist[imgNum][i] / float(pixelCount);
    gCumulativeHistPercent[imgNum][i] = gCumulativeHist[imgNum][i] / float(pixelCount);
    bCumulativeHistPercent[imgNum][i] = bCumulativeHist[imgNum][i] / float(pixelCount);
  }
  
  // Create histograms normalized by the maximum number of pixels of any one value
  // (the "peak" of the histogram).
  for (int i = 0; i < 256; i++) {
    rHistNormalized[imgNum][i] = rHist[imgNum][i] / float(redMax);
    gHistNormalized[imgNum][i] = gHist[imgNum][i] / float(greenMax);
    bHistNormalized[imgNum][i] = bHist[imgNum][i] / float(blueMax);
  }
}  


float compareHistograms(int k) {
  // Compares histograms based on the percentage of the pixels that have each RGB value.
  float redDiff = 0;
  float greenDiff = 0;
  float blueDiff = 0;
  for (int i = 0; i < 256; i++) {
    redDiff += abs(rHistPercent[0][i] - rHistPercent[k+1][i]);
    greenDiff += abs(gHistPercent[0][i] - gHistPercent[k+1][i]);
    blueDiff += abs(bHistPercent[0][i] - bHistPercent[k+1][i]);
  }
  return redDiff + greenDiff + blueDiff;
}


float compareCumulativeHistograms(int k) {
  // Compares histograms based on the percentage of the pixels that have values <= each 
  // RGB value.
  float redDiff = 0;
  float greenDiff = 0;
  float blueDiff = 0;
  for (int i = 0; i < 256; i++) {
    redDiff += abs(rCumulativeHistPercent[0][i] - rCumulativeHistPercent[k+1][i]);
    greenDiff += abs(gCumulativeHistPercent[0][i] - gCumulativeHistPercent[k+1][i]);
    blueDiff += abs(bCumulativeHistPercent[0][i] - bCumulativeHistPercent[k+1][i]);
  }
  return redDiff + greenDiff + blueDiff;
}


float compareNormalizedHistograms(int k) {
  // Compares histograms which have been normalized by the maximum number of pixels
  // of any one value.
  float redDiff = 0;
  float greenDiff = 0;
  float blueDiff = 0;
  for (int i = 0; i < 256; i++) {
    redDiff += abs(rHistNormalized[0][i] - rHistNormalized[k+1][i]);
    greenDiff += abs(gHistNormalized[0][i] - gHistNormalized[k+1][i]);
    blueDiff += abs(bHistNormalized[0][i] - bHistNormalized[k+1][i]);
  }
  return redDiff + greenDiff + blueDiff;
}


PGraphics showMatches() {
  // Sorts the images according to the currently selected comparisonMethod, then creates 
  // a PGraphics object to display these ranked images.
  Arrays.sort(imgArray);
  
  rankImg = createGraphics(1000, 700);
  rankImg.beginDraw();
  rankImg.background(200);
  rankImg.fill(0);
  rankImg.textSize(20);
  rankImg.text("Matches for " + targetFile + ": ", 10, 20);
  PImage thumbnail = targetImg.get();
  thumbnail.resize(0, 100);
  rankImg.image(thumbnail, 400, 10);
  
  for (int i = 0; i < min(5, imgCount); i++) {
    rankImg.text((i+1) + ". " + imgArray[i].getFileName(), 10, 110*(i+1) + 40);
    rankImg.text("Score: " + imgArray[i].getDiff(comparisonMethod), 30, 110*(i+1) + 80);
    thumbnail = imgArray[i].getImage();
    thumbnail.resize(0, 100);
    rankImg.image(thumbnail, 250, 110*(i+1) + 30);
  }
  if (imgCount > 5) {
    for (int i = 5; i < imgCount; i++) {
      rankImg.text((i+1) + ". " + imgArray[i].getFileName(), 510, 110*(i-4) + 40);
      rankImg.text("Score: " + imgArray[i].getDiff(comparisonMethod), 530, 110*(i-4) + 80);
      thumbnail = imgArray[i].getImage();
      thumbnail.resize(0, 100);
      rankImg.image(thumbnail, 750, 110*(i-4) + 30);
    }
  }
  rankImg.endDraw();
  return rankImg;  
}


PGraphics drawHistograms(int imgNum) {  
  // This function draws the histograms, assuming createHistograms() has already been called
  // with the same imgNum.
  
  // Find the maximum height of the histograms, to be sure we can display them accurately.
  int rMax = max(rHist[imgNum]);
  int gMax = max(gHist[imgNum]);
  int bMax = max(bHist[imgNum]);
  int histMax = max(rMax, gMax, bMax);
  float factor = float(histHeight - 10) / histMax;  // used to scale the histogram
  
  // Draw the histograms.
  PGraphics hist = createGraphics(histWidth, histHeight);
  hist.beginDraw();
  for (int i = 0; i < 256; i++) {
    hist.stroke(255, 0, 0);
    hist.line(i+10, histHeight, i+10, histHeight - rHist[imgNum][i] * factor);
    hist.stroke(0, 255, 0);
    hist.line(i+276, histHeight, i+276, histHeight - gHist[imgNum][i] * factor);
    hist.stroke(0, 0, 255);
    hist.line(i+542, histHeight, i+542, histHeight - bHist[imgNum][i] * factor);
  }
  hist.endDraw();
  return hist;
}


void printPixelCounts(int imgNum) {
  // If a histogram is shown, displays pixel information on the histograms 
  // (when mouse moves over them).
  if (mouseX >= 10 && mouseX <= 265) {
    text("Red pixel value: " + (mouseX - 10), 5, 15);
    if (mouseY < histHeight)
      text("Count: " + rHist[0][mouseX - 10], 5, 35);
    else
      text("Count: " + rHist[imgNum + 1][mouseX - 10], 5, 35);
  } else if (mouseX >= 276 && mouseX <= 531) {
    text("Green pixel value: " + (mouseX - 276), 5, 15);
    if (mouseY < histHeight)
      text("Count: " + gHist[0][mouseX - 276], 5, 35);
    else
      text("Count: " + gHist[imgNum + 1][mouseX - 276], 5, 35);
  } else if (mouseX >= 542 && mouseX <= 797) {
    text("Blue pixel value: " + (mouseX - 542), 5, 15);
    if (mouseY < histHeight)
      text("Count: " + bHist[0][mouseX - 542], 5, 35);
    else
      text("Count: " + bHist[imgNum + 1][mouseX - 542], 5, 35);
  }
}



