//===Global vars===// - whole program will depends on these vars! especially command processing...
UnipackInfo info;//buttonX, chain and global things...
CommandEdit editor;//led editor
KsSession ks;//ks editor
int ksChain;//current ks chain
StatusBar statusL;
StatusBar statusR;
//===Global finals===//
static final int AUTOINPUT=1;
static final int RIGHTOFFMODE=2;
static final int VEL=1;
static final int HTML=2;
static final int LED_EDITOR=1;//equals tab index
static final int KS_EDITOR=2;
//===Tabs===//
int mainTabs_selected=LED_EDITOR;
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
//===Current editors===//
LedScript currentLedEditor;//equivalent to currentLed.led.script
LedTab currentLed;
//===Paths===//
String path_global=joinPath(getDocuments(), "PositionWriter");
String path_projects="projects";
String path_ledPath="led";
String path_export="export";
String path_midi="midi";
color[] color_lp;
color[] color_mf;
//===hashmap elements caching===//
FrameSlider fs;
Button fsTime;
TabLayout led_filetabs;
//
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
    light.addTrack(IntVector2.zero, script);
    led=light.scripts.get(IntVector2.zero);
    script.tab=this;
    thread.start();
  }
}
ArrayList<LedTab> ledTabs=new ArrayList<LedTab>();//tab order.
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
    return;
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