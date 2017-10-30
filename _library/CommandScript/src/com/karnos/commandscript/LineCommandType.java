package com.karnos.commandscript;
import java.util.ArrayList;
public abstract class LineCommandType {//processes commands.determinates analyzer's behavior...
  public Parameter commands;//root of commands
  public char seperator=' ';
  public char range='~';
  public char wrapper='\"';
  public LineCommandType() {
    commands=new Parameter(Parameter.STRING, "");//root not included in commands!!
  }
  public abstract Command getCommand(Analyzer analyzer, int line, String location, String text, String commandName, ArrayList<String> params);
  public abstract Command getErrorCommand();
  public abstract Command getEmptyCommand();
  public void addCommand(ParamInfo... params) {//set seperator first. ex)on y(integer) x(integer) auto vel(integer) you not have to  write fixed explicitly.
    //all type names are same as Parameter's constants.
    Parameter parent=commands;
    int a=1;
    for (ParamInfo info : params) {
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