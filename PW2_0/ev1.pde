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
      KyUI.addLayer(frame_skinedit);
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
      println(MidiCommand.reloadDevices(joinPath(getDataPath(), "midi")));//change
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
      currentLedEditor.editor.onTextChangeListener.onEvent(currentLedEditor.editor);
      currentLedEditor.editor.invalidate();
      return false;
    }
  }
  );
  ((Button)KyUI.get("led_printe")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      action_print.accept(userMacro2);
      currentLedEditor.editor.onTextChangeListener.onEvent(currentLedEditor.editor);
      currentLedEditor.editor.invalidate();
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("led_next")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      LedFindReplace f=ledFindReplace;
      if (f.textChanged) {
        f.findAll(currentLedEditor.editor.getText());
      }
      if (f.findData.size()!=0) {
        f.findIndex=f.findIndex+1;
        if (f.findIndex>=f.findData.size())f.findIndex=0;
        if (f.findData.size()>0) {
          currentLedEditor.setCursorByIndex(f.findData.get(f.findIndex).start);
          currentLedEditor.selectFromCursor(f.findData.get(f.findIndex).text.length());
          currentLedEditor.editor.moveToCursor();
          currentLedEditor.editor.invalidate();
        }
      }
      ((TextBox)KyUI.get("led_findtext")).rightText="("+(ledFindReplace.findIndex+1)+"/"+ledFindReplace.findData.size()+")";
      KyUI.get("led_findtext").invalidate();
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("led_previous")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      LedFindReplace f=ledFindReplace;
      if (f.textChanged) {
        f.findAll(currentLedEditor.editor.getText());
      }
      if (f.findData.size()!=0) {
        f.findIndex=f.findIndex-1;
        if (f.findIndex<0)f.findIndex=f.findData.size()-1;
        if (f.findData.size()>0) {
          currentLedEditor.setCursorByIndex(f.findData.get(f.findIndex).start);
          currentLedEditor.selectFromCursor(f.findData.get(f.findIndex).text.length());
          currentLedEditor.editor.moveToCursor();
          currentLedEditor.editor.invalidate();
        }
      }
      ((TextBox)KyUI.get("led_findtext")).rightText="("+(ledFindReplace.findIndex+1)+"/"+ledFindReplace.findData.size()+")";
      KyUI.get("led_findtext").invalidate();
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("led_replaceall")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      if (ledFindReplace.textChanged) {
        ledFindReplace.findAll(currentLedEditor.editor.getText());
      }
      currentLedEditor.editor.recordHistory();
      currentLedEditor.editor.setText(ledFindReplace.replaceAll(currentLedEditor.editor.getText()));
      currentLedEditor.editor.recordHistory();
      return false;
    }
  }
  );
  ((ImageToggleButton)KyUI.get("led_calcmode")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      ((TextBox)KyUI.get("led_findtext")).onTextChangeListener.onEvent(KyUI.get("led_findtext"));
      ((TextBox)KyUI.get("led_replacetext")).onTextChangeListener.onEvent(KyUI.get("led_replacetext"));
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
  ((TextBox)KyUI.get("led_findtext")).setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      ledFindReplace.compileFind(((TextBox)e).getText(), ((ImageToggleButton)KyUI.get("led_calcmode")).value, currentLedEditor.editor.getText());
      ((TextBox)e).error=ledFindReplace.patternFind.error;
      ((TextBox)KyUI.get("led_findtext")).rightText="("+(ledFindReplace.findIndex+1)+"/"+ledFindReplace.findData.size()+")";
      KyUI.get("led_findtext").invalidate();
      e.invalidate();
    }
  }
  );
  ((TextBox)KyUI.get("led_replacetext")).setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      ledFindReplace.compileReplace(((TextBox)e).getText(), ((ImageToggleButton)KyUI.get("led_calcmode")).value);
      ((TextBox)e).error=ledFindReplace.patternReplace.error;
      e.invalidate();
    }
  }
  );
}