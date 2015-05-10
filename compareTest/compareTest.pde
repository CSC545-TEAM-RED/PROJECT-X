import java.io.File;

File dir;
File[] files;
ArrayList<String> imgFiles = new ArrayList<String>();
ArrayList<String> imgNames = new ArrayList<String>();
PImage sourceImg;

void setup() {
  dir = new File(dataPath("")); // set the data folder to hold files to search from
  updateFiles(); // keep list of all image files to search from 

  /*for(int i = 0; i < imgFiles.size(); i++) {
    println(imgFiles.get(i),imgNames.get(i));
  }*/
  
  selectInput("select a file to search for:", "setSource");
  
}

void setSource(File selection) {
  println("File selected:",selection.getAbsolutePath());
  sourceImg = loadImage(selection.getAbsolutePath());
  
  PImage compareTo;
  float histo, direct, pal, total;
  for(int i = 0; i < imgFiles.size(); i++) {
    compareTo = loadImage(imgFiles.get(i));
    histo = histoCompare(sourceImg, compareTo);
    direct = directPixelCompare(sourceImg, compareTo);
    //pal = paletteImageCompare(sourceImg, compareTo);
    pal = 0.0;
    total = histo+direct+pal;
    println(imgNames.get(i),total);
  }
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
}

