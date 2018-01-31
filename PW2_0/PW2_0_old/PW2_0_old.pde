
String title_filename="";
String title_keyledfilename="";
String title_keysoundfoldername="";
String title_edited="";//or *.
String title_keylededited="";//
String title_keysoundedited="";//or *.
String filePath="";
boolean loadedOnce_led=false;
boolean loadedOnce_keySound=false;

boolean jeonjehong=false;
boolean initialOpen=false;
void setup_main() {
  External_setup();
  if (new File(joinPath(GlobalPath, "jeonjehong")).isFile()) {
    jeonjehong=true;
    println("jeonjehong=true");
  }
  if (new File(joinPath(getDataPath(), "Initial")).isFile()) {
    initialOpen=true;
    println("initial=true");
    new File(joinPath(getDataPath(), "Initial")).delete();
  }
  //setup data
  I_ResetKs();
  pushMatrix();
  scale(scale);
  pushMatrix();
  loadDefaultImages();
  UI_setup();
  AU_setup();
  title_filename=newFile();
  // === Initial Open === //
  if (initialOpen) {
    registerPrepare(getFrameid("F_INITIAL"));
  }
  // === Load in start === // loadedOnce_xxx can't be true on start, but settings.xml can set it to true on start. if true, reload.
  if (loadedOnce_keySound) {
    try {
      loadKeySoundGlobal(title_keysoundfoldername);
      title_keysoundedited="";
    }
    catch(Exception e) {
      displayLogError(e);
      loadedOnce_keySound=false;
    }
  } else {
    title_keysoundfoldername=newFolder();
  }
  if (loadedOnce_led) {
    try {
      keyled_textEditor.loadText(title_keyledfilename, readFile(title_keyledfilename));
      title_filename=title_keyledfilename;
      title_edited="";
    }
    catch(Exception e) {
      displayLogError(e);
      loadedOnce_led=false;
    }
  } else {
    title_keyledfilename=title_filename;
  }
}
long drawStart=0;
long drawEnd=0;
long drawInterval=100;

/* AutoRun time vars */
boolean autorun_infinite=false;//set by ui
int autorun_loopCountTotal=1;//set by ui
int autorun_loopCount=0;
int autorun_backup=0;
boolean autorun_playing=false;
boolean autorun_paused=false;
void draw_main() {
  //DEBUG
  autoSave();
}
void editable_keyTyped() {
  int a=1;
  while (a<Shortcuts.length) {
    if (Shortcuts[a].isPressed(ctrlPressed, altPressed, shiftPressed, key, keyCode, shortcutExcept(), currentFrame)) {
      int functionId=Shortcuts[a].FunctionId;
      if (functionId==S_PLAY)((Button)UI[getUIid("I_PLAYSTOP")]).onRelease();
      else if (functionId==S_REWIND) {
        autorun_paused=false;
        autoRunRewind();
      } else if (functionId==S_STOP) {
        keyled_textEditor.current.processer.displayTime=autorun_backup;
        keyled_textEditor.current.processer.setFrameByTime();
        frameSlider.adjust(keyled_textEditor.current.processer.displayTime);
        frameSlider.render();
      } else if (functionId==S_LOOP) {
        ((Button)UI[getUIid("I_LOOP")]).onRelease();
        UI[getUIid("I_LOOP")].render();
      } else if (functionId==S_OPENFIND) {
        if (UI[getUIid("I_OPENFIND")].disabled==false) {
          ((Button)UI[getUIid("I_OPENFIND")]).onRelease();
        }
      } else if (functionId==S_KEYSOUNDCLEAR) {
        if (UI[getUIid("I_CLEARKEYSOUND")].disabled==false) {
          ((Button)UI[getUIid("I_CLEARKEYSOUND")]).onRelease();
        }
      } else if (functionId==S_UNDO) {
        UndoLog();
        setStatusR("undo");
      } else if (functionId==S_REDO) {
        RedoLog();
        setStatusR("redo");
      } else if (functionId==S_RESETFOCUS) {//lost focus(Ctrl+T)
        UI[focus].resetFocus();
        focus=DEFAULT;
      } else if (functionId==S_EXPORT) {//save in unipad command(Ctrl+S)
        saveWorkingFile_unipad();
      } else if (functionId==S_SAVE) {//save(Ctrl+S)
        saveWorkingFile();
      } else if (functionId==S_TRANSPORTL) {
        keyled_textEditor.current.processer.displayFrame=max(0, keyled_textEditor.current.processer.displayFrame-1);
        keyled_textEditor.current.processer.setTimeByFrame();
        frameSlider.render();
      } else if (functionId==S_TRANSPORTR) {//>
        keyled_textEditor.current.processer.displayFrame=min(keyled_textEditor.current.processer.DelayPoint.size()-1, keyled_textEditor.current.processer.displayFrame+1);
        keyled_textEditor.current.processer.setTimeByFrame();
        frameSlider.render();
      } else if (functionId==S_PRINTQ) {//asdf
        ((Button)UI[getUIid("I_NUMBER1")]).onRelease();
      } else if (functionId==S_PRINTE) {//asdf
        ((Button)UI[getUIid("I_NUMBER2")]).onRelease();
      } else if (functionId==S_STARTFROMCURSOR) {
        if (startFrom)startFrom=false;
        else startFrom=true;
        Button temp=((Button)UI[getUIid("I_STARTFROM")]);
        temp.value=startFrom;
        temp.render();
        frameSlider.render();
      } else if (functionId==S_AUTOSTOP) {
        if (autoStop)autoStop=false;
        else autoStop=true;
        Button temp=((Button)UI[getUIid("I_AUTOSTOP")]);
        temp.value=autoStop;
        temp.render();
        frameSlider.render();
      } else if (functionId==S_AUTOINPUTUP) {
        if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
          if (selectedColorType==DS_VEL)((VelocityButton)UI[velnumId]).cursorUp();
          else ((ColorPicker)UI[htmlselId]).cursorUp();
        }
      } else if (functionId==S_AUTOINPUTLEFT) {
        if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
          if (selectedColorType==DS_VEL)((VelocityButton)UI[velnumId]).cursorLeft();
          else ((ColorPicker)UI[htmlselId]).cursorLeft();
        }
      } else if (functionId==S_AUTOINPUTDOWN) {
        if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
          if (selectedColorType==DS_VEL)((VelocityButton)UI[velnumId]).cursorDown();
          else ((ColorPicker)UI[htmlselId]).cursorDown();
        }
      } else if (functionId==S_AUTOINPUTRIGHT) {
        if (Mode==AUTOINPUT||Mode==RIGHTOFFMODE) {
          if (selectedColorType==DS_VEL)((VelocityButton)UI[velnumId]).cursorRight();
          else ((ColorPicker)UI[htmlselId]).cursorRight();
        }
      } else if (functionId==S_EXTERNAL) {
        writeDisplay(Shortcuts[a].text);
      }
    }
    a=a+1;
  }
}