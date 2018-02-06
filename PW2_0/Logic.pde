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
boolean StartFromCursor=true;
boolean AutoStop=false;
boolean AutoSave=true;
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
  //LayoutLoader.loadProps(getDataPath());
}
void export_settings() {//call when setting element is changed.
  String[] exportData=new String[]{"set_autosave.value", "set_autosavedelay.valueI", "set_resolution.value", "set_reloaeinstart.value", "set_textsize", "set_startfromcursor", "set_autostop", "set_mode"};
  //float scale=Data.getFloat("value");//if negative or too big, error will occur.
  //surface.setSize(floor(initialWidth*scale), floor(initialHeight*scale));
  //setSize(floor(initialWidth*scale), floor(initialHeight*scale));
}