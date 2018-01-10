//===Global vars===// - whole program will depends on these vars! especially command processing...
UnipackInfo info;//buttonX, chain and global things...
CommandEdit editor;//led editor
KsSession ks;//ks editor
int ksChain;//current ks chain
StatusBar statusL;
StatusBar statusR;
//===Global finals===//
static final int AUTOINPUT=1;
static final int MANUALINPUT=2;
static final int RIGHTOFFMODE=3;
//===Paths===//
String path_global=getDocuments();
String path_projects="projects";
String path_ledPath="Led_saved";
String path_ksPath="KeySound_saved";

void exportSettings() {//call when setting element is changed.
  //write settings file.
}