// size of palette - set to what you think is best
final int palSize = 5;
// max iteration of the kmeans function - don't let it get too high
final int maxIterations = 20;
// distance threshold before the function quits early
final float deltaThreshold = 0.1;

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
    while(already[q] != 0) q++;
    current = q;
    minDistance = abs(red(palette1[i])-red(palette2[q])) + abs(green(palette1[i])-green(palette2[q])) + abs(blue(palette1[i])-blue(palette2[q]));
    for(int j = q+1; j < palSize; j++) {
      if(already[j] == 1) { 
        continue;
      }
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
  for(int c = 0; c < palSize; c++) {
    tmpC = img.pixels[int(random(0,img.pixels.length))];
    palette[c][0] = red(tmpC);
    palette[c][1] = green(tmpC);
    palette[c][2] = blue(tmpC); 
  }
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
}



