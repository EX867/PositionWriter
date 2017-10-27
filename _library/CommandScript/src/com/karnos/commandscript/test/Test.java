package com.karnos.commandscript.test;
import com.karnos.commandscript.*;

import java.util.ArrayList;
public class Test {
  public static void main(String[] args) {
    //variations are only assigned once.
    CommandType commandType=new CommandType();
    //unipad led commands
    //normal on
    commandType.addCommand(new ParamInfo("on", Parameter.FIXED, "o"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("vel", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX));
    //mc on
    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("vel", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX));
    //normal off
    commandType.addCommand(new ParamInfo("off", Parameter.FIXED, "f"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE));
    //delay
    commandType.addCommand(new ParamInfo("delay", Parameter.FIXED, "d"), new ParamInfo("value", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("delay"), new ParamInfo("fraction", Parameter.STRING));
    //bpm
    commandType.addCommand(new ParamInfo("bpm", Parameter.FIXED, "b"), new ParamInfo("value", Parameter.FLOAT));
    //chain
    commandType.addCommand(new ParamInfo("chain", Parameter.FIXED, "c"), new ParamInfo("c", Parameter.INTEGER));
    //mapping
    commandType.addCommand(new ParamInfo("mapping", Parameter.FIXED, "m"), new ParamInfo("s"), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("n", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("mapping"), new ParamInfo("l"), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("n", Parameter.INTEGER));
    Processer processer=new Processer();
    Script script=new Script("LedEditor", commandType, processer);
    script.addLine("on 6 5 auto 2");
    script.addLine("o 6 5 auto 2");
    script.addLine("o 5 4 a 2");
    script.addLine("on 2 3 1");
    script.addLine("on mc 4 3");
    script.addLine("on mc 2 auto 2");
    script.addLine("on 1~3 3~6 auto 2");
    script.addLine("o 4~5 2~6 4");
    script.addLine("off 2 4");
    script.addLine("f 2 4");
    script.addLine("delay 5");
    script.addLine("delay 2/3");
    script.addLine("bpm 2.5");
    script.addLine("chain 2");
    script.addLine("m s 2 4 6");
    script.addLine("o 2 2 2 2");
    script.addLine("off 2 s");
    System.out.println("//===result===//");
    System.out.println(script.toString());
    //System.out.println(script.toCommandString());
    for (LineError e : script.getErrors()) {
      System.out.println(e.toString());
    }
  }
}
class CommandType extends LineCommandType {
  @Override
  public Command getCommand(Analyzer analyzer, String commandName, ArrayList<String> params) {
    System.out.println("[result] " + commandName);
    if (commandName.equals("a x y")) {
      return getEmptyCommand();
    }
    return getEmptyCommand();
    //return getErrorCommand();
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
class Processer extends LineCommandProcesser {
  @Override
  public void processCommand(int line, Command before, Command after) {
    //if (before == null) System.out.println("[out] " + line + " added " + after.toString());
    //else if (after == null) System.out.println("[out] " + line + " deleted " + before.toString());
    //else System.out.println("[out] " + line + " changed from " + before.toString() + " to " + after.toString());
  }
  @Override
  public void onReadFinished() {
    //set title progress to 0 etc...
  }
  @Override
  public void clear() {
  }
}
class ErrorCommand implements Command {
  @Override
  public String toString() {
    return "error";
  }
  @Override
  public void execute(int time) {
    System.out.println("error excuted!");
  }
}
class EmptyCommand implements Command {
  @Override
  public String toString() {
    return "empty";
  }
  @Override
  public void execute(int time) {
    System.out.println("empty excuted!");
  }
}