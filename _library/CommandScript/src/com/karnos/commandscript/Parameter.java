package com.karnos.commandscript;
public class Parameter extends MergingTree.Node {//this is used for form of command, not real command. this class stores data (struct).
  public static final int STRING=0;//number means priority too.
  public static final int INTEGER=1;
  public static final int FLOAT=2;
  public static final int RANGE=3;
  public static final int ENUM=4;//included fixed.
  public static final int WRAPPED_STRING=5;//like string literals ignoring meta symbols.
  public static final int HEX=6;//hex value with length 6.(not supporting 8 for now)
  //identifiers
  public int type;//originally, are parameters are string.
  public String name;//name inside of command.
  //values
  public String[] value;//used for fixed values.
  public int minI=Integer.MIN_VALUE;//used for checking range.
  public int maxI=Integer.MAX_VALUE;
  public float minF=Float.MIN_VALUE;//used for checking range.
  public float maxF=Float.MAX_VALUE;
  public Parameter(int type_, String name_) {
    type=type_;
    name=name_;
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
