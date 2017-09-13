class Button extends UIelement {
  //attributes
  int ButtonType=0;
  static final int TYPE_BUTTON_TEXT=0;
  static final int TYPE_BUTTON_COLOR=1;
  static final int TYPE_BUTTON_IMAGE=2;
  static final int TYPE_BUTTON_TOGGLE_TEXT=3;
  static final int TYPE_BUTTON_TOGGLE_IMAGE=4;
  boolean vertical=false;
  //fields
  String text="";
  int textSize=20;
  color colorInfo;
  PImage image;
  //runtime
  boolean value=true;
  public Button(int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, String text_, int textSize_) {
    super(ID_, Type_, name_, description_, x_, y_, w_, h_);
    ButtonType=TYPE_BUTTON_TEXT;
    text=text_;
    textSize=max(1, textSize_);
  }
  public Button(int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, color colorInfo_) {
    super(ID_, Type_, name_, description_, x_, y_, w_, h_);
    ButtonType=TYPE_BUTTON_COLOR;
    colorInfo=colorInfo_;
  }
  public Button(int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, String imageName_) {
    super(ID_, Type_, name_, description_, x_, y_, w_, h_);
    ButtonType=TYPE_BUTTON_IMAGE;
    image=loadImage(imageName_);
  }
  public Button(int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, String text_, int textSize_, boolean value_) {
    super(ID_, Type_, name_, description_, x_, y_, w_, h_);
    ButtonType=TYPE_BUTTON_TOGGLE_TEXT;
    text=text_;
    textSize=max(1, textSize_);
    value=value_;
  }
  public Button(int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, String imageName_, boolean value_) {
    super(ID_, Type_, name_, description_, x_, y_, w_, h_);
    ButtonType=TYPE_BUTTON_TOGGLE_IMAGE;
    image=loadImage(imageName_);
    value=value_;
  }
  @Override
    boolean react() {
    if (super.react ()==false)return false;
    if (isMouseOn(position.x, position.y, size.x, size.y)==false&&focus==ID)focus=DEFAULT;//button characteristics
    if (mouseState==AN_RELEASE&&(isMouseOn(position.x, position.y, size.x, size.y)&&pressed)) {
      onRelease();
      return true;
    }
    return false;
  }
  void resetFocusBeforeFrame() {
    skip=true;
    focus=DEFAULT;
    resetFocus();
    skip=false;
  }
  @Override
    void render() {
    if (disabled)return;
    if (skip)return;
    noStroke();
    if (isMouseOn (position.x, position.y, size.x, size.y )) {
      if (ButtonType==TYPE_BUTTON_TOGGLE_TEXT||ButtonType==TYPE_BUTTON_TOGGLE_IMAGE) {
        if (value) {
          if (mousePressed)fill(UIcolors [I_FOREGROUND]);
          else fill(brighter(UIcolors [I_FOREGROUND], 40));
        } else {
          if (mousePressed)fill(UIcolors [I_FOREGROUND]);
          else fill(brighter(UIcolors [I_FOREGROUND], -20));
        }
      } else {
        if (mousePressed)fill(brighter(UIcolors [I_FOREGROUND], 40));
        else fill(brighter(UIcolors [I_FOREGROUND], 20));
      }
    } else {
      if (ButtonType==TYPE_BUTTON_TOGGLE_TEXT||ButtonType==TYPE_BUTTON_TOGGLE_IMAGE) {
        if (value)fill(brighter(UIcolors [I_FOREGROUND], 60));
        else fill(brighter(UIcolors [I_FOREGROUND], -40));
      } else {
        fill(UIcolors[I_FOREGROUND]);
      }
    }
    rect(position.x, position.y, size.x, size.y);
    pushMatrix();
    translate(position.x, position.y);
    if (vertical)rotate(radians(90));
    if (ButtonType==TYPE_BUTTON_TEXT||ButtonType==TYPE_BUTTON_TOGGLE_TEXT) {
      textSize(textSize);
      fill(UIcolors[I_TEXTCOLOR]);
      text(text, 0, 0);
    } else if (ButtonType==TYPE_BUTTON_COLOR) {
      fill (colorInfo);
      rect (0, 0, size.x*0.8F, size.y*0.8F);
    } else if (ButtonType==TYPE_BUTTON_IMAGE||ButtonType==TYPE_BUTTON_TOGGLE_IMAGE) {
      image (image, 0, 0);
    }
    popMatrix();
    if (name.equals("TAB_KEYLED")) {
      if (currentTabGlobal==1)drawTabVertical();
    } else if (name.equals("TAB_KEYSOUND")) {
      if (currentTabGlobal==2)drawTabVertical();
    } else if (name.equals("TAB_SETTINGS")) {
      if (currentTabGlobal==3)drawTabVertical();
    } else if (name.equals("TAB_WAVEDIT")) {
      if (currentTabGlobal==4)drawTabVertical();
    } else if (name.equals("T_VELOCITY")) {
      if (currentTabKeyLed==1)drawTab();
    } else if (name.equals("T_HTML")) {
      if (currentTabKeyLed==2)drawTab();
    } else if (name.equals("T_TEXT")) {
      if (currentTabKeyLed==3)drawTab();
    } else if (selectedColorType==DS_HTML&&ID==((ColorPicker)UI[htmlselId]).selectedHtml) {
      drawIndicator(position.x, position.y, size.x-4, size.y-4, 4);
    } else if (name.equals("T_SOUNDVIEW")) {
      if (currentTabKeySound==1)drawTab();
    } else if (name.equals("T_LEDVIEW")) {
      if (currentTabKeySound==2)drawTab();
    } else if (name.equals("T_SHORTCUTS")) {
      if (currentTabSettings==1)drawTab();
    } else if (name.equals("T_UICOLORS")) {
      if (currentTabSettings==2)drawTab();
    }
  }
  void drawTabVertical() {
    fill(UIcolors[I_TABC1]);
    rect(position.x+size.x-5, position.y, 5, size.y);
  }
  void drawTab() {
    fill(UIcolors[I_TABC1]);
    rect(position.x, position.y-size.y+5, size.x, 5);
  }
  void onRelease() {
    if (ButtonType==TYPE_BUTTON_TOGGLE_TEXT||ButtonType==TYPE_BUTTON_TOGGLE_IMAGE) {
      if (value)value=false;
      else value=true;
      render();//it is ineffcient!!!
    }
    if (name.equals("TAB_KEYLED"))Frames[getFrameid("F_KEYLED")].prepare();
    else if (name.equals("TAB_KEYSOUND"))Frames[getFrameid("F_KEYSOUND")].prepare();
    else if (name.equals("TAB_SETTINGS"))Frames[getFrameid("F_SETTINGS")].prepare();
    else if (name.equals("TAB_WAVEDIT"))Frames[getFrameid("F_WAVEDIT")].prepare();
    else if (name.equals("OPEN_ERROR"))Frames[getFrameid("F_ERROR")].prepare();
    else if (name.equals("T_VELOCITY")) {
      UI [getUIid("I_VELNUM")].disabled=false;
      ((ColorPicker)UI[getUIid("I_HTMLSEL")]).disableTextBoxes(true);
      UI [getUIid("I_HTMLSEL")].disabled=true;
      UI [getUIid("I_TEXTFIELD")].disabled=true;
      UI [getUIid("I_OPENFIND")].disabled=true;
      UI[getUIidRev("I_FINDTEXTBOX")].disabled=true;
      UI[getUIidRev("I_REPLACETEXTBOX")].disabled=true;
      UI[getUIidRev("I_NEXTFIND")].disabled=true;
      UI[getUIidRev("I_PREVIOUSFIND")].disabled=true;
      UI[getUIidRev("I_CALCULATE")].disabled=true;
      UI[getUIidRev("I_REPLACEALL")].disabled=true;
      currentTabKeyLed=1;
      Frames[currentFrame].render();
    } else if (name.equals("T_HTML")) {
      UI [getUIid("I_VELNUM")].disabled=true;
      ((ColorPicker)UI[getUIid("I_HTMLSEL")]).disableTextBoxes(false);
      UI [getUIid("I_HTMLSEL")].disabled=false;
      UI [getUIid("I_TEXTFIELD")].disabled=true;
      UI [getUIid("I_OPENFIND")].disabled=true;
      UI[getUIidRev("I_FINDTEXTBOX")].disabled=true;
      UI[getUIidRev("I_REPLACETEXTBOX")].disabled=true;
      UI[getUIidRev("I_NEXTFIND")].disabled=true;
      UI[getUIidRev("I_PREVIOUSFIND")].disabled=true;
      UI[getUIidRev("I_CALCULATE")].disabled=true;
      UI[getUIidRev("I_REPLACEALL")].disabled=true;
      currentTabKeyLed=2;
      Frames[currentFrame].render();
    } else if (name.equals("T_TEXT")) {
      UI [getUIid("I_VELNUM")].disabled=true;
      ((ColorPicker)UI[getUIid("I_HTMLSEL")]).disableTextBoxes(true);
      UI [getUIid("I_HTMLSEL")].disabled=true;
      UI [getUIid("I_TEXTFIELD")].disabled=false;
      UI [getUIid("I_OPENFIND")].disabled=false;
      currentTabKeyLed=3;
      Frames[currentFrame].render();
    } else if (name.equals("T_SHORTCUTS")) {
      UI[getUIid("I_UICOLORS")].disabled=true;
      UI[getUIid("I_SHORTCUTS")].disabled=false;
      currentTabSettings=1;
      Frames[currentFrame].render();
    } else if (name.equals("T_UICOLORS")) {
      UI[getUIid("I_UICOLORS")].disabled=false;
      UI[getUIid("I_SHORTCUTS")].disabled=true;
      currentTabSettings=2;
      Frames[currentFrame].render();
    } else if (name.equals("T_SOUNDVIEW")) {
      UI[getUIid("I_SOUNDVIEW")].disabled=false;
      UI[getUIid("I_LEDVIEW")].disabled=true;
      currentTabKeySound=1;
      if (((ScrollList)UI[getUIid("I_SOUNDVIEW")]).selected==-1)UI[getUIidRev("KS_LOOP")].disabled=true;
      else UI[getUIidRev("KS_LOOP")].disabled=false;
      Frames[currentFrame].render();
    } else if (name.equals("T_LEDVIEW")) {
      UI[getUIid("I_SOUNDVIEW")].disabled=true;
      UI[getUIid("I_LEDVIEW")].disabled=false;
      currentTabKeySound=2;
      if (((ScrollList)UI[getUIid("I_LEDVIEW")]).selected==-1)UI[getUIidRev("KS_LOOP")].disabled=true;
      else UI[getUIidRev("KS_LOOP")].disabled=false;
      Frames[currentFrame].render();
      //} else if (name.equals("I_RELOADINSTART")) {
      //nothing
    } else if (name.equals("I_OPENMC")) {//External
      resetFocusBeforeFrame();
      Frames[getFrameid("F_MCCONVERT")].prepare(currentFrame);
    } else if (name.equals("I_OPENMP3")) {//External
      resetFocusBeforeFrame();
      UI[getUIid("MP3_TIME")].disabled=false;
      Frames[getFrameid("F_MP3CONVERT")].prepare(currentFrame);
    } else if (name.equals("I_CHANGETITLE")) {
      resetFocusBeforeFrame();
      ((TextBox)UI[getUIidRev("TITLEEDIT_TEXT")]).text=title_filename;
      Frames[getFrameid("F_TITLEEDIT")].prepare(currentFrame);
    } else if (name.equals("TITLEEDIT_EXIT")) {
      Frames[currentFrame].returnBack();
      title_filename=((TextBox)UI[getUIidRev("TITLEEDIT_TEXT")]).text;
      title_edited="*";
      surface.setTitle(title_filename+title_edited+title_suffix);
    } else if (name.equals("I_PROJECTS")) {
      resetFocusBeforeFrame();
      uncloud_prepare();
      Frames[getFrameid("F_UNCLOUD")].prepare(currentFrame);
    } else if (name.equals("I_RELOAD")) {
      L_ResizeData(((TextBox)UI[getUIid("I_CHAIN")]).value, ((TextBox)UI[getUIid("I_BUTTONX")]).value, ((TextBox)UI[getUIid("I_BUTTONY")]).value);
      analyzer.clear();
      Lines.readAll();
      UI[getUIid("I_CHAIN")].render();
      UI[getUIid("I_BUTTONX")].render();
      UI[getUIid("I_BUTTONY")].render();
      updateFrameSlider();
    } else if (name.equals("I_MIDI")) {
      reloadMidiDevices();
    } else if (name.equals("I_CAFELINK")) {//External
      link ("http://cafe.naver.com/unipad");
    } else if (name.equals("I_PATH")) {
      if (platform==WINDOWS) {//WARNING!!! Windows specific
        //https://stackoverflow.com/questions/15875295/open-a-folder-in-explorer-using-java
        try {
          java.awt.Desktop.getDesktop().open(new File(GlobalPath));
        }
        catch(Exception e) {
          e.printStackTrace();
        }
      } else if (platform==LINUX) {
      }
    } else if (name.equals("I_INFO")) {//UI
      Frames [getFrameid("F_INFO")].prepare (currentFrame);
    } else if (name.equals("I_DEFAULTINPUT")) {//Settings
      value=true;
      ((Button)UI [getUIid("I_OLDINPUT")]).value=false;
      ((Button)UI [getUIid("I_CYXMODE")]).value=false;
      UI [getUIid("I_DEFAULTINPUT")].render();
      UI [getUIid("I_OLDINPUT")].render();
      UI [getUIid("I_CYXMODE")].render();
      Mode=AUTOINPUT;
      removeErrorsWithCode(3, 5);
      adderror=true;
      int a=0;
      while (a<analyzer.uLines.size()) {//WARNING!!! assert analyzer.uLines.size()==Lines.lines()
        if (analyzer.uLines.get(a).Type==Analyzer.UnipackLine.APON||analyzer.uLines.get(a).Type==Analyzer.UnipackLine.CHAIN)printError(2/*remove when changing mode!*/, a, "LedEditor", Lines.getLine(a), "can't use autoPlay command in led file.");
        a=a+1;
      }
      adderror=false;
    } else if (name.equals("I_OLDINPUT")) {//Settings
      value=true;
      ((Button)UI [getUIid("I_DEFAULTINPUT")]).value=false;
      ((Button)UI [getUIid("I_CYXMODE")]).value=false;
      UI [getUIid("I_DEFAULTINPUT")].render();
      UI [getUIid("I_OLDINPUT")].render();
      UI [getUIid("I_CYXMODE")].render();
      Mode=MANUALINPUT;
      removeErrorsWithCode(3, 5);
      adderror=true;
      int a=0;
      while (a<analyzer.uLines.size()) {
        if (analyzer.uLines.get(a).Type==Analyzer.UnipackLine.APON||analyzer.uLines.get(a).Type==Analyzer.UnipackLine.CHAIN)printError(2/*remove when changing mode!*/, a, "LedEditor", Lines.getLine(a), "can't use autoPlay command in led file.");
        a=a+1;
      }
      adderror=false;
    } else if (name.equals("I_CYXMODE")) {//Settings
      value=true;
      ((Button)UI [getUIid("I_DEFAULTINPUT")]).value=false;
      ((Button)UI [getUIid("I_OLDINPUT")]).value=false;
      UI [getUIid("I_DEFAULTINPUT")].render();
      UI [getUIid("I_OLDINPUT")].render();
      UI [getUIid("I_CYXMODE")].render();
      Mode=CYXMODE;
      removeErrorsWithCode(2, 4);
      adderror=true;
      int a=0;
      while (a<analyzer.uLines.size()) {
        if (analyzer.uLines.get(a).Type==Analyzer.UnipackLine.ON)printError(3/*remove when changing mode!*/, a, "LedEditor", Lines.getLine(a), "can't use led on command in autoPlay." );
        a=a+1;
      }
      adderror=false;
    } else if (name.equals("I_IGNOREMC")) {//Settings
      ignoreMc=value;
      if (value)removeErrorsWithCode(4, 5);
      else {
        adderror=true;
        int a=0;
        if (Mode==CYXMODE) {
          while (a<analyzer.uLines.size()) {
            if (analyzer.uLines.get(a).mc)printError(5/*remove when changing mode!*/, a, "LedEditor", Lines.getLine(a), "mc not working!");
            a=a+1;
          }
        } else {
          while (a<analyzer.uLines.size()) {
            if (analyzer.uLines.get(a).mc)printError(4/*remove when changing mode!*/, a, "LedEditor", Lines.getLine(a), "mc not working!");
            a=a+1;
          }
        }     
        adderror=false;
      }
    } else if (name.equals("T_FILEVIEW")) {
      currentTabWavList=1;
      UI[getUIidRev("I_FILEVIEW3")].disabled=false;
      UI[getUIidRev("I_CUTPOINT")].disabled=true;
      UI[getUIidRev("T_SIGNALCHAIN")].disabled=true;
      UI[getUIidRev("T_AUTOMATION")].disabled=true;
      UI[getUIidRev("I_SIGNALCHAIN")].disabled=true;
      UI[getUIidRev("I_EFFECTORS")].disabled=true;
      UI[getUIidRev("I_AUTOMATION")].disabled=true;
      Frames[currentFrame].render();
    } else if (name.equals("T_CUTPOINT")) {
      currentTabWavList=2;
      UI[getUIidRev("I_FILEVIEW3")].disabled=true;
      UI[getUIidRev("I_CUTPOINT")].disabled=false;
      UI[getUIidRev("T_SIGNALCHAIN")].disabled=true;
      UI[getUIidRev("T_AUTOMATION")].disabled=true;
      UI[getUIidRev("I_SIGNALCHAIN")].disabled=true;
      UI[getUIidRev("I_EFFECTORS")].disabled=true;
      UI[getUIidRev("I_AUTOMATION")].disabled=true;
      Frames[currentFrame].render();
    } else if (name.equals("T_TRACKLIST")) {
      currentTabWavList=3;
      UI[getUIidRev("I_FILEVIEW3")].disabled=true;
      UI[getUIidRev("I_CUTPOINT")].disabled=true;
      UI[getUIidRev("T_SIGNALCHAIN")].disabled=false;
      UI[getUIidRev("T_AUTOMATION")].disabled=false;
      if (currentTabAuto==1) {
        UI[getUIidRev("I_SIGNALCHAIN")].disabled=false;
        UI[getUIidRev("I_EFFECTORS")].disabled=false;
      } else if (currentTabAuto==2) {
        UI[getUIidRev("I_AUTOMATION")].disabled=false;
      }
      Frames[currentFrame].render();
    } else if (name.equals("T_SIGNALCHAIN")) {
      currentTabAuto=1;
      UI[getUIidRev("I_SIGNALCHAIN")].disabled=false;
      UI[getUIidRev("I_EFFECTORS")].disabled=false;
      UI[getUIidRev("I_AUTOMATION")].disabled=true;
      Frames[currentFrame].render();
    } else if (name.equals("T_AUTOMATION")) {
      currentTabAuto=2;
      UI[getUIidRev("I_SIGNALCHAIN")].disabled=true;
      UI[getUIidRev("I_EFFECTORS")].disabled=true;
      UI[getUIidRev("I_AUTOMATION")].disabled=false;
      Frames[currentFrame].render();
    } else if (name.equals("I_INFRAME")) {
      InFrameInput=value;
    } else if (name.equals("I_PLAYSTOP")) {
      if (autorun_playing) {
        if (autorun_paused)autorun_paused=false;
        else autorun_paused=true;
      } else {
        autoRunReset();
      }
    } else if (name.equals("I_LOOP")) {
      autorun_infinite=value;
    } else if (name.equals("I_AUTOSAVE")) {
      autoSave=value;
    } else if (name.equals("I_AUTOSTOP")) {
      autoStop=value;
    } else if (name.equals("I_STARTFROM")) {
      startFrom=value;
    } else if (name.equals("I_RECENT1")) {
      if (((Button)UI[ID]).colorInfo!=((Button)UI[ID+1]).colorInfo) {
        int a=ID+9;
        while (a>ID) {
          ((Button)UI[a]).colorInfo=((Button)UI[a-1]).colorInfo;
          Button temp=((Button)UI[a]);
          UI[a].description.content="["+int(red(temp.colorInfo))+", "+int(green(temp.colorInfo))+", "+int(blue(temp.colorInfo))+"]";
          UI[a].render();
          a=a-1;
        }
        description.content="["+int(red(colorInfo))+", "+int(green(colorInfo))+", "+int(blue(colorInfo))+"]";//this also do in colorpicker.
      }
      if (Mode==AUTOINPUT) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT2")) {
      if (Mode==AUTOINPUT) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT3")) {
      if (Mode==AUTOINPUT) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT4")) {
      if (Mode==AUTOINPUT) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT5")) {
      if (Mode==AUTOINPUT) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT6")) {
      if (Mode==AUTOINPUT) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT7")) {
      if (Mode==AUTOINPUT) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT8")) {
      if (Mode==AUTOINPUT) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT9")) {
      if (Mode==AUTOINPUT) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT) writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENTA")) {
      if (Mode==AUTOINPUT) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_EXIT")) {
      exit();
    } else if (name.equals("I_NUMBER1")) {
      int before=LED.size();
      writeDisplay(userMacro1);
      if (LED.size()==before+1) {//ap.size and led.size is equal.
        currentLedFrame++;
        setTimeByFrame();
        frameSlider.render();
      }
    } else if (name.equals("I_NUMBER2")) {
      int before=LED.size();
      writeDisplay(userMacro2);
      UI[textfieldId].render();
      if (LED.size()==before+1) {
        currentLedFrame++;
        setTimeByFrame();
        frameSlider.render();
      }
    } else if (name.equals("I_OPENFIND")) {
      if (currentTabKeyLed==3) {
        if (value) {
          UI[getUIidRev("I_FINDTEXTBOX")].disabled=false;
          UI[getUIidRev("I_REPLACETEXTBOX")].disabled=false;
          UI[getUIidRev("I_NEXTFIND")].disabled=false;
          UI[getUIidRev("I_PREVIOUSFIND")].disabled=false;
          UI[getUIidRev("I_CALCULATE")].disabled=false;
          UI[getUIidRev("I_REPLACEALL")].disabled=false;
          UI[textfieldId].position.y=((TextEditor)UI[textfieldId]).shortenY;
          UI[textfieldId].size.y=((TextEditor)UI[textfieldId]).shortenSY;
          ((TextEditor)UI[textfieldId]).resizeSlider();
          Frames[currentFrame].render();
        } else {
          UI[getUIidRev("I_FINDTEXTBOX")].disabled=true;
          UI[getUIidRev("I_REPLACETEXTBOX")].disabled=true;
          UI[getUIidRev("I_NEXTFIND")].disabled=true;
          UI[getUIidRev("I_PREVIOUSFIND")].disabled=true;
          UI[getUIidRev("I_CALCULATE")].disabled=true;
          UI[getUIidRev("I_REPLACEALL")].disabled=true;
          UI[textfieldId].position.y=((TextEditor)UI[textfieldId]).originalY;
          UI[textfieldId].size.y=((TextEditor)UI[textfieldId]).originalSY;
          ((TextEditor)UI[textfieldId]).resizeSlider();
          Frames[currentFrame].render();
        }
      } else {
        value=false;
      }
    } else if (name.equals("I_NEXTFIND")) {
      if (findData.size()!=0) {
        if (patternMatcher.findUpdated==false)findData=patternMatcher.findAll(Lines.toString());
        findIndex=findIndex+1;
        if (findIndex>=findData.size())findIndex=0;
        Lines.setCursorByIndex(findData.get(findIndex).startpoint);
        Lines.selectFromCursor(findData.get(findIndex).text.length());
        focus=textfieldId;
        ((TextEditor)UI[textfieldId]).moveToCursor();
        //UI[textfieldId].render();
        UI[findId].render();
      }
    } else if (name.equals("I_PREVIOUSFIND")) {
      if (findData.size()!=0) {
        if (patternMatcher.findUpdated==false)findData=patternMatcher.findAll(Lines.toString());
        findIndex=findIndex-1;
        if (findIndex<0)findIndex=findData.size()-1;
        Lines.setCursorByIndex(findData.get(findIndex).startpoint);
        Lines.selectFromCursor(findData.get(findIndex).text.length());
        focus=textfieldId;
        ((TextEditor)UI[textfieldId]).moveToCursor();
        //UI[textfieldId].render();
        UI[findId].render();
      }
    } else if (name.equals("I_REPLACEALL")) {
      patternMatcher.registerFind(((TextBox)UI[getUIid("I_FINDTEXTBOX")]).text, value);
      patternMatcher.registerReplace(((TextBox)UI[getUIid("I_REPLACETEXTBOX")]).text, value);
      findData=patternMatcher.findAll(Lines.toString());//WARNING!!!
      RecordLog();
      ((TextEditor)UI[textfieldId]).setText(patternMatcher.replaceAll(Lines.toString(), ((TextBox)UI[getUIid("I_REPLACETEXTBOX")]).text, findData));
      RecordLog();
    } else if (name.equals("I_CALCULATE")) {
      patternMatcher.registerFind(((TextBox)UI[getUIid("I_FINDTEXTBOX")]).text, value);
      patternMatcher.registerReplace(((TextBox)UI[getUIid("I_REPLACETEXTBOX")]).text, value);
      findData=patternMatcher.findAll(Lines.toString());//WARNING!!!
    } else if (name.equals("I_CLEARKEYSOUND")) {
      int a=0;
      while (a<ksDisplay.length) {
        int b=0;
        while (b<ksDisplay[a].length) {
          ksDisplay[a][b]=OFFCOLOR;
          b=b+1;
        }
        a=a+1;
      }
      while (ledstack.size()>0) {
        ledstack.get(ledstack.size()-1).isInStack=false;
        ledstack.remove(ledstack.size()-1);
      }
      a=0;
      while (a<ButtonX) {
        int b=0;
        while (b<ButtonY) {
          KS.get(ksChain)[a][b].stopSound();
          b=b+1;
        }
        a=a+1;
      }
      int id=getUIidRev("KS_SOUNDMULTI");
      ((TextBox)UI[id]).value=max(1, min(KS.get(ksChain)[X][Y].multiSound, KS.get(ksChain)[X][Y].ksSound.size()));
      ((TextBox)UI[id]).text=""+((TextBox)UI[id]).value;
      UI[id].render();
      id=getUIidRev("KS_LEDMULTI");
      ((TextBox)UI[id]).value=max(1, min(KS.get(ksChain)[X][Y].multiLed, KS.get(ksChain)[X][Y].ksLedFile.size()));
      ((TextBox)UI[id]).text=""+((TextBox)UI[id]).value;
      UI[id].render();
      UI[getUIid("KEYSOUND_PAD")].render();
      setStatusR("Cleared");
    } else if (name.equals("I_RELOADKEYSOUND")) {
      for (int a=0; a<Chain; a++) {
        for (int b=0; b<ButtonX; b++) {
          for (int c=0; c<ButtonY; c++) {
            KS.get(a)[b][c].reloadLeds();
          }
        }
      }
      setStatusR("Reloaded");
    } else if (name.equals("MP3_CONVERT")) {
      int a=0;
      boolean valid=true;
      File file=new File(((TextBox)UI[getUIidRev("MP3_OUTPUT")]).text);
      if (file.isDirectory()==false) {
        if (file.mkdirs()) {
        } else valid=false;
      }
      if (((ScrollList)UI[getUIidRev("MP3_FORMAT")]).selected==-1)valid=false;
      if (((ScrollList)UI[getUIidRev("MP3_CODEC")]).selected==-1)valid=false;
      ScrollList input=(ScrollList)UI[getUIidRev("MP3_INPUT")];
      if (valid) {//outputFormat, outputCodec, outputBitRate, outputChannels, outputSampleRate
        UI[getUIid("LOG_EXIT")].disabled=true;
        ((Logger)UI[getUIid("LOG_LOG")]).logs.clear();
        Frames[getFrameid("F_LOG")].prepare(currentFrame);
        int channels=2;
        if (((Button)UI[getUIidRev("MP3_STEREO")]).value==false)channels=1;
        //println("ready to convert");
        converter.convertAll(input.View, ((TextBox)UI[getUIidRev("MP3_OUTPUT")]).text, ((ScrollList)UI[getUIidRev("MP3_FORMAT")]).getSelection(), ((ScrollList)UI[getUIidRev("MP3_CODEC")]).getSelection(), ((TextBox)UI[getUIidRev("MP3_BITRATE")]).value, channels, ((TextBox)UI[getUIidRev("MP3_SAMPLERATE")]).value);
      } else printLog("convert()", "file is not convertable");
    } else if (name.equals("MP3_PLAY")) {
      if (((ScrollList)UI[getUIid("MP3_INPUT")]).selected!=-1) {//inefficient!!!
        if (converter.converterPlayer.fileLoaded)SampleManager.removeSample(converter.converterPlayer.sample);
        converter.converterPlayer.load(((ScrollList)UI[getUIid("MP3_INPUT")]).getSelection());
        converter.converterPlayer.setValue(converter.converterPlayer.slider.valueF);
      }
      if (converter.converterPlayer.fileLoaded) {
        converter.converterPlayer.loop(converter.converterPlayer.loop);
        converter.converterPlayer.play();
      }
    } else if (name.equals("MP3_STOP")) {
      converter.converterPlayer.stop();
    } else if (name.equals("MP3_LOOP")) {
      converter.converterPlayer.setLoopStart(0);
      converter.converterPlayer.setLoopEnd(converter.converterPlayer.length);
      converter.converterPlayer.loop(value);
    } else if (name.equals("MP3_EXIT")) {
      ((ScrollList)UI[getUIid("MP3_INPUT")]).setItems(new String[0]);
      Frames[currentFrame].returnBack();
    } else if (name.equals("LOG_EXIT")) {
      ((ScrollList)UI[getUIid("MP3_INPUT")]).setItems(new String[0]);
      Frames[currentFrame].returnBack();
    } else if (name.equals("ERROR_EXIT")) {
      Frames[currentFrame].returnBack();
    } else if (name.equals("KEYEDIT_EXIT")) {
      Shortcuts[tempShortcut.ID].ctrl=tempShortcut.ctrl;
      Shortcuts[tempShortcut.ID].shift=tempShortcut.shift;
      Shortcuts[tempShortcut.ID].alt=tempShortcut.alt;
      Shortcuts[tempShortcut.ID].keyn=tempShortcut.keyn;
      Shortcuts[tempShortcut.ID].keyCoden=tempShortcut.keyCoden;
      setShortcutData();
      Frames[currentFrame].returnBack();
    } else if (name.equals("PC_EXIT")) {
      UIcolors[tempColor]=((ColorPicker)UI[getUIidRev("PC_HTMLSEL")]).selectedRGB;
      Frames[currentFrame].returnBack();
    } else if (name.equals("MC_MC10")) {
      if (text.equals("mc->10")) text="10->mc";
      else text="mc->10";
      render();
    } else if (name.equals("MC_CONVERT")) {
      boolean direc=false;
      if (((Button)UI[getUIidRev("MC_MC10")]).text.equals("mc->10"))direc=true;
      UI[getUIid("LOG_EXIT")].disabled=true;
      ((Logger)UI[getUIid("LOG_LOG")]).logs.clear();
      Frames[getFrameid("F_LOG")].prepare(currentFrame);
      mcConverter.convert(((TextBox)UI[getUIidRev("MC_INPUT")]).text, ((TextBox)UI[getUIidRev("MC_OUTPUT")]).text, direc, getUIidRev("LOG_EXIT"));
    } else if (name.equals("MC_EXIT")) {
      Frames[currentFrame].returnBack();
    } else if (name.equals("INFO_EXIT")) {
      Frames[currentFrame].returnBack();
    } else if (name.equals("INFO_GITHUBLINK")) {
      link ("https://github.com/EX867/PositionWriter");
    } else if (name.equals("INFO_PROCESSINGLINK")) {
      link ("https://processing.org");
    } else if (name.equals("INFO_DEVELOPERLINK")) {
      link ("https://blog.naver.com/ghh2000");
    } else if (name.equals("INFO_JEONJEHONGLINK")) {
      link ("https://blog.naver.com/jehongjeon");
    } else if (name.equals("INFO_ASDFLINK")) {
      link ("https://EX867.github.io/PositionWriter/asdf");
      //}else if(name.equals("MP3_LOOP")){
      //do nothing
    } else if (name.equals("UN_LOGIN")) {
      resetFocusBeforeFrame();
      Frames[getFrameid("F_LOGIN")].prepare(currentFrame);
    } else if (name.equals("UN_PRIVATE")) {
      //do nothing=
    } else if (name.equals("UN_EXIT")) {
      Frames[currentFrame].returnBack();
    } else if (name.equals("UN_UPLOAD")) {
      resetFocusBeforeFrame();
      tempCode=DIALOG_UPLOAD;
      Frames[getFrameid("F_LOGIN")].prepare(currentFrame);
    } else if (name.equals("UN_UPDATE")) {
      resetFocusBeforeFrame();
      tempCode=DIALOG_UPDATE;
      Frames[getFrameid("F_LOGIN")].prepare(currentFrame);
    } else if (name.equals("UN_DELETE")) {
      resetFocusBeforeFrame();
      tempCode=DIALOG_DELETE;
      Frames[getFrameid("F_LOGIN")].prepare(currentFrame);
    } else if (name.equals("UN_DOWNLOAD")) {
      resetFocusBeforeFrame();
      tempCode=DIALOG_DOWNLOAD;
      Frames[getFrameid("F_LOGIN")].prepare(currentFrame);
    } else if (name.equals("DIALOG_EXIT")) {
      tempCode=0;//no happens
      Frames[currentFrame].returnBack();
    } else if (name.equals("DIALOG_OK")) {
      if (tempCode==DIALOG_UPLOAD) {
        uncloud_upload(((ScrollList)UI[getUIidRev("UN_LIST")]).selected);
      } else if (tempCode==DIALOG_UPDATE) {
        uncloud_update(((ScrollList)UI[getUIidRev("UN_LIST")]).selected);
      } else if (tempCode==DIALOG_DELETE) {
        uncloud_delete(((ScrollList)UI[getUIidRev("UN_LIST")]).selected);
      } else if (tempCode==DIALOG_DOWNLOAD) {
        uncloud_download(((ScrollList)UI[getUIidRev("UN_LIST")]).selected);
      }
      tempCode=0;
      Frames[currentFrame].returnBack();
    } else if (name.equals("UPDATE_UPDATE")) {
      link("https://github.com/EX867/PositionWriter/releases");
      Frames[currentFrame].returnBack();
    } else if (name.equals("UPDATE_EXIT")) {
      Frames[currentFrame].returnBack();
    }
  }
}
class Label extends UIelement {
  String text;
  int textSize=1;
  StateReturner returner;
  public Label( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, String text_, int textSize_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    text=text_;
    textSize=max(1, textSize_);
  }
  @Override
    boolean react() {
    if (name.equals("KEYEDIT_INPUT")) {
      getPressedKeysCount();
      if (keyCount>0&&(pkeyCount<keyCount)) {
        tempShortcut.ctrl=ctrlPressed;
        tempShortcut.shift=shiftPressed;
        tempShortcut.alt=altPressed;
        tempShortcut.keyn=key;
        tempShortcut.keyCoden=0;
        text=Shortcuts[tempShortcut.ID].name+"\n\n"+tempShortcut.toString();
        render();
      }
      if (super.react ()==false)return false;
      return false;
    }
    if (focus==ID)focus=DEFAULT;
    update();
    return false;
  }
  void update() {
    if (returner!=null) {
      String before=text;
      text=returner.getState();
      if (before.equals(text)==false)render();
    }
  }
  @Override
    void render() {
    if (disabled)return;
    if (isMouseOn (position.x, position.y, size.x, size.y ))fill(brighter(UIcolors [I_FOREGROUND], 20));
    else fill(UIcolors[I_FOREGROUND]);
    rect(position.x, position.y, size.x, size.y);
    textSize(textSize);
    fill(UIcolors[I_TEXTCOLOR]);
    if (name.equals("STATUS_BAR_R")) {
      textAlign(LEFT, CENTER);
      text(text, position.x-size.x+textSize, position.y-3);
      if (error.size()>0)fill(UIcolors[I_TABC2]);
      else fill(UIcolors[I_TABC1]);
      rect(position.x, position.y-size.y+5, size.x, 5);
      textAlign(RIGHT, CENTER);
      textSize(textSize*3/4);
      text("("+(displayingError+1)+"/"+error.size()+")", position.x+size.x-textSize, position.y-3);
      textAlign(CENTER, CENTER);
      statusRchanged=false;
    } else if (name.equals("STATUS_BAR_L")) {
      textAlign(LEFT, CENTER);
      text(text, position.x-size.x+textSize, position.y-3);
      textAlign(CENTER, CENTER);
      fill(UIcolors[I_TABC1]);
      rect(position.x, position.y-size.y+5, size.x, 5);
      statusLchanged=false;
    } else {
      text(text, position.x, position.y-3);
    }
  }
  void setTextUpdater(StateReturner returner_) {
    returner=returner_;
  }
}

