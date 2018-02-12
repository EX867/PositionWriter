
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
              //writeFile(joinPath(path, "keyLED/"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" "+KS.get(a)[b][c].ksLedLoop.get(d)+" "+str(char(d+'a'))), keyled_textEditor.current.toString(ToUnipadLed(readFile(KS.get(a)[b][c].ksLedFile.get(d)))));
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