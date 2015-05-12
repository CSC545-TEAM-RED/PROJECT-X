// size of palette - set to what you think is best
final int palSize = 100;
// max iteration of the kmeans function - don't let it get too high
final int maxIterations = 5;
// distance threshold before the function quits early
final float deltaThreshold = 0.5;

// use paletteImageCompare(img1, img2)

float paletteImageCompare(PImage img1, PImage img2) {
  float paletteOne[][] = new float[palSize][3];
  float paletteTwo[][] = new float[palSize][3];
  color paletteCOne[] = new color[palSize];
  color paletteCTwo[] = new color[palSize];
  
  for(int i = 0; i < palSize; i++) {
    paletteOne[i][0] = 0.0;
    paletteOne[i][1] = 0.0;
    paletteOne[i][2] = 0.0;
    paletteTwo[i][0] = 0.0;
    paletteTwo[i][1] = 0.0;
    paletteTwo[i][2] = 0.0;
  }
  
  makePalette(img1, paletteOne);
  makePalette(img2, paletteTwo);
  compilePalette(paletteOne, paletteCOne);
  compilePalette(paletteTwo, paletteCTwo);
  
  // for debug
  /* size(palSize*8,16);
  noStroke();
  for(int i = 0; i < palSize; i++) {
    fill(paletteCOne[i]);
    rect(i*8,0,8,8);
    fill(paletteCTwo[i]);
    rect(i*8,8,8,8);
  } */
  
  return comparePalette(paletteCOne,paletteCTwo);
} 

void initPalette(PImage img, float[][] palette) {
  int red[] = new int[256];
  int green[] = new int[256];
  int blue[] = new int[256];
  img.loadPixels();
  
  for(int i = 0; i < 256; i++) {
    red[i] = 0;
    green[i] = 0;
    blue[i] = 0;
  }
  
  
  for(int i = 0; i < img.pixels.length; i++) {
    red[int(red(img.pixels[i]))]++;
    green[int(green(img.pixels[i]))]++;
    blue[int(blue(img.pixels[i]))]++;
  }
  
  for(int i = 1; i < 256; i++) {
    red[i] += red[i-1];
    green[i] += green[i-1];
    blue[i] += blue[i-1];
  }
  
  float redIncrement = float(red[255])/float(palSize+1);
  float greenIncrement = float(green[255])/float(palSize+1);
  float blueIncrement = float(blue[255])/float(palSize+1);
  float redCount = 0.0, greenCount = 0.0, blueCount = 0.0;
  int redPos = 0, greenPos = 0, bluePos = 0;
  int count;
  
  count = 0;
  while(count < 256 && redPos < palSize) {
    if(red[count] < redCount) { // find next increment
      count++;
    }
    else {
      redCount += redIncrement;
      palette[redPos][0] = count;
      redPos ++;
    }
  }
  
  count = 0;
  while(count < 256 && greenPos < palSize) {
    if(green[count] < greenCount) { // find next increment
      count++;
    }
    else {
      greenCount += greenIncrement;
      palette[greenPos][0] = count;
      greenPos ++;
    }
  }  
  
  count = 0;
  while(count < 256 && bluePos < palSize) {
    if(blue[count] < blueCount) { // find next increment
      count++;
    }
    else {
      blueCount += blueIncrement;
      palette[bluePos][0] = count;
      bluePos ++;
    }
  }    
  
  return;
}

