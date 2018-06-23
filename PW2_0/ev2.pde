import java.util.function.*;
void setup_ev2() {
  KyUI.addShortcut(new KyUI.Shortcut("undo", true, false, false, 'Z'-'A'+1, java.awt.event.KeyEvent.VK_Z, new EventListener() {//Ctrl-Z
    public void onEvent(Element e) {
      if (e instanceof CommandEdit) {
        ((CommandEdit)e).script.undo();
      } else {
        if (mainTabs_selected==WAV_EDITOR) {
          if (currentWav!=null) {
            currentWav.editor.undo();
          }
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("redo", true, false, false, 'Y'-'A'+1, java.awt.event.KeyEvent.VK_Y, new EventListener() {//Ctrl-Y
    public void onEvent(Element e) {
      if (e instanceof CommandEdit) {
        ((CommandEdit)e).script.redo();
      } else {
        if (mainTabs_selected==WAV_EDITOR) {
          if (currentWav!=null) {
            currentWav.editor.redo();
          }
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("selectAll", true, false, false, 1, java.awt.event.KeyEvent.VK_A, new EventListener() {//Ctrl-A
    public void onEvent(Element e) {
      if (e instanceof TextEdit) {
        TextEdit edit=(TextEdit)e;
        edit.getContent().selectAll();
        edit.setCursorLine(edit.getContent().lines()-1);
        edit.setCursorPoint(edit.getLine(edit.getContent().lines()-1).length());
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("copy", true, false, false, 3, java.awt.event.KeyEvent.VK_C, new EventListener() {//Ctrl-C
    public void onEvent(Element e) {
      if (e instanceof TextEdit) {
        if (((TextEdit)e).getContent().hasSelection()) {
          textTransfer.setClipboardContents(((TextEdit)e).getContent().getSelection());
        }
      } else {
        if (mainTabs_selected==WAV_EDITOR) {
          if (currentWav!=null) {
            currentWav.editor.copy();
          }
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("cut", true, false, false, 24, java.awt.event.KeyEvent.VK_X, new EventListener() {//Ctrl-X
    public void onEvent(Element e) {
      if (e instanceof TextEdit) {
        EditorString edit=(EditorString)((TextEdit)e).getContent();
        if (edit.hasSelection()) {
          edit.line=edit.selStartPoint;
          edit.point=edit.selStartLine;
          textTransfer.setClipboardContents(edit.getSelection());
          edit.deleteSelection();
          edit.resetSelection();
          if (((TextEdit)e).onTextChangeListener!=null) {
            ((TextEdit)e).onTextChangeListener.onEvent(e);
          }
          ((TextEdit)e).recordHistory();
          e.invalidate();
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("paste", true, false, false, 22, java.awt.event.KeyEvent.VK_V, new EventListener() {//Ctrl-V
    public void onEvent(Element e) {
      if (e instanceof TextEdit) {
        EditorString edit=(EditorString)((TextEdit)e).getContent();
        if (edit.hasSelection()) {
          edit.deleteSelection();
          edit.resetSelection();
        }
        if (e instanceof ConsoleEdit) {
          ConsoleEdit c=(ConsoleEdit)e;
          if (c.getContent().line < c.editingLine) {
            c.getContent().line = c.editingLine;
            c.getContent().point = Math.min(c.header.length(), c.getLine(c.editingLine).length());
          } else if (c.getContent().point > c.getLine(c.editingLine).length()) {
            c.getContent().point = c.getLine(c.editingLine).length();
          }
        }
        String pasteString=textTransfer.getClipboardContents().replace("\r\n", "\n").replace("\r", "\n");
        if (pasteString.length()>0) {
          edit.insert(pasteString);
          String[] lines=split(pasteString, "\n");
          edit.line=edit.line+lines.length-1;
          if (lines.length==1) {
            edit.point=edit.point+lines[0].length();
          } else {
            edit.point=lines[lines.length-1].length();
          }
        }
        if (((TextEdit)e).onTextChangeListener!=null) {
          ((TextEdit)e).onTextChangeListener.onEvent(e);
        }
        ((TextEdit)e).recordHistory();
        e.invalidate();
      } else {
        if (mainTabs_selected==WAV_EDITOR) {
          if (currentWav!=null) {
            currentWav.editor.paste();
          }
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("registerQ", true, false, false, 17, java.awt.event.KeyEvent.VK_Q, new EventListener() {//Ctrl-Q
    public void onEvent(Element e) {
      if (e instanceof TextEdit) {
        EditorString edit=(EditorString)((TextEdit)e).getContent();
        userMacro1=edit.getSelection();
        Button btn=((Button)KyUI.get("led_printq"));
        btn.text=userMacro1.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
        btn.invalidate();
        export_settings();
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("registerE", true, false, false, 5, java.awt.event.KeyEvent.VK_E, new EventListener() {//Ctrl-E
    public void onEvent(Element e) {
      if (e instanceof TextEdit) {
        EditorString edit=(EditorString)((TextEdit)e).getContent();
        userMacro2=edit.getSelection();
        Button btn=((Button)KyUI.get("led_printe"));
        btn.text=userMacro2.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
        btn.invalidate();
        export_settings();
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("printQ", false, false, false, 'q', 'Q', new EventListener() {//Q
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        ((Button)KyUI.get("led_printq")).getPressListener().onEvent(null, 0);
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("printE", false, false, false, 'e', 'E', new EventListener() {//E
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        ((Button)KyUI.get("led_printe")).getPressListener().onEvent(null, 0);
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("openFind", true, false, false, 6, java.awt.event.KeyEvent.VK_F, new EventListener() {//Ctrl+F
    public void onEvent(Element e) {//why two??
      if (mainTabs_selected==LED_EDITOR) {
        ImageButton btn=((ImageButton)KyUI.get("led_findreplace"));
        btn.onPress();
        btn.getPressListener().onEvent(null, 0);
      } else if (mainTabs_selected==MACRO_EDITOR) {
        ImageButton btn=((ImageButton)KyUI.get("m_findreplace"));
        btn.onPress();
        btn.getPressListener().onEvent(null, 0);
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("openCommand", true, false, false, 13, java.awt.event.KeyEvent.VK_M, new EventListener() {//Ctrl+M
    public void onEvent(Element e) {
      if (mainTabs_selected==LED_EDITOR) {
        ImageButton btn=((ImageButton)KyUI.get("led_commands"));
        btn.onPress();
        btn.getPressListener().onEvent(null, 0);
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("transportL", false, false, true, '<', 44, new EventListener() {//<
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        if (mainTabs_selected==LED_EDITOR) {
          if (currentLedEditor.DelayPoint.size()>1) {
            currentLedEditor.setDisplayFrame(max(0, currentLedEditor.displayFrame-1));
            currentLedEditor.setTimeByFrame();
            currentLedEditor.updateSlider();
            currentLedEditor.displayControl();
            currentLed.light.copyFrame(currentLedEditor.LED.get(currentLedEditor.displayFrame), currentLedEditor.velLED.get(currentLedEditor.displayFrame));
          }
        } else if (mainTabs_selected==WAV_EDITOR) {
          if (currentWav!=null) {
            currentWav.editor.left(2);
          }
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("transportR", false, false, true, '>', 46, new EventListener() {//>
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        if (mainTabs_selected==LED_EDITOR) {
          if (currentLedEditor.displayFrame<currentLedEditor.DelayPoint.size()-1) {
            currentLedEditor.setDisplayFrame(min(currentLedEditor.DelayPoint.size()-1, currentLedEditor.displayFrame+1));
            currentLedEditor.setTimeByFrame();
            currentLedEditor.updateSlider();
            currentLedEditor.displayControl();
            currentLed.light.copyFrame(currentLedEditor.LED.get(currentLedEditor.displayFrame), currentLedEditor.velLED.get(currentLedEditor.displayFrame));
          }
        } else if (mainTabs_selected==WAV_EDITOR) {
          if (currentWav!=null) {
            currentWav.editor.right(2);
          }
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("velocityL", false, false, false, 'a', 'A', new EventListener() {//a
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        if (mainTabs_selected==LED_EDITOR) {
          VelocityType.left();
        } else if (mainTabs_selected==WAV_EDITOR) {
          currentWav.editor.setAutomationMode(!currentWav.editor.getAutomationMode());
          //ADD automation button toggle.
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("velocityR", false, false, false, 'd', 'D', new EventListener() {//d
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        if (mainTabs_selected==LED_EDITOR) {
          VelocityType.right();
        } else if (mainTabs_selected==WAV_EDITOR) {
          currentWav.editor.deletePoint();
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("velocityU", false, false, false, 'w', 'W', new EventListener() {//w
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        if (mainTabs_selected==LED_EDITOR) {
          VelocityType.up();
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("velocityD", false, false, false, 's', 'S', new EventListener() {//s
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        if (mainTabs_selected==LED_EDITOR) {
          VelocityType.down();
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("snap", false, false, false, 'p', 'P', new EventListener() {//p
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        if (mainTabs_selected==WAV_EDITOR) {
          if (currentWav!=null) {
            currentWav.editor.setSnap(currentWav.editor.snap);
          }
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("loop", false, false, false, 'l', 'L', new EventListener() {//l
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        if (mainTabs_selected==LED_EDITOR) {
          ImageToggleButton btn=((ImageToggleButton)KyUI.get("led_loop"));
          btn.onPress();
          btn.getPressListener().onEvent(null, 0);
          btn.invalidate();
        } else if (mainTabs_selected==WAV_EDITOR) {
          if (currentWav!=null) {
            currentWav.editor.setLoop(!currentWav.editor.getLoop());
            //ADD toggle loop button
          }
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("rewind", false, false, false, 'r', 'R', new EventListener() {//r
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        if (mainTabs_selected==LED_EDITOR) {
          if (currentLed.led.loopStart<currentLed.led.loopEnd) {
            currentLedEditor.displayTime=currentLed.led.loopStart;
            currentLedEditor.setFrameByTime();
          } else {
            currentLedEditor.setDisplayFrame(0);
            currentLedEditor.setTimeByFrame();
          }
          ledTabs.get(0).light.start(ledTabs.get(0).led, currentLedEditor.displayTime);
        } else if (mainTabs_selected==WAV_EDITOR) {
          if (currentWav!=null) {
            currentWav.editor.player.setPosition(currentWav.editor.player.getLoopStartUGen().getValue());
            currentWav.editor.player.pause(false);
          }
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("play", false, false, false, ' ', ' ', new EventListener() {//" "
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        if (mainTabs_selected==LED_EDITOR) {
          ImageButton btn=((ImageButton)KyUI.get("led_playstop"));
          btn.getPressListener().onEvent(null, 0);
        } else if (mainTabs_selected==WAV_EDITOR) {
          if (currentWav!=null) {
            WavEditor w=currentWav.editor;
            if (w.player.getPosition() == w.player.getLoopEndUGen().getValue()) {
              w.player.setPosition(w.player.getLoopStartUGen().getValue());
              w.player.pause(false);
            } else {
              w.player.pause(!w.player.isPaused());
            }
          }
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("save", true, false, false, 19, java.awt.event.KeyEvent.VK_S, new EventListener() {//Ctrl+S
    public void onEvent(Element e) {
      println("shortcut : save");
      if (mainTabs_selected==LED_EDITOR) {
        saveLed(currentLedEditor);
      } else if (mainTabs_selected==KS_EDITOR) {
        saveKs(currentKs, false);
      } else if (mainTabs_selected==WAV_EDITOR) {
        saveWav(currentWav);
      } else if (mainTabs_selected==MACRO_EDITOR) {
        saveMacro(currentMacro);
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("saveAll", true, false, true, 19, java.awt.event.KeyEvent.VK_S, new EventListener() {//Ctrl+Shift+S
    public void onEvent(Element e) {
      println("shortcut : saveAll");
      if (mainTabs_selected==LED_EDITOR) {
        for (LedTab tab : ledTabs) {
          saveLed(tab.led.script);
        }
      } else if (mainTabs_selected==KS_EDITOR) {
        for (KsSession tab : ksTabs) {
          saveKs(tab, false);
        }
      } else if (mainTabs_selected==WAV_EDITOR) {
        for (WavTab tab : wavTabs) {
          saveWav(tab);
        }
      } else if (mainTabs_selected==MACRO_EDITOR) {
        for (MacroTab tab : macroTabs) {
          saveMacro(tab);
        }
      }
    }
  }
  ));
  KyUI.addShortcut(new KyUI.Shortcut("export", true, true, false, 65535, 83, new EventListener() {//Ctrl+Alt+S
    public void onEvent(Element e) {
      println("shortcut : export");
      if (mainTabs_selected==LED_EDITOR) {
        exportLed(currentLedEditor);
      } else if (mainTabs_selected==KS_EDITOR) {
        saveKs(currentKs, true);
      }
    }
  }
  ));
  //and...finally drag and drop!
  KyUI.addDragAndDrop(KyUI.get("led_layout"), new FileDropEventListener() {
    public void onEvent(DropEvent de) {
      String filename=de.file().getAbsolutePath().replace("\\", "/");
      if (de.file().isFile()) {
        addLedFileTab(filename);
      }
    }
  }
  );
  KyUI.addDragAndDrop(KyUI.get("ks_layout"), new FileDropEventListener() {
    public void onEvent(DropEvent de) {
      String filename=de.file().getAbsolutePath().replace("\\", "/");
      if (de.file().isDirectory()) {
        addKsFileTab(filename);
      } else if (de.file().isFile()&&getFileName(filename).equals("autoPlay")) {
        UnipackInfo info_=info;
        info=currentKs.info;
        LedScript autoPlay=loadApScript(filename, readFile(filename));
        int c=0;
        int cnt=1;
        for (Command cmd : autoPlay.getCommands()) {
          if (cmd instanceof ApOnCommand) {
            ApOnCommand apOn=(ApOnCommand)cmd;
            if (c>=0&&c<currentKs.info.chain&&apOn.x1>0&&apOn.y1>0&&apOn.x1<=currentKs.info.buttonX&&apOn.y1<=currentKs.info.buttonY) {
              if (currentKs.autoPlayOrder.get(c)[apOn.x1-1][apOn.y1-1].isEmpty()) {
                currentKs.autoPlayOrder.get(c)[apOn.x1-1][apOn.y1-1]+=cnt;
              } else {
                textSize(15);
                int index=max(0, currentKs.autoPlayOrder.get(c)[apOn.x1-1][apOn.y1-1].lastIndexOf("\n"));
                if (textWidth(currentKs.autoPlayOrder.get(c)[apOn.x1-1][apOn.y1-1].substring(index))<50) {
                  currentKs.autoPlayOrder.get(c)[apOn.x1-1][apOn.y1-1]+=" "+cnt;//#ADD range commands
                } else {
                  currentKs.autoPlayOrder.get(c)[apOn.x1-1][apOn.y1-1]+="\n"+cnt;//#ADD range commands
                }
              }
              cnt++;
            }
          } else if (cmd instanceof ChainCommand) {
            ChainCommand chainCmd=(ChainCommand)cmd;
            c=chainCmd.c-1;
          }
        }
        info=info_;
        currentKs.textControl();
      }
    }
  }
  );
  KyUI.addDragAndDrop(KyUI.get("wv_layout"), new FileDropEventListener() {
    public void onEvent(DropEvent de) {
      String filename=de.file().getAbsolutePath().replace("\\", "/");
      if (filename.endsWith(".cue")) {
        if (currentWav!=null&&currentWav.editor.automation!=null&&currentWav.editor.automation.getName().equals("cuePoint")) {
          PwWaveditLoader.loadGoldwaveCue(filename, currentWav.editor.automation);
        }
      } else {
        if (de.file().isFile()&&isSoundFile(de.file())) {
          try {
            addWavFileTab(filename);//catch numberformatexception.
          }
          catch(NumberFormatException e) {
            displayError(e);
          }
        }
      }
    }
  }
  );
  KyUI.addDragAndDrop(KyUI.get("ks_fileview"), KyUI.get("ks_led"), new DropEventListener() {
    public void onEvent(DropMessenger d, MouseEvent e, int index) {
      final String filename=((FileSelectorButton)((LinearList)KyUI.get("ks_fileview")).getItems().get(d.startIndex)).file.getAbsolutePath().replace("\\", "/");
      //println("drop : "+filename);
      if (!new File(filename).isFile()||isSoundFile(new File(filename))) {
        return;
      }
      final LinearList ks_led=(LinearList)KyUI.get("ks_led");
      KyUI.checkOverlayCondition(new BiFunction<Element, Vector2, Boolean>() {
        public Boolean apply(Element e, Vector2 pos) {
          if (ks_led.isListItem(e)) {
            currentKs.getSelected().loadLed(ks_led.getReorderIndex(pos), filename, 1);
            return true;
          }
          return false;
        }
      }
      );
    }
  }
  );
  KyUI.addDragAndDrop(KyUI.get("ks_fileview"), KyUI.get("ks_sound"), new DropEventListener() {
    public void onEvent(DropMessenger d, MouseEvent e, int index) {
      final String filename=((FileSelectorButton)((LinearList)KyUI.get("ks_fileview")).getItems().get(d.startIndex)).file.getAbsolutePath().replace("\\", "/");
      //println("drop : "+filename);
      if (!new File(filename).isFile()||!isSoundFile(new File(filename))) {
        return;
      }
      final LinearList ks_sound=(LinearList)KyUI.get("ks_sound");
      KyUI.checkOverlayCondition(new BiFunction<Element, Vector2, Boolean>() {
        public Boolean apply(Element e, Vector2 pos) {
          if (ks_sound.isListItem(e)) {
            currentKs.getSelected().loadSound(ks_sound.getReorderIndex(pos), filename, 1);
            return true;
          }
          return false;
        }
      }
      );
    }
  }
  );
  KyUI.addDragAndDrop(KyUI.get("ks_led"), KyUI.get("ks_fileview"), new DropEventListener() {
    public void onEvent(DropMessenger d, MouseEvent e, int index) {
      currentKs.getSelected().removeLed(d.startIndex);
    }
  }
  );
  KyUI.addDragAndDrop(KyUI.get("ks_sound"), KyUI.get("ks_fileview"), new DropEventListener() {
    public void onEvent(DropMessenger d, MouseEvent e, int index) {
      currentKs.getSelected().removeSound(d.startIndex);
    }
  }
  );
  KyUI.addDragAndDrop(KyUI.get("ks_fileview"), ks_pad, new DropEventListener() {
    public void onEvent(DropMessenger d, MouseEvent e, int index) {
      if (d.startIndex<0)return;
      final String filename=((FileSelectorButton)((LinearList)KyUI.get("ks_fileview")).getItems().get(d.startIndex)).file.getAbsolutePath().replace("\\", "/");
      if (!new File(filename).isFile()) {
        return;
      }
      //println("drop : "+filename);
      IntVector2 coord=ks_pad.getCoord();
      if (isSoundFile(new File(filename))) {
        currentKs.get(currentKs.chain, coord.x, coord.y).loadSound(filename, 1);
      } else {
        currentKs.get(currentKs.chain, coord.x, coord.y).loadLed(filename, 1);
      }
    }
  }
  );
  KyUI.addDragAndDrop(KyUI.get("wv_files"), KyUI.get("wv_frame"), new DropEventListener() {
    public void onEvent(DropMessenger d, MouseEvent e, int index) {
      if (d.startIndex<0)return;
      final String filename=((FileSelectorButton)((LinearList)KyUI.get("wv_files")).getItems().get(d.startIndex)).file.getAbsolutePath().replace("\\", "/");
      if (!new File(filename).isFile()) {
        return;
      }
      if (isSoundFile(new File(filename))) {
        addWavFileTab(filename);
      }
    }
  }
  );
  KyUI.addDragAndDrop(KyUI.get("ks_led"), ks_pad, new DropEventListener() {
    public void onEvent(DropMessenger d, MouseEvent e, int index) {
      IntVector2 coord=ks_pad.getCoord();
      if (coord.equals(ks_pad.selected)) {
        return;
      }
      currentKs.get(currentKs.chain, coord.x, coord.y).loadLed(currentKs.getSelected().getLed(d.startIndex), currentKs.getSelected().getLedLoop(index));
      currentKs.getSelected().removeLed(d.startIndex);
    }
  }
  );
  KyUI.addDragAndDrop(KyUI.get("ks_sound"), ks_pad, new DropEventListener() {
    public void onEvent(DropMessenger d, MouseEvent e, int index) {
      IntVector2 coord=ks_pad.getCoord();
      if (coord.equals(ks_pad.selected)) {
        return;
      }
      currentKs.get(currentKs.chain, coord.x, coord.y).loadSound(currentKs.getSelected().getSound(d.startIndex), currentKs.getSelected().getSoundLoop(index));
      currentKs.getSelected().removeSound(d.startIndex);
    }
  }
  );
  ((LinearList)KyUI.get("ks_led")).reorderListener=new BiPredicate<Integer, Integer>() {
    public boolean test(Integer a, Integer b) {
      currentKs.getSelected().reorderLed(a, b);
      return true;
    }
  };
  ((LinearList)KyUI.get("ks_sound")).reorderListener=new BiPredicate<Integer, Integer>() {
    public boolean test(Integer a, Integer b) {
      currentKs.getSelected().reorderSound(a, b);
      return true;
    }
  };
  KyUI.addDragAndDrop(KyUI.get("mp3_input"), new FileDropEventListener() {
    public void onEvent(DropEvent de) {
      String filename=de.file().getAbsolutePath().replace("\\", "/");
      ((LinearList)KyUI.get("mp3_input")).addItem(filename);
    }
  }
  );
  KyUI.addDragAndDrop(KyUI.get("mp3_input"), KyUI.get("mp3_cf1"), new DropEventListener() {
    public void onEvent(DropMessenger m, MouseEvent ev, int index) {
      ((LinearList)KyUI.get("mp3_input")).removeItem(m.startIndex);
    }
  }
  );
}

//  } else if (functionId==S_STOP) {
//    currentLedEditor.displayTime=autorun_backup;
//    currentLedEditor.setFrameByTime();
//    frameSlider.adjust(currentLedEditor.displayTime);
//    frameSlider.render();
//  } else if (functionId==S_KEYSOUNDCLEAR) {
//    if (UI[getUIid("I_CLEARKEYSOUND")].disabled==false) {
//      ((Button)UI[getUIid("I_CLEARKEYSOUND")]).onRelease();
//    }
//export

/*
 if (key == 'o') {
 Button b = KyUI.<Button>get2("autoscroll");
 b.onPress();
 b.invalidate();
 b.getPressListener().onEvent(null, 0);
 }
 if (key == '=') {
 Button b = KyUI.<Button>get2("grid+");
 b.getPressListener().onEvent(null, 0);
 }
 if (key == '-') {
 Button b = KyUI.<Button>get2("grid-");
 b.getPressListener().onEvent(null, 0);
 }
 if (key == '[') {
 Button b = KyUI.<Button>get2("zoomout");
 b.getPressListener().onEvent(null, 0);
 }
 if (key == ']') {
 Button b = KyUI.<Button>get2("zoomin");
 b.getPressListener().onEvent(null, 0);
 }
 if (key == 't') {
 Button b = KyUI.<Button>get2("cut");
 b.getPressListener().onEvent(null, 0);
 }
 if (key == 's') {
 Button b = KyUI.<Button>get2("save");
 b.getPressListener().onEvent(null, 0);
 }
 if (key == '0') {
 Button b = KyUI.<Button>get2("resetloop");
 b.getPressListener().onEvent(null, 0);
 }
 if (key == 'q' || key == 17) {//processing's limit
 w.addPoint(w.snapTime(
 Math.max(Math.min(w.player.getPosition() + (double)(((java.awt.event.KeyEvent)e.getNative()).getWhen() - System.currentTimeMillis()), w.sample.getLength()), 0)
 ), 1);
 w.automationInvalid = true;
 KyUI.get("wav").invalidate();
 if(key=='Ctrl+F'){
 wv_points.setEnabled(!wv_points.isEnabled);
 }
 }*/