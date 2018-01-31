import pw2.element.*;
//PositionWriter 2.0.pde
//===ADD list===//
//shortcuts = selectall,copy,cut,paste,(exists=undo,redo),registerq,registere,save,export,transportl,transportr,play,rewind,stop,loop,openfind,resetfocus,printq,printe,startfromcursor,autostop,autoinput vel controlx4,ksclear,delay value edit,macros
//add ziploader
//note on highlight
//drag and print range commands
//add custom velocity selector
//
//===ADD list - not now===//
//
// : add html+vel color autoinput mode
// : remove #platform_specific
// : KeySoundPlayer and midi->autoPlay
//
// skinedit : change theme to appcompat-material(later...)
// uncloud : wait uncloud update!!
// uncloud : customize list : display date and upload state inside list.
// uncloud : infoviewer design upgrade.
//===initialVars===//
String initialText="// === PW 2.0 === //";
float initialWidth=1420;
float initialHeight=920;
float initialScale;
//
//===finals===//
static final long SAMPLEWAV_MAX_SIZE=(long)1024*1024*200;
static final int SAMPLE_RATE=44100;
static final int PAD_MAX=200;
static final float DEFAULT_BPM=120; 
static final color COLOR_OFF=0x00000000;
static final color COLOR_RND=0x00000001;
static final int DS_VEL=1;
static final int DS_HTML=2;
//static final int LINE_MAX_LENGTH=200;//text editor...
final float Width=1460;
final float Height=960;//scaled, not vary.
//
//===structure===//
void settings() {
  //smooth(8);
  initialScale=min((float)displayWidth/1920, (float)displayHeight/1080);
  initialWidth=1460;//*displayScale;
  initialHeight=960;//*displayScale;
  size(int(1460*initialScale), int(960*initialScale));
}
void setup() {
  if (TRY) {
    try {
      main_setup();
    }
    catch(Exception e) {
      displayError(e);
    }
  } else {
    main_setup();
  }
}
boolean pfocused=true;
void draw() {
  if (TRY) {
    try {
      main_draw();
    }
    catch(Exception e) {
      displayError(e);
    }
  } else {
    main_draw();
  }
  pfocused=focused;
}
void textSize(float size) {
  super.textSize(size);
  textLeading(size*3/4);
}
void exit() {
  //#ADD autoSave();
  super.exit();
}
void handleKeyEvent(KeyEvent e) {
  super.handleKeyEvent(e);
  KyUI.handleEvent(e);
}
void handleMouseEvent(MouseEvent e) {
  super.handleMouseEvent(e);
  KyUI.handleEvent(e);
}
//
//===program logic===//
void main_setup() {
  //debug switches
  //Analyzer.debug=true;
  //
  rectMode(RADIUS);
  ellipseMode(RADIUS);
  textAlign(CENTER, CENTER);
  strokeCap(PROJECT);//set KyUI?
  imageMode(CENTER);
  textFont(createFont("fonts/SourceCodePro-Bold.ttf", 30));
  noStroke();
  frameRate(50);
  vs_detectProcessing();
  //orientation (LANDSCAPE);
  surface.setIcon(loadImage("icon.png"));
  textTransfer=new TextTransfer();
  KyUI.start(this, 30, true);//mono is secure...only multi when needs high performance.
  ElementLoader.loadOnStart();
  ElementLoader.loadExternal(joinPath(getCodePath(), "PwElements.jar"));
  ElementLoader.loadExternal(joinPath(getCodePath(), "CommandScript.jar"));
  LayoutLoader.loadXML(KyUI.getRoot(), loadXML("layout.xml"));
  KyUI.taskManager.executeAll();//add all element
  //initialize
  ((TabLayout)KyUI.get("main_tabs")).setTabNames(new String[]{"KEYLED", "KEYSOUND", "SETTINGS", "WAVEDIT", "MACRO"});
  ((TabLayout)KyUI.get("led_edittabs")).setTabNames(new String[]{"HTML", "VEL", "TEXT"});
  ((TabLayout)KyUI.get("led_vellayout")).setTabNames(new String[]{"LAUNCHPAD", "MIDIFIGHTER"});
  ((TabLayout)KyUI.get("ks_filelist")).setTabNames(new String[]{"SOUND", "LED"});
  ((TabLayout)KyUI.get("set_lists")).setTabNames(new String[]{"SHORTCUTS", "COLORS"});
  ((TabLayout)KyUI.get("wv_list")).setTabNames(new String[]{"LIBS", "POINTS"});
  ((TabLayout)KyUI.get("main_tabs")).selectTab(1);
  ((TabLayout)KyUI.get("led_vellayout")).selectTab(1);
  KyUI.get("led_consolelayout").setEnabled(false);
  KyUI.get("led_findlr").setEnabled(false);
  ui_attachSlider((CommandEdit)KyUI.get("led_text"));
  ui_attachSlider((ConsoleEdit)KyUI.get("led_console"));
  //load shortcuts
  //add events
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
  KyUI.changeLayout();
  //setup commands
  script_setup();
  info=new UnipackInfo();
  final LedScript currentLedEditor=new LedScript("LedFileName", (CommandEdit)KyUI.get("led_text"), (PadButton)KyUI.get("led_pad"));
  ((CommandEdit)KyUI.get("led_text")).setContent(currentLedEditor);
  ((CommandEdit)KyUI.get("led_text")).setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
    }
  }
  );
  final java.util.function.Function<IntVector2, Boolean> on=new java.util.function.Function<IntVector2, Boolean>() {
    public Boolean apply(IntVector2 coord) {//#ADD inframeinput and start cut
      if (currentLedEditor.cmdset==ledCommands) {
        if (ColorMode==VEL) {
          currentLedEditor.addLine("on "+(coord.y+1)+" "+(coord.x+1)+" auto "+3);//#TEST
        } else if (ColorMode==HTML) {
          currentLedEditor.addLine("on "+(coord.y+1)+" "+(coord.x+1)+" "+hex(-1, 6));//#TEST
        }
      } else if (currentLedEditor.cmdset==apCommands) {
        currentLedEditor.addLine("on "+(coord.y+1)+" "+(coord.x+1));
      }
      return true;
    }
  };
  final java.util.function.Function<IntVector2, Boolean> off=new java.util.function.Function<IntVector2, Boolean>() {
    public Boolean apply(IntVector2 coord) {
      currentLedEditor.addLine("off "+(coord.y+1)+" "+(coord.x+1));
      return true;
    }
  };
  ((PadButton)KyUI.get("led_pad")).buttonListener=new java.util.function.BiConsumer<IntVector2, Integer>() {
    public void accept(IntVector2 coord, Integer action) {//only sends in-range events.
      boolean edited=false;
      if (InputMode==AUTOINPUT) {
        if (action==PadButton.RELEASE_L) {
          int line=currentLedEditor.line;
          int frame=currentLedEditor.LED.size()-1;
          if (InFrameInput) {
            if (currentLedEditor.displayFrame!=currentLedEditor.DelayPoint.size()-1)line=currentLedEditor.DelayPoint.get(currentLedEditor.displayFrame+1);
            frame=currentLedEditor.displayFrame;
          }
          int a=line-1;
          int aframe=currentLedEditor.getFrame(line);
          boolean done=false;
          while (a>0&&a>currentLedEditor.DelayPoint.get(aframe)) {
            Command cmd= currentLedEditor.getCommands().get(a);
            if (cmd instanceof OnCommand) {
              LightCommand info=(LightCommand)cmd;
              if (info.x1-1==X&&info.y1-1==Y&&info.x1==info.x2&&info.y1==info.y2) {//???range command
                done=true;
                currentLedEditor.deleteLine(a);
                break;
              }
            } else if (cmd instanceof OffCommand) {
              LightCommand info=(LightCommand)cmd;
              if (info.x1-1==X&&info.y1-1==Y&&info.x1==info.x2&&info.y1==info.y2) {
                done=true;
                currentLedEditor.deleteLine(a);
                boolean notsame=color_lp[3]!=currentLedEditor.LED.get(frame)[X][Y];//#TEST
                if (notsame)edited=on.apply(coord);
                break;
              }
            }
            a--;
          }
          a--;
          if (done==false) {
            boolean onBefore=false;
            while (a>0) {
              Command cmd= currentLedEditor.getCommands().get(a);
              if (cmd instanceof OnCommand) {
                LightCommand info=(LightCommand)cmd;
                if (info.x1-1<=X&&X<=info.x2-1&&info.y1-1<=Y&&Y<=info.y2-1) {
                  onBefore=true;
                  break;
                }
              } else if (cmd instanceof OffCommand) {
                LightCommand info=(LightCommand)cmd;
                if (info.x1-1<=X&&X<=info.x2-1&&info.y1-1<=Y&&Y<=info.y2-1) {
                  onBefore=false;
                  break;
                }
              }
              a--;
            }
            if (onBefore) {
              edited=off.apply(coord);
            } else {
              edited=on.apply(coord);
            }
          }
        }
      } else if (InputMode==RIGHTOFFMODE) {
        if (action==PadButton.RELEASE_L) {
          edited=on.apply(coord);
        } else if (action==PadButton.RELEASE_R) {
          edited=off.apply(coord);
        }
      }
      if (edited) {
        currentLedEditor.editor.updateSlider();
        currentLedEditor.editor.invalidate();
      }
    }
  };
  //load others
  vs_loadBuildVersion();
  vs_checkVersion();
  //uncloud_setup();//later
}
void main_draw() {
  KyUI.render(g);
  pushMatrix();
  scale(KyUI.scaleGlobal);
  //draw other things
  popMatrix();
}

