import java.nio.*;
import java.util.*;
import org.opencv.core.*;
import org.opencv.features2d.*;
import org.opencv.imgproc.Imgproc;


float keyPointCompare(PImage img1, PImage img2) {
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  
  FeatureDetector detector = FeatureDetector.create(FeatureDetector.ORB);


  // bArray is the temporary byte array buffer for OpenCV cv::Mat.
  // iArray is the temporary integer array buffer for PImage pixels.
  byte[] bArrayImg1 = new byte[img1.width*img1.height*4];
  int[] iArrayImg1 = new int[img1.width*img1.height];
  img1.loadPixels();
  byte[] bArrayImg2 = new byte[img2.width*img2.height*4];
  int[] iArrayImg2 = new int[img2.width*img2.height];
  img2.loadPixels();

  // Copy the webcam image to the temporary integer array iArray.
  arrayCopy(img1.pixels, iArrayImg1);
  arrayCopy(img2.pixels, iArrayImg2);

  // Define the temporary Java byte and integer buffers.
  // They share the same storage.
  ByteBuffer bBufImg1 = ByteBuffer.allocate(img1.width*img1.height*4);
  IntBuffer iBufImg1 = bBufImg1.asIntBuffer();
  ByteBuffer bBufImg2 = ByteBuffer.allocate(img2.width*img2.height*4);
  IntBuffer iBufImg2 = bBufImg2.asIntBuffer();

  // Copy the webcam image to the byte buffer iBuf.
  iBufImg1.put(iArrayImg1);
  iBufImg2.put(iArrayImg2);

  // Copy the webcam image to the byte array bArray.
  bBufImg1.get(bArrayImg1);
  bBufImg2.get(bArrayImg2);

  // Create the OpenCV cv::Mat.
  Mat m1Img1 = new Mat(img1.height, img1.width, CvType.CV_8UC4);
  Mat m1Img2 = new Mat(img2.height, img2.width, CvType.CV_8UC4);

  // Initialise the matrix m1 with content from bArray.
  m1Img1.put(0, 0, bArrayImg1);
  m1Img2.put(0, 0, bArrayImg2);
  // Prepare the grayscale matrix.
  Mat m3Img1 = new Mat(img1.height, img1.width, CvType.CV_8UC1);
  Imgproc.cvtColor(m1Img1, m3Img1, Imgproc.COLOR_BGRA2GRAY);
  Mat m3Img2 = new Mat(img2.height, img2.width, CvType.CV_8UC1);
  Imgproc.cvtColor(m1Img2, m3Img2, Imgproc.COLOR_BGRA2GRAY);

  MatOfKeyPoint keypointsImg1 = new MatOfKeyPoint();
  detector.detect(m3Img1, keypointsImg1);
  MatOfKeyPoint keypointsImg2 = new MatOfKeyPoint();
  detector.detect(m3Img2, keypointsImg2);

  List<KeyPoint> keypointsListImg1 = keypointsImg1.toList();
  List<KeyPoint> keypointsListImg2 = keypointsImg2.toList();

  Mat descriptorsImg1 = new Mat();
  Mat descriptorsImg2 = new Mat();

  DescriptorExtractor extractor = DescriptorExtractor.create(DescriptorExtractor.BRISK);
  extractor.compute(m3Img1, keypointsImg1, descriptorsImg1);
  extractor.compute(m3Img2, keypointsImg2, descriptorsImg2);

  List<MatOfDMatch> matches = new ArrayList<MatOfDMatch>();

  DescriptorMatcher matcher = DescriptorMatcher.create(DescriptorMatcher.BRUTEFORCE_HAMMING);
  //matcher.match(descriptorsImg1, descriptorsImg2, matches);
  try {
    matcher.knnMatch(descriptorsImg1, descriptorsImg2, matches, 2);
  } catch (Exception e) {
    // OpenCV throwing an exception? Give up and return the max distance.
    return 1;
  }

  MatOfDMatch matchesFiltered = new MatOfDMatch();

  //List<DMatch> matchesList = matches.toList();
  //List<DMatch> bestMatches = new ArrayList<DMatch>();

  List<DMatch> goodMatches = new ArrayList<DMatch>();
  // Ratio Test
  for (int matchIdx = 0; matchIdx < matches.size(); ++matchIdx)
  {
    float ratio = 0.8; // As in Lowe's paper (can be tuned)
    DMatch[] theMatch = matches.get(matchIdx).toArray();
    if (theMatch.length >= 2 && theMatch[0].distance < ratio * theMatch[1].distance)
    {
      goodMatches.add(theMatch[0]);
    }
  }

  if (goodMatches.size() == 0) {
    // No good matches? Return the max distance.
    return 1;
  }

  double max_dist = 0.0;
  double min_dist = 100.0;
  double sum_dist = 0;

  for (int i = 0; i < goodMatches.size(); i++) {
    double dist = (double) goodMatches.get(i).distance;

    if (dist < min_dist && dist != 0) {
      min_dist = dist;
    }

    if (dist > max_dist) {
      max_dist = dist;
    }

    sum_dist += dist;
  }

  /*System.out.println("max_dist : " + max_dist);
  System.out.println("min_dist : " + min_dist);
  System.out.println("avg_dist : " + (sum_dist / goodMatches.size()));*/

 /*
  KeyPoint [] pointsImg1 = keypointsImg1.toArray();
  ArrayList<KeyPoint> pListImg1 = new ArrayList<KeyPoint>();
  pListImg1.add(pointsImg1[0]);

  // Remove the keypoints that are close together.
  for (int i=1; i<pointsImg1.length; i++) {
    boolean done = true;
    for (int j=0; j<pListImg1.size(); j++) {
      float d = dist((float)pointsImg1[i].pt.x, (float)pointsImg1[i].pt.y,
      (float)pListImg1.get(j).pt.x, (float)pListImg1.get(j).pt.y);
      if (d > DELTA) {
        continue;
      }
      else {
        done = false;
      }
    }
    if (done) {
      pListImg1.add(pointsImg1[i]);
    }
  }

  for (int i=0; i<pListImg1.size(); i++) {
    ellipse((float)pListImg1.get(i).pt.x, (float)pListImg1.get(i).pt.y, pListImg1.get(i).size, pListImg1.get(i).size);
    if (pListImg1.get(i).angle != -1) {
      float angle = 360.0 - pListImg1.get(i).angle;
      float tx = (float)pListImg1.get(i).pt.x + pListImg1.get(i).size*cos(radians(angle))/2.0;
      float ty = (float)pListImg1.get(i).pt.y + pListImg1.get(i).size*sin(radians(angle))/2.0;
      line(tx, ty, (float)pListImg1.get(i).pt.x, (float)pListImg1.get(i).pt.y);
    }
  }
  keypointsImg1.release();*/
  return (float)(sum_dist / goodMatches.size()) / 166.0f; // 166 seems to be the upper-limit, but who knows?
}

