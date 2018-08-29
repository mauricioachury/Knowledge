package BSE;

import java.awt.image.*;
import javax.imageio.*;
import javax.imageio.stream.FileImageOutputStream;
import javax.imageio.stream.FileImageInputStream;

import java.awt.geom.*;
import java.io.*;

public class RotateImage {

    /**
     * @param args
     */
    public static void main(String[] args) {
        // TODO Auto-generated method stub
        System.out.println("haha");
        try {
            /*BufferedImage image=ImageIO.read(myfile);
              AffineTransform tx = new AffineTransform();
              tx.translate(image.getHeight() / 2, image.getWidth() / 2);
              tx.rotate(Math.PI / 2);
              tx.translate(-image.getWidth() / 2,-image.getHeight() / 2);

              AffineTransformOp op = new AffineTransformOp(tx, AffineTransformOp.TYPE_NEAREST_NEIGHBOR);
              image = op.filter(image, null);
             */ 
              String myfile = "D:\\eclipse\\ws\\tt\\JDA_Logo.jpg";
              byte [] imageData2 = null;
              
              imageData2 = rotateImage(myfile, 90);
              
              String path="D:\\eclipse\\ws\\tt\\JDA_Logo2.jpg";
              File file2=new File(path);
              
              FileImageOutputStream outfile = new FileImageOutputStream(file2);
              
              outfile.write(imageData2, 0, imageData2.length);
              outfile.close();
              //ImageIO.write(image,"jpeg",  file);
            } 
            catch (IOException e) {
              e.printStackTrace();
            }
    }
    
    public static byte[] rotateImage(String PathToFile, int degree) {
        ByteArrayOutputStream rotatedImageStream = null;

        try {
              File myfile = new File(PathToFile);
              byte [] buf = new byte[1024];
              byte [] imageData = null;
              int numBytesRead = 0;
              FileImageInputStream input = new FileImageInputStream(myfile);
              ByteArrayOutputStream output = new ByteArrayOutputStream(); 
              while((numBytesRead = input.read(buf)) != -1) {
                 output.write(buf, 0, numBytesRead);
              }
              
              imageData = output.toByteArray();
              
              BufferedImage image = ImageIO.read(new ByteArrayInputStream(imageData));
              AffineTransform tf= new AffineTransform();
              tf.translate(image.getHeight() / 2, image.getWidth() / 2);
              tf.rotate(degree / 180.0 * Math.PI);
              tf.translate(-image.getWidth() / 2,-image.getHeight() / 2);
              
              AffineTransformOp rotationTransformOp = new AffineTransformOp(tf, AffineTransformOp.TYPE_NEAREST_NEIGHBOR); 
              BufferedImage rotatedImage = rotationTransformOp.filter(image, null); 
              
              rotatedImageStream = new ByteArrayOutputStream();
              ImageIO.write(rotatedImage, "png" , rotatedImageStream); 
        } catch (IOException e) {
            e.printStackTrace();
        }
        return rotatedImageStream.toByteArray();
    }
    
    public static byte[] rotateImage0(byte[] originalImageAsBytes , int degree) {
        ByteArrayOutputStream rotatedImageStream = null;

        try {
          BufferedImage image = ImageIO.read(new ByteArrayInputStream(originalImageAsBytes)); // read the original image
          AffineTransform tf= new AffineTransform();
           // last, width = height and height = width :)
              tf.translate(image.getHeight() / 2, image.getWidth() / 2);
              tf.rotate(degree / 180.0 * Math.PI);
              // first - center image at the origin so rotate works OK
              tf.translate(-image.getWidth() / 2,-image.getHeight() / 2);
          AffineTransformOp rotationTransformOp = 
            new AffineTransformOp(tf, AffineTransformOp.TYPE_NEAREST_NEIGHBOR); 
          BufferedImage rotatedImage = rotationTransformOp.filter(image, null); 

          rotatedImageStream = new ByteArrayOutputStream();
          ImageIO.write(rotatedImage, "png" , rotatedImageStream); 
        } catch (IOException e) {
            e.printStackTrace();
        }
        return rotatedImageStream.toByteArray();
    }
}
