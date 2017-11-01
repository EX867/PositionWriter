import java.lang.reflect.Method;
import java.lang.reflect.Field;
PFont fontRegular;
PFont fontBold;
boolean DEBUG=true;
boolean DEVELOPER_BUILD=false;//detect with processing.exe
String DEVELOPER_PATH="";//changed to use processing's dataPath(""). sometimes this doesn't works...there are some problems...
String pw_startText="// === PW 2.0 === //";
void detectProcessing() {
  File file=new File("");
  println("detectProcessing : "+file.getAbsolutePath());
  if (new File(joinPath(file.getAbsolutePath(), "processing.exe")).exists()) {//windows
    println("yes. this is processing build.");
    DEVELOPER_BUILD=true;
  }
  if (new File(joinPath(file.getAbsolutePath(), "processing")).exists()) {//linux
    println("yes. this is processing build.");
    DEVELOPER_BUILD=true;
  }
  if (DEVELOPER_BUILD) {
    DEVELOPER_PATH=dataPath("");
  }
}
float Width=1420;
float Height=920;
float initialWidth=1420;
float initialHeight=920;
String VERSION="{\"type\"=\"production\",\"major\"=0,\"minor\"=0,\"patch\"=0,\"build\"=0,\"build_date\"=\"\"}";
;//type=beta or production - loaded from file from now.
String startText="PositionWriter <major>.<minor> <type> [<build>] (<build_date> build)";//template for startText. see buildVersion() to get actual string.
String title_suffix=" | Position Writer 2.0";
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
/*
 
 // ==== TODO ==== //
 //wavedit
 make effects control ui.
 all sound stops on stop button double click
 add control delay(long press usually used in select and move) to settigs
 wavedit play to playpause(line led), replace stop with record.
 2.+ : keysound sound right double click-wavedit load
 
 //other
 2.+ : multi threading
 2.+ : add html+vel color autoinput(option)
 2.+ : change entire ui class structure!!!*
 change some arraylists to multimap. this is important!!!
 2.+ : add KeySoundPlayer and midi->autoPlay tools
 2.+ : directly edit and save zip(for users)
 2.+ : (option) keySound autosave, undo
 2.+ : linux file chooser???
 2.+ : multi language support
 2.+ : led editor multi tab support***
 2.+ : note on highlight
 2.+ : only store setting data if they are modified
 2.+ : calculator support hexcode.(and some functions for color)
 2.+ : delay value edit shortcut(from unitor-lpassist)
 2.+ : autoplay led link - triggering led(run triggering and frame both in led editor, stop link with clear button - this will enable rnd command in led editor too.)
 2.+ : drag to print range commands***
 2.+ : currently, mc converter cannot manipulate range commands. add!
 2.+ : show sound file name toggle button.
 
 midi : midi<->led converter (merge threaded track needed)
 
 extra : gif animation file save/load
 
 skinedit : change theme to appcompat-material(later...)
 uncloud : wait uncloud update!!
 uncloud : customize list : display date and upload state inside list.
 uncloud : infoviewer design upgrade.
 // ==== ERROR ==== //
 // ==== WARNING ==== //
 hardcoded numbers(textEditor,skinedit)
 */
float initialScale;
void settings() {
  smooth(8);
  initialScale=min((float)displayWidth/1920, (float)displayHeight/1080);
  initialWidth=1420;//*displayScale;
  initialHeight=920;//*displayScale;
  size(int(1420*initialScale), int(920*initialScale));
  scale=initialScale;//(float)142/92;
}
//https://github.com/processing/processing/wiki/Export-Info-and-Tips
boolean Debug=false;
boolean pfocused=true;
void setup() {
  if (Debug) {
    try {
      setup_main();
    }
    catch(Exception e) {
      displayLogError(e);
    }
  } else {
    setup_main();
  }
}
void draw() {
  if (Debug) {
    try {
      draw_main();
    }
    catch(Exception e) {
      displayLogError(e);
    }
  } else {
    draw_main();
  }
  pfocused=focused;
}
void keyPressed() {
  if (Debug) {
    try {
      keyPressed_main();
    }
    catch(Exception e) {
      displayLogError(e);
    }
  } else {
    keyPressed_main();
  }
}
void keyTyped() {
  if (Debug) {
    try {
      keyTyped_main();
    }
    catch(Exception e) {
      displayLogError(e);
    }
  } else {
    keyTyped_main();
  }
}
void mouseWheel(MouseEvent ev) {
  if (Debug) {
    try {
      mouseWheel_main(ev);
    }
    catch(Exception e) {
      displayLogError(e);
    }
  } else {
    mouseWheel_main(ev);
  }
}
void setup_main() {
  detectProcessing();
  //orientation (LANDSCAPE);
  rectMode(RADIUS);
  ellipseMode(RADIUS);
  textAlign(CENTER, CENTER);
  strokeCap(PROJECT);
  textMode(MODEL);
  imageMode(CENTER);
  noStroke();
  frameRate(50);
  surface.setIcon(loadImage("icon.png"));
  setInverseK();
  //setup utils
  textTransfer=new TextTransfer();
  createMissingFiles();
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
  //load data and settings
  //...
  //setup data
  I_ResetKs();
  //setup ui
  fontBold=createFont("fonts/SourceCodePro-Bold.ttf", 30);
  fontRegular=createFont("fonts/The160.ttf", 30);
  textFont(fontBold);
  pushMatrix();
  scale(scale);
  pushMatrix();
  loadDefaultImages();
  UI_setup();
  //translate(Frames[currentFrame].position.x-Frames[currentFrame].size.x, Frames[currentFrame]. position.y-Frames[currentFrame].size.y);
  AU_setup();
  //
  testSetup();
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
  //end things
  surface.setTitle(title_filename+title_edited+title_suffix);
  try {
    VERSION=readFile("versionInfo.json");
    buildVersion();
    checkVersion();
    statusR.text=startText;
  }
  catch(Exception e) {
    displayLogError("can't load version.");
  }
  Frames[currentFrame].render();
  popMatrix();
  popMatrix();
  uncloud_setup();
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
@Override
  void textSize(float size) {
  super.textSize(size);
  textLeading(size*3/4);
}
void draw_main() {
  drawStart=drawEnd;//
  pushMatrix();
  scale(scale);
  pushMatrix();
  translate(Frames[currentFrame].position.x-Frames[currentFrame].size.x, Frames[currentFrame]. position.y-Frames[currentFrame].size.y);
  //update ui functions
  getMouseState();
  UI_update();
  //DEBUG
  autoRun();
  autoSave();
  popMatrix();
  popMatrix();
  drawEnd=System.currentTimeMillis();//
  drawInterval=drawEnd-drawStart;//
  //
}
@Override
  void exit() {
  autoSaveWrite();
  generateSettings();
  generateShortcuts();
  generateColors();
  super.exit();
}
//=====future todo list=====//
//ADD Ctrl+Shift+Backspace support
void testSetup() {
  ((DropDown)UI[getUIid("I_LANGUAGE")]).setItems(new String[]{"english"});
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