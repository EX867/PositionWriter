import com.karnos.commandscript.*;
UnipackCommands ledCommands;
void script_setup() {
  ledCommands=new UnipackCommands();
  ledCommands.addCommand(new ParamInfo("on", Parameter.FIXED, "o"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX));
  //mc on
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
  ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("vel", Parameter.INTEGER));
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
  Script script;
  ArrayList<color[][]> LED;
  Multiset<Integer> DelayPoint;
  Multiset<Integer> BpmPoint;
  int ButtonX;
  int ButtonY;
  public LedProcesser(Script script_, int ButtonX_, int ButtonY_) {
    script=script_;
    resize(ButtonX_,ButtonY_);
  }
  int getFrame(int line){
  }
  int getDelayValue(){
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