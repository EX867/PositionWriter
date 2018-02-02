void shortcuts_setup() {
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
        ((TextEdit)e).recordHistory();
        e.invalidate();
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
            currentLedEditor.displayFrame=max(0, currentLedEditor.displayFrame-1);
            currentLedEditor.setTimeByFrame();
            currentLedEditor.updateSlider();
            currentLedEditor.displayControl();
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
            currentLedEditor.displayFrame=min(currentLedEditor.DelayPoint.size()-1, currentLedEditor.displayFrame+1);
            currentLedEditor.setTimeByFrame();
            currentLedEditor.updateSlider();
            currentLedEditor.displayControl();
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
  KyUI.addShortcut(new KyUI.Shortcut("loop", false, false, false, 'l', 'L', new EventListener() {//l
    public void onEvent(Element e) {
      if (!(e instanceof TextEdit)) {
        ImageButton btn=((ImageButton)KyUI.get("led_loop"));
        btn.onPress();
        btn.getPressListener().onEvent(null, 0);
        btn.invalidate();
      }
    }
  }
  ));
}

//void editable_keyTyped() {
//  if (functionId==S_PLAY){
//    ((Button)UI[getUIid("I_PLAYSTOP")]).onRelease();
//  }else if (functionId==S_REWIND) {
//    autorun_paused=false;
//    autoRunRewind();
//  } else if (functionId==S_STOP) {
//    currentLedEditor.displayTime=autorun_backup;
//    currentLedEditor.setFrameByTime();
//    frameSlider.adjust(currentLedEditor.displayTime);
//    frameSlider.render();
//  } else if (functionId==S_KEYSOUNDCLEAR) {
//    if (UI[getUIid("I_CLEARKEYSOUND")].disabled==false) {
//      ((Button)UI[getUIid("I_CLEARKEYSOUND")]).onRelease();
//    }
//  } else if (functionId==S_UNDO) {
//    UndoLog();
//    setStatusR("undo");
//  } else if (functionId==S_REDO) {
//    RedoLog();
//    setStatusR("redo");
//  } else if (functionId==S_RESETFOCUS) {//lost focus(Ctrl+T)
//    UI[focus].resetFocus();
//    focus=DEFAULT;
//  } else if (functionId==S_EXPORT) {//save in unipad command(Ctrl+S)
//    saveWorkingFile_unipad();
//  } else if (functionId==S_SAVE) {//save(Ctrl+S)
//    saveWorkingFile();
//  } else if (functionId==S_EXTERNAL) {
//    writeDisplay(Shortcuts[a].text);
//  }
//}