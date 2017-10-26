package com.karnos.commandscript;
import java.util.ArrayList;
import java.util.LinkedList;
public class Parser {//Analyzes specific Script and stores parsed commands.
  public static boolean debug=true;
  public ArrayList<Command> lines;
  private Parameter commands;//root of commands
  LineCommandProcesser processer;
  public Multiset<LineError> errors;
  private LineError cacheError;
  String location="";
  char seperator=' ';
  char range='~';
  char wrapper='\"';
  public Parser(LineCommandProcesser processer_) {
    errors=new Multiset<LineError>();
    cacheError=new LineError(LineError.PRIOR, 0, 0, 0, "", "");
    processer=processer_;
    commands=processer.commands;
    seperator=processer.seperator;
    range=processer.range;
    wrapper=processer.wrapper;
    lines=new ArrayList<Command>();
  }
  public void clear() {
    processer.clear();
  }
  public void readAll(ArrayList<String> lines) {
    //ADD
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
    errors.add(error);
  }
  public void removeErrors(int line) {
    cacheError.line=line;
    int index=errors.getBeforeIndex(cacheError) - 1;//because this returns after same values.
    while (index >= 0 && index <= errors.size() && errors.get(index).line == line) {
      errors.remove(index);
    }
  }
  public void add(int line, String before_, String after_) {
    Command before=parse(line, location, before_);//make this to queue and thread...
    Command after=parse(line, location, after_);//make this to queue and thread...
    assert before != null || after != null;
    if (before == null) {
      lines.add(line, after);
    } else if (after == null) {
      lines.remove(line);
    } else {
      lines.set(line, after);
    }
    processer.processCommand(line, before, after);
  }
  public Command parse(int line, String location_, String text) {
    if (text == null) return null;
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
          while (a >= text.length() || text.charAt(a) != wrapper) {
            if (a >= text.length()) {
              addError(new LineError(LineError.ERROR, line, wrapperChar, text.length(), location_, "unterminated wrapped string"));
              return processer.getErrorCommand();
            }
            buffer.append(text.charAt(a));
            a++;
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
    int b=0;
    for (Parameter p : command) {
      key.append(p.name);
      if (b != command.size() - 1) key.append(seperator);
      b++;
    }
    return processer.buildCommand(key.toString(), params);
  }
  private LinkedList<Parameter> search(ArrayList<String> tokens, ArrayList<Integer> tokensPoint, int line, String location_, String text) {//end 4 parameters are harming this generalization...
    //this range problem has to solve later!
    //bfs to search!!
    ArrayList<LinkedList<Parameter>> command=new ArrayList<LinkedList<Parameter>>();//result of matches
    Multiset<Parameter> parents=new Multiset<Parameter>(new LinkedList<Parameter>());//queue.
    parents.add(commands);
    int count=1;
    int index=0;
    while (index <= tokens.size()) {
      count=parents.size();
      LinkedList<Parameter> parents_turn=new LinkedList<Parameter>();
      for (int a=0; a < count; a++) {
        parents_turn.add(parents.get(a));
      }
      parents.clear();
      int matches=0;
      LinkedList<Parameter> availableParameters=new LinkedList<Parameter>();
      for (int a=0; a < count; a++) {
        if (index < tokens.size()) {
          for (Parameter next : parents_turn.getFirst().children) {
            availableParameters.add(next);
            if (debug) System.out.print("[" + parents_turn.getFirst().name + " - " + next.name + "] ");
            if (next.type == Parameter.STRING) {
              parents.add(next);
              matches++;
            } else if (next.type == Parameter.FLOAT) {
              if (isFloat(tokens.get(index))) {
                parents.add(next);
                matches++;
              }
            } else if (next.type == Parameter.INTEGER) {
              if (isInt(tokens.get(index))) {
                parents.add(next);
                matches++;
              }
            } else if (next.type == Parameter.RANGE) {
              if (isRange(tokens.get(index))) {
                parents.add(next);
                matches++;
              }
            } else if (next.type == Parameter.FIXED) {
              if (tokens.get(index).equals(next.name)) {
                parents.add(next);
                matches++;
              }
            } else if (next.type == Parameter.WRAPPED_STRING) {
              if (isWrappedString(tokens.get(index))) {
                parents.add(next);
                matches++;
              }
            } else if (next.type == Parameter.HEX) {
              if (isHex(tokens.get(index))) {
                parents.add(next);
                matches++;
              }
            }
          }
        } else {
          availableParameters.add(parents_turn.getFirst());
          if (parents_turn.getFirst().isEnd) {//end of command
            LinkedList<Parameter> result=new LinkedList<Parameter>();
            command.add(result);
            Parameter next=parents_turn.getFirst();
            result.addFirst(next);
            while (next.parent != null) {
              result.addFirst(next.parent);
              next=next.parent;
            }
            matches++;
            //else add to available errors... if no matching
          } else {
            availableParameters.add(parents_turn.getFirst());
          }
        }
        parents_turn.pollFirst();
      }
      if (debug) System.out.println("[matching : " + matches + "] ");
      if (matches == 0) {//no matching command in all available branches!
        if (availableParameters.size() == 0) {
          addError(new LineError(LineError.ERROR, line, 0, text.length(), location_, " command is too long"));
        } else {
          StringBuilder builder=new StringBuilder("");
          int b=0;
          for (Parameter next : availableParameters) {
            builder.append(next.name).append('(').append(Parameter.getTypeName(next.type)).append(')');
            if (b != availableParameters.size() - 1) builder.append(" or ");
            b++;
          }
          addError(new LineError(LineError.ERROR, line, tokensPoint.get(index), text.length(), location_, builder.toString() + " expected"));
        }
        return null;
      }
      index++;
    }
    if (command.size() == 0) {
      addError(new LineError(LineError.ERROR, line, tokensPoint.get(index), text.length(), location_, "No matching command!"));
      return null;
    }
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
