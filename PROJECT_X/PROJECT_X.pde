import java.io.File;

// Filename of target image (the one we will be comparing everything to)
String targetImageLocation = "target.jpg";

// Path to directory of images that will be searched through
String imageLibraryLocation = "."; // '.' means current directory

void setup() {
  PImage target = loadImage(targetImageLocation);
  
  for (String filePath : getFiles(dataPath(imageLibraryLocation))) {
    PImage image = loadImage(filePath);
    if (image == null) continue;
    
    // Use the "image" variable in the search functions
    // Like so:
    // some_algorithm(target, image);
  }
}

/* getFiles generates an ArrayList of direct file paths */
ArrayList<String> getFiles(String path) {
  ArrayList<String> files = new ArrayList<String>();
  File root = new File(path);
  File[] list = root.listFiles();
  
  if (list != null) {
    for (File f : list) {
      if (f.isDirectory()) {
        files.addAll(getFiles(f.getAbsolutePath()));
      }
      else {
        files.add(f.getAbsolutePath());
      }
    }
  }
  
  return files;
}
