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
int InputMode=RIGHTOFFMODE;
int ColorMode=VEL;
boolean InFrameInput=false;
//===Current editors===//
LedScript currentLedEditor;//equivalent to currentLed.led.script
LedTab currentLed;
//===Paths===//
String path_global=getDocuments();
String path_projects="projects";
String path_ledPath="Led_saved";
String path_ksPath="KeySound_saved";
//
//
class LedTab {
  LedCounter led;
  LightThread light;
  LedTab(LedScript script) {
    light=new LightThread();
    light.addTrack(IntVector2.zero, script);
    Thread thread=new Thread(light);
    light.thread=thread;
    thread.start();
  }
}
ArrayList<LedTab> ledTabs=new ArrayList<LedTab>();//tab order.

void exportSettings() {//call when setting element is changed.
  //write settings file.
}