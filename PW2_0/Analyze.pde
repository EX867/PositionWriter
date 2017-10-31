
class UnipackLine {
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