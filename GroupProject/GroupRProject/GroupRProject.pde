/*
Group Red Project GUI


*/ 

import controlP5.*;
import java.nio.*;
import java.io.File;

ControlP5 cp5;

CheckBox checkbox;
ListBox l;
File dir;
File[] files;
ArrayList<String> imgFiles = new ArrayList<String>();
ArrayList<String> imgNames = new ArrayList<String>();
int functionIndex, imageCount = 0;
boolean onLoadImage = false, onLoadBest = false;
void setup() {
  size(1000, 700);
  smooth();
  dir = new File(dataPath("")); // set the data folder to hold files to search from
  getFilesOnStart();
  cp5 = new ControlP5(this);
  //sets up check boxes
  checkbox = cp5.addCheckBox("checkBox")
                .setPosition(25, 55)
                .setColorForeground(color(75,255,230))//light blue when hover
                .setColorBackground(color(255))
                .setColorActive(color(255,187,10)) //light orange when clicked
                .setColorLabel(color(255))
                .setSize(15, 15)
                .setItemsPerRow(1)
                .setSpacingColumn(20)
                .setSpacingRow(20)
                .addItem("0", 0) //calls a value which then will be assigned to a function call
                .addItem("1", 1)
                .addItem("2", 2)
                .addItem("3", 3)
                .addItem("4", 4)
                ;
                
   l = cp5.addListBox("imageList")
         .setPosition(0, 300)
         .setSize(200,300)
         .setItemHeight(20)
         .setBarHeight(20)
         .setColorBackground(color(255, 128,15))
         .setColorActive(color(255))
         .setColorForeground(color(255, 100,20))
         ;

  l.captionLabel().toUpperCase(true);
  l.captionLabel().set("  Images  ");
  l.captionLabel().setColor(color(255));
  l.captionLabel().style().marginTop = 3;
  l.valueLabel().style().marginTop = 3;
  
  //for (int i=0;i<10;i++) {
   // ListBoxItem lbi = l.addItem("item "+i, i);
    //lbi.setColorBackground(color(0,205,215));
  //}  

  // create a new button with name 'Load Image'
  cp5.addButton("LoadImage")
     .setLabel("      Load Image")
     .setValue(0)
     .setPosition(20,15)
     .setSize(150,25)
     .setColorForeground(color(225,155,180))// hover over
     .setColorBackground(color(255, 128,15)) //background
     .setColorActive(color(155)) //clicked
      ; 

// create a new button with name 'find Best match'
  cp5.addButton("FindBestMatch")
     .setLabel("      Find Best Match")
     .setValue(1)
     .setPosition(20,230)
     .setSize(150,25)
     .setColorForeground(color(225,155,180))// hover over
     .setColorBackground(color(255, 128,15)) //background
     .setColorActive(color(155)) //clicked
      ; 
}


void draw() {
  background(0);
  backgroundObjects();
  
  pushMatrix();//new layer to work on
  
  popMatrix(); //reverts back to base layer
}
void backgroundObjects(){
  fill(0);
  stroke(255);
  strokeWeight(2);
  //box in which shows image display area
  rect(200,0,800,700);
}
public void LoadImage(){
  if(onLoadImage == false){
    onLoadImage = true;
  }
  else{
    println("load button presssed");
    //open file explored to open file
    selectInput("Select a file to process:", "fileSelected");
  }
}
public void FindBestMatch(){
 if(onLoadBest == false){
   onLoadBest = true; 
 }
 else{
 println("find button pressed"); 
   int col = 0;
   for (int i=0;i<checkbox.getArrayValue().length;i++) {
     int n = (int)checkbox.getArrayValue()[i];
        if(n==1) {
          functionIndex= (int)checkbox.getItem(i).internalValue();
          callFunction(functionIndex);
        }
     } 
 }
}
void getFilesOnStart(){
   
  files = dir.listFiles();
  String path, name;
  
  for(int i = 0; i < files.length; i++) {
    path = files[i].getAbsolutePath();
    name = files[i].getName();
    if(path.toLowerCase().endsWith(".jpg") || path.toLowerCase().endsWith(".png")) {
      imgFiles.add(path);
      imgNames.add(name);
      println(files[i].getName());
      ListBoxItem lbi = l.addItem(files[i].getName(),i);
      lbi.setColorBackground(color(0,205,215));
    }
    else{
      
    }
  }
  for(int x = 0; x < imgNames.size(); x++){
    String file = imgNames.get(x);
    println("file being added: ", file);
     imageCount++;
  }
  return;   
   
}
void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
  }
  ListBoxItem lbi = l.addItem(selection.getName(), imageCount);
  lbi.setColorBackground(color(0,205,215));
  println(selection.getName());
  File toSave = saveFile(selection.getName());
  println(toSave);
  File dest = new File(savePath("/data/"), selection.getName());
  
  //.copy(selection.toPath(),dest.toPath());
  //if (!s) {
    // println("not moved");
  //}
  
}
void callFunction(int index){ //insert functions that corrolate to the check boxes
  switch(index) {
    case 0: 
      println("Zero");  // Does not execute
      doSomething();
      break;
    case 1: 
      println("One");  // Prints "One"
      break;
    case 2:
      println("two");
      break;
    case 3:
      println("three");
      break;
    case 4:
      println("four");
      break;
      
  }
}
void doSomething(){
 println("worst button clicked"); 
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(checkbox)) {
    //print("got an event from "+checkbox.getName()+"\t\n");
    // checkbox uses arrayValue to store the state of 
    // individual checkbox-items. usage:
    //println(checkbox.getArrayValue());
    int col = 0;
    for (int i=0;i<checkbox.getArrayValue().length;i++) {
      int n = (int)checkbox.getArrayValue()[i];
      if(n==1) {
        functionIndex= (int)checkbox.getItem(i).internalValue();
        //callFunction(functionIndex);
      }
    }   
  }
  
  if (theEvent.isGroup()) {
    // an event from a group e.g. scrollList
    println(theEvent.group().value()+" from "+theEvent.group());
  }
  
  if(theEvent.isGroup() && theEvent.name().equals("ImagesList")){
    int test = (int)theEvent.group().value();
    println("test "+test);
  }
}
void keyPressed() {
  
}
void checkBox(float[] a) {
  //println(a);
}
