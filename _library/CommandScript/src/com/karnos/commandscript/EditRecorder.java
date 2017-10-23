package com.karnos.commandscript;
import java.util.ArrayList;
public class EditRecorder{
  static final int LOGHISTORY_SIZE=5000;//just AfterLog size.
  ArrayList<Difference> BeforeLog=new ArrayList<Difference>();
  ArrayList<Difference> AfterLog=new ArrayList<Difference>();//real log.
  ArrayList<Difference> RedoStack=new ArrayList<Difference>();
  public void add(Difference in) {
    BeforeLog.add(in);
  }
  public void recordLog() {//this will be done in script.
    shiftLog();
  }
  void shiftLog() {//just add data to last.
    RedoStack.clear();//clears stack on input.
    if (BeforeLog.size()==0)return;
    int a=0;
    int index;
    if (AfterLog.size()==0)index=0;
    else index=AfterLog.get(AfterLog.size()-1).index;
    index++;
    while (a<BeforeLog.size()) {
      AfterLog.add(BeforeLog.get(a).setIndex(index));
      if (AfterLog.size()>LOGHISTORY_SIZE) {
        AfterLog.remove(0);
      }
      a=a+1;
    }
    BeforeLog.clear();
  }
  public void undo(){
    if (BeforeLog.size()!=0)shiftLog();
    if (AfterLog.size()<=2)return;
    int index=AfterLog.get(AfterLog.size()-1).index;
    int a=AfterLog.size()-1;
    while (a>0&&AfterLog.get(AfterLog.size()-1).index==index) {
      AfterLog.get(a).undo();
      RedoStack.add(AfterLog.get(a));
      AfterLog.remove(a);
      a=AfterLog.size()-1;
    }
  }
  public void redo(){
    if (RedoStack.size()==0)return;
    int a=RedoStack.size()-1;
    int index=RedoStack.get(a).index;
    while (a>=0&&RedoStack.get(RedoStack.size()-1).index==index) {
      RedoStack.get(a).redo();
      AfterLog.add(RedoStack.get(a));
      RedoStack.remove(a);
      a=RedoStack.size()-1;
    }
  }
}
