package com.karnos.commandscript;
public class ParameterInfo {
  public int type;
  public String name;
  public ParameterInfo(String type_, String name_) {
    type=Parameter.getTypeId(type_);
    name=name_;
  }
  public ParameterInfo(String name_) {
    type=Parameter.FIXED;
    name=name_;
  }
  public ParameterInfo(int type_, String name_) {
    type=type_;
    name=name_;
  }
}
