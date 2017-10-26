package com.karnos.commandscript;
import java.util.ArrayList;
import java.util.HashMap;
public abstract class LineCommandProcesser {//processes commands.determinates parser's behavior...
  public Parameter commands;//root of commands
  public char seperator=' ';
  public char range='~';
  public char wrapper='\"';
  public LineCommandProcesser() {
    commands=new Parameter(Parameter.STRING, "");//root not included in commands!!
  }
  public abstract Command buildCommand(String commandName, ArrayList<String> params);
  public abstract Command getErrorCommand();
  public abstract Command getEmptyCommand();
  public abstract void processCommand(int line, Command before, Command after);
  public abstract void clear();
  public void addCommand(ParameterInfo... params) {//set seperator first. ex)on y(integer) x(integer) auto vel(integer) you not have to  write fixed explicitly.
    //all type names are same as Parameter's constants.
    Parameter parent=commands;
    int a=1;
    for (ParameterInfo info : params) {
      Parameter next=null;
      for (Parameter next_ : parent.children) {
        if (next_.equals(info)) {//parameter equals parameterinfo
          next=next_;
        }
      }
      if (next == null) {
        next=new Parameter(info);
        parent.children.add(next);
        if (parent != commands) next.parent=parent;
      }
      parent=next;
      if (a == params.length) {
        next.isEnd=true;
      }
      a++;
    }
  }
}