package com.karnos.commandscript;
import kyui.util.EditorString;

import java.util.ArrayList;
import java.util.List;
public class CommandScript extends EditorString {
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
  }//record unit.
  public static int READ_THRESHOLD=64;
  public EditRecorder recorder;
  public Analyzer analyzer;
  public String name;
  public CommandScript(String name_) {
    super();
    name=name_;
    recorder=new EditRecorder();
    setAnalyzer(null);
    addLine(0, "");
  }
  public CommandScript(String name_, Analyzer analyzer_) {
    super();
    name=name_;
    recorder=new EditRecorder();
    setAnalyzer(analyzer_);
    addLine(0, "");
  }
  //
  //==Analyzer==//
  public CommandScript setAnalyzer(Analyzer analyzer_) {
    if (analyzer_ == null) {
      analyzer_=Analyzer.NO_COMMAND;
    }
    analyzer=analyzer_;
    int count=0;
    for (String line : l) {
      analyzer.add(count, null, line);
      count++;
    }
    analyzer.read();
    analyzer.location=name;
    return this;
  }
  public ArrayList<Command> getCommands() {
    return analyzer.lines;
  }
  public Multiset<LineError> getErrors() {
    return analyzer.errors;
  }
  public int getTotal() {
    return analyzer.total;
  }
  public int getProgress() {
    return analyzer.progress;
  }
  public void readAll() {
    analyzer.readAll(getRaw());
  }
  public Analyzer getAnalyzer() {
    return analyzer;
  }
  public String toCommandString() {
    return analyzer.toString();
  }
  //
  //==Errors==//
  public void addError(LineError error) {
    analyzer.addError(error);
  }
  public void removeErrors(int line_) {
    analyzer.removeErrors(line_);
  }
  public LineError getFirstError(int line_) {
    return analyzer.getFirstError(line_);
  }
  //
  //==Recording==//
  public void undo() {
    recorder.undo();
  }
  public void redo() {
    recorder.redo();
  }
  //
  //==EditorString==//
  @Override
  public void clear() {
    if (analyzer != null) {
      analyzer.clear();
    }
    line=0;
    point=0;
    l.clear();
    if (recorder != null) {
      for (int a=lines() - 1; a >= 0; a--) {
        recorder.add(new CommandScript.LineChange(a, l.get(a), line, point, null, 0, 0));
      }
      addLine(0, "");
      recorder.recordLog();
    }
  }
  //
  //===Edit===//
  @Override
  public void addLine(String text) {
    addLine(lines(), text);
  }
  @Override
  public void addLine(int line_, String text) {
    addLine_(line_, text);
    if (analyzer != null) {
      analyzer.read();
    }
  }
  public void addLine_(int line_, String text) {
    addLineWithoutAnalyze(line_, text);
    if (analyzer != null) {
      analyzer.add(line_, null, text);
    }
  }
  void addLineWithoutRecord(int line_, String text) {
    if (text == null) return;
    l.add(line_, text);
    if (analyzer != null) {
      analyzer.add(line_, null, text);
      analyzer.read();
    }
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
  @Override
  public void deleteLine(int line_) {
    deleteLine_(line_);
    if (analyzer != null) {
      analyzer.read();
    }
  }
  public void deleteLine_(int line_) {
    if (analyzer != null) {
      analyzer.add(line_, l.get(line_), null);
    }
    deleteLineWithoutAnalyze(line_);
  }
  void deleteLineWithoutRecord(int line_) {
    if (analyzer != null) {
      analyzer.add(line_, l.get(line_), null);
    }
    l.remove(line_);
    if (analyzer != null) {
      analyzer.read();
    }
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
  @Override
  public void setLine(int line_, String text) {
    setLine_(line_, text);
    if (analyzer != null) {
      analyzer.read();
    }
  }
  public void setLine_(int line_, String text) {
    String before=l.get(line_);
    setLineWithoutAnalyze(line_, text);
    if (analyzer != null) {
      analyzer.add(line_, before, text);
    }
  }
  void setLineWithoutRecord(int line_, String text) {
    if (text == null) return;
    String before=l.get(line_);
    l.set(line_, text);
    if (analyzer != null) {
      analyzer.add(line_, before, text);
      analyzer.read();
    }
  }
  void setLineWithoutAnalyze(int line_, String text) {
    if (text == null) return;
    int afterPoint=Math.min(point, l.get(line_).length());
    recorder.add(new LineChange(line_, l.get(line_), line, point, text, line, afterPoint));
    l.set(line_, text);
  }
  //===Edit complicated===// - override needed in commandScript.
  @Override
  public void insert(String text) {
    insert(line, point, text);
  }
  @Override
  public void insert(int line_, int point_, String text) {
    if (text.isEmpty()) return;
    String[] lines=split(text, "\n");
    boolean reread=false;
    if (lines.length >= READ_THRESHOLD && analyzer != null) reread=true;
    String endText=l.get(line_).substring(point_, l.get(line_).length());
    if (reread) {
      analyzer.clear();
      setLineWithoutAnalyze(line_, l.get(line_).substring(0, point_) + lines[0]);
    } else {
      setLine_(line_, l.get(line_).substring(0, point_) + lines[0]);
    }
    for (int a=1; a < lines.length; a++) {
      line_++;
      if (reread) {
        addLineWithoutAnalyze(line_, lines[a]);
      } else {
        addLine_(line_, lines[a]);
      }
    }
    if (!endText.isEmpty()) {
      if (reread) {
        setLineWithoutAnalyze(line_, l.get(line_) + endText);
      } else {
        setLine_(line_, l.get(line_) + endText);
      }
    }
    if (reread) {
      readAll();
    } else {
      if (analyzer != null) {
        analyzer.read();
      }
    }
  }
  @Override
  public void delete(int startLine, int startPoint, int endLine, int endPoint) {
    if ((startLine < endLine || (startLine == endLine && startPoint < endPoint)) == false) return;
    if (startLine > l.size() || endLine < 0) return;
    endLine=Math.min(lines() - 1, endLine);
    startPoint=Math.min(l.get(startLine).length(), startPoint);
    endPoint=Math.min(l.get(endLine).length(), endPoint);
    //
    boolean reread=false;
    if (endLine - startLine >= READ_THRESHOLD && analyzer != null) reread=true;
    String endText=l.get(endLine).substring(endPoint, l.get(endLine).length());
    if (reread) {
      analyzer.clear();
      setLineWithoutAnalyze(startLine, l.get(startLine).substring(0, startPoint));
    } else {
      setLine_(startLine, l.get(startLine).substring(0, startPoint));
    }
    for (int a=startLine + 1; a <= endLine; a++) {
      if (reread) {
        deleteLineWithoutAnalyze(startLine + 1);
      } else {
        deleteLine_(startLine + 1);
      }
    }
    if (reread) {
      setLineWithoutAnalyze(startLine, l.get(startLine) + endText);
    } else {
      setLine_(startLine, l.get(startLine) + endText);
    }
    if (reread) {
      readAll();
    } else {
      if (analyzer != null) {
        analyzer.read();
      }
    }
    maxpoint=point;
  }
  @Override
  public String deleteBefore(boolean word) {
    String ret;
    if ((point == 0 && line == 0) || empty()) return "";
    if (point == 0) {
      if (line == 0) return "";
      cursorLeft(false, false);
      setLine_(line, l.get(line) + l.get(line + 1));
      deleteLine_(line + 1);
      ret="\n";
    } else if (word) {
      boolean isSpace=false;
      String before=l.get(line);
      StringBuilder sb=new StringBuilder();
      if (isSpaceChar(l.get(line).charAt(point - 1))) isSpace=true;
      while (l.get(line).length() > 0 && point > 0) {
        if (((isSpace && isSpaceChar(l.get(line).charAt(point - 1)) == false)) || (!isSpace && isSpaceChar(l.get(line).charAt(point - 1)))) break;
        sb.append(l.get(line).charAt(point - 1));
        setLineWithoutAnalyze(line, l.get(line).substring(0, point - 1) + l.get(line).substring(Math.min(point, l.get(line).length()), l.get(line).length()));
        point--;
      }
      if (analyzer != null) {
        analyzer.add(line, before, l.get(line));
      }
      ret=sb.reverse().toString();
    } else {
      String before=l.get(line);
      ret="" + l.get(line).charAt(point - 1);
      setLineWithoutAnalyze(line, l.get(line).substring(0, point - 1) + l.get(line).substring(point, l.get(line).length()));
      cursorLeft(false, false);
      maxpoint=point;
      if (analyzer != null) {
        analyzer.add(line, before, l.get(line));
      }
    }
    maxpoint=point;
    if (analyzer != null) {
      analyzer.read();
    }
    return ret;
  }
  @Override
  public String deleteAfter(boolean word) {
    String ret;
    if (empty()) return "";
    if (point == l.get(line).length()) {
      if (line == lines() - 1) return "";
      setLine_(line, l.get(line) + l.get(line + 1));
      deleteLine_(line + 1);
      ret="\n";
    } else if (word) {
      boolean isSpace=false;
      String before=l.get(line);
      StringBuilder sb=new StringBuilder();
      if (isSpaceChar(l.get(line).charAt(point))) isSpace=true;
      while (l.get(line).length() > 0 && point < l.get(line).length()) {
        if (((isSpace && isSpaceChar(l.get(line).charAt(point)) == false)) || (!isSpace && isSpaceChar(l.get(line).charAt(point)))) break;
        sb.append(l.get(line).charAt(point));
        setLineWithoutAnalyze(line, l.get(line).substring(0, point) + l.get(line).substring(Math.min(point + 1, l.get(line).length()), l.get(line).length()));
      }
      if (analyzer != null) {
        analyzer.add(line, before, l.get(line));
      }
      ret=sb.toString();
    } else {
      String before=l.get(line);
      ret="" + l.get(line).charAt(point);
      setLineWithoutAnalyze(line, l.get(line).substring(0, point) + l.get(line).substring(Math.min(point + 1, l.get(line).length()), l.get(line).length()));
      if (analyzer != null) {
        analyzer.add(line, before, l.get(line));
      }
    }
    maxpoint=point;
    if (analyzer != null) {
      analyzer.read();
    }
    return ret;
  }
  //
  //===Cursor movements===// - script specific
  @Override
  public void cursorUp(boolean word, boolean select) {
    if (word) {
      if (analyzer != null) {
        analyzer.cursorUpWord(this, select);
      }
    } else {
      if (line == 0) {
        point=0;
      } else {
        line=line - 1;
        point=Math.min(maxpoint, l.get(line).length());
        if (select == false) resetSelection();
      }
    }
  }
  @Override
  public void cursorDown(boolean word, boolean select) {
    if (word) {
      if (analyzer != null) {
        analyzer.cursorDownWord(this, select);
      }
    } else {
      if (line >= lines() - 1) {
        point=l.get(lines() - 1).length();
      } else {
        line=line + 1;
        point=Math.min(maxpoint, l.get(line).length());
        if (select == false) resetSelection();
      }
    }
  }
  static public String[] split(String value, String delim) {//processing split
    List<String> items=new ArrayList<>();
    int index;
    int offset=0;
    while ((index=value.indexOf(delim, offset)) != -1) {
      items.add(value.substring(offset, index));
      offset=index + delim.length();
    }
    items.add(value.substring(offset));
    String[] outgoing=new String[items.size()];
    items.toArray(outgoing);
    return outgoing;
  }
}