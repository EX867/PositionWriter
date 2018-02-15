import pw2.element.*;
//PositionWriter 2.0.pde
//===ADD list===//
//led=(undo,redo),stop
//shortcuts = ,ksclear,delay value edit,macros
//add ziploader
//note on highlight
//add custom velocity selector
//loop statements?
//vel 0->invisible
//auto download android.jar
//script updater and file downloader(and midi preset) frame
//add rnd view
//
//===ADD list - not now===//
//
// : add html+vel color autoinput mode
// : remove #platform_specific
// : KeySoundPlayer and midi->autoPlay
//
//===FIX list - you should not do that!!===//
//remove KsButton link in SampleState and LedCounter.
//
// skinedit : change theme to appcompat-material(later...)
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
//static final int LINE_MAX_LENGTH=200;//text editor...
final float Width=1460;
final float Height=960;//scaled, not vary.
boolean setupFinished=false;
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
      exit();
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
  KyUI.shortcutsByName.get("saveAll").event.onEvent(null);
  export_reload();
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
  if (focused&&!pfocused) {//on focus
    //check file lastModifiedTime.
    //led
    for (LedTab t : ledTabs) {
      LedScript script=t.led.script;
      if (!script.file.isFile()) {
        if (!script.empty()) {
          script.setChanged(true, false);
        }
      } else if (script.lastSaveTime<script.file.lastModified()) {
        script.lastSaveTime=script.file.lastModified();
        script.reload();
        println(script.name+" reloaded");
      }
    }
  }
  KyUI.render(g); 
  //pushMatrix(); 
  //scale(KyUI.scaleGlobal); 
  ////draw other things
  //popMatrix();
  autoSave();
}
void main_setup() {
  surface.setResizable(true);
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
  String dataPath=getDataPath();
  //orientation (LANDSCAPE);
  surface.setIcon(loadImage("icon.png"));
  textTransfer=new TextTransfer();
  //load default data
  layout_led_frame_xml=loadXML("layout_led_frame.xml");
  KyUI.start(this, 30, true);//mono is secure...only multi when needs high performance.
  ElementLoader.loadOnStart();
  ElementLoader.loadExternal(joinPath(getCodePath(), "PwElements.jar"));
  ElementLoader.loadExternal(joinPath(getCodePath(), "CommandScript.jar"));
  LayoutLoader.loadXML(frame_main=KyUI.getRoot(), loadXML("layout.xml"));
  LayoutLoader.loadXML(frame_changetitle=KyUI.getNewLayer().setAlpha(100), loadXML("changetitle.xml"));
  LayoutLoader.loadXML(frame_ksinfo=KyUI.getNewLayer().setAlpha(100), loadXML("ksinfo.xml"));
  KyUI.taskManager.executeAll();//add all element
  //initialize
  statusL=(StatusBar)KyUI.get("main_statusL");
  statusR=(StatusBar)KyUI.get("main_statusR");
  led_filetabs=((TabLayout)KyUI.get("led_filetabs"));
  ks_filetabs=((TabLayout)KyUI.get("ks_filetabs"));
  led_pad=((PadButton)KyUI.get("led_pad"));
  ks_pad=((PadButton)KyUI.get("ks_pad"));
  ks_chain=((PadButton)KyUI.get("ks_chain"));
  ks_soundindex=((TextBox)KyUI.get("ks_soundindex"));
  ks_ledindex=((TextBox)KyUI.get("ks_ledindex"));
  color_lp=VelocityButton.color_lp;
  color_vel=color_lp;
  ((TabLayout)KyUI.get("main_tabs")).setTabNames(new String[]{"KEYLED", "KEYSOUND", "SETTINGS", "WAVEDIT", "MACRO"});
  ((TabLayout)KyUI.get("led_edittabs")).setTabNames(new String[]{"VEL", "HTML", "TEXT"});
  ((TabLayout)KyUI.get("led_vellayout")).setTabNames(new String[]{"LAUNCHPAD", "MIDIFIGHTER"});
  ((TabLayout)KyUI.get("ks_control")).setTabNames(new String[]{"CT", "AP"});
  ((TabLayout)KyUI.get("ks_filelist")).setTabNames(new String[]{"SOUND", "LED"});
  ((TabLayout)KyUI.get("set_lists")).setTabNames(new String[]{"SHORTCUTS", "COLORS"});
  ((TabLayout)KyUI.get("wv_list")).setTabNames(new String[]{"LIBS", "POINTS"});
  ((TabLayout)KyUI.get("main_tabs")).selectTab(1);
  ((TabLayout)KyUI.get("led_vellayout")).selectTab(1);
  ((TabLayout)KyUI.get("ks_control")).selectTab(1);
  ((TabLayout)KyUI.get("led_filetabs")).attachExternalFrame((FrameLayout)KyUI.get("led_frame"));
  KyUI.get("led_consolelayout").setEnabled(false);
  KyUI.get("led_findlr").setEnabled(false);
  ui_attachSlider((ConsoleEdit)KyUI.get("led_console"));
  ((DropDown)KyUI.get("set_mode")).addItem("AUTOINPUT");
  ((DropDown)KyUI.get("set_mode")).addItem("RIGHT OFF MODE");
  //load shortcuts
  //add events
  ((TabLayout)KyUI.get("main_tabs")).tabSelectListener=new ItemSelectListener() {
    public void onEvent(int index) {
      mainTabs_selected=index;
      if (index==LED_EDITOR) {
        currentLedEditor.midiControl();
      } else if (index==KS_EDITOR) {
        currentKs.light.midiControl(currentKs.light.velDisplay);
      }
    }
  };
  ((LinearList)KyUI.get("ks_led")).enableReordering();
  ((LinearList)KyUI.get("ks_sound")).enableReordering();
  KyUI.changeLayout();//layout all!
  final Element mainFrame=KyUI.get("main_layout");
  if (platform==WINDOWS) {
    KyUI.addResizeListener(new ResizeListener() {
      public void onEvent(final int w, final int h) {
        if (!((frame.getExtendedState() & java.awt.Frame.ICONIFIED) == java.awt.Frame.ICONIFIED||(frame.getExtendedState() & java.awt.Frame.NORMAL) == java.awt.Frame.NORMAL)) {
          frame.setExtendedState((frame.getExtendedState() & java.awt.Frame.NORMAL));
          surface.setSize((int)(mainFrame.pos.right-mainFrame.pos.left), (int)(mainFrame.pos.bottom-mainFrame.pos.top));
          return;
        }
        KyUI.scaleGlobal=(float)h/initialHeight;
        mainFrame.invalidate();//??????!?!?!??
        surface.setSize((int)(h*initialWidth/initialHeight), h);
      }
    }
    );
  }
  info=new UnipackInfo();
  //setup
  setup_ev1();
  script_setup();
  load_settings();
  led_setup();
  ks_setup();
  midi_setup();
  MidiCommand.setState("8x8");//#TEST
  au_setup();
  //load path data
  if (((ToggleButton)KyUI.get("set_reload")).value) {//reload
    load_reload();
  } else {
    addLedTab(createNewLed());
    addKsTab(createNewKs());
  }
  ((LinearList)KyUI.get("ks_fileview")).setFixedSize(30);
  FileSelectorButton.listDirectory(((LinearList)KyUI.get("ks_fileview")), new File(path_global), new java.util.function.Consumer<File>() {
    public void accept(File file) {
      //println("file accept : "+file.getAbsolutePath());
      if (isSoundFile(file)) {
        globalSamplePlayerPlay(file.getAbsolutePath());
      } else if (isLedFile(file)) {
        LedScript script=loadLedScript(file.getName(), readLed(file.getAbsolutePath()));
        globalKsLedPlayerPlay(script);
      }
    }
  }
  );
  if (!DEVELOPER_BUILD&&new File(joinPath(dataPath, "Initial")).isFile()) {//detect first time use.
    println("initial open");
    //KyUI.addLayer(initialLayer);
    //registerFileType();
    new File(joinPath(dataPath, "Initial")).delete();
  }
  new Thread(new Runnable() {
    public void run() {
      vs_checkVersion();
    }
  }
  ).start();
  KyUI.taskManager.executeAll();
  KyUI.getRoot().invalidate();//invalidate all!
  //add shortcuts
  setup_ev2();
  println("Setup finished");
  setupFinished=true;
}