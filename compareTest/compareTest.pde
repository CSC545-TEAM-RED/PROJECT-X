import java.io.File;

File dir;
File[] files;
ArrayList<String> imgFiles = new ArrayList<String>();
ArrayList<String> imgNames = new ArrayList<String>();
PImage sourceImg;
ArrayList<String> sortedNames = new ArrayList<String>();
ArrayList<Float> sortedDiff = new ArrayList<Float>();
float searchQuality;

void setup() {
  dir = new File(dataPath("")); // set the data folder to hold files to search from
  updateFiles(); // keep list of all image files to search from 

  /*for(int i = 0; i < imgFiles.size(); i++) {
    println(imgFiles.get(i),imgNames.get(i));
  }*/
  //searchQuality = 0.25; // general search
  //searchQuality = 0.50; // relaxed search
  searchQuality = 0.70; // good search
  //searchQuality = 0.85; // strict search
  //searchQuality = 0.95; // best search
  
  selectInput("select a file to search for:", "setSource");
  
}

void setSource(File selection) {
  // check if file is valid (non-null)
  
  println("File selected:",selection.getAbsolutePath());
  sourceImg = loadImage(selection.getAbsolutePath());
  // check if file is an image
  
  PImage compareTo;
  int count;
  float histo, direct, pal, total;
  for(int i = 0; i < imgFiles.size(); i++) {
    println("Comparing with:",imgFiles.get(i));
    compareTo = loadImage(imgFiles.get(i));
    histo = histoCompare(sourceImg, compareTo);
    direct = directPixelCompare(sourceImg, compareTo);
    pal = paletteImageCompare(sourceImg, compareTo);
    total = (histo+direct+pal)/3;
    count = 0;
    while(count < sortedDiff.size() && total > sortedDiff.get(count)) count++;
    sortedDiff.add(count,total);
    sortedNames.add(count,imgNames.get(i));
  }
  
  for(int i = 0; i < sortedDiff.size(); i++) {
    //println(sortedNames.get(i),sortedDiff.get(i));
    if(1-sortedDiff.get(i) < searchQuality) break; // don't include results below selected quality
    System.out.printf("File:%s Match: %.1f%%\n",sortedNames.get(i),(1.0-sortedDiff.get(i))*100.0);
  }
  
  return;
}

void updateFiles() {
  imgFiles.clear();
  imgNames.clear();
  files = dir.listFiles();
  String path,name;
  
  for(int i = 0; i < files.length; i++) {
    path = files[i].getAbsolutePath();
    name = files[i].getName();
    if(path.toLowerCase().endsWith(".jpg") || path.toLowerCase().endsWith(".png")) {
      imgFiles.add(path);
      imgNames.add(name);
    }
  }
  
  return;
}

