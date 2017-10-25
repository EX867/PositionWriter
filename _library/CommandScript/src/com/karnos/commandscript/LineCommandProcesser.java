package com.karnos.commandscript;
import java.util.ArrayList;
import java.util.HashMap;
public abstract class LineCommandProcesser {//processes commands.determinates parser's behavior...
  public Parameter commands;//root of commands
  public HashMap<String, String> commandNames;//just giving a name for parameter sequence!
  public LineCommandProcesser() {
    commandNames=new HashMap<String, String>();
    commands=new Parameter(Parameter.STRING, "");//root not included in commands!!
  }
  public abstract Command buildCommand(String commandName, ArrayList<String> params);
  public abstract Command getErrorCommand();
  public abstract Command getEmptyCommand();
  public abstract void processCommand(int line, Command before, Command after);
  public abstract void clear();
  public void addCommand(String form) {//set seperator first. ex)on y(integer) x(integer) auto vel(integer) you not have to  write fixed explicitly.
    //all type names are same as Parameter's constants.
  }
}