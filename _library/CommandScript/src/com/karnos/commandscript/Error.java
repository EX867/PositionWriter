package com.karnos.commandscript;
public class LineError implements Comparable<LineError>{
  public static final int PRIOR=0;
  public static final int ERROR=1;
  public static final int WARNING=2;
  public int type;
  int line;
  String location;
  String cause;
  public LineError(int type_,int line_,String location_,String cause_){
    type=type_;
    line=line_;
    location=location_;
    cause=cause_;
  }
  @Override String toString() {
    if (type==ERROR)return "Error! (line "+line+" ,"location+") : "+cause;//not showing code(for removing)
    if (type==WARNING)return "Warning! (line "+line+" ,"+location+") : "+cause;
    return "No content";
  }
  @Override int compareTo(LineError other){
    if(line!=other.line)return line-other.line;
    return other.type-type;
  }
}
