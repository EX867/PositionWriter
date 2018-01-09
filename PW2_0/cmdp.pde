
public LedScript loadLedScript(String name_, String text) {//line ending have to be normalized.
  LedScript ledScript=new LedScript(name_);
  ledScript.insert(0, 0, text);
  return ledScript;
}
class LedScript extends CommandScript {
  CommandEdit editor;//linked editor
  ArrayList<color[][]> LED;
  Multiset<Integer> DelayPoint;
  Multiset<Integer> BpmPoint;
  Multiset<Integer> ChainPoint;
  LineCommandType cmdset;
  boolean bypass=false;//used when speed is required.
  boolean ignoreUnitorCmd=false;
  int displayFrame=0;
  int displayTime=0;
  public LedScript(String name_) {
    super(name_, ledCommands, null);
    setAnalyzer(ledCommands, new LedProcessor());
  }
  void setCmdSet(LineCommandType cmdset_) {
    cmdset=cmdset_;
    readAll();
  }
  LineCommandType getCmdSet() {
    return cmdset;
  }
  void readAll() {
    bypass=true;
    super.readAll();
    bypass=false;
    ((LedProcessor)analyzer.getProcessor()).readAll();//optimization...
  }
  int getFrame(int line) {
    if (line<0)return 0;
    return DelayPoint.getBeforeIndex(line-1)-1;//find frame with delay is meaningless.
  }
  float getBpm(int line) {
    int index=BpmPoint.getBeforeIndex(line-1)-1;
    if (index==0)return DEFAULT_BPM;
    //assert script.getCommands().get(index) instanceof BpmCommand
    return ((BpmCommand)getCommands().get(index)).value;
  }
  int getDelayValue(int line) {//milliseconds.
    if (line==-1)return 0;
    //assert script.getCommands().get(index) instanceof DelayCommand
    DelayCommand info=(DelayCommand)getCommands().get(line);
    if (info.isFraction) {
      return floor((info.up*2400/(getBpm(line)*info.down))*100);
    } else return info.up;
  }
  int getFrameLength() {
    return DelayPoint.size();
  }
  int getDelayValueByFrame(int frame) {//last frame returns 0.
    if (frame==DelayPoint.size()-1) {
      return 0;
    }
    return getDelayValue(DelayPoint.get(frame+1));
  }
  void resize() {//resize to ButtonX,ButtonY.
    analyzer.clear();
    readAll();
  }
  void setTimeByFrame() {
    displayTime=getTimeByFrame(displayFrame);
  }
  void setTimeByFrame(int frame) {
    displayTime=getTimeByFrame(frame);
  }
  int getTimeByFrame(int frame) {
    int time=0;
    for (int a=1; a<=frame; a++) {
      time+=getDelayValue(DelayPoint.get(a));
    }
    return time;
  }
  void setFrameByTime() {
    displayFrame=getFrameByTime(displayTime);
  }
  void setFrameByTime(long time) {
    displayFrame=getFrameByTime(time);
  }
  int getFrameByTime(long time) {
    int sum=0;
    int frame=0;
    for (int a=1; a<DelayPoint.size(); a++) {
      sum=sum+getDelayValue(DelayPoint.get(a));
      if (time<sum) {
        break;
      }
      frame++;
    }
    return frame;
  }
  class LedProcessor extends LineCommandProcessor {
    LedScript script;
    public LedProcessor() {
      resize();
      script=LedScript.this;
    }
    public void processCommand(Analyzer analyzer, int line, Command before, Command after) {
      setTitleProcessing("reading...("+script.getProgress()+"/"+script.getTotal()+")");
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
          if (displayFrame>LED.size()-1)displayFrame--;
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
          if (!ignoreUnitorCmd) {//int type_, int line_, int start_, int end_, String location_, String cause_
            script.addError(new LineError(LineError.WARNING, line, 0, script.getLine(line).length(), script.name, "you can't use unitor command in normal led."));
          }
        } else if (after instanceof LightCommand) {//includes on and off.
          LightCommand info=(LightCommand)after;
          for (int a=info.x1; a<=info.x2; a++) {
            for (int b=info.y1; b<=info.y2; b++) {
              insertLedPosition(frame, line+(after==null?0:1), a, b, info.htmlc);
            }
          }
        } else if (after instanceof DelayCommand) {
          DelayPoint.add(line);
          LED.add(frame+1, new color[info.buttonX][info.buttonY]);
          readFramesLed(frame, 2);
        } else if (after instanceof BpmCommand) {
          BpmPoint.add(line);
        } else if (after instanceof ChainCommand) {
          if (!(cmdset==apCommands||!ignoreUnitorCmd)) {//chain is duplication so add error manually...
            script.addError(new LineError(LineError.WARNING, line, 0, script.getLine(line).length(), script.name, "you can't use chain command in normal led."));
          }
          ChainPoint.add(line);
        }
      }
    }
    void readAll() {
      ArrayList<Command> commands=script.getCommands();
      //float bpm=DEFAULT_BPM;
      int line=0;
      for (Command cmd : commands) {
        if (cmd instanceof LightCommand) {
          LightCommand data=(LightCommand)cmd;
          for (int a=max(1, data.x1); a<=info.buttonX&&a<=data.x2; a++) {
            for (int b=max(1, data.y1); b<=info.buttonY&&b<=data.y2; b++) {
              LED.get(LED.size()-1)[a-1][b-1]=data.htmlc;
            }
          }
        } else if (cmd instanceof DelayCommand) {
          LED.add(new color[info.buttonX][info.buttonY]); 
          for (int a=0; a<info.buttonX; a++) {
            for (int b=0; b<info.buttonY; b++) {
              LED.get(LED.size()-1)[a][b]=LED.get(LED.size()-2)[a][b];
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
      displayFrame=min(displayFrame, DelayPoint.size()-1); 
      setTimeByFrame(displayFrame);
    }
    void insertLedPosition(int frame, int line, int x, int y, color c) {
      if (line>=script.lines())return;
      if (0<x&&x<=info.buttonX&&0<y&&y<=info.buttonY) {
        ArrayList<Command> commands=script.getCommands();
        boolean changed=false;
        color toSet=c;
        for (; line<script.lines(); line++) {
          Command cmd=commands.get(line);
          if (cmd instanceof LightCommand) {
            LightCommand info=(LightCommand)cmd;
            if (info.x1<=x&&x<=info.x2&&info.y1<=y&&y<=info.y2) {
              toSet=info.htmlc;
              changed=true;
            }
          } else if (cmd instanceof DelayCommand) {
            if (changed==false) {
              LED.get(frame)[x-1][y-1]=toSet;
            } else {
              break;
            }
            frame++;
          }
        }
        if (changed==false&&line==script.lines()) {
          LED.get(frame)[x-1][y-1]=toSet;
        }
      }
    }
    void deleteLedPosition(int frame, int x, int y) {
      if (frame==0) {
        LED.get(frame)[x-1][y-1]=COLOR_OFF;
      } else {
        LED.get (frame)[x-1][y-1]=LED.get (frame-1)[x-1][y-1];
      }
      int max=script.lines();
      if (frame<DelayPoint.size()-1)max=DelayPoint.get(frame+1);
      for (int a=DelayPoint.get (frame)+1; a <max; a++) {
        Command cmd=script.getCommands().get(a);
        if (cmd instanceof LightCommand) {
          LightCommand info=(LightCommand)cmd;
          if (info.x1<=x&&x<=info.x2&&info.y1<=y&&y<=info.y2)LED.get(frame)[x-1][y-1]=info.htmlc;
        }
      }
      insertLedPosition (frame+1, max, x, y, LED.get (frame)[x-1][y-1]);
    }
    void readFramesLed(int frame, int count) {
      if (frame==0) {
        for (int a=0; a<info.buttonX; a++) {
          for (int b=0; b<info.buttonY; b++) {
            LED.get(frame)[a][b]=COLOR_OFF;
          }
        }
      } else {
        for (int a=0; a<info.buttonX; a++) {
          for (int b=0; b<info.buttonY; b++) {
            LED.get(frame)[a][b]=LED.get(frame-1)[a][b];
          }
        }
      }
      int d=DelayPoint.get(frame)+1;
      count=frame+count;
      ArrayList<Command> commands=script.getCommands();
      for (; frame<=count&&d<script.lines(); d++) {//reset
        Command cmd=commands.get(d);//AnalyzeLine(a, "readFrame - read "+count+" frames", Lines.getLine(a));
        if (cmd instanceof LightCommand) {
          LightCommand info=(LightCommand)cmd;
          for (int a=info.x1; a<=info.x2; a++) {
            for (int b=info.y1; b<=info.y2; b++) {
              LED.get(frame)[a-1][b-1]=info.htmlc;
            }
          }
        } else if (cmd instanceof DelayCommand) {
          frame++;
          for (int a=0; a<info.buttonX; a++) {
            for (int b=0; b<info.buttonY; b++) {
              LED.get(frame)[a][b]=LED.get(frame-1)[a][b];
            }
          }
        }
      }
    }

    public void onReadFinished(Analyzer analyzer) {
      setTitleProcessing();
    }

    public void clear(Analyzer analyzer) {
      LED=null; 
      DelayPoint=null; 
      BpmPoint=null; 
      LED=new ArrayList<color[][]>(); 
      DelayPoint=new Multiset<Integer>(); 
      BpmPoint=new Multiset<Integer>(); 
      ChainPoint=new Multiset<Integer>(); 
      LED.add(new color[info.buttonX][info.buttonY]); 
      DelayPoint.add(-1); 
      BpmPoint.add(-1); 
      ChainPoint.add(-1);
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