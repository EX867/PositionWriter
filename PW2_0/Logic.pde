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
//===Paths===//
String path_global=getDocuments();
String path_projects="projects";
String path_ledPath="Led_saved";
String path_ksPath="KeySound_saved";

void exportSettings() {//call when setting element is changed.
  //write settings file.
}