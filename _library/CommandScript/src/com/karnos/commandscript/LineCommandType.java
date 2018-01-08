package com.karnos.commandscript;
import java.util.ArrayList;
import java.util.HashMap;
public abstract class LineCommandType {//processes commands.determinates analyzer's behavior...
  public HashMap<String, Integer> keywords;//keyword is fixed value.
  public static LineCommandType DEFAULT_COMMAND_TYPE=new LineCommandType() {
    @Override
    public Command getCommand(Analyzer analyzer, int line, String location, String text, String commandName, ArrayList<String> params) {
      return Command.DEFAULT_COMMAND;
    }
    @Override
    public Command getErrorCommand() {
      return Command.DEFAULT_COMMAND;
    }
    @Override
    public Command getEmptyCommand() {
      return Command.DEFAULT_COMMAND;
    }
    @Override
    public void cursorUpWord(CommandScript script, boolean select) {
    }
    @Override
    public void cursorDownWord(CommandScript script, boolean select) {
    }
  };
  public Parameter commands;//root of commands
  public char seperator=' ';
  public char range='~';
  public char wrapper='\"';
  public LineCommandType() {
    commands=new Parameter(Parameter.FIXED, "");//root not included in commands!!
    keywords=new HashMap<>(10000);
  }
  public LineCommandType(int keywordsSize) {
    commands=new Parameter(Parameter.FIXED, "");//root not included in commands!!
    keywords=new HashMap<>(keywordsSize);
  }
  public abstract Command getCommand(Analyzer analyzer, int line, String location, String text, String commandName, ArrayList<String> params);
  public abstract Command getErrorCommand();
  public abstract Command getEmptyCommand();
  public void addCommand(ParamInfo... params) {
    //set seperator first. ex)on y(integer) x(integer) auto vel(integer) you not have to  write fixed explicitly.
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
  public abstract void cursorUpWord(CommandScript script, boolean select);
  public abstract void cursorDownWord(CommandScript script, boolean select);
  public void setKeyword(String text_, int color_) {
    keywords.put(text_, color_);
  }
  public void removeKeyword(String text_) {
    keywords.remove(text_);
  }
}