//if (selectAll) {//Ctrl-A
//  current.selectAll();
//  current.line=current.lines()-1;
//  current.point=current.getLine(current.line).length();
//}
//if (copy) {//Ctrl-C
//  if (current.hasSelection())textTransfer.setClipboardContents(current.getSelection());
//} 
//if (cut) {//Ctrl-X
//  if (current.hasSelection()) {
//    textTransfer.setClipboardContents(current.getSelection());
//    current.deleteSelection();
//  }
//  current.resetSelection();
//  current.recorder.recordLog();
//  pkey='\0';
//}
//if (paste) {//Ctrl-V
//  if (current.hasSelection()) {
//    current.deleteSelection();
//  } 
//  String pasteString1=textTransfer.getClipboardContents().replace("\r\n", "\n").replace("\r", "\n");
//  if (pasteString1.length()>0) {
//    current.insert(pasteString1);
//  }
//  current.resetSelection();
//  current.recorder.recordLog();
//  pkey='\0';
//}
//if (registerQ) {//Ctrl+Q
//  userMacro1=current.getSelection();
//  Button num1=((Button)UI[getUIid("I_NUMBER1")]);
//  num1.text=userMacro1.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
//  num1.render();
//}
//if (registerE) {//Ctrl+E
//  //processing...don't stop!!
//  userMacro2=current.getSelection();
//  Button num2=((Button)UI[getUIid("I_NUMBER2")]);
//  num2.text=userMacro2.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
//  num2.render();
//}