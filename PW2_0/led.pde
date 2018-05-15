java.util.function.Consumer<String> action_print;
java.util.function.BiConsumer<IntVector2, IntVector2> action_on;
java.util.function.BiConsumer<IntVector2, IntVector2> action_off;
java.util.function.Consumer<IntVector2> action_autoInput;
void led_setup() {
  final TextBox changetitle_edit=((TextBox)KyUI.get("changetitle_edit"));
  final ImageButton changetitle_exit=((ImageButton)KyUI.get("changetitle_exit"));
  ((Button)KyUI.get("led_changetitle")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      externalFrame=LED_CHANGETITLE;
      KyUI.addLayer(frame_changetitle);
      changetitle_edit.setText(currentLedEditor.file.getAbsolutePath().replace("\\", "/"));
      final String before=currentLedEditor.file.getAbsolutePath();
      changetitle_edit.onTextChangeListener=new EventListener() {
        public void onEvent(Element e) {
          String text=changetitle_edit.getText().replace("\\", "/");
          boolean er=!isValidFileName(text);
          for (LedTab t : ledTabs) {//anti duplication
            if (t!=currentLed&&t.led.script.file.getAbsolutePath().replace("\\", "/").equals(text)) {
              er=true;
              break;
            }
          }
          changetitle_edit.error=er;
        }
      };
      changetitle_exit.setPressListener(new MouseEventListener() {
        public boolean onEvent(MouseEvent e, int index) {
          if (!changetitle_edit.error) {
            currentLedEditor.file=new File(changetitle_edit.getText());
            String after=currentLedEditor.file.getAbsolutePath();
            if (!before.equals(after)) {
              if (!currentLedEditor.file.isFile()&&currentLedEditor.empty()) {
                currentLedEditor.setChanged(false, true);
              } else {
                currentLedEditor.setChanged(true, true);
              }
            }
            KyUI.removeLayer();
            externalFrame=NONE;
          }
          return false;
        }
      }
      );
      return false;
    }
  }
  );
  action_print=new java.util.function.Consumer<String>() {
    public void accept(String in) {
      int line=currentLedEditor.lines()-1;
      int point=0;
      if (InFrameInput&&currentLedEditor.displayFrame<currentLedEditor.DelayPoint.size()-1) {
        line=currentLedEditor.DelayPoint.get(currentLedEditor.displayFrame+1)-1;
      }
      if (line<0) {
        line=0;
        point=0;
        if (in.length()>0&&in.charAt(0)=='\n') {
          in=in.substring(1, in.length())+"\n";
        }
      } else {
        point=currentLedEditor.getLine(line).length();
      }
      if (line==0&&point==0) {
        in=in.substring(1, in.length());
      }
      currentLedEditor.insert(line, point, in);
      currentLedEditor.editor.recordHistory();
    }
  };
  action_on=new java.util.function.BiConsumer<IntVector2, IntVector2>() {
    public void accept(IntVector2 click, IntVector2 coord) {//#ADD inframeinput and start cut
      String pos;
      if (click==null) {
        pos=(coord.y+1)+" "+(coord.x+1);
      } else {//range commands
        pos=(min(click.y, coord.y)+1)+"~"+(max(click.y, coord.y)+1)+" "+(min(click.x, coord.x)+1)+"~"+(max(click.x, coord.x)+1);
      }
      if (currentLedEditor.cmdset==ledCommands) {
        if (ColorMode==VEL) {
          action_print.accept("\non "+pos+" auto "+SelectedColor);
        } else if (ColorMode==HTML) {
          action_print.accept("\non "+pos+" "+hex(SelectedColor, 6));
        }
      } else if (currentLedEditor.cmdset==apCommands) {
        action_print.accept("\non "+pos);
      }
    }
  };
  action_off=new java.util.function.BiConsumer<IntVector2, IntVector2>() {
    public void accept(IntVector2 click, IntVector2 coord) {
      String pos;
      if (click==null) {
        pos=(coord.y+1)+" "+(coord.x+1);
      } else {//range commands
        pos=(min(click.y, coord.y)+1)+"~"+(max(click.y, coord.y)+1)+" "+(min(click.x, coord.x)+1)+"~"+(max(click.x, coord.x)+1);
      }
      action_print.accept("\noff "+pos);
    }
  };
  action_autoInput=new java.util.function.Consumer<IntVector2>() {
    public void accept(IntVector2 coord) {
      int line=currentLedEditor.getCommands().size();
      int frame=currentLedEditor.LED.size()-1;
      if (InFrameInput) {
        if (currentLedEditor.displayFrame<currentLedEditor.DelayPoint.size()-1)line=currentLedEditor.DelayPoint.get(currentLedEditor.displayFrame+1);
      }
      int aframe=currentLedEditor.getFrame(line);
      int a;
      for (a=line-1; a>=0&&a>currentLedEditor.DelayPoint.get(aframe); a--) {
        Command cmd= currentLedEditor.getCommands().get(a);
        if (cmd instanceof OnCommand) {
          LightCommand info=(LightCommand)cmd;
          if (info.x1<=coord.x+1&&coord.x+1<=info.x2&&info.y1<=coord.y+1&&coord.y+1<=info.y2) {
            if (info.x1==info.x2&&info.y1==info.y2) {
              if (a==0&&currentLedEditor.lines()==1) {
                currentLedEditor.setLine(0, "");
              } else {
                currentLedEditor.deleteLine(a);
              }
            } else {
              action_off.accept(null, coord);
            }
            return;
          }
        } else if (cmd instanceof OffCommand) {
          LightCommand info=(LightCommand)cmd;
          if (info.x1<=coord.x+1&&coord.x+1<=info.x2&&info.y1<=coord.y+1&&coord.y+1<=info.y2) {
            if (info.x1==info.x2&&info.y1==info.y2) {
              if (a==0&&currentLedEditor.lines()==1) {
                currentLedEditor.setLine(0, "");
              } else {
                currentLedEditor.deleteLine(a);
              }
            }
            if (color_vel[SelectedColor]!=currentLedEditor.LED.get(frame)[coord.x][coord.y])action_on.accept(null, coord);//not same
            return;
          }
        }
      }
      for (a--; a>=0; a--) {
        Command cmd= currentLedEditor.getCommands().get(a);
        if (cmd instanceof OnCommand) {
          LightCommand info=(LightCommand)cmd;
          if (info.x1<=coord.x+1&&coord.x+1<=info.x2&&info.y1<=coord.y+1&&coord.y+1<=info.y2) {
            action_off.accept(null, coord);
            return;
          }
        } else if (cmd instanceof OffCommand) {
          LightCommand info=(LightCommand)cmd;
          if (info.x1<=coord.x+1&&coord.x+1<=info.x2&&info.y1<=coord.y+1&&coord.y+1<=info.y2) {
            break;
          }
        }
      }
      action_on.accept(null, coord);
    }
  };
  ((PadButton)KyUI.get("led_pad")).buttonListener=new PadButton.ButtonListener() {
    public void accept(IntVector2 click, IntVector2 coord, int action) {//only sends in-range events.
      boolean edited=false;
      if (InputMode==AUTOINPUT) {
        if ((!PrintOnPress&&action==PadButton.RELEASE_L)||(PrintOnPress&&action==PadButton.PRESS_L)) {
          edited=true;
          for (int b=min(coord.y, click.y); b<=max(coord.y, click.y); b++) {
            for (int a=min(coord.x, click.x); a<=max(coord.x, click.x); a++) {
              action_autoInput.accept(new IntVector2(a, b));
            }
          }
        }
      } else if (InputMode==RIGHTOFFMODE) {
        if ((!PrintOnPress&&action==PadButton.RELEASE_L)||(PrintOnPress&&action==PadButton.PRESS_L)) {
          edited=true;
          if (click.equals(coord)) {
            action_on.accept(null, coord);
          } else {
            action_on.accept(click, coord);
          }
        } else if ((!PrintOnPress&&action==PadButton.RELEASE_R)||(PrintOnPress&&action==PadButton.PRESS_R)) {
          edited=true;
          if (click.equals(coord)) {
            action_off.accept(null, coord);
          } else {
            action_off.accept(click, coord);
          }
        }
      }
      if (edited) {
        currentLedEditor.editor.updateSlider(); 
        currentLedEditor.editor.invalidate();
      }
    }
  };
  VelocityType=((VelocityButton)KyUI.get("led_lp"));
  VelocityType.colorSelectListener=new EventListener() {
    public void onEvent(Element e) {
      ColorMode=VEL;
      ((ColorPickerFull)KyUI.get("led_cp")).setSelectable(false);
      ((VelocityButton)e).selectionVisible=true;
      SelectedColor=((VelocityButton)e).selectedVelocity;
      VelocityType=(VelocityButton)e;
    }
  };
  ((VelocityButton)KyUI.get("led_mf")).colorSelectListener=VelocityType.colorSelectListener;
  ((ColorPickerFull)KyUI.get("led_cp")).colorSelectListener=new EventListener() {
    public void onEvent(Element e) {
      ColorMode=HTML;
      ((ColorPickerFull)KyUI.get("led_cp")).setSelectable(true);
      ((VelocityButton)KyUI.get("led_lp")).selectionVisible=false;
      SelectedColor=((ColorButton)e).c;
    }
  };
  fs=((FrameSlider)KyUI.get("led_frameslider"));
  fsTime=((Button)KyUI.get("led_time"));
  fs.setAdjustListener(new EventListener() {
    public void onEvent(Element e) {
      synchronized(currentLedEditor) {
        currentLedEditor.displayTime=fs.valueI;
        fsTime.text=currentLedEditor.displayTime+"/"+fs.maxI;
        currentLedEditor.setFrameByTime();
        // fs.set(currentLedEditor.getTimeByFrame(currentLedEditor.displayFrame));
        currentLedEditor.FrameSliderBackup=currentLedEditor.displayTime;//user input
        currentLedEditor.displayPad.displayControl(currentLedEditor.LED.get(currentLedEditor.displayFrame));
        currentLed.light.midiControl(currentLedEditor.velLED.get(currentLedEditor.displayFrame));
      }
      currentLedEditor.displayPad.invalidate();
      fsTime.invalidate();
    }
  }
  );
  fs.loopAdjustListener=new EventListener() {
    public void onEvent(Element e) {
      //synchronized(currentLedEditor) {
      currentLed.led.loopStart=fs.valueS;
      currentLed.led.loopEnd=fs.valueE;
      if (currentLed.led.loopStart>=currentLed.led.loopEnd) {//no loop range
        currentLedEditor.loopStartRange.startLine=0;
        currentLedEditor.loopStartRange.endLine=0;
        currentLedEditor.loopEndRange.startLine=0;
        currentLedEditor.loopEndRange.endLine=0;
      } else {
        int startFrame=currentLedEditor.getFrameByTime(fs.valueS);
        int endFrame=currentLedEditor.getFrameByTime(fs.valueE);
        currentLedEditor.loopStartRange.startLine=currentLedEditor.DelayPoint.get(startFrame)+1;
        if (startFrame+1<currentLedEditor.DelayPoint.size()) {
          currentLedEditor.loopStartRange.endLine=currentLedEditor.DelayPoint.get(startFrame+1)+1;
        } else {
          currentLedEditor.loopStartRange.endLine=currentLedEditor.editor.script.lines();
        }
        currentLedEditor.loopEndRange.startLine=currentLedEditor.DelayPoint.get(endFrame)+1;
        if (endFrame+1<currentLedEditor.DelayPoint.size()) {
          currentLedEditor.loopEndRange.endLine=currentLedEditor.DelayPoint.get(endFrame+1)+1;
        } else {
          currentLedEditor.loopEndRange.endLine=currentLedEditor.editor.script.lines();
        }
      }
      //}
      currentLedEditor.editor.getSlider().invalidate();
    }
  };
  fs.frameMarker=new ExtendedRenderer() {
    public void render(PGraphics g) {
      int sum=0;
      float size=(fs.pos.right-fs.pos.left-2*fs.padding);
      for (int a=1; a < currentLedEditor.DelayPoint.size(); a++) {
        sum=sum + currentLedEditor.getDelayValue(currentLedEditor.DelayPoint.get(a));
        g.line(fs.pos.left + fs.padding+size * sum / (fs.maxI - fs.minI), fs.pos.top+fs.padding+2, fs.pos.left +  fs.padding+size * sum / (fs.maxI - fs.minI), fs.pos.bottom-fs.padding-2);
      }
      g.strokeWeight(2);
      g.stroke(0, 255, 0);
      g.line(fs.pos.left + fs.padding+size * currentLedEditor.FrameSliderBackup / (fs.maxI - fs.minI), fs.pos.top+fs.padding+2, fs.pos.left +  fs.padding+size * currentLedEditor.FrameSliderBackup / (fs.maxI - fs.minI), (fs.pos.top+fs.pos.bottom)/2);
      //if(StartFromCursor)g.line(fs.pos.left + fs.padding+size * currentLedEditor.FrameSliderBackup / (fs.maxI - fs.minI), fs.pos.top+fs.padding+2, fs.pos.left +  fs.padding+size * currentLedEditor.FrameSliderBackup / (fs.maxI - fs.minI), (fs.pos.top+fs.pos.bottom)/2);
      //if(AutoStop)g.line(fs.pos.left + fs.padding+size* currentLedEditor.FrameSliderBackup / (fs.maxI - fs.minI), (fs.pos.top+fs.pos.bottom)/2, fs.pos.left + fs.padding+size * currentLedEditor.FrameSliderBackup / (fs.maxI - fs.minI), fs.pos.bottom-fs.padding-2);
    }
  };
  fs.unholdListener=new EventListener() {
    public void onEvent(Element e) {
      currentLed.light.unhold();
    }
  };
  ((TabLayout)KyUI.get("led_filetabs")).tabSelectListener=new ItemSelectListener() {
    public void onEvent(int index) {
      selectLedTab(index-1);
      KyUI.get("led_frame").invalidate();
    }
  };
  ((TabLayout)KyUI.get("led_filetabs")).tabRemoveListener=new ItemSelectListener() {
    public void onEvent(int index) {
      ledTabs.get(index).light.active=false;
      println("remove : "+ledTabs.get(index).led.script.name);
      ledTabs.remove(index);
      if (ledTabs.size()==0) {
        addLedTab(createNewLed());
      }
      led_filetabs.onLayout();
    }
  };
  ((TabLayout)KyUI.get("led_filetabs")).addTabListener=new EventListener() {
    public void onEvent(Element e) {
      addLedTab(createNewLed());
    }
  };
}
String readLed(String filename) {//must file exists.
  final String ext=getFileExtension(filename);
  if (ext.equals("png")) {
    return PngToLed(loadImage(filename));
  } else if (ext.equals("gif")) {
    return GifToLed(filename);
  } else if (ext.equals("mid")) {
    return MidiToLed(filename);
  } else {
    return readFile(filename);
  }
}
void saveLed(final LedScript led) { 
  if (led.changed) {
    final String filename=led.file.getAbsolutePath();
    final String ext=getFileExtension(filename);
    if (ext.equals("png")||ext.equals("gif")||ext.equals("mid")) {//you cant save these. export it then save it.
      return;
    }
    saveFileTo(filename, new Runnable() {
      public void run() {
        if (ext.equals("png")) {
          LedToPng(led, led.displayFrame).save(filename);
        } else if (ext.equals("gif")) {
          LedToGif(filename, led);
        } else if (ext.equals("mid")) {
          LedToMidi(filename, led);//TEST
        } else {
          writeFile(filename, led.toString());
        }
      }
    }
    );
    led.setChanged(false, false);
    led.lastSaveTime=new File(filename).lastModified();
  }
}
void exportLed(final LedScript led) {//save as led for now. FIX to file name based file type save
  String filename_=getNotDuplicatedFilename(joinPath(joinPath(path_global, path_led), getFileName(led.file.getAbsolutePath())));
  final String filename;
  if (filename_.endsWith(".mid")||filename_.endsWith(".png")||filename_.endsWith(".gif")) {
    filename=filename_.substring(0, filename_.length()-3)+"led";
  } else {
    filename=filename_;
  }
  saveFileTo(filename, new Runnable() {
    public void run() {
      if (optimize) {
        writeFile(filename, ToUnipadLedOptimize(led));
      } else {
        writeFile(filename, ToUnipadLed(led));
      }
    }
  }
  );
}
LineError cacheError=new LineError(LineError.ERROR, 0, 0, 0, "", "");
LedTab addLedTab(String filename) {
  TabLayout tabs=((TabLayout)KyUI.get("led_filetabs"));
  Element e=tabs.addTabFromXmlPath(getFileName(filename), layout_led_frame_xml, "layout_led_frame.xml", null);
  KyUI.taskManager.executeAll();//add elements
  final CommandEdit edit=(CommandEdit)e.children.get(0).children.get(0);
  edit.textSize=((TextBox)KyUI.get("set_textsize")).valueI;
  ui_attachSlider(edit);
  final LedScript script=new LedScript(filename, edit, (PadButton)KyUI.get("led_pad"));
  edit.setContent(script);
  LedTab tab=new LedTab(script);
  println("added : "+script.name);
  ledTabs.add(tab);
  EventListener ev=new EventListener() {
    public void onEvent(Element e) {
      cacheError.line=edit.getCursorLine()-1;
      int index=script.getErrors().getBeforeIndex(cacheError);
      if (index>=0&&index<script.getErrors().size()&&script.getErrors().get(index).line==edit.getCursorLine()) {
        statusR.tabColor2=(script.getErrors().get(index).type==LineError.ERROR)?edit.errorColor:edit.warningColor;
        statusR.setError(true);
        setStatusR(script.getErrors().get(index).toString());
      } else if (script.getErrors().size()>0) {
        statusR.tabColor2=(script.getErrors().get(0).type==LineError.ERROR)?edit.errorColor:edit.warningColor;
        statusR.setError(true);
        setStatusR(script.getErrors().get(0).toString());
      } else {
        statusR.setError(false);
        setStatusR("no errors.");
      }
      ledFindReplace.textChanged=true;
    }
  };
  edit.setTextChangeListener(ev);
  edit.onCursorChangeListener=ev;
  tabs.onLayout();
  tabs.onLayout();//???????????
  KyUI.get("led_frame").onLayout();
  tabs.selectTab(ledTabs.size());
  return tab;
}
void addLedFileTab(String filename) {
  for (int a=0; a<ledTabs.size(); a++) {//anti duplication
    LedTab t=ledTabs.get(a);
    if (t.led.script.file.equals(new File(filename))) {
      led_filetabs.selectTab(a+1);
      return;
    }
  }
  //
  LedTab tab=addLedTab(filename);
  tab.led.script.insert(0, 0, readLed(filename));
  tab.led.script.tab=tab;
  tab.led.script.setChanged(false, false);
}
void selectLedTab(int index) {
  if (index<0||index>=ledTabs.size()) {//???
    println(index+"??");
    return;
  }
  currentLed=ledTabs.get(index);
  currentLedEditor=currentLed.led.script;
  currentLedEditor.updateSlider();
  currentLedEditor.displayControl();
  KyUI.get("led_frame").invalidate();
  ((ImageToggleButton)KyUI.get("led_loop")).value=currentLed.led.loop;
  KyUI.get("led_loop").invalidate();
  fs.valueS=currentLed.led.loopStart;
  fs.valueE=currentLed.led.loopEnd;
  setInfoLed(currentLedEditor.info);
  currentLedEditor.displayPad.size.set(info.buttonX, info.buttonY);
  currentLedEditor.displayPad.invalidate();
  ledFindReplace.textChanged=true;
}