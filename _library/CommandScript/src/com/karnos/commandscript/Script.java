package com.karnos.commandscript;
import kyui.util.EditorString;

import java.util.ArrayList;
public class Script extends EditorString {
  public static final int READ_THRESHOLD=64;
  private ArrayList<String> l;//if modified, add difference.
  public int point=0;
  public int line=0;
  public int selStartLine;
  public int selStartPoint;
  public int selEndLine;
  public int selEndPoint;
  int maxpoint;
  public EditRecorder recorder;
  public Analyzer analyzer;
  public String name;
  public Script(String name_) {
    name=name_;
    l=new ArrayList<String>();
    recorder=new EditRecorder();
    //not set analyzer...
    //FIX>>if analyzer is null, nullpointer exception!
  }
  public void setAnalyzer(LineCommandType commandType, LineCommandProcesser processer_) {
    analyzer=new Analyzer(commandType, processer_);
    analyzer.location=name;
  }
  public void clear() {
    for (int a=l.size() - 1; a >= 0; a--) {
      recorder.add(new LineChange(a, l.get(a), line, point, null, 0, 0));
    }
    line=0;
    point=0;
    l.clear();
    analyzer.clear();
    addLine(0, "");
    recorder.recordLog();
  }
  @Override
  public String toString() {
    if (l.size() == 0) return "";
    StringBuilder builder=new StringBuilder();
    builder.append(l.get(0));
    for (int a=1; a < l.size(); a++) {
      builder.append("\n").append(l.get(a));
    }
    return builder.toString();
  }
  public String toCommandString() {
    return analyzer.toString();
  }
  public ArrayList<String> getRaw() {
    return l;
  }
  public void setRaw(ArrayList<String> l_) {
    l=l_;
  }
  public boolean empty() {
    if (l.size() == 0) return true;
    if (l.size() == 1 && l.get(0).equals("")) return true;
    return false;
  }
  public int lines() {
    return l.size();
  }
  public String getLine(int line_) {
    if (line_ >= l.get(line_).length()) return "";
    return l.get(line_);
  }
  public void readAll() {
    analyzer.readAll(l);
  }
  //analyzer functions
  public int getTotal() {
    return analyzer.total;
  }
  public int getProgress() {
    return analyzer.progress;
  }
  public ArrayList<Command> getCommands() {
    return analyzer.lines;
  }
  public Multiset<LineError> getErrors() {
    return analyzer.errors;
  }
  public void addError(LineError error) {
    analyzer.addError(error);
  }
  public void removeErrors(int line_) {
    analyzer.removeErrors(line_);
  }
  public LineError getFirstError(int line_) {
    return analyzer.getFirstError(line_);
  }
  //===Edit===//
  public void addLine(String text) {
    addLine(l.size(), text);
  }
  public void addLine(int line_, String text) {
    addLine_(line_, text);
    analyzer.read();
  }
  public void deleteLine(int line_) {
    deleteLine_(line_);
    analyzer.read();
  }
  public void setLine(int line_, String text) {
    setLine_(line_, text);
    analyzer.read();
  }
  public void addLine_(int line_, String text) {
    addLineWithoutAnalyze(line_, text);
    analyzer.add(line_, null, text);
  }
  public void deleteLine_(int line_) {
    analyzer.add(line_, l.get(line_), null);
    deleteLineWithoutAnalyze(line_);
  }
  public void setLine_(int line_, String text) {
    String before=l.get(line_);
    setLineWithoutAnalyze(line_, text);
    analyzer.add(line_, before, text);
  }
  void addLineWithoutRecord(int line_, String text) {
    if (text == null) return;
    l.add(line_, text);
    analyzer.add(line_, null, text);
    analyzer.read();
  }
  void deleteLineWithoutRecord(int line_) {
    analyzer.add(line_, l.get(line_), null);
    l.remove(line_);
    analyzer.read();
  }
  void setLineWithoutRecord(int line_, String text) {
    if (text == null) return;
    String before=l.get(line_);
    l.set(line_, text);
    analyzer.add(line_, before, text);
    analyzer.read();
  }
  void addLineWithoutAnalyze(int line_, String text) {
    if (text == null) return;
    l.add(line_, text);
    int afterLine=line;
    if (line_ <= line) {
      afterLine++;
    }
    recorder.add(new LineChange(line_, null, line, point, text, afterLine, point));
  }
  void deleteLineWithoutAnalyze(int line_) {
    int afterLine=line_ - 1;
    int afterPoint=0;
    if (line_ == 0) {
      afterLine=0;
    } else {
      afterPoint=l.get(afterLine).length() - 1;
    }
    recorder.add(new LineChange(line_, l.get(line_), line, point, null, afterLine, afterPoint));
    l.remove(line_);
  }
  void setLineWithoutAnalyze(int line_, String text) {
    if (text == null) return;
    int afterPoint=Math.min(point, l.get(line).length());
    recorder.add(new LineChange(line_, l.get(line_), line, point, text, line, afterPoint));
    l.set(line_, text);
  }
  //===Edit complicated===//
  public void insert(String text) {
    insert(line, point, text);
  }
  public void insert(int line_, int point_, String text) {
    if (text.equals("")) return;
    String[] lines=text.split("\n");
    boolean reread=false;
    if (lines.length > READ_THRESHOLD) reread=true;
    String endText=l.get(line_).substring(point, l.get(line_).length());
    if (reread) analyzer.clear();
    if (reread) setLineWithoutAnalyze(line_, l.get(line_).substring(0, point) + lines[0]);
    else setLine_(line_, l.get(line_).substring(0, point) + lines[0]);
    for (int a=1; a < lines.length; a++) {
      line_++;
      if (reread) addLineWithoutAnalyze(line_, lines[a]);
      else addLine_(line_, lines[a]);
    }
    if (endText.equals("") == false) setLine_(line_, l.get(line_) + endText);
    if (reread) analyzer.readAll(l);
    else analyzer.read();
  }
  public void delete(int startLine, int startPoint, int endLine, int endPoint) {
    if ((startLine < endLine || (startLine == endLine && startPoint < endPoint)) == false) return;
    boolean reread=false;
    if (endLine - startLine > READ_THRESHOLD) reread=true;
    String endText=l.get(endLine).substring(endPoint, l.get(endLine).length());
    if (reread) analyzer.clear();
    if (reread) setLineWithoutAnalyze(startLine, l.get(startLine).substring(0, startPoint));
    else setLine_(startLine, l.get(startLine).substring(0, startPoint));
    for (int a=startLine + 1; a <= endLine; a++) {
      if (reread) deleteLineWithoutAnalyze(startLine + 1);
      else deleteLine_(startLine + 1);
    }
    if (reread) setLineWithoutAnalyze(startLine, l.get(startLine) + endText);//??????
    else setLine_(startLine, l.get(startLine) + endText);
    if (reread) analyzer.readAll(l);
    else analyzer.read();
    maxpoint=point;
  }
  public void deleteBefore(boolean word) {//if word, ctrl. - fix needed
    maxpoint=point;
    if ((point == 0 && line == 0) || empty()) return;
    if (point == 0) {
      if (line == 0) return;
      cursorLeft(false, false);
      setLine_(line, l.get(line) + l.get(line + 1));
      deleteLine_(line + 1);
    } else if (word) {
      boolean isSpace=false;
      String before=l.get(line);
      if (isSpaceChar(l.get(line).charAt(point - 1))) isSpace=true;
      while (l.get(line).length() > 0 && point > 0) {
        if (((isSpace && isSpaceChar(l.get(line).charAt(point - 1)) == false)) || (!isSpace && isSpaceChar(l.get(line).charAt(point - 1)))) break;
        l.set(line, l.get(line).substring(0, point - 1) + l.get(line).substring(Math.min(point, l.get(line).length()), l.get(line).length()));
        point--;
      }
      analyzer.add(line, before, l.get(line));
    } else {
      String before=l.get(line);
      l.set(line, l.get(line).substring(0, point - 1) + l.get(line).substring(Math.min(point, l.get(line).length()), l.get(line).length()));
      cursorLeft(false, false);
      maxpoint=point;
      analyzer.add(line, before, l.get(line));
    }
    maxpoint=point;
    analyzer.read();
  }
  public void deleteAfter(boolean word) {// - fix needed
    maxpoint=point;
    if (empty()) return;
    if (point == l.get(line).length()) {
      if (line == l.size() - 1) return;
      setLine_(line, l.get(line) + l.get(line + 1));
      deleteLine_(line + 1);
    } else if (word) {
      boolean isSpace=false;
      String before=l.get(line);
      if (isSpaceChar(l.get(line).charAt(point))) isSpace=true;
      while (l.get(line).length() > 0 && point < l.get(line).length()) {
        if (((isSpace && isSpaceChar(l.get(line).charAt(point)) == false)) || (!isSpace && isSpaceChar(l.get(line).charAt(point)))) break;
        l.set(line, l.get(line).substring(0, point) + l.get(line).substring(Math.min(point + 1, l.get(line).length()), l.get(line).length()));
      }
      analyzer.add(line, before, l.get(line));
    } else {
      String before=l.get(line);
      l.set(line, l.get(line).substring(0, point) + l.get(line).substring(Math.min(point + 1, l.get(line).length()), l.get(line).length()));
      analyzer.add(line, before, l.get(line));
    }
    maxpoint=point;
    analyzer.read();
  }
  //===Cursor movements===//
  public void setCursor(int line_, int point_) {
    line=line_;
    point=point_;
    if (line >= l.size()) line=l.size() - 1;
    if (point >= l.get(line).length()) point=l.get(line).length() - 1;
  }
  //currently, word is seperated by space.
  public void cursorLeft(boolean word, boolean select) {
    if (word && point != 0) {
      if (l.get(line).length() > 0 && point > 0) {
        boolean isSpace=false;
        if (isSpaceChar(l.get(line).charAt(point - 1))) isSpace=true;
        while (l.get(line).length() > 0 && point > 0) {
          if (((isSpace && isSpaceChar(l.get(line).charAt(point - 1)) == false)) || (!isSpace && isSpaceChar(l.get(line).charAt(point - 1)))) break;
          point--;
        }
      }
      if (select == false) resetSelection();
    } else {
      if (point == 0) {
        if (line != 0) {
          line--;
          point=l.get(line).length();
          if (select == false) resetSelection();
        }
      } else {
        point--;
        if (select == false) resetSelection();
      }
    }
    maxpoint=point;
  }
  public void cursorRight(boolean word, boolean select) {
    if (word && point != l.get(line).length()) {
      if (l.get(line).length() > 0 && point < l.get(line).length()) {
        boolean isSpace=false;
        if (isSpaceChar(l.get(line).charAt(point))) isSpace=true;
        while (l.get(line).length() > 0 && point < l.get(line).length()) {
          if (((isSpace && isSpaceChar(l.get(line).charAt(point)) == false)) || (isSpace == false && isSpaceChar(l.get(line).charAt(point)))) break;
          point++;
        }
      }
      if (select == false) resetSelection();
    } else {
      if (point == l.get(line).length()) {
        if (line < l.size() - 1) {
          line++;
          point=0;
          if (select == false) resetSelection();
        }
      } else {
        point++;
        if (select == false) resetSelection();
      }
    }
    maxpoint=point;
  }
  public void cursorUp(boolean select) {
    if (line == 0) {
      point=0;
    } else {
      line=line - 1;
      point=Math.min(maxpoint, l.get(line).length());
      if (select == false) resetSelection();
    }
  }
  public void cursorDown(boolean select) {
    if (line >= l.size() - 1) {
      point=l.get(l.size() - 1).length();
    } else {
      line=line + 1;
      point=Math.min(maxpoint, l.get(line).length());
      if (select == false) resetSelection();
    }
  }
  public void selectionLeft(boolean word) {
    if (hasSelection() == false) {
      resetSelection();
    }
    cursorLeft(word, true);
    if (line > selStartLine || (selStartPoint < point && selStartLine == line)) {
      selEndPoint=point;
      selEndLine=line;
    } else {
      selStartPoint=point;
      selStartLine=line;
    }
    fixSelection();
  }
  public void selectionRight(boolean word) {
    if (hasSelection() == false) {
      resetSelection();
    }
    cursorRight(word, true);
    if (line > selEndLine || (selEndPoint <= point && selEndLine == line)) {
      selEndPoint=point;
      selEndLine=line;
    } else {
      selStartPoint=point;
      selStartLine=line;
    }
    fixSelection();
  }
  public void selectionUp() {
    if (hasSelection() == false) {
      resetSelection();
    }
    boolean start=false;
    if (selStartLine == line && selStartPoint == point) start=true;
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
  public void selectionDown() {
    if (hasSelection() == false) {
      resetSelection();
    }
    boolean start=true;
    if (selEndLine == line && selEndPoint == point) start=false;
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
    while (a < len) {
      selectionRight(false);
      a=a + 1;
    }
  }
  public void selectAll() {
    selStartLine=0;
    selStartPoint=0;
    selEndLine=l.size() - 1;
    selEndPoint=l.get(l.size() - 1).length();
  }
  public boolean hasSelection() {
    if (selStartLine == selEndLine && selStartPoint == selEndPoint) return false;
    return true;
  }
  public void resetSelection() {
    selStartLine=line;
    selStartPoint=point;
    selEndLine=selStartLine;
    selEndPoint=selStartPoint;
  }
  public String getSelection() {
    return substring(selStartLine, selStartPoint, selEndLine, selEndPoint);
  }
  public void deleteSelection() {
    maxpoint=point;
    if (hasSelection() == false) return;
    delete(selStartLine, selStartPoint, selEndLine, selEndPoint);
    point=selStartPoint;
    line=selStartLine;
    resetSelection();
  }
  //===Recording===//
  public void undo() {
    recorder.undo();
  }
  public void redo() {
    recorder.redo();
  }
  class LineChange extends Difference<Value> {
    //before and after can't be both null.
    int line;
    public LineChange(Value before, Value after) {
      super(before, after);
    }
    public LineChange(int line_, String before_, int beforeLine, int beforePoint, String after_, int afterLine, int afterPoint) {
      super(new Value(before_, beforeLine, beforePoint), new Value(after_, afterLine, afterPoint));
      line=line_;
    }
    @Override
    public void undo() {
      if (before.text == null) {//found index
        deleteLineWithoutRecord(line);
      } else if (after.text == null) {
        addLineWithoutRecord(line, before.text);
      } else {
        setLineWithoutRecord(line, before.text);
      }
      setCursor(before.cursorLine, before.cursorPoint);
    }
    @Override
    public void redo() {
      if (before.text == null) {
        addLineWithoutRecord(line, after.text);
      } else if (after.text == null) {
        deleteLineWithoutRecord(line);
      } else {
        setLineWithoutRecord(line, after.text);
      }
      setCursor(after.cursorLine, after.cursorPoint);
    }
  }
  static class Value {
    String text;
    int cursorLine;
    int cursorPoint;
    public Value(String text_, int line_, int point_) {
      text=text_;
      cursorLine=line_;
      cursorPoint=point_;
    }
  }
  //===Utils===//
  public void setCursorByIndex(int index) {//slow!
    if (l.size() == 0) return;
    int sum=0;
    int psum=0;
    int a=0;
    while (a < l.size()) {
      sum=sum + l.get(a).length();
      if (index < sum) {
        point=Math.min(l.get(a).length(), index - psum);
        line=a;
        return;
      }
      sum=sum + 1;
      psum=sum;
      a=a + 1;
    }
    line=l.size() - 1;
    point=l.get(line).length();
  }
  public int getLineByIndex(int index) {//slow!
    if (l.size() == 0) return 0;
    int sum=l.get(0).length();
    if (index <= sum) return 0;
    int a=1;
    while (a < l.size()) {
      sum=sum + 1 + l.get(a).length();
      if (index <= sum) return a;
      a=a + 1;
    }
    return l.size() - 1;
  }
  public boolean lineEmpty(int line_) {
    if (l.get(line_).equals("")) return true;
    return false;
  }
  public String getSelectionPartBefore(int line_) {
    if (line_ == selStartLine) {
      return l.get(selStartLine).substring(0, selStartPoint);
    }
    return "";
  }
  public String getSelectionPart(int line_) {
    if (line_ == selStartLine) return l.get(selStartLine).substring(selStartPoint, l.get(selStartLine).length()) + "\n";
    if (line_ > selStartLine && line_ < selEndLine) {
      return l.get(line_) + "\n";
    }
    if (selEndLine >= l.size()) selEndLine=l.size() - 1;
    if (selEndPoint > l.get(selEndLine).length()) selEndPoint=l.get(selEndLine).length();
    if (line_ == selEndLine) return l.get(selEndLine).substring(0, selEndPoint);
    return "";
  }
  public String substring(int startLine, int startPoint, int endLine, int endPoint) {
    fixSelection();
    if (selStartLine == selEndLine) return l.get(selStartLine).substring(selStartPoint, selEndPoint);
    StringBuilder ret=new StringBuilder();
    ret.append(l.get(selStartLine).substring(selStartPoint, l.get(selStartLine).length()));
    for (int a=selStartLine + 1; a < selEndLine; a++) {
      ret=ret.append("\n").append(l.get(a));
    }
    ret=ret.append("\n").append(l.get(selEndLine).substring(0, selEndPoint));
    return ret.toString();
  }
  //===Privates===//
  private boolean isSpaceChar(char in) {
    if (in == ' ' || in == '\t' || in == '\n' || in == '\r') return true;
    return false;
  }
  public void fixSelection() {//swap selection is wrong.
    if (selStartLine > selEndLine || (selStartLine == selEndLine && selStartPoint > selEndPoint)) {
      int temp=selEndLine;
      selEndLine=selStartLine;
      selStartLine=temp;
      temp=selEndPoint;
      selEndPoint=selStartPoint;
      selStartPoint=temp;
    }
    if (selStartLine >= l.size()) selStartLine=l.size() - 1;
    else if (selStartLine < 0) selStartLine=0;
    if (selEndLine >= l.size()) selEndLine=l.size() - 1;
    else if (selEndLine < 0) selEndLine=0;
    if (selStartPoint >= l.get(selStartLine).length()) selStartPoint=l.get(selStartLine).length() - 1;
    else if (selStartPoint < 0) selStartPoint=0;
    if (selEndPoint >= l.get(selEndLine).length()) selEndPoint=l.get(selEndLine).length() - 1;
    else if (selEndPoint < 0) selEndPoint=0;
  }
}
