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
  ((DropDown)KyUI.get("set_mode")).addItem("AUTOINPUT");
  ((DropDown)KyUI.get("set_mode")).addItem("RIGHT OFF MODE");
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
  ((Button)KyUI.get("set_ffmpeg")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      //KyUI.addLayer(ffMpegLayer);
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
  //((Button)KyUI.get("led_changetitle")).setPressListener(new MouseEventListener() {
  //  public boolean onEvent(MouseEvent e, int index) {
  //    titleChangeTarget=currentLedScript;
  //    KyUI.addLayer(changeTitleLayer);
  //    return false;
  //  }
  //}
  //);
  //((Button)KyUI.get("layer_exit")).setPressListener(new MouseEventListener() {//use one exit button all time...
  //  public boolean onEvent(MouseEvent e, int index) {
  //    KyUI.removeLayer();
  //    return false;
  //  }
  //}
  //);
  ((ImageButton)KyUI.get("set_apply")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      //resize();
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("set_midi")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      MidiCommand.reloadDevices(joinPath(path_global, path_midi));
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
      //KyUI.addLayer(infoLayer);
      return false;
    }
  }
  );
  ((DropDown)KyUI.get("set_mode")).setSelectListener(new ItemSelectListener() {
    public void onEvent(int index) {
      InputMode=index+1;//index is 0 to 2
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
  ((ToggleButton)KyUI.get("set_startfromcursor")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      StartFromCursor=((ToggleButton)KyUI.get("set_startfromcursor")).value;
      return false;
    }
  }
  );
  ((ToggleButton)KyUI.get("set_autostop")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      AutoStop=((ToggleButton)KyUI.get("set_autostop")).value;
      return false;
    }
  }
  );
  ((ToggleButton)KyUI.get("set_autosave")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      AutoSave=((ToggleButton)KyUI.get("set_autosave")).value;
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("led_playstop")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      //start or pause led thread.
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
  ((Button)KyUI.get("led_printq")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      //
      return false;
    }
  }
  );
  ((Button)KyUI.get("led_printe")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      //
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
  KyUI.changeLayout();
  //setup commands
  script_setup();
  info=new UnipackInfo();
  currentLedEditor=new LedScript("LedFileName", (CommandEdit)KyUI.get("led_text"), (PadButton)KyUI.get("led_pad"));
  ((CommandEdit)KyUI.get("led_text")).setContent(currentLedEditor);
  ((CommandEdit)KyUI.get("led_text")).setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
    }
  }
  );
  led_setup();
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