class DropDown extends UIelement {
  int selection;
  String[] text;
  int textSize;
  //runtime
  float realsizeY;
  float realpositionY;
  int direction=1;//down
  boolean opened=false;
  public DropDown( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, int textSize_, int defaultSelection_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    text=new String[0];
    textSize=max(1, textSize_);
    selection=defaultSelection_;
    realpositionY=position.y;
    realsizeY=size.y;
    setDirection();
  }
  private void setDirection() {
    if ((realpositionY+realsizeY/2+realsizeY*text.length)*scale>height) {//height is not scaled
      direction=-1;
    } else {
      direction=1;
    }
  }
  void setItems(String[] text_) {
    text=text_;
    setDirection();
  }
  String getItem() {
    if (selection<0||text.length<=selection)return "- nothing -";
    else return text[selection];
  }
  @Override
    boolean react() {
    if (super.react ()==false)return false;
    if (isMouseOn(position.x, position.y, size.x, size.y)==false&&focus==ID)focus=DEFAULT;//button characteristics
    if (mouseState==AN_RELEASE&&(isMouseOn(position.x, position.y, size.x, size.y)||focus==ID)) {
      if (opened) {
        opened=false;
        position.y=realpositionY;
        size.y=realsizeY;
        float flipMouseY=MouseY;
        if (direction==-1)flipMouseY=realpositionY*2-MouseY;
        int tselection=floor((flipMouseY-realpositionY-realsizeY)/(realsizeY*2));
        if (tselection>0) {
          selection=tselection-1;
        }
        Frames[currentFrame].render();
      } else {
        opened=true;
        position.y=position.y+direction*realsizeY*text.length;
        size.y=realsizeY*(text.length+1);
        render();//extra render
      }
      return true;
    }
    return false;
  }
  @Override
    void render() {
    fill(UIcolors[I_BACKGROUND]);
    rect(position.x, position.y, size.x, size.y);
    strokeWeight(5);
    if (isMouseOn (position.x, position.y, size.x, size.y )) {
      if (mousePressed) {
        fill(brighter(UIcolors [I_FOREGROUND], 40));
        stroke(brighter(UIcolors [I_FOREGROUND], 40));
      } else {
        fill(brighter(UIcolors [I_FOREGROUND], 20));
        stroke(brighter(UIcolors [I_FOREGROUND], 20));
      }
    } else {
      fill(UIcolors[I_FOREGROUND]);
      stroke(UIcolors[I_FOREGROUND]);
    }
    rect(position.x+size.x-realsizeY, realpositionY, realsizeY, realsizeY);
    textSize(textSize);
    noFill();
    rect(position.x, realpositionY, size.x, realsizeY);
    if (opened) {
      int a=1;
      while (a<=text.length) {
        noFill();
        rect(position.x, realpositionY+direction*realsizeY*(a+1), size.x, realsizeY);
        fill(UIcolors[I_FOREGROUND]);
        text(text[a-1], position.x-size.x/2, realpositionY+direction*realsizeY*(a+1));
        a=a+1;
      }
      fill (UIcolors [I_BACKGROUND]);
      triangle(position.x+size.x-realsizeY*3/2, realpositionY-direction*realsizeY/2, position.x+size.x-realsizeY/2, realpositionY-direction*realsizeY/2, position.x+size.x-realsizeY, realpositionY+direction*realsizeY/2);
    } else {
      fill (UIcolors [I_BACKGROUND]);
      triangle(position.x+size.x-realsizeY*3/2, realpositionY+direction*realsizeY/2, position.x+size.x-realsizeY/2, realpositionY+direction*realsizeY/2, position.x+size.x-realsizeY, realpositionY-direction*realsizeY/2);
    }
    fill(UIcolors[I_FOREGROUND]);
    text(getItem(), position.x-size.x/2, realpositionY);
    noStroke();
  }
}


