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
//===States===//
int InputMode=AUTOINPUT;
int ColorMode=VEL;
boolean InFrameInput=false;
boolean StartFromCursor=true;
boolean AutoStop=false;
boolean AutoSave=true;
TitleChangeTarget titleChangeTarget;
//===Current editors===//
LedScript currentLedEditor;//equivalent to currentLed.led.script
LedTab currentLed;
//===Paths===//
String path_global=getDocuments();
String path_projects="Projects";
String path_ledPath="Led_saved";
String path_ksPath="KeySound_saved";
String path_midi="Midi";
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

void exportSettings() {//call when setting element is changed.
  //write settings file.
}