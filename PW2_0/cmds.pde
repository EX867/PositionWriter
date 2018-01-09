import com.karnos.commandscript.*;
import com.karnos.commandscript.Parameter;
import com.karnos.commandscript.Multiset;
UnipackCommands ledCommands;
UnipackCommands ksCommands;
UnipackCommands apCommands;//#ADD
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
        if (y1<=0||y1>info.buttonY||x1<=0||x1>info.buttonX||y2<=0||y2>info.buttonY||x2<=0||x2>info.buttonX) {
          analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "position is out of range."));
          x1=min(max(1, x1), info.buttonX);
          x2=min(max(1, x2), info.buttonX);
          y1=min(max(1, y1), info.buttonY);
          y2=min(max(1, y2), info.buttonY);
        }
      }
    }
    //assert x1!=0 if x,y exists.
    if (commandName.equals("on y x auto vel")) {
      return new OnCommand(x1, x2, y1, y2, color_lp[int(params.get(4))], int(params.get(4)));
    } else if (commandName.equals("on y x auto vel p")) {
      return new OnCommand(x1, x2, y1, y2, color_lp[int(params.get(4))], int(params.get(4)), true);
    } else if (commandName.equals("on y x vel")) {
      return new OnCommand(x1, x2, y1, y2, color_lp[int(params.get(3))], int(params.get(3)));
    } else if (commandName.equals("on y x html vel")) {
      return new OnCommand(x1, x2, y1, y2, color(unhex("FF"+params.get(3))), int(params.get(4)));
    } else if (commandName.equals("on y x html")) {
      return new OnCommand(x1, x2, y1, y2, color(unhex("FF"+params.get(3))), COLOR_OFF);
    } else if (commandName.equals("on y x auto rnd")) {
      return new OnCommand(x1, x2, y1, y2, COLOR_RND, COLOR_OFF);
    } else if (commandName.equals("on y x rnd")) {
      return new OnCommand(x1, x2, y1, y2, COLOR_RND, COLOR_OFF);
    } else if (commandName.equals("on mc n auto vel")) {
      return new McOnCommand(int(params.get(2)), color_lp[int(params.get(4))], int(params.get(4)));
    } else if (commandName.equals("on mc n auto vel p")) {
      return new McOnCommand(int(params.get(2)), color_lp[int(params.get(4))], int(params.get(4)), true);
    } else if (commandName.equals("on mc n vel")) {
      return new McOnCommand(int(params.get(2)), color_lp[int(params.get(4))], int(params.get(3)));
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
    if (commandName.equals("kschain y x relative")) {//#ADD
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
  public void cursorUpWord(CommandScript script, boolean select) {
    //#ADD
  }
  public void cursorDownWord(CommandScript script, boolean select) {
    //#ADD
  }
}
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
  //#ADD
  //
  ksCommands=new UnipackCommands();
  ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("relative", Parameter.STRING));
  ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("relative", Parameter.STRING), new ParamInfo("loop", Parameter.INTEGER));
  ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("absolute", Parameter.WRAPPED_STRING));
  ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("absolute", Parameter.WRAPPED_STRING), new ParamInfo("loop", Parameter.INTEGER));
}
class UnipackCommand implements Command {
  String toUnipadString() {
    return toString();
  }
  public void execute(long time) {
  }
}
class UnitorCommand extends UnipackCommand {
}
class LightCommand extends UnipackCommand {
  int x1, x2, y1, y2;
  int vel;
  color htmlc;
  public LightCommand(int x1_, int x2_, int y1_, int y2_, int vel_, color htmlc_) {
    x1=x1_;
    x2=x2_;
    y1=y1_;
    y2=y2_;
    vel=vel_;
    htmlc=htmlc_;
  }
}
class OnCommand extends LightCommand {
  boolean pulse;
  public OnCommand(int x1_, int x2_, int y1_, int y2_, int vel_, int htmlc_) {
    super(x1_, x2_, y1_, y2_, vel_, htmlc_);
  }
  public OnCommand(int x1_, int x2_, int y1_, int y2_, int vel_, int htmlc_, boolean pulse_) {//pw supports pulse...
    super(x1_, x2_, y1_, y2_, vel_, htmlc_);
    pulse=pulse_;
  }
  public String toString() {
    String ret="";
    ret="on "+((y1==y2)?y1+"":y1+"~"+y2)+" "+((x1==x2)?x1+"":x1+"~"+x2);
    if (htmlc==COLOR_RND)ret+=" auto rnd";
    else if (color_lp[vel]!=htmlc)ret+=" "+hex(htmlc, 6)+" "+vel;
    else if (vel==0)ret+=hex(htmlc, 6);
    else ret+=" auto "+vel;
    if (pulse)ret+=" p";
    return ret;
  }
  String toUnipadString() {
    if (pulse||htmlc==COLOR_RND)return "";
    return toString();
  }
}
class OffCommand extends LightCommand {
  public OffCommand(int x1_, int x2_, int y1_, int y2_) {
    super(x1_, x2_, y1_, y2_, COLOR_OFF, 0);
  }
  public String toString() {
    return "off "+((y1==y2)?y1+"":y1+"~"+y2)+" "+((x1==x2)?x1+"":x1+"~"+x2);
  }
}
class McOnCommand extends UnitorCommand {
  int n;
  int vel;
  color htmlc;
  boolean pulse;
  public McOnCommand(int n_, int vel_, int htmlc_) {
    n=n_;
    vel=vel_;
    htmlc=htmlc_;
  }
  public McOnCommand(int n_, int vel_, int htmlc_, boolean pulse_) {//pw supports pulse...
    n=n_;
    vel=vel_;
    htmlc=htmlc_;
    pulse=pulse_;
  }
  public String toString() {
    String ret="";
    ret="on mc "+n;
    if (htmlc==COLOR_RND)ret+=" auto rnd";
    else if (color_lp[vel]!=htmlc)ret+=" "+hex(htmlc, 6)+" "+vel;
    else if (vel==0)ret+=hex(htmlc, 6);
    else ret+=" auto "+vel;
    if (pulse)ret+=" p";
    return ret;
  }
  String toUnipadString() {
    return "";
  }
}
class McOffCommand extends UnitorCommand {
  int n;
  public McOffCommand(int n_) {
    n=n_;
  }
  public String toString() {
    return "off mc "+n;
  }
}
class ApOnCommand extends LightCommand {
  public ApOnCommand(int x1_, int x2_, int y1_, int y2_) {
    super(x1_, x2_, y1_, y2_, color(255), 3);
  }
  public String toString() {
    return "on "+((y1==y2)?y1+"":y1+"~"+y2)+" "+((x1==x2)?x1+"":x1+"~"+x2);
  }
}
class DelayCommand extends UnipackCommand {
  boolean isFraction;
  int up;
  int down;
  public DelayCommand(int value) {
    up=value;
    down=1;
    isFraction=false;
  }
  public DelayCommand(int up_, int down_) {
    up=up_;
    down=down_;
    isFraction=true;
  }
  public String toString() {
    if (isFraction)return "delay "+up;
    return "delay "+up+"/"+down;
  }
  String toUnipadString() {
    if (isFraction)return "";
    return "delay "+up;
  }
  String toUnipadString(float bpm) {
    if (isFraction)return "delay "+floor((up*2400/(bpm*down))*100);
    return "delay "+up;
  }
}
class BpmCommand extends UnipackCommand {
  float value;
  public BpmCommand(float value_) {
    value=value_;
  }
  public String toString() {
    return "bpm "+value;
  }
  String toUnipadString() {
    return "";
  }
}
class ChainCommand extends UnipackCommand {
  int c;
  public ChainCommand(int c_) {
    c=c_;
  }
  public String toString() {
    return "chain "+c;
  }
}
class MappingCommand extends UnitorCommand {
  static final int SOUND=1;
  static final int LED=2;
  int type;
  int x, y, n;
  public MappingCommand(int type_, int x_, int y_, int n_) {
    type=type_;
    x=x_;
    y=y_;
    n=n_;
  }
  public String toString() {
    if (type==SOUND)return "mapping s "+y+" "+x+" "+n;
    else return "mapping l "+y+" "+x+" "+n;
  }
  String toUnipadString() {
    return "";
  }
}
class ErrorCommand implements Command {
  public String toString() {
    return "";
  }
  public void execute(long time) {
  }
}
class EmptyCommand implements Command {
  public String toString() {
    return "";
  }
  public void execute(long time) {
  }
}