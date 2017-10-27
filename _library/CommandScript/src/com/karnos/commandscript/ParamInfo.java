package com.karnos.commandscript;
public class ParamInfo {
  public int type;
  public String name;
  public String[] variation;
  public ParamInfo(String name_, String type_) {
    type=Parameter.getTypeId(type_);
    name=name_;
  }
  public ParamInfo(String name_, String type_, String... v) {
    type=Parameter.getTypeId(type_);
    name=name_;
    variation=v;
  }
  public ParamInfo(String name_) {
    type=Parameter.FIXED;
    name=name_;
  }
  public ParamInfo(String name_, int type_) {
    type=type_;
    name=name_;
  }
  public ParamInfo(String name_, int type_, String... v) {
    type=type_;
    name=name_;
    variation=v;
  }
}