class Slider extends UIelement {
  int VariableType;
  static final int TYPE_SLIDER_INT=0;
  static final int TYPE_SLIDER_FLOAT=1;
  SliderUpdater updater;
  int minI;
  int maxI;
  float minF;
  float maxF;
  //runtime
  int valueI;
  float valueF;
  boolean sliderClicked=false;
  public Slider( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, int min_, int max_, int value_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    VariableType=TYPE_SLIDER_INT;
    minI=min_;
    maxI=max_;
    valueI=value_;
  }
  public Slider( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, float min_, float max_, float value_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    VariableType=TYPE_SLIDER_FLOAT;
    minF=min_;
    maxF=max_;
    valueF=value_;
  }
  void adjust(int value) {
    valueI=max(0, min(maxI, value));
    if (name.equals("I_FRAMESLIDER")&&skip==false) {
      if (UI[textfieldId].disabled==false)UI[textfieldId].render();
    }
  }
  void setUpdater(SliderUpdater updater_) {
    updater=updater_;
  }
  @Override
    boolean react() {
    if (super.react()==false)return false;
    if (focus!=ID)sliderClicked=false;
    if (updater!=null) {
      minF=updater.getMin();
      maxF=updater.getMax();
      valueF=min(maxF, max(minF, updater.getValue()));//this is limit!!!
      render();
    }
    if (((isMousePressed(position.x, position.y, size.x, size.y)||(mousePressed&&sliderClicked)))&&pressed) {
      if (VariableType==TYPE_SLIDER_INT) {
        valueI=minI+floor(min(max(MouseX-position.x+size.x, 0), 2*size.x)*(maxI-minI)/(size.x*2));
      } else if (VariableType==TYPE_SLIDER_FLOAT) {
        valueF=minF+min(max(MouseX-position.x+size.x, 0), 2*size.x)*(maxF-minF)/(size.x*2);
      }
      if (name.equals("I_RESOLUTION")) {
        if (valueF<=0)valueF=1;
        surface.setSize(floor(1420*valueF), floor(920*valueF));
        setSize(floor(1420*valueF), floor(920*valueF));
      } else if (name.equals("I_FRAMESLIDER")) {
        currentLedTime=valueI;
        timeLabel.text=currentLedTime+"/"+maxI;
        int sum=0;
        int a=0;
        valueI=sum;
        currentLedFrame=0;
        while (a<DelayValue.size()) {
          sum=sum+DelayValue.get(a);
          if (currentLedTime<sum) break;
          else valueI=sum;
          currentLedFrame++;
          a=a+1;
        }
        currentLedTime=valueI;
        if (autorun_playing==false||autorun_paused)autorun_backup=currentLedTime;
        if (UI[textfieldId].disabled==false)UI[textfieldId].render();
      }
      if (updater!=null)updater.setValue(valueF);//this is limit!!!
      render();
      focus=ID;
      sliderClicked=true;
    } else if (name.equals("I_RESOLUTION")&&mouseState==AN_RELEASE&&pressed) {
      scale=valueF;
      popMatrix();
      popMatrix();
      pushMatrix();
      scale(scale);
      pushMatrix();
      registerRender();
      sliderClicked=false;
    } else {
      sliderClicked=false;
    }
    return false;
  }
  @Override
    void render() {
    if (skip)return;
    strokeWeight(5);
    stroke(UIcolors[I_BACKGROUND]);
    fill(UIcolors[I_BACKGROUND]);
    rect(position.x, position.y, size.x+3, size.y);
    stroke(UIcolors[I_FOREGROUND]);
    line(position.x-size.x, position.y, position.x+size.x, position.y);
    //line(position.x-size.x, position.y-size.y, position.x-size.x, position.y+size.y);
    //line(position.x+size.x, position.y-size.y, position.x+size.x, position.y+size.y);
    //noStroke();
    if (name.equals("I_FRAMESLIDER")) {
      stroke(brighter(UIcolors[I_FOREGROUND], -10));
      strokeWeight(1);
      //assert currentFrame==getFrameid("F_KEYLED")
      int a=0;
      int sum=0;
      while (a<DelayValue.size()) {
        sum=sum+DelayValue.get(a);
        line(position.x-size.x+(2*size.x)*sum/(maxI-minI), position.y-size.y, position.x-size.x+(2*size.x)*sum/(maxI-minI), position.y+size.y);
        a=a+1;
      }
      strokeWeight(2);
      stroke(0, 255, 0);
      if (startFrom) {
        line(position.x-size.x+(2*size.x)*autorun_backup/(maxI-minI), position.y-size.y, position.x-size.x+(2*size.x)*autorun_backup/(maxI-minI), position.y);
      }
      if (autoStop) {
        line(position.x-size.x+(2*size.x)*autorun_backup/(maxI-minI), position.y, position.x-size.x+(2*size.x)*autorun_backup/(maxI-minI), position.y+size.y);
      }
      noStroke();
      UI[getUIid("KEYLED_PAD")].render();
      UI[getUIid("I_TIME1")].render();
      //render external
      skip=true;
      frameSliderLoop.render();
      skip=false;
    }
    noFill();
    strokeWeight(1);
    stroke(brighter(UIcolors[I_FOREGROUND], 50));
    if (VariableType==TYPE_SLIDER_INT) {
      if (maxI<=minI)rect(position.x-size.x, position.y, 5, size.y);
      else rect(position.x-size.x+(2*size.x)*valueI/(maxI-minI), position.y, 5, size.y);
      line(position.x-size.x+(2*size.x)*(valueI-minI)/(maxI-minI), position.y-size.y, position.x-size.x+(2*size.x)*(valueI-minI)/(maxI-minI), position.y+size.y);
    } else if (VariableType==TYPE_SLIDER_FLOAT) {
      if (maxF<=minF)rect(position.x-size.x, position.y, 5, size.y);
      else rect(position.x-size.x+(2*size.x)*(valueF-minF)/(maxF-minF), position.y, 5, size.y);
      line(position.x-size.x+(2*size.x)*(valueF-minF)/(maxF-minF), position.y-size.y, position.x-size.x+(2*size.x)*(valueF-minF)/(maxF-minF), position.y+size.y);
    }
    noStroke();
  }
}
class DragSlider extends UIelement {//only int
  boolean sliderClicked=false;
  float valueS;
  float valueE;
  boolean bypass=true;
  Slider follow;
  float direction=0;
  public DragSlider( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, int follow_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    valueS=0;
    valueE=0;
    follow=(Slider)UI[follow_];//WARNING!!!
  }
  @Override
    boolean react() {
    int focusBackup=focus;
    if (super.react()==false) {
      focus=focusBackup;
      return false;
    }
    if (((isMousePressedRight(position.x, position.y, size.x, size.y)||(mousePressed&&sliderClicked)))&&pressed) {
      if (mouseState==AN_PRESS) {
        valueS=(min(max(MouseX, position.x-size.x), position.x+size.x)-position.x+size.x)*(follow.maxI-follow.minI)/(size.x*2);
        valueE=valueS;
        direction=0;
      }
      if (direction==0) {
        float mouse=(min(max(MouseX, position.x-size.x), position.x+size.x)-position.x+size.x)*(follow.maxI-follow.minI)/(size.x*2);
        if (mouse!=valueS)direction=mouse-valueS;
        if (abs(direction)<5)direction=0;
      } else if (direction>0) {
        valueE=(min(max(MouseX, position.x-size.x), position.x+size.x)-position.x+size.x)*(follow.maxI-follow.minI)/(size.x*2);
      } else if (direction<0) {
        valueS=(min(max(MouseX, position.x-size.x), position.x+size.x)-position.x+size.x)*(follow.maxI-follow.minI)/(size.x*2);
      }
      if (valueS>=valueE&&direction!=0) {
        if (direction>0)valueE=valueS;
        else if (direction<0)valueS=valueE;
        bypass=true;
      } else {
        bypass=false;
      }
      render();
      if (name.equals("I_FRAMESLIDERLOOP")) {
        UI[textfieldId].render();
      }
      sliderClicked=true;
    } else {
      //direction=0;
      sliderClicked=false;
    }
    focus=focusBackup;
    return false;
  }
  @Override
    void render() {
    if (skip)return;
    if (bypass&&(mousePressed==false||(mousePressed&&mouseButton==LEFT)))return;
    skip=true;
    frameSlider.render();
    skip=false;
    strokeWeight(2);
    stroke(255, 0, 0);
    line(position.x-size.x+(2*size.x)*valueS/(follow.maxI-follow.minI), position.y-size.y, position.x-size.x+(2*size.x)*valueS/(follow.maxI-follow.minI), position.y+size.y);
    stroke(0, 0, 255);
    line(position.x-size.x+(2*size.x)*valueE/(follow.maxI-follow.minI), position.y-size.y, position.x-size.x+(2*size.x)*valueE/(follow.maxI-follow.minI), position.y+size.y);
    noStroke();
  }
}
class TextBox extends UIelement {
  String text="";
  String hint="";
  String title="";
  int value=0;
  int textSize=1;
  boolean numberonly=false;
  //runtime
  int cursor=0;
  int selectionStart=0;
  int selectionLen=0;
  //
  boolean editorClicked=false;
  int clickcursor=0;
  public TextBox( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, String text_, String hint_, int textSize_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    numberonly=false;
    text=text_;
    hint=hint_;
    textSize=max(1, textSize_);
    cursor=text.length();
  }
  public TextBox( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, int value_, String hint_, int textSize_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    numberonly=true;
    value=value_;
    text=str(value);
    hint=hint_;
    textSize=max(1, textSize_);
    cursor=text.length();
  }
  public TextBox( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, String title_, String text_, String hint_, int textSize_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    numberonly=false;
    text=text_;
    hint=hint_;
    title=title_;
    textSize=max(1, textSize_);
    cursor=text.length();
  }
  public TextBox( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, String title_, int value_, String hint_, int textSize_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    numberonly=true;
    value=value_;
    text=str(value);
    hint=hint_;
    title=title_;
    textSize=max(1, textSize_);
    cursor=text.length();
  }
  @Override
    boolean react() {
    boolean isFocused=false;
    if (focus==ID) {
      isFocused=true;
    }
    if (super.react()==false)return false;
    if (isMouseOn(position.x, position.y, size.x, size.y)) {
      if (mousePressed) {
        if (editorClicked) {
          adjustCursor();
          selectionStart=min(cursor, clickcursor);
          selectionLen=max(cursor, clickcursor)-selectionStart;
        } else {
          editorClicked=false;
        }
        if (mouseState==AN_PRESS) {
          focus=ID;
          adjustCursor();
          clickcursor=cursor;
          selectionLen=0;
          editorClicked=true;
        }
      }
    }
    if (ID==focus||(isFocused&&ID!=focus)) {
      render();//extra render
    }
    return false;
  }
  void adjustCursor() {
    cursor=text.length();
    textSize(max(1, textSize));
    while (cursor>0&&position.x-size.x+textSize+textWidth(text.substring(0, cursor))>=MouseX) {
      cursor--;
    }
  }
  @Override
    void render() {
    strokeWeight(5);
    if (isMouseOn (position.x, position.y, size.x, size.y )) {
      if (mousePressed) {
        fill(brighter(UIcolors[I_BACKGROUND], 40));
        stroke(brighter(UIcolors [I_FOREGROUND], 40));
      } else {
        if (ID==focus) {
          fill(brighter(UIcolors[I_BACKGROUND], 20));
          stroke(brighter(UIcolors [I_FOREGROUND], 80));
        } else {
          fill(UIcolors[I_BACKGROUND]);
          stroke(brighter(UIcolors [I_FOREGROUND], 20));
        }
      }
    } else {
      if (ID==focus) {
        fill(brighter(UIcolors[I_BACKGROUND], 20));
        stroke(brighter(UIcolors [I_FOREGROUND], 80));
      } else {
        fill(UIcolors[I_BACKGROUND]);
        stroke(UIcolors[I_FOREGROUND]);
      }
    }
    rect(position.x, position.y, size.x, size.y);
    noStroke();
    textAlign(LEFT, CENTER);
    float offset=0;
    if (title.equals("")==false) {
      textSize(max(1, textSize*3/4));
      fill(UIcolors[I_TABCOLOR]);
      offset=textSize/3;
      text(title+"/ ", position.x-size.x+textSize-5, position.y-textSize*2/3);
    }
    textSize(textSize);
    if (selectionLen>0) {
      fill(UIcolors[I_TEXTBOXSELECTION]);
      String selectionPart=text.substring(selectionStart, selectionStart+selectionLen);
      if (selectionStart==0)rect(position.x-size.x+textSize+textWidth(selectionPart)/2, position.y+offset, textWidth(selectionPart)/2, textSize/2);
      else rect(position.x-size.x+textSize+textWidth(selectionPart)/2+textWidth(text.substring(0, selectionStart)), position.y+offset, textWidth(selectionPart)/2, textSize/2);
    }
    if (text.equals("")) {
      fill(brighter(UIcolors[I_FOREGROUND], -60));
      text(hint, position.x-size.x+textSize, position.y+offset);
    } else {
      fill(UIcolors[I_FOREGROUND]);
      text(text, position.x-size.x+textSize, position.y+offset);
    }
    if (ID==focus)if (frameCount%54<36)text("|", position.x-size.x+textSize+textWidth(text.substring(0, min(text.length(), cursor)))-5, position.y+offset);
    if (name.equals("I_FINDTEXTBOX")) {
      if (((Button)UI[getUIidRev("I_CALCULATE")]).value) {
        if (text.equals("")==false&&patternMatcher.errorFind) {
          stroke(UIcolors[I_TABC2]);
          noFill();
          strokeWeight(2);
          rect(position.x, position.y, size.x, size.y);
          noStroke();
        }
      }
      textAlign(RIGHT, CENTER);
      textSize(textSize*3/4);
      text("("+(findIndex+1)+"/"+findData.size()+")", position.x+size.x-textSize, position.y+offset);
    } else if (name.equals("I_REPLACETEXTBOX")) {
      if (((Button)UI[getUIidRev("I_CALCULATE")]).value) {
        if (text.equals("")==false&&patternMatcher.errorReplace) {
          stroke(UIcolors[I_TABC2]);
          noFill();
          strokeWeight(2);
          rect(position.x, position.y, size.x, size.y);
          noStroke();
        }
      }
    } else if (name.equals("I_BUTTONX")) {
      if (value!=ButtonX) {
        textAlign(RIGHT, CENTER);
        textSize(textSize*4/3);
        text("*", position.x+size.x-textSize, position.y);
      }
    } else if (name.equals("I_BUTTONY")) {
      if (value!=ButtonY) {
        textAlign(RIGHT, CENTER);
        textSize(textSize*4/3);
        text("*", position.x+size.x-textSize, position.y);
      }
    } else if (name.equals("I_CHAIN")) {
      if (value>Chain) {
        textAlign(RIGHT, CENTER);
        textSize(textSize*4/3);
        text("*", position.x+size.x-textSize, position.y);
      }
    }
    textAlign(CENTER, CENTER);
  }
  void keyTyped() {
    boolean selectAll=false;
    boolean copy=false;
    boolean cut=false;
    boolean paste=false;
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
        }
      }
      a=a+1;
    }
    if (selectAll) {//Ctrl-A
      if (text.length()>0) {
        selectionStart=0;
        selectionLen=text.length();
        cursor=text.length();
      }
    }
    if (copy) {//Ctrl-C
      if (selectionLen>0)textTransfer.setClipboardContents(text.substring(selectionStart, selectionStart+selectionLen));
    }
    if (cut) {//Ctrl-X
      if (selectionLen>0) {
        textTransfer.setClipboardContents(text.substring(selectionStart, selectionStart+selectionLen));
        text=text.substring(0, selectionStart)+text.substring(min(selectionStart+selectionLen, text.length()), text.length());
        cursor=selectionStart;
      }
      selectionLen=0;
    }
    if (paste) {//Ctrl-V
      if (selectionLen>0) {
        text=text.substring(0, selectionStart)+text.substring(min(selectionStart+selectionLen, text.length()), text.length());
        cursor=selectionStart;
      } 
      String pasteString1=textTransfer.getClipboardContents().replace("\n", "").replace("\r", "").replace("\t", "  ");
      if (pasteString1.length()>0) {
        String pasteString2;
        if (numberonly) {
          a=0;
          if (cursor==0&&pasteString1.charAt(0)=='-') {
            pasteString2="-";
            a=1;
          } else pasteString2="";
          while (a<pasteString1.length()) {
            if ('0'<=pasteString1.charAt(a)&&pasteString1.charAt(a)<='9') {
              pasteString2=pasteString2+pasteString1.charAt(a);
            }
            a=a+1;
          }
        } else {
          pasteString2=pasteString1;
        }
        if (cursor==text.length())text=text+pasteString2;
        else text=text.substring(0, cursor)+pasteString2+text.substring(min(cursor, text.length()-1), text.length());
        cursor=min(text.length(), cursor+pasteString2.length());
      }
      selectionLen=0;
    }
    if (key==BACKSPACE) {
      if (text.length()>0) {
        if (selectionLen>0) {
          text=text.substring(0, selectionStart)+text.substring(min(selectionStart+selectionLen, text.length()), text.length());
          cursor=selectionStart;
        } else if (cursor>0) {
          text=text.substring(0, cursor-1)+text.substring(min(cursor, text.length()), text.length());
          cursor--;
        }
      }
      selectionLen=0;
    } else if (ctrlPressed&&key==127) {
      if (text.length()>0) {
        if (selectionLen>0) {
          text=text.substring(0, selectionStart)+text.substring(min(selectionStart+selectionLen, text.length()), text.length());
          cursor=selectionStart;
        } else if (cursor>0) {
          if (text.length()>0&&cursor>0) {
            boolean isSpace=false;
            if (text.charAt(cursor-1)==' '||text.charAt(cursor-1)=='\t'||text.charAt(cursor-1)=='\n'||text.charAt(cursor-1)=='\r')isSpace=true;
            while (text.length()>0&&cursor>0) {
              if (((isSpace&&(text.charAt(cursor-1)==' '||text.charAt(cursor-1)=='\t'||text.charAt(cursor-1)=='\n'||text.charAt(cursor-1)=='\r')==false))||(isSpace==false&&(text.charAt(cursor-1)==' '||text.charAt(cursor-1)=='\t'||text.charAt(cursor-1)=='\n'||text.charAt(cursor-1)=='\r')))break;
              text=text.substring(0, cursor-1)+text.substring(min(cursor, text.length()), text.length());
              cursor--;
            }
          }
        }
      }
      selectionLen=0;
    } else if (key==DELETE) {
      if (text.length()>0) {
        if (selectionLen>0) {
          text=text.substring(0, selectionStart)+text.substring(min(selectionStart+selectionLen, text.length()), text.length());
          cursor=selectionStart;
        } else if (cursor<text.length()) {
          if (ctrlPressed) {
            if (text.length()>0&&cursor<text.length()) {
              boolean isSpace=false;
              if (text.charAt(cursor)==' '||text.charAt(cursor)=='\t'||text.charAt(cursor)=='\n'||text.charAt(cursor)=='\r')isSpace=true;
              while (text.length()>0&&cursor<text.length()) {
                if (((isSpace&&(text.charAt(cursor)==' '||text.charAt(cursor)=='\t'||text.charAt(cursor)=='\n'||text.charAt(cursor)=='\r')==false))||(isSpace==false&&(text.charAt(cursor)==' '||text.charAt(cursor)=='\t'||text.charAt(cursor)=='\n'||text.charAt(cursor)=='\r')))break;
                text=text.substring(0, cursor)+text.substring(min(cursor+1, text.length()), text.length());
              }
            }
          } else {
            cursor=min(text.length(), max(0, cursor));
            if (text.length()>0&&cursor<text.length()) {
              text=text.substring(0, cursor)+text.substring(min(cursor+1, text.length()), text.length());
            }
          }
        }
      }
      selectionLen=0;
    } else if (key=='\n'||key=='\r') {//textBox characteristics
    } else if (key=='\t') {
      if (selectionLen>0) {
        text=text.substring(0, selectionStart)+text.substring(min(selectionStart+selectionLen, text.length()), text.length());
        cursor=selectionStart;
      } 
      if (numberonly==false) {
        if (cursor==text.length())text=text+"  ";
        else text=text.substring(0, cursor)+"  "+text.substring(min(cursor, text.length()-1), text.length());
        cursor=cursor+2;
      }
      selectionLen=0;
    } else if (ctrlPressed==false&&altPressed==false) {
      cursor=max(0, min(text.length(), cursor));
      if (selectionLen>0) {
        text=text.substring(0, selectionStart)+text.substring(min(selectionStart+selectionLen, text.length()), text.length());
        cursor=selectionStart;
      } 
      if (numberonly==false||(numberonly&&(('0'<=key&&key<='9')||(key=='-'&&cursor==0)))) {
        text=text.substring(0, cursor)+key+text.substring(cursor, text.length());
        cursor++;
      }
      selectionLen=0;
    }
    if (numberonly) {
      if (text.equals(""))value=0;
      else if (isInt(text)) value=int(text);
    }
    if (name.equals("I_HTMLR")||name.equals("I_HTMLG")||name.equals("I_HTMLB")) {
      value=min(255, max(0, value));
      ((ColorPicker)UI[htmlselId]).updateFromTextBoxRGB();
      ((ColorPicker)UI[htmlselId]).updateColor();
    } else if (name.equals("I_HTMLH")||name.equals("I_HTMLS")||name.equals("I_HTMLV")) {
      value=min(255, max(0, value));
      ((ColorPicker)UI[htmlselId]).updateFromTextBoxHSB();
      ((ColorPicker)UI[htmlselId]).updateColor();
    } else if (name.equals("PC_HTMLR")||name.equals("PC_HTMLG")||name.equals("PC_HTMLB")) {
      value=min(255, max(0, value));
      int id=getUIidRev("PC_HTMLSEL");
      ((ColorPicker)UI[id]).updateFromTextBoxRGB();
      ((ColorPicker)UI[id]).updateColor();
    } else if (name.equals("PC_HTMLH")||name.equals("PC_HTMLS")||name.equals("PC_HTMLV")) {
      value=min(255, max(0, value));
      int id=getUIidRev("PC_HTMLSEL");
      ((ColorPicker)UI[id]).updateFromTextBoxHSB();
      ((ColorPicker)UI[id]).updateColor();
    } else if (name.equals("I_AUTOSAVETIME")) {
      value=max(10, value);
    } else if (name.equals("I_DESCRIPTIONTIME")||name.equals("I_BUTTONX")) {
      value=max(1, value);
    } else if (name.equals("I_CHAIN")) {
      value=min(max(1, value), 8);
    } else if (name.equals("I_TEXTSIZE")) {
      value=max(1, min(50, value));
    } else if (name.equals("I_FINDTEXTBOX")) {
      patternMatcher.findUpdated=false;
      patternMatcher.registerFind(text, ((Button)UI[getUIidRev("I_CALCULATE")]).value);
      findData=patternMatcher.findAll(Lines.toString());//WARNING!!!
    } else if (name.equals("I_REPLACETEXTBOX")) {
      patternMatcher.registerReplace(text, ((Button)UI[getUIidRev("I_CALCULATE")]).value);
    } else if (name.equals("KS_SOUNDMULTI")) {
      KS.get(ksChain)[ksX][ksY].multiSound=min(max(1, value), KS.get(ksChain)[ksX][ksY].ksSound.size())-1;
    } else if (name.equals("KS_LEDMULTI")) {
      KS.get(ksChain)[ksX][ksY].multiLed=min(max(1, value), KS.get(ksChain)[ksX][ksY].ksLedFile.size())-1;
      KS.get(ksChain)[ksX][ksY].multiLedBackup=KS.get(ksChain)[ksX][ksY].multiLed;
    } else if (name.equals("KS_LOOP")) {
      if (soundLoopEdit) {
        if (((ScrollList)UI[getUIid("I_SOUNDVIEW")]).selected==-1)return;
        KS.get(ksChain)[ksX][ksY].ksSoundLoop.set(((ScrollList)UI[getUIid("I_SOUNDVIEW")]).selected, value);
      } else {
        if (((ScrollList)UI[getUIid("I_LEDVIEW")]).selected==-1)return;
        KS.get(ksChain)[ksX][ksY].ksLedLoop.set(((ScrollList)UI[getUIid("I_LEDVIEW")]).selected, value);
      }
    }
    //render();
  }
  void cursorLeft() {
    if (shiftPressed) {
      if (ctrlPressed) {
        if (text.length()>0&&cursor>0) {
          boolean isSpace=false;
          if (text.charAt(cursor-1)==' '||text.charAt(cursor-1)=='\t'||text.charAt(cursor-1)=='\n'||text.charAt(cursor-1)=='\r')isSpace=true;
          if (selectionLen==0)selectionStart=cursor;
          while (text.length()>0&&cursor>0) {
            if (((isSpace&&(text.charAt(cursor-1)==' '||text.charAt(cursor-1)=='\t'||text.charAt(cursor-1)=='\n'||text.charAt(cursor-1)=='\r')==false))||(isSpace==false&&(text.charAt(cursor-1)==' '||text.charAt(cursor-1)=='\t'||text.charAt(cursor-1)=='\n'||text.charAt(cursor-1)=='\r')))break;
            cursor=cursor-1;
            if (cursor==selectionStart) {
              selectionLen--;
            } else if (cursor<=selectionStart) {
              selectionLen++;
              selectionStart--;
            } else {
              selectionLen--;
            }
          }
        }
      } else {
        if (text.length()>0&&cursor>0) {
          if (selectionLen==0)selectionStart=cursor;
          cursor=cursor-1;
          if (cursor==selectionStart) {
            selectionLen--;
          } else if (cursor<=selectionStart) {
            selectionLen++;
            selectionStart--;
          } else {
            selectionLen--;
          }
        }
      }
    } else {
      if (ctrlPressed) {
        if (text.length()>0&&cursor>0) {
          boolean isSpace=false;
          if (text.charAt(cursor-1)==' '||text.charAt(cursor-1)=='\t'||text.charAt(cursor-1)=='\n'||text.charAt(cursor-1)=='\r')isSpace=true;
          selectionLen=0;
          while (text.length()>0&&cursor>0) {
            if (((isSpace&&(text.charAt(cursor-1)==' '||text.charAt(cursor-1)=='\t'||text.charAt(cursor-1)=='\n'||text.charAt(cursor-1)=='\r')==false))||(isSpace==false&&(text.charAt(cursor-1)==' '||text.charAt(cursor-1)=='\t'||text.charAt(cursor-1)=='\n'||text.charAt(cursor-1)=='\r')))break;
            cursor=cursor-1;
          }
        }
      } else {
        if (text.length()>0&&cursor>0) {
          selectionLen=0;
          cursor=cursor-1;
        }
      }
    }
    //render();
  }
  void cursorRight() {
    if (shiftPressed) {
      if (ctrlPressed) {
        if (text.length()>0&&cursor<text.length()) {
          boolean isSpace=false;
          if (text.charAt(cursor)==' '||text.charAt(cursor)=='\t'||text.charAt(cursor)=='\n'||text.charAt(cursor)=='\r')isSpace=true;
          if (selectionLen==0)selectionStart=cursor;
          while (text.length()>0&&cursor<text.length()) {
            if (((isSpace&&(text.charAt(cursor)==' '||text.charAt(cursor)=='\t'||text.charAt(cursor)=='\n'||text.charAt(cursor)=='\r')==false))||(isSpace==false&&(text.charAt(cursor)==' '||text.charAt(cursor)=='\t'||text.charAt(cursor)=='\n'||text.charAt(cursor)=='\r')))break;
            cursor=cursor+1;
            if (cursor==selectionStart+selectionLen) {
              selectionLen--;
            } else if (cursor>selectionStart+selectionLen) {
              selectionLen++;
            } else {
              selectionLen--;
              selectionStart++;
            }
          }
        }
      } else {
        if (text.length()>0&&cursor<text.length()) {
          if (selectionLen==0)selectionStart=cursor;
          cursor=cursor+1;
          if (cursor==selectionStart+selectionLen) {
            selectionLen--;
          } else if (cursor>selectionStart+selectionLen) {
            selectionLen++;
          } else {
            selectionLen--;
            selectionStart++;
          }
        }
      }
    } else {
      if (ctrlPressed) {
        if (text.length()>0&&cursor<text.length()) {
          boolean isSpace=false;
          if (text.charAt(cursor)==' '||text.charAt(cursor)=='\t'||text.charAt(cursor)=='\n'||text.charAt(cursor)=='\r')isSpace=true;
          selectionLen=0;
          while (text.length()>0&&cursor<text.length()) {
            if (((isSpace&&(text.charAt(cursor)==' '||text.charAt(cursor)=='\t'||text.charAt(cursor)=='\n'||text.charAt(cursor)=='\r')==false))||(isSpace==false&&(text.charAt(cursor)==' '||text.charAt(cursor)=='\t'||text.charAt(cursor)=='\n'||text.charAt(cursor)=='\r')))break;
            cursor=cursor+1;
          }
        }
      } else {
        if (text.length()>0&&cursor<text.length()) {
          selectionLen=0;
          cursor=cursor+1;
        }
      }
    }
    //render();
  }
}
class ScrollList extends UIelement {
  static final int ITEM_HEIGHT=50;
  static final int SLIDER_HALFWIDTH=10;
  String[] View;
  public boolean dragging=false;
  public int selected=-1;
  float sliderPos=0;
  float sliderLength;
  boolean sliderClicked=false;
  boolean itemClicked=false;
  int textSize=1;
  boolean needsScreenUpdate=false;
  boolean reorderable=true;
  int reordering=-1;//0 to size
  int adding=-1;
  public ScrollList(int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, int textSize_, boolean reorderable_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    View=new String[0];
    sliderLength=size.y*size.y/max(size.y, max(View.length, size.y*2/ITEM_HEIGHT)*ITEM_HEIGHT/2);//half
    sliderPos=position.y-size.y+sliderLength;//+min(max(-position.y, ), size.y-sliderLength);
    textSize=max(1, textSize_);
    reorderable=reorderable_;
  }
  void setItems(String[] View_) {
    View=View_;
    setSelect(min(selected, View.length-1));
    sliderPos-=sliderLength;
    sliderLength=size.y*size.y/max(size.y, max(View.length, size.y*2/ITEM_HEIGHT)*ITEM_HEIGHT/2);//half
    sliderPos=position.y+min(max(sliderPos+sliderLength-position.y, -size.y+sliderLength), size.y-sliderLength);
  }
  void setSelect(int sel) {
    selected=sel;
    if (name.equals("I_SOUNDVIEW")) {
      soundLoopEdit=true;
      if (selected==-1) {
        UI[getUIidRev("KS_LOOP")].disabled=true;
        UI[getUIidRev("KS_LOOP")].registerRender=false;
        registerRender();//inefficient!
      } else {
        if (selected>=KS.get(ksChain)[ksX][ksY].ksSoundLoop.size())return;
        ((TextBox)UI[getUIidRev("KS_LOOP")]).value=KS.get(ksChain)[ksX][ksY].ksSoundLoop.get(selected);
        ((TextBox)UI[getUIidRev("KS_LOOP")]).text=""+((TextBox)UI[getUIidRev("KS_LOOP")]).value;
        UI[getUIidRev("KS_LOOP")].disabled=false;
        UI[getUIidRev("KS_LOOP")].registerRender=true;
      }
    } else if (name.equals("I_LEDVIEW")) {
      soundLoopEdit=false;
      if (selected==-1) {
        UI[getUIidRev("KS_LOOP")].disabled=true;
        UI[getUIidRev("KS_LOOP")].registerRender=false;
        registerRender();//inefficient!
      } else {
        if (selected>=KS.get(ksChain)[ksX][ksY].ksLedLoop.size())return;
        ((TextBox)UI[getUIidRev("KS_LOOP")]).value=KS.get(ksChain)[ksX][ksY].ksLedLoop.get(selected);
        ((TextBox)UI[getUIidRev("KS_LOOP")]).text=""+((TextBox)UI[getUIidRev("KS_LOOP")]).value;
        UI[getUIidRev("KS_LOOP")].disabled=false;
        UI[getUIidRev("KS_LOOP")].registerRender=true;
      }
    } else if (name.equals("UN_LIST")) {
      uncloud_select(selected);
    }
  }
  void addItem(String item) {
    String[] temp=View;
    View=new String[temp.length+1];
    boolean dragging=false;
    int a=0;
    while (a<temp.length) {
      View[a]=temp[a];
      a=a+1;
    }
    View[View.length-1]=item;
    temp=null;
    sliderPos-=sliderLength;
    sliderLength=size.y*size.y/max(size.y, max(View.length, size.y*2/ITEM_HEIGHT)*ITEM_HEIGHT/2);//half
    sliderPos=position.y+min(max(sliderPos+sliderLength-position.y, -size.y+sliderLength), size.y-sliderLength);
  }
  void addItem(int index, String item) {
    String[] temp=View;
    View=new String[temp.length+1];
    int a=0;
    while (a<temp.length+1) {
      if (a<index) View[a]=temp[a];
      else if (a==index) View[a]=item;
      else if (a>index) View[a]=temp[a-1];
      a=a+1;
    }
    temp=null;
    sliderPos-=sliderLength;
    sliderLength=size.y*size.y/max(size.y, max(View.length, size.y*2/ITEM_HEIGHT)*ITEM_HEIGHT/2);//half
    sliderPos=position.y+min(max(sliderPos+sliderLength-position.y, -size.y+sliderLength), size.y-sliderLength);
  }
  String getSelection() {
    if (selected==-1)return null;
    return View[selected];
  }
  void removeItem(int index) {
    if (View.length==0)return;
    String[] temp=View;
    View=new String[temp.length-1];
    int a=0;
    while (a<temp.length) {
      if (a<index) View[a]=temp[a];
      else if (a>index) View[a-1]=temp[a];
      a=a+1;
    }
    temp=null;
    sliderPos-=sliderLength;
    sliderLength=size.y*size.y/max(size.y, max(View.length, size.y*2/ITEM_HEIGHT)*ITEM_HEIGHT/2);//half
    sliderPos=position.y+min(max(sliderPos+sliderLength-position.y, -size.y+sliderLength), size.y-sliderLength);
  }
  void mouseWheel(MouseEvent e) {
    if (isMouseOn(position.x, position.y, size.x, size.y)) {
      float total=size.y*2-sliderLength*2;
      sliderPos=position.y+min(max(-size.y+sliderLength, sliderPos-position.y+e.getCount()*40/(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2))), size.y-sliderLength);
    }
  }
  @Override
    boolean react() {
    needsScreenUpdate=false;
    if (super.react()==false) {
      dragging=false;
      return false;
    }
    if (isMouseOn(position.x, position.y, size.x, size.y)) {
      if (mouseState==AN_PRESS) {
        focus=ID;
        if ((isMousePressed(position.x+size.x-SLIDER_HALFWIDTH, position.y, SLIDER_HALFWIDTH, size.y)||(sliderClicked/*&&mousePressed&&mouseButton==RIGHT*/))) {
          sliderClicked=true;
        } else {//isMousePressed(position.x-SLIDER_HALFWIDTH, position.y, size.x-SLIDER_HALFWIDTH, size.y)
          setSelect((int)(MouseY-(position.y-size.y-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2))))/ITEM_HEIGHT);
          if (selected<0||selected>=View.length)setSelect(-1);
          if (selected!=-1) {
            itemClicked=true;
            if (keyInterval<DOUBLE_CLICK&&doubleClicked==0&&doubleClickDist<10) {//double click (10 hardcoded!!)
              doubleClicked=1;
              if (name.equals("I_LEDVIEW")) {
                if (mouseButton==RIGHT) {
                  skip=true;
                  focus=DEFAULT;
                  resetFocus();
                  skip=false;
                  Frames[getFrameid("F_KEYLED")].prepare();
                  String filename=getSelection();
                  try {
                    analyzer.loadKeyLedGlobal(filename);
                    title_filename=filename;
                  }
                  catch(Exception e) {
                    displayLogError(e);
                  }
                  title_edited="";
                  surface.setTitle(title_filename+title_edited+title_suffix);
                } else {
                  KS.get(ksChain)[ksX][ksY].autorun_startLedIndex(selected);
                }
              } else if (name.equals("I_SOUNDVIEW")) {
                KS.get(ksChain)[ksX][ksY].autorun_startSoundIndex(selected);
              } else if (name.equals("I_FILEVIEW1")) {
                if (fileList[selected].isDirectory())setItems(listFilePaths_related(fileList[selected].getAbsolutePath()));
                else if (isSoundFile(fileList[selected])) {
                  UI[getUIid("MP3_TIME")].disabled=true;
                  //from converter play button
                  if (converter.converterPlayer.fileLoaded)SampleManager.removeSample(converter.converterPlayer.sample);
                  converter.converterPlayer.load(fileList[selected].getAbsolutePath().replace("\\", "/"));
                  converter.converterPlayer.setValue(0);
                  if (converter.converterPlayer.fileLoaded) {
                    converter.converterPlayer.loop(false);
                    converter.converterPlayer.play();
                  }
                  //
                }
              } else if (name.equals("I_SHORTCUTS")) {
                skip=true;
                focus=DEFAULT;
                resetFocus();
                skip=false;
                tempShortcut.ID=selected+1;//this can be warning
                tempShortcut.ctrl=Shortcuts[tempShortcut.ID].ctrl;
                tempShortcut.shift=Shortcuts[tempShortcut.ID].shift;
                tempShortcut.alt=Shortcuts[tempShortcut.ID].alt;
                tempShortcut.keyn=Shortcuts[tempShortcut.ID].keyn;
                tempShortcut.keyCoden=Shortcuts[tempShortcut.ID].keyCoden;
                ((Label)UI[getUIidRev("KEYEDIT_INPUT")]).text=Shortcuts[tempShortcut.ID].name+"\n\n"+tempShortcut.toString();
                render();
                Frames[getFrameid("F_KEYEDIT")].prepare(currentFrame);
                return false;//WARNING!!!
              } else if (name.equals("I_UICOLORS")) {
                skip=true;
                focus=DEFAULT;
                resetFocus();
                skip=false;
                tempColor=selected+1;
                ColorPicker pick=((ColorPicker)UI[getUIidRev("PC_HTMLSEL")]);
                pick.skip=true;
                pick.setColor(UIcolors[tempColor]);
                pick.skip=false;
                Frames[getFrameid("F_PICKCOLOR")].prepare(currentFrame);
                return false;//WARNING!!!
              } else if (name.equals("MP3_INPUT")) {
                removeItem(selected);
              }
            }
          }
        }
      } else if (mouseState==AN_PRESSED) {
        focus=ID;
        if (reorderable&&selected!=-1&&itemClicked) {
          reordering=(int)(MouseY-(position.y-size.y-ITEM_HEIGHT/2-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2))))/ITEM_HEIGHT;
          if (selected==reordering||selected+1==reordering||reordering<0||reordering>View.length)reordering=-1;
        } else if (draggedListId!=-1) {
          //update drag an drop thing in here(cannot occur in same time with reordering)
          if (((ScrollList)UI[draggedListId]).dragging&&((ScrollList)UI[draggedListId]).selected!=-1&&((ScrollList)UI[draggedListId]).itemClicked) {
            adding=(int)(MouseY-(position.y-size.y-ITEM_HEIGHT/2-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2))))/ITEM_HEIGHT;
            if (adding<0)adding=-1;
            if (adding>View.length)adding=View.length;
          }
        }
      } else if (mouseState==AN_RELEASE) {
        if (reordering!=-1) {
          String temp=View[selected];
          if (selected<reordering) {
            reordering--;
            int a=selected;
            while (a<reordering) {
              if (name.equals("I_LEDVIEW")) {
                KS.get(ksChain)[ksX][ksY].reorderLed(a, a+1);
                title_edited="*";
                surface.setTitle(title_filename+title_edited+title_suffix);
              } else if (name.equals("I_SOUNDVIEW")) {
                KS.get(ksChain)[ksX][ksY].reorderSound(a, a+1);
                title_edited="*";
                surface.setTitle(title_filename+title_edited+title_suffix);
              } else {
                View[a]=View[a+1];
              }
              a=a+1;
            }
            View[reordering]=temp;
          } else {
            int a=selected;
            while (a>reordering) {
              if (name.equals("I_LEDVIEW")) {
                KS.get(ksChain)[ksX][ksY].reorderLed(a, a-1);
                title_edited="*";
                surface.setTitle(title_filename+title_edited+title_suffix);
              } else if (name.equals("I_SOUNDVIEW")) {
                KS.get(ksChain)[ksX][ksY].reorderSound(a, a-1);
                title_edited="*";
                surface.setTitle(title_filename+title_edited+title_suffix);
              } else {
                View[a]=View[a-1];
              }
              a=a-1;
            }
            View[reordering]=temp;
          }
          if (name.equals("I_LEDVIEW")) {
            setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
          } else if (name.equals("I_SOUNDVIEW")) {
            setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
          }
        } else if (draggedListId!=-1) {
          //update drag an drop thing in here(cannot occur in same time with reordering)
          if (((ScrollList)UI[draggedListId]).dragging) {
            //adding=(int)(MouseY-(position.y-size.y-ITEM_HEIGHT/2-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2))))/ITEM_HEIGHT;
            if (adding!=-1) {
              if (name.equals("I_LEDVIEW")&&UI[draggedListId].name.equals("I_FILEVIEW1")) {
                if (fileList[((ScrollList)UI[draggedListId]).selected].isDirectory()==false) {
                  if (isSoundFile(fileList[((ScrollList)UI[draggedListId]).selected])==false) {
                    KS.get(ksChain)[ksX][ksY].loadLed(adding, ((ScrollList)UI[draggedListId]).View[((ScrollList)UI[draggedListId]).selected]);
                    setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
                    title_edited="*";
                    surface.setTitle(title_filename+title_edited+title_suffix);
                    UI[getUIid("KEYSOUND_PAD")].render();
                  }
                }
              } else if (name.equals("I_SOUNDVIEW")&&UI[draggedListId].name.equals("I_FILEVIEW1")) {
                if (fileList[((ScrollList)UI[draggedListId]).selected].isDirectory()==false) {
                  if (isSoundFile(fileList[((ScrollList)UI[draggedListId]).selected])) {
                    KS.get(ksChain)[ksX][ksY].loadSound(adding, ((ScrollList)UI[draggedListId]).View[((ScrollList)UI[draggedListId]).selected]);
                    setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
                    title_edited="*";
                    surface.setTitle(title_filename+title_edited+title_suffix);
                    UI[getUIid("KEYSOUND_PAD")].render();
                  }
                }
              } else if (name.equals("I_FILEVIEW1")&&UI[draggedListId].name.equals("I_LEDVIEW")) {
                KS.get(ksChain)[ksX][ksY].removeLed(((ScrollList)UI[draggedListId]).selected);
                ((ScrollList)UI[draggedListId]).setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
                ((ScrollList)UI[draggedListId]).dragging=false;
                dragging=false;
                title_edited="*";
                surface.setTitle(title_filename+title_edited+title_suffix);
                UI[draggedListId].render();
                UI[getUIid("KEYSOUND_PAD")].render();
              } else if (name.equals("I_FILEVIEW1")&&UI[draggedListId].name.equals("I_SOUNDVIEW")) {
                KS.get(ksChain)[ksX][ksY].removeSound(((ScrollList)UI[draggedListId]).selected);
                ((ScrollList)UI[draggedListId]).setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
                ((ScrollList)UI[draggedListId]).dragging=false;
                title_edited="*";
                surface.setTitle(title_filename+title_edited+title_suffix);
                UI[draggedListId].render();
                UI[getUIid("KEYSOUND_PAD")].render();
              }
              draggedListId=-1;
            }
          }
        }
        sliderClicked=false;
        itemClicked=false;
        reordering=-1;
        adding=-1;
      } else {
        sliderClicked=false;
        itemClicked=false;
        reordering=-1;
        adding=-1;
      }
      if (skipRendering==false)render();
    } else {
      reordering=-1;
      if (mouseState==AN_PRESSED||mouseState==AN_RELEASE) {
        if (pressed&&sliderClicked==false&&dragging==false) {
          draggedListId=ID;
          dragging=true;
        }
      } else {
        if (dragging&&selected!=-1) {
          Frames[currentFrame].render();
          skipRendering=true;
          dragging=false;
        }
        itemClicked=false;
        sliderClicked=false;
      }
    }
    if (sliderClicked) {
      sliderLength=size.y*size.y/max(size.y, max(View.length, size.y*2/ITEM_HEIGHT)*ITEM_HEIGHT/2);//half
      sliderPos=position.y+min(max(MouseY-position.y, -size.y+sliderLength), size.y-sliderLength);
      if (skipRendering==false)render();
    }
    if (dragging&&selected!=-1) {
      Frames[currentFrame].render();
      skipRendering=true;
      if (isMouseOn(position.x, position.y, size.x, size.y)==false) {//ui code in update()!!!
        textFont(fontRegular);
        textSize(15);
        fill(255, 200);
        int len=floor(4+textWidth(View[selected]));
        rect(MouseX, MouseY, len/2, 15);
        fill(0);
        text(View[selected], MouseX, MouseY);
        textFont(fontBold);
      }
    }
    if (needsScreenUpdate) {
      disableDescription();
    }
    return false;
  }
  @Override
    void render() {
    textFont(fontRegular);
    textSize(25);
    textAlign(LEFT, CENTER);
    fill(UIcolors[I_BACKGROUND]);
    stroke(UIcolors[I_BACKGROUND]);
    strokeWeight(15);
    rect(position.x, position.y, size.x, size.y);//first
    stroke(UIcolors[I_FOREGROUND]);
    strokeWeight(2);
    textSize(textSize);
    boolean uicolors=false;
    if (name.equals("I_UICOLORS"))uicolors=true;
    boolean mouseon=isMouseOn(position.x-SLIDER_HALFWIDTH, position.y, size.x-SLIDER_HALFWIDTH, size.y);
    boolean mousepoint=false;
    int a=0;
    while (a<View.length) {
      float tempY=position.y-size.y+ITEM_HEIGHT*a+ITEM_HEIGHT/2-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2));
      tempY=tempY-min(ITEM_HEIGHT/4, (tempY-position.y+size.y)/2)+ITEM_HEIGHT/4;
      tempY=tempY+min(ITEM_HEIGHT/4, (position.y+size.y-tempY)/2)-ITEM_HEIGHT/4;
      float tempSY= min(min(ITEM_HEIGHT/2, (tempY-position.y+size.y)), (position.y+size.y-tempY));
      if (position.y-size.y<tempY+tempSY-2&&tempY-tempSY+2<position.y+size.y&&tempSY>0) {
        if (mouseon&&tempY-tempSY<MouseY&&MouseY<tempY+tempSY&&focus==ID) {
          mousepoint=true;
          if (description.content.equals(View[a])==false) {
            needsScreenUpdate=true;
            firstOn=0;
            description.content=View[a];
          }
          fill(brighter(UIcolors[I_BACKGROUND], -max(0, -(tempSY-ITEM_HEIGHT/2))*2+30)) ;
        } else {
          fill(brighter(UIcolors[I_BACKGROUND], -max(0, -(tempSY-ITEM_HEIGHT/2))*2));
        }
        if (a==selected) {
          fill(brighter(UIcolors[I_BACKGROUND], -max(0, -(tempSY-ITEM_HEIGHT/2))*2+60));
        }
        rect(position.x-SLIDER_HALFWIDTH, tempY, size.x-SLIDER_HALFWIDTH, tempSY);
      }
      if (position.y-size.y<tempY+tempSY-15&&tempY-tempSY+15<position.y+size.y&&tempSY>0) {
        fill(brighter(UIcolors[I_FOREGROUND], -max(0, -(tempSY-ITEM_HEIGHT/2))*7));
        text(displayText(a), position.x-size.x-SLIDER_HALFWIDTH+25, tempY-3);
        if (uicolors) {//WARNING?
          fill(UIcolors[a+1]);
          rect(position.x+size.x-SLIDER_HALFWIDTH*2-33, tempY, 25, tempSY-8);
        }
      }
      a=a+1;
    }
    if (mousepoint==false)description.content="";
    textAlign(CENTER, CENTER);
    color fillcolor=UIcolors[I_BACKGROUND];
    if (isMouseOn (position.x, position.y, size.x, size.y)&&mousePressed) {
      fillcolor=(brighter(UIcolors[I_BACKGROUND], 40));
      stroke(brighter(UIcolors [I_FOREGROUND], 40));
    } else {
      if (ID==focus) {
        fillcolor=(brighter(UIcolors[I_BACKGROUND], 20));
        stroke(brighter(UIcolors [I_FOREGROUND], 80));
      } else {
        stroke(UIcolors[I_FOREGROUND]);
      }
    }
    noFill();
    strokeWeight(5);
    rect(position.x, position.y, size.x, size.y);//second
    strokeWeight(3);
    fill(UIcolors[I_BACKGROUND]);
    rect(position.x+size.x-SLIDER_HALFWIDTH, position.y, SLIDER_HALFWIDTH, size.y);//slider holder
    fill(fillcolor);
    rect(position.x+size.x-SLIDER_HALFWIDTH, sliderPos, SLIDER_HALFWIDTH-2, max(sliderLength-2, 2));
    if (reordering!=-1) {
      float tempY=position.y-size.y+ITEM_HEIGHT*reordering-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2));
      strokeWeight(1);
      noFill();
      rect(position.x-SLIDER_HALFWIDTH, tempY, (size.x-SLIDER_HALFWIDTH)-15, 5);
    } else if (adding!=-1) {
      float tempY=position.y-size.y+ITEM_HEIGHT*adding-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2));
      strokeWeight(1);
      noFill();
      rect(position.x-SLIDER_HALFWIDTH, tempY, (size.x-SLIDER_HALFWIDTH)-15, 5);
    }
    textFont(fontBold);
    noStroke();
  }
  String displayText(int index) {
    if (name.equals("I_FILEVIEW1")) {
      if (fileList[index].isDirectory())return "/"+getFileName(View[index]);
      else return getFileName(View[index]);
    } else if (name.equals("I_SOUNDVIEW")||name.equals("I_LEDVIEW")) {
      return getFileName(View[index]);
    }
    return View[index];
  }
}
class TextEditor extends UIelement {//only render and add text. this class not do data management.
  int textSize=1;
  static final int SLIDER_HALFWIDTH=10;
  float sliderPos=0;
  float sliderLength;
  boolean sliderClicked=false;
  boolean editorClicked=false;
  //temp vars
  int clickline=0;
  int clickcursor=0;
  //hard coded data(set in UI_setup())
  float originalY;
  float originalSY;
  float shortenY;
  float shortenSY;
  //
  int errorpsize=0;
  public TextEditor( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    sliderLength=size.y*size.y/max(size.y, max(Lines.lines()+10, size.y*2/textSize)*textSize/2);//half
    sliderPos=position.y+min(max(0-position.y, -size.y+sliderLength), size.y-sliderLength);
  }
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
        adjustCursor();
        Lines.selStartLine=Lines.line;
        Lines.selStartPoint=Lines.cursor;
        clickline=Lines.line;
        clickcursor=Lines.cursor;
        Lines.resetSelection();
        editorClicked=true;
      }
    }
    if (ID==focus||(isFocused&&ID!=focus)) {
      render();//extra render
    }
    return false;
  }
  void resizeSlider() {
    sliderLength=size.y*size.y/max(size.y, max(Lines.lines()+10, size.y*2/textSize)*textSize/2);//half
    sliderPos=position.y+min(max(MouseY-position.y, -size.y+sliderLength), size.y-sliderLength);
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
        } else if (Mode!=CYXMODE&&ignoreMc&&(tokens[b].equals("mc")||tokens[b].equals("chain")||tokens[b].equals("c")||tokens[b].equals("mapping")||tokens[b].equals("m")||tokens[b].equals("rnd"))) {
          fill(UIcolors[I_UNITORTEXT]);
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
        if (commentPoint==-13)return;//warning!!!
        String showText=Lines.getLine(a).substring(commentPoint, Lines.getLine(a).length());
        text(showText, position.x-size.x+textSize*3+textWidth(Lines.getLine(a).substring(0, commentPoint))+5, position.y-size.y+(a+1)*textSize+Yoffset);
      }
      int err=getFirstErrorInLine(a);
      if (err<error.size()&&error.get(err).line==a) {//need check...
        errorpassed=true;
        stroke(UIcolors[I_TABC2]);
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
  int pkey='\0';
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
    patternMatcher.findUpdated=false;
  }
  void cursorLeft() {
    if (shiftPressed) {
      if (ctrlPressed)Lines.selectionLeft(true);
      else Lines.selectionLeft(false);
    } else {
      if (ctrlPressed)Lines.cursorLeft(true, false);
      else Lines.cursorLeft(false, false);
    }
  }
  void cursorRight() {
    if (shiftPressed) {
      if (ctrlPressed)Lines.selectionRight(true);
      else Lines.selectionRight(false);
    } else {
      if (ctrlPressed)Lines.cursorRight(true, false);
      else Lines.cursorRight(false, false);
    }
  }
  void cursorUp() {
    if (shiftPressed) {
      if (ctrlPressed) {
        int line=DelayPoint.get(max(0, analyzer.getFrame(Lines.line)));
        if (line==-1)line=0;
        while (Lines.line>line) {
          Lines.selectionUp();
        }
      } else {
        Lines.selectionUp();
      }
    } else {
      if (ctrlPressed) {
        int line=DelayPoint.get(max(0, analyzer.getFrame(Lines.line)));
        if (line==-1)line=0;
        while (Lines.line>line) {
          Lines.cursorUp(false);
        }
      } else {
        Lines.cursorUp(false);
      }
    }
  }
  void cursorDown() {
    if (shiftPressed) {
      if (ctrlPressed) {
        int a=Lines.line;
        int line=DelayPoint.get(min(DelayPoint.size()-1, analyzer.getFrame(Lines.line)+1));
        if (analyzer.uLines.get(Lines.line).Type==Analyzer.UnipackLine.DELAY) {
          line=DelayPoint.get(min(DelayPoint.size()-1, analyzer.getFrame(Lines.line)+2));
        }
        while (Lines.line<line) {
          Lines.selectionDown();
          if (a==Lines.line)break;
          a=Lines.line;
        }
      } else Lines.selectionDown();
    } else {
      if (ctrlPressed) {
        int line=DelayPoint.get(min(DelayPoint.size()-1, analyzer.getFrame(Lines.line)+1));
        if (analyzer.uLines.get(Lines.line).Type==Analyzer.UnipackLine.DELAY) {
          line=DelayPoint.get(min(DelayPoint.size()-1, analyzer.getFrame(Lines.line)+2));
        }
        while (Lines.line<line) {
          Lines.cursorDown(false);
        }
      } else Lines.cursorDown(false);
    }
  }
  void mouseWheel(MouseEvent e) {
    float total=size.y*2-sliderLength*2;
    sliderPos=position.y+min(max(-size.y+sliderLength, sliderPos-position.y+e.getCount()*2000/max(Lines.lines()+8, size.y*2/textSize)), size.y-sliderLength);//HARDCODED!!!
  }
  synchronized void setText(String text) {//#remove sync and thread
    text=text.replace("\r\n", "\n").replace("\r", "\n");
    if (text==null)return;
    String[] lines=split(text, "\n");
    int a=0;
    Lines.reset();
    while (a<lines.length) {
      Lines.addLineWithoutReading(Lines.lines(), lines[a]);
      a=a+1;
    }
    Lines.readAll();
    updateFrameSlider();
    //if (lines.length>0)Lines.deleteLine(0);//for deleting first line.
    RecordLog();
  }
}

