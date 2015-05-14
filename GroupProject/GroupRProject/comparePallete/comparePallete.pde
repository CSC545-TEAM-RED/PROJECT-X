int NUMCOLORS = 100;
int ITERATIONS = 10; // K means iterations
float THRESH = 0.1;

//PImage img1,img2,img1K,img2K;
//
//void setup(){
//  String fileName ="Corgi.jpg";
//  String fileName2 = "Corgi8.jpg";
//  compareWrapper(fileName,fileName2);
//}
//void draw(){
////  if(displayPallete == true){
////    startX = 0;
////    startY = 0;
////    for(int i = 0; i < NUMCOLORS; i ++){
////      if(startX % 50 == 0){
////        startX = 0;
////        startY += 10;
////      }
////      fill(color(currentPallete[i][0],currentPallete[i][1],currentPallete[i][2]));
////      rect(startX,startY,10,10);
////      startX += 10;
////    }
////  }
//}
int[][] kMeansWrapper(String filename1){
  PImage img1 = loadImage(filename1);
  size(img1.width,img1.height);
  int[][] img1Data = new int[img1.width*img1.height][3];
  int[][] img1KData = img1Data;
  int[][] pallete1 = new int[NUMCOLORS][3];
  img1Data = getimgData(img1);
  pallete1 = initPallete(img1);
  img1KData = getPallete(img1Data,pallete1);
  //printData(pallete);
  img1K = applyPallete(img1Data,img1);
  //image(img1,0,0);
  return pallete1;
}
float compareWrapper(int[][] pallete1, int[][] pallete2){
  return comparePallete(pallete1,pallete2);
}  
  
int[][] getimgData(PImage img){
  // Puts all pixels of an image into an 2d array
  // Stored as [pixel number][R G B]
  float r,g,b;
  int index = 0;
  img.loadPixels();
  int[][] imgData = new int[img.pixels.length][3];
  for(int i = 0; i < img.pixels.length; i ++){
    r = red(img.pixels[i]);
    g = green(img.pixels[i]);
    b = blue(img.pixels[i]);
    imgData[index][0] = int(r);  // Red
    imgData[index][1] = int(g); // Green
    imgData[index][2] = int(b); // Blue
    index ++;
  }
  return imgData;
}
  
