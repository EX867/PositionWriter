//===Global vars===// - whole program will depends on these vars! especially command processing...
boolean optimize=true;//TEST
//
UnipackInfo info;//buttonX, chain and global things...
CommandEdit editor;//led editor
KsSession ks;//ks editor
StatusBar statusL;
StatusBar statusR;
//===Global finals===//
static final int AUTOINPUT=1;
static final int RIGHTOFFMODE=2;
static final int VEL=1;
static final int HTML=2;
static final int LED_EDITOR=1;//equals tab index
static final int KS_EDITOR=2;
static final int WAV_EDITOR=4;
static final int MACRO_EDITOR=5;
static final int NONE=0;
static final int LED_CHANGETITLE=1;
static final int KS_INFO=2;
static final int MACRO_CHANGETITLE=3;
//===Tabs===//
int mainTabs_selected=LED_EDITOR;
int externalFrame=NONE;
int ksControl_selected=1;//ctrl
//===States===//
int InputMode=AUTOINPUT;
int ColorMode=VEL;
int SelectedColor=0;
boolean InFrameInput=false;
boolean AutoSave=true;
boolean PrintOnPress=false;
int AutoSaveTime=30;
TitleChangeTarget titleChangeTarget;
VelocityButton VelocityType;
color[] color_vel;
String userMacro1="\ndelay 50";//#TEST 20
String userMacro2="\ndelay 30";
PImage[] tips;
int tipsIndex=0;
LedFindReplace ledFindReplace=new LedFindReplace();
//===Current editors===//
public LedScript currentLedEditor;//equivalent to currentLed.led.script
public LedTab currentLed;
public KsSession currentKs;
public WavTab currentWav;//warning. this can be null!
public MacroTab currentMacro;//this can also be null.
//===Paths===//
String path_global=joinPath(getDocuments(), "PositionWriter");
String path_projects="projects";
String path_led="led";
String path_export="export";
String path_tempSamples="temp/samples";
String path_macro="macro";
color[] color_lp;
color[] color_mf;
//===hashmap elements caching===//
FrameSlider fs;
Button fsTime;
PadButton led_pad;
TabLayout led_filetabs;
TabLayout ks_filetabs;
PadButton ks_pad;
PadButton ks_chain;
TextBox ks_soundindex;
TextBox ks_ledindex;
TabLayout macro_filetabs;
//==Additional frames===//
CachingFrame frame_main;
CachingFrame frame_changetitle;
CachingFrame frame_ksinfo;
CachingFrame frame_info;
CachingFrame frame_tips;
CachingFrame frame_mp3;
CachingFrame frame_log;
CachingFrame frame_update;
CachingFrame frame_skinedit;
//
interface TitleChangeTarget {
  String getTitle();
  void setTitleTo(String path);
}
class LedTab {
  LedCounter led;
  LightThread light;
  LedTab(LedScript script) {
    light=new LightThread();
    Thread thread=new Thread(light);
    light.thread=thread;
    led=light.addTrack(script);
    script.tab=this;
    thread.start();
  }
  public void close() {
    light.active=false;
    led.script.tab=null;
  }
}
ArrayList<LedTab> ledTabs=new ArrayList<LedTab>();//tab order.
ArrayList<KsSession> ksTabs=new ArrayList<KsSession>();
ArrayList<WavTab> wavTabs=new ArrayList<WavTab>();
ArrayList<MacroTab> macroTabs=new ArrayList<MacroTab>();
long lastAutoSaved=System.currentTimeMillis();
void autoSave() {
  if (AutoSave) {
    if (System.currentTimeMillis()>lastAutoSaved+AutoSaveTime*1000) {
      new Thread(new Runnable() {
        public void run() {
          KyUI.shortcutsByName.get("saveAll").event.onEvent(null);
        }
      }
      ).start();
      lastAutoSaved=System.currentTimeMillis();
    }
  }
}
void load_settings() {
  String path=joinPath(getDataPath(), "settings.xml");
  if (DEVELOPER_BUILD) {
    ((Button)KyUI.get("led_printq")).text=userMacro1.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
    ((Button)KyUI.get("led_printe")).text=userMacro2.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
    ((ToggleButton)KyUI.get("set_autosave")).value=false;
    return;
  } else {//also!
    ((Button)KyUI.get("led_printq")).text=userMacro1.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
    ((Button)KyUI.get("led_printe")).text=userMacro2.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
  }
  if (!new File(path).isFile()) {
    return;
  }
  LayoutLoader.loadElementProperties(loadXML(path));
  //load resolution
  AutoSave=((ToggleButton)KyUI.get("set_autosave")).value;
  AutoSaveTime=((TextBox)KyUI.get("set_autosavedelay")).valueI;
  PrintOnPress=((ToggleButton)KyUI.get("set_printonpress")).value;
  String mode=((DropDown)KyUI.get("set_mode")).text;
  if (mode.equals("AUTOINPUT")) {
    InputMode=AUTOINPUT;
  } else if (mode.equals("RIGHTOFFMODE")) {
    InputMode=RIGHTOFFMODE;
  }
  ui_textValueRange((TextBox)KyUI.get("set_dbuttonx"), 1, PAD_MAX);
  ui_textValueRange((TextBox)KyUI.get("set_dbuttony"), 1, PAD_MAX);
  ((Button)KyUI.get("led_printq")).text=userMacro1.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
  ((Button)KyUI.get("led_printe")).text=userMacro2.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
}
void export_settings() {//call when setting element is changed.
  if (DEVELOPER_BUILD) {
    println("settings store ignored");
    return;
  }
  //"set_resolution.value",
  String[] exportData=new String[]{"set_autosave.value", "set_autosavedelay.text", "set_reload.value", "set_textsize.text", "set_mode.text", "set_dbuttonx.text", "set_dbuttony.text", "set_printonpress.value", "led_printq.text", "led_printe.text"};
  writeFile(joinPath(getDataPath(), "settings.xml"), LayoutLoader.saveElementProperties(exportData).format(2));
  println("settings stored");
}
void load_reload() {
  String path=joinPath(getDataPath(), "reload.xml");
  if (!new File(path).isFile()) {
    return;
  }//no reload in developer mode
  XML xml=loadXML(path);
  XML[] led=xml.getChildren("led");
  for (XML dat : led) {
    if (new File(dat.getContent()).isFile()) {
      println("loading : "+dat.getContent());
      addLedFileTab(dat.getContent());
    }
  }
}
void export_reload() {
  if (DEVELOPER_BUILD) {
    println("reload store ignored");
    return;
  }
  XML xml=new XML("Data");
  for (LedTab tab : ledTabs) {
    xml.addChild("led").setContent(tab.led.script.file.getAbsolutePath());
  }
  writeFile(joinPath(getDataPath(), "reload.xml"), xml.format(2));
}
void loadTips() {
  File[] files=new File(joinPath(getDataPath(), "tips")).listFiles();
  ArrayList<PImage> images=new ArrayList<PImage>();
  for (File f : files) {
    if (isImageFile(f)) {
      images.add(loadImage(f.getAbsolutePath()));
    }
  }
  tips=new PImage[images.size()];
  for (int a=0; a<tips.length; a++) {
    tips[a]=images.get(a);
  }
  if (tips.length!=0) {
    ((ImageButton)KyUI.get("tips_content")).image=tips[tipsIndex];
  }
}
void loadPaths() {
  if (new File(joinPath(getDataPath(), "path.xml")).isFile()) {
    //path.xml : <Data "global"="C:/Users/?/Documents/PositionWriter" "projects"="..." "led"="..." "export"="..."/>
    String username=getUsername();
    XML customPath=loadXML("path.xml");
    path_global=customPath.getString("global", path_global).replace("?", username);
    path_projects=customPath.getString("projects", path_projects).replace("?", username);
    path_led=customPath.getString("led", path_led).replace("?", username);
    path_export=customPath.getString("export", path_export).replace("?", username);
  }
}