class ColorPicker extends UIelement {
  PGraphics colorImage;
  boolean hueClicked=false;
  boolean sbClicked=false;
  color selectedRGB;
  color selectedHSB;
  //
  int htmls;
  int recents;
  int selectedHtml;//recent colors
  public ColorPicker( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    createColorImage();
    selectedRGB=color(255);
    selectedHSB=color(255);
  }
  void setTextBoxes(int start1, int start2) {//must be in sequence from start;
    htmls=start1;
    recents=start2;
    selectedHtml=start2;
  }
  void createColorImage() {
    colorImage=createGraphics(floor(size.x*2), floor(size.y*2));
    colorImage.beginDraw();
    colorImage.ellipseMode(RADIUS);
    colorImage.rectMode(RADIUS);
    colorImage.translate(size.x, size.y);
    colorImage.noStroke();
    colorImage.fill(UIcolors[I_BACKGROUND]);
    colorImage.ellipse(0, 0, size.x, size.y);
    int a=0;
    while (a<255) {
      colorImage.fill(HSBtoRGB((float)a/255, 1.0F, 1.0F));
      colorImage.stroke(HSBtoRGB((float)a/255, 1.0F, 1.0F));
      colorImage.arc(0, 0, size.x*5/6, size.y*5/6, a*(TWO_PI/255), (a+1)*(TWO_PI/255), PIE);
      a=a+1;
    }
    colorImage.stroke(brighter(UIcolors[I_BACKGROUND], -50));
    colorImage.strokeWeight(1);
    colorImage.fill(UIcolors[I_BACKGROUND]);
    colorImage.ellipse(0, 0, size.x/2, size.y/2);
    colorImage.noFill();
    colorImage.ellipse(0, 0, size.x*5/6, size.y*5/6);
    colorImage.endDraw();
  }
  @Override
    boolean react() {
    //htmlsel, selection frame
    if (mousePressed==false||focus!=ID) {
      hueClicked=false;
      sbClicked=false;
    }
    if (super.react()==false)return false;
    if (pressed)focus=ID;
    if (mouseState==AN_PRESSED&&focus==ID) {
      float radius=sqrt((MouseX-position.x)*(MouseX-position.x)+(MouseY-position.y)*(MouseY-position.y));
      if (((size.x/2<radius&&radius<size.x*5/6)||hueClicked)&&sbClicked==false) {
        float atan2pos=atan2(MouseY-position.y, MouseX-position.x);
        if (atan2pos<0)atan2pos+=radians(360);
        selectedHSB=color((atan2pos)*256/TWO_PI, green(selectedHSB), blue(selectedHSB));
        selectedRGB=HSBtoRGB(red(selectedHSB)/255, green(selectedHSB)/255, blue(selectedHSB)/255);
        updateColor();
        updateTextBoxes1();
        updateTextBoxes2();
        if (hueClicked==false)hueClicked=true;
      } else if ((isMousePressed(position.x, position.y, size.x/3, size.y/3)||sbClicked)&&hueClicked==false) {
        selectedHSB=color(red(selectedHSB), (MouseX-position.x+size.x/3)*255/(size.x*2/3), (position.y+size.y/3-MouseY)*255/(size.y*2/3));
        selectedRGB=HSBtoRGB(red(selectedHSB)/255, green(selectedHSB)/255, blue(selectedHSB)/255);
        updateColor();
        updateTextBoxes1();
        updateTextBoxes2();
        if (sbClicked==false)sbClicked=true;
      }
    }
    return false;
  }
  void setColor(color c) {
    ((TextBox)UI[htmls]).value=int(red(c));
    ((TextBox)UI[htmls]).text=""+int(red(c));
    ((TextBox)UI[htmls+1]).value=int(green(c));
    ((TextBox)UI[htmls+1]).text=""+int(green(c));
    ((TextBox)UI[htmls+2]).value=int(blue(c));
    ((TextBox)UI[htmls+2]).text=""+int(blue(c));
    updateFromTextBoxRGB();
  }
  void updateFromTextBoxRGB() {
    selectedRGB=color(((TextBox)UI[htmls]).value, ((TextBox)UI[htmls+1]).value, ((TextBox)UI[htmls+2]).value);
    selectedHSB=color(hue(selectedRGB), saturation(selectedRGB), brightness(selectedRGB));
    updateTextBoxes2();
  }
  void updateFromTextBoxHSB() {
    selectedHSB=color(((TextBox)UI[htmls+3]).value, ((TextBox)UI[htmls+4]).value, ((TextBox)UI[htmls+5]).value);
    selectedRGB=HSBtoRGB(red(selectedHSB)/255, green(selectedHSB)/255, blue(selectedHSB)/255);
    updateTextBoxes1();
  }
  void updateColor() {//call after changing selectedHSB
    render();
    ((Button)UI[recents]).colorInfo=selectedRGB;
    UI[recents].description.content="["+int(red(selectedRGB))+", "+int(green(selectedRGB))+", "+int(blue(selectedRGB))+"]";
    UI[recents].render();
  }
  void updateTextBoxes1() {
    ((TextBox)UI[htmls]).text=str(int(red(selectedRGB)));
    ((TextBox)UI[htmls+1]).text=str(int(green(selectedRGB)));
    ((TextBox)UI[htmls+2]).text=str(int(blue(selectedRGB)));
    UI[htmls].render();
    UI[htmls+1].render();
    UI[htmls+2].render();
  }
  void updateTextBoxes2() {
    ((TextBox)UI[htmls+3]).text=str(int(red(selectedHSB)));
    ((TextBox)UI[htmls+4]).text=str(int(green(selectedHSB)));
    ((TextBox)UI[htmls+5]).text=str(int(blue(selectedHSB)));
    if (skip==false) {
      UI[htmls+3].render();
      UI[htmls+4].render();
      UI[htmls+5].render();
    }
  }
  void disableTextBoxes(boolean in) {
    UI[htmls].disabled=in;
    UI[htmls+1].disabled=in;
    UI[htmls+2].disabled=in;
    UI[htmls+3].disabled=in;
    UI[htmls+4].disabled=in;
    UI[htmls+5].disabled=in;
    UI[recents].disabled=in;
    UI[recents+1].disabled=in;
    UI[recents+2].disabled=in;
    UI[recents+3].disabled=in;
    UI[recents+4].disabled=in;
    UI[recents+5].disabled=in;
    UI[recents+6].disabled=in;
    UI[recents+7].disabled=in;
    UI[recents+8].disabled=in;
    UI[recents+9].disabled=in;
  }
  void selectHtml(int id) {
    int temp=selectedHtml;
    selectedHtml=id;
    UI[temp].render();
    UI[selectedHtml].render();
  }
  @Override
    void render() {
    //specify id here
    image(colorImage, position.x, position.y);//, size.x*2, size.y*2);
    stroke(0);
    strokeWeight(1);
    noFill();
    pushMatrix();
    translate(position.x, position.y);
    pushMatrix();
    rotate(red(selectedHSB)*TWO_PI/255-radians(90));
    rect(0, size.y*4/6, 4, size.y/6+6);
    line(0, size.y*3/6-6, 0, size.y*5/6+6);
    popMatrix();
    strokeWeight(2);
    int a=1;
    while (a<256) {
      int b=1;
      while (b<256) {
        stroke(HSBtoRGB((float)red(selectedHSB)/255, (float)a/255, (float)b/255));
        point(-size.x/3+size.x*2*a/765, size.y/3-size.y*2*b/765);
        b=b+2;
      }
      a=a+2;
    }
    stroke(brighter(UIcolors[I_BACKGROUND], -50));
    rect(0, 0, size.x/3, size.y/3);
    if (blue(selectedHSB)>128)stroke(0);
    else stroke(255);
    strokeWeight(1);
    rect(-size.x/3+green(selectedHSB)*size.x*2/765, size.y/3-blue(selectedHSB)*size.y*2/765, 4, 4);
    noStroke();
    popMatrix();
  }
  void cursorLeft() {
    int temp=selectedHtml-1;
    if (temp<recents)temp=recents;
    selectHtml(temp);
  }
  void cursorRight() {
    int temp=selectedHtml+1;
    if (temp>recents+9)temp=recents+9;
    selectHtml(temp);
  }
  void cursorUp() {
    int temp=selectedHtml-5;
    if (temp<recents)temp=recents;
    selectHtml(temp);
  }
  void cursorDown() {
    int temp=selectedHtml+5;
    if (temp>recents+9)temp=recents+9;
    selectHtml(temp);
  }
}


