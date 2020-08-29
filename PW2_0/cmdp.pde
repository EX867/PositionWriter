public LedScript loadLedScript(String name_, String text) {//line ending have to be normalized.
  LedScript ledScript=new LedScript(name_, null);
  ledScript.insert(0, 0, text);
  return ledScript;
}
public LedScript loadApScript(String name_, String text) {
  LedScript ledScript=new LedScript(name_, null);
  ledScript.setCmdSet(apCommands);
  ledScript.insert(0, 0, text);
  return ledScript;
}
public class LedScript extends CommandScript {
  public CommandEdit editor;//linked editor
  //file management
  public File file;
  public boolean changed=false;
  long lastSaveTime=System.currentTimeMillis();
  public LedTab tab;//if this is led editor, linke to this! then change name will work.
  private boolean tabchanged=false;
  //
  public UnipackInfo info=new UnipackInfo(((TextBox)KyUI.get("set_dbuttony")).valueI, ((TextBox)KyUI.get("set_dbuttonx")).valueI);
  public ArrayList<color[][]> LED;
  public ArrayList<int[][]> velLED;
  public Multiset<Integer> DelayPoint;
  public Multiset<Integer> BpmPoint;
  public Multiset<Integer> ChainPoint;
  public Multiset<Long> delayValue=new Multiset<Long>();//updated frequently. this delayValue array contains accumulated delay value from frame 0.
  public boolean delayValueInvalidated=true;
  public LineCommandType cmdset;
  public LedProcessor processor;
  public PadButton displayPad;
  public boolean bypass=false;//used when speed is required.
  public boolean ignoreUnitorCmd=false;
  public int displayFrame=0;
  public long displayTime=0;
  CommandEdit.MarkRange loopStartRange;
  CommandEdit.MarkRange loopEndRange;
  CommandEdit.MarkRange frameSliderRange;
  public long FrameSliderBackup;//backup time.used in startfromcursor and autostop.
  public LedScript(String name_, PadButton displayPad_) {//editor,displayPad is nullable.
    super(getFileName(name_), null);
    file=new File(name_);
    lastSaveTime=file.lastModified();
    displayPad=displayPad_;
    processor=new LedProcessor();
    processor.clear(null);
    setCmdSet(ledCommands);
    readAll();
    setChanged(false, false);
  }
  public void setEditor(CommandEdit editor_) {    
    editor=editor_;
    setCmdSet(ledCommands);//???
    loopStartRange=editor.addMarkRange(0x3FFF0000);
    loopEndRange=editor.addMarkRange(0x3F0000FF);
    //frameSliderRange=editor.addMarkRange(0x3F000000);
    frameSliderRange=editor.addMarkRange(0x3F00D4FF);
  }
  void setCmdSet(LineCommandType cmdset_) {
    cmdset=cmdset_;
    if (editor==null) {
      setAnalyzer(new DelimiterParser(cmdset, processor));
    } else {
      editor.setContent(this);
      processor.clear(null);
      editor.setAnalyzer(new DelimiterParser(cmdset, processor));
    }
  }
  LineCommandType getCmdSet() {
    return cmdset;
  }
  public void reload() {
    if (file!=null) {
      setText(readFile(file.getAbsolutePath()));
      editor.invalidate();
      setChanged(false, false);
    }
  }
  public void readAll() {
    bypass=true;
    super.readAll();
    bypass=false;
    if (processor!=null) {
      processor.readAll();//optimization...
    }
  }
  int getFrame(int line) {
    if (line<0)return 0;
    return DelayPoint.getBeforeIndex(line-1)-1;//find frame with delay is meaningless.
  }
  float getBpm(int line) {
    int index=BpmPoint.getBeforeIndex(line-1)-1;
    if (index>=BpmPoint.size()) {
      index=BpmPoint.size()-1;
    }
    index=BpmPoint.get(index);
    if (index==-1)return DEFAULT_BPM;
    //assert script.getCommands().get(index) instanceof BpmCommand
    return ((BpmCommand)getCommands().get(index)).value;
  }
  int getDelayValue(int line) {//milliseconds.
    if (line==-1)return 0;
    //assert script.getCommands().get(index) instanceof DelayCommand
    DelayCommand info=(DelayCommand)getCommands().get(line);
    if (info.isFraction) {
      return round(info.up*240000/(getBpm(line)*info.down));
    } else return info.up;
  }
  int getFrameCount() {
    return DelayPoint.size();
  }
  int getDelayValueByFrame(int frame) {//last frame returns 0.
    if (frame==DelayPoint.size()-1) {
      return 0;
    }
    return getDelayValue(DelayPoint.get(frame+1));
  }
  void resize(int x, int y) {//resize to ButtonX,ButtonY.
    info.buttonX=x;
    info.buttonY=y;
    if (displayPad!=null) {
      displayPad.resizePad(x, y);
    }
    analyzer.clear();
    readAll();
  }
  void setTimeByFrame() {
    displayTime=getTimeByFrame(displayFrame);
  }
  void setTimeByFrame(int frame) {
    displayTime=getTimeByFrame(frame);
  }
  long getTimeByFrame(int frame) {
    if (delayValueInvalidated) {
      delayValue=calculateDelayValue(LedScript.this, delayValue);
      delayValueInvalidated=false;
    }
    //int time=0;
    //for (int a=1; a<=frame&&a<DelayPoint.size(); a++) {//a<DelayPoint... is just for error handling.
    //  time+=getDelayValue(DelayPoint.get(a));
    //}
    //return time;
    return delayValue.get(frame);
  }
  void setFrameByTime() {
    setDisplayFrame(getFrameByTime(displayTime));
  }
  void setFrameByTime(long time) {
    setDisplayFrame(getFrameByTime(time));
  }
  int getFrameByTime(long time) {
    if (delayValueInvalidated) {
      delayValue=calculateDelayValue(LedScript.this, delayValue);
      delayValueInvalidated=false;
    }
    //int sum=0;
    //int frame=0;
    //for (int a=1; a<DelayPoint.size(); a++) {
    //  sum=sum+getDelayValue(DelayPoint.get(a));
    //  if (time<sum) {
    //    break;
    //  }
    //  frame++;
    //}
    //return frame;
    return delayValue.getBeforeIndex(time)-1;
  }
  void setDisplayFrame(int frame) {
    displayFrame=frame;
    if (frameSliderRange!=null) {
      frameSliderRange.startLine=DelayPoint.get(frame)+1;
      if (frame+1<DelayPoint.size()) {
        frameSliderRange.endLine=DelayPoint.get(frame+1)+1;
      } else {
        frameSliderRange.endLine=editor.script.lines();
      }
      editor.invalidate();
      editor.getSlider().invalidate();
    }
  }
  void updateSlider() {
    if (currentLedEditor==this) {
      fs.set(0, getTimeByFrame(DelayPoint.size()-1));
      fs.invalidate();
      fs.set(displayTime);
      fsTime.text=displayTime+"/"+fs.maxI;
      fsTime.invalidate();
    }
  }
  void updateLoopRange() {
    if (tab==null||editor==null)return;
    if (tab.led.loopStart>=tab.led.loopEnd) {//no loop range
      loopStartRange.startLine=0;
      loopStartRange.endLine=0;
      loopEndRange.startLine=0;
      loopEndRange.endLine=0;
    } else {
      int startFrame=getFrameByTime(fs.valueS);
      int endFrame=getFrameByTime(fs.valueE);
      loopStartRange.startLine=DelayPoint.get(startFrame)+1;
      if (startFrame+1<currentLedEditor.DelayPoint.size()) {
        loopStartRange.endLine=DelayPoint.get(startFrame+1)+1;
      } else {
        loopStartRange.endLine=editor.script.lines();
      }
      loopEndRange.startLine=DelayPoint.get(endFrame)+1;
      if (endFrame+1<DelayPoint.size()) {
        loopEndRange.endLine=DelayPoint.get(endFrame+1)+1;
      } else {
        loopEndRange.endLine=editor.script.lines();
      }
    }
  }
  void updateFs(long time) {
    fs.set(time);
    fs.invalidate();
    fsTime.text=time+"/"+fs.maxI;
    fsTime.invalidate();
  }
  void displayControl() {
    if (currentLedEditor==this) {
      if (displayPad!=null) {
        currentLed.light.checkDisplay(displayPad);
        displayPad.displayControl(LED.get(displayFrame));
        displayPad.invalidate();
      }
      midiControl();
    }
  }
  void midiControl() {
    currentLed.light.midiControl(velLED.get(displayFrame));
  }
  void setChanged(boolean v, boolean force) {
    if (v) {
      if (tab!=null&&(!tabchanged||force)) {
        int index=ledTabs.indexOf(tab);
        if (index>=0) {
          led_filetabs.setTabName(index, getFileName(file.getAbsolutePath())+"*");
        }
        tabchanged=true;
        led_filetabs.invalidate();
      }
      changed=true;
    } else {
      if (tab!=null&&(tabchanged||force)) {
        int index=ledTabs.indexOf(tab);
        if (index>=0) {
          led_filetabs.setTabName(index, getFileName(file.getAbsolutePath()));
        }
        tabchanged=false;
        led_filetabs.invalidate();
      }
      changed=false;
    }
  }
  void infiniteLoopOff(int[][] display, int[][] velDisplay) {
    int[][] lastFrame=LED.get(LED.size()-1);
    int[][] velLastFrame=velLED.get(velLED.size()-1);
    for (int a=0; a<lastFrame.length; a++) {
      for (int b=0; b<lastFrame[a].length; b++) {
        if (lastFrame[a][b]!=COLOR_OFF) {
          display[a][b]=COLOR_OFF;
        }
        if (velLastFrame[a][b]!=COLOR_OFF) {
          velDisplay[a][b]=COLOR_OFF;
        }
      }
    }
  }
  class LedProcessor extends LineCommandProcessor {
    public LedProcessor() {
      resize(info.buttonX, info.buttonY);
    }
    public void processCommand(Analyzer analyzer, int line, Command before, Command after) {
      if(before!=null&&after!=null&&before.toString().trim().equals(after.toString().trim()))return;//optimize line breaks
      setChanged(true, false);
      //println("\""+before+"\" to \""+after+"\" line "+line);
      if (getProgress()%100==0) {//for window manager!!
        setTitleProcessing("reading...("+getProgress()+"/"+getTotal()+")");
      }
      //println("processing "+before+" -> "+after+" "+(before==null?"":before.getClass())+" "+(after==null?"":after.getClass()));
      if (bypass)return;
      int frame=getFrame(line);
      if (after==null) {
        for (int a=DelayPoint.size()-1; a>0&&line<DelayPoint.get(a); a--) {
          DelayPoint.set(a, DelayPoint.get(a)-1);
        }
        for (int a=BpmPoint.size()-1; a>0&&line<BpmPoint.get(a); a--) {
          BpmPoint.set(a, BpmPoint.get(a)-1);
        }
        for (int a=ChainPoint.size()-1; a>0&&line<ChainPoint.get(a); a--) {
          ChainPoint.set(a, ChainPoint.get(a)-1);
        }
      }//else 
      if (before==null) {
        for (int a=DelayPoint.size()-1; a>0&&line<=DelayPoint.get(a); a--) {
          DelayPoint.set(a, DelayPoint.get(a)+1);
        }
        for (int a=BpmPoint.size()-1; a>0&&line<=BpmPoint.get(a); a--) {
          BpmPoint.set(a, BpmPoint.get(a)+1);
        }
        for (int a=ChainPoint.size()-1; a>0&&line<ChainPoint.get(a); a--) {
          ChainPoint.set(a, ChainPoint.get(a)+1);
        }
      }
      if (before!=null) {
        if (before instanceof LightCommand) {//includes on and off.
          LightCommand info=(LightCommand)before;
          info.sortPos();
          for (int a=info.x1; a<=info.x2; a++) {
            for (int b=info.y1; b<=info.y2; b++) {
              deleteLedPosition(frame, a, b);//line+(after==null?0:1)
            }
          }
        } else if (before instanceof DelayCommand) {
          int index=DelayPoint.getBeforeIndex(line-1);
          //assert DelayCommand.get(index)==line
          DelayPoint.remove(index);
          LED.remove(frame);//assert frame>=1
          velLED.remove(frame);
        } else if (before instanceof BpmCommand) {
          int index=BpmPoint.getBeforeIndex(line-1);
          //assert BpmCommand.get(index)==line
          BpmPoint.remove(index);
        } else if (before instanceof ChainCommand) {
          int index=ChainPoint.getBeforeIndex(line-1);
          //assert ChainCommand.get(index)==line
          ChainPoint.remove(index);
        }
      }
      if (after!=null) {
        if (after instanceof UnitorCommand) {
          //if (cmdset==ledCommands) {
          //  addError(new LineError(LineError.WARNING, line, 0, getLine(line).length(), name, "you can't use unitor command in normal led."));
          //}
        } else if (after instanceof LightCommand) {//includes on and off.
          LightCommand info=(LightCommand)after;
          info.sortPos();
          for (int a=info.x1; a<=info.x2; a++) {
            for (int b=info.y1; b<=info.y2; b++) {
              insertLedPosition(frame, line, a, b, info.htmlc, info.vel);
            }
          }
        } else if (after instanceof DelayCommand) {
          DelayPoint.add(line);
          LED.add(frame+1, new color[info.buttonX][info.buttonY]);
          velLED.add(frame+1, new int[info.buttonX][info.buttonY]);
          readFramesLed(frame, 2);
        } else if (after instanceof BpmCommand) {
          BpmPoint.add(line);
        } else if (after instanceof ChainCommand) {
          if (cmdset!=apCommands) {//chain is duplication so add error manually...
            addError(new LineError(LineError.WARNING, line, 0, getLine(line).length(), name, "you can't use chain command in normal led."));
          }
          ChainPoint.add(line);
        }
      }
      if (displayFrame>= DelayPoint.size()) {
        setDisplayFrame(DelayPoint.size()-1);
        setTimeByFrame(displayFrame);
      }
      if (after instanceof DelayCommand || before instanceof DelayCommand ||after instanceof BpmCommand ||before instanceof BpmCommand) {
        delayValueInvalidated=true;
        updateSlider();
      }
      setDisplayFrame(displayFrame);
      updateLoopRange();
      displayControl();
    }
    void readAll() {
      ArrayList<Command> commands=getCommands();
      //float bpm=DEFAULT_BPM;
      int line=0;
      for (Command cmd : commands) {
        if (cmd instanceof LightCommand) {
          LightCommand data=(LightCommand)cmd;
          for (int a=max(1, data.x1); a<=info.buttonX&&a<=data.x2; a++) {
            for (int b=max(1, data.y1); b<=info.buttonY&&b<=data.y2; b++) {
              LED.get(LED.size()-1)[a-1][b-1]=data.htmlc;
              velLED.get(velLED.size()-1)[a-1][b-1]=data.vel;
            }
          }
        } else if (cmd instanceof DelayCommand) {
          LED.add(new color[info.buttonX][info.buttonY]); 
          velLED.add(new int[info.buttonX][info.buttonY]); 
          for (int a=0; a<info.buttonX; a++) {
            for (int b=0; b<info.buttonY; b++) {
              LED.get(LED.size()-1)[a][b]=LED.get(LED.size()-2)[a][b];
              velLED.get(velLED.size()-1)[a][b]=velLED.get(velLED.size()-2)[a][b];
            }
          }
          DelayPoint.add(line);
        } else if (cmd instanceof BpmCommand) {
          BpmPoint.add(line);
        } else if (cmd instanceof ChainCommand) {
          ChainPoint.add(line);
        }//else ignore
        line++;
      }
      delayValueInvalidated=true;
      setDisplayFrame(min(displayFrame, DelayPoint.size()-1));
      setTimeByFrame(displayFrame);
      //delayValue=calculateDelayValue(LedScript.this, delayValue);
      updateSlider();
      displayControl();
    }
    void insertLedPosition(int frame, int line, int x, int y, color c, int vel) {
      if (line>=getCommands().size())return;
      line=line+1;//skip that line.
      if (0<x&&x<=info.buttonX&&0<y&&y<=info.buttonY) {
        ArrayList<Command> commands=getCommands();
        color toSet=c;
        color toSetVel=vel;
        for (; line<getCommands().size(); line++) {
          Command cmd=commands.get(line);
          if (cmd instanceof LightCommand) {
            LightCommand info=(LightCommand)cmd;
            //println("insert : process "+info);
            if (info.x1<=x&&x<=info.x2&&info.y1<=y&&y<=info.y2) {
              toSet=info.htmlc;
              toSet=info.vel;
              return;
            }
          } else if (cmd instanceof DelayCommand) {
            LED.get(frame)[x-1][y-1]=toSet;
            velLED.get(frame)[x-1][y-1]=toSetVel;
            frame++;
          }
        }
        LED.get(frame)[x-1][y-1]=toSet;
        velLED.get(frame)[x-1][y-1]=toSetVel;
      }
    }
    void deleteLedPosition(int frame, int x, int y) {
      if (frame==0) {
        LED.get(frame)[x-1][y-1]=COLOR_OFF;
        velLED.get(frame)[x-1][y-1]=COLOR_OFF;
      } else if (frame>0) {
        LED.get (frame)[x-1][y-1]=LED.get (frame-1)[x-1][y-1];
        velLED.get (frame)[x-1][y-1]=velLED.get (frame-1)[x-1][y-1];
      }
      int max=getCommands().size();
      if (frame<DelayPoint.size()-1)max=DelayPoint.get(frame+1);
      for (int a=DelayPoint.get (frame)+1; a <max; a++) {
        Command cmd=getCommands().get(a);
        if (cmd instanceof LightCommand) {
          LightCommand info=(LightCommand)cmd;
          //println("delete : process "+info);
          if (info.x1<=x&&x<=info.x2&&info.y1<=y&&y<=info.y2) {
            LED.get(frame)[x-1][y-1]=info.htmlc;
            velLED.get(frame)[x-1][y-1]=info.vel;
          }
        }
      }
      insertLedPosition (frame+1, max, x, y, LED.get (frame)[x-1][y-1], velLED.get (frame)[x-1][y-1]);
    }
    void readFramesLed(int frame, int count) {
      if (frame==0) {
        for (int a=0; a<info.buttonX; a++) {
          for (int b=0; b<info.buttonY; b++) {
            LED.get(frame)[a][b]=COLOR_OFF;
            velLED.get(frame)[a][b]=COLOR_OFF;
          }
        }
      } else {
        for (int a=0; a<info.buttonX; a++) {
          for (int b=0; b<info.buttonY; b++) {
            LED.get(frame)[a][b]=LED.get(frame-1)[a][b];
            velLED.get(frame)[a][b]=velLED.get(frame-1)[a][b];
          }
        }
      }
      int d=DelayPoint.get(frame)+1;
      count=frame+count;
      ArrayList<Command> commands=getCommands();
      for (; frame<=count&&d<getCommands().size(); d++) {//reset
        Command cmd=commands.get(d);//AnalyzeLine(a, "readFrame - read "+count+" frames", Lines.getLine(a));
        if (cmd instanceof LightCommand) {
          LightCommand info=(LightCommand)cmd;
          for (int a=info.x1; a<=info.x2; a++) {
            for (int b=info.y1; b<=info.y2; b++) {
              LED.get(frame)[a-1][b-1]=info.htmlc;
              velLED.get(frame)[a-1][b-1]=info.vel;
            }
          }
        } else if (cmd instanceof DelayCommand) {
          frame++;
          if(!(frame<=count))break;//remove error from resetting last frame of readFramesLed
          for (int a=0; a<info.buttonX; a++) {
            for (int b=0; b<info.buttonY; b++) {
              LED.get(frame)[a][b]=LED.get(frame-1)[a][b];
              velLED.get(frame)[a][b]=velLED.get(frame-1)[a][b];
            }
          }
        }
      }
    }

    public void onReadFinished(Analyzer analyzer) {
      setTitleProcessing();
    }

    public void clear(Analyzer analyzer) {//analyzer can be null!!
      LED=null; 
      velLED=null; 
      DelayPoint=null; 
      BpmPoint=null; 
      LED=new ArrayList<color[][]>(); 
      velLED=new ArrayList<int[][]>(); 
      DelayPoint=new Multiset<Integer>(); 
      BpmPoint=new Multiset<Integer>(); 
      ChainPoint=new Multiset<Integer>(); 
      LED.add(new color[info.buttonX][info.buttonY]); 
      velLED.add(new int[info.buttonX][info.buttonY]); 
      DelayPoint.add(-1); 
      BpmPoint.add(-1); 
      ChainPoint.add(-1);
      //delayValue=calculateDelayValue(LedScript.this, delayValue);
    }
  }
  //class KsProcessor extends LineCommandProcessor {

  //  public void processCommand(int line, Command before, Command after) {
  //  }

  //  public void onReadFinished() {
  //    setTitleProcessing();
  //  }

  //  public void clear() {
  //  }
  //}
}
