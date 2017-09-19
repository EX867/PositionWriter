//
String GlobalPath="";//PositionWriter
String KeySoundPath="";//ADD load from file! make file in setup.
String WavEditPath="";
//
String AutoSavePath="";//GlobalPath+(Autosaved)
String LedSavePath="";//GlobalPath+(Led_saved)
String KeySoundSavePath="";//GlobalPath+(KeySound_saved)
String ProjectsPath="";//GlobalPath+(Projects)
String TempPath="";//GlobalPath+(Temp)
String ExternalPath="";//GlobalPath+(External)
//
int ButtonX=8;
int ButtonY=8;
int Chain=8;
float Bpm=DEFAULT_BPM;
//
int selectedColorType;
int velnumId;//shortcut
int htmlselId;//shortcut
int textfieldId;//shortcut
Slider frameSlider;//shortcut
DragSlider frameSliderLoop;//
Label timeLabel;
int autoSaveId;
int findId;
int replaceId;
Label statusL;
Label statusR;
PadButton keyLedPad;
PadButton keySoundPad;

int currentLedFrame=0;
int currentLedTime=0;
int ksChain=0;
int ksX=0;
int ksY=0;
//
String userMacro1="";
String userMacro2="";
//option
boolean autoSave=true;
boolean ignoreMc=false;
int Mode=AUTOINPUT;
boolean InFrameInput=false;
boolean autoStop=false;
boolean startFrom=true;
//led
ArrayList<color[][]> LED;//0 is empty!(OFFCOLOR)
ArrayList<boolean[][]> apLED;//0 is empty!(OFFCOLOR)
ArrayList<Integer> apChainPoint;
ArrayList<Integer> DelayPoint;
ArrayList<Integer> DelayValue;//updated in updateFrameSlider();
ArrayList<Integer> BpmPoint;
Analyzer analyzer=new Analyzer();
ModString Lines=new ModString();//TextEditor.
//keydsound
ArrayList<KsButton[][]> KS;
color[][] ksDisplay;
ArrayList<String> ksLoadedSamples=new ArrayList<String>();
ArrayList<Integer> ksLoadedSamplesCount=new ArrayList<Integer>();
AudioContext ksac=new AudioContext();
ArrayList<KsButton> ledstack=new ArrayList<KsButton>();//really, this is not a stack. it works more like queue, but I can't rename this!!
boolean ksautorun_render=false;
class IntVector2 {
  int x;
  int y;
  IntVector2() {
    x=0;
    y=0;
  }
  IntVector2(int x_, int y_) {
    x=x_;
    y=y_;
  }
  boolean equals(IntVector2 other) {
    if (other.x==x&&other.y==y)return true;
    return false;
  }
  boolean equals(int x_, int y_) {
    if (x_==x&&y_==y)return true;
    return false;
  }
}
ArrayList<IntVector2> CurrentNoteOn=new ArrayList<IntVector2>();
//temp save variables
boolean soundLoopEdit=true;//keysound loop edit
boolean isNoteOn(int x, int y) {
  int a=0;
  while (a<CurrentNoteOn.size()) {
    if (CurrentNoteOn.get(a).equals(x, y))return true;
    a=a+1;
  }
  return false;
}
class KsButton {
  int bC=0, bX=0, bY=0;
  ArrayList<ArrayList> ksLED;//multi,<UnipackLine>
  ArrayList<String> ksLedFile;
  ArrayList<ArrayList> ksDelayValue;//multi,<Integer>//You can delete this!!!
  int ksCurrentTime=0;
  int ksCurrentIndex=0;
  int ksNextTime=0;
  int ksCurrentDelayIndex=0;
  ArrayList<Integer> ksLedLoop;
  int ksCurrentLedLoop=0;
  ArrayList<String> ksSound;
  ArrayList<Sample> ksSample;
  ArrayList<Integer> ksSoundLoop;
  int ksCurrentSoundLoop=0;
  //int ksLedPointer=0;//???? DELETE
  SamplePlayer ksPlayer;
  int multiLed=0;
  int multiSound=0;
  public KsButton(int c, int x, int y) {
    bC=c;
    bX=x;
    bY=y;
    ksLedFile=new ArrayList<String>();
    ksLED=new ArrayList<ArrayList>();
    ksDelayValue=new ArrayList<ArrayList>();
    ksLedLoop=new ArrayList<Integer>();
    ksSound=new ArrayList<String>();
    ksSample=new ArrayList<Sample>();
    ksSoundLoop=new ArrayList<Integer>();
    ksPlayer=new SamplePlayer(ksac, 2);
    ksPlayer.setEndListener(new Bead() {
      public void messageReceived(Bead message) {
        autorun_startSound(false);
      }
    }
    );
    //if (ksSound.size()==0) {
    ksac.out.addInput(ksPlayer);
    //}
    ksPlayer.setKillOnEnd(false);
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
    ksLED.add(index, new ArrayList<Analyzer.UnipackLine>());
    ksDelayValue.add(index, new ArrayList<Integer>());
    if (analyzer.loadLedFile(path, ksLED.get(index), ksDelayValue.get(index))) {
      ksLedFile.add(index, path);
      ksLedLoop.add(index, 1);//ADD!!
    } else {
      ksLED.remove(index);
      ksDelayValue.remove(index);
      return false;
    }
    return true;
  }
  void reloadLeds() {
    int index=0;
    while (index<ksLedFile.size()) {
      String path=ksLedFile.get(index);
      //not null ksLED.add(index, new ArrayList<Analyzer.UnipackLine>());
      //not null ksDelayValue.add(index, new ArrayList<Integer>());
      if (analyzer.loadLedFile(path, ksLED.get(index), ksDelayValue.get(index))) {
      }
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
    ArrayList<Integer> temp2=ksDelayValue.get(index1);
    ksDelayValue.set(index1, ksDelayValue.get(index2));
    ksDelayValue.set(index2, temp2);
    ArrayList<color[][]> temp3=ksLED.get(index1);
    ksLED.set(index1, ksLED.get(index2));
    ksLED.set(index2, temp3);
    Integer temp4=ksLedLoop.get(index1);
    ksLedLoop.set(index1, ksLedLoop.get(index2));
    ksLedLoop.set(index2, temp4);
  }
  void removeLed(int index) {//done
    ksLED.remove(index);
    ksDelayValue.remove(index);
    ksLedFile.remove(index);
    ksLedLoop.remove(index);
  }
  boolean loadSound(int index, String path) {//done
    ksSound.add(index, path);
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
    if (ksLED.size()>0) {
      multiLed=multiLedBackup;
      if (multiLed>=ksLED.size())multiLed=0;
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
  void autorun_resetLed() {
    ksCurrentTime=0;
    ksNextTime=0;
    ksCurrentIndex=0;
    ksCurrentLedLoop=0;
    ksCurrentDelayIndex=0;
  }
  boolean autorun_led() {
    if (multiLed-1>=ksLED.size()) {
      autorun_resetLed();
      return false;//end
    }
    boolean endframe=true;
    while (ksNextTime<=ksCurrentTime) {//change frame
      //#refactor!!!
      ksautorun_render=true;
      while (ksCurrentIndex<ksLED.get(multiLed-1).size()) {
        if (((Analyzer.UnipackLine)(ksLED.get(multiLed-1).get(ksCurrentIndex))).Type==Analyzer.UnipackLine.DELAY) {
          endframe=false;
          ksNextTime=ksNextTime+max(1, (int)ksDelayValue.get(multiLed-1).get(ksCurrentDelayIndex));
          ksCurrentDelayIndex++;
          ksCurrentIndex++;
          break;
        } else if (((Analyzer.UnipackLine)(ksLED.get(multiLed-1).get(ksCurrentIndex))).Type==Analyzer.UnipackLine.ON) {
          Analyzer.UnipackLine line=(Analyzer.UnipackLine)ksLED.get(multiLed-1).get(ksCurrentIndex);
          if (0<line.x&&line.x<=ButtonX&&0<line.y&&line.y<=ButtonY) {
            //add leds to ksLED array.
            if (line.hasVel) {
              if (line.vel>=0&&line.vel<=127)ksDisplay[line.x-1][line.y-1]=k[line.vel];
            } else ksDisplay[line.x-1][line.y-1]=line.html;
          }
        } else if (((Analyzer.UnipackLine)(ksLED.get(multiLed-1).get(ksCurrentIndex))).Type==Analyzer.UnipackLine.OFF) {
          Analyzer.UnipackLine line=(Analyzer.UnipackLine)ksLED.get(multiLed-1).get(ksCurrentIndex);
          if (0<line.x&&line.x<=ButtonX&&0<line.y&&line.y<=ButtonY) {
            //add leds to ksLED array.
            ksDisplay[line.x-1][line.y-1]=OFFCOLOR;
          }
        } 
        ksCurrentIndex++;
        //bpm is translated to ms in readFrame.
      }
      if (endframe||ksCurrentIndex==ksLED.get(multiLed-1).size()) {//do end
        ksCurrentTime=0;
        ksNextTime=0;
        ksCurrentIndex=0;
        ksCurrentDelayIndex=0;
        ksCurrentLedLoop++;
        if (ksLedLoop.get(multiLed-1)==0||ksLedLoop.get(multiLed-1)>ksCurrentLedLoop) {
          return true;//not end(loop)
        } else {
          ksCurrentLedLoop=0;
          return false;//end
        }
      }
    }
    ksCurrentTime+=drawInterval;
    return true;
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
  ArrayList<color[][]> tempLED=LED;
  ArrayList<boolean[][]> tempapLED=apLED;
  LED=new ArrayList<color[][]>();
  apLED=new ArrayList<boolean[][]>();
  int a=0;
  while (a<tempLED.size()) {
    LED.add(new color[ButtonX_][ButtonY_]);
    apLED.add(new boolean[ButtonX_][ButtonY_]);
    int b=0;
    while (b<min(tempLED.get(a).length, ButtonX_)) {
      int c=0;
      while (c<min(tempLED.get(a)[b].length, ButtonY_)) {
        LED.get(a)[b][c]=tempLED.get(a)[b][c];
        apLED.get(a)[b][c]=tempapLED.get(a)[b][c];
        c=c+1;
      }
      b=b+1;
    }
    a=a+1;
  }
  ArrayList<KsButton[][]> tempKS=KS;
  KS=new ArrayList<KsButton[][]>();
  a=0;
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
  setStatusR("resized to "+Chain+":("+ButtonX+", "+ButtonY+")");
}
void updateFrameSlider() {
  int a=1;
  DelayValue.clear();
  while (a<DelayPoint.size()) {
    // print("delay line : "+DelayPoint.get(a)+" ");
    DelayValue.add(analyzer.getDelayValue(DelayPoint.get(a)));
    a=a+1;
  }
  a=0;
  frameSlider.maxI=0;
  while (a<DelayValue.size()) {
    frameSlider.maxI+=DelayValue.get(a);
    a=a+1;
  }
  //printLog("updateFrameSlider()", "frameSlider.maxI = "+frameSlider.maxI);
  frameSlider.adjust(min(frameSlider.maxI, max(frameSlider.minI, frameSlider.valueI)));
  //printLog("updateFrameSlider()", "frameSlider.valueI = "+frameSlider.valueI);
  currentLedTime=frameSlider.valueI;
  timeLabel.text=currentLedTime+"/"+frameSlider.maxI;
  setFrameByTime();
  //printLog("updateFrameSlider()", "currentLedFrame = "+currentLedFrame);
  frameSlider.render();
}
void autoRun() {
  if (currentFrame==1) {//keyled
    if (autorun_playing&&autorun_paused==false) {
      int sum=0;
      int a=1;
      timeLabel.text=currentLedTime+"/"+frameSlider.maxI;
      setFrameByTime();
      frameSlider.adjust(currentLedTime);
      currentLedTime+=drawInterval;
      if (frameSliderLoop.bypass&&currentLedTime>=frameSlider.maxI) {
        if (frameSlider.maxI!=0&&(autorun_loopCount>=autorun_loopCountTotal||autorun_infinite))currentLedTime=currentLedTime%frameSlider.maxI;
        else {
          if (autoStop) {
            currentLedTime=min(frameSlider.maxI, autorun_backup);
          } else {
            currentLedTime=frameSlider.maxI;
          }
          currentLedFrame=getFrameByTime(currentLedTime);
          frameSlider.adjust(currentLedTime);
          timeLabel.text=currentLedTime+"/"+frameSlider.maxI;
          autorun_playing=false;
        }
      } else if (frameSliderLoop.bypass==false&&currentLedTime>=frameSliderLoop.valueE) {
        if (autorun_loopCount>=autorun_loopCountTotal||autorun_infinite)currentLedTime=int(frameSliderLoop.valueS+(currentLedTime-frameSliderLoop.valueS)%(frameSliderLoop.valueE-frameSliderLoop.valueS));
        else {
          if (autoStop) {
            currentLedTime=ceil(min(frameSliderLoop.valueE, autorun_backup));
          } else {
            currentLedTime=ceil(frameSliderLoop.valueE);
          }
          setFrameByTime();
          autorun_playing=false;
        }
      }
      frameSlider.render();
    }
  } else if (currentFrame==2) {
    ksautorun_render=false;
    int c=0;
    while (c<ledstack.size()) {//pointer
      if (ledstack.get(c).autorun_led()) {
        c=c+1;
      } else {
        ledstack.get(c).isInStack=false;
        ledstack.remove(c);
      }
    }
    if (ksautorun_render)UI[getUIid("KEYSOUND_PAD")].render();
  }
} 
void setFrameByTime() {
  currentLedFrame=0;
  int a=1;
  int sum=0;
  while (a<DelayValue.size()) {
    sum=sum+DelayValue.get(a);
    if (currentLedTime<sum) {
      break;
    }
    currentLedFrame++;
    a=a+1;
  }
  frameSlider.adjust(currentLedTime);
  timeLabel.text=currentLedTime+"/"+frameSlider.maxI;
}
void setTimeByFrame() {
  currentLedTime=0;
  int a=0;
  while (a<currentLedFrame) {//warning! this can be incorrect
    currentLedTime+=DelayValue.get(a);
    a=a+1;
  }
  timeLabel.text=currentLedTime+"/"+frameSlider.maxI;
  frameSlider.adjust(currentLedTime);
}
void autoRunReset() {
  autorun_paused=false;
  autorun_loopCount=0;
  autorun_playing=true;
  if (autorun_playing==false)autorun_backup=currentLedTime;
  if (frameSliderLoop.bypass) {
    if (startFrom==false||currentLedTime==frameSlider.maxI) {
      currentLedTime=0;
    }
  } else {
    if (startFrom==false||currentLedTime>=frameSliderLoop.valueE) {
      currentLedTime=(int)frameSliderLoop.valueS;
    }
  }
}
void autoRunRewind() {
  autorun_loopCount=0;
  autorun_playing=true;
  if (frameSliderLoop.bypass) {
    currentLedTime=0;
  } else {
    currentLedTime=(int)frameSliderLoop.valueS;
  }
}
int getFrameByTime(int time) {
  int sum=0;
  int a=0;
  int frame=0;
  while (a<DelayValue.size()) {
    sum=sum+DelayValue.get(a);
    if (time<sum) {
      break;
    }
    frame++;
    a=a+1;
  }
  return frame;
}