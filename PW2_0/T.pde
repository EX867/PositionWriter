static final int SLIDER_HALFWIDTH=10;
class LedTextEditor extends UIelement {
  ArrayList<String> files=new ArrayList<String>();
  HashMap<String, LedScript> opened=new HashMap<String, LedScript>();
  LedScript current;
  int textSize=1;
  //draw vars
  float sliderPos=0;
  float sliderLength;
  boolean sliderClicked=false;
  boolean editorClicked=false;
  //temp vars
  int pkey='\0';
  int clickline=0;
  int clickcursor=0;
  //generalize this!!!(hard coded data)
  float originalY;
  float originalSY;
  float shortenY;
  float shortenSY;
  public TextEditor( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    updateSlider(position.y-size.y);
    openNewFile();
  }
  void updateSlider(int pos) {//MouseY
    sliderLength=size.y*size.y/max(size.y, max(Lines.lines()+10, size.y*2/textSize)*textSize/2);//half
    sliderPos=position.y+min(max(pos-position.y, -size.y+sliderLength), size.y-sliderLength);
  }
  void loadText(String filename, String text) {
  }
  void openNewFile() {
    loadText(ext_createFileName(), pw_startText);
  }
  //cursor controls
  void cursorLeft(boolean ctrl, boolean shift) {
    if (shiftPressed) current.selectionLeft(ctrl);
    else current.cursorLeft(ctrl, false);
  }
  void cursorRight(boolean ctrl, boolean shift) {
    if (shiftPressed) current.selectionRight(ctrl);
    else current.cursorRight(ctrl, false);
  }
  void cursorUp(boolean shift) {
    if (shift)current.selectionUp();
    else current.cursorUp(false);
  }
  void cursorUp(boolean ctrl, boolean shift) {
    if (ctrl) {
      int line=max(0, DelayPoint.get(current.getFrame(current.line)));
      while (Lines.line>line) {
        Lines.selectionUp();
      }
    } else cursorUp(shift);
  }
  void cursorDown(boolean shift) {
    if (shift)current.selectionDown();
    else current.cursorDown(false);
  }
  void cursorDown(boolean ctrl, boolean shift) {
    if (ctrl) {
      int index=current.processer.getFrame(Lines.line)+1;
      int line=current.lines();
      if (current.getCommands().get(current.line) instanceof DelayCommand)line=DelayPoint.get(min(DelayPoint.size()-1, index+1));
      else if (index<DelayPoint.size())line=DelayPoint.get(index);
      while (Lines.line<line) {
        cursorDown(shift);
      }
    } else cursorDown(shift);
  }
  void mouseWheel(MouseEvent e) {
    sliderPos=position.y+min(max(-size.y+sliderLength, sliderPos-position.y+e.getCount()*2000/max(Lines.lines()+8, size.y*2/textSize)), size.y-sliderLength);//HARDCODED!!!
  }
}

