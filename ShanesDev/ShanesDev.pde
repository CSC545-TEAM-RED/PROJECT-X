
import java.util.*;
import java.nio.*;
 
import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
import org.opencv.imgproc.Imgproc;
import org.opencv.features2d.Features2d;
import org.opencv.features2d.FeatureDetector;
//import org.opencv.flann.*;
import org.opencv.core.MatOfKeyPoint;
import org.opencv.features2d.KeyPoint;
 
final float DELTA = 10.0;
 
PImage cap;
 
byte [] bArray;
int [] iArray;
int pixCnt1, pixCnt2;
FeatureDetector detector;
 
void setup() {
  size(640, 480);
 
  background(0);
  // Define and initialise the default capture device.
  cap = loadImage("Corgi.jpg");
 
  // Load the OpenCV native library.
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);
 
  // pixCnt1 is the number of bytes in the pixel buffer.
  // pixCnt2 is the number of integers in the PImage pixels buffer.
  pixCnt1 = width*height*4;
  pixCnt2 = width*height;
 
  // bArray is the temporary byte array buffer for OpenCV cv::Mat.
  // iArray is the temporary integer array buffer for PImage pixels.
  bArray = new byte[pixCnt1];
  iArray = new int[pixCnt2];
  detector = FeatureDetector.create(FeatureDetector.STAR);
  noFill();
  stroke(255, 255, 0, 180);
}
 
void draw() {
  cap.loadPixels();
  image(cap, 0, 0);
 
  // Copy the webcam image to the temporary integer array iArray.
  arrayCopy(cap.pixels, iArray);
 
  // Define the temporary Java byte and integer buffers. 
  // They share the same storage.
  ByteBuffer bBuf = ByteBuffer.allocate(pixCnt1);
  IntBuffer iBuf = bBuf.asIntBuffer();
 
  // Copy the webcam image to the byte buffer iBuf.
  iBuf.put(iArray);
 
  // Copy the webcam image to the byte array bArray.
  bBuf.get(bArray);
 
  // Create the OpenCV cv::Mat.
  Mat m1 = new Mat(height, width, CvType.CV_8UC4);
 
  // Initialise the matrix m1 with content from bArray.
  m1.put(0, 0, bArray);
  // Prepare the grayscale matrix.
  Mat m3 = new Mat(height, width, CvType.CV_8UC1);
  Imgproc.cvtColor(m1, m3, Imgproc.COLOR_BGRA2GRAY);
 
  MatOfKeyPoint keypoints = new MatOfKeyPoint();
  detector.detect(m3, keypoints);
 
  KeyPoint [] points = keypoints.toArray();
  ArrayList<KeyPoint> pList = new ArrayList<KeyPoint>();
  pList.add(points[0]);
  // Remove the keypoints that are close together.
  for (int i=1; i<points.length; i++) {
    boolean done = true;
    for (int j=0; j<pList.size(); j++) {
      float d = dist((float)points[i].pt.x, (float)points[i].pt.y, 
      (float)pList.get(j).pt.x, (float)pList.get(j).pt.y);
      if (d > DELTA) {
        continue;
      } 
      else {
        done = false;
      }
    }
    if (done) {
      pList.add(points[i]);
    }
  }
 
  for (int i=0; i<pList.size(); i++) {
    ellipse((float)pList.get(i).pt.x, (float)pList.get(i).pt.y, pList.get(i).size, pList.get(i).size);
    if (pList.get(i).angle != -1) {
      float angle = 360.0 - pList.get(i).angle;
      float tx = (float)pList.get(i).pt.x + pList.get(i).size*cos(radians(angle))/2.0;
      float ty = (float)pList.get(i).pt.y + pList.get(i).size*sin(radians(angle))/2.0;
      line(tx, ty, (float)pList.get(i).pt.x, (float)pList.get(i).pt.y);
    }
  }
  keypoints.release();
}

void keyReleased() {
  if (key == 'c') {
    cap = loadImage("Corgi.jpg");
  } else if (key == 'b') {
    cap = loadImage("color.jpg");
  }
  size(cap.width, cap.height);
}
