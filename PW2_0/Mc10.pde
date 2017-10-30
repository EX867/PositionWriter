McConverter mcConverter=new McConverter();
class McConverter {
  class ThreadConverter implements Runnable {
    String input;
    String output;
    boolean direc;
    int id;
    ThreadConverter(String input_, String output_, boolean direc_, int id_) {
      input=input_;
      output=output_;
      direc=direc_;
      id=id_;
    }
    @Override
      void run() {
      mcConverter.convert(input, output, direc, id);
    }
  }
  void convert(String input, String output, boolean direc, int id) {
    surface.setTitle(title_filename+title_edited+title_suffix+" - converting start...");
    Logger logui=((Logger)UI[getUIid("LOG_LOG")]);
    File[] files=new File[0];
    int fileCount=0;
    logui.logs.add("---Conversion Started---");
    input=input.replace("\\", "/");
    output=output.replace("\\", "/");
    int autoWarningCount=0;
    if (new File(input+"/keyLED").isDirectory()==false&&new File(input+"keyLED").isDirectory()==false) {
      logui.logs.add("[Warning (line : "+0+")] [ - ] no keyLED found.");
    } else {
      if (input.charAt(input.length()-1)=='/')files=listFiles(input+"keyLED/");
      else files=listFiles(input+"/keyLED/");
      int a=0;
      while (a<files.length) {
        surface.setTitle(title_filename+title_edited+title_suffix+" - converting... "+files[a].getAbsolutePath());
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
                  logui.logs.add("[Error (line : "+b+")] ["+current+"] too few arguments. cannot convert this line!");
                  buffer=buffer+tokens[0];
                  d=1;
                } else {
                  if (isInt(tokens[2])==false) {
                    logui.logs.add("[Error (line : "+b+")] ["+current+"] 3rd argument is not a number. conversion may not be correct!");
                  }
                  if (direc) {//mc to 10=================================================================================
                    if (tokens[1].equals("mc")) {
                      if (int(tokens[2])<1 || int(tokens[2])>32) {
                        logui.logs.add("[Warning (line : "+b+")] ["+current+"] mc number is out of range. line skipped.");
                        d=tokens.length;
                      } else {
                        Pos c=McToTen(new Pos(int(tokens[2]), 0, true));
                        if (c.x==-1) {
                          logui.logs.add("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                          d=tokens.length;
                        } else {
                          buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                          if (tokens.length==4&&(tokens[0].equals("on")||tokens[0].equals("o"))) {
                            buffer=buffer+" auto";
                          }
                        }
                      }
                    } else {//10 to mc=====================================================================================
                      if (tokens[1].equals("mc")) {
                        logui.logs.add("[Warning (line : "+b+")] ["+current+"] this is not pure 10*10 unipack file!(unitor mc pack) line skipped.");
                        d=tokens.length;
                      } else {
                        if (isInt(tokens[1])==false) {
                          logui.logs.add("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number. conversion may not be correct!");
                        }
                        Pos c=TenToMc(new Pos(int(tokens[2]), int(tokens[1]), false));
                        if (c.x==-1) {
                          logui.logs.add("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
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
                }
              } else if (tokens[0].equals("mapping")) {
                if (direc) {//mc to 10=================================================================================
                  if (tokens[2].equals("mc")) {
                    Pos c=McToTen(new Pos(int(tokens[3]), 0, true));
                    if (c.x==-1) {
                      logui.logs.add("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                      d=tokens.length;
                    } else {
                      buffer=buffer+tokens[0]+" "+tokens[1]+" "+c.y+" "+c.x;
                    }
                  } else {
                    if (isInt(tokens[1])==false) {
                      logui.logs.add("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number. conversion may not be correct!");
                    }
                    Pos c=McToTen(new Pos(int(tokens[3]), int(tokens[2]), false));
                    if (c.x==-1) {
                      logui.logs.add("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                      d=tokens.length;
                    } else {
                      buffer=buffer+tokens[0]+" "+tokens[1]+" "+c.y+" "+c.x;
                    }
                  }
                } else {//10 to mc=====================================================================================
                  if (tokens[1].equals("mc")) {
                    logui.logs.add("[Warning (line : "+b+")] ["+current+"] this is not pure 10*10 unipack file!(unitor mc pack) line skipped.");
                    d=tokens.length;
                  } else {
                    if (isInt(tokens[1])==false) {
                      logui.logs.add("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number. conversion may not be correct!");
                    }
                    Pos c=TenToMc(new Pos(int(tokens[2]), int(tokens[1]), false));
                    if (c.x==-1) {
                      logui.logs.add("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
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
              logui.logs.add("[Error (line : "+0+")] ["+current+"] position out of range, cannot convert.");
            } else {
              if (c.mc) {
                logui.logs.add("[Warning (line : "+0+")] ["+current+"] you cannot use mc on filename.");
              } else {
                if (fname.length==4)outputName=fname[0]+" "+c.y+" "+c.x+" "+fname[3];
                else outputName=fname[0]+" "+c.y+" "+c.x+" "+fname[3]+" "+fname[4];
              }
            }
          } else {
            logui.logs.add("[Error (line : "+0+")] ["+current+"] filename is not [c y x loop] or [c y x loop multi]. can't convert filename.");
          }
          //
          if (/*readFrame(buffer)==*/false) {
            logui.logs.add("[Read] "+str(a+1)+". "+current+" : Failed!");
          } else {
            logui.logs.add("[Read] "+str(a+1)+". "+current+" : Success! out : ("+outputName+")");
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
              logui.logs.add("[Write] "+str(a+1)+". "+current+" : Success! out : ("+outputName+") <overwrited>");
            } else {
              logui.logs.add("[Write] "+str(a+1)+". "+current+" : Success! out : ("+outputName+")");
            }
          }
        }
        catch(Exception e) {
          logui.logs.add("[Read] "+str(a+1)+". "+current+" : Failed!");
          logui.logs.add("[Error (line : "+0+")] ["+current+"] <Exception> : "+e.toString());
        }
        a=a+1;
      }
    }
    BufferedReader read;
    surface.setTitle(title_filename+title_edited+title_suffix+" - converting... keySound");
    if (new File(input+"/keySound").isFile()==false&&new File(input+"keySound").isFile()==false) {
      logui.logs.add("[Warning (line : "+0+")] [ - ] no keySound found.");
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
              logui.logs.add("[Error (line : "+b+")] ["+current+"] too few arguments. cannot convert this line!");
              buffer=buffer+tokens[0];
              d=1;
            } else {
              if (isInt(tokens[1])==false) {
                logui.logs.add("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number. conversion may not be correct!");
              }
              if (isInt(tokens[2])==false) {
                logui.logs.add("[Error (line : "+b+")] ["+current+"] 3rd argument is not a number. conversion may not be correct!");
              }
              if (direc) {//mc to 10=================================================================================
                if (tokens[1].equals("mc")) {
                  logui.logs.add("[Warning (line : "+b+")] ["+current+"] mc is not allowed in keySound.");
                  d=tokens.length;
                } else {
                  Pos c=McToTen(new Pos(int(tokens[2]), int(tokens[1]), false));
                  if (c.x==-1) {
                    logui.logs.add("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                    d=tokens.length;
                  } else {
                    buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                  }
                }
              } else {//10 to mc=====================================================================================
                if (tokens[1].equals("mc")) {
                  logui.logs.add("[Warning (line : "+b+")] ["+current+"] mc is not allowed in keySound.");
                  d=tokens.length;
                } else {
                  Pos c=TenToMc(new Pos(int(tokens[2]), int(tokens[1]), false));
                  if (c.x==-1) {
                    logui.logs.add("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                    d=tokens.length;
                  } else {
                    if (c.mc) {
                      //buffer=buffer+tokens[0]+" mc "+c.x;
                      logui.logs.add("[Warning (line : "+b+")] ["+current+"] mc is not allowed in keySound. line skipped.");
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
        if (/*readFrameKS(buffer)==*/false) {
          logui.logs.add("[Read] "+fileCount+". "+current+" : Failed!");
        } else {
          logui.logs.add("[Read] "+fileCount+". "+current+" : Success!");
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
            logui.logs.add("[Write] "+fileCount+". "+current+" : Success! <overwrited>");
          } else {
            logui.logs.add("[Write] "+fileCount+". "+current+" : Success!");
          }
        }
      }
      catch(Exception e) {
        logui.logs.add("[Read] "+fileCount+". "+current+" : Failed!");
        logui.logs.add("[Error (line : "+0+")] ["+current+"] <Exception> : "+e.toString());
      }
    }
    surface.setTitle(title_filename+title_edited+title_suffix+" - converting... info");
    if (new File(input+"/info").isFile()==false&&new File(input+"info").isFile()==false) {
      logui.logs.add("[Warning (line : "+0+")] [ - ] no info found.");
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
              logui.logs.add("[Warning (line : "+b+")] ["+current+"] this line does not contains \'=\'!");
              buffer=buffer+line;
            } else {
              while (d<tokens.length) {
                tokens[1]=tokens[1]+"="+tokens[d];
                d=d+1;
              }
              if (direc) {//mc to 10=================================================================================
                if (tokens[0].equals("buttonX")) {
                  if (isInt(tokens[1])==false) {
                    logui.logs.add("[Warning (line : "+b+")] ["+current+"] buttonX is not a number. conversion may not be correct!");
                  } else if (int(tokens[1])!=8) {
                    logui.logs.add("[Warning (line : "+b+")] ["+current+"] buttonX is not 8. this unipack is not correct mc unipack.");
                  }
                  buffer=buffer+"buttonX=10";
                } else if (tokens[0].equals("buttonY")) {
                  if (isInt(tokens[1])==false) {
                    logui.logs.add("[Warning (line : "+b+")] ["+current+"] buttonY is not a number. conversion may not be correct!");
                  } else if (int(tokens[1])!=8) {
                    logui.logs.add("[Warning (line : "+b+")] ["+current+"] buttonY is not 8. this unipack is not correct mc unipack.");
                  }
                  buffer=buffer+"buttonX=10";
                } else {
                  buffer=buffer+line;
                }
              } else {//10 to mc=====================================================================================
                if (tokens[0].equals("buttonX")) {
                  if (isInt(tokens[1])==false) {
                    logui.logs.add("[Warning (line : "+b+")] ["+current+"] buttonX is not a number. conversion may not be correct!");
                  } else if (int(tokens[1])!=8) {
                    logui.logs.add("[Warning (line : "+b+")] ["+current+"] buttonX is not 10. this unipack is not correct 10*10 unipack.");
                  }
                  buffer=buffer+"buttonX=8";
                } else if (tokens[0].equals("buttonY")) {
                  if (isInt(tokens[1])==false) {
                    logui.logs.add("[Warning (line : "+b+")] ["+current+"] buttonsY is not a number. conversion may not be correct!");
                  } else if (int(tokens[1])!=8) {
                    logui.logs.add("[Warning (line : "+b+")] ["+current+"] buttonY is not 10. this unipack is not correct 10*10 unipack.");
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
        if (/*readFrameInfo(buffer)==*/false) {
          logui.logs.add("[Read] "+fileCount+". "+current+" : Failed!");
        } else {
          logui.logs.add("[Read] "+fileCount+". "+current+" : Success!");
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
            logui.logs.add("[Write] "+fileCount+". "+current+" : Success! <overwrited>");
          } else {
            logui.logs.add("[Write] "+fileCount+". "+current+" : Success!");
          }
        }
      }
      catch(Exception e) {
        logui.logs.add("[Read] "+fileCount+". "+current+" : Failed!");
        logui.logs.add("[Error (line : "+0+")] ["+current+"<Exception> : "+e.toString());
      }
    }
    if (new File(input+"/sounds").isDirectory()==false&&new File(input+"sounds").isDirectory()==false) {
      logui.logs.add("[Warning (line : "+0+")] [ - ] no sounds found.");
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
        if (EX_fileCopy(files[a].getAbsolutePath(), out.getAbsolutePath())) {
          if (overwrite) {
            logui.logs.add("[Copy] "+fileCount+". "+current+" : Success! <overwrited>");
          } else {
            logui.logs.add("[Copy] "+fileCount+". "+current+" : Success!");
          }
        } else {
          if (overwrite) {
            logui.logs.add("[Copy] "+fileCount+". "+current+" : Failed! <overwrited>");
          } else {
            logui.logs.add("[Copy] "+fileCount+". "+current+" : Failed!");
          }
        }
        a=a+1;
      }
    }
    surface.setTitle(title_filename+title_edited+title_suffix+" - converting... autoPlay");
    if (new File(input+"/autoPlay").isFile()==false&&new File(input+"autoPlay").isFile()==false) {
      logui.logs.add("[Warning (line : "+0+")] [ - ] no autoPlay found.");
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
                logui.logs.add("[Error (line : "+b+")] ["+current+"] too few arguments. cannot convert this line!");
                buffer=buffer+tokens[0];
              } else {
                if (isInt(tokens[2])==false) { 
                  logui.logs.add("[Error (line : "+b+")] ["+current+"] 3rd argument is not a number. conversion may\nnot be correct!");
                }
                if (direc) {//mc to 10=================================================================================
                  if (tokens[1].equals("mc")) {
                    if (int(tokens[2])<1 || int(tokens[2])>32) {
                      logui.logs.add("[Warning (line : "+b+")] ["+current+"] mc number is out of range. line skipped.");
                    } else {
                      Pos c=McToTen(new Pos(int(tokens[2]), 0, true));
                      if (c.x==-1) {
                        logui.logs.add("[Error (line :"+b+")] ["+current+"] position out of range, cannot convert.");
                      } else {
                        buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                      }
                    }
                  } else {
                    if (isInt(tokens[1])==false) {
                      logui.logs.add("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number. conversion may\nnot be correct!");
                    }
                    Pos c=McToTen(new Pos(int(tokens[2]), int(tokens[1]), false));
                    if (c.x==-1) {
                      logui.logs.add("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
                    } else {
                      buffer=buffer+tokens[0]+" "+c.y+" "+c.x;
                    }
                  }
                } else {//10 to mc=====================================================================================
                  if (tokens[1].equals("mc")) {
                    logui.logs.add("[Warning (line : "+b+")] ["+current+"] this is not pure 10*10 unipack file!(unitor mc pack)\nline skipped.");
                  } else {
                    if (isInt(tokens[1])==false) {
                      logui.logs.add("[Error (line : "+b+")] ["+current+"] 2nd argument is not a number.\nconversion may not be correct!");
                    }
                    Pos c=TenToMc(new Pos(int(tokens[2]), int(tokens[1]), false));
                    if (c.x==-1) {
                      logui.logs.add("[Error (line : "+b+")] ["+current+"] position out of range, cannot convert.");
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
        if (/*readFrameAP(buffer)==*/false) {
          logui.logs.add("[Read] "+fileCount+". "+current+" : Failed!");
        } else {
          logui.logs.add("[Read] "+fileCount+". "+current+" : Success!");
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
            logui.logs.add("[Write] "+fileCount+". "+current+" : Success! <overwrited>");
          } else {
            logui.logs.add("[Write] "+fileCount+". "+current+" : Success!");
          }
        }
      }
      catch(Exception e) {
        logui.logs.add("[Read] "+fileCount+". "+current+" : Failed!");
        logui.logs.add("[Error (line : "+0+")] ["+current+"] <Exception> : "+e.toString());
      }
    }
    //logui.logs.add("[Warning (line : "+0+")] [keyLED] "+autoWarningCount+" of [on mc n vel]'s are converted into [on y x auto vel]. if this is right, ignore this.");
    if (direc)logui.logs.add("[ Mode : <Mc->10*10> ][ Files : "+fileCount+" ]---");
    else logui.logs.add("[ Mode : <10*10->Mc> ][ Files : "+fileCount+" ]---");
    UI[id].disabled=false;
    UI[id].registerRender=true;
    focus=id;
    surface.setTitle(title_filename+title_edited+title_suffix);
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
}