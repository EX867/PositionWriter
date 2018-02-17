void setup_ev1() {//setup small listeners
  ((ImageButton)KyUI.get("ks_stop")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      currentKs.light.stopAll();
      currentKs.player.stopAll();
      globalSamplePlayer.pause(true);
      midiOffAll();
      ks_pad.displayControl(currentKs.light.display);
      ks_pad.invalidate();
      return false;
    }
  }
  );
  ((ImageToggleButton)KyUI.get("led_commands")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.get("led_consolelayout").setEnabled(((ImageToggleButton)KyUI.get("led_commands")).value);
      KyUI.get("led_textlayout2").localLayout();
      return false;
    }
  }
  );
  ((ImageToggleButton)KyUI.get("led_findreplace")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.get("led_findlr").setEnabled(((ImageToggleButton)KyUI.get("led_findreplace")).value);
      KyUI.get("led_textlayout3").localLayout();
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("tips_previous")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      if (tips.length!=0) {
        tipsIndex--;
        if (tipsIndex<0) {
          tipsIndex=tips.length-1;
        }
        ((ImageButton)KyUI.get("tips_content")).image=tips[tipsIndex];
        KyUI.get("tips_content").invalidate();
      }
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("tips_next")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      if (tips.length!=0) {
        tipsIndex++;
        if (tipsIndex>=tips.length) {
          tipsIndex=0;
        }
        ((ImageButton)KyUI.get("tips_content")).image=tips[tipsIndex];
        KyUI.get("tips_content").invalidate();
      }
      return false;
    }
  }
  );
  ((Button)KyUI.get("set_ffmpeg")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.addLayer(frame_mp3);
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("mp3_exit")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.removeLayer();
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("log_exit")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.removeLayer();
      return false;
    }
  }
  );
  ((Button)KyUI.get("set_skinbuilder")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      //KyUI.addLayer(skitEditLayer);
      return false;
    }
  }
  );
  ((LinearList)KyUI.get("mp3_input")).setSelectListener(new ItemSelectListener() {
    public void onEvent(int index) {
      converter.selection=((Button)((LinearList)KyUI.get("mp3_input")).getItems().get(index)).text;
    }
  }
  );
  ((ImageButton)KyUI.get("mp3_play")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent ev, int index) {
      LinearList list=(LinearList)KyUI.get("mp3_input");
      for (Element e : list.getItems()) {
        if (((Button)e).text.equals(converter.selection)) {
          if (new File(converter.selection).isFile()) {
            globalSamplePlayerPlay(converter.selection);
          }
          return false;
        }
      }
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("mp3_stop")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      globalSamplePlayer.pause(true);
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("mp3_convert")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent ev, int index) {
      KyUI.addLayer(frame_log);
      LinearList list=(LinearList)KyUI.get("mp3_input");
      ArrayList<String> input=new ArrayList<String>();
      for (Element e : list.getItems()) {
        input.add(((LinearList.SelectableButton)e).text);
      }
      String[] a=new String[input.size()];
      converter.convertAll(input.toArray(a), ((TextBox)KyUI.get("mp3_output")).getText(), ((DropDown)KyUI.get("mp3_format")).text, ((DropDown)KyUI.get("mp3_codec")).text, ((TextBox)KyUI.get("mp3_bitrate")).valueI, ((ImageToggleButton)KyUI.get("mp3_stereo")).value?2:1, ((TextBox)KyUI.get("mp3_samplerate")).valueI);
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("set_apply")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      currentLedEditor.resize(((TextBox)KyUI.get("set_buttony")).valueI, ((TextBox)KyUI.get("set_buttonx")).valueI);
      setInfoLed(currentLedEditor.info);
      currentLedEditor.displayPad.size.set(info.buttonX, info.buttonY);
      currentLedEditor.displayPad.invalidate();
      ((TextBox)KyUI.get("set_buttony")).onTextChangeListener.onEvent(((TextBox)KyUI.get("set_buttony")));
      ((TextBox)KyUI.get("set_buttonx")).onTextChangeListener.onEvent(((TextBox)KyUI.get("set_buttonx")));
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("set_midi")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      MidiCommand.reloadDevices(joinPath(path_global, "midi"));//#Change
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("set_navercafe")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      link ("https://cafe.naver.com/unipad");
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("info_github")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      link ("https://github.com/EX867/PositionWriter");
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("info_processing")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      link ("https://processing.org");
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("info_ex867")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      link ("https://blog.naver.com/ghh2000");
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("info_ulm")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      link ("https://blog.naver.com/jehongjeon");
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("info_asdf")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      link ("https://ex867.github.io/asdf");
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("set_navercafe")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      link ("http://cafe.naver.com/unipad");
      return false;
    }
  }
  );
  ((Button)KyUI.get("set_globalpath")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      openFileExplorer(path_global);
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("set_info")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.addLayer(frame_info);
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("set_tips")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.addLayer(frame_tips);
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("info_exit")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.removeLayer();
      return false;
    }
  }
  );
  ((Button)KyUI.get("update_content")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      link ("https://github.com/EX867/PositionWriter/releases");
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("update_exit")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.removeLayer();
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("tips_exit")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.removeLayer();
      return false;
    }
  }
  );
  ((DropDown)KyUI.get("set_mode")).setSelectListener(new ItemSelectListener() {
    public void onEvent(int index) {
      InputMode=index+1;//index is 0 to 2
      export_settings();
    }
  }
  );
  ((ImageToggleButton)KyUI.get("led_inframeinput")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      InFrameInput=((ImageToggleButton)KyUI.get("led_inframeinput")).value;
      return false;
    }
  }
  );
  ((ToggleButton)KyUI.get("set_autosave")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      AutoSave=((ToggleButton)KyUI.get("set_autosave")).value;
      export_settings();
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("led_playstop")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      if (currentLed.led.loopStart<currentLed.led.loopEnd) {
        if (currentLedEditor.displayTime>=currentLed.led.loopEnd) {
          currentLedEditor.displayTime=currentLed.led.loopStart;
          currentLedEditor.setFrameByTime();
        }
      } else {
        if (currentLedEditor.displayFrame>=currentLedEditor.DelayPoint.size()-1) {
          currentLedEditor.displayFrame=0;
          currentLedEditor.setTimeByFrame();
        }
      }
      if (currentLed.led.active) {
        if (currentLed.led.paused) {
          currentLed.light.unPause(currentLed.led);
        } else {
          currentLed.light.pause(currentLed.led);
        }
      } else {
        currentLed.light.start(currentLed.led, currentLedEditor.displayTime);
      }
      return false;
    }
  }
  );
  ((ImageToggleButton)KyUI.get("led_loop")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      currentLed.led.loop=((ImageToggleButton)KyUI.get("led_loop")).value;
      return false;
    }
  }
  );
  ((ImageToggleButton)KyUI.get("ks_loop")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      currentKs.loop=((ImageToggleButton)KyUI.get("ks_loop")).value;
      return false;
    }
  }
  );
  ((Button)KyUI.get("led_printq")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      action_print.accept(userMacro1.replace("\\r", "\r").replace("\\t", "\t").replace("\\n", "\n").replace("\\\\", "\\"));
      currentLedEditor.editor.invalidate();
      return false;
    }
  }
  );
  ((Button)KyUI.get("led_printe")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      action_print.accept(userMacro2);
      currentLedEditor.editor.invalidate();
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("led_next")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      //if (findData.size()!=0) {
      //  if (patternMatcher.findUpdated==false)findData=patternMatcher.findAll( keyled_textEditor.current.toString());
      //  findIndex=findIndex+1;
      //  if (findIndex>=findData.size())findIndex=0;
      //  if (findData.size()>0) {
      //    currentLedEditor.setCursorByIndex(findData.get(findIndex).startpoint);
      //    currentLedEditor.selectFromCursor(findData.get(findIndex).text.length());
      //    currentLedEditor.editor.moveToCursor();
      //  }
      //}
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("led_previous")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      //if (findData.size()!=0) {
      //  if (patternMatcher.findUpdated==false)findData=patternMatcher.findAll(keyled_textEditor.current.toString());
      //  findIndex=findIndex-1;
      //  if (findIndex<0)findIndex=findData.size()-1;
      //  if (findData.size()>0) {
      //    keyled_textEditor.current.setCursorByIndex(findData.get(findIndex).startpoint);
      //    keyled_textEditor.current.selectFromCursor(findData.get(findIndex).text.length());
      //    focus=keyled_textEditor.ID;
      //    keyled_textEditor.moveToCursor();
      //  }
      //}
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("led_replaceall")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      //patternMatcher.registerFind(((TextBox)UI[getUIid("I_FINDTEXTBOX")]).text, value);
      //patternMatcher.registerReplace(((TextBox)UI[getUIid("I_REPLACETEXTBOX")]).text, value);
      //findData=patternMatcher.findAll(keyled_textEditor.current.toString());//WARNING!!!
      //RecordLog();
      //keyled_textEditor.setText(patternMatcher.replaceAll(keyled_textEditor.current.toString(), ((TextBox)UI[getUIid("I_REPLACETEXTBOX")]).text, findData));
      //RecordLog();
      //title_edited="*";
      return false;
    }
  }
  );
  ((ImageToggleButton)KyUI.get("led_calcmode")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      //patternMatcher.registerFind(((TextBox)I[getUIid("I_FINDTEXTBOX")]).text, value);
      //patternMatcher.registerReplace(((TextBox)UI[getUIid("I_REPLACETEXTBOX")]).text, value);
      //findData=patternMatcher.findAll(keyled_textEditor.current.toString());//WARNING!!!
      return false;
    }
  }
  );
  ((TextBox)KyUI.get("set_buttonx")).setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      TextBox t=(TextBox)e;
      ui_textValueRange(t, 1, PAD_MAX);
      if (t.valueI!=currentLedEditor.info.buttonY) {
        t.rightText="*";
      } else {
        t.rightText="";
      }
    }
  }
  );
  ((TextBox)KyUI.get("set_buttony")).setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      TextBox t=(TextBox)e;
      ui_textValueRange(t, 1, PAD_MAX);
      if (t.valueI!=currentLedEditor.info.buttonX) {
        t.rightText="*";
      } else {
        t.rightText="";
      }
    }
  }
  );
  ((TextBox)KyUI.get("set_autosavedelay")).setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      ui_textValueRange((TextBox)e, 10, 86000);
      AutoSaveTime=((TextBox)e).valueI;
      export_settings();
    }
  }
  );
  ((TextBox)KyUI.get("set_textsize")).setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      ui_textValueRange((TextBox)e, 1, 150);
      for (LedTab t : ledTabs) {
        t.led.script.editor.textSize=((TextBox)e).valueI;
        t.led.script.editor.updateSlider();
      }
      export_settings();
    }
  }
  );
  ((TextBox)KyUI.get("set_dbuttonx")).setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      ui_textValueRange((TextBox)e, 1, PAD_MAX);
      export_settings();
    }
  }
  );
  ((TextBox)KyUI.get("set_dbuttony")).setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      ui_textValueRange((TextBox)e, 1, PAD_MAX);
      export_settings();
    }
  }
  );
  //((Slider)KyUI.get("set_resolution")).setAdjustListener(new EventListener() {//no use
  //  public void onEvent(Element e) {
  //  }
  //});
  ((ToggleButton)KyUI.get("set_reload")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      export_settings();
      return false;
    }
  }
  );
  ((ToggleButton)KyUI.get("set_printonpress")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      PrintOnPress=((ToggleButton)KyUI.get("set_printonpress")).value;
      export_settings();
      return false;
    }
  }
  );
  //if () {
  //} else if (name.equals("I_FINDTEXTBOX")) {
  //  patternMatcher.findUpdated=false;
  //  patternMatcher.registerFind(text, ((Button)UI[getUIidRev("I_CALCULATE")]).value);
  //  findData=patternMatcher.findAll(keyled_textEditor.current.toString());//WARNING!!!
  //} else if (name.equals("I_REPLACETEXTBOX")) {
  //  patternMatcher.registerReplace(text, ((Button)UI[getUIidRev("I_CALCULATE")]).value);
  //} else if (name.equals("KS_SOUNDMULTI")) {
  //  KS.get(ksChain)[ksX][ksY].multiSound=min(max(1, value), KS.get(ksChain)[ksX][ksY].ksSound.size())-1;
  //} else if (name.equals("KS_LEDMULTI")) {
  //  KS.get(ksChain)[ksX][ksY].multiLed=min(max(1, value), KS.get(ksChain)[ksX][ksY].ksLedFile.size())-1;
  //  KS.get(ksChain)[ksX][ksY].multiLedBackup=KS.get(ksChain)[ksX][ksY].multiLed;
  //} else if (name.equals("KS_LOOP")) {
  //  if (soundLoopEdit) {
  //    if (((ScrollList)UI[getUIid("I_SOUNDVIEW")]).selected==-1)return;
  //    KS.get(ksChain)[ksX][ksY].ksSoundLoop.set(((ScrollList)UI[getUIid("I_SOUNDVIEW")]).selected, value);
  //  } else {
  //    if (((ScrollList)UI[getUIid("I_LEDVIEW")]).selected==-1)return;
  //    KS.get(ksChain)[ksX][ksY].ksLedLoop.set(((ScrollList)UI[getUIid("I_LEDVIEW")]).selected, value);
  //  }
  //} else if (name.equals("SKIN_PACKAGE")) {
  //  description.content="com.kimjisub.launchpad.theme."+text;
  //}
  //if () {
  //} else if (name.equals("I_CLEARKEYSOUND")) {
  //  int a=0;
  //  while (a<ksDisplay.length) {
  //    int b=0;
  //    while (b<ksDisplay[a].length) {
  //      ksDisplay[a][b]=OFFCOLOR;
  //      b=b+1;
  //    }
  //    a=a+1;
  //  }
  //  while (ledstack.size()>0) {
  //    ledstack.get(ledstack.size()-1).isInStack=false;
  //    ledstack.remove(ledstack.size()-1);
  //  }
  //  a=0;
  //  while (a<ButtonX) {
  //    int b=0;
  //    while (b<ButtonY) {
  //      KS.get(ksChain)[a][b].stopSound();
  //      b=b+1;
  //    }
  //    a=a+1;
  //  }
  //  midiOffAll();
  //  int id=getUIidRev("KS_SOUNDMULTI");
  //  ((TextBox)UI[id]).value=max(1, min(KS.get(ksChain)[X][Y].multiSound, KS.get(ksChain)[X][Y].ksSound.size()));
  //  ((TextBox)UI[id]).text=""+((TextBox)UI[id]).value;
  //  UI[id].render();
  //  id=getUIidRev("KS_LEDMULTI");
  //  ((TextBox)UI[id]).value=max(1, min(KS.get(ksChain)[X][Y].multiLed, KS.get(ksChain)[X][Y].ksLedFile.size()));
  //  ((TextBox)UI[id]).text=""+((TextBox)UI[id]).value;
  //  UI[id].render();
  //  UI[getUIid("KEYSOUND_PAD")].render();
  //  setStatusR("Cleared");
  //} else if (name.equals("I_RELOADKEYSOUND")) {
  //  for (int a=0; a<Chain; a++) {
  //    for (int b=0; b<ButtonX; b++) {
  //      for (int c=0; c<ButtonY; c++) {
  //        KS.get(a)[b][c].reloadLeds();
  //      }
  //    }
  //  }
  //  setStatusR("Reloaded");
  //} else if (name.equals("MP3_CONVERT")) {
  //  int a=0;
  //  boolean valid=true;
  //  File file=new File(((TextBox)UI[getUIidRev("MP3_OUTPUT")]).text);
  //  if (file.isDirectory()==false) {
  //    if (file.mkdirs()) {
  //    } else valid=false;
  //  }
  //  if (((ScrollList)UI[getUIidRev("MP3_FORMAT")]).selected==-1)valid=false;
  //  if (((ScrollList)UI[getUIidRev("MP3_CODEC")]).selected==-1)valid=false;
  //  ScrollList input=(ScrollList)UI[getUIidRev("MP3_INPUT")];
  //  if (valid) {//outputFormat, outputCodec, outputBitRate, outputChannels, outputSampleRate
  //    UI[getUIid("LOG_EXIT")].disabled=true;
  //    ((Logger)UI[getUIid("LOG_LOG")]).logs.clear();
  //    Frames[getFrameid("F_LOG")].prepare(currentFrame);
  //    int channels=2;
  //    if (((Button)UI[getUIidRev("MP3_STEREO")]).value==false)channels=1;
  //    //println("ready to convert");
  //    converter.convertAll(input.View, ((TextBox)UI[getUIidRev("MP3_OUTPUT")]).text, ((ScrollList)UI[getUIidRev("MP3_FORMAT")]).getSelection(), ((ScrollList)UI[getUIidRev("MP3_CODEC")]).getSelection(), ((TextBox)UI[getUIidRev("MP3_BITRATE")]).value, channels, ((TextBox)UI[getUIidRev("MP3_SAMPLERATE")]).value);
  //  } else printLog("convert()", "file is not convertable");
  //} else if (name.equals("MP3_PLAY")) {
  //  if (((ScrollList)UI[getUIid("MP3_INPUT")]).selected!=-1) {//inefficient!!!
  //    if (converter.converterPlayer.fileLoaded)SampleManager.removeSample(converter.converterPlayer.sample);
  //    converter.converterPlayer.load(((ScrollList)UI[getUIid("MP3_INPUT")]).getSelection());
  //    converter.converterPlayer.setValue(converter.converterPlayer.slider.valueF);
  //  }
  //  if (converter.converterPlayer.fileLoaded) {
  //    converter.converterPlayer.loop(converter.converterPlayer.loop);
  //    converter.converterPlayer.play();
  //  }
  //} else if (name.equals("MP3_STOP")) {
  //  converter.converterPlayer.stop();
  //} else if (name.equals("MP3_LOOP")) {
  //  converter.converterPlayer.setLoopStart(0);
  //  converter.converterPlayer.setLoopEnd(converter.converterPlayer.length);
  //  converter.converterPlayer.loop(value);
  //} else if (name.equals("MP3_EXIT")) {
  //  ((ScrollList)UI[getUIid("MP3_INPUT")]).setItems(new String[0]);
  //  Frames[currentFrame].returnBack();
  //} else if (name.equals("LOG_EXIT")) {
  //  ((ScrollList)UI[getUIid("MP3_INPUT")]).setItems(new String[0]);
  //  Frames[currentFrame].returnBack();
  //} else if (name.equals("ERROR_EXIT")) {
  //  Frames[currentFrame].returnBack();
  //} else if (name.equals("INFO_EXIT")) {
  //  Frames[currentFrame].returnBack();
  //} else if (name.equals("INFO_GITHUBLINK")) {
  //  link ("https://github.com/EX867/PositionWriter");
  //} else if (name.equals("INFO_PROCESSINGLINK")) {
  //  link ("https://processing.org");
  //} else if (name.equals("INFO_DEVELOPERLINK")) {
  //  link ("https://blog.naver.com/ghh2000");
  //} else if (name.equals("INFO_JEONJEHONGLINK")) {
  //  link ("https://blog.naver.com/jehongjeon");
  //} else if (name.equals("INFO_ASDFLINK")) {
  //  link ("https://EX867.github.io/PositionWriter/asdf");
  //} else if (name.equals("UN_LOGIN")) {
  //  resetFocusBeforeFrame();
  //  Frames[getFrameid("F_LOGIN")].prepare(currentFrame);
  //} else if (name.equals("UN_PRIVATE")) {
  //  //do nothing=
  //} else if (name.equals("UN_EXIT")) {
  //  Frames[currentFrame].returnBack();
  //} else if (name.equals("UN_UPLOAD")) {
  //  resetFocusBeforeFrame();
  //  tempCode=DIALOG_UPLOAD;
  //  Frames[getFrameid("F_DIALOG")].prepare(currentFrame);
  //} else if (name.equals("UN_UPDATE")) {
  //  resetFocusBeforeFrame();
  //  tempCode=DIALOG_UPDATE;
  //  Frames[getFrameid("F_DIALOG")].prepare(currentFrame);
  //} else if (name.equals("UN_DELETE")) {
  //  resetFocusBeforeFrame();
  //  tempCode=DIALOG_DELETE;
  //  Frames[getFrameid("F_DIALOG")].prepare(currentFrame);
  //} else if (name.equals("UN_DOWNLOAD")) {
  //  resetFocusBeforeFrame();
  //  tempCode=DIALOG_DOWNLOAD;
  //  Frames[getFrameid("F_DIALOG")].prepare(currentFrame);
  //} else if (name.equals("DIALOG_EXIT")) {
  //  tempCode=0;//no happens
  //  Frames[currentFrame].returnBack();
  //} else if (name.equals("DIALOG_OK")) {
  //  if (tempCode==DIALOG_UPLOAD) {
  //    uncloud_upload(((ScrollList)UI[getUIidRev("UN_LIST")]).selected);
  //  } else if (tempCode==DIALOG_UPDATE) {
  //    uncloud_update(((ScrollList)UI[getUIidRev("UN_LIST")]).selected);
  //  } else if (tempCode==DIALOG_DELETE) {
  //    uncloud_delete(((ScrollList)UI[getUIidRev("UN_LIST")]).selected);
  //  } else if (tempCode==DIALOG_DOWNLOAD) {
  //    uncloud_download(((ScrollList)UI[getUIidRev("UN_LIST")]).selected);
  //  }
  //  tempCode=0;
  //  Frames[currentFrame].returnBack();
  //} else if (name.equals("UPDATE_UPDATE")) {
  //  link("https://github.com/EX867/PositionWriter/releases");
  //  Frames[currentFrame].returnBack();
  //} else if (name.equals("UPDATE_EXIT")) {
  //  Frames[currentFrame].returnBack();
  //} else if (name.equals("SKIN_BUILD")) {
  //  String packageText="com.kimjisub.launchpad.theme."+((TextBox)UI[getUIidRev("SKIN_PACKAGE")]).text;
  //  String appnameText=filterString(((TextBox)UI[getUIidRev("SKIN_APPNAME")]).text, new String[]{"\\", "/", ":", "*", "?", "\"", "<", ">", "|"});
  //  if (appnameText.equals("")==false&&isValidPackageName(packageText)) {
  //    resetFocusBeforeFrame();
  //    Frames[getFrameid("F_ERROR")].prepare(currentFrame);
  //    build_windows(packageText, appnameText, ((TextBox)UI[getUIidRev("SKIN_AUTHOR")]).text, ((TextBox)UI[getUIidRev("SKIN_DESCRIPTION")]).text, ((TextBox)UI[getUIidRev("SKIN_TITLE")]).text, ((TextBox)UI[getUIidRev("SKIN_VERSION")]).text, ((Button)UI[getUIidRev("SKIN_TEXT1")]).colorInfo);
  //  }
  //} else if (name.equals("SKIN_EXIT")) {
  //  Frames[currentFrame].returnBack();
  //} else if (name.equals("INITIAL_HOWTOUSE")) {
  //  link("https://github.com/EX867/PositionWriter/wiki/How-to-use-v2-(english)");
  //}
}