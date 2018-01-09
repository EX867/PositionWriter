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
    super(x1_, x2_, y1_, y2_, OFFCOLOR, 0);
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