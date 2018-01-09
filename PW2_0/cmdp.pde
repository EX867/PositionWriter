import com.karnos.commandscript.*;
import com.karnos.commandscript.Parameter;
import com.karnos.commandscript.Multiset;
UnipackCommands ledCommands;
UnipackCommands ksCommands;
void script_setup() {
  ledCommands=new UnipackCommands();
  //> unipad led commands
  //normal on
  ledCommands.addCommand(new ParamInfo("on", Parameter.FIXED, "o"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX));
  //mc on
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX));
  //pulse
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("p", Parameter.FIXED));
  //mc pulse
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX), new ParamInfo("p", Parameter.FIXED));
  //normal off
  ledCommands.addCommand(new ParamInfo("off", Parameter.FIXED, "f"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE));
  //mc off
  ledCommands.addCommand(new ParamInfo("off"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER));
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
  //no autoplay in here because that is not led cmdset.
  //> highlight keywords
  int C_KEYWORD1=0xFF3294AA;
  int C_UNITOR1=0xFF669900;
  int C_UNITOR2=0xFF614793;
  ledCommands.setKeyword("on", C_KEYWORD1);
  ledCommands.setKeyword("o", C_KEYWORD1);
  ledCommands.setKeyword("off", C_KEYWORD1);
  ledCommands.setKeyword("f", C_KEYWORD1);
  ledCommands.setKeyword("delay", C_KEYWORD1);
  ledCommands.setKeyword("d", C_KEYWORD1);
  ledCommands.setKeyword("auto", C_KEYWORD1);
  ledCommands.setKeyword("a", C_KEYWORD1);
  ledCommands.setKeyword("bpm", C_KEYWORD1);
  ledCommands.setKeyword("b", C_KEYWORD1);
  ledCommands.setKeyword("p", C_KEYWORD1);
  ledCommands.setKeyword("chain", C_UNITOR1);
  ledCommands.setKeyword("c", C_UNITOR1);
  ledCommands.setKeyword("mapping", C_UNITOR1);
  ledCommands.setKeyword("m", C_UNITOR1);
  ledCommands.setKeyword("mc", C_UNITOR2);
  ledCommands.setKeyword("s", C_UNITOR2);
  ledCommands.setKeyword("l", C_UNITOR2);
  ledCommands.setKeyword("rnd", C_UNITOR2);
  //
  ksCommands=new UnipackCommands();
  ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("relative", Parameter.STRING));
  ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("relative", Parameter.STRING), new ParamInfo("loop", Parameter.INTEGER));
  ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("absolute", Parameter.WRAPPED_STRING));
  ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("absolute", Parameter.WRAPPED_STRING), new ParamInfo("loop", Parameter.INTEGER));
}
class LedScript extends CommandScript {
  CommandEdit editor;//linked editor
  LedProcessor processor=new LedProcessor();
  public LedScript(String name_) {
    super(name_, ledCommands, null);
    processor.setScript(this);
    analyzer.processor=processor;//why!!!!
  }
  void setCmdSet(int cmdset) {
    processor.cmdset=cmdset;
  }
  int getCmdSet() {
    return processor.cmdset;
  }
  void readAll() {
    processor.bypass=true;
    super.readAll();
    processor.bypass=false;
    processor.readAll();
  }
}
public LedScript loadLedScript(String name_, String text) {//line ending have to be normalized.
  LedScript ledScript=new LedScript(name_);
  ledScript.insert(0, 0, text);
  return ledScript;
}
class UnipackCommands extends LineCommandType {
  public Command getCommand(com.karnos.commandscript.Analyzer analyzer, int line, String location, String text, String commandName, ArrayList<String> params) {
    //add additional errors to analyzer
    String[] tokens=split(commandName, " ");
    int x1=0, x2=0, y1=0, y2=0;
    for (int a=0; a<tokens.length; a++) {
      if (tokens[a].equals("vel")) {
        int vel=int(params.get(a));
        if (vel<0||vel>=128) {
          analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "velocity is out of range."));
          return getErrorCommand();
        }
      } else if (a>0&&tokens[a-1].equals("y")&&tokens[a].equals("x")) {//position.
        y1=com.karnos.commandscript.Analyzer.getRangeFirst(params.get(a-1));
        y2=com.karnos.commandscript.Analyzer.getRangeSecond(params.get(a-1));
        x1=com.karnos.commandscript.Analyzer.getRangeFirst(params.get(a));
        x2=com.karnos.commandscript.Analyzer.getRangeSecond(params.get(a));
        if (y1<=0||y1>ButtonY||x1<=0||x1>ButtonX||y2<=0||y2>ButtonY||x2<=0||x2>ButtonX) {
          analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "position is out of range."));
          x1=min(max(1, x1), ButtonX);
          x2=min(max(1, x2), ButtonX);
          y1=min(max(1, y1), ButtonY);
          y2=min(max(1, y2), ButtonY);
        }
      }
    }
    //assert x1!=0 if x,y exists.
    if (commandName.equals("on y x auto vel")) {
      return new OnCommand(x1, x2, y1, y2, k[int(params.get(4))], int(params.get(4)));
    } else if (commandName.equals("on y x auto vel p")) {
      return new OnCommand(x1, x2, y1, y2, k[int(params.get(4))], int(params.get(4)), true);
    } else if (commandName.equals("on y x vel")) {
      return new OnCommand(x1, x2, y1, y2, k[int(params.get(3))], int(params.get(3)));
    } else if (commandName.equals("on y x html vel")) {
      return new OnCommand(x1, x2, y1, y2, color(unhex("FF"+params.get(3))), int(params.get(4)));
    } else if (commandName.equals("on y x html")) {
      return new OnCommand(x1, x2, y1, y2, color(unhex("FF"+params.get(3))), COLOR_OFF);
    } else if (commandName.equals("on y x auto rnd")) {
      return new OnCommand(x1, x2, y1, y2, COLOR_RND, COLOR_OFF);
    } else if (commandName.equals("on y x rnd")) {
      return new OnCommand(x1, x2, y1, y2, COLOR_RND, COLOR_OFF);
    } else if (commandName.equals("on mc n auto vel")) {
      return new McOnCommand(int(params.get(2)), k[int(params.get(4))], int(params.get(4)));
    } else if (commandName.equals("on mc n auto vel p")) {
      return new McOnCommand(int(params.get(2)), k[int(params.get(4))], int(params.get(4)), true);
    } else if (commandName.equals("on mc n vel")) {
      return new McOnCommand(int(params.get(2)), k[int(params.get(4))], int(params.get(3)));
    } else if (commandName.equals("on mc n html vel")) {
      return new McOnCommand(int(params.get(2)), color(unhex("FF"+params.get(3))), int(params.get(4)));
    } else if (commandName.equals("on mc n html")) {
      return new McOnCommand(int(params.get(2)), color(unhex("FF"+params.get(3))), 0);
    } else if (commandName.equals("on mc n auto rnd")) {
      return new McOnCommand(int(params.get(2)), COLOR_RND, 0);
    } else if (commandName.equals("on mc n rnd")) {
      return new McOnCommand(int(params.get(2)), COLOR_RND, 0);
    } else if (commandName.equals("on y x")) {
      return new ApOnCommand(x1, x2, y1, y2);
    } else if (commandName.equals("off y x")) {
      return new OffCommand(x1, x2, y1, y2);
    } else if (commandName.equals("off mc n")) {
      return new McOffCommand(int(params.get(2)));
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
    if (commandName.equals("kschain y x relative")) {//ADD
    } else if (commandName.equals("kschain y x relative loop")) {
    } else if (commandName.equals("kschain y x absolute")) {
    } else if (commandName.equals("kschain y x absolute loop")) {
    }
    return getErrorCommand();
  }

  public Command getErrorCommand() {
    return new ErrorCommand();
  }

  public Command getEmptyCommand() {
    return new EmptyCommand();
  }
}
class LedProcessor extends LineCommandProcessor {
  LedScript script;
  ArrayList<color[][]> LED;
  Multiset<Integer> DelayPoint;
  Multiset<Integer> BpmPoint;
  Multiset<Integer> ChainPoint;
  int cmdset;
  boolean bypass=false;//used when speed is required.
  int displayFrame=0;
  int displayTime=0;
  public LedProcessor() {
    resize(ButtonX, ButtonY);
    cmdset=LED_CMDSET;
  }
  void setScript(Script script_) {
    script=script_;
  }
  int getFrame(int line) {
    if (line<0)return 0;
    return DelayPoint.getBeforeIndex(line-1)-1;//find frame with delay is meaningless.
  }
  float getBpm(int line) {
    int index=BpmPoint.getBeforeIndex(line-1)-1;
    if (index==0)return DEFAULT_BPM;
    //assert script.getCommands().get(index) instanceof BpmCommand
    return ((BpmCommand)script.getCommands().get(index)).value;
  }
  int getDelayValue(int line) {//milliseconds.
    if (line==-1)return 0;
    //assert script.getCommands().get(index) instanceof DelayCommand
    DelayCommand info=(DelayCommand)script.getCommands().get(line);
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
  void resize(int ButtonX_, int ButtonY_) {
    clear();
    script.readAll();
  }

  public void processCommand(int line, Command before, Command after) {
    surface.setTitle(title_filename+title_edited+title_suffix+" - reading...("+script.getProgress()+"/"+script.getTotal()+")");
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
            deleteLedPosition(frame, line+(after==null?0:1), a, b);
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
        if (cmdset!=UNITOR_CMDSET) {//int type_, int line_, int start_, int end_, String location_, String cause_
          script.addError(new LineError(LineError.ERROR, line, 0, script.getLine(line).length(), script.name, "you can't use unitor command in normal led."));
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
        LED.add(frame+1, new color[ButtonX][ButtonY]);
        readFramesLed(frame, 2);
      } else if (after instanceof BpmCommand) {
        BpmPoint.add(line);
      } else if (after instanceof ChainCommand) {
        if (!(cmdset==AUTOPLAY_CMDSET||cmdset==UNITOR_CMDSET)) {//chain is duplication so add error manually...
          script.addError(new LineError(LineError.ERROR, line, 0, script.getLine(line).length(), script.name, "you can't use chain command in normal led."));
        }
        ChainPoint.add(line);
      }
    }
  }
  void readAll() {
    ArrayList<Command> commands=script.getCommands();
    float bpm=DEFAULT_BPM;
    int line=0;
    for (Command cmd : commands) {
      if (cmd instanceof LightCommand) {
        LightCommand info=(LightCommand)cmd;
        for (int a=max(1, info.x1); a<=ButtonX&&a<=info.x2; a++) {
          for (int b=max(1, info.y1); b<=ButtonY&&b<=info.y2; b++) {
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
    displayFrame=min(displayFrame, DelayPoint.size()-1); 
    setTimeByFrame(displayFrame);
  }
  void insertLedPosition(int frame, int line, int x, int y, color c) {
    if (line>=script.lines())return;
    if (0<x&&x<=ButtonX&&0<y&&y<=ButtonY) {
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
  void deleteLedPosition(int frame, int line, int x, int y) {
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
      for (int a=0; a<ButtonX; a++) {
        for (int b=0; b<ButtonY; b++) {
          LED.get(frame)[a][b]=COLOR_OFF;
        }
      }
    } else {
      for (int a=0; a<ButtonX; a++) {
        for (int b=0; b<ButtonY; b++) {
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
        for (int a=0; a<ButtonX; a++) {
          for (int b=0; b<ButtonY; b++) {
            LED.get(frame)[a][b]=LED.get(frame-1)[a][b];
          }
        }
      }
    }
  }
  void setTimeByFrame() {
    displayTime=getTimeByFrame(displayFrame);
  }
  void setTimeByFrame(int frame) {
    displayTime=getTimeByFrame(frame);
  }
  int getTimeByFrame(int frame) {
    long time=0;
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

  public void onReadFinished() {
    surface.setTitle(title_filename+title_edited+title_suffix);
  }

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
class KsProcessor extends LineCommandProcessor {

  public void processCommand(int line, Command before, Command after) {
  }

  public void onReadFinished() {
    surface.setTitle(title_filename+title_edited+title_suffix);
  }

  public void clear() {
  }
}