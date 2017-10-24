package com.karnos.commandscript;
import java.util.ArrayList;
import java.util.HashMap;
public class Parser {
  MergingTree commands;
  HashMap<String,String> commandNames;//just giving a name for parameter sequence!
  LineCommandProcesser processer;
  public Multiset<LineError> errors;
  private LineError cacheError;
  public char seperator=' ';
  public char range='~';
  public char wrapper='\"';
  public Parser(LineCommandProcesser processer_) {
    errors=new Multiset<LineError>();
    commandNames=new HashMap<String,String>();
    cacheError=new LineError(LineError.PRIOR, 0, "", "");
    processer=processer_;
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
  public Command parse(int line, String location_, String text) {
    StringBuilder key=new StringBuilder();
    ArrayList<String> params=new ArrayList<String>();
    int a=0;
    StringBuilder buffer=new StringBuilder();
    while(a<text.length()){
      while(text.charAt(a)!=seperator){
        buffer.append(text.charAt(a));
        a++;
      }
      params.add(buffer.toString());
      addToKey(key,buffer.toString());
      buffer=new StringBuilder();
      a++;//skip the seperator.
    }
    if(buffer.length()!=0){
      params.add(buffer.toString());
      addToKey(key,buffer.toString());
    }
    return processer.buildCommand(commandNames.get(key.toString().trim()),params);
  }
  void addToKey(StringBuilder base,String token){
    if(token)
  }
  static boolean isBoolean (String in) {
    if (in.equals ("true")||in.equals("false"))return true;
    return false;
  }
  public static boolean isInt(String str) {
    if (str.equals("")) return false;
    if (str.length() > 9) return false;
    if (str.equals("-"))return false;
    // just int or float is needed!
    int a = 0;
    if (str.charAt(0) == '-') a = 1;
    while (a < str.length()) {
      if (!('0' <= str.charAt(a) && str.charAt(a) <='9'))return false;
      a = a + 1;
    }
    return true;
  }
  private boolean isRange(String str) {
    if (isInt(str))return true;
    String[] ints=str.split("~");
    return isInt(ints[0])&&isInt(ints[1]);
  }
  private int getRangeFirst(String str) {
    if (isInt(str))return Integer.parseInt(str);
    String[] ints=str.split("~");
    return Integer.parseInt(ints[0]);
  }
  private int getRangeSecond(String str) {
    if (isInt(str))return Integer.parseInt(str);
    String[] ints=str.split("~");
    return Integer.parseInt(ints[1]);
  }
}
