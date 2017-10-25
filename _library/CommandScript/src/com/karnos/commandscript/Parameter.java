package com.karnos.commandscript;
import java.util.ArrayList;
public class Parameter {//this is used for form of command, not real command. this class stores data (struct).
  public static final int STRING=0;//number means priority too.
  public static final int INTEGER=1;//in parsing-considered as float, but prior than float.
  public static final int FLOAT=2;
  public static final int RANGE=3;//now only supports int.
  public static final int FIXED=4;//if fixed, name equals value.
  public static final int WRAPPED_STRING=5;//like string literals ignoring meta symbols.
  public static final int HEX=6;//hex value with length 6.(not supporting 8 for now)
  ArrayList<Parameter> children;
  //identifiers
  public int type;//originally, are parameters are string.
  public String name;//name inside of command.
  //range checking will be done in LineCommandProcesser.
  public Parameter(int type_, String name_) {
    type=type_;
    name=name_;
    children=new ArrayList<Parameter>();
  }
  @Override
  public boolean equals(Object other) {
    if (other instanceof Parameter) {
      Parameter p=(Parameter)other;
      if (type == p.type && name.equals(p.name)) return true;
    }
    return false;
  }
}
