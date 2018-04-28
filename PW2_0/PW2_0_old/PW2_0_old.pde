import java.nio.channels.FileChannel;
import java.util.*;
import java.io.*;
void setup() {
  convert("C:/Users/user/Documents/PositionWriter/led/ll", "C:/Users/user/Documents/PositionWriter/led/llcc", false);
  exit();
}
//d<element id="122" type="TYPE_TEXTBOX" x="400" y="50" w="380" h="35" description="" title="input path (folder)" text="" hint="C:/Users/user/Documents..." numberonly="false" textsize="20">MC_INPUT</element>
//<element id="123" type="TYPE_TEXTBOX" x="400" y="130" w="380" h="35" description="" title="output path (folder)" text="" hint="C:/Users/user/Documents..." numberonly="false" textsize="20">MC_OUTPUT</element>
//<element id="124" type="TYPE_BUTTON" x="842" y="50" w="45" h="35" description="mc to 10, or 10 to mc." text="mc->10" textsize="20">MC_MC10</element>
//<element id="125" type="TYPE_BUTTON" x="842" y="130" w="45" h="35" description="convert!" image="I_CONVERT.png">MC_CONVERT</element>
//<element id="126" type="TYPE_BUTTON" x="865" y="-35" w="25" h="25" description="exit frame." image="I_EXIT.png">MC_EXIT</element>
void convert(String input, String output, boolean direc) {
  File[] files=new File[0];
  int fileCount=0;
  println("---Conversion Started---");
  input=input.replace("\\", "/");
  output=output.replace("\\", "/");
  if (new File(input+"/keyLED").isDirectory()==false&&new File(input+"keyLED").isDirectory()==false) {
    println("[Warning (line : "+0+")] [ - ] no keyLED found.");
  } else {
    if (input.charAt(input.length()-1)=='/')files=listFiles(input+"keyLED/");
    else files=listFiles(input+"/keyLED/");
    int a=0;
    while (a<files.length) {
      BufferedReader read=createReader(files[a].getAbsolutePath());
      String current=files[a].getName();
      fileCount++;
      String buffer="";
      int b=1;
      try {
        String line=read.readLine();
        while (line!=null) {
          line=line.trim();
          String[] tokens=split(line, " ");
          int d=3;
          if (line.equals("")==false) {
            if (tokens[0].equals("on")||tokens[0].equals("off")||tokens[0].equals("o")||tokens[0].equals("f")) {//only watch first three arguments
              if (tokens.length<3) {
                println("[Error (line : "+b+")] ["+current+"] too few arguments. cannot convert this line!");
                d=1;
              } else {
                if (isInt(tokens[2])==false) {
                  println("[Error (line : "+b+")] ["+current+"] 3rd argument is not a number. conversion may not be correct!");
                }
                if (direc) {//mc to 10=================================================================================
                  if (tokens[1].equals("mc")) {
                    if (int(tokens[2])<1 || int(tokens[2])>32) {
                      println("[Warning (line : "+b+")] ["+current+"] mc number is out of range. line skipped.");
                      d=tokens.length;
                    } else {
                      Pos c=McToTen(new Pos(int(tokens[2]), 0, true));
                      if (c.x==-1) {
                        println("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                        d=tokens.length;
                      } else {
                        buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                        if (tokens.length==4&&(tokens[0].equals("on")||tokens[0].equals("o"))) {
                          buffer=buffer+" a";
                        }
                      }
                    }
                  }
                } else {//10 to mc=====================================================================================
                  if (tokens[1].equals("mc")) {
                    println("[Warning (line : "+b+")] ["+current+"] this is not pure 10*10 unipack file!(unitor mc pack) line skipped.");
                    d=tokens.length;
                  } else {
                    if (isInt(tokens[1])==false) {
                      println("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number. conversion may not be correct!");
                    }
                    Pos c=TenToMc(new Pos(int(tokens[2]), int(tokens[1]), false));
                    if (c.x==-1) {
                      println("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                      d=tokens.length;
                    } else {
                      if (c.mc) {
                        buffer=buffer+tokens[0]+" mc "+c.x;
                      } else {
                        buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                      }
                    }
                  }
                }
              }
            } else if (tokens[0].equals("mapping")) {
              if (direc) {//mc to 10=================================================================================
                if (tokens[2].equals("mc")) {
                  Pos c=McToTen(new Pos(int(tokens[3]), 0, true));
                  if (c.x==-1) {
                    println("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                    d=tokens.length;
                  } else {
                    buffer=buffer+tokens[0]+" "+tokens[1]+" "+c.y+" "+c.x;
                  }
                } else {
                  if (isInt(tokens[1])==false) {
                    println("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number. conversion may not be correct!");
                  }
                  Pos c=McToTen(new Pos(int(tokens[3]), int(tokens[2]), false));
                  if (c.x==-1) {
                    println("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                    d=tokens.length;
                  } else {
                    buffer=buffer+tokens[0]+" "+tokens[1]+" "+c.y+" "+c.x;
                  }
                }
              } else {//10 to mc=====================================================================================
                if (tokens[1].equals("mc")) {
                  println("[Warning (line : "+b+")] ["+current+"] this is not pure 10*10 unipack file!(unitor mc pack) line skipped.");
                  d=tokens.length;
                } else {
                  if (isInt(tokens[1])==false) {
                    println("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number. conversion may not be correct!");
                  }
                  Pos c=TenToMc(new Pos(int(tokens[2]), int(tokens[1]), false));
                  if (c.x==-1) {
                    println("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                    d=tokens.length;
                  } else {
                    if (c.mc) {
                      buffer=buffer+tokens[0]+" mc "+c.x;
                    } else {
                      buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                    }
                  }
                }
              }//======================================================================================================
            } else {
              buffer=buffer+tokens[0];
              d=1;
            }
            while (d<tokens.length) {
              buffer=buffer+" "+tokens[d];
              d=d+1;
            }
          }
          buffer=buffer+"\n";
          b++;
          line=read.readLine();
        }
        read.close();
        //convert filename [c y x l]
        String outputName=current;
        String[] fname=split(current, " ");
        if (fname.length==4||fname.length==5) {
          Pos c;
          if (direc)c=McToTen(new Pos(int(fname[2]), int(fname[1]), false));
          else c=TenToMc(new Pos(int(fname[2]), int(fname[1]), false));
          if (c.x==-1) {
            println("[Error (line : "+0+")] ["+current+"] position out of range, cannot convert.");
          } else {
            if (c.mc) {
              println("[Warning (line : "+0+")] ["+current+"] you cannot use mc on filename.");
            } else {
              if (fname.length==4)outputName=fname[0]+" "+c.y+" "+c.x+" "+fname[3];
              else outputName=fname[0]+" "+c.y+" "+c.x+" "+fname[3]+" "+fname[4];
            }
          }
        } else {
          println("[Error (line : "+0+")] ["+current+"] filename is not [c y x loop] or [c y x loop multi]. can't convert filename.");
        }
        println("[Read] "+str(a+1)+". "+current+" : Success! out : ("+outputName+")");
        File out;
        if (output.charAt(output.length()-1)=='/')out=new File(output+"keyLED/"+outputName);
        else out=new File(output+"/keyLED/"+outputName);
        boolean overwrite=false;
        if (out.exists())overwrite=true;
        PrintWriter write;
        if (output.charAt(output.length()-1)=='/')write=createWriter(output+"keyLED/"+outputName);
        else write=createWriter(output+"/keyLED/"+outputName);
        write.write(buffer);
        write.close();
        if (overwrite) {
          println("[Write] "+str(a+1)+". "+current+" : Success! out : ("+outputName+") <overwrited>");
        } else {
          println("[Write] "+str(a+1)+". "+current+" : Success! out : ("+outputName+")");
        }
      }
      catch(Exception e) {
        println("[Read] "+str(a+1)+". "+current+" : Failed!");
        println("[Error (line : "+0+")] ["+current+"] <Exception> : "+e.toString());
      }
      a=a+1;
    }
  }
  BufferedReader read;
  if (new File(input+"/keySound").isFile()==false&&new File(input+"keySound").isFile()==false) {
    println("[Warning (line : "+0+")] [ - ] no keySound found.");
  } else {
    if (input.charAt(input.length()-1)=='/')read=createReader(input+"keySound");
    else read=createReader(input+"/keySound");
    fileCount++;
    String current="keySound";
    String buffer="";
    int b=1;
    try {
      String line=read.readLine();
      while (line!=null) {
        line=line.trim();
        String[] tokens=split(line, " ");
        int d=3;
        if (line.equals("")==false) {
          if (tokens.length<3) {
            println("[Error (line : "+b+")] ["+current+"] too few arguments. cannot convert this line!");
            buffer=buffer+tokens[0];
            d=1;
          } else {
            if (isInt(tokens[1])==false) {
              println("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number. conversion may not be correct!");
            }
            if (isInt(tokens[2])==false) {
              println("[Error (line : "+b+")] ["+current+"] 3rd argument is not a number. conversion may not be correct!");
            }
            if (direc) {//mc to 10=================================================================================
              if (tokens[1].equals("mc")) {
                println("[Warning (line : "+b+")] ["+current+"] mc is not allowed in keySound.");
                d=tokens.length;
              } else {
                Pos c=McToTen(new Pos(int(tokens[2]), int(tokens[1]), false));
                if (c.x==-1) {
                  println("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                  d=tokens.length;
                } else {
                  buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                }
              }
            } else {//10 to mc=====================================================================================
              if (tokens[1].equals("mc")) {
                println("[Warning (line : "+b+")] ["+current+"] mc is not allowed in keySound.");
                d=tokens.length;
              } else {
                Pos c=TenToMc(new Pos(int(tokens[2]), int(tokens[1]), false));
                if (c.x==-1) {
                  println("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                  d=tokens.length;
                } else {
                  if (c.mc) {
                    //buffer=buffer+tokens[0]+" mc "+c.x;
                    println("[Warning (line : "+b+")] ["+current+"] mc is not allowed in keySound. line skipped.");
                  } else {
                    buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                  }
                }
              }
            }//======================================================================================================
          }
          while (d<tokens.length) {
            buffer=buffer+" "+tokens[d];
            d=d+1;
          }
        }
        buffer=buffer+"\n";
        b++;
        line=read.readLine();
      }
      read.close();
      println("[Read] "+fileCount+". "+current+" : Success!");
      File out;
      if (output.charAt(output.length()-1)=='/')out=new File(output+current);
      else out=new File(output+"/"+current);
      boolean overwrite=false;
      if (out.exists())overwrite=true;
      PrintWriter write;
      if (output.charAt(output.length()-1)=='/')write=createWriter(output+current);
      else write=createWriter(output+"/"+current);
      write.write(buffer);
      write.close();
      if (overwrite) {
        println("[Write] "+fileCount+". "+current+" : Success! <overwrited>");
      } else {
        println("[Write] "+fileCount+". "+current+" : Success!");
      }
    }
    catch(Exception e) {
      println("[Read] "+fileCount+". "+current+" : Failed!");
      println("[Error (line : "+0+")] ["+current+"] <Exception> : "+e.toString());
    }
  }
  if (new File(input+"/info").isFile()==false&&new File(input+"info").isFile()==false) {
    println("[Warning (line : "+0+")] [ - ] no info found.");
  } else {
    if (input.charAt(input.length()-1)=='/')read=createReader(input+"info");
    else read=createReader(input+"/info");
    fileCount++;
    String current="info";
    String buffer="";
    int b=1;
    try {
      String line=read.readLine();
      while (line!=null) {
        line=line.trim();
        String[] tokens=split(line, "=");
        int d=2;
        if (line.equals("")==false) {
          if (tokens.length<2) {
            println("[Warning (line : "+b+")] ["+current+"] this line does not contains \'=\'!");
            buffer=buffer+line;
          } else {
            while (d<tokens.length) {
              tokens[1]=tokens[1]+"="+tokens[d];
              d=d+1;
            }
            if (direc) {//mc to 10=================================================================================
              if (tokens[0].equals("buttonX")) {
                if (isInt(tokens[1])==false) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonX is not a number. conversion may not be correct!");
                } else if (int(tokens[1])!=8) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonX is not 8. this unipack is not correct mc unipack.");
                }
                buffer=buffer+"buttonX=10";
              } else if (tokens[0].equals("buttonY")) {
                if (isInt(tokens[1])==false) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonY is not a number. conversion may not be correct!");
                } else if (int(tokens[1])!=8) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonY is not 8. this unipack is not correct mc unipack.");
                }
                buffer=buffer+"buttonX=10";
              } else {
                buffer=buffer+line;
              }
            } else {//10 to mc=====================================================================================
              if (tokens[0].equals("buttonX")) {
                if (isInt(tokens[1])==false) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonX is not a number. conversion may not be correct!");
                } else if (int(tokens[1])!=8) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonX is not 10. this unipack is not correct 10*10 unipack.");
                }
                buffer=buffer+"buttonX=8";
              } else if (tokens[0].equals("buttonY")) {
                if (isInt(tokens[1])==false) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonsY is not a number. conversion may not be correct!");
                } else if (int(tokens[1])!=8) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonY is not 10. this unipack is not correct 10*10 unipack.");
                }
                buffer=buffer+"buttonX=8";
              } else {
                buffer=buffer+line;
              }
            }//======================================================================================================
          }
        }
        buffer=buffer+"\n";
        b++;
        line=read.readLine();
      }
      read.close();
      println("[Read] "+fileCount+". "+current+" : Success!");
      File out;
      if (output.charAt(output.length()-1)=='/')out=new File(output+current);
      else out=new File(output+"/"+current);
      boolean overwrite=false;
      if (out.exists())overwrite=true;
      PrintWriter write;
      if (output.charAt(output.length()-1)=='/')write=createWriter(output+current);
      else write=createWriter(output+"/"+current);
      write.write(buffer);
      write.close();
      if (overwrite) {
        println("[Write] "+fileCount+". "+current+" : Success! <overwrited>");
      } else {
        println("[Write] "+fileCount+". "+current+" : Success!");
      }
    }
    catch(Exception e) {
      println("[Read] "+fileCount+". "+current+" : Failed!");
      println("[Error (line : "+0+")] ["+current+"<Exception> : "+e.toString());
    }
    finally {
      try {
        read.close();
      }
      catch(Exception e) {
      }
    }
  }
  if (new File(input+"/sounds").isDirectory()==false&&new File(input+"sounds").isDirectory()==false) {
    println("[Warning (line : "+0+")] [ - ] no sounds found.");
  } else {
    if (input.charAt(input.length()-1)=='/')files=listFiles(input+"sounds/");
    else files=listFiles(input+"/sounds/");
    int a=0;
    while (a<files.length) {
      fileCount++;
      String current=files[a].getName();
      File out;
      if (output.charAt(output.length()-1)=='/')out=new File(output+"sounds/"+current);
      else out=new File(output+"/sounds/"+current);
      boolean overwrite=false;
      if (out.exists())overwrite=true;
      PrintWriter write=createWriter(out.getAbsolutePath());
      write.write("toFill");
      write.close();
      if (copyFile(files[a].getAbsolutePath(), out.getAbsolutePath())) {
        if (overwrite) {
          println("[Copy] "+fileCount+". "+current+" : Success! <overwrited>");
        } else {
          println("[Copy] "+fileCount+". "+current+" : Success!");
        }
      } else {
        if (overwrite) {
          println("[Copy] "+fileCount+". "+current+" : Failed! <overwrited>");
        } else {
          println("[Copy] "+fileCount+". "+current+" : Failed!");
        }
      }
      a=a+1;
    }
  }
  if (new File(input+"/autoPlay").isFile()==false&&new File(input+"autoPlay").isFile()==false) {
    println("[Warning (line : "+0+")] [ - ] no autoPlay found.");
  } else {
    if (input.charAt(input.length()-1)=='/')read=createReader(input+"autoPlay");
    else read=createReader(input+"/autoPlay");
    fileCount++;
    String current="autoPlay";
    String buffer="";
    int b=1;
    try {
      String line=read.readLine();
      while (line!=null) {
        line=line.trim();
        String[] tokens=split(line, " ");
        if (line.equals("")==false) {
          if (tokens[0].equals("on")||tokens[0].equals("off")||tokens[0].equals("o")||tokens[0].equals("f")) {//only watch first three arguments
            if (tokens.length<3&&tokens.length!=3) {//fix later
              println("[Error (line : "+b+")] ["+current+"] too few arguments. cannot convert this line!");
              buffer=buffer+tokens[0];
            } else {
              if (isInt(tokens[2])==false) { 
                println("[Error (line : "+b+")] ["+current+"] 3rd argument is not a number. conversion may\nnot be correct!");
              }
              if (direc) {//mc to 10=================================================================================
                if (tokens[1].equals("mc")) {
                  if (int(tokens[2])<1 || int(tokens[2])>32) {
                    println("[Warning (line : "+b+")] ["+current+"] mc number is out of range. line skipped.");
                  } else {
                    Pos c=McToTen(new Pos(int(tokens[2]), 0, true));
                    if (c.x==-1) {
                      println("[Error (line :"+b+")] ["+current+"] position out of range, cannot convert.");
                    } else {
                      buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                    }
                  }
                } else {
                  if (isInt(tokens[1])==false) {
                    println("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number. conversion may\nnot be correct!");
                  }
                  Pos c=McToTen(new Pos(int(tokens[2]), int(tokens[1]), false));
                  if (c.x==-1) {
                    println("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                  } else {
                    buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                  }
                }
              } else {//10 to mc=====================================================================================
                if (tokens[1].equals("mc")) {
                  println("[Warning (line : "+b+")] ["+current+"] this is not pure 10*10 unipack file!(unitor mc pack)\nline skipped.");
                } else {
                  if (isInt(tokens[1])==false) {
                    println("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number.\nconversion may not be correct!");
                  }
                  Pos c=TenToMc(new Pos(int(tokens[2]), int(tokens[1]), false));
                  if (c.x==-1) {
                    println("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                  } else {
                    if (c.mc) {
                      buffer=buffer+tokens[0]+" mc "+c.x;
                    } else {
                      buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                    }
                  }
                }
              }//======================================================================================================
            }
          } else {
            buffer=buffer+line;
          }
        }
        buffer=buffer+"\n";
        b++;
        line=read.readLine();
      }
      read.close();
      println("[Read] "+fileCount+". "+current+" : Success!");
      File out;
      if (output.charAt(output.length()-1)=='/')out=new File(output+current);
      else out=new File(output+"/"+current);
      boolean overwrite=false;
      if (out.exists())overwrite=true;
      PrintWriter write;
      if (output.charAt(output.length()-1)=='/')write=createWriter(output+current);
      else write=createWriter(output+"/"+current);
      write.write(buffer);
      write.close();
      if (overwrite) {
        println("[Write] "+fileCount+". "+current+" : Success! <overwrited>");
      } else {
        println("[Write] "+fileCount+". "+current+" : Success!");
      }
    }
    catch(Exception e) {
      println("[Read] "+fileCount+". "+current+" : Failed!");
      println("[Error (line : "+0+")] ["+current+"] <Exception> : "+e.toString());
    }
  }
  //println("[Warning (line : "+0+")] [keyLED] "+autoWarningCount+" of [on mc n vel]'s are converted into [on y x auto vel]. if this is right, ignore this.");
  if (direc)println("[ Mode : <Mc->10*10> ][ Files : "+fileCount+" ]---");
  else println("[ Mode : <10*10->Mc> ][ Files : "+fileCount+" ]---");
}
class Pos {
  int x;//x and mc
  int y;
  boolean mc;
  Pos(int x_, int y_, boolean mc_) {
    x=x_;
    y=y_;
    mc=mc_;
  }
  Pos() {
    x=0;
    y=0;
  }
  String toString() {
    return "["+x+" "+y+"]";
  }
}
void test() {
  int a=1;
  while (a<=10) {
    int b=1;
    while (b<=10) {
      print(TenToMc(new Pos(b, a, false))+" ");
      b=b+1;
    }
    println();
    a=a+1;
  }
  println();
  a=1;
  while (a<=8) {
    int b=1;
    while (b<=8) {
      print(McToTen(new Pos(b, a, false))+" ");
      b=b+1;
    }
    println();
    a=a+1;
  }
  a=1;
  while (a<=32) {
    print(McToTen(new Pos(a, 0, true))+" ");
    a=a+1;
  }
}
Pos TenToMc(Pos in) {
  if (2<=in.x&&in.x<=9&&2<=in.y&&in.y<=9) {
    return new Pos(in.x-1, in.y-1, false);
  }
  if (in.x==1&&2<=in.y&&in.y<=9) {
    return new Pos(34-in.y, 0, true);
  }
  if (in.x==10&&2<=in.y&&in.y<=9) {
    return new Pos(in.y+7, 0, true);
  }
  if (in.y==1&&2<=in.x&&in.x<=9) {
    return new Pos(in.x-1, 0, true);
  }
  if (in.y==10&&2<=in.x&&in.x<=9) {
    return new Pos(26-in.x, 0, true);
  }
  return new Pos(-1, 0, false);//ignore!
}
Pos McToTen(Pos in) {
  if (in.mc) {
    if (1<=in.x&&in.x<=8) {
      return new Pos(in.x+1, 1, false);
    }
    if (9<=in.x&&in.x<=16) {
      return new Pos(10, in.x-7, false);
    }
    if (17<=in.x&&in.x<=24) {
      return new Pos(26-in.x, 10, false);
    }
    if (25<=in.x&&in.x<=32) {
      return new Pos(1, 34-in.x, false);
    }
  } else {
    if (1<=in.x&&in.x<=8&&1<=in.y&&in.y<=8) {
      return new Pos(in.x+1, in.y+1, false);
    }
  }
  return new Pos(-1, 0, false);//ignore
}

boolean isAbsolutePath(String path) {//warning!!
  if (path.contains(":"))return true;
  else return false;
}

public static boolean isInt(String str) {
  if (str.equals("")) return false;
  if (str.length() > 9) return false;
  if (str.equals("-")) return false;
  // just int or float is needed!
  int a=0;
  if (str.charAt(0) == '-') a=1;
  while (a < str.length()) {
    if (!('0' <= str.charAt(a) && str.charAt(a) <= '9')) return false;
    a=a + 1;
  }
  return true;
}

boolean copyFile(String source, String target) {
  new File(target).getParentFile().mkdirs();
  FileInputStream inputStream=null;
  FileOutputStream outputStream=null;
  FileChannel fcin=null;
  FileChannel fcout=null;
  try {
    inputStream = new FileInputStream(source); 
    outputStream = new FileOutputStream(target);
    fcin = inputStream.getChannel(); 
    fcout = outputStream.getChannel();
    long size = fcin.size();
    fcin.transferTo(0, size, fcout);
  } 
  catch (Exception e) {
    e.printStackTrace();
  } 
  if (inputStream!=null) {
    try {
      inputStream.close();
    }
    catch(Exception e) {
    }
  } 
  if (outputStream!=null) {
    try {
      outputStream.close();
    }
    catch(Exception e) {
    }
  } 
  if (fcin!=null) {
    try {
      fcin.close();
    }
    catch(Exception e) {
    }
  } 
  if (fcout!=null) {
    try {
      fcout.close();
    }
    catch(Exception e) {
    }
  }
  return true;
}