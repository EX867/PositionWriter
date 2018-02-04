import pw2.element.*;
//PositionWriter 2.0.pde
//===ADD list===//
//led=(undo,redo),export,stop
//shortcuts = ,resetfocus,ksclear,delay value edit,macros
//add ziploader
//note on highlight
//add custom velocity selector
//loop statements?
//vel 0->invisible
//auto download android.jar
//script updater and file downloader(and midi preset) frame
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
  midiOffAll();
  super.exit();
}
void handleKeyEvent(KeyEvent e) {
  super.handleKeyEvent(e);
  KyUI.handleEvent(e);
  if (e.getAction()==MouseEvent.PRESS) {
    //println((int)key+" "+keyCode);
  }
}
void handleMouseEvent(MouseEvent e) {
  super.handleMouseEvent(e);
  KyUI.handleEvent(e);
}
//
//===program logic===//
void main_draw() {
  KyUI.render(g); 
  pushMatrix(); 
  scale(KyUI.scaleGlobal); 
  //draw other things
  popMatrix();
}
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
  color_lp=VelocityButton.color_lp;
  color_vel=color_lp;
  ((TabLayout)KyUI.get("main_tabs")).setTabNames(new String[]{"KEYLED", "KEYSOUND", "SETTINGS", "WAVEDIT", "MACRO"});
  ((TabLayout)KyUI.get("led_edittabs")).setTabNames(new String[]{"VEL", "HTML", "TEXT"});
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
  ((TabLayout)KyUI.get("main_tabs")).tabSelectListener=new ItemSelectListener() {
    public void onEvent(int index) {
      mainTabs_selected=index;
    }
  };
  setup_ev1();
  KyUI.changeLayout();//layout all!
  //setup commands
  script_setup();
  info=new UnipackInfo();
  currentLedEditor=new LedScript(joinPath(getDocuments(), "PWTest/testled.led"), (CommandEdit)KyUI.get("led_text"), (PadButton)KyUI.get("led_pad"));
  ((CommandEdit)KyUI.get("led_text")).setContent(currentLedEditor);
  ((CommandEdit)KyUI.get("led_text")).setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
    }
  }
  );
  ledTabs.add(new LedTab(currentLedEditor));//#TEST
  currentLed=ledTabs.get(0);
  led_setup();
  //load custom settings
  midi_setup();
  ((Button)KyUI.get("led_printq")).text=userMacro1.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
  ((Button)KyUI.get("led_printe")).text=userMacro2.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
  new Thread(new Runnable() {
    public void run() {
      vs_checkVersion();
    }
  }
  ).start();
  //uncloud_setup();//later
  //add newversion layer!
  KyUI.taskManager.executeAll();
  KyUI.getRoot().invalidate();//invalidate all!
  //add shortcuts
  registerFileType();
  shortcuts_setup();
  println("Setup finished");
}