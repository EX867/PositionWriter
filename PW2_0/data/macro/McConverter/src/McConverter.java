import java.nio.channels.FileChannel;
import java.util.*;
import java.io.*;
import kyui.element.*;
import kyui.core.*;
import kyui.util.*;
import processing.event.MouseEvent;
public class McConverter extends PW2_0.PwMacroApi {






public void setup() {
  CachingFrame frame;
  ImageButton convert;
  TextBox input;
  TextBox output;
  ToggleButton direction;
  if(KyUI.get("frame_converter")==null){
    println("creating new layer");
    frame=KyUI.getNewLayer().setAlpha(100);
    KyUI.rename(frame,"frame_converter");
    CenterFrameLayout l1=new CenterFrameLayout("l1");
    DivisionLayout l2=new DivisionLayout("l2");
    l2.rotation=Attributes.Rotation.UP;
    l2.mode=DivisionLayout.Behavior.PROPORTIONAL;
    l2.value=0.5F;
    l2.setPosition(new Rect(0,0,900,180));
    l1.setPosition(frame.pos.clone());
    l1.addChild(l2);
    frame.addChild(l1);
    //
    AlterLinearLayout l3=new AlterLinearLayout("l3");
    l3.padding=3;
    l2.addChild(l3);
    AlterLinearLayout l4=new AlterLinearLayout("l4");
    l2.addChild(l4);
    l4.padding=3;
    //
    //add input
    input=new TextBox("mc_input");
    input.title="input path (folder)";
    input.hint="C:/Users/user/Documents...";
    input.setNumberOnly(TextBox.NumberType.NONE);
    //
    //add output
    output=new TextBox("mc_output");
    output.title="output path (folder)";
    output.hint="C:/Users/user/Documents...";
    input.setNumberOnly(TextBox.NumberType.NONE);
    //
    //add direction
    direction=new ToggleButton("mc_direction");
    direction.text="mc->10";
    direction.textSize=20;
    direction.value=false;
    //
    //add convert
    convert=new ImageButton("mc_convert");
    convert.scaled=true;
    convert.padding=7;
    convert.setDescription("convert!");
    convert.image=loadImage("convert.png");
    //
    //add exit
    ImageButton exit=new ImageButton("mc_exit");
    exit.scaled=true;
    exit.padding=7;
    exit.image=loadImage("exit.png");
    exit.setPressListener((MouseEvent e,int index)->{
      KyUI.removeLayer();
      return false;
    });
    //
    //add all
    l3.addChild(input);
    l3.addChild(direction);
    l3.addChild(exit);
    l4.addChild(output);
    l4.addChild(convert);
    KyUI.taskManager.executeAll();  
    l3.set(input, AlterLinearLayout.LayoutType.STATIC, 1);
    l3.set(direction, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1);
    l3.set(exit, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1);
    l4.set(output, AlterLinearLayout.LayoutType.STATIC, 1);
    l4.set(convert, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 2);
    //
  }else{
    frame=(CachingFrame)KyUI.get("frame_converter");
    input=(TextBox)KyUI.get("mc_input");
    output=(TextBox)KyUI.get("mc_output");
    direction=(ToggleButton)KyUI.get("mc_direction");
    convert=(ImageButton)KyUI.get("mc_convert");
  }
  convert.setPressListener((MouseEvent e,int index)->{
    println("convert pressed");
    convert(input.getText(), output.getText(), direction.value);
    KyUI.removeLayer();
    return false;
  });
  KyUI.addLayer(frame);
  KyUI.changeLayout();
}
public void convert(String input, String output, boolean direc) {
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
                    if (Integer.parseInt(tokens[2])<1 || Integer.parseInt(tokens[2])>32) {
                      println("[Warning (line : "+b+")] ["+current+"] mc number is out of range. line skipped.");
                      d=tokens.length;
                    } else {
                      Pos c=McToTen(new Pos(Integer.parseInt(tokens[2]), 0, true));
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
                    Pos c=TenToMc(new Pos(Integer.parseInt(tokens[2]), Integer.parseInt(tokens[1]), false));
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
                  Pos c=McToTen(new Pos(Integer.parseInt(tokens[3]), 0, true));
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
                  Pos c=McToTen(new Pos(Integer.parseInt(tokens[3]), Integer.parseInt(tokens[2]), false));
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
                  Pos c=TenToMc(new Pos(Integer.parseInt(tokens[2]), Integer.parseInt(tokens[1]), false));
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
          if (direc)c=McToTen(new Pos(Integer.parseInt(fname[2]), Integer.parseInt(fname[1]), false));
          else c=TenToMc(new Pos(Integer.parseInt(fname[2]), Integer.parseInt(fname[1]), false));
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
        println("[Read] "+(a+1)+". "+current+" : Success! out : ("+outputName+")");
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
          println("[Write] "+(a+1)+". "+current+" : Success! out : ("+outputName+") <overwrited>");
        } else {
          println("[Write] "+(a+1)+". "+current+" : Success! out : ("+outputName+")");
        }
      }
      catch(Exception e) {
        println("[Read] "+(a+1)+". "+current+" : Failed!");
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
                Pos c=McToTen(new Pos(Integer.parseInt(tokens[2]), Integer.parseInt(tokens[1]), false));
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
                Pos c=TenToMc(new Pos(Integer.parseInt(tokens[2]), Integer.parseInt(tokens[1]), false));
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
                } else if (Integer.parseInt(tokens[1])!=8) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonX is not 8. this unipack is not correct mc unipack.");
                }
                buffer=buffer+"buttonX=10";
              } else if (tokens[0].equals("buttonY")) {
                if (isInt(tokens[1])==false) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonY is not a number. conversion may not be correct!");
                } else if (Integer.parseInt(tokens[1])!=8) {
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
                } else if (Integer.parseInt(tokens[1])!=8) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonX is not 10. this unipack is not correct 10*10 unipack.");
                }
                buffer=buffer+"buttonX=8";
              } else if (tokens[0].equals("buttonY")) {
                if (isInt(tokens[1])==false) {
                  println("[Warning (line : "+b+")] ["+current+"] buttonsY is not a number. conversion may not be correct!");
                } else if (Integer.parseInt(tokens[1])!=8) {
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
                  if (Integer.parseInt(tokens[2])<1 || Integer.parseInt(tokens[2])>32) {
                    println("[Warning (line : "+b+")] ["+current+"] mc number is out of range. line skipped.");
                  } else {
                    Pos c=McToTen(new Pos(Integer.parseInt(tokens[2]), 0, true));
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
                  Pos c=McToTen(new Pos(Integer.parseInt(tokens[2]), Integer.parseInt(tokens[1]), false));
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
                  Pos c=TenToMc(new Pos(Integer.parseInt(tokens[2]), Integer.parseInt(tokens[1]), false));
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
  public Pos(int x_, int y_, boolean mc_) {
    x=x_;
    y=y_;
    mc=mc_;
  }
  public Pos() {
    x=0;
    y=0;
  }
  public String toString() {
    return "["+x+" "+y+"]";
  }
}
public Pos TenToMc(Pos in) {
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
public Pos McToTen(Pos in) {
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

public boolean isAbsolutePath(String path) {//warning!!
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
}}