class PadButton extends UIelement {
  int padClickX=-1;
  int padClickY=-1;
  public PadButton( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
  }
  //boolean onl=false;
  @Override
    boolean react() {
    if (super.react()==false)return false;
    float padX=position.x-(size.x-size.y);
    float interval=2*min(size.y/ButtonX, size.y/ButtonY);
    if (isMouseOn(padX, position.y, size.y, size.y)) {
      int X=floor((MouseX-padX+(ButtonX*interval/2))/interval);
      int Y=floor((MouseY-position.y+(ButtonY*interval/2))/interval);
      if (name.equals("KEYLED_PAD")) {
        if (((jeonjehong==false&&mouseState==AN_RELEASE)||(jeonjehong&&mouseState==AN_PRESS))&&pressed) {
          printLed(X, Y);
        }
      }
      if (name.equals("KEYSOUND_PAD")) {
        if (mouseState==AN_RELEASE) {
          noteOff(X, Y);
          if (draggedListId!=-1&&((ScrollList)UI[draggedListId]).dragging) {
            if (((ScrollList)UI[draggedListId]).selected!=-1) {
              //update drag an drop thing in here(cannot occur in same time with reordering)
              if (UI[draggedListId].name.equals("I_FILEVIEW1")) {//||UI[draggedListId].name.equals("I_LEDVIEW")||UI[draggedListId].name.equals("I_SOUNDVIEW")) {
                if (fileList[((ScrollList)UI[draggedListId]).selected].isFile()) {
                  if (isSoundFile(fileList[((ScrollList)UI[draggedListId]).selected])) {
                    KS.get(ksChain)[X][Y].loadSound(((ScrollList)UI[draggedListId]).View[((ScrollList)UI[draggedListId]).selected]);
                    title_edited="*";
                    surface.setTitle(title_filename+title_edited+title_suffix);
                    if (X==ksX&&Y==ksY) {
                      int soundviewid=getUIid("I_SOUNDVIEW");
                      ((ScrollList)UI[soundviewid]).setItems(KS.get(ksChain)[X][Y].ksSound.toArray(new String[0]));
                      if (UI[soundviewid].disabled==false)UI[soundviewid].render();
                    }
                  } else {
                    KS.get(ksChain)[X][Y].loadLed(((ScrollList)UI[draggedListId]).View[((ScrollList)UI[draggedListId]).selected]);
                    title_edited="*";
                    surface.setTitle(title_filename+title_edited+title_suffix);
                    if (X==ksX&&Y==ksY) {
                      int ledviewid=getUIid("I_LEDVIEW");
                      ((ScrollList)UI[ledviewid]).setItems(KS.get(ksChain)[X][Y].ksLedFile.toArray(new String[0]));
                      if (UI[ledviewid].disabled==false)UI[ledviewid].render();
                    }
                  }
                }
              }
            }
          } else if (pressed) {
            ksX=X;
            ksY=Y;
            int soundviewid=getUIid("I_SOUNDVIEW");
            int ledviewid=getUIid("I_LEDVIEW");
            ((ScrollList)UI[soundviewid]).setItems(KS.get(ksChain)[X][Y].ksSound.toArray(new String[0]));
            ((ScrollList)UI[ledviewid]).setItems(KS.get(ksChain)[X][Y].ksLedFile.toArray(new String[0]));
            if (UI[soundviewid].disabled==false) {
              UI[soundviewid].registerRender=true;
            }
            if (UI[ledviewid].disabled==false) {
              UI[ledviewid].registerRender=true;
            }
          }
        } else if (mouseState==AN_PRESS&&mouseButton==LEFT) {
          padClickX=X;
          padClickY=Y;
          triggerButton(X, Y);
        } else if (mouseState==AN_PRESSED) {
          notePressing(X, Y);
        }
      }
      render();
    } else if (isMouseOn(position.x, position.y, size.x, size.y)) {
      //onl=false;
      int Y=floor((MouseY-position.y+size.y)*4/size.y);
      if (Y<Chain) {
        if (name.equals("KEYLED_PAD")) {
          if (Mode==CYXMODE&&pressed) {
            if ((jeonjehong==false&&mouseState==AN_RELEASE)||(jeonjehong&&mouseState==AN_PRESS)) {
              writeDisplayLine("chain "+str(Y+1));
            }
          }
        } else if (name.equals("KEYSOUND_PAD")) {
          if (mouseState==AN_RELEASE&&pressed) {
            int a=0;
            while (a<ButtonX) {
              int b=0;
              while (b<ButtonY) {
                KS.get(ksChain)[a][b].multiLed=1;//this is strange,but right.
                KS.get(ksChain)[a][b].multiSound=0;
                b=b+1;
              }
              a=a+1;
            }
            ksChain=Y;
            int soundviewid=getUIid("I_SOUNDVIEW");
            int ledviewid=getUIid("I_LEDVIEW");
            ((ScrollList)UI[soundviewid]).setItems(KS.get(ksChain)[X][Y].ksSound.toArray(new String[0]));
            ((ScrollList)UI[ledviewid]).setItems(KS.get(ksChain)[X][Y].ksLedFile.toArray(new String[0]));
            if (UI[soundviewid].disabled==false)UI[soundviewid].render();
            if (UI[ledviewid].disabled==false)UI[ledviewid].render();
          }
        }
        render();
      }
    }
    return false;
  }
  @Override
    void render() {
    float padX=position.x-(size.x-size.y);
    float interval=2*min(size.y/ButtonX, size.y/ButtonY);
    fill(UIcolors[I_PADBACKGROUND]);
    rect(padX, position.y, ButtonX*interval/2, ButtonY*interval/2);//size.y*size.y
    stroke(UIcolors[I_PADFOREGROUND]);
    strokeWeight(1);
    for (int a=0; a<=ButtonX; a++) {
      line(padX-ButtonX*interval/2+a*interval, position.y-size.y, padX-ButtonX*interval/2+a*interval, position.y+size.y);
    }
    for (int a=0; a<=ButtonY; a++) {
      line(position.x-size.x, position.y-ButtonY*interval/2+a*interval, position.x+size.x-size.y/4, position.y-ButtonY*interval/2+a*interval);
    }
    noStroke();
    if (name.equals("KEYLED_PAD")) {
      int a=0;
      if (Mode==AUTOINPUT||Mode==MANUALINPUT) {
        if (currentLedFrame>=LED.size())return;//#remove
        while (a<ButtonX) {
          int b=0;
          while (b<ButtonY) {
            if (LED.get(currentLedFrame)[a][b]!=OFFCOLOR) {
              fill(LED.get(currentLedFrame)[a][b]);
              rect(padX-ButtonX*interval/2+a*interval+interval/2, position.y-ButtonY*interval/2+b*interval+interval/2, interval*2/5, interval*2/5);
            }
            b=b+1;
          }
          a=a+1;
        }
      } else if (Mode==CYXMODE) {
        noStroke();
        fill(brighter(UIcolors[I_PADBACKGROUND], -50));
        rect(position.x+size.x-size.y/8, position.y-size.y*(8-Chain)/8, size.y/8, size.y*Chain/8);
        stroke(UIcolors[I_PADFOREGROUND]);
        strokeWeight(1);
        a=0;
        while (a<Chain) {
          line(position.x+size.x-size.y/4, position.y-size.y+size.y*a/4, position.x+size.x, position.y-size.y+size.y*a/4);
          a=a+1;
        }
        noStroke();
        a=0;
        while (a<ButtonX) {
          int b=0;
          while (b<ButtonY) {
            if (apLED.get(currentLedFrame)[a][b]) {
              fill(255);
              rect(padX-ButtonX*interval/2+a*interval+interval/2, position.y-ButtonY*interval/2+b*interval+interval/2, interval*2/5, interval*2/5);
            }
            b=b+1;
          }
          a=a+1;
        }
      }
    } else if (name.equals("KEYSOUND_PAD")) {
      noStroke();
      fill(brighter(UIcolors[I_PADBACKGROUND], -50));
      rect(position.x+size.x-size.y/8, position.y-size.y*(8-Chain)/8, size.y/8, size.y*Chain/8);
      stroke(UIcolors[I_PADFOREGROUND]);
      strokeWeight(1);
      int a=0;
      while (a<Chain) {
        line(position.x+size.x-size.y/4, position.y-size.y+size.y*a/4, position.x+size.x, position.y-size.y+size.y*a/4);
        a=a+1;
      }
      noStroke();
      textSize(max(1, interval/5));
      a=0;
      while (a<ButtonX) {
        int b=0;
        while (b<ButtonY) {
          if (ksDisplay[a][b]!=OFFCOLOR) {
            fill(ksDisplay[a][b]);
            rect(padX-ButtonX*interval/2+a*interval+interval/2, position.y-ButtonY*interval/2+b*interval+interval/2, interval*2/5, interval*2/5);
          }
          fill(UIcolors[I_BACKGROUND]);
          if (KS.get(ksChain)[a][b].ksSound.size()!=0) {
            text(str(KS.get(ksChain)[a][b].ksSound.size()), padX-ButtonX*interval/2+a*interval+interval/2, position.y-ButtonY*interval/2+b*interval+interval*2/5);
          }
          if (KS.get(ksChain)[a][b].ksLedFile.size()!=0) {
            text(str(KS.get(ksChain)[a][b].ksLedFile.size()), padX-ButtonX*interval/2+a*interval+interval/2, position.y-ButtonY*interval/2+b*interval+interval*3/5);
          }
          b=b+1;
        }
        a=a+1;
      }
      drawIndicator(padX-ButtonX*interval/2+ksX*interval+interval/2, position.y-ButtonY*interval/2+ksY*interval+interval/2, interval*2/5, interval*2/5, 4);
      drawIndicator(position.x+size.x-size.y/8, position.y-size.y+size.y*(ksChain*2+1)/8, size.y/10, size.y/10, 4);
    }
    if (isMouseOn(padX, position.y, size.y, size.y)) {
      int X=floor((MouseX-padX+(ButtonX*interval/2))/interval);
      int Y=floor((MouseY-position.y+(ButtonY*interval/2))/interval);
      if (0<=X&&X<ButtonX&&0<=Y&&Y<ButtonY) {
        setStatusL(str(X+1)+" "+str(Y+1));
        if (mousePressed)fill(0, 100);
        else fill(0, 50);
        rect(padX-ButtonX*interval/2+X*interval+interval/2, position.y, interval/2, ButtonY*interval/2);
        rect(padX, position.y-ButtonY*interval/2+Y*interval+interval/2, ButtonX*interval/2, interval/2);
      }
    } else if (isMouseOn(position.y, position.y, size.x, size.y)) {
      if (Mode==CYXMODE||name.equals("KEYSOUND_PAD")) {
        int Y=floor((MouseY-position.y+size.y)*4/size.y);
        if (Y<Chain) {
          setStatusL(""+str(Y+1));
          if (mousePressed)fill(0, 100);
          else fill(0, 50);
          rect(position.x+size.x-size.y/8, position.y-size.y+size.y*(Y*2+1)/8, size.y/8, size.y/8);
        }
      }
    }
  }
  void printLed(int X, int Y) {
    printLed(X, Y, false);
  }
  synchronized void printLed(int X, int Y, boolean async) {
    if (Mode==AUTOINPUT) {
      int line=Lines.lines();
      int frame=LED.size()-1;
      if (InFrameInput) {
        if (currentLedFrame!=DelayPoint.size()-1)line=DelayPoint.get(currentLedFrame+1);
        frame=currentLedFrame;
      }
      int a=line-1;
      int aframe=analyzer.getFrame(line);
      boolean done=false;
      while (a>0&&a>DelayPoint.get(aframe)) {
        Analyzer.UnipackLine info= analyzer.uLines.get(a);
        if (info.Type==Analyzer.UnipackLine.ON) {
          if (info.x-1==X&&info.y-1==Y) {
            done=true;
            Lines.deleteLine(a);
            if (UI[textfieldId].disabled==false) {
              if (async)UI[textfieldId].registerRender=true;
              else UI[textfieldId].render();
            }
            break;
          }
        } else if (info.Type==Analyzer.UnipackLine.OFF) {
          if (info.x-1==X&&info.y-1==Y) {
            done=true;
            Lines.deleteLine(a);
            boolean notsame=k[((VelocityButton)UI[velnumId]).selectedVelocity]!=LED.get(frame)[X][Y];
            if (notsame)writeDisplayLine("on "+str(Y+1)+" "+str(X+1)+" auto "+((VelocityButton)UI[velnumId]).selectedVelocity);
            else if (UI[textfieldId].disabled==false) {
              if (async)UI[textfieldId].registerRender=true;
              else UI[textfieldId].render();
            }
            break;
          }
        }
        a--;
      }
      a--;
      if (done==false) {
        boolean on=false;
        while (a>0) {
          Analyzer.UnipackLine info= analyzer.uLines.get(a);
          if (info.Type==Analyzer.UnipackLine.ON) {
            if (info.x-1==X&&info.y-1==Y) {
              on=true;
              break;
            }
          } else if (info.Type==Analyzer.UnipackLine.OFF) {
            if (info.x-1==X&&info.y-1==Y) {
              on=false;
              break;
            }
          }
          a--;
        }
        if (on)writeDisplayLine("off "+str(Y+1)+" "+str(X+1), true);
        else if (selectedColorType==DS_VEL) {
          writeDisplayLine("on "+str(Y+1)+" "+str(X+1)+" auto "+((VelocityButton)UI[velnumId]).selectedVelocity, true);
        } else {//html
          writeDisplayLine("on "+str(Y+1)+" "+str(X+1)+" "+hex(((Button)UI[((ColorPicker)UI[htmlselId]).selectedHtml]).colorInfo, 6), true);
        }
      }
    } else if (Mode==MANUALINPUT) {
      writeDisplay(" "+str(Y+1)+" "+str(X+1), true);
    } else if (Mode==CYXMODE) {
      int line=Lines.lines();
      if (InFrameInput) {
        if (currentLedFrame!=DelayPoint.size()-1)line=DelayPoint.get(currentLedFrame+1);
      }
      int a=line-1;
      boolean on=false;
      while (a>0) {
        Analyzer.UnipackLine info= analyzer.uLines.get(a);
        if (info.Type==Analyzer.UnipackLine.APON) {
          if (info.x-1==X&&info.y-1==Y) {
            on=true;
            break;
          }
        } else if (info.Type==Analyzer.UnipackLine.OFF) {
          if (info.x-1==X&&info.y-1==Y) {
            on=false;
            break;
          }
        }
        a--;
      }
      if (on)writeDisplayLine("off "+str(Y+1)+" "+str(X+1), true);
      else writeDisplayLine("on "+str(Y+1)+" "+str(X+1), true);
    }
    if (async)registerRender=true;
  }
  void triggerButton(int X, int Y) {
    triggerButton(X, Y, false);
  }
  synchronized void triggerButton(int X, int Y, boolean async) {
    if (X<0||Y<0||X>=ButtonX||Y>=ButtonY)return;
    KS.get(ksChain)[X][Y].autorun();
    int id=getUIidRev("KS_SOUNDMULTI");
    ((TextBox)UI[id]).value=max(1, min(KS.get(ksChain)[X][Y].multiSound, KS.get(ksChain)[X][Y].ksSound.size()));
    ((TextBox)UI[id]).text=""+((TextBox)UI[id]).value;
    if (async)UI[id].registerRender=true;
    else UI[id].render();
    id=getUIidRev("KS_LEDMULTI");
    ((TextBox)UI[id]).value=max(1, min(KS.get(ksChain)[X][Y].multiLed, KS.get(ksChain)[X][Y].ksLedFile.size()));
    ((TextBox)UI[id]).text=""+((TextBox)UI[id]).value;
    if (async)UI[id].registerRender=true;
    else UI[id].render();
    noteOn(X, Y);
  }
  synchronized void noteOn(int x, int y) {//uses in midi section too.
    if (isNoteOn(x, y)==false)CurrentNoteOn.add(new IntVector2(x, y));
  }
  private void notePressing(int x, int y) {//using local variable! don't use this in else.
    if (padClickX==-2)return;//resets on noteOn in padbutton.
    if (padClickX!=x||padClickY!=y) {//mouse moved.
      noteOff(x, y);
      padClickX=-2;
      padClickY=-2;
    }
  }
  synchronized void noteOff(int x, int y) {//if note is not in list, ignore.
    if (x<0||y<0||x>=ButtonX||y>=ButtonY)return;
    int a=0;
    while (a<CurrentNoteOn.size()) {
      if (CurrentNoteOn.get(a).equals(x, y)) {
        CurrentNoteOn.remove(a);
        if (KS.get(ksChain)[x][y].multiSound>0&&KS.get(ksChain)[x][y].ksSoundLoop.size()>0&&KS.get(ksChain)[x][y].ksSoundLoop.get(KS.get(ksChain)[x][y].multiSound-1)==0) {
          KS.get(ksChain)[x][y].stopSound();
          KS.get(ksChain)[x][y].autorun_soundFlag=true;
        }
        if (KS.get(ksChain)[x][y].multiLed>0&&KS.get(ksChain)[x][y].ksLedLoop.size()>0&&KS.get(ksChain)[x][y].ksLedLoop.get(KS.get(ksChain)[x][y].multiLed-1)==0) {
          int c=0;
          while (c<ledstack.size()) {//pointer
            if (ledstack.get(c).bX==x&&ledstack.get(c).bY==y) {
              ledstack.get(c).isInStack=false;
              ledstack.get(c).autorun_resetLed();
              ledstack.remove(c);
            } else {
              c=c+1;
            }
          }
        }
      } else {
        a=a+1;
      }
    }
  }
}


