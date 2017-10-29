import com.karnos.commandscript.*;
UnipackCommands ledCommands;
void script_setup() {
  ledCommands=new UnipackCommands();
  ledCommands.addCommand(new ParamInfo("on", Parameter.FIXED, "o"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p"));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("rnd"));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("rnd"));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX));
  //mc on
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p"));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("rnd"));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("rnd"));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX));
  //normal off
  ledCommands.addCommand(new ParamInfo("off", Parameter.FIXED, "f"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE));
  //delay
  ledCommands.addCommand(new ParamInfo("delay", Parameter.FIXED, "d"), new ParamInfo("value", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("delay"), new ParamInfo("fraction", Parameter.STRING));
  //bpm
  ledCommands.addCommand(new ParamInfo("bpm", Parameter.FIXED, "b"), new ParamInfo("value", Parameter.FLOAT));
  //chain
  ledCommands.addCommand(new ParamInfo("chain", Parameter.FIXED, "c"), new ParamInfo("c", Parameter.INTEGER));
  //mapping
  ledCommands.addCommand(new ParamInfo("mapping", Parameter.FIXED, "m"), new ParamInfo("s"), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("n", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("mapping"), new ParamInfo("l"), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("n", Parameter.INTEGER));
}
class LedScript {
  String name;
  Script script;
  LedProcesser processer;
  public LedScript(String name_) {
    name=name_;
    processer=new LedProcesser();
    script=new Script(name, ledCommands, processer);
  }
}
public LedScript loadLedScript(String name_, String text) {//line ending have to be normalized.
  LedScript ledScript=new LedScript(name_);
  ledScript.insert(0, 0, text);
  return ledScript;
}
static class UnipackCommands extends LineCommandType {
  @Override
    public Command getCommand(Analyzer analyzer, String commandName, ArrayList<String> params) {
    //add additional errors to analyzer.
    if (commandName.equals("a x y")) {
      return getEmptyCommand();
    }
    return getErrorCommand();
  }
  @Override
    public Command getErrorCommand() {
    return new ErrorCommand();
  }
  @Override
    public Command getEmptyCommand() {
    return new EmptyCommand();
  }
}
class LedProceser extends LineCommandProcesser {
  static final int LED_CMDSET=1;
  static final int UNITOR_CMDSET=2;
  static final int AUTOPLAY_CMDSET=3;
  Script script;
  ArrayList<color[][]> LED;
  Multiset<Integer> DelayPoint;
  Multiset<Integer> BpmPoint;
  int ButtonX;
  int ButtonY;
  int mode;
  public LedProcesser(Script script_, int ButtonX_, int ButtonY_) {
    script=script_;
    resize(ButtonX_, ButtonY_);
    mode=LED_CMDSET;
  }
  int getFrame(int line) {
    return DelayPoint.getBeforeIndex(line-1)-1;//find frame with delay is meaningless.
  }
  int getBpm(int line) {
    int index=BpmPoint.getBeforeIndex(line-1)-1;
    if (index==0)return 120;
    //assert script.getCommands().get(index) instanceof BpmCommand
    return ((BpmCommand)script.getCommands().get(index)).bpm;
  }
  int getDelayValue(int line) {//milliseconds.
    if (line==-1)return 0;
    //assert script.getCommands().get(index) instanceof DelayCommand
    DelayCommand info=(DelayCommand)script.getCommands().get(line);
    if (info.isFraction) {
      return floor((info.up*2400/(getBpm(line)*info.down))*100);
    } else return info.value;
  }
  void resize(int ButtonX_, int ButtonY_) {
    ButtonX=ButtonX_;
    ButtonY=ButtonY_;
    clear();
    script.readAll();
  }
  @Override
    public void processCommand(int line, Command before, Command after) {
    surface.setTitle(title_filename+title_edited+title_suffix+" - reading...("+script.getProgress()+"/"+script.getTotal()+")");
    int frame=getFrame(line);
    if (after==null) {
      uLines.remove(line.line);
      for (int a=DelayPoint.size()-1; a>0&&line<DelayPoint.get(a); a--) {
        DelayPoint.set(a, DelayPoint.get(a)-1);
      }
      for (int a=BpmPoint.size()-1; a>0&&line.line<BpmPoint.get(a); a--) {
        BpmPoint.set(a, BpmPoint.get(a)-1);
      }
    }//else 
    if (before==null) {
      for (int a=DelayPoint.size()-1; a>0&&line.line<=DelayPoint.get(a); a--) {
        DelayPoint.set(a, DelayPoint.get(a)+1);
      }
      for (int a=BpmPoint.size()-1; a>0&&line.line<=BpmPoint.get(a); a--) {
        BpmPoint.set(a, BpmPoint.get(a)+1);
      }
    }
    if (before!=null) {
      if (before instanceof OnCommand) {
        OnCommand info=(OnCommand)before;
        if (!info.mc) {
          for (int a=info.x1; a<=info.x2; a++) {
            for (int b=info.y1; b<=info.y2; b++) {
              deleteLedPosition(frame, line+(after==null?0:1), a, b);
            }
          }
        }
      } else if (before instanceof OffCommand) {
        OffCommand info=(OffCommand)before;
        if (!info.mc) {
          for (int a=info.x1; a<=info.x2; a++) {
            for (int b=info.y1; b<=info.y2; b++) {
              deleteLedPosition(frame, line+(after==null?0:1), a, b);
            }
          }
        }
      } else if (before instanceof DelayCommand) {
        int index=DelayPoint.getBeforeIndex(line-1);
        //assert DelayCommand.get(index)==line
        DelayPoint.remove(index);
        LED.remove(frame);//assert frame>=1
        if (currentLedFrame>LED.size()-1)currentLedFrame--;
      } else if (before instanceof BpmCommand) {
        int index=BpmPoint.getBeforeIndex(line-1);
        //assert BpmCommand.get(index)==line
        BpmPoint.remove(index);
      }
    }
    if (after!=null) {
      if (after.Type==UnipackLine.ON) {
        if (after.mc==false) {
          if (after.hasVel) {
            if (after.vel>=0&&after.vel<128) {
              for (int a=after.x; a<=after.x2; a++) {
                for (int b=after.y; b<=after.y2; b++) {
                  readFrameLedPosition(frame, line.line, a, b, k[after.vel], after);
                }
              }
            }
          } else if (after.hasHtml) {
            for (int a=after.x; a<=after.x2; a++) {
              for (int b=after.y; b<=after.y2; b++) {
                readFrameLedPosition(frame, line.line, a, b, after.html, after);
              }
            }
          }
        } else if (ignoreMc==false) {
          adderror=true;
          printError(4, line.line, "LedEditor", line.after, "mc is unitor command. enable ignoreMc to disable unitor errors.");
          adderror=false;
        }
      } else if (after.Type==UnipackLine.OFF) {
        if (after.mc==false) {
          for (int a=after.x; a<=after.x2; a++) {
            for (int b=after.y; b<=after.y2; b++) {
              readFrameLedPosition(frame, line.line, a, b, OFFCOLOR, after);
              readFrameApLedPosition(frame, line.line, a, b, false, after);
            }
          }
        } else if (ignoreMc==false) {
          adderror=true;
          printError(4, line.line, "LedEditor", line.after, "mc is unitor command. enable ignoreMc to disable unitor errors.");
          adderror=false;
        }
      } else if (after.Type==UnipackLine.DELAY) {
        int a=DelayPoint.size();
        while (line.line<=DelayPoint.get(a-1)&&a>1)a--;//a cant be 0.
        DelayPoint.add(a, line.line);
        LED.add(frame+1, new color[ButtonX][ButtonY]);
        apLED.add(frame+1, new boolean[ButtonX][ButtonY]);
        readFrameLed(frame, 2);
        sliderUpdate=true;
      } else if (after.Type==UnipackLine.BPM) {
        int a=BpmPoint.size();
        while (line.line<=BpmPoint.get(a-1)&&a>1)a--;
        BpmPoint.add(a, line.line);
        sliderUpdate=true;
      } else if (after.Type==UnipackLine.CHAIN) {
        if (Mode!=CYXMODE) {//unitor keyword
          if (ignoreMc==false) {
            adderror=true;
            printError(4, line.line, "LedEditor", line.after, "mc is unitor command. enable ignoreMc to disable unitor errors.");
            adderror=false;
          }
        }
        int a=apChainPoint.size();
        while (line.line<=apChainPoint.get(a-1)&&a>1)a--;
        apChainPoint.add(a, line.line);
      } else if (after.Type==UnipackLine.MAPPING) {
        adderror=true;
        if (Mode==CYXMODE) {//unitor keyword
          printError(3, line.line, "LedEditor", line.after, "can't use led command in autoPlay file.");
        }
        if (ignoreMc==false) {
          adderror=true;
          printError(4, line.line, "LedEditor", line.after, "mc is unitor command. enable ignoreMc to disable unitor errors.");
          adderror=false;
        }
        adderror=false;
      }
    }
  }
  @Override
    public void onReadFinished() {
    surface.setTitle(title_filename+title_edited+title_suffix);
  }
  @Override
    public void clear() {
    LED=null;
    DelayPoint=null;
    BpmPoint=null;
    LED=new ArrayList<color[][]>();
    DelayPoint=new Multiset<Integer>();
    BpmPoint=new Multiset<Integer>();
    LED.add(new color[ButtonX][ButtonY]);
    DelayPoint.add(-1);
    BpmPoint.add(-1);
  }
}
class ErrorCommand implements Command {
  @Override
    public String toString() {
    return "*error*";
  }
  @Override
    public void execute(int time) {
  }
}
class EmptyCommand implements Command {
  @Override
    public String toString() {
    return "*empty*";
  }
  @Override
    public void execute(int time) {
  }
}