float getDist(int[] sample1, int[] sample2){
  // returns the ecludian distance of sample1 and sample2
  float dist;
  dist = sqrt(pow(sample2[0]-sample1[0],2) + pow(sample2[1]-sample1[1],2) 
    + pow(sample2[2]-sample1[2],2));
  return dist;
}
int lcd(int num){
  for(int i = 2 ; i < num; i ++){
    if(num % i == 0){
      return i;
    }
  }
  return num;
}
int getSamples(PImage img, int xIncr, int yIncr, int index, int[][] pallete){ 
  for(int y = yIncr; y < img.height; y += yIncr){
    for(int x = xIncr; x < img.width; x += xIncr){
      if(NUMCOLORS != index){
        pallete[index][0] = int(red(img.get(x,y)));
        pallete[index][1] = int(green(img.get(x,y)));
        pallete[index][2] = int(blue(img.get(x,y))); 
        //img.set(x,y,color(255,0,0));
        setRedBox(img, 5, x, y);
        index ++;
      }
    }
  }
 return index; 
}
int [][] initPallete(PImage img){
  // Generate NUMCOLORS of random colors from the pixels array
//  int index = 0;
//  int colorNum = 0;
//  int [][] pallete = new int[NUMCOLORS][3];
//  for(int i = 0 ; i < NUMCOLORS; i ++){
//    index = int(random(0,img.length));  // index of random color chosen
//    pallete[colorNum][0] = img[index][0];  // Store random color red value
//    pallete[colorNum][1] = img[index][1];  // same for green
//    pallete[colorNum][2] = img[index][2];  // and blue
//    colorNum += 1;
//  }
  int [][] pallete = new int[NUMCOLORS][3];
  int xIncr = ceil(img.width/(sqrt(NUMCOLORS)));
  int yIncr = ceil(img.height/(sqrt(NUMCOLORS)));
  int divisorX = 1;
  int divisorY = 1;
  int index = 0;

//  xIncr = xIncr - (xIncr/2);
//  yIncr = yIncr - (yIncr/2);
  
  if(NUMCOLORS == 1){
    divisorX = 2;
    divisorY = 2;
  }
  else if(NUMCOLORS == 2){ //sample two center of two halves
    divisorX = 2;
    divisorY = 1;
    xIncr = ceil(img.width)/2;
    yIncr = ceil(img.height)/2;
  }
  else{
    divisorX = lcd(NUMCOLORS);
    divisorY = lcd(NUMCOLORS);
  }
//  else if(NUMCOLORS % 2 != 0){
//    divisorX = 3;
//    divisorY = 3;
//  }
//  else if(NUMCOLORS % 2 == 0){
//    divisorX = 2;
//    divisorY = 2;
//  }
//  println("divisorX: ",divisorX);
//  println("divisorY: ",divisorY);
//  println("width: ",img.width);
//  println("height: ",img.height);
//  println("x: ",xIncr);
//  println("y: ",yIncr);
   
  index = getSamples(img, xIncr, yIncr, index, pallete);
  while(index != NUMCOLORS){
    index = getSamples(img,xIncr/2+xIncr,yIncr/2+yIncr,index,pallete);
  }
  
 // printData(pallete);
  return pallete;
}
void setRedBox(PImage img, int w, int x, int y){
  for(int i = x; i < x+5; i++){
    for(int j = y; j < y+5; j ++){
      img.set(i,j,color(255,0,0));
    }
  }
}
void printData(int[][] data){
  // prints the 2d array to the console for debug
  for(int i = 0; i < data.length; i ++){
    print(i, " ");
    for(int j = 0; j < data[i].length; j ++){
      print(data[i][j]," ");
    }
    println("");
  }
}
boolean palleteConverge(int[][] oldpallete,int [][] newpallete){
  // Finds the change (distance) between palletes and returns a true if the 
  // change is less than the global threshold value
  int changeR,changeG,changeB;
  for(int i = 0; i < newpallete.length; i ++){
    changeR = abs(oldpallete[i][0] - newpallete[i][0]);
    changeG = abs(oldpallete[i][1] - newpallete[i][1]);
    changeB = abs(oldpallete[i][2] - newpallete[i][2]);
    if(changeR < THRESH && changeG < THRESH && changeB < THRESH){
      return true;
    }
  }
  return false;
}
PImage applyPallete(int[][] pallete,PImage img){
  PImage result = createImage(img.width,img.height,RGB);
  int r,g,b;
  result.loadPixels();
  for(int i = 0; i < pallete.length; i ++){
    r = pallete[i][0];
    g = pallete[i][1];
    b = pallete[i][2];
    result.pixels[i] = color(r,g,b);
  }
  return result;
}
  