// get difference between two palettes by finding the closest match
// for each color, and recording the total of the distances
// between all matches
float comparePalette(color[] palette1, color[] palette2) {
  int already[] = new int[palSize];
  for(int i = 0; i < palSize; i++) {
    already[i] = 0;
  }
  int q, current;
  float totalDistance = 0.0, minDistance, tmpDistance;
  for(int i = 0; i < palSize; i++) {
    q = 0;
    //while(already[q] != 0) q++; //uncomment for one-to-one palette matching
    current = q;
    minDistance = abs(red(palette1[i])-red(palette2[q])) + abs(green(palette1[i])-green(palette2[q])) + abs(blue(palette1[i])-blue(palette2[q]));
    for(int j = q+1; j < palSize; j++) {
      /*if(already[j] == 1) { //uncomment for one-to-one palette matching
        continue;
      }*/
      tmpDistance = abs(red(palette1[i])-red(palette2[j])) + abs(green(palette1[i])-green(palette2[j])) + abs(blue(palette1[i])-blue(palette2[j]));
      //minDistance = min(minDistance,tmpDistance);
      if(tmpDistance < minDistance) {
        current = j;
        minDistance = tmpDistance;
      }
    }
    already[current] = 1;
    noStroke();
    fill(palette1[i]);
    rect(i*8,0,8,8);
    fill(palette2[current]);
    rect(i*8,8,8,8);
    totalDistance += minDistance;
  }
  
  return totalDistance / (255*palSize*3); // normalize!
}

// used to copy a floating point value palette array to a color array
void compilePalette(float[][] floatPalette, color[] colorPalette) {
  for(int i = 0; i < palSize; i++) {
    colorPalette[i] = color(floor(floatPalette[i][0]),floor(floatPalette[i][1]),floor(floatPalette[i][2]));
  }
  
  return;
}

// nondeterministic kmeans function. generates a palette
void makePalette(PImage img, float[][] palette) {
  float paletteTmp[][] = new float[palSize][4];
  color tmpC;  
  img.loadPixels();
  // nondeterministic part. You can hack this to make it deterministic if you need
  /*for(int c = 0; c < palSize; c++) {
    tmpC = img.pixels[int(random(0,img.pixels.length))];
    palette[c][0] = red(tmpC);
    palette[c][1] = green(tmpC);
    palette[c][2] = blue(tmpC); 
  }*/
  
  initPalette(img,palette); // Dan's median slice nondeterministic initialization
  
  float cdist, tmpdist, sumdist, lastdist = -1.0;
  int currentColor;
  for(int i = 0; i < maxIterations; i++) {
    for(int c = 0; c < palSize; c++) {
    paletteTmp[c][0] = 0.0;
    paletteTmp[c][1] = 0.0;
    paletteTmp[c][2] = 0.0;
    paletteTmp[c][3] = 0.0;
    }
    sumdist = 0.0;
    for(int p = 0; p < img.pixels.length; p++) {
      tmpC = img.pixels[p];      
      cdist = abs(red(tmpC) - palette[0][0]) + abs(green(tmpC) - palette[0][1]) + abs(blue(tmpC) - palette[0][2]);
      currentColor = 0;
      for(int c = 1; c < palSize; c++) {
         tmpdist = abs(red(tmpC) - palette[c][0]) + abs(green(tmpC) - palette[c][1]) + abs(blue(tmpC) - palette[c][2]);
         if(tmpdist < cdist) {
           currentColor = c;
           cdist = tmpdist;
         }
      }
      sumdist += cdist;
      paletteTmp[currentColor][0] += red(tmpC);
      paletteTmp[currentColor][1] += green(tmpC);
      paletteTmp[currentColor][2] += blue(tmpC);
      paletteTmp[currentColor][3] ++;
    }
    sumdist /= img.pixels.length;
    for(int c = 0; c < palSize; c++) {
      if(paletteTmp[c][3] != 0.0) {
        palette[c][0] = paletteTmp[c][0] / paletteTmp[c][3];
        palette[c][1] = paletteTmp[c][1] / paletteTmp[c][3];
        palette[c][2] = paletteTmp[c][2] / paletteTmp[c][3];
      }
    }
    //print("dist:",sumdist," ");
    if(lastdist > 0) {
      //println("delta:",abs(sumdist - lastdist));
      if(abs(sumdist - lastdist) < deltaThreshold) {
        break;
      }
      lastdist = sumdist;
    }
    else {
      //println();
      lastdist = sumdist;
    } 
  }
  
  return;
}



