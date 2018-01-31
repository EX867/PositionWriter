class Button extends UIelement implements ImageComponent {
  void onRelease() {
    if (name.equals("I_OPENMP3")) {//External
      resetFocusBeforeFrame();
      UI[getUIid("MP3_TIME")].disabled=false;
      Frames[getFrameid("F_MP3CONVERT")].prepare(currentFrame);
    } else if (name.equals("I_OPENSKINEDIT")) {//External
      resetFocusBeforeFrame();
      Frames[getFrameid("F_SKINEDIT")].prepare(currentFrame);
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
      //uncloud_prepare();
      //Frames[getFrameid("F_UNCLOUD")].prepare(currentFrame);//#uncloud this is disabled in current version!!
    } else if (name.equals("I_RELOAD")) {
      L_ResizeData(((TextBox)UI[getUIid("I_CHAIN")]).value, ((TextBox)UI[getUIid("I_BUTTONX")]).value, ((TextBox)UI[getUIid("I_BUTTONY")]).value);
      //analyzer.clear();
      //keyled_textEditor.current.readAll();
      UI[getUIid("I_CHAIN")].render();
      UI[getUIid("I_BUTTONX")].render();
      UI[getUIid("I_BUTTONY")].render();
      updateFrameSlider();
    } else if (name.equals("I_MIDI")) {
      reloadMidiDevices();
    } else if (name.equals("I_CAFELINK")) {//External
      link ("http://cafe.naver.com/unipad");
    } else if (name.equals("I_PATH")) {
      openFileExplorer(GlobalPath);
    } else if (name.equals("I_INFO")) {//UI
      Frames [getFrameid("F_INFO")].prepare (currentFrame);
    } else if (name.equals("I_DEFAULTINPUT")) {//Settings
      value=true;
      ((Button)UI [getUIid("I_OLDINPUT")]).value=false;
      ((Button)UI [getUIidRev("I_RIGHTOFFMODE")]).value=false;
      ((Button)UI [getUIid("I_CYXMODE")]).value=false;
      UI [getUIid("I_DEFAULTINPUT")].render();
      UI [getUIid("I_OLDINPUT")].render();
      UI [getUIidRev("I_RIGHTOFFMODE")].render();
      UI [getUIid("I_CYXMODE")].render();
      //Mode=AUTOINPUT;
      //readAll();
    } else if (name.equals("I_OLDINPUT")) {//Settings
      value=true;
      ((Button)UI [getUIid("I_DEFAULTINPUT")]).value=false;
      ((Button)UI [getUIidRev("I_RIGHTOFFMODE")]).value=false;
      ((Button)UI [getUIid("I_CYXMODE")]).value=false;
      UI [getUIid("I_DEFAULTINPUT")].render();
      UI [getUIid("I_OLDINPUT")].render();
      UI [getUIidRev("I_RIGHTOFFMODE")].render();
      UI [getUIid("I_CYXMODE")].render();
      //Mode=MANUALINPUT;
    } else if (name.equals("I_RIGHTOFFMODE")) {// duplication x3. make it to function!
      value=true;
      ((Button)UI [getUIid("I_DEFAULTINPUT")]).value=false;
      ((Button)UI [getUIid("I_OLDINPUT")]).value=false;
      ((Button)UI [getUIid("I_CYXMODE")]).value=false;
      UI [getUIid("I_DEFAULTINPUT")].render();
      UI [getUIid("I_OLDINPUT")].render();
      UI [getUIidRev("I_RIGHTOFFMODE")].render();
      UI [getUIid("I_CYXMODE")].render();
      //Mode=RIGHTOFFMODE;
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
      if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT2")) {
      if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT3")) {
      if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT4")) {
      if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT5")) {
      if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT6")) {
      if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT7")) {
      if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT8")) {
      if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENT9")) {
      if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT) writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_RECENTA")) {
      if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
        selectedColorType=DS_HTML;
        ((ColorPicker)UI[htmlselId]).selectHtml(ID);
      } else if (Mode==MANUALINPUT)writeDisplay(" "+hex(colorInfo, 6));
    } else if (name.equals("I_NUMBER1")) {
      //int before=LED.size();
      //int first=keyled_textEditor.current.processer.displayFrame;
      //writeDisplay(userMacro1);
      //if (LED.size()!=before) {//ap.size and led.size is equal.
      //  keyled_textEditor.current.processer.displayFrame=min(first+(LED.size()-before), DelayPoint.size()-1);
      //  setTimeByFrame();
      //  frameSlider.render();
      //}
    } else if (name.equals("I_NUMBER2")) {
      //int before=LED.size();
      //int first=keyled_textEditor.current.processer.displayFrame;
      //writeDisplay(userMacro2);
      //if (LED.size()!=before) {
      //  keyled_textEditor.current.processer.displayFrame+=(LED.size()-before);
      //  keyled_textEditor.current.processer.displayFrame=min(first+(LED.size()-before), DelayPoint.size()-1);
      //  setTimeByFrame();
      //  frameSlider.render();
      //}
    } else if (name.equals("I_OPENFIND")) {
    } else if (name.equals("I_NEXTFIND")) {
      if (findData.size()!=0) {
        if (patternMatcher.findUpdated==false)findData=patternMatcher.findAll( keyled_textEditor.current.toString());
        findIndex=findIndex+1;
        if (findIndex>=findData.size())findIndex=0;
        if (findData.size()>0) {
          keyled_textEditor.current.setCursorByIndex(findData.get(findIndex).startpoint);
          keyled_textEditor.current.selectFromCursor(findData.get(findIndex).text.length());
          focus=keyled_textEditor.ID;
          keyled_textEditor.moveToCursor();
        }
        UI[findId].render();
      }
    } else if (name.equals("I_PREVIOUSFIND")) {
      if (findData.size()!=0) {
        if (patternMatcher.findUpdated==false)findData=patternMatcher.findAll(keyled_textEditor.current.toString());
        findIndex=findIndex-1;
        if (findIndex<0)findIndex=findData.size()-1;
        if (findData.size()>0) {
          keyled_textEditor.current.setCursorByIndex(findData.get(findIndex).startpoint);
          keyled_textEditor.current.selectFromCursor(findData.get(findIndex).text.length());
          focus=keyled_textEditor.ID;
          keyled_textEditor.moveToCursor();
        }
        UI[findId].render();
      }
    } else if (name.equals("I_REPLACEALL")) {
      patternMatcher.registerFind(((TextBox)UI[getUIid("I_FINDTEXTBOX")]).text, value);
      patternMatcher.registerReplace(((TextBox)UI[getUIid("I_REPLACETEXTBOX")]).text, value);
      findData=patternMatcher.findAll(keyled_textEditor.current.toString());//WARNING!!!
      RecordLog();
      keyled_textEditor.setText(patternMatcher.replaceAll(keyled_textEditor.current.toString(), ((TextBox)UI[getUIid("I_REPLACETEXTBOX")]).text, findData));
      RecordLog();
      title_edited="*";
      surface.setTitle(title_filename+title_edited+title_suffix);
    } else if (name.equals("I_CALCULATE")) {
      patternMatcher.registerFind(((TextBox)UI[getUIid("I_FINDTEXTBOX")]).text, value);
      patternMatcher.registerReplace(((TextBox)UI[getUIid("I_REPLACETEXTBOX")]).text, value);
      findData=patternMatcher.findAll(keyled_textEditor.current.toString());//WARNING!!!
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
      midiOffAll();
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
      Frames[getFrameid("F_DIALOG")].prepare(currentFrame);
    } else if (name.equals("UN_UPDATE")) {
      resetFocusBeforeFrame();
      tempCode=DIALOG_UPDATE;
      Frames[getFrameid("F_DIALOG")].prepare(currentFrame);
    } else if (name.equals("UN_DELETE")) {
      resetFocusBeforeFrame();
      tempCode=DIALOG_DELETE;
      Frames[getFrameid("F_DIALOG")].prepare(currentFrame);
    } else if (name.equals("UN_DOWNLOAD")) {
      resetFocusBeforeFrame();
      tempCode=DIALOG_DOWNLOAD;
      Frames[getFrameid("F_DIALOG")].prepare(currentFrame);
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
    } else if (name.equals("SKIN_TEXT1")) {
      resetFocusBeforeFrame();
      tempColor=-1;
      ColorPicker pick=((ColorPicker)UI[getUIidRev("PC_HTMLSEL")]);
      ((TextBox)UI[getUIid("PC_ALPHA")]).value=int(alpha(colorInfo));
      ((TextBox)UI[getUIid("PC_ALPHA")]).text=str(int(alpha(colorInfo)));
      pick.skip=true;
      pick.setColor(colorInfo);
      pick.skip=false;
      Frames[getFrameid("F_PICKCOLOR")].prepare(currentFrame);
    } else if (name.equals("SKIN_BUILD")) {
      String packageText="com.kimjisub.launchpad.theme."+((TextBox)UI[getUIidRev("SKIN_PACKAGE")]).text;
      String appnameText=filterString(((TextBox)UI[getUIidRev("SKIN_APPNAME")]).text, new String[]{"\\", "/", ":", "*", "?", "\"", "<", ">", "|"});
      if (appnameText.equals("")==false&&isValidPackageName(packageText)) {
        resetFocusBeforeFrame();
        Frames[getFrameid("F_ERROR")].prepare(currentFrame);
        build_windows(packageText, appnameText, ((TextBox)UI[getUIidRev("SKIN_AUTHOR")]).text, ((TextBox)UI[getUIidRev("SKIN_DESCRIPTION")]).text, ((TextBox)UI[getUIidRev("SKIN_TITLE")]).text, ((TextBox)UI[getUIidRev("SKIN_VERSION")]).text, ((Button)UI[getUIidRev("SKIN_TEXT1")]).colorInfo);
      }
    } else if (name.equals("SKIN_EXIT")) {
      Frames[currentFrame].returnBack();
    } else if (name.equals("INITIAL_HOWTOUSE")) {
      link("https://github.com/EX867/PositionWriter/wiki/How-to-use-v2-(english)");
    }
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
      if (keyled_textEditor.disabled==false)keyled_textEditor.render();
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
        surface.setSize(floor(initialWidth*valueF), floor(initialHeight*valueF));
        setSize(floor(initialWidth*valueF), floor(initialHeight*valueF));
      } else if (name.equals("I_FRAMESLIDER")) {
        keyled_textEditor.current.processer.displayTime=valueI;
        timeLabel.text=keyled_textEditor.current.processer.displayTime+"/"+maxI;
        int sum=0;
        int a=0;
        valueI=sum;
        keyled_textEditor.current.processer.displayFrame=0;
        while (a<DelayValue.size()) {
          sum=sum+DelayValue.get(a);
          if (keyled_textEditor.current.processer.displayTime<sum) break;
          else valueI=sum;
          keyled_textEditor.current.processer.displayFrame++;
          a=a+1;
        }
        keyled_textEditor.current.processer.displayTime=valueI;
        if (autorun_playing==false||autorun_paused)autorun_backup=keyled_textEditor.current.processer.displayTime;
        if (keyled_textEditor.disabled==false)keyled_textEditor.render();
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
        keyled_textEditor.render();
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
    if (bypass&&(mousePressed==false||(mousePressed&&mouseButtonLast==LEFT)))return;
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
void a() {
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
  } else if (name.equals("PC_ALPHA")) {
    value=min(255, max(0, value));
  } else if (name.equals("I_AUTOSAVETIME")) {
    value=max(10, value);
  } else if (name.equals("I_DESCRIPTIONTIME")) {
    value=max(1, value);
  } else if (name.equals("I_BUTTONX")||name.equals("I_BUTTONY")) {
    value=max(1, min(value, PAD_MAX));
  } else if (name.equals("I_CHAIN")) {
    value=min(max(1, value), 8);
  } else if (name.equals("I_TEXTSIZE")) {
    value=max(1, min(50, value));
  } else if (name.equals("I_FINDTEXTBOX")) {
    patternMatcher.findUpdated=false;
    patternMatcher.registerFind(text, ((Button)UI[getUIidRev("I_CALCULATE")]).value);
    findData=patternMatcher.findAll(keyled_textEditor.current.toString());//WARNING!!!
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
  } else if (name.equals("SKIN_PACKAGE")) {
    description.content="com.kimjisub.launchpad.theme."+text;
  }
}
class ScrollList extends UIelement {
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
  @Override
    boolean react() {
    if (isMouseOn(position.x, position.y, size.x, size.y)) {
      if (mouseState==AN_PRESS) {
        focus=ID;
        if ((isMousePressed(position.x+size.x-SLIDER_HALFWIDTH, position.y, SLIDER_HALFWIDTH, size.y)||(sliderClicked/*&&mousePressed&&mouseButtonLast==RIGHT*/))) {
          sliderClicked=true;
        } else {//isMousePressed(position.x-SLIDER_HALFWIDTH, position.y, size.x-SLIDER_HALFWIDTH, size.y)
          setSelect((int)(MouseY-(position.y-size.y-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2))))/ITEM_HEIGHT);
          if (selected<0||selected>=View.length)setSelect(-1);
          if (selected!=-1) {
            itemClicked=true;
            if (keyInterval<DOUBLE_CLICK&&doubleClicked==0&&doubleClickDist<10) {//double click (10 hardcoded!!)
              doubleClicked=1;
              if (name.equals("I_LEDVIEW")) {
                if (mouseButtonLast==RIGHT) {
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
                ((TextBox)UI[getUIid("PC_ALPHA")]).value=int(alpha(UIcolors[tempColor]));
                ((TextBox)UI[getUIid("PC_ALPHA")]).text=str(int(alpha(UIcolors[tempColor])));
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
          //update drag and drop thing in here(cannot occur in same time with reordering)
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
        if (pressed&&sliderClicked==false/*&&dragging==false*/) {//?????
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
}

class PadButton extends UIelement {
  int padClickX=-1;
  int padClickY=-1;
  color[][] before=new color[ButtonX][ButtonY];
  public PadButton( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
  }
  //boolean onl=false;
  @Override
    boolean react() {
    if (super.react()==false)return false;
    if (focused==false)return false;
    float padX=position.x-(size.x-size.y);
    float interval=2*min(size.y/ButtonX, size.y/ButtonY);
    if (isMouseOn(padX, position.y, size.y, size.y)) {
      int X=floor((MouseX-padX+(ButtonX*interval/2))/interval);
      int Y=floor((MouseY-position.y+(ButtonY*interval/2))/interval);
      if (name.equals("KEYLED_PAD")) {
        if (jeonjehong&&mouseState==AN_PRESS) {
          printLed(X, Y);
        } else if ((jeonjehong==false&&mouseState==AN_RELEASE)&&pressed) {
          if (Mode==RIGHTOFFMODE) {
            if (mouseButtonLast==LEFT)printLed(X, Y, false, 0);
            else printLed(X, Y, false, 1);
          } else {
            if (mouseButtonLast==LEFT)printLed(X, Y);
          }
        }
      }
      if (name.equals("KEYSOUND_PAD")) {
        if (mouseState==AN_RELEASE) {
          noteOff(X, Y);
          if (draggedListId!=-1&&((ScrollList)UI[draggedListId]).dragging) {
            if (((ScrollList)UI[draggedListId]).selected!=-1) {
              //update drag and drop thing in here(cannot occur in same time with reordering)
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
        } else if (mouseState==AN_PRESS&&mouseButtonLast==LEFT) {
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
            triggerChain(Y);
          }
        }
        render();
      }
    }
    return false;
  }
  void printLed(int X, int Y) {
    printLed(X, Y, false, 0);
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
  synchronized void triggerChain(int c) {
    if (c<0||c>=Chain)return;
    ksChain=c;
    int a=0;
    while (a<ButtonX) {
      int b=0;
      while (b<ButtonY) {
        KS.get(ksChain)[a][b].multiLed=0;
        KS.get(ksChain)[a][b].multiLedBackup=0;
        KS.get(ksChain)[a][b].multiSound=0;
        b=b+1;
      }
      a=a+1;
    }
    int soundviewid=getUIid("I_SOUNDVIEW");
    int ledviewid=getUIid("I_LEDVIEW");
    ((ScrollList)UI[soundviewid]).setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
    ((ScrollList)UI[ledviewid]).setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
    if (UI[soundviewid].disabled==false)UI[soundviewid].registerRender=true;
    if (UI[ledviewid].disabled==false)UI[ledviewid].registerRender=true;
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
    if (info!=null)text(info.toUncloudString(), position.x-size.x+15, position.y-size.y+15);
    textFont(fontBold);
    textAlign(CENTER, CENTER);
  }
}