class VelocityButton extends UIelement {
  int selectedVelocity=0;
  public VelocityButton( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
  }
  @Override
    boolean react() {
    //only I_VELNUM
    if (super.react()==false)return false;
    if (isMouseOn(position.x, position.y, size.x, size.y)&&mouseState==AN_PRESSED) {
      selectedVelocity=floor((MouseY-position.y+size.y)*8/size.y)*8+floor(min(7, (max(0, MouseX-position.x+size.x)*4/size.x)));
      selectedColorType=DS_VEL;
      render();
    }
    return false;
  }
  @Override
    void render() {
    drawVel(position.x-size.x, position.y-size.y, size.x*2, size.y*2);
    if (mouseState==AN_PRESSED) {
      fill(UIcolors[I_BACKGROUND]);
      rect(position.x-size.x-2, position.y, 2, size.y+2);
      rect(position.x+size.x+2, position.y, 2, size.y+2);
      rect(position.x, position.y-size.y-2, size.x+2, 2);
      rect(position.x, position.y+size.y+2, size.x+2, 2);
      if (firstPress>450) {//HARDCODED
        fill(UIcolors[I_BACKGROUND], 200);
        rect(position.x, position.y, size.x, size.y);
      }
      fill (k [selectedVelocity]);
      rect(position.x-size.x+((selectedVelocity%8)*(size.x/4))+(size.x/8), position.y-size.y+(size.y/8)*(selectedVelocity/8)+(size.y/16), (size.x/8), (size.y/16));
    } else {
      if (selectedColorType==DS_VEL) {
        drawIndicator(position.x-size.x+((selectedVelocity%8)*(size.x/4))+(size.x/8), position.y-size.y+(size.y/8)*(selectedVelocity/8)+(size.y/16), (size.x/8), (size.y/16), 2);
      }
    }
  }
  void cursorLeft() {
    selectedVelocity--;
    if (selectedVelocity<0)selectedVelocity=0;
    render();
  }
  void cursorRight() {
    selectedVelocity++;
    if (selectedVelocity>=k.length)selectedVelocity=k.length-1;
    render();
  }
  void cursorUp() {
    selectedVelocity-=8;
    if (selectedVelocity<0)selectedVelocity=0;
    render();
  }
  void cursorDown() {
    selectedVelocity+=8;
    if (selectedVelocity>=k.length)selectedVelocity=k.length-1;
    render();
  }
}
class WaveEditor extends UIelement {//waveform visualizer &&automation editor
  public WaveEditor( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
  }
  @Override
    boolean react() {
    super.react();
    //only I_WAVEDITOR
    return false;
  }
  @Override
    void render() {
    fill(UIcolors[I_FOREGROUND]);
    noStroke();
    rect(position.x, position.y, size.x, size.y);
  }
}

