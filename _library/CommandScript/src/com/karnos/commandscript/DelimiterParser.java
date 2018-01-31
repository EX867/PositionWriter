package com.karnos.commandscript;
import java.util.ArrayList;
import java.util.LinkedList;
public class DelimiterParser extends Analyzer {
  // public static boolean debug=false;
  public DelimiterParser(LineCommandType commandType_, LineCommandProcessor processor_) {
    super(commandType_, processor_);
  }
  //FIX>>allocation optimization...?
  public Command parse(int line, String location_, String text) {
    if (debug) {
      System.out.println("parsing line " + line + ", \"" + text + "\"...");
    }
    if (text == null) return null;
    text=CommandScript.split(text, "//")[0].trim();//remove comments
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
              return commandType.getErrorCommand();
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
      return commandType.getEmptyCommand();//so search() not returns result "expected (first layer)...".
    }
    LinkedList<Parameter> command=search(params, paramsPoint, line, location_, text);
    if (command == null) {
      //error added from search function!!
      return commandType.getErrorCommand();
    }
    StringBuilder key=new StringBuilder();
    int b=0;
    for (Parameter p : command) {
      key.append(p.name);
      if (b != command.size() - 1) key.append(seperator);
      b++;
    }
    return commandType.getCommand(this, line, location_, text, key.toString(), params);
  }
  private LinkedList<Parameter> search(ArrayList<String> tokens, ArrayList<Integer> tokensPoint, int line, String location_, String text) {
    //end 4 parameters are harming this generalization...
    //this range problem has to solve later!
    ArrayList<LinkedList<Parameter>> command=new ArrayList<LinkedList<Parameter>>();//result of matches
    Multiset<Parameter> parents=new Multiset<Parameter>(new LinkedList<Parameter>());//queue.
    parents.add(commands);
    int count=1;
    int index=0;
    while (index <= tokens.size()) {//bfs to search!
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
              } else {
                if (next.variation != null) {
                  for (String vari : next.variation) {
                    if (tokens.get(index).equals(vari)) {
                      parents.add(next);
                      matches++;
                      break;
                    }
                  }
                }
              }
            } else if (next.type == Parameter.WRAPPED_STRING) {
              if (isWrappedString(tokens.get(index), wrapper)) {
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
          addError(new LineError(LineError.ERROR, line, 0, text.length(), location_, "command is too long"));
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
}
