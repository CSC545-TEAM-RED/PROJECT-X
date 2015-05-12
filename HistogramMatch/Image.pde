// Each image object contains a file name, a PImage, and an array of "differences" or
// "scores" calculated by comparing histograms.  This class was created in order to be
// able to use Arrays.sort().

class Image implements Comparable {
    
  String fileName;
  PImage img;
  float[] diff = new float[3];
  
  Image(String file) {
    fileName = file;
    img = loadImage(fileName);
  }
  
  void setDiff(int i, float d) {
    diff[i] = d;
  }
  
  String getFileName() {
    return fileName;
  }
  
  PImage getImage() {
    return img.get();
  }
  
  float getDiff(int i) {
    return diff[i];
  }
  
  int compareTo(Object o) {
    Image img = (Image)o;

    if (diff[comparisonMethod] < img.diff[comparisonMethod])
      return -1;
    else if (diff[comparisonMethod] == img.diff[comparisonMethod])
      return 0;
    else
      return 1;
  }
}
