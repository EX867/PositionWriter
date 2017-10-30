
class UnipackLine {
  static final int TITLE=11;
  static final int PRODUCERNAME=12;
  static final int BUTTONX=13;
  static final int BUTTONY=14;
  static final int CHAINNUMBER=15;
  static final int LANDSCAPE=16;
  static final int SQUAREBUTTON=17;
  static final int UPDATED=18;
  //keysound
  //autoPlay
  UnipackInfo getEmptyUnipackInfo() {
    return new UnipackInfo();
  }
  public class UnipackInfo {
    boolean valid=true;
    String title="";
    String producerName="";
    int buttonX=8;
    int buttonY=8;
    int chain=3;
    boolean landscape=true;
    boolean squareButton=true;
    boolean updated=false;
    public UnipackInfo() {
    }
    @Override
      String toString() {
      String ret="";
      ret+="title="+title+"\n";
      ret+="producerName="+producerName+"\n";
      ret+="buttonX="+buttonX+"\n";
      ret+="buttonY="+buttonY+"\n";
      ret+="chain="+chain+"\n";
      ret+="squareButton="+str(squareButton)+"\n";
      ret+="landscape="+str(landscape)+"\n";
      ret+="updated"+str(updated);
      return ret;
    }
    String uncloud_toString() {
      String ret="";
      ret+="title="+title+"\n";
      ret+="producerName="+producerName+"\n";
      ret+="buttonX="+buttonX+"\n";
      ret+="buttonY="+buttonY+"\n";
      ret+="chain="+chain+"\n";
      return ret;
    }
  }
  public UnipackInfo getUnipackInfo(String filename, String text) {
    UnipackInfo ret=new UnipackInfo();
    boolean[] check = new boolean[7];
    int a=0;
    while (a<7) {
      check[a]=false;
      a++;
    }
    String[] lines=split(text, "\n");
    a=0;
    while (a<lines.length) {
      UnipackLine result=AnalyzeLine(a, filename, lines[a]);
      if (result.Type==UnipackLine.TITLE) {
        ret.title=result.value;
        check[0]=true;
      } else if (result.Type==UnipackLine.PRODUCERNAME) {
        ret.producerName=result.value;
        check[1]=true;
      } else if (result.Type==UnipackLine.BUTTONX) {
        ret.buttonX=int(result.value);
        check[2]=true;
      } else if (result.Type==UnipackLine.BUTTONY) {
        ret.buttonY=int(result.value);
        check[3]=true;
      } else if (result.Type==UnipackLine.CHAINNUMBER) {
        ret.chain=int(result.value);
        check[4]=true;
      } else if (result.Type==UnipackLine.LANDSCAPE) {
        ret.landscape=toBoolean(result.value);
        check[5]=true;
      } else if (result.Type==UnipackLine.SQUAREBUTTON) {
        ret.squareButton=toBoolean(result.value);
        check[6]=true;
      } else if (result.Type==UnipackLine.UPDATED) {
        ret.updated=toBoolean(result.value);
      }
      a=a+1;
    }
    a=0;
    while (a<7) {
      if (a==5)a++;
      if (check[a]==false)ret.valid=false;
      a=a+1;
    }
    return ret;
  }