int[][] getPallete(int[][] imgData, int[][] pallete){
  // Applys the k means algorithim to create a color pallette stored in the global variable pallete
  // Also returns the modified kmeans image as a 2d array
  int[][] kmeansData = imgData;
  int totalRed,totalGreen,totalBlue,numMatches;
  int iterations = 0;
  float distance;
  float prevDist;
  boolean convergence = false;
  int[][] oldPallete = pallete;
  int [][] matches = new int [imgData.length][3];  // Stores the best pallete color for each pixel
  while(convergence != true && iterations != ITERATIONS){
    oldPallete = pallete;  // store for comparison later
    for(int i = 0; i < imgData.length; i ++){ // For each pixel in the image
      prevDist = getDist(imgData[i],pallete[0]); // Initialize comparing distances
      matches[i][0] = pallete[0][0];   // make it the current match
      matches[i][1] = pallete[0][1];
      matches[i][2] = pallete[0][2];
      for(int p = 1; p < pallete.length; p ++){ // For each pallete color
        distance = getDist(imgData[i],pallete[p]);
        if(distance < prevDist &&  matches[i][0] != pallete[p][0] && matches[i][1] != pallete[p][1]
          && matches[i][2] != pallete[p][2]){ // The the current pallete color is better...
          matches[i][0] = pallete[p][0];   // make it the current match
          matches[i][1] = pallete[p][1];
          matches[i][2] = pallete[p][2];
          prevDist = distance;
        }
      }
    }
    //printData(matches);
    // Calculate new palette
    for(int p = 0; p < pallete.length; p++){  // for each pallete color
      for(int i = 0; i < imgData.length; i ++){ // For each pixel
       totalRed = 0;
       totalGreen = 0;
       totalBlue = 0;
       numMatches = 0;
       if(matches[i][0] == pallete[p][0] && matches[i][1] == pallete[p][1] && 
         matches[i][2] == pallete[p][2]){  // If the pixel matched pallete p
           totalRed += matches[i][0];  // Keep a running total of the amount of r,g,b matched for 
           totalGreen += matches[i][1]; // that particular pallete
           totalBlue += matches[i][2];
           numMatches ++;
           kmeansData[i][0] = pallete[p][0];  // Apply the pallete to the new image
           kmeansData[i][1] = pallete[p][1];
           kmeansData[i][2] = pallete[p][2];
         }
       if(numMatches != 0){  // Possible the pallete did not match any color in the image
        totalRed = totalRed/numMatches;  // Take the average of r,g,b matched to pallete p
        totalGreen = totalGreen/numMatches;
        totalBlue = totalBlue/numMatches;
        pallete[p][0] = totalRed;   // Assign the existing pallete the new r,g,b pallete color
        pallete[p][1] = totalGreen;
        pallete[p][2] = totalBlue;
        // By now we have a new pallete color at location p in the pallete variable
       }
      }
    }
    convergence = palleteConverge(oldPallete,pallete);  // compare the pallete we just calculated with old pallete
    //println("convergence: ",convergence);
    iterations ++;
//    if(iterations == ITERATIONS){
//      println("Stopped on iterations");
//    }
//    if(convergence == true){
//      println("Stopped on convergence");
//    }
  }
  return kmeansData;
}
float comparePallete(int[][] pallete1, int[][] pallete2){
  // Compares the palletes by finding the closest matching color in pallete2 for each pallete1 color, then 
  // finds the difference between that match, for each color in pallete1, then averages the differences
  float prevDist;
  float dist;
  float[] distMatches = new float [NUMCOLORS];
  float total = 0;
  for(int p = 0; p < pallete1.length; p ++){   // for each color in pallete1
    prevDist = getDist(pallete1[p],pallete2[0]);  // initialize distance compare
    //println("prevDist: ",prevDist);
    distMatches[p] = prevDist;
    for(int p2 = 1; p2 < pallete2.length; p2++){
      dist = getDist(pallete1[p], pallete2[p2]);
      //println("dist: ",dist);
      if(dist < prevDist){  // We have found a better match
        distMatches[p] = dist;
        prevDist = dist;
      }
    }
  }
 // printArray(distMatches);
  // Now average all of the distances
  for(int i = 0; i < distMatches.length; i ++){
    total += distMatches[i];
  }
  //println("total: ",total);
  total = total/distMatches.length/(255 * sqrt(3));
  println("Percent Difference: ",total);
  return total;
}

//void keyPressed(){
//  if(key == '1'){
//    image(img1,0,0);
//    //displayPallete = false;
//  //  currentPallete = pallete1;
//  }
//  else if(key == '2'){
//    image(img1K,0,0);
//    //displayPallete = false;
//   // currentPallete = pallete1;
//  }
//  else if(key == '3'){
//    image(img2,0,0);
//    //displayPallete = false;
//   // currentPallete = pallete2;
//  }
//  else if(key == '4'){
//    image(img2K,0,0);
//    //displayPallete = false;
//   // currentPallete = pallete2;
//  }
//  else if(key == 'p'){
//    //displayPallete = true;
//  }
//}