class TextEditor extends UIelement {//only render and add text. this class not do data management.
  int errorpsize=0;
  @Override
    boolean react() {
    boolean isFocused=false;
    if (focus==ID) {
      isFocused=true;
    }
    super.react();
    if (focus!=ID)sliderClicked=false;
    if ((isMousePressed(position.x+size.x-SLIDER_HALFWIDTH, position.y, SLIDER_HALFWIDTH, size.y)||(sliderClicked&&mousePressed))&&pressed) {
      resizeSlider();
      focus=ID;
      editorClicked=false;
      sliderClicked=true;
    } else if (isMousePressed(position.x-SLIDER_HALFWIDTH, position.y, size.x-SLIDER_HALFWIDTH, size.y)) {
      if (editorClicked) {
        adjustCursor();
        Lines.selStartLine=min(Lines.line, clickline);
        Lines.selEndLine=max(Lines.line, clickline);
        if (Lines.line==clickline) {
          Lines.selStartPoint=min(Lines.cursor, clickcursor);
          Lines.selEndPoint=max(Lines.cursor, clickcursor);
        } else if (Lines.selStartLine==Lines.line) {
          Lines.selStartPoint=Lines.cursor;
          Lines.selEndPoint=clickcursor;
        } else {
          Lines.selStartPoint=clickcursor;
          Lines.selEndPoint=Lines.cursor;
        }
      }
      sliderClicked=false;//no needing
    } else {
      editorClicked=false;
      sliderClicked=false;
    }
    if (isMouseOn(position.x-SLIDER_HALFWIDTH, position.y, size.x-SLIDER_HALFWIDTH, size.y)) {
      if (mouseState==AN_PRESS) {
        if (shiftPressed) {
          if (Lines.line==Lines.selStartLine&&Lines.cursor==Lines.selStartPoint) {//reverse
            clickline=Lines.selEndLine;
            clickcursor=Lines.selEndPoint;
            adjustCursor();
            Lines.selStartLine=Lines.line;
            Lines.selStartPoint=Lines.cursor;
          } else {
            clickline=Lines.selStartLine;
            clickcursor=Lines.selStartPoint;
            adjustCursor();
            Lines.selEndLine=Lines.line;
            Lines.selEndPoint=Lines.cursor;
          }
        } else {
          adjustCursor();
          Lines.selStartLine=Lines.line;
          Lines.selStartPoint=Lines.cursor;
          Lines.resetSelection();
          clickline=Lines.line;
          clickcursor=Lines.cursor;
        }
        editorClicked=true;
      }
    }
    if (ID==focus||(isFocused&&ID!=focus)) {
      render();//extra render
    }
    return false;
  }
  void insert(int cursor_, int line_, String text) {
    Lines.insert(cursor_, line_, text);
    moveTo(line_);
    sliderLength=size.y*size.y/max(size.y, max(Lines.lines()+10, size.y*2/textSize)*textSize/2);//half
  }
  void addLine(int line_, String text) {
    Lines.addLine(line_, text);
    moveTo(line_);
    sliderLength=size.y*size.y/max(size.y, max(Lines.lines()+10, size.y*2/textSize)*textSize/2);//half
  }
  void adjustCursor() {
    float Yoffset=-(sliderPos-(position.y-size.y+sliderLength))*(max(1, (Lines.lines()+10)*textSize-size.y*2)/max(1, size.y*2-sliderLength*2));
    Lines.line=floor(max(0, min(Lines.lines()-1, ((-Yoffset+MouseY-position.y+size.y)/textSize)-1)));
    Lines.cursor=Lines.getLine(Lines.line).length();
    if (Lines.getLine(Lines.line).length()>500) {//WARNING!!! this is for removing lag in "no happening" state. it is hardcoded, and this can occur some error when complexity become higher.
      Lines.cursor=500;
    }
    textFont(fontRegular);
    textSize(max(1, textSize));
    while (Lines.cursor>0&&position.x-size.x+textSize*3+textWidth(Lines.getLine(Lines.line).substring(0, Lines.cursor))>=MouseX) {
      Lines.cursor--;
    }
    textFont(fontBold);
  }
  @Override
    void render() {
    if (skip)return;
    fill(UIcolors[I_TEXTBACKGROUND]);
    rect(position.x, position.y, size.x, size.y);
    fill(UIcolors[I_FOREGROUND]);
    textSize=((TextBox)UI[getUIid("I_TEXTSIZE")]).value;
    rect(position.x-size.x+textSize*3/2-3, position.y, textSize*3/2-3, size.y);
    textAlign(LEFT, CENTER);
    textFont(fontRegular);
    textSize(max(1, textSize));
    textLeading(textSize/2);
    boolean errorpassed=false;
    float Yoffset=textSize/2-(sliderPos-(position.y-size.y+sliderLength))*(max(1, (Lines.lines()+10)*textSize-size.y*2)/max(1, size.y*2-sliderLength*2));
    int a=floor(max(0, min(Lines.lines()-1, (-Yoffset)/textSize)));//Yoffset+a*textSize>-textSize
    while (Yoffset+a*textSize<size.y*2-textSize*3/2&&a<Lines.lines()) {
      if (Lines.hasSelection()) {
        fill(UIcolors[I_TEXTBOXSELECTION]);//MODIFY!
        String selectionPart=Lines.getSelection(a);
        if (selectionPart.equals("")==false) {
          if (selectionPart.charAt(selectionPart.length()-1)=='\n') {
            selectionPart=selectionPart.substring(0, selectionPart.length()-1);
            rect(position.x+textWidth(Lines.getSelectionBeforePart(a))/2+textSize+5, position.y-size.y+(a+1)*textSize+Yoffset+5, size.x-textWidth(Lines.getSelectionBeforePart(a))/2-textSize*2, textSize/2);
          } else rect(position.x-size.x+textSize*3+textWidth(selectionPart)/2+textWidth(Lines.getSelectionBeforePart(a))+5, position.y-size.y+(a+1)*textSize+3+Yoffset, textWidth(selectionPart)/2, textSize/2);
        }
      }
      fill(UIcolors[I_GENERALTEXT]);
      int commentPoint=Lines.getLine(a).length();
      int b=1;
      while (b<Lines.getLine(a).length()) {
        if (Lines.getLine(a).charAt(b-1)=='/'&&Lines.getLine(a).charAt(b)=='/') {
          commentPoint=b-1;
          break;
        }
        b=b+1;
      }
      String[] tokens=split(Lines.getLine(a).substring(0, commentPoint), " ");
      b=0;
      String count="";
      while (b<tokens.length) {
        if (Mode!=CYXMODE&&(tokens[b].equals("on")||tokens[b].equals("o")||tokens[b].equals("off")||tokens[b].equals("f")||tokens[b].equals("delay")||tokens[b].equals("d")||tokens[b].equals("auto")||tokens[b].equals("a")||tokens[b].equals("bpm")||tokens[b].equals("b"))) {
          fill(UIcolors[I_KEYWORDTEXT]);
        } else if (Mode!=CYXMODE&&ignoreMc&&(tokens[b].equals("chain")||tokens[b].equals("c")||tokens[b].equals("mapping")||tokens[b].equals("m"))) {
          fill(UIcolors[I_UNITORTEXT]);
        } else if (Mode!=CYXMODE &&ignoreMc&&(tokens[b].equals("mc")||tokens[b].equals("s")||tokens[b].equals("l")||tokens[b].equals("rnd"))) {
          fill(UIcolors[I_UNITORTEXT2]);
        } else if (Mode==CYXMODE&&((ignoreMc&&tokens[b].equals("mc"))||tokens[b].equals("on")||tokens[b].equals("o")||tokens[b].equals("off")||tokens[b].equals("f")||tokens[b].equals("delay")||tokens[b].equals("d")||tokens[b].equals("chain")||tokens[b].equals("c"))) {
          fill(UIcolors[I_KEYWORDTEXT]);
        } else {
          fill(UIcolors[I_GENERALTEXT]);
        }
        if (count.length()+tokens[b].length()>500) {//WARNING!!! this is for removing lag in "no happening" state. it is hardcoded, and this can occur some error when complexity become higher.
          text(tokens[b].substring(0, min(1000, tokens[b].length())), position.x-size.x+textSize*3+textWidth(count)+5, position.y-size.y+(a+1)*textSize+Yoffset);
          a=987654321;
          break;
        }
        text(tokens[b], position.x-size.x+textSize*3+textWidth(count)+5, position.y-size.y+(a+1)*textSize+Yoffset);
        count=count+tokens[b]+" ";
        b=b+1;
      }
      if (a<987654321/*WARNING!!!*/&&commentPoint!=Lines.getLine(a).length()) {
        fill(UIcolors[I_COMMENTTEXT]);
        if (commentPoint<0)return;//warning!!!
        String showText=Lines.getLine(a).substring(commentPoint, Lines.getLine(a).length());
        text(showText, position.x-size.x+textSize*3+textWidth(Lines.getLine(a).substring(0, commentPoint))+5, position.y-size.y+(a+1)*textSize+Yoffset);
      }
      int err=getFirstErrorInLine(a);
      if (err<error.size()&&error.get(err).line==a) {//need check...
        errorpassed=true;
        if (error.get(err).type==Error.WARNING) {
          stroke(UIcolors[I_TABC3]);
        } else {
          stroke(UIcolors[I_TABC2]);
        }
        strokeWeight(2);
        line(position.x-size.x+textSize*3.2F, position.y-size.y+(a+1.5F)*textSize+Yoffset, position.x-size.x+textSize*3.2F+textWidth(Lines.getLine(a)), position.y-size.y+(a+1.5F)*textSize+Yoffset);
        noStroke();
        if (Lines.line==a) {
          setStatusR(error.get(err).toString());
          errorpsize=error.size();
          displayingError=err;
        }
      }
      a=a+1;
    }
    if (errorpassed==false&&error.size()>0) {
      setStatusR(error.get(0).toString());
      errorpsize=error.size();
      displayingError=0;
    } else if (error.size()==0) {
      if (errorpsize!=0)setStatusR("");
      errorpsize=0;
      displayingError=-1;
    }
    fill(UIcolors[I_GENERALTEXT]);
    if (ID==focus)if (frameCount%54<36)if (Yoffset+Lines.line*textSize>-textSize&&Yoffset+Lines.line*textSize<size.y*2-textSize*3/2)text("|", position.x-size.x+textSize*3+textWidth(Lines.getLine(Lines.line).substring(0, min(Lines.getLine(Lines.line).length(), Lines.cursor)))+2, position.y-size.y+(Lines.line+1)*textSize+Yoffset);
    textAlign(RIGHT, CENTER);
    textFont(fontBold);
    textSize(max(1, textSize));
    textLeading(textSize/2);
    a=floor(max(0, (-Yoffset)/textSize));//Yoffset+a*textSize>-textSize
    int loopstart=getFrameByTime((int)frameSliderLoop.valueS);
    int loopend=getFrameByTime((int)frameSliderLoop.valueE);
    int linecnt=Lines.lines();
    while (Yoffset+a*textSize<size.y*2-textSize*3/2) {//a<Lines.lines()+30) {
      if (a<linecnt) {
        float tempY=position.y-size.y+(a+1)*textSize+Yoffset;
        tempY=tempY-min(textSize/4, (tempY-position.y+size.y)/2)+textSize/4;
        tempY=tempY+min(textSize/4, (position.y+size.y-tempY)/2)-textSize/4;
        float tempSY= min(min(textSize/2, (tempY-position.y+size.y)), (position.y+size.y-tempY));
        if (frameSliderLoop.bypass==false) {
          if (DelayPoint.get(loopstart)<a&&((loopstart<DelayPoint.size()-1&&a<=DelayPoint.get(loopstart+1))||loopstart>=DelayPoint.size()-1)) {
            fill(255, 0, 0, 40);
            rect(position.x-size.x+textSize*3/2-3, tempY, textSize*3/2-3, tempSY);
          } else if (DelayPoint.get(loopend)<a&&((loopend<DelayPoint.size()-1&&a<=DelayPoint.get(loopend+1))||loopend>=DelayPoint.size()-1)) {
            fill(0, 0, 255, 40);
            rect(position.x-size.x+textSize*3/2-3, tempY, textSize*3/2-3, tempSY);
          }
        }
        if (currentLedFrame<DelayPoint.size()) {
          if ((DelayPoint.get(currentLedFrame)<a&&((currentLedFrame<DelayPoint.size()-1&&a<=DelayPoint.get(currentLedFrame+1)))||(currentLedFrame==DelayPoint.size()-1&&a>DelayPoint.get(currentLedFrame)))) {
            fill(0, 40);
            rect(position.x-size.x+textSize*3/2-3, tempY, textSize*3/2-3, tempSY);
          }
        }
        fill(brighter(UIcolors[I_BACKGROUND], -10));
      } else fill(brighter(UIcolors[I_BACKGROUND], 100));
      text(str(a), position.x-size.x+textSize*5/2, position.y-size.y+(a+1)*textSize+Yoffset);
      a=a+1;
    }
    textAlign(CENTER, CENTER);
    //draw rect
    color fillcolor=UIcolors[I_TEXTBACKGROUND];
    if (isMouseOn (position.x, position.y, size.x, size.y)&&mousePressed) {
      fillcolor=(brighter(UIcolors[I_TEXTBACKGROUND], -20));
      stroke(brighter(UIcolors [I_FOREGROUND], -40));
    } else {
      if (ID==focus) {
        fillcolor=(brighter(UIcolors[I_TEXTBACKGROUND], -20));
        stroke(brighter(UIcolors [I_FOREGROUND], -20));
      } else {
        stroke(UIcolors[I_FOREGROUND]);
      }
    }
    noFill();
    strokeWeight(3);
    rect(position.x, position.y, size.x, size.y);//second
    fill(fillcolor);
    rect(position.x+size.x-SLIDER_HALFWIDTH, position.y, SLIDER_HALFWIDTH, size.y);//slider holder
    fill(UIcolors[I_TEXTBACKGROUND]);
    rect(position.x+size.x-SLIDER_HALFWIDTH, sliderPos, SLIDER_HALFWIDTH-2, max(sliderLength-2, 2));
    line(position.x+size.x-SLIDER_HALFWIDTH*2, sliderPos, position.x+size.x, sliderPos);
    strokeWeight(2);
    float offset=position.y-size.y+sliderLength;
    float total=size.y*2-sliderLength*2;//just passing... //#cache!!!
    if (frameSliderLoop.bypass==false) {
      markLine(color(255, 0, 0), max(0, DelayPoint.get(loopstart)), offset, total);
      markLine(color(0, 0, 255), max(0, DelayPoint.get(loopend)), offset, total);
    }
    markLine(color(0), max(0, DelayPoint.get(currentLedFrame)), offset, total);
    a=0;
    while (a<error.size()) {
      markLine(UIcolors[I_TABC2], error.get(a).line, offset, total);
      a=a+1;
    }
    UI[getUIid("I_OPENFIND")].render();
  }
  void markLine(color c, int line, float offset, float total) {
    stroke(c);
    float val=offset+total*line/(Lines.lines()-floor(size.y*2/textSize)+8);
    if (val<position.y+size.y)line(position.x+size.x-SLIDER_HALFWIDTH*2, val, position.x+size.x, val);
  }
  void moveTo(int line) {
    float Yoffset=textSize/2-(sliderPos-(position.y-size.y+sliderLength))*(max(1, (Lines.lines()+10)*textSize-size.y*2)/max(1, size.y*2-sliderLength*2));
    int start=floor(max(0, min(Lines.lines()-1, (-Yoffset)/textSize)));//Yoffset+a*textSize>-textSize
    int end=floor((size.y*2-Yoffset)/textSize-3/2);
    if (line<start) {
      Yoffset=-(line-1/2)*textSize;
      sliderPos=(position.y-size.y+sliderLength)-(Yoffset-textSize/2)/(max(1, (Lines.lines()+10)*textSize-size.y*2)/max(1, size.y*2-sliderLength*2));
    } else if (line>end) {
      Yoffset=-(line+5/2)*textSize+size.y*2;
      sliderPos=(position.y-size.y+sliderLength)-(Yoffset-textSize/2)/(max(1, (Lines.lines()+10)*textSize-size.y*2)/max(1, size.y*2-sliderLength*2));
    }
    sliderPos=position.y+min(max(-size.y+sliderLength, sliderPos-position.y), size.y-sliderLength);//FIX
  }
  void moveToCursor() {
    moveTo(Lines.line);
  }
  void keyTyped() {
    boolean selectAll=false;
    boolean copy=false;
    boolean cut=false;
    boolean paste=false;
    boolean registerQ=false;
    boolean registerE=false;
    int a=1;
    while (a<Shortcuts.length) {
      if (Shortcuts[a].isPressed(ctrlPressed, altPressed, shiftPressed, key, keyCode, shortcutExcept(), currentFrame)) {
        if (Shortcuts[a].FunctionId==S_SELECTALL) {
          selectAll=true;
        } else if (Shortcuts[a].FunctionId==S_COPY) {
          copy=true;
        } else if (Shortcuts[a].FunctionId==S_CUT) {
          cut=true;
        } else if (Shortcuts[a].FunctionId==S_PASTE) {
          paste=true;
        } else if (Shortcuts[a].FunctionId==S_REGISTERQ) {
          registerQ=true;
        } else if (Shortcuts[a].FunctionId==S_REGISTERE) {
          registerE=true;
        }
      }
      a=a+1;
    }
    if (selectAll) {//Ctrl-A
      Lines.selectAll();
      Lines.line=Lines.lines()-1;
      Lines.cursor=Lines.getLine(Lines.line).length();
    }
    if (copy) {//Ctrl-C
      if (Lines.hasSelection())textTransfer.setClipboardContents(Lines.getSelection());
    } 
    if (cut) {//Ctrl-X
      if (Lines.hasSelection()) {
        textTransfer.setClipboardContents(Lines.getSelection());
        Lines.deleteSelection();
      }
      Lines.resetSelection();
      RecordLog();
      pkey='\0';
    }
    if (paste) {//Ctrl-V
      if (Lines.hasSelection()) {
        Lines.deleteSelection();
      } 
      String pasteString1=textTransfer.getClipboardContents().replace("\r\n", "\n").replace("\r", "\n");
      if (pasteString1.length()>0) {
        Lines.insert(pasteString1);
      }
      Lines.resetSelection();
      RecordLog();
      pkey='\0';
    }
    if (registerQ) {//Ctrl+Q
      userMacro1=Lines.getSelection();
      Button num1=((Button)UI[getUIid("I_NUMBER1")]);
      num1.text=userMacro1.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
      num1.render();
    }
    if (registerE) {//Ctrl+E
      //processing...don't stop!!
      userMacro2=Lines.getSelection();
      Button num2=((Button)UI[getUIid("I_NUMBER2")]);
      num2.text=userMacro2.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
      num2.render();
    }
    if (key==BACKSPACE) {
      if (Lines.hasSelection()) Lines.deleteSelection();
      else Lines.deleteBefore(false);
      Lines.resetSelection();
      if (pkey!='\b')RecordLog();
      pkey='\b';
    } else if (ctrlPressed&&key==127) {
      if (Lines.hasSelection())Lines.deleteSelection();
      else Lines.deleteBefore(true);
      Lines.resetSelection();
      if (pkey!='\b')RecordLog();
      pkey='\b';
    } else if (key==DELETE) {
      if (Lines.hasSelection()) {
        Lines.deleteSelection();
      } else {
        if (ctrlPressed) Lines.deleteAfter(true);
        else  Lines.deleteAfter(false);
      }
      Lines.resetSelection();
      if (pkey!='\b')RecordLog();
      pkey='\b';
    } else if (ctrlPressed==false&&altPressed==false) {
      if (key=='\t') {
        if (Lines.hasSelection()) {
          Lines.deleteSelection();
        } 
        Lines.insert("  ");
        Lines.resetSelection();
        if (pkey!=' ')RecordLog();
        pkey=' ';
      } else {
        if (Lines.hasSelection()) {
          Lines.deleteSelection();
        } 
        Lines.insert(str(key));
        Lines.resetSelection();
        if ((key==' '&&pkey!=' ')||(key!=' '&&(pkey=='\n'||pkey==BACKSPACE)))RecordLog();
        pkey=key;
      }
    }
    sliderLength=size.y*size.y/max(size.y, max(Lines.lines()+10, size.y*2/textSize)*textSize/2);//half
    sliderPos=position.y+min(max(-size.y+sliderLength, sliderPos-position.y), size.y-sliderLength);//FIX
    moveToCursor();
  }
}