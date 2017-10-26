package com.karnos.commandscript.test;
import com.karnos.commandscript.*;

import java.util.ArrayList;
public class Test {
  public static void main(String[] args) {
    Processer processer=new Processer();
    processer.addCommand(new ParameterInfo("a"), new ParameterInfo("Integer", "x"), new ParameterInfo("Integer", "y"));
    processer.addCommand(new ParameterInfo("b"), new ParameterInfo("Integer", "x"), new ParameterInfo("Integer", "y"));
    processer.addCommand(new ParameterInfo("a"), new ParameterInfo("String", "str1"), new ParameterInfo("String", "str2"));
    processer.addCommand(new ParameterInfo("b"), new ParameterInfo("Integer", "x"), new ParameterInfo("String", "str1"));
    Script script=new Script("test", processer);
    //script.addLine("a 3 4");
    //script.addLine("a 2 d");
    script.addLine("b ew h");
    script.addLine("b 7 d");
    System.out.println("//===result===//");
    System.out.println(script.toCommandString());
    for (LineError e : script.getErrors()) {
      System.out.println(e.toString());
    }
  }
}
class Processer extends LineCommandProcesser {
  @Override
  public Command buildCommand(String commandName, ArrayList<String> params) {
    System.out.println("[result] " + commandName);
    if (commandName.equals("a x y")) {
      return new TestCommand("a", Integer.parseInt(params.get(1)), Integer.parseInt(params.get(2)));
    } else if (commandName.equals("b x y")) {
      return new TestCommand("b", Integer.parseInt(params.get(1)), Integer.parseInt(params.get(2)));
    } else if (commandName.equals("a str1 str2")) {
      return new TestCommand2(params.get(1), params.get(2));
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
  @Override
  public void processCommand(int line, Command before, Command after) {
    //if (before == null) System.out.println("[out] " + line + " added " + after.toString());
    //else if (after == null) System.out.println("[out] " + line + " deleted " + before.toString());
    //else System.out.println("[out] " + line + " changed from " + before.toString() + " to " + after.toString());
  }
  @Override
  public void clear() {
  }
}
class TestCommand implements Command {
  String type;
  int param1;
  int param2;
  public TestCommand(String type_, int param1_, int param2_) {
    type=type_;
    param1=param1_;
    param2=param2_;
  }
  @Override
  public String toString() {
    return param1 + " " + param2;
  }
  @Override
  public void execute(int time) {
    System.out.println("command excuted!");
  }
}
class TestCommand2 implements Command {
  String param1;
  String param2;
  public TestCommand2(String param1_, String param2_) {
    param1=param1_;
    param2=param2_;
  }
  @Override
  public String toString() {
    return param1 + " " + param2;
  }
  @Override
  public void execute(int time) {
    System.out.println("command2 excuted!");
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