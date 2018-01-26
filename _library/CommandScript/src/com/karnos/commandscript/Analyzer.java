package com.karnos.commandscript;
import java.util.ArrayList;
import java.util.LinkedList;
public abstract class Analyzer {//Analyzes specific Script and stores parsed commands.
  public static final Analyzer NO_COMMAND=new Analyzer(LineCommandType.DEFAULT_TYPE, LineCommandProcessor.DEFAULT_PROCESSOR) {
    @Override
    public Command parse(int line, String location_, String text) {
      return commandType.getEmptyCommand();
    }
  };
  public static boolean debug=false;
  public ArrayList<Command> lines;
  protected Parameter commands;//root of commands
  protected LineCommandType commandType;
  protected LineCommandProcessor processor;
  public LineCommandProcessor getProcessor() {
    return processor;
  }
  public LineCommandType getCommandType() {
    return commandType;
  }
  LinkedList<LineChangeData> addList;
  public Multiset<LineError> errors;
  private LineError cacheError;
  protected boolean recordError;
  protected String location="";
  protected char seperator=' ';
  protected char range='~';
  protected char wrapper='\"';
  //these two vars are used in checking progress.
  int total=0;
  int progress=0;
  public Analyzer(LineCommandType commandType_, LineCommandProcessor processer_) {//NotNull all params
    errors=new Multiset<LineError>();
    cacheError=new LineError(LineError.PRIOR, 0, 0, 0, "", "");
    commandType=commandType_;
    commands=commandType.commands;
    seperator=commandType.seperator;
    range=commandType.range;
    wrapper=commandType.wrapper;
    lines=new ArrayList<Command>();
    addList=new LinkedList<LineChangeData>();
    processor=processer_;
    recordError=true;
  }
  public void clear() {
    if (processor != null) {
      processor.clear(this);
    }
    addList.clear();
    lines.clear();
    errors.clear();
    total=0;
    progress=0;
  }
  public void read() {//read the add list.
    total=addList.size();
    progress=0;
    for (LineChangeData data : addList) {
      analyzeLine(data.line, data.before, data.after);
      progress++;
    }
    addList.clear();
    total=0;
    progress=0;
    processor.onReadFinished(this);
  }
  public void readAll(ArrayList<String> lines) {
    clear();
    for (int a=0; a < lines.size(); a++) {
      add(a, null, lines.get(a));
    }
    read();
  }
  public void cursorUpWord(CommandScript script, boolean select) {
    if (commandType != null) {
      commandType.cursorUpWord(script, select);
    }
  }
  public void cursorDownWord(CommandScript script, boolean select) {
    if (commandType != null) {
      commandType.cursorDownWord(script, select);
    }
  }
  public int getTotal() {
    return total;
  }
  public int getProgress() {
    return progress;
  }
  @Override
  public String toString() {
    if (lines.size() == 0) return "";
    StringBuilder builder=new StringBuilder();
    builder.append(lines.get(0).toString());
    for (int a=1; a < lines.size(); a++) {
      builder.append("\n").append(lines.get(a).toString());
    }
    return builder.toString();
  }
  public void addError(LineError error) {
    if (!recordError) return;
    errors.add(error);
  }
  public void removeErrors(int line) {
    cacheError.line=line - 1;
    for (int a=errors.getBeforeIndex(cacheError); a < errors.size() && errors.get(a).line == line; ) {
      errors.remove(a);
    }
  }
  public LineError getFirstError(int line) {
    cacheError.line=line - 1;
    int index=errors.getBeforeIndex(cacheError);
    if (index >= errors.size() || errors.get(index).line != line) return null;
    return errors.get(index);
  }
  public void add(int line, String before, String after) {
    addList.add(new LineChangeData(line, before, after));
  }
  public void analyzeLine(int line, String before_, String after_) {
    cacheError.line=line + 1;
    if (before_ != null) {
      removeErrors(line);
      if (after_ == null) {
        for (int index=errors.getBeforeIndex(cacheError); index < errors.size(); index++) {
          errors.get(index).line-=1;
        }
      }
    } else {
      for (int index=errors.getBeforeIndex(cacheError); index < errors.size(); index++) {
        errors.get(index).line+=1;
      }
    }
    recordError=false;
    Command before=parse(line, location, before_);//make this to queue and thread...
    recordError=true;
    Command after=parse(line, location, after_);//make this to queue and thread...
    assert before != null || after != null;
    if (before == null) {
      lines.add(line, after);
    } else if (after == null) {
      lines.remove(line);
    } else {
      lines.set(line, after);
    }
    processor.processCommand(this, line, before, after);
  }
  public abstract Command parse(int line, String location_, String text);
  //===Checkers===//
  public static boolean isWrappedString(String in, char wrapper) {
    if (in.length() < 2) return false;
    return in.charAt(0) == wrapper && in.charAt(in.length() - 1) == wrapper;
  }
  public static boolean isBoolean(String in) {
    if (in.equals("true") || in.equals("false")) return true;
    return false;
  }
  public static boolean isInt(String str) {
    if (str.equals("")) return false;
    if (str.length() > 9) return false;
    if (str.equals("-")) return false;
    // just int or float is needed!
    int a=0;
    if (str.charAt(0) == '-') a=1;
    while (a < str.length()) {
      if (!('0' <= str.charAt(a) && str.charAt(a) <= '9')) return false;
      a=a + 1;
    }
    return true;
  }
  public static boolean isRange(String str) {
    if (isInt(str)) return true;
    String[] ints=str.split("~");
    return ints.length == 2 && isInt(ints[0]) && isInt(ints[1]);
  }
  public static boolean isHex(String in) {
    if (in.length() != 6) return false;
    StringBuilder builder=new StringBuilder();
    for (int a=0; a < in.length(); a++) {
      if (('a' <= in.charAt(a) && in.charAt(a) <= 'f') || ('A' <= in.charAt(a) && in.charAt(a) <= 'F')) builder.append('0');
      else builder.append(in.charAt(a));
    }
    return isInt(builder.toString());
  }
  public static boolean isFloat(String str) {//https://stackoverflow.com/questions/43156077/how-to-check-a-string-is-float-or-int
    if (str.equals("")) return false;
    if (str.length() > 9) return false;
    if (str.equals("-")) return false;
    return str.matches("[+-]?([0-9]*[.])?[0-9]+");
  }
  public static int getRangeFirst(String str) {
    if (isInt(str)) return Integer.parseInt(str);
    String[] ints=str.split("~");
    return Integer.parseInt(ints[0]);
  }
  public static int getRangeSecond(String str) {
    if (isInt(str)) return Integer.parseInt(str);
    String[] ints=str.split("~");
    return Integer.parseInt(ints[1]);
  }
  static class LineChangeData {
    int line;
    String before;
    String after;
    public LineChangeData(int line_, String before_, String after_) {
      line=line_;
      before=before_;
      after=after_;
    }
  }
}
