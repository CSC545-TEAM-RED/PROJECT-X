PImage source, compareTo;
float threshold = 0.05;

// use directPixelCompare(img1, img2)

float directPixelCompare(PImage img1, PImage img2) {
  PImage test1 = createImage(min(img1.width,img2.width),min(img1.height,img2.height),RGB);
  PImage test2 = createImage(min(img1.width,img2.width),min(img1.height,img2.height),RGB);
  test1.copy(img1,0,0,img1.width,img1.height,0,0,test1.width,test1.height);
  test2.copy(img2,0,0,img2.width,img2.height,0,0,test2.width,test2.height);
  test1.loadPixels();
  test2.loadPixels();
  float difference=0.0, dr, dg, db;
  for(int i = 0; i < test1.pixels.length; i++) {
    color p1 = test1.pixels[i];
    color p2 = test2.pixels[i];
    
    dr = red(p1) - red(p2);
    dg = green(p1) - green(p2);
    db = blue(p1) - blue(p2);
    
    difference += sqrt(dr*dr + dg*dg + db*db)/255.0;
  }
  return difference/(test1.width*test1.height);
} 
