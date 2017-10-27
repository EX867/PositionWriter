package com.karnos.commandscript;
import java.util.ArrayList;
public class Parameter implements Comparable<Parameter> {//this is used for form of command, not real command. this class stores data (struct).
  public static final int ERROR=0;
  public static final int STRING=1;//number means priority too.
  public static final int FLOAT=2;
  public static final int RANGE=3;//now only supports int. this contains int.
  public static final int INTEGER=4;//in parsing-considered as float, but prior than float.
  public static final int FIXED=5;//if fixed, name equals value.
  public static final int WRAPPED_STRING=6;//like string literals ignoring meta symbols.
  public static final int HEX=7;//hex value with length 6.(not supporting 8 for now)
  Parameter parent=null;//used for backtracking in search().
  ArrayList<Parameter> children;
  //identifiers
  public int type;//originally, are parameters are string.
  public String name;//name inside of command.
  public String[] variation;//variation for fixed commands.
  //range checking will be done in LineCommandType.
  public boolean isEnd=false;//checks if this node is end of command.
  public Parameter(int type_, String name_) {
    type=type_;
    name=name_;
    children=new ArrayList<Parameter>();
  }
  public Parameter(ParamInfo info) {
    type=info.type;
    name=info.name;
    if (info.variation != null) variation=info.variation;
    children=new ArrayList<Parameter>();
  }
  @Override
  public boolean equals(Object other) {
    if (other instanceof Parameter) {
      Parameter p=(Parameter)other;
      if (type == p.type && name.equals(p.name)) return true;
    } else if (other instanceof ParamInfo) {
      ParamInfo p=(ParamInfo)other;
      if (type == p.type && name.equals(p.name)) return true;
    }
    return false;
  }
  public static String getTypeName(int type_) {
    switch (type_) {
      case STRING:
        return "String";
      case FLOAT:
        return "Float";
      case INTEGER:
        return "Integer";
      case RANGE:
        return "Range";
      case FIXED:
        return "Fixed";
      case WRAPPED_STRING:
        return "Wrapped_string";
      case HEX:
        return "Hex";
    }
    return "";
  }
  public static int getTypeId(String name) {
    if (name.equals("String")) return STRING;
    if (name.equals("Float")) return FLOAT;
    if (name.equals("Integer")) return INTEGER;
    if (name.equals("Range")) return RANGE;
    if (name.equals("Fixed")) return FIXED;
    if (name.equals("Wrapped_string")) return WRAPPED_STRING;
    if (name.equals("Hex")) return HEX;
    return ERROR;
  }
  @Override
  public int compareTo(Parameter o) {
    return o.type - type;
  }
}
