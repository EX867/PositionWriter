import pw2.element.*;
import java.util.TreeMap;
//PositionWriter 2.0.pde
//===ADD list===//
//led=(undo,redo),stop
//shortcuts = ,ksclear,delay value edit,macros,export| resetloop undo redo rewind zoomin zoomout moveToCursorLed
//add ziploader
//note on highlight
//add custom velocity selector
//script updater and file downloader(and midi preset) frame
//add rnd view
//colors drag and drop in settings
//PUT COMPRESSOR LABEL TEXT BELOW KNOB*******
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
void keyPressed(KeyEvent e) {
  KyUI.preventFromExit(this, e);
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
  if (g!=null) {
    KyUI.render(g);
  }
  pushMatrix(); 
  strokeWeight(1);
  textAlign(LEFT, TOP);
  textSize(12);
  stroke(255);
  noFill();
  ellipse(mouseX, mouseY, 20, 20);
  fill(255);
  line(0, mouseY, width, mouseY);
  line(mouseX, 0, mouseX, height);
  strokeWeight(5);
  line(mouseX, mouseY, pmouseX, pmouseY);
  text("[" + mouseX + ", " + mouseY + "] (" + frameRate + ")", mouseX + 10, mouseY + 12);
  popMatrix();
  autoSave();
}
void main_setup() {
  surface.setResizable(true);
  //debug switches
  //Analyzer.debug=true;
  KyUI.log=false;
  //
  rectMode(RADIUS);
  ellipseMode(RADIUS);
  textAlign(CENTER, CENTER);
  strokeCap(PROJECT);//set KyUI?
  imageMode(CENTER);
  //textFont(createFont("fonts/SourceCodePro-Bold.ttf", 30));
  noStroke();
  frameRate(50);
  vs_detectProcessing();
  String dataPath=getDataPath();
  //orientation (LANDSCAPE);
  surface.setIcon(loadImage("icon.png"));
  textTransfer=new TextTransfer();
  //load default data
  layout_led_frame_xml=loadXML("layout_led_frame.xml");
  layout_wv_frame_xml=loadXML("layout_wv_frame.xml");
  KyUI.start(this, 30, true);//mono is secure...only multi when needs high performance.
  textFont(KyUI.fontMain);
  ElementLoader.loadOnStart();
  ElementLoader.loadExternal(joinPath(getCodePath(), "PwElements.jar"));
  ElementLoader.loadExternal(joinPath(getCodePath(), "CommandScript.jar"));
  LayoutLoader.loadXML(frame_main=KyUI.getRoot(), loadXML("layout.xml"));
  LayoutLoader.loadXML(frame_changetitle=KyUI.getNewLayer().setAlpha(100), loadXML("changetitle.xml"));
  LayoutLoader.loadXML(frame_ksinfo=KyUI.getNewLayer().setAlpha(100), loadXML("ksinfo.xml"));
  LayoutLoader.loadXML(frame_info=KyUI.getNewLayer().setAlpha(100), loadXML("info.xml"));
  LayoutLoader.loadXML(frame_tips=KyUI.getNewLayer().setAlpha(100), loadXML("tips.xml"));
  LayoutLoader.loadXML(frame_mp3=KyUI.getNewLayer().setAlpha(100), loadXML("ffmpeg.xml"));
  LayoutLoader.loadXML(frame_log=KyUI.getNewLayer().setAlpha(100), loadXML("logger.xml"));
  LayoutLoader.loadXML(frame_update=KyUI.getNewLayer().setAlpha(100), loadXML("update.xml"));
  frame_skinedit=KyUI.getNewLayer().setAlpha(180);
  frame_skinedit.addChild(new SkinEditView("skin_edit", new Rect(0, 0, 1460, 960)));
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
  ((TabLayout)KyUI.get("wv_list")).setTabNames(new String[]{"FILE", "AUTO"});
  ((TabLayout)KyUI.get("main_tabs")).selectTab(1);
  ((TabLayout)KyUI.get("led_vellayout")).selectTab(1);
  ((TabLayout)KyUI.get("ks_control")).selectTab(1);
  ((TabLayout)KyUI.get("led_filetabs")).attachExternalFrame((FrameLayout)KyUI.get("led_frame"));
  ((TabLayout)KyUI.get("wv_filetabs")).attachExternalFrame((FrameLayout)KyUI.get("wv_frame"));
  ((TabLayout)KyUI.get("wv_list")).selectTab(1);
  KyUI.get("wv_text").setEnabled(true);
  KyUI.get("led_consolelayout").setEnabled(false);
  KyUI.get("led_findlr").setEnabled(false);
  ui_attachSlider((ConsoleEdit)KyUI.get("led_console"));
  ui_attachSlider((ConsoleEdit)KyUI.get("log_content"));
  ((DropDown)KyUI.get("set_mode")).addItem("AUTOINPUT");
  ((DropDown)KyUI.get("set_mode")).addItem("RIGHT OFF MODE");
  {//TEST
    final CommandEdit ce=(CommandEdit)KyUI.get("m_editor");
    final ConsoleEdit coe=(ConsoleEdit)KyUI.get("m_console");
    ui_attachSlider(ce);
    ui_attachSlider(coe);
    coe.textSize=15;
    ce.keyEventPost=new BiConsumer<TextEdit, KeyEvent>() {
      public void accept(TextEdit edit_, KeyEvent e) {
        CommandEdit edit=(CommandEdit)edit_;
        if (edit.script.line-1>=0&&edit.script.line-1<edit.script.lines()) {
          if (e.getKey()=='\n') {
            if (edit.getLine(edit.script.line-1).endsWith("{")) {
              edit.script.insert("  ");
              edit.script.point+=2;
            } else {
              String line=edit.getLine(edit.script.line-1);
              int count=0;
              for (count=0; count<line.length(); count++) {
                if (line.charAt(count)!=' ') {
                  break;
                }
              }
              if (count>0) {
                String insert="";
                for (int a=0; a<count; a++) {
                  insert=insert+" ";
                }
                edit.script.insert(insert);
                edit.script.point+=insert.length();
              }
            }
          } else if (e.getKey()=='}') {//dedent 2
            String line=edit.getLine(edit.script.line);
            if (line.endsWith("  }")) {
              edit.script.delete(edit.script.line, edit.script.point-3, edit.script.line, edit.script.point);
              edit.script.point=edit.script.point-3;
              edit.script.insert("}");
              edit.script.point=edit.script.point+1;
            }
          }
        }
      }
    };
    ((ImageButton)KyUI.get("m_run")).setPressListener(new MouseEventListener() {
      public boolean onEvent(MouseEvent e, int index) {
        final PrintStream stream=new PrintStream(new OutputStream() {
          @Override
            public void write(int b) throws IOException {
            if (b=='\n') {
              coe.addLine("");
              coe.invalidate();
            } else {
              coe.insert(((Object)((char)b)).toString());
            }
          }
        }
        );
        final String[] paths=getClassPaths();
        new Thread(new Runnable() {
          public void run() {
            //println((Object[])paths);
            try {
              PwMacroRun.run(PwMacroApi.class, "NewMacro", ce.getText(), new PW2_0Param(PW2_0.this, stream), stream, "C:\\Users\\user\\Documents\\PositionWriter\\temp\\pwmacro", paths);
            }
            catch(Exception ee) {
              ee.printStackTrace();//here comes script errors.
              //ADD redirect to coe.
            }
          }
        }
        ).start();
        return false;
      }
    }
    );
    ce.textFont=KyUI.fontMain;
    ce.commentEnabled=false;
    ce.textRenderer=new PwHighlighter(ce, PwMacroApi.class);
  }//TEST END
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
  frame_log.onLayout();
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
  try {
    String[] encoders=new it.sauronsoftware.jave.Encoder().getAudioEncoders();
    for (String s : encoders) {
      ((DropDown)KyUI.get("mp3_codec")).addItem(s);
    }
    ((DropDown)KyUI.get("mp3_codec")).text="libmp3lame";
    String[] formats=new it.sauronsoftware.jave.Encoder().getSupportedEncodingFormats();
    for (String s : formats) {
      ((DropDown)KyUI.get("mp3_format")).addItem(s);
    }
    ((DropDown)KyUI.get("mp3_format")).text="mp3";
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  //((Button)UI[getUIid("INITIAL_HOWTOUSE")]).text=readFile("versionText");
  //skinEditor=(SkinEditView)UI[getUIidRev("SKIN_EDIT")];
  //skinEditor.setComponents((TextBox)UI[getUIidRev("SKIN_PACKAGE")], (TextBox)UI[getUIidRev("SKIN_TITLE")], (TextBox)UI[getUIidRev("SKIN_AUTHOR")], (TextBox)UI[getUIidRev("SKIN_DESCRIPTION")], (TextBox)UI[getUIidRev("SKIN_APPNAME")], (Button)UI[getUIidRev("SKIN_TEXT1")]);
  info=new UnipackInfo();
  //setup
  loadTips();
  setup_ev1();
  script_setup();
  load_settings();
  led_setup();
  ks_setup();
  wav_setup();
  midi_setup();
  MidiCommand.setState("8x8");//#TEST
  au_setup();
  loadPaths();
  ((Button)KyUI.get("set_globalpath")).text=path_global;
  if (((ToggleButton)KyUI.get("set_reload")).value) {//reload
    load_reload();
  } else {
    addLedTab(createNewLed());
    addKsTab(createNewKs());
    //addWavTab(null);//no files loaded first.
  }
  ((LinearList)KyUI.get("ks_fileview")).setFixedSize(30);
  ((LinearList)KyUI.get("wv_files")).setFixedSize(30);
  ((LinearList)KyUI.get("mp3_input")).setFixedSize(30);
  FileSelectorButton.listDirectory(((LinearList)KyUI.get("ks_fileview")), new File(path_global), new java.util.function.Consumer<File>() {
    public void accept(File file) {
      //println("file accept : "+file.getAbsolutePath());
      if (isSoundFile(file)) {
        globalSamplePlayerPlay(file.getAbsolutePath());
      } else if (isLedFile(file)) {
        LedScript script=loadLedScript(file.getName(), readLed(file.getAbsolutePath()));
        script.displayPad=ks_pad;
        currentKs.light.start(currentKs.light.addTrack(script), 0);
      }
    }
  }
  );
  FileSelectorButton.listDirectory(((LinearList)KyUI.get("wv_files")), new File(path_global), new java.util.function.Consumer<File>() {
    public void accept(File file) {
      if (isSoundFile(file)) {
        globalSamplePlayerPlay(file.getAbsolutePath());
      }
    }
  }
  );
  if (!DEVELOPER_BUILD&&new File(joinPath(dataPath, "Initial")).isFile()) {//detect first time use.
    println("initial open");
    KyUI.addLayer(frame_tips);
    registerFileType();
    new File(joinPath(dataPath, "Initial")).delete();
  }
  //new Thread(new Runnable() {
  //  public void run() {
  //    vs_checkVersion();
  //  }
  //}
  //).start();
  KyUI.taskManager.executeAll();
  KyUI.getRoot().invalidate();//invalidate all!
  //add shortcuts
  setup_ev2();
  println("Setup finished");
  setupFinished=true;
}