  if (isInt(tokens[0])) {// c y x filename [loop] (keysound) - post filtered.
    if (tokens.length>3) {
      if (int(tokens[1])<=0&&int(tokens[1])>Chain)printWarning(1, line, filename, in, "chain number is out of range.");
      if (isInt(tokens[1]) && isInt(tokens[2])) {
        if (int(tokens[1])<=0||int(tokens[1])>ButtonY||int(tokens[2])<=0||int(tokens[2])>ButtonX)printWarning(1, line, filename, in, "button number is out of range.");
        String[] ttokens = split(in, "\"");
        if (ttokens.length == 3) {
          ttokens[1] = ttokens[1].trim();// make error...?
          ttokens[2] = ttokens[2].trim();// make error...?
          if (ttokens[2].length() == 0)return new UnipackLine(filename, UnipackLine.KEYSOUND, int(tokens[0]), int(tokens[2]), int(tokens[1]), ttokens[1], true, 1);
          else if (isInt(ttokens[2])) {
            if (int(ttokens[2])<0)printWarning(1, line, filename, ttokens[2], "loop number is negative");
            return new UnipackLine(filename, UnipackLine.KEYSOUND, int(tokens[0]), int(tokens[2]), int(tokens[1]), ttokens[1], true, int(ttokens[2]));
          } else printError(1, line, filename, in, "incorrect keysound command.");
        } else if (ttokens.length == 1) {
          if (tokens.length == 4)return new UnipackLine(filename, UnipackLine.KEYSOUND, int(tokens[0]), int(tokens[2]), int(tokens[1]), tokens[3], false, 1);
          else if (tokens.length == 5) {
            if (isInt(tokens[4])) {
              if (int(tokens[4])<0)printWarning(1, line, filename, tokens[4], "loop number is negative");
              return new UnipackLine(filename, UnipackLine.KEYSOUND, int(tokens[0]), int(tokens[2]), int(tokens[1]), tokens[3], false, int(tokens[4]));
            } else printError(1, line, filename, tokens[4], "loop number is not a number!");
          } else printError(1, line, filename, in, "incorrect keysound command.");
        } else printError(1, line, filename, in, " must be closed with .");
      } else printError(1, line, filename, in, "x or y number is not integer!");
    } else printError(1, line, filename, in, "keysound command expects [c y x filename] or [c y x filename loop].");
  } else {
    tokens = split(in, "=");
    a=2;
    String temp="";
    if (tokens.length>1)temp=tokens[1];
    while (a<tokens.length) {
      temp=temp+"="+tokens[a];
      a=a+1;
    }
    if (tokens.length>0) {
      if (tokens[0].equals("title")) return new UnipackLine(filename, UnipackLine.TITLE, temp);
      else if (tokens[0].equals("producerName")) return new UnipackLine(filename, UnipackLine.PRODUCERNAME, temp);
      else if (tokens[0].equals("buttonX")) {
        if (tokens.length==2) {
          if (isInt(tokens[1]))return new UnipackLine(filename, UnipackLine.BUTTONX, tokens[1]);
          else printError(1, line, filename, in, "buttonX is not integer.");
        } else printError(1, line, filename, in, "buttonX is not integer.");
      } else if (tokens[0].equals("buttonY")) {
        if (tokens.length==2) {
          if (isInt(tokens[1]))return new UnipackLine(filename, UnipackLine.BUTTONY, tokens[1]);
          else printError(1, line, filename, in, "buttonY is not integer.");
        } else printError(1, line, filename, in, "buttonY is not integer.");
      } else if (tokens[0].equals("chain")) {
        if (tokens.length==2) {
          if (isInt(tokens[1]))return new UnipackLine(filename, UnipackLine.CHAINNUMBER, tokens[1]);
          else printError(1, line, filename, in, "chain is not integer.");
        } else printError(1, line, filename, in, "chain is not integer.");
      } else if (tokens[0].equals("landscape")) {
        if (tokens.length==2) {
          if (isBoolean(tokens[1]))return new UnipackLine(filename, UnipackLine.LANDSCAPE, tokens[1]);
          else printError(1, line, filename, in, "landscape is not boolean.");
        } else printError(1, line, filename, in, "landscape is not boolean.");
      } else if (tokens[0].equals("squareButton")) {
        if (tokens.length==2) {
          if (isBoolean(tokens[1]))return new UnipackLine(filename, UnipackLine.SQUAREBUTTON, tokens[1]);
          else printError(1, line, filename, in, "squareButton is not boolean.");
        } else printError(1, line, filename, in, "squareButton is not boolean.");
      } else if (tokens[0].equals("updated")) {
        if (tokens.length==2) {
          if (isInt(tokens[1]))return new UnipackLine(filename, UnipackLine.UPDATED, tokens[1]);
          else printError(1, line, filename, in, "updated is not boolean.");
        } else printError(1, line, filename, in, "updated is not boolean.");
      } else printError(1, line, filename, in, "unknown command.");
    }
  }
  return new UnipackLine(filename, DEFAULT, mc);
}
//============================================================================================================================================
void readFrameLed(int frame, int count) {
  if (frame==0) {
    int b=0;
    while (b<ButtonX) {
      int c=0;
      while (c<ButtonY) {
        LED.get(frame)[b][c]=OFFCOLOR;
        apLED.get(frame)[b][c]=false;
        c=c+1;
      }
      b=b+1;
    }
  } else {
    int b=0;
    while (b<ButtonX) {
      int c=0;
      while (c<ButtonY) {
        LED.get(frame)[b][c]=LED.get(frame-1)[b][c];
        apLED.get(frame)[b][c]=apLED.get(frame-1)[b][c];
        c=c+1;
      }
      b=b+1;
    }
  }
  int d=DelayPoint.get(frame)+1;
  count=frame+count;
  while (frame<=count&&d<Lines.lines()) {//reset
    UnipackLine info=uLines.get(d);//AnalyzeLine(a, "readFrame - read "+count+" frames", Lines.getLine(a));
    if (info.mc) {
      d++;
      continue;
    }
    if (info.Type==UnipackLine.ON) {
      if (0<info.x&&info.x<=ButtonX&&0<info.y&&info.y<=ButtonY&&0<info.x2&&info.x2<=ButtonX&&0<info.y2&&info.y2<=ButtonY) {
        for (int a=info.x; a<=info.x2; a++) {
          for (int b=info.y; b<=info.y2; b++) {
            onLED(info, a, b, frame);
          }
        }
      }
    } else if (info.Type==UnipackLine.OFF) {
      if (0<info.x&&info.x<=ButtonX&&0<info.y&&info.y<=ButtonY&&0<info.x2&&info.x2<=ButtonX&&0<info.y2&&info.y2<=ButtonY) {
        for (int a=info.x; a<=info.x2; a++) {
          for (int b=info.y; b<=info.y2; b++) {
            offLED(info, a, b, frame);
            offApLED(info, a, b, frame);
          }
        }
      }
    } else if (info.Type==UnipackLine.DELAY) {
      frame++;
      int b=0;
      while (b<ButtonX) {
        int c=0;
        while (c<ButtonY) {
          LED.get(frame)[b][c]=LED.get(frame-1)[b][c];
          apLED.get(frame)[b][c]=apLED.get(frame-1)[b][c];
          c=c+1;
        }
        b=b+1;
      }
    } else if (info.Type==UnipackLine.APON) {
      if (0<info.x&&info.x<=ButtonX&&0<info.y&&info.y<=ButtonY&&0<info.x2&&info.x2<=ButtonX&&0<info.y2&&info.y2<=ButtonY) {
        for (int a=info.x; a<=info.x2; a++) {
          for (int b=info.y; b<=info.y2; b++) {
            onApLED(info, a, b, frame);
          }
        }
      }
    }
    d++;
  }
}
ArrayList<UnipackLine> loadKeySound(String path) throws Exception {
  ArrayList<UnipackLine> ret=new ArrayList<UnipackLine>();
  String alltext=readFile(path);
  String[] lines=split(alltext, "\n");
  int a=0;
  while (a<lines.length) {
    UnipackLine line=AnalyzeLine(a, "LoadLedFile", lines[a]);
    if (line.Type==UnipackLine.KEYSOUND) {
      ret.add(line);
    }
    a=a+1;
  }
  return ret;
}
boolean loadKeyLedFlag =false;//true if loading
void loadKeyLedGlobal(String filename) throws Exception {
  if (loadKeyLedFlag)return;//ignore
  File file=new File(filename);
  if (file.isFile()) {
    loadKeyLedFlag=true;
    String text;
    try {
      text=readFile(filename).replace("\r\n", "\n").replace("\r", "\n");
    }
    catch(Exception e) {
      loadKeyLedFlag=false;
      throw e;
    }
    if (text!=null) {//???
      currentLedFrame=0;
      frameSlider.skip=true;
      ((TextEditor)UI[textfieldId]).setText(text);
      frameSlider.skip=false;
      registerRender();
    }
    loadKeyLedFlag=false;
  } else if (file.isDirectory()) {
    throw new Exception("ignore");
  } else {
    throw new Exception("file not exists : "+filename);
  }
}
boolean loadKeySoundFlag=false;//true if loading
void loadKeySoundGlobal(String filename) throws Exception {
  if (loadKeySoundFlag)return;//ignore
  File file=new File(filename);
  println(filename);
  if (file.isDirectory()) {//and exists
    try {
      loadKeySoundFlag=true;
      println("load start");
      File infof=new File(joinPath(filename, "info"));
      File keySoundf=new File(joinPath(filename, "keySound"));
      File soundsf=new File(joinPath(filename, "sounds"));
      File keyLEDf=new File(joinPath(filename, "keyLED"));
      File projectf=new File(joinPath(filename, ".project"));
      if (infof.isFile()) {
        println("load info "+infof.getAbsolutePath());
        UnipackInfo info=getUnipackInfo(infof.getAbsolutePath(), readFile(infof.getAbsolutePath()));
        if (info.valid) {
          ((TextBox)UI[getUIid("I_TITLE")]).text=info.title;
          ((TextBox)UI[getUIid("I_PRODUCERNAME")]).text=info.producerName;
          ((TextBox)UI[getUIid("I_BUTTONX")]).value=info.buttonX;
          ((TextBox)UI[getUIid("I_BUTTONX")]).text=""+info.buttonX;
          ((TextBox)UI[getUIid("I_BUTTONY")]).value=info.buttonY;
          ((TextBox)UI[getUIid("I_BUTTONY")]).text=""+info.buttonY;
          ((TextBox)UI[getUIid("I_CHAIN")]).value=info.chain;
          ((TextBox)UI[getUIid("I_CHAIN")]).text=""+info.chain;
          ((Button)UI[getUIid("I_LANDSCAPE")]).value=info.landscape;
          ((Button)UI[getUIid("I_SQUAREBUTTONS")]).value=info.squareButton;
          ButtonX=info.buttonX;
          ButtonY=info.buttonY;
          Chain=info.chain;
        } else {//ignore
          //throw new Exception("info is not correct");
          ButtonX=8;
          ButtonY=8;
          Chain=8;
        }
        MidiCommand.setState(ButtonX+"x"+ButtonY);
        keyLedPad.before=new color[ButtonX][ButtonY];
        keySoundPad.before=new color[ButtonX][ButtonY];
      } else {
        throw new Exception("info is not a file : "+infof.getAbsolutePath());
      }
      I_ResetKs();
      if (keySoundf.isFile()) {//soundsf.isDirectory()
        println("load sound "+soundsf.getAbsolutePath());
        ArrayList<Analyzer.UnipackLine> lines=analyzer.loadKeySound(keySoundf.getAbsolutePath());
        int a=0;
        while (a<lines.size()) {
          Analyzer.UnipackLine line=lines.get(a);
          if (0<line.x&&line.x<=ButtonX&&0<line.y&&line.y<=ButtonY&&0<line.chain&&line.chain<=Chain) {
            File soundfile;
            if (line.absolute) {
              soundfile=new File(line.filename);
            } else {
              soundfile=new File(joinPath(soundsf.getAbsolutePath(), line.filename));
            }
            if (isSoundFile(soundfile)) {
              println("load : "+soundfile.getAbsolutePath());
              if (KS.get(line.chain-1)[line.x-1][line.y-1].loadSound(soundfile.getAbsolutePath().replace("\\", "/"))) {
                KS.get(line.chain-1)[line.x-1][line.y-1].ksSoundLoop.set(KS.get(line.chain-1)[line.x-1][line.y-1].ksSoundLoop.size()-1, line.loop);
              }
            }
          }
          a=a+1;
        }
      } else {
        throw new Exception("keySound is not a file : "+keySoundf.getAbsolutePath());
      }
      if (keyLEDf.isDirectory()) {
        println("load led "+keyLEDf.getAbsolutePath());
        int a=0;
        File[] files=keyLEDf.listFiles();
        //already sorted by abc
        int c=-1;
        int x=-1;
        int y=-1;
        int loop=1;
        while (a<files.length) {
          String[] tokens=split(getExtensionElse(getFileName(files[a].getAbsolutePath())), " ");
          if (tokens.length>3) {
            if (isInt(tokens[0])&&isInt(tokens[1])&&isInt(tokens[2])&&isInt(tokens[3])) {
              c=int(tokens[0]);
              x=int(tokens[2]);
              y=int(tokens[1]);
              loop=int(tokens[3]);
              if (0<x&&x<=ButtonX&&0<y&&y<=ButtonY&&0<c&&c<=Chain) {
                println("load : "+files[a].getAbsolutePath());
                if (KS.get(c-1)[x-1][y-1].loadLed(files[a].getAbsolutePath().replace("\\", "/"))) {
                  KS.get(c-1)[x-1][y-1].ksLedLoop.set(KS.get(c-1)[x-1][y-1].ksLedLoop.size()-1, loop);
                }
                //set loop!//#add
              }
            }
          }
          a=a+1;
        }
      } else if (keyLEDf.isFile()) {
        println("load led(file) "+keyLEDf.getAbsolutePath());
        ArrayList<Analyzer.UnipackLine> lines=analyzer.loadKeySound(keyLEDf.getAbsolutePath());
        int a=0;
        while (a<lines.size()) {
          Analyzer.UnipackLine line=lines.get(a);
          if (0<line.x&&line.x<=ButtonX&&0<line.y&&line.y<=ButtonY&&0<line.chain&&line.chain<=Chain) {
            if (line.absolute) {
              File ledfile=new File(line.filename);
              if (ledfile.isFile()) {
                println("load : "+ledfile.getAbsolutePath());
                KS.get(line.chain-1)[line.x-1][line.y-1].loadLed(ledfile.getAbsolutePath().replace("\\", "/"));
              }
            }//else ignore(error)
          }
          a=a+1;
        }
      } else {
        //throw new Exception("keyLED not exists : "+keyLEDf.getAbsolutePath()); - just ignore
      }
      if (projectf.isFile()) {
        ((TextBox)UI[getUIid("I_PROJECTNAME")]).text=readFile(projectf.getAbsolutePath());
      } else {
        ((TextBox)UI[getUIid("I_PROJECTNAME")]).text=getFileName(filename);
      }
      ksX=0;
      ksY=0;
      ksChain=0;
      ((ScrollList)UI[getUIid("I_SOUNDVIEW")]).setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
      ((ScrollList)UI[getUIid("I_LEDVIEW")]).setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
      registerRender();
      loadKeySoundFlag=false;
    }
    catch(Exception e) {
      loadKeySoundFlag=false;
      throw e;
    }
  } else if (file.isFile()) {
    throw new Exception("ignore");
  } else {
    throw new Exception("folder not exists : "+filename);
  }
}
void readKS(String path) {//set KS instance to asdf. loades sound file too.
  I_ResetKs();//erase original data - WARNING!
}
void writeKS(String path, boolean canonical) {//write "keySound" file and copy sounds/led. path is project path.
  //new File(joinPath(path,"sounds")).mkdirs();
  //setting canonical to true copies all sounds and led, and
  String text="";
  String ledtext="";
  int a=0;
  while (a<KS.size()) {
    int b=0;
    while (b<KS.get(a).length) {
      int c=0;
      while (c<KS.get(a)[b].length) {
        int d=0;
        while (d<KS.get(a)[b][c].ksSound.size()) {
          if (canonical) {
            text=text+"\n"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" "+getFileName(KS.get(a)[b][c].ksSound.get(d)).replace(" ", "_")+" "+KS.get(a)[b][c].ksSoundLoop.get(d);
          } else {
            text=text+"\n"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" \""+KS.get(a)[b][c].ksSound.get(d)+"\" "+KS.get(a)[b][c].ksSoundLoop.get(d);
          }
          d=d+1;
        }
        d=0;
        if (canonical) {
          while (d<KS.get(a)[b][c].ksSound.size()) {
            EX_fileCopy(KS.get(a)[b][c].ksSound.get(d), joinPath(path, "sounds/"+getFileName(KS.get(a)[b][c].ksSound.get(d)).replace(" ", "_")));
            d=d+1;
          }
          d=0;
          while (d<KS.get(a)[b][c].ksLedFile.size()) {//not just copy, clear and rename.
            try {
              writeFile(joinPath(path, "keyLED/"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" "+KS.get(a)[b][c].ksLedLoop.get(d)+" "+str(char(d+'a'))), Lines.toString(toUnipadLed(split(readFile(KS.get(a)[b][c].ksLedFile.get(d)), "\n"))));
            }
            catch(Exception e) {
              e.printStackTrace();
            }
            d=d+1;
          }
        } else {
          while (d<KS.get(a)[b][c].ksLedFile.size()) {
            ledtext=ledtext+"\n"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" \""+KS.get(a)[b][c].ksLedFile.get(d)+"\" "+KS.get(a)[b][c].ksLedLoop.get(d);
            d=d+1;
          }
        }
        c=c+1;
      }
      b=b+1;
    }
    a=a+1;
  }
  UnipackInfo info=new UnipackInfo();
  info.title=((TextBox)UI[getUIid("I_TITLE")]).text;
  if (info.title.equals(""))info.title="untitled";
  info.producerName=((TextBox)UI[getUIid("I_PRODUCERNAME")]).text;
  if (info.producerName.equals(""))info.producerName="made by "+getUsername()+", made with PositionWriter.";
  info.buttonX=int(((TextBox)UI[getUIid("I_BUTTONX")]).value);
  info.buttonY=int(((TextBox)UI[getUIid("I_BUTTONY")]).value);
  info.chain=int(((TextBox)UI[getUIid("I_CHAIN")]).value);
  info.landscape=((Button)UI[getUIid("I_LANDSCAPE")]).value;
  info.squareButton=((Button)UI[getUIid("I_SQUAREBUTTONS")]).value;
  try {
    writeFile(joinPath(path, "keySound"), text);
    if (canonical==false)writeFile(joinPath(path, "keyLED"), ledtext);
    writeFile(joinPath(path, "info"), info.toString());
    if (canonical==false) {
      if (((TextBox)UI[getUIid("I_PROJECTNAME")]).text.equals("")==false) {
        writeFile(joinPath(path, ".project"), filterString(((TextBox)UI[getUIid("I_PROJECTNAME")]).text, new String[]{"\\", "/", ":", "*", "?", "\"", "<", ">", "|"}));
      } else {
        writeFile(joinPath(path, ".project"), filterString(getFileName(title_filename), new String[]{"\\", "/", ":", "*", "?", "\"", "<", ">", "|"}));
      }
    }
  }
  catch(Exception e) {
    e.printStackTrace();//failed!
  }
}
}