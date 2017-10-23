//read all when change mode!!!
  synchronized String toUnipadString() {
    if (l.size()==0)return "";
    ArrayList<String> al=analyzer.toUnipadLed(l);
    StringBuilder builder = new StringBuilder();
    builder.append(al.get(0));
    int a=1;
    while (a<al.size()) {
      builder.append("\n").append(al.get(a));
      a=a+1;
    }
    return builder.toString();
  }
  String startText="// === PW 2.0 === //";
  void addOnEditThings(){//!!!!
    patternMatcher.findUpdated=false;
  }
  class ModString {
  void insert(String text) {
    if (text.equals(""))return;
    String[] lines=split(text, "\n");
    boolean reread=false;
    if (lines.length>READ_THRESHOLD)reread=true;
    String endText;
    analyzer.total=lines.length;
    if (cursor>l.get(line).length())cursor=l.get(line).length();
    if (cursor==l.get(line).length())endText="";
    else endText=l.get(line).substring(cursor, l.get(line).length());
    setLine(line, l.get(line).substring(0, cursor)+lines[0]);
    int a=1;
    if (reread)analyzer.clear();
    while (a<lines.length) {
      analyzer.index=a;
      line++;
      if (reread)addLineWithoutReading(line, lines[a]);
      else addLine(line, lines[a]);
      a=a+1;
    }
    if (reread) {
      analyzer.readAll(l);//thread error?
      updateFrameSlider();
    }
    cursor=l.get(line).length();
    maxcursor=cursor;
    if (endText.equals("")==false)setLine(line, l.get(line)+endText);
    analyzer.total=0;
    analyzer.index=0;
    patternMatcher.findUpdated=false;
  }
  void insert(int cursor_, int line_, String text) {
    if (text.equals(""))return;
    String[] lines=split(text, "\n");
    boolean reread=false;
    if (lines.length>READ_THRESHOLD)reread=true;
    String endText;
    analyzer.total=lines.length;
    if (cursor_==l.get(line_).length())endText="";
    else endText=l.get(line_).substring(cursor_, l.get(line_).length());
    setLine(line_, l.get(line_).substring(0, cursor_)+lines[0]);
    int a=1;
    if (reread)analyzer.clear();
    while (a<lines.length) {
      analyzer.index=a;
      line_++;
      if (reread)addLineWithoutReading(line_, lines[a]);
      else addLine(line_, lines[a]);
      a=a+1;
    }
    if (reread) {
      analyzer.readAll(l);
      updateFrameSlider();
    }
    if (endText.equals("")==false)setLine(line_, l.get(line_)+endText);
    analyzer.total=0;
    analyzer.index=0;
    patternMatcher.findUpdated=false;
  }
  void delete(int sl, int sp, int el, int ep) {
    if (( sl<el||(sl==el&&sp<ep))==false)return;
    analyzer.total=el-sl;
    boolean reread=false;
    if (analyzer.total>READ_THRESHOLD)reread=true;
    String endText=l.get(el).substring(ep, l.get(el).length());
    setLine(sl, l.get(sl).substring(0, sp));
    int a=sl+1;
    if (reread)analyzer.clear();
    while (a<=el) {
      analyzer.index=a;
      if (reread)deleteLineWithoutReading(sl+1);
      else deleteLine(sl+1);
      a=a+1;
    }
    if (reread==false)setLine(sl, l.get(sl)+endText);
    if (reread) {
      analyzer.readAll(l);
      updateFrameSlider();
    }
    maxcursor=cursor;
    analyzer.total=0;
    analyzer.index=0;
    patternMatcher.findUpdated=false;
  }
  void deleteBefore(boolean word) {//if word, ctrl.
    maxcursor=cursor;
    if ((cursor==0&&line==0)||empty())return;
    if (cursor==0) {
      if (line==0)return;
      cursorLeft(false, false);
      setLine(line, l.get(line)+l.get(line+1));
      deleteLine(line+1);
    } else if (word) {
      boolean isSpace=false;
      String before=l.get(line);
      if (l.get(line).charAt(cursor-1)==' '||l.get(line).charAt(cursor-1)=='\t'||l.get(line).charAt(cursor-1)=='\n'||l.get(line).charAt(cursor-1)=='\r')isSpace=true;
      while (l.get(line).length()>0&&cursor>0) {
        if (((isSpace&&(l.get(line).charAt(cursor-1)==' '||l.get(line).charAt(cursor-1)=='\t'||l.get(line).charAt(cursor-1)=='\n'||l.get(line).charAt(cursor-1)=='\r')==false))||(isSpace==false&&(l.get(line).charAt(cursor-1)==' '||l.get(line).charAt(cursor-1)=='\t'||l.get(line).charAt(cursor-1)=='\n'||l.get(line).charAt(cursor-1)=='\r')))break;
        l.set(line, l.get(line).substring(0, cursor-1)+l.get(line).substring(min(cursor, l.get(line).length()), l.get(line).length()));
        cursor--;
      }
      analyzer.add(line, before, l.get(line));
    } else {
      String before=l.get(line);
      l.set(line, l.get(line).substring(0, cursor-1)+l.get(line).substring(min(cursor, l.get(line).length()), l.get(line).length()));
      cursorLeft(false, false);
      maxcursor=cursor;
      analyzer.add(line, before, l.get(line));
    }
    maxcursor=cursor;
  }
  void deleteAfter(boolean word) {
    maxcursor=cursor;
    if (empty())return;
    if (cursor==l.get(line).length()) {
      if (line==l.size()-1)return;
      setLine(line, l.get(line)+l.get(line+1));
      deleteLine(line+1);
    } else if (word) {
      boolean isSpace=false;
      String before=l.get(line);
      if (l.get(line).charAt(cursor)==' '||l.get(line).charAt(cursor)=='\t'||l.get(line).charAt(cursor)=='\n'||l.get(line).charAt(cursor)=='\r')isSpace=true;
      while (l.get(line).length()>0&&cursor<l.get(line).length()) {
        if (((isSpace&&(l.get(line).charAt(cursor)==' '||l.get(line).charAt(cursor)=='\t'||l.get(line).charAt(cursor)=='\n'||l.get(line).charAt(cursor)=='\r')==false))||(isSpace==false&&(l.get(line).charAt(cursor)==' '||l.get(line).charAt(cursor)=='\t'||l.get(line).charAt(cursor)=='\n'||l.get(line).charAt(cursor)=='\r')))break;
        l.set(line, l.get(line).substring(0, cursor)+l.get(line).substring(min(cursor+1, l.get(line).length()), l.get(line).length()));
      }
      analyzer.add(line, before, l.get(line));
    } else {
      String before=l.get(line);
      l.set(line, l.get(line).substring(0, cursor)+l.get(line).substring(min(cursor+1, l.get(line).length()), l.get(line).length()));
      analyzer.add(line, before, l.get(line));
    }
    maxcursor=cursor;
  }
  String getSelection() {//error
    if (selStartLine==selEndLine)return l.get(selStartLine).substring(selStartPoint, selEndPoint);
    StringBuilder ret=new StringBuilder();
    ret.append(l.get(selStartLine).substring(selStartPoint, l.get(selStartLine).length()));
    int a=selStartLine+1;
    while (a<selEndLine) {
      ret=ret.append("\n").append(l.get(a));
      a=a+1;
    }
    ret=ret.append("\n").append(l.get(selEndLine).substring(0, selEndPoint));
    return ret.toString();
  }
  String getSelectionBeforePart(int line_) {
    if (line_==selStartLine) {
      return l.get(selStartLine).substring(0, selStartPoint);
    }
    return "";
  }
  String getSelection(int line_) {
    if (line_==selStartLine)return l.get(selStartLine).substring(selStartPoint, l.get(selStartLine).length())+"\n";
    if (line_>selStartLine&&line_<selEndLine) {
      return l.get(line_)+"\n";
    }
    if (selEndLine>=l.size())selEndLine=l.size()-1;
    if (selEndPoint>l.get(selEndLine).length())selEndPoint=l.get(selEndLine).length();
    if (line_==selEndLine)return l.get(selEndLine).substring(0, selEndPoint);
    return "";
  }
  //
}