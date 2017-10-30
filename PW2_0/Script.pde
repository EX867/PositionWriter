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
  //ap on
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE));
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
class LedScript extends Script {
  Script script;
  LedProcesser processer;
  public LedScript(String name_) {
    processer=new LedProcesser();
    super(name, ledCommands, processer);
  }
  @Override void readAll() {
    processer.bypass=true;
    super.readAll();
    processer.bypass=false;
    processer.readAll();
  }
}
public LedScript loadLedScript(String name_, String text) {//line ending have to be normalized.
  LedScript ledScript=new LedScript(name_);
  ledScript.insert(0, 0, text);
  return ledScript;
}
static class UnipackCommands extends LineCommandType {
  @Override
    public Command getCommand(Analyzer analyzer, int line, String location, String text, String commandName, ArrayList<String> params) {
    //add additional errors to analyzer
    String[] tokens=split(commandName, " ");
    for (int a=0; a<tokens.length; a++) {
      if (tokens[a].equals("vel")) {
        int vel=int(params.get(a));
        if (vel<0||vel>=128) {
          analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "velocity is out of range."));
          return getErrorCommand();
        }
      } else if (a>0&&tokens[a-1].equals("y")&&tokens[a].equals("x")) {//position.
        int y1=getRangeFirst(params.get(a-1));
        int y2=getRangeSecond(params.get(a-1));
        int x1=getRangeFirst(params.get(a));
        int x2=getRangeSecond(params.get(a));
        if (y1<=0||y1>ButtonY||x1<=0||x1>ButtonX||y2<=0||y2>ButtonY||x2<=0||x2>ButtonX) {
          analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "position is out of range."));
          return getErrorCommand();
        }
      }
    }
    if (commandName.equals("on y x auto vel")) {
      return new OnCommand(false, int(params.get(2)), int(params.get(1)), k[int(parms.get(4))], int(parms.get(4)));
    } else if (commandName.equals("on y x auto vel p")) {
      return new OnCommand(false, int(params.get(2)), int(params.get(1)), k[int(parms.get(4))], int(parms.get(4)), true);
    } else if (commandName.equals("on y x vel")) {
      return new OnCommand(false, int(params.get(2)), int(params.get(1)), k[int(parms.get(3))], int(parms.get(3)));
    } else if (commandName.equals("on y x html vel")) {
      return new OnCommand(false, int(params.get(2)), int(params.get(1)), color(unhex("FF"+parms.get(3))), int(parms.get(4)));
    } else if (commandName.equals("on y x html")) {
      return new OnCommand(false, int(params.get(2)), int(params.get(1)), color(unhex("FF"+parms.get(3))), OFFCOLOR);
    } else if (commandName.equals("on y x auto rnd")) {
      return new OnCommand(false, int(params.get(2)), int(params.get(1)), RNDCOLOR, OFFCOLOR);
    } else if (commandName.equals("on y x rnd")) {
      return new OnCommand(false, int(params.get(2)), int(params.get(1)), RNDCOLOR, OFFCOLOR);
    } else if (commandName.equals("on mc n auto vel")) {
      return new OnCommand(true, int(params.get(2)), k[int(parms.get(4))], int(parms.get(4)));
    } else if (commandName.equals("on mc n auto vel p")) {
      return new OnCommand(true, int(params.get(2)), k[int(parms.get(4))], int(parms.get(4)), true);
    } else if (commandName.equals("on mc n vel")) {
      return new OnCommand(true, int(params.get(2)), k[int(parms.get(4))], int(parms.get(3)));
    } else if (commandName.equals("on mc n html vel")) {
      return new OnCommand(true, int(params.get(2)), color(unhex("FF"+parms.get(3))), int(parms.get(4)));
    } else if (commandName.equals("on mc n html")) {
      return new OnCommand(true, int(params.get(2)), color(unhex("FF"+parms.get(3))), OFFCOLOR);
    } else if (commandName.equals("on mc n auto rnd")) {
      return new OnCommand(true, int(params.get(2)), RNDCOLOR, OFFCOLOR);
    } else if (commandName.equals("on mc n rnd")) {
      return new OnCommand(true, int(params.get(2)), RNDCOLOR, OFFCOLOR);
    } else if (commandName.equals("on y x")) {
      return new ApOnCommand(int(params.get(2)), int(params.get(1)));
    } else if (commandName.equals("off y x")) {
      return new OffCommand(int(params.get(2)), int(params.get(1)));
    } else if (commandName.equals("delay value")) {
      int value=int(params.get(1));
      if (value<0) {
        analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "delay value is negative."));
        return getErrorCommand();
      }
      return new DelayCommand(value);
    } else if (commandName.equals("delay fraction")) {
      if (isFraction(params.get(1))) {
        String[] split=split(params.get(1), "/");
        int up=int(split[0]);
        int down=int(split[1]);
        if (up*down >= 0) {
          if (down!=0) {
            return new DelayCommand(up, down);
          } else {
            analyzer.addError(new LineError(LineError.ERROR, line, 0, text.length(), location, "divided by 0!"));
            return getErrorCommand();
          }
        } else {
          analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "delay value is negative."));
          return getErrorCommand();
        }
      } else {
        analyzer.addError(new LineError(LineError.ERROR, line, 0, text.length(), location, "delay fraction is incorrect."));
        return getErrorCommand();
      }
    } else if (commandName.equals("bpm value")) {
      float value=float(params.get(1));
      if (value<=0) {
        analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "bpm value is 0 or negative."));
        return getErrorCommand();
      }
      return new BpmCommand(value);
    } else if (commandName.equals("chain c")) {
      int c=int(params.get(1));
      if (c<=0) {
        analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "chain value is negative."));
        return getErrorCommand();
      }
      return new ChainCommand(c);
    } else if (commandName.equals("mapping s y x n")) {
      int n=int(params.get(4));
      if (n<0) {
        analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "mapping value is negative."));
        return getErrorCommand();
      }
      return new MappingCommand(MappingCommand.SOUND, int(params.get(2)), int(params.get(1)), n);//sound
    } else if (commandName.equals("mapping l y x n")) {
      int n=int(params.get(4));
      if (n<0) {
        analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "mapping value is negative."));
        return getErrorCommand();
      }
      return new MappingCommand(MappingCommand.LED, int(params.get(2)), int(params.get(1)), n);//sound
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
  Multiset<Integer> ChainPoint;
  int ButtonX;
  int ButtonY;
  int cmdset;
  boolean bypass=false;//used when speed is required.
  int displayFrame=0;
  int displayTime==0;
  public LedProcesser(Script script_, int ButtonX_, int ButtonY_) {
    script=script_;
    resize(ButtonX_, ButtonY_);
    cmdset=LED_CMDSET;
  }
  int getFrame(int line) {
    return DelayPoint.getBeforeIndex(line-1)-1;//find frame with delay is meaningless.
  }
  int getBpm(int line) {
    int index=BpmPoint.getBeforeIndex(line-1)-1;
    if (index==0)return DEFAULT_BPM;
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
    if (bypass)return;
    int frame=getFrame(line);
    if (after==null) {
      uLines.remove(line.line);
      for (int a=DelayPoint.size()-1; a>0&&line<DelayPoint.get(a); a--) {
        DelayPoint.set(a, DelayPoint.get(a)-1);
      }
      for (int a=BpmPoint.size()-1; a>0&&line.line<BpmPoint.get(a); a--) {
        BpmPoint.set(a, BpmPoint.get(a)-1);
      }
      for (int a=ChainPoint.size()-1; a>0&&line.line<ChainPoint.get(a); a--) {
        ChainPoint.set(a, ChainPoint.get(a)-1);
      }
    }//else 
    if (before==null) {
      for (int a=DelayPoint.size()-1; a>0&&line.line<=DelayPoint.get(a); a--) {
        DelayPoint.set(a, DelayPoint.get(a)+1);
      }
      for (int a=BpmPoint.size()-1; a>0&&line.line<=BpmPoint.get(a); a--) {
        BpmPoint.set(a, BpmPoint.get(a)+1);
      }
      for (int a=ChainPoint.size()-1; a>0&&line.line<ChainPoint.get(a); a--) {
        ChainPoint.set(a, ChainPoint.get(a)+1);
      }
    }
    if (before!=null) {
      if (before instanceof LightCommand) {//includes on and off.
        LightCommand info=(LightCommand)before;
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
      } else if (before instanceof ChainCommand) {
        int index=ChainPoint.getBeforeIndex(line-1);
        //assert ChainCommand.get(index)==line
        ChainPoint.remove(index);
      }
    }
    if (after!=null) {
      if (after instanceof LightCommand) {//includes on and off.
        LightCommand info=(LightCommand)after;
        if (info.mc) {
          if (cmdset!=UNITOR_CMDSET) {//int type_, int line_, int start_, int end_, String location_, String cause_
            script.addError(new LineError(LineError.ERROR, line, 0, script.getLine(line).length(), script.name, "you can't use mc in normal led."));
          }
        } else {
          for (int a=info.x1; a<=info.x2; a++) {
            for (int b=info.y1; b<=info.y2; b++) {
              insertLedPosition(frame, line+(after==null?0:1), a, b, info.htmlc);
            }
          }
        }
      } else if (after instanceof DelayCommand) {
        DelayPoint.add(line);
        LED.add(frame+1, new color[ButtonX][ButtonY]);
        readFramesLed(frame, 2);
      } else if (after instanceof BpmCommand) {
        BpmPoint.add(line);
      } else if (after instanceof ChainCommand) {
        if (!(cmdset==AUTOPLAY_CMDSET||cmdset==UNITOR_CMDSET)) {
          script.addError(new LineError(LineError.ERROR, line, 0, script.getLine(line).length(), script.name, "you can't use chain command in normal led."));
        }
        ChainPoint.add(line);
      } else if (after instanceof MappingCommand) {
        if (cmdset!=UNITOR_CMDSET) {
          script.addError(new LineError(LineError.ERROR, line, 0, script.getLine(line).length(), script.name, "you can't use mapping in led or autoplay."));
        }
      }
    }
  }
  void readAll() {
    ArrayList<Command> cmds=script.getCommands();
    float bpm=DEFAULT_BPM;
    int line=0;
    for (Command cmd : commands) {
      if (cmd instanceof LightCommand) {
        LightCommand info=(LightCommand)cmd;
        for (int a=max(1, info.x); a<=ButtonX&&a<=info.x2; a++) {
          for (int b=max(1, info.y); b<=ButtonY&&b<=info.y2; b++) {
            LED.get(LED.size()-1)[a-1][b-1]=info.htmlc;
          }
        }
      } else if (cmd instanceof DelayCommand) {
        LED.add(new color[ButtonX][ButtonY]); 
        for (int a=0; a<ButtonX; a++) {
          for (int b=0; b<ButtonY; b++) {
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
    displayFrame=min(frameDisplay, DelayPoint.size()-1); 
    setTimeByFrame(displayFrame);
  }
  void insertLedPositon(int frame, int line, int x, int y, color c) {
    if (line>=Lines.lines())return;
    if (0<x&&x<=ButtonX&&0<y&&y<=ButtonY) {
      Arraylist<Command> commands=script.getCommands();
      boolean changed=false;
      color toSet=c;
      for (; line<script.lines(); line++) {
        Command cmd=commands.get(line);
        if (cmd instanceof LightCommand) {
          LightCommand info=(LightCommand)cmd;
          if (!info.mc) {
            if (info.x1<=x&&x<=info.x2&&info.y1<=y&&y<=info.y2) {
              toSet=info.htmlc;
              changed=true;
            }
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
  void deleteLedPosition(int frame, int line, int x, int y) {
    if (frame==0) {
      LED.get(frame)[x-1][y-1]=OFFCOLOR;
    } else {
      LED.get (frame)[x-1][y-1]=LED.get (frame-1)[x-1][y-1];
    }
    UnipackLine info;
    int max=script.lines();
    if (frame<DelayPoint.size()-1)max=DelayPoint.get(frame+1);
    for (int a=DelayPoint.get (frame)+1; a <max&&a++) {
      Command cmd=script.getCommands().get(a);
      if (cmd instanceof LightCommand) {
        LightCommand info=(LightCommand)cmd;
        if (!info.mc) {
          if (info.x1<=x&&x<=info.x2&&info.y1<=y&&y<=info.y2)LED.get(frame)[x-1][y-1]=info.htmlc;
        }
      }
    }
    insertLedPosition (frame+1, max, x, y, LED.get (frame)[x-1][y-1]);
  }
  void readFramesLed(int frame, int count) {
  }
  void setTimeByFrame(int frame) {
    displayTime=0;
    for (int a=1; a<=frame; a++) {
      displayTime+=getDelayValue(DelayPoint.get(a));
    }
  }
  void setFrameByTime(int time) {
    int sum=0;
    displayFrame=0;
    for (int a=0; a<DelayValue.size(); a++) {
      sum=sum+DelayValue.get(a);
      if (time<sum) {
        break;
      }
      displayFrame++;
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
    ChainPoint=new Multiset<Integer>(); 
    LED.add(new color[ButtonX][ButtonY]); 
    DelayPoint.add(-1); 
    BpmPoint.add(-1); 
    ChainPoint.add(-1);
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