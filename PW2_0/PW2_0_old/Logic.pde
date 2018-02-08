
//led
//keydsound
ArrayList<KsButton[][]> KS;
color[][] ksDisplay;
ArrayList<String> ksLoadedSamples=new ArrayList<String>();
ArrayList<Integer> ksLoadedSamplesCount=new ArrayList<Integer>();
ArrayList<IntVector2> CurrentNoteOn=new Array
  int ksCurrentSoundLoop=0;
  //int ksLedPointer=0;//???? DELETE
  SamplePlayer ksPlayer;
  int multiLed=0;
  int multiSound=0;
  public KsButton(int c, int x, int y) {
    if (c==0) {
      ksPlayer=new SamplePlayer(ksac, 2);
      ksac.out.addInput(ksPlayer);
      ksPlayer.setKillOnEnd(false);
    } else {
      ksPlayer=KS.get(0)[x][y].ksPlayer;
    }
    ksPlayer.setEndListener(new Bead() {
      public void messageReceived(Bead message) {
        autorun_startSound(false);
      }
    }
    );
  }
  void delete() {
    int a=ksSample.size()-1;
    while (a>=0) {
      removeSound(a);
      a=a-1;
    }
    ksac.out.removeConnection(0, ksPlayer, 0);
    ksac.out.removeConnection(1, ksPlayer, 0);
    ksac.out.removeConnection(0, ksPlayer, 1);
    ksac.out.removeConnection(1, ksPlayer, 1);
  }
  boolean loadLed(int index, String path) {
    try {
      ksLed.add(index, loadLedScript(path, readFile(path)).getCommands());
      ksLedFile.add(index, path);
      ksLedLoop.add(index, 1);//ADD!!
    }
    catch(Exception e) {
    }
    return true;
  }
  void reloadLeds() {
    int index=0;
    while (index<ksLedFile.size()) {
      String path=ksLedFile.get(index);
      //not null ksLed.add(index, new ArrayList<Analyzer.UnipackLine>());
      //not null ksDelayValue.add(index, new ArrayList<Integer>());
      //if (analyzer.  loadLedFile(path, ksLed.get(index), ksDelayValue.get(index))) {
      //}
      index++;
    }
  }
  boolean loadLed(String path) {//done
    return loadLed(ksLedFile.size(), path);
  }
  void reorderLed(int index1, int index2) {//done
    String temp1=ksLedFile.get(index1);
    ksLedFile.set(index1, ksLedFile.get(index2));
    ksLedFile.set(index2, temp1);
    ArrayList<color[][]> temp3=ksLed.get(index1);
    ksLed.set(index1, ksLed.get(index2));
    ksLed.set(index2, temp3);
    Integer temp4=ksLedLoop.get(index1);
    ksLedLoop.set(index1, ksLedLoop.get(index2));
    ksLedLoop.set(index2, temp4);
  }
  void removeLed(int index) {//done
    ksLed.remove(index);
    ksLedFile.remove(index);
    ksLedLoop.remove(index);
  }
  boolean loadSound(int index, String path) {//done
    ksSound.add(index, path);
    println(path);
    ksSample.add(index, SampleManager.sample(path));
    if (ksSample.get(index)==null) {
      ksSound.remove(index);
      ksSample.remove(index);
      return false;
    } else {
      ksSoundLoop.add(index, 1);
      int a=0;
      while (a<ksLoadedSamples.size()) {
        if (ksLoadedSamples.get(a).equals(path)) {
          ksLoadedSamplesCount.set(a, ksLoadedSamplesCount.get(a)+1);
          break;
        }
        a=a+1;
      }
      if (a==ksLoadedSamples.size()) {
        ksLoadedSamples.add(path);
        ksLoadedSamplesCount.add(1);
      }
    }
    return true;
  }
  boolean loadSound(String path) {//done
    return loadSound(ksSample.size(), path);
  }
  void reorderSound(int index1, int index2) {//done
    String temp1=ksSound.get(index1);
    ksSound.set(index1, ksSound.get(index2));
    ksSound.set(index2, temp1);
    Sample temp2=ksSample.get(index1);
    ksSample.set(index1, ksSample.get(index2));
    ksSample.set(index2, temp2);
    Integer temp4=ksSoundLoop.get(index1);
    ksSoundLoop.set(index1, ksSoundLoop.get(index2));
    ksSoundLoop.set(index2, temp4);
  }
  void removeSound(int index) {//done
    int a=0;
    String path=ksSound.get(index);
    while (a<ksLoadedSamples.size()) {
      if (ksLoadedSamples.get(a).equals(path)) {
        ksLoadedSamplesCount.set(a, ksLoadedSamplesCount.get(a)-1);
        if (ksLoadedSamplesCount.get(a)==0) {
          SampleManager.removeSample(ksSample.get(index));
        }
        break;
      }
      a=a+1;
    }
    ksSample.remove(index);
    ksSound.remove(index);
    ksSoundLoop.remove(index);
  }
  boolean isInStack=false;
  int multiLedBackup=0;
  synchronized void autorun() {
    autorun_startSound();
    autorun_startLed();
  }
  void autorun_startSound() {
    autorun_startSound(true);
  }
  boolean autorun_soundFlag=false;//if true, updated.
  synchronized void autorun_startSound(boolean plus) {
    if (plus==false&&autorun_soundFlag)return;
    if (ksSample.size()>0) {
      if (plus) {
        ksCurrentSoundLoop=0;
        autorun_soundFlag=false;
      } else if (multiSound>0&&(ksCurrentSoundLoop<ksSoundLoop.get(multiSound-1)||ksSoundLoop.get(multiSound-1)==0)) {//continue
        multiSound=min(ksSample.size()-1, multiSound-1);
      } else {//break
        ksCurrentSoundLoop=0;
        autorun_soundFlag=true;
        return;
      }
      if (multiSound>=ksSample.size())multiSound=0;
      //if (multiSound>=ksSample.size())multiSound=ksSample.size()-1;
      ksPlayer.setSample(ksSample.get(multiSound));
      setStatusR(ksSample.get(multiSound).toString()+" "+str(bC+1)+"("+str(bX+1)+", "+str(bY+1)+")");
      ksPlayer.pause(false);//
      ksPlayer.reTrigger();
      multiSound++;
      ksCurrentSoundLoop++;
    }
  }
  void autorun_startLed() {
    if (ksLed.size()>0) {
      multiLed=multiLedBackup;
      if (multiLed>=ksLed.size())multiLed=0;
      autorun_resetLed();
      if (isInStack==false)ledstack.add(this);
      isInStack=true;
      multiLed++;//multiled cant be 0.
      multiLedBackup=multiLed;
    }
  }
  void autorun_startSoundIndex(int index) {
    if (index<0||index>=ksSample.size())return;
    ksPlayer.setSample(ksSample.get(index));
    ksPlayer.pause(false);//
    ksPlayer.reTrigger();
  }
  void autorun_startLedIndex(int index) {
    if (index<0||index>=ksLedFile.size())return;
    autorun_resetLed();
    multiLed=index+1;
    if (isInStack==false)ledstack.add(this);
    isInStack=true;
  }
  public void stopSound() {
    if (ksPlayer==null)return;
    if (ksPlayer.getSample()!=null)ksPlayer.setToEnd();
  }
}
void I_ResetKs() {
  KS=null;
  KS=new ArrayList<KsButton[][]>();
  int a=0;
  while (a<Chain) {
    KS.add(new KsButton[ButtonX][ButtonY]);
    int b=0;
    while (b<ButtonX) {
      int c=0;
      while (c<ButtonY) {
        KS.get(a)[b][c]=new KsButton(a, b, c);
        c=c+1;
      }
      b=b+1;
    }
    a=a+1;
  }
  ksDisplay=new color[ButtonX][ButtonY];
  int b=0;
  while (b<ButtonX) {
    int c=0;
    while (c<ButtonY) {
      ksDisplay[b][c]=OFFCOLOR;
      c=c+1;
    }
    b=b+1;
  }
  ksac.start();
}
synchronized void L_ResizeData(int Chain_, int ButtonX_, int ButtonY_) {//ADD KS(resize button,chain
  ArrayList<KsButton[][]> tempKS=KS;
  KS=new ArrayList<KsButton[][]>();
  int a=0;
  while (a<Chain_) {
    KS.add(new KsButton[ButtonX_][ButtonY_]);
    int b=0;
    while (b<ButtonX_) {
      int c=0;
      while (c< ButtonY_) {
        if (b>=ButtonX||c>=ButtonY||a>=Chain)KS.get(a)[b][c]=new KsButton(a, b, c);
        else KS.get(a)[b][c]=tempKS.get(a)[b][c];
        c=c+1;
      }
      if (b<ButtonX) {
        while (c<ButtonY) {
          tempKS.get(a)[b][c].delete();
          c=c+1;
        }
      }
      b=b+1;
    }
    if (a<Chain) {
      while (b<ButtonX) {
        int c=0;
        while (c<ButtonY) {
          tempKS.get(a)[b][c].delete();
          c=c+1;
        }
        b=b+1;
      }
    }
    a=a+1;
  }
  while (a<Chain) {
    int b=0;
    while (b<ButtonX) {
      int c=0;
      while (c<ButtonY) {
        tempKS.get(a)[b][c].delete();
        c=c+1;
      }
      b=b+1;
    }
    a=a+1;
  }
  ksDisplay=new color[ButtonX_][ButtonY_];
  int b=0;
  while (b<ButtonX_) {
    int c=0;
    while (c<ButtonY_) {
      ksDisplay[b][c]=OFFCOLOR;
      c=c+1;
    }
    b=b+1;
  }
  ButtonX=ButtonX_;
  ButtonY=ButtonY_;
  Chain=Chain_;
  ksX=min(ksX, ButtonX-1);
  ksY=min(ksY, ButtonY-1);
  ksChain=min(ksChain, Chain-1);
  ((ScrollList)UI[getUIid("I_SOUNDVIEW")]).setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
  ((ScrollList)UI[getUIid("I_LEDVIEW")]).setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
  MidiCommand.setState(ButtonX+"x"+ButtonY);
  keyLedPad.before=new color[ButtonX][ButtonY];
  keySoundPad.before=new color[ButtonX][ButtonY];
  setStatusR("resized to "+Chain+":("+ButtonX+", "+ButtonY+")");
}