package com.karnos.commandscript;
public class Script{
  private ArrayList<String> l;//if modified, add difference.
  public int point=0;
  public int line=0;
  public int selStartLine;
  public int selStartPoint;
  public int selEndLine;
  public int selEndPoint;
  int maxpoint;
  EditRecorder recorder;
  Parser parser;
  public Script(Parser parser_){
    l=new ArrayList<String>();
    recorder=new EditRecorder();
    parser=parser_;
  }
  public void clear(){
    for(int a=l.size()-1;a>=0;a--){
      recorder.add(new LineChange(a, l.get(a),line,point, null,0,0));
    }
    line=0;
    point=0;
    l.clear();
    parser.clear();
    addLine(0, "");
    recorder.RecordLog();
  }
  @Override
    synchronized String toString() {
    if (l.size()==0)return "";
    StringBuilder builder = new StringBuilder();
    builder.append(l.get(0));
    for(int a=1;a<l.size();a++){
      builder.append("\n").append(l.get(a));
    }
    return builder.toString();
  }
  public boolean empty() {
    if (l.size()==0)return true;
    if (l.size()==1&&l.get(0).equals(""))return true;
    return false;
  }
  public int lines() {
    return l.size();
  }
  public String getLine(int line_){
    if(line_>=line.size())return "";
    return l.get(line_);
  }
  void readAll(){
    parser.readAll();
  }
  //===Edit===//
  public void addLine(int line_,String text){
    addLineWithoutParse(line_,text);
    parser.add(line_,null,text);
  }
  public void deleteLine(int line_){
    parser.add(line_,l.get(line_),null);
    deleteLineWithoutParse(line_);
  }
  public void setLine(int line_,String text){
    String before=l.get(line_);
    setLineWithoutParse(line_,text);
    parser.add(line_,before,text);
  }
  void addLineWithoutRecord(int line_,String text){
    if (text==null)return;
    l.add(line_, text);
    parser.add(line_,null,text);
  }
  void deleteLineWithoutRecord(int line_){
    parser.add(line_,l.get(line_),null);
    l.remove(line_);
  }
  void setLineWithoutRecord(int line_,String text){
    if (text==null)return;
    String before=l.get(line_);
    l.set(line_, text);
    parser.add(line_,before,text);
  }
  void addLineWithoutParse(int line_,String text){
    if (text==null)return;
    l.add(line_, text);
    int afterLine=line;
    if(line_<=line){
      afterLine++;
    }
    recorder.add(new LineChange(line_,null,line,point,text,afterLine,point));
  }
  void deleteLineWithoutParse(int line_){
    int afterLine=line_-1;
    int afterPoint=0;
    if(line_==0){
      afterLine=0;
    }else{
      afterPoint=l.get(afterLine).length()-1;
    }
    recorder.add(new LineChange(aline_ l.get(line_),line,point, null,afterLine,afterPoint));
    l.remove(line_);
  }
  void setLineWithoutParse(int line_,String text){
    if (text==null)return;
    int afterPoint=min(point,l.get(line).length());
    recorder.add(new LineChange(line_,l.get(line_),line,point,text,line,afterPoint));
    l.set(line_, text);
  }
  //===Edit conplicated===//
  public void deleteSelection() {
    maxpoint=point;
    if (hasSelection()==false)return;
    delete(selStartLine, selStartPoint, selEndLine, selEndPoint);
    point=selStartPoint;
    line=selStartLine;
    resetSelection();
  }
  //===Cursor movements===//
  public void setCursor(int line_,int point_){
    line=line_;
    point=point_;
    if(line>=l.size())l=l.size()-1;
    if(point>=l.get(line).length())point=l.get(line).length()-1;
  }
  //currently, word is seperated by space.
  void cursorLeft(boolean word, boolean select) {
    if (word&&point!=0) {
      if (l.get(line).length()>0&&point>0) {
        boolean isSpace=false;
        if (isSpaceChar(l.get(line).charAt(point-1)))isSpace=true;
        while (l.get(line).length()>0&&point>0) {
          if (((isSpace&&isSpaceChar(l.get(line).charAt(point-1))==false))||(isSpace==false&&isSpaceChar(l.get(line).charAt(point-1))))break;
          point--;
        }
      }
      if (select==false)Lines.resetSelection();
    } else {
      if (point==0) {
        if (line!=0) {
          line--;
          point=l.get(line).length();
          if (select==false)Lines.resetSelection();
        }
      } else {
        point--;
        if (select==false)Lines.resetSelection();
      }
    }
    maxpoint=point;
  }
  void cursorRight(boolean word, boolean select) {
    if (word&&point!=l.get(line).length()) {
      if (l.get(line).length()>0&&point<l.get(line).length()) {
        boolean isSpace=false;
        if (isSpaceChar(l.get(line).charAt(point)))isSpace=true;
        while (l.get(line).length()>0&&cursor<l.get(line).length()) {
          if (((isSpace&&isSpaceChar(l.get(line).charAt(point))==false))||(isSpace==false&&isSpaceChar(l.get(line).charAt(point))))break;
          point++;
        }
      }
      if (select==false)Lines.resetSelection();
    } else {
      if (point==l.get(line).length()) {
        if (line<l.size()-1) {
          line++;
          point=0;
          if (select==false)Lines.resetSelection();
        }
      } else {
        point++;
        if (select==false)Lines.resetSelection();
      }
    }
    maxpoint=point;
  }
  void cursorUp(boolean select) {
    if (line==0) {
      cursor=0;
    }else{
      line=line-1;
      point=min(maxpoint, l.get(line).length());
      if (select==false)resetSelection();
    }
  }
  void cursorDown(boolean select) {
    if (line>=l.size()-1) {
      cursor=l.get(l.size()-1).length();
    }else{
      line=line+1;
      point=min(maxpoint, l.get(line).length());
      if (select==false)resetSelection();
    }
  }
  void selectionLeft(boolean word) {
    if (hasSelection()==false) {
      resetSelection();
    }
    cursorLeft(word, true);
    if (line>selStartLine||(selStartPoint<point&&selStartLine==line)) {
      selEndPoint=point;
      selEndLine=line;
    } else {
      selStartPoint=point;
      selStartLine=line;
    }
    fixSelection();
  }
  void selectionRight(boolean word) {
    if (hasSelection()==false) {
      resetSelection();
    }
    cursorRight(word, true);
    if (line>selEndLine||(selEndPoint<=point&&selEndLine==line)) {
      selEndPoint=point;
      selEndLine=line;
    } else {
      selStartPoint=point;
      selStartLine=line;
    }
    fixSelection();
  }
  void selectionUp() {
    if (hasSelection()==false) {
      resetSelection();
    }
    boolean start=false;
    if (selStartLine==line&&selStartPoint==point)start=true;
    cursorUp(true);
    if (start) {
      selStartPoint=point;
      selStartLine=line;
    } else {
      selEndPoint=point;
      selEndLine=line;
    }
    fixSelection();
  }
  void selectionDown() {
    if (hasSelection()==false) {
      resetSelection();
    }
    boolean start=true;
    if (selEndLine==line&&selEndPoint==point)start=false;
    cursorDown(true);
    if (start) {
      selStartPoint=point;
      selStartLine=line;
    } else {
      selEndPoint=point;
      selEndLine=line;
    }
    fixSelection();
  }
  //===Selection===//
  public void selectFromCursor(int len) {
    resetSelection();
    int a=0;
    while (a<len) {
      selectionRight(false);
      a=a+1;
    }
  }
  public void selectAll() {
    selStartLine=0;
    selStartPoint=0;
    selEndLine=l.size()-1;
    selEndPoint=l.get(l.size()-1).length();
  }
  public boolean hasSelection() {
    if (selStartLine==selEndLine&&selStartPoint==selEndPoint)return false;
    return true;
  }
  public void resetSelection() {
    selStartLine=line;
    selStartPoint=point;
    selEndLine=selStartLine;
    selEndPoint=selStartPoint;
  }
  //===Recording===//
  public void undo(){
    recorder.undo();
  }
  public void redo(){
    recorder.redo();
  }
  class LineChange extends Difference<LineChange.Value>{
    //before and after can't be both null.
    int line;
    class Value{
      String text;
      int cursorLine;
      int cursorPoint;
      public Value(String text_,int line_,int point_){
        text=text_;
        cursorLint=line_;
        cursorPoint=point_;
      }
    }
    public LineChange(int line_,String before_,int beforeLine,int beforePoint,String after_,int afterLine,int afterPoint){
      line=line_;
      super(new Value(before_,beforeLine,beforePoint),new Value(after_,afterLine,afterPoint));
    }
    @Override public void undo(){
      if (before.text==null) {//found index
        deleteLineWithoutRecord(line);
      } else if (after.text==null) {
        addLineWithoutRecord(line,before.text);
      } else {
        setLineWithoutRecord(line,before.text);
      }
      setCursor(before.cursorLine,before.cursorPoint);
    }
    @Override public void redo(){
      if (before.text==null) {
        addLineWithoutRecord(line,after.text);
      } else if (after.text==null) {
        deleteLineWithoutRecord(line);
      } else {
        setLineWithoutRecord(line, after.text);
      }
      setCursor(after.cursorLine,after.cursorPoint);
    }
  }
  //===Utils===//
  public void setCursorByIndex(int index) {//slow!
    if(l.size()==0)return;
    int sum=0;
    int psum=0;
    int a=0;
    while (a<l.size()) {
      sum=sum+l.get(a).length();
      if (index<sum) {
        point=min(l.get(a).length(), index-psum);
        line=a;
        return;
      }
      sum=sum+1;
      psum=sum;
      a=a+1;
    }
    line=l.size()-1;
    point=l.get(line).length();
  }
  public int getLineByIndex(int index) {//slow!
    if(l.size()==0)return 0;
    int sum=l.get(0).length();
    if (index<=sum)return 0;
    int a=1;
    while (a<l.size()) {
      sum=sum+1+l.get(a).length();
      if (index<=sum)return a;
      a=a+1;
    }
    return l.size()-1;
  }
  public boolean lineEmpty(int line_) {
    if (l.get(line_).equals(""))return true;
    return false;
  }
  //===Privates===//
  private boolean isSpaceChar(char in){
   if(in==' '||in=='\t'||in=='\n'||in=='\r')return true;
    return false;
  }
  private void fixSelection() {//swap selection is wrong.
    if (selStartLine>selEndLine||(selStartLine==selEndLine&&selStartPoint>selEndPoint)) {
      int temp=selEndLine;
      selEndLine=selStartLine;
      selStartLine=temp;
      temp=selEndPoint;
      selEndPoint=selStartPoint;
      selStartPoint=temp;
    }
  }
  public static void main(String[] args){
    System.out.println("CommandScript class files");
  }
}
