boolean R=true;
boolean sR;
ArrayList<String> error=new ArrayList<String>();
ArrayList<String> warning=new ArrayList<String>();
ArrayList<String> result=new ArrayList<String>();
//https://github.com/processing/processing/wiki/Export-Info-and-Tips
void setup() {
  size(700, 150);
  PFont font=createFont("SourceCodePro-Regular.ttf", 20);
  textFont(font);
  frameRate(50);
  imageMode(CENTER);
  loadImages();
  getPath();
  view=1;
  textTransfer=new TextTransfer(); 
  PImage titlebaricon = loadImage("icon.png");
  surface.setIcon(titlebaricon);
  surface.setTitle("ConvertMcTen - (v1.0 by EX867)");
}
String input=sketchPath();
String output=input;
String dataPath="";
void getPath() {//initialize save path by default, can overwrited by settings
  String[] tokens=split(sketchPath(), "\\");
  input="C:/Users/"+tokens[2]+"/Documents/Unipacks/";
  output="C:/Users/"+tokens[2]+"/Documents/Karnos/UnipackMc/";
  int a=0;
  while (a<tokens.length) {
    dataPath=dataPath+tokens[a]+"/";
    a=a+1;
  }
}
TextTransfer textTransfer;
int cursor=input.length();
boolean focus=true;//input
boolean mode=true;
int view=1;
boolean keyState=false;
boolean keyInit=false;
boolean mouseState=false;
int keyFrame=0;
String current;
void draw() {
  sR=true;
  if (view==1) {
    if (R) {
      background(225);
      fill(255);
      rect(10, 10, 590, 60);
      rect(10, 80, 590, 60);
      rect(610, 10, 80, 40);
      rect(610, 60, 80, 64);
      line(25, 10, 25, 140);
      fill(0);
      pushMatrix();
      textAlign(CENTER, CENTER);
      rotate(radians(270));
      textSize(15);
      text("input", -41, 15);//10, 30);
      text("output", -113, 15);//10, 85);
      popMatrix();
      textSize(15);
      pushMatrix();
      scale(2);
      image(img_result, 325/*650*/, 46/*92*/);
      popMatrix();
      if (mode)text("mc->10", 650, 30);
      else text("10->mc", 650, 30);
      text("by EX867", 650, 132);
      textAlign(LEFT, CENTER);
      text(input, 40, 35);
      text(output, 40, 108);
      if (focus) {
        if (frameCount%54<36)text("|", 36+textWidth(input.substring(0, min(input.length(), cursor))), 35);
        noFill();
        rect(30, 15, 565, 50);
      } else {
        if (frameCount%54<36)text("|", 36+textWidth(output.substring(0, min(output.length(), cursor))), 108);
        noFill();
        rect(30, 85, 565, 50);
      }
      textAlign(CENTER, CENTER);
    }
  } else {
    if (R) {
      background(225);
      textAlign(CENTER, CENTER);
      fill(255);
      //40 40 40 30->5 35 5 30 5 30 5 30 5
      rect(5, 5, 30, 30);
      rect(5, 40, 30, 30);
      rect(5, 75, 30, 30);
      rect(5, 110, 30, 35);
      image(img_result, 20, 20);
      image(img_error, 20, 55);
      image(img_warning, 20, 90);
      image(img_back, 20, 128);
      fill(255, 150);
      rect(5, 40, 30, 30);
      rect(5, 75, 30, 30);
      fill(0);
      textSize(25);
      text(error.size(), 20, 50);
      text(warning.size(), 20, 84);
    }
    ListView();
  }
  if (keyPressed) {
    sR=true;
    if (keyState==false) {
      keyFrame=frameCount;
      if (key==CODED) {
        if (keyCode==LEFT) {
          if (focus) {
            cursor=min(input.length(), max(0, cursor-1));
          } else {
            cursor=min(output.length(), max(0, cursor-1));
          }
        }
        if (keyCode==RIGHT) {
          if (focus) {
            cursor=min(input.length(), max(0, cursor+1));
          } else {
            cursor=min(output.length(), max(0, cursor+1));
          }
        }
      }
    }
    keyState=true;
    if (keyInit) {
      if (frameCount-keyFrame>1) {
        keyState=false;
      }
    } else {
      if (frameCount-keyFrame>20) {
        keyState=false;
        keyInit=true;
      }
    }
  } else {
    keyState=false;
    keyInit=false;
  }
  if (mousePressed) {
    sR=true;
    if (view==1) {
      if (610<mouseX&&mouseX<690) {
        if (10<mouseY&&mouseY<50) {
          fill(0, 50);
          rect(610, 10, 80, 40);
          if (mouseState==false) {
            if (mode)mode=false;
            else mode=true;
          }
        } else if (60<mouseY&&mouseY<140) {
          fill(0, 50);
          rect(610, 60, 80, 64);
          File file=new File(input);
          if (file.getAbsolutePath().equals(new File(output).getAbsolutePath())) {
            fill(0, 50);
            rect(0, 0, 700, 150);
            fill(0, 150);
            rect(10, 80, 590, 60);
            fill(255);
            text("printing in same place can make strange results!!", 305, 105);
          } else if (file.isDirectory()) {
            if (mouseState==false) {
              convert(mode);
              view=2;
              Object[] tobj=result.toArray();
              int b=0;
              View=new String[tobj.length];
              while (b<tobj.length) {
                View[b]=(String)tobj[b];
                b=b+1;
              }
            }
          } else {
            fill(0, 50);
            rect(0, 0, 700, 150);
            fill(0, 150);
            rect(10, 10, 590, 60);
            fill(255);
            text("check the input path!", 305, 35);
          }
        }
      } else {
        if (mouseY<75) {
          fill(0, 50);
          rect(10, 10, 590, 60);
          focus=true;
        } else {
          fill(0, 50);
          rect(10, 80, 590, 60);
          focus=false;
        }
      }
    } else {
      if (isMouseIsPressed(5, 5, 30, 30)) {
        fill(0, 50);
        rect(5, 5, 30, 30);
        if (mouseState==false) {
          FV_sliderPos=0;
          Object[] tobj=result.toArray();
          int b=0;
          View=new String[tobj.length];
          while (b<tobj.length) {
            View[b]=(String)tobj[b];
            b=b+1;
          }
        }
      } else if (isMouseIsPressed(5, 40, 30, 30)) {
        fill(0, 50);
        rect(5, 40, 30, 30);
        if (mouseState==false) {
          FV_sliderPos=0;
          Object[] tobj=error.toArray();
          int b=0;
          View=new String[tobj.length];
          while (b<tobj.length) {
            View[b]=(String)tobj[b];
            b=b+1;
          }
        }
      } else if (isMouseIsPressed(5, 75, 30, 30)) {
        fill(0, 50);
        rect(5, 75, 30, 30);
        if (mouseState==false) {
          FV_sliderPos=0;
          Object[] tobj=warning.toArray();
          int b=0;
          View=new String[tobj.length];
          while (b<tobj.length) {
            View[b]=(String)tobj[b];
            b=b+1;
          }
        }
      } else if (isMouseIsPressed(5, 110, 30, 35)) {
        fill(0, 50);
        rect(5, 110, 30, 35);
        view=1;
      }
    }
    mouseState=true;
  } else {
    mouseState=false;
    colorPress=0;
  }
  R=sR;
  sR=false;
}
@Override void exit() {
  super.exit();
}
void convert(boolean direc) {
  error.clear();
  warning.clear();
  File[] files=new File[0];
  int fileCount=0;
  result.add("---Conversion Started---");
  input=input.replace("\\", "/");
  output=output.replace("\\", "/");
  int autoWarningCount=0;
  if (new File(input+"/keyLED").isDirectory()==false&&new File(input+"keyLED").isDirectory()==false) {
    printError(2, 0, "-", "no keyLED found.");
  } else {
    if (input.charAt(input.length()-1)=='/')files=EX_listFiles(input+"keyLED/");
    else files=EX_listFiles(input+"/keyLED/");
    int a=0;
    while (a<files.length) {
      BufferedReader read=createReader(files[a].getAbsolutePath());
      current=files[a].getName();
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
                printError(1, b, current, "too few arguments. cannot convert this line!");
                buffer=buffer+tokens[0];
                d=1;
              } else {
                if (isNumber(tokens[2])==false) {
                  printError(1, b, current, "3rd argument is not a number. conversion may\nnot be correct!");
                }
                if (direc) {//mc to 10=================================================================================
                  if (tokens[1].equals("mc")) {
                    if (int(tokens[2])<1 || int(tokens[2])>32) {
                      printError(2, b, current, "mc number is out of range. line skipped.");
                      d=tokens.length;
                    } else {
                      Pos c=McToTen(new Pos(int(tokens[2]), 0, true));
                      if (c.x==-1) {
                        printError(1, b, current, "position out of range, cannot convert.");
                        d=tokens.length;
                      } else {
                        buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                        if (tokens.length==4&&(tokens[0].equals("on")||tokens[0].equals("o"))) {
                          //printError(2, b, current, "[on mc n vel] is converted into [on y x auto vel].\nif this is right, ignore this.");
                          autoWarningCount++;
                          buffer=buffer+" auto";
                        }
                      }
                    }
                  } else {
                    if (isNumber(tokens[1])==false) {
                      printError(1, b, current, "2nd argument is not a number. conversion may\nnot be correct!");
                    }
                    Pos c=McToTen(new Pos(int(tokens[2]), int(tokens[1]), false));
                    if (c.x==-1) {
                      printError(1, b, current, "position out of range, cannot convert.");
                      d=tokens.length;
                    } else {
                      buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                      if (tokens.length==4&&(tokens[0].equals("on")||tokens[0].equals("o"))) {
                        if (tokens[3].length()!=6) {
                          //printError(2, b, current, "[on y x vel] is converted into [on y x auto vel].\nif this is right, ignore this.");
                          autoWarningCount++;
                          buffer=buffer+" auto";
                        }
                      }
                    }
                  }
                } else {//10 to mc=====================================================================================
                  if (tokens[1].equals("mc")) {
                    printError(2, b, current, "this is not pure 10*10 unipack file!(unitor mc pack)\nline skipped.");
                    d=tokens.length;
                  } else {
                    if (isNumber(tokens[1])==false) {
                      printError(1, b, current, "2nd argument is not a number.\nconversion may not be correct!");
                    }
                    Pos c=TenToMc(new Pos(int(tokens[2]), int(tokens[1]), false));
                    if (c.x==-1) {
                      printError(1, b, current, "position out of range, cannot convert.");
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
              }
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
        if (fname.length!=4) {
          printError(2, 0, current, "filename is not [c y x loop]. can't convert filename.");
        } else {
          Pos c;
          if (mode)c=McToTen(new Pos(int(fname[2]), int(fname[1]), false));
          else c=TenToMc(new Pos(int(fname[2]), int(fname[1]), false));
          if (c.x==-1) {
            printError(2, 0, current, "position out of range, cannot convert.");
          } else {
            if (c.mc) {
              printError(2, 0, current, "you cannot use mc on filename.");
            } else {
              outputName=fname[0]+" "+c.y+" "+c.x+" "+fname[3];
            }
          }
        }
        //
        if (readFrame(buffer)==false) {
          result.add("[Read] "+str(a+1)+". "+current+" : Failed!");
        } else {
          result.add("[Read] "+str(a+1)+". "+current+" : Success! out : ("+outputName+")");
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
            result.add("[Write] "+str(a+1)+". "+current+" : Success! out : ("+outputName+") <overwrited>");
          } else {
            result.add("[Write] "+str(a+1)+". "+current+" : Success! out : ("+outputName+")");
          }
        }
      }
      catch(Exception e) {
        result.add("[Read] "+str(a+1)+". "+current+" : Failed!");
        printError(1, 0, current, "<Exception> : "+e.toString());
      }
      a=a+1;
    }
  }
  BufferedReader read;
  if (new File(input+"/keySound").isFile()==false&&new File(input+"keySound").isFile()==false) {
    printError(2, 0, "-", "no keySound found.");
  } else {
    if (input.charAt(input.length()-1)=='/')read=createReader(input+"keySound");
    else read=createReader(input+"/keySound");
    fileCount++;
    current="keySound";
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
            printError(1, b, current, "too few arguments. cannot convert this line!");
            buffer=buffer+tokens[0];
            d=1;
          } else {
            if (isNumber(tokens[1])==false) {
              printError(1, b, current, "2nd argument is not a number. conversion may not be correct!");
            }
            if (isNumber(tokens[2])==false) {
              printError(1, b, current, "3rd argument is not a number. conversion may not be correct!");
            }
            if (direc) {//mc to 10=================================================================================
              if (tokens[1].equals("mc")) {
                printError(2, b, current, "mc is not allowed in keySound.");
                d=tokens.length;
              } else {
                Pos c=McToTen(new Pos(int(tokens[2]), int(tokens[1]), false));
                if (c.x==-1) {
                  printError(1, b, current, "position out of range, cannot convert.");
                  d=tokens.length;
                } else {
                  buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                }
              }
            } else {//10 to mc=====================================================================================
              if (tokens[1].equals("mc")) {
                printError(2, b, current, "mc is not allowed in keySound.");
                d=tokens.length;
              } else {
                Pos c=TenToMc(new Pos(int(tokens[2]), int(tokens[1]), false));
                if (c.x==-1) {
                  printError(1, b, current, "position out of range, cannot convert.");
                  d=tokens.length;
                } else {
                  if (c.mc) {
                    //buffer=buffer+tokens[0]+" mc "+c.x;
                    printError(2, b, current, "mc is not allowed in keySound. line skipped.");
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
      if (readFrameKS(buffer)==false) {
        result.add("[Read] "+fileCount+". "+current+" : Failed!");
      } else {
        result.add("[Read] "+fileCount+". "+current+" : Success!");
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
          result.add("[Write] "+fileCount+". "+current+" : Success! <overwrited>");
        } else {
          result.add("[Write] "+fileCount+". "+current+" : Success!");
        }
      }
    }
    catch(Exception e) {
      result.add("[Read] "+fileCount+". "+current+" : Failed!");
      printError(1, 0, current, "<Exception> : "+e.toString());
    }
  }
  if (new File(input+"/info").isFile()==false&&new File(input+"info").isFile()==false) {
    printError(2, 0, "-", "no info found.");
  } else {
    if (input.charAt(input.length()-1)=='/')read=createReader(input+"info");
    else read=createReader(input+"/info");
    fileCount++;
    current="info";
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
            printError(2, b, current, "this line does not contains \'=\'!");
            buffer=buffer+line;
          } else {
            while (d<tokens.length) {
              tokens[1]=tokens[1]+"="+tokens[d];
              d=d+1;
            }
            if (direc) {//mc to 10=================================================================================
              if (tokens[0].equals("buttonX")) {
                if (isNumber(tokens[1])==false) {
                  printError(2, b, current, "buttonX is not a number. conversion may not be correct!");
                } else if (int(tokens[1])!=8) {
                  printError(2, b, current, "buttonX is not 8. this unipack is not correct mc unipack.");
                }
                buffer=buffer+"buttonX=10";
              } else if (tokens[0].equals("buttonY")) {
                if (isNumber(tokens[1])==false) {
                  printError(2, b, current, "buttonY is not a number. conversion may not be correct!");
                } else if (int(tokens[1])!=8) {
                  printError(2, b, current, "buttonY is not 8. this unipack is not correct mc unipack.");
                }
                buffer=buffer+"buttonX=10";
              } else {
                buffer=buffer+line;
              }
            } else {//10 to mc=====================================================================================
              if (tokens[0].equals("buttonX")) {
                if (isNumber(tokens[1])==false) {
                  printError(2, b, current, "buttonX is not a number. conversion may not be correct!");
                } else if (int(tokens[1])!=8) {
                  printError(2, b, current, "buttonX is not 10. this unipack is not correct 10*10 unipack.");
                }
                buffer=buffer+"buttonX=8";
              } else if (tokens[0].equals("buttonY")) {
                if (isNumber(tokens[1])==false) {
                  printError(2, b, current, "buttonsY is not a number. conversion may not be correct!");
                } else if (int(tokens[1])!=8) {
                  printError(2, b, current, "buttonY is not 10. this unipack is not correct 10*10 unipack.");
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
      if (readFrameInfo(buffer)==false) {
        result.add("[Read] "+fileCount+". "+current+" : Failed!");
      } else {
        result.add("[Read] "+fileCount+". "+current+" : Success!");
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
          result.add("[Write] "+fileCount+". "+current+" : Success! <overwrited>");
        } else {
          result.add("[Write] "+fileCount+". "+current+" : Success!");
        }
      }
    }
    catch(Exception e) {
      result.add("[Read] "+fileCount+". "+current+" : Failed!");
      printError(1, 0, current, "<Exception> : "+e.toString());
    }
  }
  if (new File(input+"/sounds").isDirectory()==false&&new File(input+"sounds").isDirectory()==false) {
    printError(2, 0, "-", "no sounds found.");
  } else {
    if (input.charAt(input.length()-1)=='/')files=EX_listFiles(input+"sounds/");
    else files=EX_listFiles(input+"/sounds/");
    int a=0;
    while (a<files.length) {
      fileCount++;
      current=files[a].getName();
      File out;
      if (output.charAt(output.length()-1)=='/')out=new File(output+"sounds/"+current);
      else out=new File(output+"/sounds/"+current);
      boolean overwrite=false;
      if (out.exists())overwrite=true;
      PrintWriter write=createWriter(out.getAbsolutePath());
      write.write("toFill");
      write.close();
      if (EX_fileCopy(files[a].getAbsolutePath(), out.getAbsolutePath())) {
        if (overwrite) {
          result.add("[Copy] "+fileCount+". "+current+" : Success! <overwrited>");
        } else {
          result.add("[Copy] "+fileCount+". "+current+" : Success!");
        }
      } else {
        if (overwrite) {
          result.add("[Copy] "+fileCount+". "+current+" : Failed! <overwrited>");
        } else {
          result.add("[Copy] "+fileCount+". "+current+" : Failed!");
        }
      }
      a=a+1;
    }
  }
  if (new File(input+"/autoPlay").isFile()==false&&new File(input+"autoPlay").isFile()==false) {
    printError(2, 0, "-", "no autoPlay found.");
  } else {
    if (input.charAt(input.length()-1)=='/')read=createReader(input+"autoPlay");
    else read=createReader(input+"/autoPlay");
    fileCount++;
    current="autoPlay";
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
              printError(1, b, current, "too few arguments. cannot convert this line!");
              buffer=buffer+tokens[0];
            } else {
              if (isNumber(tokens[2])==false) { 
                printError(1, b, current, "3rd argument is not a number. conversion may\nnot be correct!");
              }
              if (direc) {//mc to 10=================================================================================
                if (tokens[1].equals("mc")) {
                  if (int(tokens[2])<1 || int(tokens[2])>32) {
                    printError(2, b, current, "mc number is out of range. line skipped.");
                  } else {
                    Pos c=McToTen(new Pos(int(tokens[2]), 0, true));
                    if (c.x==-1) {
                      printError(1, b, current, "position out of range, cannot convert.");
                    } else {
                      buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                    }
                  }
                } else {
                  if (isNumber(tokens[1])==false) {
                    printError(1, b, current, "2nd argument is not a number. conversion may\nnot be correct!");
                  }
                  Pos c=McToTen(new Pos(int(tokens[2]), int(tokens[1]), false));
                  if (c.x==-1) {
                    printError(1, b, current, "position out of range, cannot convert.");
                  } else {
                    buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                  }
                }
              } else {//10 to mc=====================================================================================
                if (tokens[1].equals("mc")) {
                  printError(2, b, current, "this is not pure 10*10 unipack file!(unitor mc pack)\nline skipped.");
                } else {
                  if (isNumber(tokens[1])==false) {
                    printError(1, b, current, "2nd argument is not a number.\nconversion may not be correct!");
                  }
                  Pos c=TenToMc(new Pos(int(tokens[2]), int(tokens[1]), false));
                  if (c.x==-1) {
                    printError(1, b, current, "position out of range, cannot convert.");
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
      if (readFrameAP(buffer)==false) {
        result.add("[Read] "+fileCount+". "+current+" : Failed!");
      } else {
        result.add("[Read] "+fileCount+". "+current+" : Success!");
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
          result.add("[Write] "+fileCount+". "+current+" : Success! <overwrited>");
        } else {
          result.add("[Write] "+fileCount+". "+current+" : Success!");
        }
      }
    }
    catch(Exception e) {
      result.add("[Read] "+fileCount+". "+current+" : Failed!");
      printError(1, 0, current, "<Exception> : "+e.toString());
    }
  }
  printError(2, 0, "keyLED", autoWarningCount+" of [on mc n vel]'s are converted into [on y x auto vel].\nif this is right, ignore this.");
  if (mode)result.add("[ Mode : <Mc->10*10> ][ Files : "+fileCount+" ]---");
  else result.add("[ Mode : <10*10->Mc> ][ Files : "+fileCount+" ]---");
  result.add("[Result] : [ Error : "+error.size()+" ][ Warning : "+warning.size()+" ]---");
}
void keyPressed() {
  if (key == ESC) {
    key = 0;  // Fools! don't let them escape!
  }
}
void keyTyped() {
  sR=true;
  if (key==BACKSPACE) {
    if (focus) {
      if (input.length()>0&&cursor>0) {
        cursor=min(input.length(), max(0, cursor));
        input=input.substring(0, cursor-1)+input.substring(min(cursor, input.length()), input.length());
        cursor--;
      }
    } else {
      if (output.length()>0&&cursor>0) {
        cursor=min(output.length(), max(0, cursor));
        output=output.substring(0, cursor-1)+output.substring(min(cursor, output.length()), output.length());
        cursor--;
      }
    }
  } else if (key==DELETE) {
    if (focus) {
      cursor=min(input.length(), max(0, cursor));
      if (input.length()>0&&cursor<input.length()) {
        input=input.substring(0, cursor)+input.substring(min(cursor+1, input.length()), input.length());
      }
    } else {
      cursor=min(output.length(), max(0, cursor));
      if (output.length()>0&&cursor<=output.length()) {
        output=output.substring(0, cursor)+output.substring(min(cursor+1, output.length()), output.length());
      }
    }
  } else if (key==3) {//Ctrl-C
    if (view==1) {
      if (focus) {
        textTransfer.setClipboardContents(input);
      } else {
        textTransfer.setClipboardContents(output);
      }
    }
  } else if (key==22) {//Ctrl-V
    if (view==1) {
      if (focus) {
        if (cursor==input.length()) {
          input=input+textTransfer.getClipboardContents();
        } else {
          input=input.substring(0, cursor)+textTransfer.getClipboardContents()+input.substring(min(cursor, input.length()-1), input.length());
        }
      } else {
        if (cursor==output.length()) {
          output=output+textTransfer.getClipboardContents();
        } else {
          output=output.substring(0, cursor)+textTransfer.getClipboardContents()+output.substring(min(cursor, output.length()-1), output.length());
        }
      }
    }
  } else {
    if (focus) {
      cursor=min(input.length(), max(0, cursor));
      if (cursor==input.length()) {
        input=input+key;
      } else {
        input=input.substring(0, cursor)+key+input.substring(min(cursor, input.length()-1), input.length());
      }
      cursor++;
    } else {
      cursor=min(output.length(), max(0, cursor));
      if (cursor==output.length()) {
        output=output+key;
      } else {
        output=output.substring(0, cursor)+key+output.substring(min(cursor, output.length()-1), output.length());
      }
      cursor++;
    }
  }
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