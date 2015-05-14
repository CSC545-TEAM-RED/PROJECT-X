// This function is intended to be called by GroupRProject (the main file).  It calculates
// the best matches using an average of the selected methods and returns a PGraphics object
// showing the 10 best matches that the GUI can display.
// targetFilename: Name of the file to be used as the target for matching
// targetImg: A PImage which is the target for matching
// imgNames: Names of the files we'll compare the target to
// imgFiles: Paths to the files we'll compare the target to
// methods: An array of four booleans to indicate whether each of the four methods
//          (direct pixel, histogram, palette, keypoint) has been selected.


PGraphics showMatches(String targetFilename, PImage targetImg, ArrayList<String> imgFiles, 
                      ArrayList<String> imgNames, boolean[] methods) {

  // Parallel arrays
  ArrayList<String> sortedNames = new ArrayList<String>();
  ArrayList<Float> sortedDiff = new ArrayList<Float>();
  ArrayList<PImage> sortedImages = new ArrayList<PImage>();
  
  // Compare targetImg to each of the images in the list using the selected methods
  // and sort them as we go using insertion sort.
  PImage compareTo;
  int count;
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  for(int i = 0; i < imgFiles.size(); i++) {
    
    compareTo = loadImage(imgFiles.get(i));
    int methodCount = 0;
    float total = 0;
    
    if (methods[0]) {
      println("direct");
      methodCount += 1;
      total += directPixelCompare(targetImg, compareTo);
    }
    if (methods[1]) {
      println("histogram");
      methodCount += 1;
      total += histogramCompare(targetImg, compareTo);
    }
    if (methods[2]) {
      println("palette");
      methodCount += 1;
      total += paletteCompare(targetImg, compareTo);
      //total += paletteImageCompare(targetImg, compareTo);
    }
    if (methods[3]) {
      println("keypoint");
      methodCount += 1;
      total += keyPointCompare(targetImg, compareTo);
    }
    
    total = total / methodCount;
    count = 0;
    while(count < sortedDiff.size() && total > sortedDiff.get(count)) count++;
    sortedDiff.add(count,total);
    sortedNames.add(count,imgNames.get(i));
    sortedImages.add(count, compareTo);
  }
  
  // Create a PGraphics object displaying the 10 best matches.
  PGraphics rankImg = createGraphics(1000, 700);
  rankImg.beginDraw();
  rankImg.background(200);
  rankImg.fill(0);
  rankImg.textSize(20);
  rankImg.text("Matches for " + targetFilename + ": ", 10, 20);
  PImage thumbnail = targetImg.get();
  thumbnail.resize(0, 100);
  rankImg.image(thumbnail, 400, 10);
  
  for (int i = 0; i < min(5, sortedNames.size()); i++) {
    rankImg.text((i+1) + ". " + sortedNames.get(i), 10, 110*(i+1) + 40);
    float score = 100 * (1 - sortedDiff.get(i));      
    rankImg.text("Score: " + score + "%", 30, 110*(i+1) + 80);
    thumbnail = sortedImages.get(i);
    thumbnail.resize(0, 100);
    rankImg.image(thumbnail, 250, 110*(i+1) + 30);
  }
  
  if (sortedNames.size() > 5) {
    for (int i = 5; i < min(10, sortedNames.size()); i++) {
      rankImg.text((i+1) + ". " + sortedNames.get(i), 510, 110*(i-4) + 40);
      float score = 100 * (1 - sortedDiff.get(i));
      rankImg.text("Score: " + score + "%", 530, 110*(i-4) + 80);
      thumbnail = sortedImages.get(i);
      thumbnail.resize(0, 100);
      rankImg.image(thumbnail, 750, 110*(i-4) + 30);
    }
  }
  
  rankImg.endDraw();
  return rankImg;
}
