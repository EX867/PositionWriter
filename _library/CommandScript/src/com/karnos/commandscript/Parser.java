package com.karnos.commandscript;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
public class Parser {//Analyzes specific Script and stores parsed commands.
  public ArrayList<Command> lines;
  private Parameter commands;//root of commands
  private HashMap<String, String> commandNames;//just giving a name for parameter sequence!
  LineCommandProcesser processer;
  public Multiset<LineError> errors;
  private LineError cacheError;
  public char seperator=' ';
  public char range='~';
  public char wrapper='\"';
  public Parser(LineCommandProcesser processer_) {
    errors=new Multiset<LineError>();
    cacheError=new LineError(LineError.PRIOR, 0, 0, 0, "", "");
    processer=processer_;
    commands=processer.commands;
    commandNames=processer.commandNames;
    lines=new ArrayList<Command>();
  }
  public void clear() {
    processer.clear();
  }
  public void readAll(ArrayList<String> lines) {
    //ADD
  }
  public void addError(LineError error) {
    errors.add(error);
  }
  public void removeErrors(int line) {
    cacheError.line=line;
    int index=errors.getBeforeIndex(cacheError) - 1;//because this returns after same values.
    while (index >= 0 && index <= errors.size() && errors.get(index).line == line) {
      errors.remove(index);
    }
  }
  public void add(int line, String location_, String text) {
    parse(line, location_, text);//make this to queue and thread...
  }
  public Command parse(int line, String location_, String text) {
    cacheError.line=line - 1;
    for (int a=errors.getBeforeIndex(cacheError); a < errors.size() && errors.get(a).line == line; ) {
      errors.remove(a);
    }
    ArrayList<String> params=new ArrayList<String>();
    int a=0;
    StringBuilder buffer=new StringBuilder();
    while (true) {
      if (a >= text.length()) break;
      while (a < text.length() && text.charAt(a) != seperator) {
        buffer.append(text.charAt(a));
        if (text.charAt(a) == wrapper) {
          int wrapperChar=a;//use in error
          a++;
          while (text.charAt(a) != wrapper) {
            if (a >= text.length()) {
              addError(new LineError(LineError.ERROR, line, wrapperChar, text.length(), location_, "unterminated wrapped string"));
              return processer.getErrorCommand();
            }
            buffer.append(text.charAt(a));
          }
        }
        a++;
      }
      params.add(buffer.toString());
      buffer=new StringBuilder();
      a++;//skip the seperator.
    }
    if (params.size() == 0) {
      return processer.getEmptyCommand();//so search() not returns result "expected (first layer)...".
    }
    ArrayList<Parameter> command=search(params);
    if (command == null) {
      //error added from search function!!
      return processer.getErrorCommand();
    }
    StringBuilder key=new StringBuilder();
    for (Parameter p : command) {
      key.append(p.name).append(seperator);
    }
    return processer.buildCommand(commandNames.get(key.toString()), params);
  }
  private ArrayList<Parameter> search(ArrayList<String> tokens) {
    //bfs to search!!
    ArrayList<ArrayList<Parameter>> command=new ArrayList<ArrayList<Parameter>>();//result of matches
    Multiset<ParameterExpectation> expectations=new Multiset<ParameterExpectation>();//string that really used for error. form=<name>(<type>)
    LinkedList<Parameter> parents=new LinkedList<Parameter>();
    parents.add(commands);
    int count=1;
    int index=0;
    while (parents.size() != 0) {
      if (index >= tokens.size()) break;
      count=parents.size();
      for (int a=0; a < count; a++) {//ADD inside of this loop to bfs commands and matching command! what are expectations?
        int matches=0;
        for (Parameter next : commands.children) {
          switch (next.type) {
            case Parameter.STRING:
              parents.add(next);
            case Parameter.INTEGER:
              if (isInt(tokens.get(index))) parents.add(next);
            case Parameter.FLOAT:
            case Parameter.RANGE:
            case Parameter.FIXED:
            case Parameter.WRAPPED_STRING:
            case Parameter.HEX:
          }
        }
      }
      index++;
    }
    for (int a=0; a < parents.size(); a++) {
      //expectations.add()
    }
    if (command.size() == 0) return null;
    return command.get(0);
  }
  class ParameterExpectation implements Comparable<ParameterExpectation> {
    int index;
    String form;
    public ParameterExpectation(int index_, String form_) {
      index=index_;
      form=form_;
    }
    @Override
    public int compareTo(ParameterExpectation other) {
      return index - other.index;
    }
  }
  //===Checkers===//
  boolean isWrappedString(String in) {
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
    return isInt(ints[0]) && isInt(ints[1]);
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
    return str.matches("\\d*\\.?\\d*");
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
}
