
String title_filename="";
String title_keyledfilename="";
String title_keysoundfoldername="";
String title_edited="";//or *.
String title_keylededited="";//
String title_keysoundedited="";//or *.
String filePath="";
boolean loadedOnce_led=false;
boolean loadedOnce_keySound=false;

boolean jeonjehong=false;
boolean initialOpen=false;
void setup_main() {
  External_setup();
  if (new File(joinPath(GlobalPath, "jeonjehong")).isFile()) {
    jeonjehong=true;
    println("jeonjehong=true");
  }
  if (new File(joinPath(getDataPath(), "Initial")).isFile()) {
    initialOpen=true;
    println("initial=true");
    new File(joinPath(getDataPath(), "Initial")).delete();
  }
  //setup data
  I_ResetKs();
  pushMatrix();
  scale(scale);
  pushMatrix();
  loadDefaultImages();
  UI_setup();
  AU_setup();
  title_filename=newFile();
  // === Initial Open === //
  if (initialOpen) {
    registerPrepare(getFrameid("F_INITIAL"));
  }
  // === Load in start === // loadedOnce_xxx can't be true on start, but settings.xml can set it to true on start. if true, reload.
  if (loadedOnce_keySound) {
    try {
      loadKeySoundGlobal(title_keysoundfoldername);
      title_keysoundedited="";
    }
    catch(Exception e) {
      displayLogError(e);
      loadedOnce_keySound=false;
    }
  } else {
    title_keysoundfoldername=newFolder();
  }
  if (loadedOnce_led) {
    try {
      keyled_textEditor.loadText(title_keyledfilename, readFile(title_keyledfilename));
      title_filename=title_keyledfilename;
      title_edited="";
    }
    catch(Exception e) {
      displayLogError(e);
      loadedOnce_led=false;
    }
  } else {
    title_keyledfilename=title_filename;
  }
}
long drawStart=0;
long drawEnd=0;
long drawInterval=100;

/* AutoRun time vars */
boolean autorun_infinite=false;//set by ui
int autorun_loopCountTotal=1;//set by ui
int autorun_loopCount=0;
int autorun_backup=0;
boolean autorun_playing=false;
boolean autorun_paused=false;
void draw_main() {
  //DEBUG
  autoSave();
}