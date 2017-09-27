class ModString {
  private ArrayList<String> l;//if modified, the Analyzer come and read the string.
  public int cursor=0;
  public int line=0;
  public int selStartLine;
  public int selStartPoint;
  public int selEndLine;
  public int selEndPoint;
  public int maxcursor;
  //
  String startText="// === PW 2.0 === //";
  public ModString() {
    l=new ArrayList<String>();
  }
  void clear() {
    reset();
    line=0;
    cursor=startText.length();
    addLine(0, "");
    setLine(0, startText);
    RecordLog();
    //force!
    title_edited="";
  }
  void reset() {
    int a=l.size()-1;
    while (a>=0) {
      analyzer.addWithoutReading(a, l.get(a), null);
      a=a-1;
    }
    l.clear();
    currentLedFrame=0;
    currentLedTime=0;
    analyzer.clear();
    line=0;
    cursor=0;
  }
  @Override
    synchronized String toString() {
    if (l.size()==0)return "";
    StringBuilder builder = new StringBuilder();
    builder.append(l.get(0));
    int a=1;
    while (a<l.size()) {
      builder.append("\n").append(l.get(a));
      a=a+1;
    }
    return builder.toString();
  }
  synchronized String toString(ArrayList lines) {
    if (lines.size()==0)return "";
    StringBuilder builder = new StringBuilder();
    builder.append(lines.get(0));
    int a=1;
    while (a<lines.size()) {
      builder.append("\n").append(lines.get(a));
      a=a+1;
    }
    return builder.toString();
  }
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
  boolean empty() {
    if (l.size()==0)return true;
    if (l.size()==1&&l.get(0).equals(""))return true;
    return false;
  }
  boolean lineEmpty(int line_) {
    if (l.get(line_).equals(""))return true;
    return false;
  }
  void addLine(int line_, String text) {
    if (text==null)return;
    l.add(line_, text);
    analyzer.add(line_, null, text);
    patternMatcher.findUpdated=false;
  }
  void addLineWithoutReading(int line_, String text) {//used to readFrame()
    if (text==null)return;
    l.add(line_, text);
    analyzer.addWithoutReading(line, null, text);
    patternMatcher.findUpdated=false;
  }
  void deleteLineWithoutReading(int line_) {
    l.remove(line_);
    patternMatcher.findUpdated=false;
  }
  void readAll() {
    analyzer.readAll(l);
  }
  void setLine(int line_, String text) {
    String before=l.get(line_);
    l.set(line_, text);
    analyzer.add(line_, before, text);
    patternMatcher.findUpdated=false;
  }
  void deleteLine(int line_) {
    String before=l.get(line_);
    l.remove(line_);
    line=min(line, l.size()-1);
    analyzer.add(line_, before, null);
    patternMatcher.findUpdated=false;
  }
  void addLineWithoutRecord(int line_, String text) {
    if (text==null)return;
    l.add(line_, text);
    analyzer.addWithoutRecord(line_, null, text);
    patternMatcher.findUpdated=false;
  }
  void setLineWithoutRecord(int line_, String text) {
    String before=l.get(line_);//#return
    l.set(line_, text);
    analyzer.addWithoutRecord(line_, before, text);
    patternMatcher.findUpdated=false;
  }
  void deleteLineWithoutRecord(int line_) {
    String before=l.get(line_);
    l.remove(line_);
    line=min(line, l.size()-1);
    analyzer.addWithoutRecord(line_, before, null);
    patternMatcher.findUpdated=false;
  }
  String getLine(int line_) {
    try {//FIX
      return l.get(line_);
    }
    catch(Exception e) {
      e.printStackTrace();
    }
    return "";
  }
  int lines() {
    return l.size();
  }
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
  void deleteSelection() {
    maxcursor=cursor;
    if (hasSelection()==false)return;
    delete(selStartLine, selStartPoint, selEndLine, selEndPoint);
    cursor=selStartPoint;
    line=selStartLine;
    resetSelection();
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
  boolean hasSelection() {
    if (selStartLine==selEndLine&&selStartPoint==selEndPoint)return false;
    return true;
  }
  void resetSelection() {
    selEndLine=selStartLine;
    selEndPoint=selStartPoint;
  }
  void selectAll() {
    selStartLine=0;
    selStartPoint=0;
    selEndLine=l.size()-1;
    selEndPoint=l.get(l.size()-1).length();
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
    if (line_==selEndLine)return l.get(selEndLine).substring(0, selEndPoint);
    return "";
  }
  void fixSelection() {
    if (selStartLine>selEndLine||(selStartLine==selEndLine&&selStartPoint>selEndPoint)) {
      int temp=selEndLine;
      selEndLine=selStartLine;
      selStartLine=temp;
      temp=selEndPoint;
      selEndPoint=selStartPoint;
      selStartPoint=temp;
    }
  }
  //
  void selectionLeft(boolean word) {
    if (hasSelection()==false) {
      selStartPoint=cursor;
      selStartLine=line;
      resetSelection();
    }
    cursorLeft(word, true);
    if (line>selStartLine||(selStartPoint<cursor&&selStartLine==line)) {
      selEndPoint=cursor;
      selEndLine=line;
    } else {
      selStartPoint=cursor;
      selStartLine=line;
    }
  }
  void selectionRight(boolean word) {
    if (hasSelection()==false) {
      selStartPoint=cursor;
      selStartLine=line;
      resetSelection();
    }
    cursorRight(word, true);
    if (line>selEndLine||(selEndPoint<=cursor&&selEndLine==line)) {
      selEndPoint=cursor;
      selEndLine=line;
    } else {
      selStartPoint=cursor;
      selStartLine=line;
    }
  }
  void selectionUp() {
    if (hasSelection()==false) {
      selStartPoint=cursor;
      selStartLine=line;
      resetSelection();
    }
    boolean start=false;
    if (selStartLine==line&&selStartPoint==cursor)start=true; 
    cursorUp(true);
    if (start) {
      selStartPoint=cursor;
      selStartLine=line;
    } else {
      selEndPoint=cursor;
      selEndLine=line;
    }
    fixSelection();
  }
  void selectionDown() {
    if (hasSelection()==false) {
      selStartPoint=cursor;
      selStartLine=line;
      resetSelection();
    }
    boolean start=true;
    if (selEndLine==line&&selEndPoint==cursor)start=false; 
    cursorDown(true);
    if (start) {
      selStartPoint=cursor;
      selStartLine=line;
    } else {
      selEndPoint=cursor;
      selEndLine=line;
    }
    fixSelection();
  }
  void cursorLeft(boolean word, boolean select) {
    if (word&&cursor!=0) {
      if (l.get(line).length()>0&&cursor>0) {
        boolean isSpace=false;
        if (l.get(line).charAt(cursor-1)==' '||l.get(line).charAt(cursor-1)=='\t'||l.get(line).charAt(cursor-1)=='\n'||l.get(line).charAt(cursor-1)=='\r')isSpace=true;
        while (l.get(line).length()>0&&cursor>0) {
          if (((isSpace&&(l.get(line).charAt(cursor-1)==' '||l.get(line).charAt(cursor-1)=='\t'||l.get(line).charAt(cursor-1)=='\n'||l.get(line).charAt(cursor-1)=='\r')==false))||(isSpace==false&&(l.get(line).charAt(cursor-1)==' '||l.get(line).charAt(cursor-1)=='\t'||l.get(line).charAt(cursor-1)=='\n'||l.get(line).charAt(cursor-1)=='\r')))break;
          cursor=cursor-1;
        }
      }
      if (select==false)Lines.resetSelection();
    } else {
      if (cursor==0) {
        if (line!=0) {
          line--;
          cursor=l.get(line).length();
          if (select==false)Lines.resetSelection();
        }
      } else {
        cursor=cursor-1;
        if (select==false)Lines.resetSelection();
      }
    }
    maxcursor=cursor;
  }
  void cursorRight(boolean word, boolean select) {
    if (word&&cursor!=l.get(line).length()) {
      if (l.get(line).length()>0&&cursor<l.get(line).length()) {
        boolean isSpace=false;
        if (l.get(line).charAt(cursor)==' '||l.get(line).charAt(cursor)=='\t'||l.get(line).charAt(cursor)=='\n'||l.get(line).charAt(cursor)=='\r')isSpace=true;
        while (l.get(line).length()>0&&cursor<l.get(line).length()) {
          if (((isSpace&&(l.get(line).charAt(cursor)==' '||l.get(line).charAt(cursor)=='\t'||l.get(line).charAt(cursor)=='\n'||l.get(line).charAt(cursor)=='\r')==false))||(isSpace==false&&(l.get(line).charAt(cursor)==' '||l.get(line).charAt(cursor)=='\t'||l.get(line).charAt(cursor)=='\n'||l.get(line).charAt(cursor)=='\r')))break;
          cursor=cursor+1;
        }
      }
      if (select==false)Lines.resetSelection();
    } else {
      if (cursor==l.get(line).length()) {
        if (line<l.size()-1) {
          line++;
          cursor=0;
          if (select==false)Lines.resetSelection();
        }
      } else {
        cursor=cursor+1;
        if (select==false)Lines.resetSelection();
      }
    }
    maxcursor=cursor;
  }
  void cursorUp(boolean select) {
    if (line==0) {
      cursor=0;
      return;
    }
    line=line-1;
    cursor=min(maxcursor, l.get(line).length());
    if (select==false)Lines.resetSelection();
  }
  void cursorDown(boolean select) {
    if (line>=l.size()-1) {
      cursor=l.get(l.size()-1).length();
      return;
    }
    line=line+1;
    cursor=min(maxcursor, l.get(line).length());
    if (select==false)Lines.resetSelection();
  }
  void setCursorByIndex(int index) {//slow!
    int sum=0;//assert l.size()>0
    int a=0;
    int psum=0;
    while (a<l.size()) {
      sum=sum+l.get(a).length();
      if (index<sum) {
        cursor=min(l.get(a).length(), index-psum);
        line=a;
        return;
      }
      sum=sum+1;
      psum=sum;
      a=a+1;
    }
    line=l.size()-1;
    cursor=l.get(line).length();
  }
  int getLineByIndex(int index) {//slow!
    int sum=l.get(0).length();//assert l.size()>0
    if (index<=sum)return 0;
    int a=1;
    while (a<l.size()) {
      sum=sum+1+l.get(a).length();
      if (index<=sum)return a;
      a=a+1;
    }
    return l.size()-1;
  }
  void selectFromCursor(int len) {
    resetSelection();
    int a=0;
    while (a<len) {
      selectionRight(false);
      a=a+1;
    }
  }
}