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
  public LedTextEditor(int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    updateSlider(position.y-size.y);
    openNewFile();
  }
  void updateSlider(float pos) {//MouseY
    sliderLength=size.y*size.y/max(size.y, max(current.lines()+10, size.y*2/textSize)*textSize/2);//half
    sliderPos=position.y+min(max(pos-position.y, -size.y+sliderLength), size.y-sliderLength);
  }
  void loadText(String filename, String text) {
    LedScript script=new LedScript(filename);
    script.insert(0, 0, text);
    current=script;
    current.readAll();
    opened.put(filename, script);
  }
  void insert(int point_, int line_, String text) {
    current.insert(point_, line_, text);
    moveTo(line_);
    updateSlider(sliderPos);
  }
  void addLine(int line_, String text) {
    current.addLine(line_, text);
    moveTo(line_);
    updateSlider(sliderPos);
  }
  void openNewFile() {
    loadText(ext_createFileName(), pw_startText);
  }
  //
  void adjustCursor() {
    float Yoffset=-(sliderPos-(position.y-size.y+sliderLength))*(max(1, (current.lines()+10)*textSize-size.y*2)/max(1, size.y*2-sliderLength*2));
    current.line=floor(max(0, min(current.lines()-1, ((-Yoffset+MouseY-position.y+size.y)/textSize)-1)));
    current.point=current.getLine(current.line).length();
    if (current.getLine(current.line).length()>500) {//WARNING!!! this is for removing lag in "no happening" state. it is hardcoded, and this can occur some error when complexity become higher.
      current.point=500;
    }
    textFont(fontRegular);
    textSize(max(1, textSize));
    while (current.point>0&&position.x-size.x+textSize*3+textWidth(current.getLine(current.line).substring(0, current.point))>=MouseX) {
      current.point--;
    }
    textFont(fontBold);
  }
  void moveTo(int line) {
    float Yoffset=textSize/2-(sliderPos-(position.y-size.y+sliderLength))*(max(1, (current.lines()+10)*textSize-size.y*2)/max(1, size.y*2-sliderLength*2));
    int start=floor(max(0, min(current.lines()-1, (-Yoffset)/textSize)));//Yoffset+a*textSize>-textSize
    int end=floor((size.y*2-Yoffset)/textSize-3/2);
    if (line<start) {
      Yoffset=-(line-1/2)*textSize;
      sliderPos=(position.y-size.y+sliderLength)-(Yoffset-textSize/2)/(max(1, (current.lines()+10)*textSize-size.y*2)/max(1, size.y*2-sliderLength*2));
    } else if (line>end) {
      Yoffset=-(line+5/2)*textSize+size.y*2;
      sliderPos=(position.y-size.y+sliderLength)-(Yoffset-textSize/2)/(max(1, (current.lines()+10)*textSize-size.y*2)/max(1, size.y*2-sliderLength*2));
    }
    sliderPos=position.y+min(max(-size.y+sliderLength, sliderPos-position.y), size.y-sliderLength);//FIX
  }
  void moveToCursor() {
    moveTo(current.line);
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
      int line=max(0, current.processer.DelayPoint.get(current.processer.getFrame(current.line)));
      while (current.line>line) {
        current.selectionUp();
      }
    } else cursorUp(shift);
  }
  void cursorDown(boolean shift) {
    if (shift)current.selectionDown();
    else current.cursorDown(false);
  }
  void cursorDown(boolean ctrl, boolean shift) {
    if (ctrl) {
      int index=current.processer.getFrame(current.line)+1;
      int line=current.lines();
      if (current.getCommands().get(current.line) instanceof DelayCommand)line=current.processer.DelayPoint.get(min(current.processer.DelayPoint.size()-1, index+1));
      else if (index<current.processer.DelayPoint.size())line=current.processer.DelayPoint.get(index);
      while (current.line<line) {
        cursorDown(shift);
      }
    } else cursorDown(shift);
  }
  void mouseWheel(MouseEvent e) {
    sliderPos=position.y+min(max(-size.y+sliderLength, sliderPos-position.y+e.getCount()*2000/max(current.lines()+8, size.y*2/textSize)), size.y-sliderLength);//HARDCODED!!!
  }
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
      updateSlider(sliderPos);
      focus=ID;
      editorClicked=false;
      sliderClicked=true;
    } else if (isMousePressed(position.x-SLIDER_HALFWIDTH, position.y, size.x-SLIDER_HALFWIDTH, size.y)) {
      if (editorClicked) {
        adjustCursor();
        current.selStartLine=min(current.line, clickline);
        current.selEndLine=max(current.line, clickline);
        if (current.line==clickline) {
          current.selStartPoint=min(current.point, clickcursor);
          current.selEndPoint=max(current.point, clickcursor);
        } else if (current.selStartLine==current.line) {
          current.selStartPoint=current.point;
          current.selEndPoint=clickcursor;
        } else {
          current.selStartPoint=clickcursor;
          current.selEndPoint=current.point;
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
          if (current.line==current.selStartLine&&current.point==current.selStartPoint) {//reverse
            clickline=current.selEndLine;
            clickcursor=current.selEndPoint;
            adjustCursor();
            current.selStartLine=current.line;
            current.selStartPoint=current.point;
          } else {
            clickline=current.selStartLine;
            clickcursor=current.selStartPoint;
            adjustCursor();
            current.selEndLine=current.line;
            current.selEndPoint=current.point;
          }
        } else {
          adjustCursor();
          current.selStartLine=current.line;
          current.selStartPoint=current.point;
          current.resetSelection();
          clickline=current.line;
          clickcursor=current.point;
        }
        editorClicked=true;
      }
    }
    if (ID==focus||(isFocused&&ID!=focus)) {
      render();//extra render
    }
    return false;
  }
  @Override void render() {
    if (skip)return;
    textSize=((TextBox)UI[getUIid("I_TEXTSIZE")]).value;
    //draw basic form
    fill(UIcolors[I_TEXTBACKGROUND]);
    rect(position.x, position.y, size.x, size.y);
    fill(UIcolors[I_FOREGROUND]);
    rect(position.x-size.x+textSize*3/2-3, position.y, textSize*3/2-3, size.y);
    //setup text
    textAlign(LEFT, CENTER);
    textFont(fontRegular);
    textSize(max(1, textSize));
    textLeading(textSize/2);
    //iterate lines
    float Yoffset=textSize/2-(sliderPos-(position.y-size.y+sliderLength))*(max(1, (current.lines()+10)*textSize-size.y*2)/max(1, size.y*2-sliderLength*2));
    int start=floor(max(0, min(current.lines()-1, (-Yoffset)/textSize)));
    int end=(int)(size.y*2-textSize*3/2-Yoffset)/textSize;
    for (int a=start; a<current.lines()&&a<end; a++) {
      //draw selection
      if (current.hasSelection()) {
        fill(UIcolors[I_TEXTBOXSELECTION]);
        String selectionPart=current.getSelectionPart(a);
        if (selectionPart.equals("")==false) {
          if (selectionPart.charAt(selectionPart.length()-1)=='\n') {
            selectionPart=selectionPart.substring(0, selectionPart.length()-1);
            rect(position.x+textWidth(current.getSelectionPartBefore(a))/2+textSize+5, position.y-size.y+(a+1)*textSize+Yoffset+5, size.x-textWidth(current.getSelectionPartBefore(a))/2-textSize*2, textSize/2);
          } else rect(position.x-size.x+textSize*3+textWidth(selectionPart)/2+textWidth(current.getSelectionPartBefore(a))+5, position.y-size.y+(a+1)*textSize+3+Yoffset, textWidth(selectionPart)/2, textSize/2);
        }
      }
      //draw text
      String line=current.getLine(a);
      int commentPoint=line.length();//split comment
      for (int b=1; b<line.length(); b++) {
        if (line.charAt(b-1)=='/'&&line.charAt(b)=='/') {
          commentPoint=b-1;
          break;
        }
      }
      //split to tokens
      String[] tokens=split(current.getLine(a).substring(0, commentPoint), " ");
      String count="";
      for (int b=0; b<tokens.length; b++) {
        fill(UIcolors[I_GENERALTEXT]);
        if (current.getCmdSet()==LedProcesser.AUTOPLAY_CMDSET) {
          if (tokens[b].equals("on")||tokens[b].equals("o")||tokens[b].equals("off")||tokens[b].equals("f")||tokens[b].equals("delay")||tokens[b].equals("d")||tokens[b].equals("chain")||tokens[b].equals("c")) {
            fill(UIcolors[I_KEYWORDTEXT]);
          }
        } else {
          if ((tokens[b].equals("on")||tokens[b].equals("o")||tokens[b].equals("off")||tokens[b].equals("f")||tokens[b].equals("delay")||tokens[b].equals("d")||tokens[b].equals("auto")||tokens[b].equals("a")||tokens[b].equals("bpm")||tokens[b].equals("b")||tokens[b].equals("p"))) {
            fill(UIcolors[I_KEYWORDTEXT]);
          } else if (current.getCmdSet()==LedProcesser.UNITOR_CMDSET) {
            if (tokens[b].equals("chain")||tokens[b].equals("c")||tokens[b].equals("mapping")||tokens[b].equals("m")) {
              fill(UIcolors[I_UNITORTEXT]);
            } else if (tokens[b].equals("mc")||tokens[b].equals("s")||tokens[b].equals("l")||tokens[b].equals("rnd")) {
              fill(UIcolors[I_UNITORTEXT2]);
            }
          }
        }
        if (count.length()+tokens[b].length()>LINE_MAX_LENGTH) {//WARNING!!! this is for removing lag in "no happening" state. it is hardcoded, and this can occur some error when complexity become higher.
          text(tokens[b].substring(0, min(1000, tokens[b].length())), position.x-size.x+textSize*3+textWidth(count)+5, position.y-size.y+(a+1)*textSize+Yoffset);
          a=987654321;
          break;
        }
        text(tokens[b], position.x-size.x+textSize*3+textWidth(count)+5, position.y-size.y+(a+1)*textSize+Yoffset);
        count=count+tokens[b]+" ";
      }
      if (a<current.lines()/*WARNING!!!*/&&commentPoint!=current.getLine(a).length()) {
        fill(UIcolors[I_COMMENTTEXT]);
        if (commentPoint<0)return;//warning!!!
        String showText=current.getLine(a).substring(commentPoint, current.getLine(a).length());
        text(showText, position.x-size.x+textSize*3+textWidth(current.getLine(a).substring(0, commentPoint))+5, position.y-size.y+(a+1)*textSize+Yoffset);
      }
      //check error and draw.
      LineError err=current.getFirstError(a);
      if (err!=null) {
        if (err.type==LineError.WARNING) {
          stroke(UIcolors[I_TABC3]);
        } else {
          stroke(UIcolors[I_TABC2]);
        }
        strokeWeight(2);
        line(position.x-size.x+textSize*3.2F, position.y-size.y+(a+1.5F)*textSize+Yoffset, position.x-size.x+textSize*3.2F+textWidth(current.getLine(a)), position.y-size.y+(a+1.5F)*textSize+Yoffset);
        noStroke();
      }
    }
    LineError err=current.getFirstError(current.line);
    errorpsize=current.getErrors().size();//fix it!
    displayingError=err;
    if (err==null) {
      if (current.getErrors().size()==0) {//no errors
        setStatusR("");
      } else {
        setStatusR(err.toString());
      }
    } else {
      setStatusR(err.toString());
    }
    fill(UIcolors[I_GENERALTEXT]);
    if (ID==focus)if (frameCount%54<36)if (Yoffset+current.line*textSize>-textSize&&Yoffset+current.line*textSize<size.y*2-textSize*3/2)text("|", position.x-size.x+textSize*3+textWidth(current.getLine(current.line).substring(0, min(current.getLine(current.line).length(), current.point)))+2, position.y-size.y+(current.line+1)*textSize+Yoffset);
    textAlign(RIGHT, CENTER);
    textFont(fontBold);
    textSize(max(1, textSize));
    textLeading(textSize/2);
    int a=floor(max(0, (-Yoffset)/textSize));//Yoffset+a*textSize>-textSize
    int loopstart=current.processer.getFrameByTime((int)frameSliderLoop.valueS);
    int loopend=current.processer.getFrameByTime((int)frameSliderLoop.valueE);
    int linecnt=current.lines();
    while (Yoffset+a*textSize<size.y*2-textSize*3/2) {//a<current.lines()+30) {
      if (a<linecnt) {
        float tempY=position.y-size.y+(a+1)*textSize+Yoffset;
        tempY=tempY-min(textSize/4, (tempY-position.y+size.y)/2)+textSize/4;
        tempY=tempY+min(textSize/4, (position.y+size.y-tempY)/2)-textSize/4;
        float tempSY= min(min(textSize/2, (tempY-position.y+size.y)), (position.y+size.y-tempY));
        if (frameSliderLoop.bypass==false) {
          if (current.processer.DelayPoint.get(loopstart)<a&&((loopstart<current.processer.DelayPoint.size()-1&&a<=current.processer.DelayPoint.get(loopstart+1))||loopstart>=current.processer.DelayPoint.size()-1)) {
            fill(255, 0, 0, 40);
            rect(position.x-size.x+textSize*3/2-3, tempY, textSize*3/2-3, tempSY);
          } else if (current.processer.DelayPoint.get(loopend)<a&&((loopend<current.processer.DelayPoint.size()-1&&a<=current.processer.DelayPoint.get(loopend+1))||loopend>=current.processer.DelayPoint.size()-1)) {
            fill(0, 0, 255, 40);
            rect(position.x-size.x+textSize*3/2-3, tempY, textSize*3/2-3, tempSY);
          }
        }
        if (current.processer.displayFrame<current.processer.DelayPoint.size()) {
          if ((current.processer.DelayPoint.get(current.processer.displayFrame)<a&&((current.processer.displayFrame<current.processer.DelayPoint.size()-1&&a<=current.processer.DelayPoint.get(current.processer.displayFrame+1)))||(current.processer.displayFrame==current.processer.DelayPoint.size()-1&&a>current.processer.DelayPoint.get(current.processer.displayFrame)))) {
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
      markLine(color(255, 0, 0), max(0, current.processer.DelayPoint.get(loopstart)), offset, total);
      markLine(color(0, 0, 255), max(0, current.processer.DelayPoint.get(loopend)), offset, total);
    }
    markLine(color(0), max(0, current.processer.DelayPoint.get(current.processer.displayFrame)), offset, total);
    a=0;
    while (a<current.getErrors().size()) {
      markLine(UIcolors[I_TABC2], current.getErrors().get(a).line, offset, total);
      a=a+1;
    }
    UI[getUIid("I_OPENFIND")].render();
  }
  void markLine(color c, int line, float offset, float total) {
    stroke(c);
    float val=offset+total*line/(current.lines()-floor(size.y*2/textSize)+8);
    if (val<position.y+size.y)line(position.x+size.x-SLIDER_HALFWIDTH*2, val, position.x+size.x, val);
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
      current.selectAll();
      current.line=current.lines()-1;
      current.point=current.getLine(current.line).length();
    }
    if (copy) {//Ctrl-C
      if (current.hasSelection())textTransfer.setClipboardContents(current.getSelection());
    } 
    if (cut) {//Ctrl-X
      if (current.hasSelection()) {
        textTransfer.setClipboardContents(current.getSelection());
        current.deleteSelection();
      }
      current.resetSelection();
      current.recorder.recordLog();
      pkey='\0';
    }
    if (paste) {//Ctrl-V
      if (current.hasSelection()) {
        current.deleteSelection();
      } 
      String pasteString1=textTransfer.getClipboardContents().replace("\r\n", "\n").replace("\r", "\n");
      if (pasteString1.length()>0) {
        current.insert(pasteString1);
      }
      current.resetSelection();
      current.recorder.recordLog();
      pkey='\0';
    }
    if (registerQ) {//Ctrl+Q
      userMacro1=current.getSelection();
      Button num1=((Button)UI[getUIid("I_NUMBER1")]);
      num1.text=userMacro1.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
      num1.render();
    }
    if (registerE) {//Ctrl+E
      //processing...don't stop!!
      userMacro2=current.getSelection();
      Button num2=((Button)UI[getUIid("I_NUMBER2")]);
      num2.text=userMacro2.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
      num2.render();
    }
    if (key==BACKSPACE) {
      if (current.hasSelection()) current.deleteSelection();
      else current.deleteBefore(false);
      current.resetSelection();
      if (pkey!='\b')current.recorder.recordLog();
      pkey='\b';
    } else if (ctrlPressed&&key==127) {
      if (current.hasSelection())current.deleteSelection();
      else current.deleteBefore(true);
      current.resetSelection();
      if (pkey!='\b')current.recorder.recordLog();
      pkey='\b';
    } else if (key==DELETE) {
      if (current.hasSelection()) {
        current.deleteSelection();
      } else {
        if (ctrlPressed) current.deleteAfter(true);
        else  current.deleteAfter(false);
      }
      current.resetSelection();
      if (pkey!='\b')current.recorder.recordLog();
      ;
      pkey='\b';
    } else if (ctrlPressed==false&&altPressed==false) {
      if (key=='\t') {
        if (current.hasSelection()) {
          current.deleteSelection();
        } 
        current.insert("  ");
        current.resetSelection();
        if (pkey!=' ')current.recorder.recordLog();
        ;
        pkey=' ';
      } else {
        if (current.hasSelection()) {
          current.deleteSelection();
        } 
        current.insert(str(key));
        current.resetSelection();
        if ((key==' '&&pkey!=' ')||(key!=' '&&(pkey=='\n'||pkey==BACKSPACE)))current.recorder.recordLog();
        ;
        pkey=key;
      }
    }
    sliderLength=size.y*size.y/max(size.y, max(current.lines()+10, size.y*2/textSize)*textSize/2);//half
    sliderPos=position.y+min(max(-size.y+sliderLength, sliderPos-position.y), size.y-sliderLength);//FIX
    moveToCursor();
  }
}