package com.karnos.commandscript;
public class LineError implements Comparable<LineError> {
  public static final int PRIOR=0;
  public static final int ERROR=1;
  public static final int WARNING=2;
  public int type;
  public int line;
  public int start;
  public int end;
  public String location;
  public String cause;
  public LineError(int type_, int line_, int start_, int end_, String location_, String cause_) {
    type=type_;
    line=line_;
    start=start_;
    end=end_;
    location=location_;
    cause=cause_;
  }
  @Override
  public String toString() {
    if (type == ERROR) return "Error! (line " + line + " ," + location + ") : " + cause;//not showing code(for removing)
    if (type == WARNING) return "Warning! (line " + line + " ," + location + ") : " + cause;
    return "No content";
  }
  @Override
  public int compareTo(LineError other) {
    if (line != other.line) return line - other.line;
    else if (type != other.type) return other.type - type;
    else if (start <= other.start && other.end <= end) return 1;
    else return other.start - start;
  }
}
