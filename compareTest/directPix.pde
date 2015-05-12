PImage source, compareTo;
float threshold = 0.05;

// use directPixelCompare(img1, img2)

float directPixelCompare(PImage img1, PImage img2) {
  PImage[] temp = makePermutations(img1);
  
  float closestMatch = comparePixels(img1, img2);
  for(int i = 0; i < 7; i++) {
    closestMatch = min(comparePixels(temp[i], img2),closestMatch);
  }
  
  return closestMatch;
}

float comparePixels(PImage img1, PImage img2) {
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

PImage[] makePermutations(PImage input) {
  PImage[] temp = new PImage[7];
  temp[0] = createImage(input.width,input.height,RGB);
  temp[1] = createImage(input.width,input.height,RGB);
  temp[2] = createImage(input.width,input.height,RGB);
  temp[3] = createImage(input.height,input.width,RGB);
  temp[4] = createImage(input.height,input.width,RGB);
  temp[5] = createImage(input.height,input.width,RGB);
  temp[6] = createImage(input.height,input.width,RGB);
  
  int wid = input.width - 1;
  int hei = input.height - 1;
  
  // horizontal flip
  color c;
  for(int y = 0; y < input.height; y++) {
    for(int x = 0; x < input.width; x++) {
      c = input.get(x,y);
      temp[0].set(wid - x, y, c);
      temp[1].set(x, hei - y, c);
      temp[2].set(wid - x, hei - y, c);
      temp[3].set(hei - y,x,c);
      temp[4].set(y,wid - x,c);
      temp[5].set(hei - y, wid - x, c);
      temp[6].set(y,x,c);
    }
  }  
  
  return temp;
}
