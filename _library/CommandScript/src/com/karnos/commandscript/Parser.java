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
    ArrayList<Integer> paramsPoint=new ArrayList<Integer>();
    int a=0;
    StringBuilder buffer=new StringBuilder();
    paramsPoint.add(0);//length is may be params+1. use params.size() instead.
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
      paramsPoint.add(a);
    }
    if (params.size() == 0) {
      return processer.getEmptyCommand();//so search() not returns result "expected (first layer)...".
    }
    LinkedList<Parameter> command=search(params, paramsPoint, line, location_, text);
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
  private LinkedList<Parameter> search(ArrayList<String> tokens, ArrayList<Integer> tokensPoint, int line, String location_, String text) {//end 4 parameters are harming this generalization...
    //this range problem has to solve later!
    //bfs to search!!
    ArrayList<LinkedList<Parameter>> command=new ArrayList<LinkedList<Parameter>>();//result of matches
    Multiset<Parameter> parents=new Multiset<Parameter>(new LinkedList<Parameter>());//queue.
    parents.add(commands);
    int count=1;
    int index=0;
    while (parents.size() != 0) {
      if (index >= tokens.size()) break;//
      count=parents.size();
      int matches=0;
      LinkedList<Parameter> availableParameters=new LinkedList<Parameter>();
      for (int a=0; a < count; a++) {//ADD inside of this loop to bfs commands and matching command! what are expectations?
        if (index < tokens.size()) {
          for (Parameter next : parents.get(0).children) {
            availableParameters.add(next);
            switch (next.type) {
              case Parameter.STRING:
                parents.add(next);
                matches++;
              case Parameter.INTEGER:
                if (isInt(tokens.get(index))) parents.add(next);
                matches++;
              case Parameter.FLOAT:
                if (isFloat(tokens.get(index))) parents.add(next);
                matches++;
              case Parameter.RANGE:
                if (isRange(tokens.get(index))) parents.add(next);
                matches++;
              case Parameter.FIXED:
                if (tokens.get(index).equals(next.name)) parents.add(next);
                matches++;
              case Parameter.WRAPPED_STRING:
                if (isWrappedString(tokens.get(index))) parents.add(next);
                matches++;
              case Parameter.HEX:
                if (isHex(tokens.get(index))) parents.add(next);
                matches++;
            }
          }
        } else {
          if (parents.get(0).isEnd) {//end of command
            LinkedList<Parameter> result=new LinkedList<Parameter>();
            command.add(result);
            Parameter next=parents.get(0);
            result.addFirst(next);
            while (next.parent != null) {
              result.addFirst(next.parent);
              next=next.parent;
            }
            //else add to available errors... if no matching
          } else {
            availableParameters.add(parents.get(0));
          }
        }
        parents.remove(parents.size() - 1);
      }
      if (matches == 0) {//no matching command in all available branches!
        StringBuilder builder=new StringBuilder("");
        int b=0;
        for (Parameter next : availableParameters) {
          builder.append(next.name).append('(').append(Parameter.getTypeName(next.type)).append(')');
          if (b != availableParameters.size()) builder.append(" or ");
          b++;
        }
        if (builder.length() != 0) builder.deleteCharAt(builder.length() - 1);
        addError(new LineError(LineError.ERROR, line, tokensPoint.get(index), text.length(), location_, builder.toString() + " expected"));
        return null;
      }
      index++;
    }
    if (command.size() == 0) return null;
    return command.get(0);
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
