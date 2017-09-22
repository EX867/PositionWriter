import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CmdFileCreator extends PApplet {

public void setup() {
  if (args==null)System.exit(1);
  if (args.length!=2)System.exit(1);
  PrintWriter write=createWriter(args[0]);
  write.write(args[1]);
  write.flush();
  write.close();
  exit();
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CmdFileCreator" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