class Visualizer extends UIelement {//effect control
  public Visualizer( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
  }
  @Override
    boolean react() {
    super.react();
    //only I_VISUALIZER
    return false;
  }
  @Override
    void render() {
    stroke(UIcolors[I_FOREGROUND]);
    noFill();
    rect(position.x, position.y, size.x, size.y);
    pushMatrix();
    translate(position.x-size.x, position.y-size.y);
    popMatrix();
    noStroke();
  }
}
class Logger extends UIelement {
  int textSize;
  ArrayList<String> logs=new ArrayList<String>();
  float offset=0;
  public Logger( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, int textSize_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    textSize=textSize_;
  }
  @Override
    boolean react() {
    if (super.react()==false)return false;//LOG_LOG
    //do nothing
    if (isMouseOn(position.x, position.y, size.x, size.y))render();
    return false;
  }
  void mouseWheel(MouseEvent e) {
    offset=max(0, min(logs.size()*4*textSize/3, offset-40*e.getCount()));
  }
  @Override
    void render() {
    stroke(UIcolors[I_FOREGROUND]);
    fill(UIcolors[I_BACKGROUND]);
    rect(position.x, position.y, size.x, size.y);
    noStroke();
    textFont(fontRegular);
    textSize(textSize);
    textLeading(textSize*4/3);
    textAlign(LEFT, DOWN);
    fill(UIcolors[I_FOREGROUND]);
    int a=min(floor(offset*3/(4*textSize)+logs.size()), logs.size()-1);
    while (a>=0&&size.y*2-textSize*4*(logs.size()-a)/3+offset>0) {
      if (position.y+size.y-textSize*4*(logs.size()-a)/3+offset<position.y+size.y)text(logs.get(a), position.x-size.x+textSize, position.y+size.y-textSize*4*(logs.size()-a)/3+offset);
      a=a-1;
    }
    textFont(fontBold);
    textAlign(CENTER, CENTER);
    if (UI[getUIid("LOG_EXIT")].disabled==false)UI[getUIid("LOG_EXIT")].render();
  }
}

class InfoViewer extends UIelement {
  int textSize;
  Analyzer.UnipackInfo info;
  public InfoViewer( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_, int textSize_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    textSize=textSize_;
  }
  @Override
    boolean react() {
    if (super.react()==false)return false;//LOG_LOG
    //do nothing
    if (pressed&&mouseState==AN_PRESS)render();
    return false;
  }
  @Override
    void render() {
    stroke(UIcolors[I_FOREGROUND]);
    fill(UIcolors[I_BACKGROUND]);
    rect(position.x, position.y, size.x, size.y);
    noStroke();
    textFont(fontRegular);
    textSize(textSize);
    textLeading(textSize*4/3);
    textAlign(LEFT, UP);
    fill(UIcolors[I_FOREGROUND]);
    if (info!=null)text(info.uncloud_toString(), position.x-size.x+15, position.y-size.y+15);
    textFont(fontBold);
    textAlign(CENTER, CENTER);
  }
}