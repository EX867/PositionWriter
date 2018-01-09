//PositionWriter 2.0.pde
//===ADD list===//
//shortcuts = selectall,copy,cut,paste,(exists=undo,redo),registerq,registere,save,export,transportl,transportr,play,rewind,stop,loop,openfind,resetfocus,printq,printe,startfromcursor,autostop,autoinput vel controlx4,ksclear,delay value edit,macros
//add ziploader
//note on highlight
//drag and print range commands
//
//===ADD list - not now===//
//
// : add html+vel color autoinput mode
// : remove #platform_specific
// : KeySoundPlayer and midi->autoPlay
//
// skinedit : change theme to appcompat-material(later...)
// uncloud : wait uncloud update!!
// uncloud : customize list : display date and upload state inside list.
// uncloud : infoviewer design upgrade.
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
static final int DS_VEL=1;
static final int DS_HTML=2;
//static final int LINE_MAX_LENGTH=200;//text editor...
final float Width=1420;
final float Height=920;//scaled, not vary.
//
//===structure===//
void settings() {
  //smooth(8);
  initialScale=min((float)displayWidth/1920, (float)displayHeight/1080);
  initialWidth=1420;//*displayScale;
  initialHeight=920;//*displayScale;
  size(int(1420*initialScale), int(920*initialScale));
}
void setup() {
  if (DEBUG) {
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
  if (DEBUG) {
    try {
      main_draw();
    }
    catch(Exception e) {
      displayError(e);
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
  //#ADD autoSave();
  super.exit();
}
void handleKeyEvent(KeyEvent e) {
  super.handleKeyEvent(e);
  KyUI.handleEvent(e);
}
void handleMouseEvent(MouseEvent e) {
  super.handleMouseEvent(e);
  KyUI.handleEvent(e);
}
//
//===program logic===//
void main_setup() {
  rectMode(RADIUS);
  ellipseMode(RADIUS);
  textAlign(CENTER, CENTER);
  strokeCap(PROJECT);//set KyUI?
  imageMode(CENTER);
  textFont(createFont("fonts/SourceCodePro-Bold.ttf", 30));
  noStroke();
  frameRate(50);
  vs_detectProcessing();
  //orientation (LANDSCAPE);
  surface.setIcon(loadImage("icon.png"));
  textTransfer=new TextTransfer();
  KyUI.start(this);
  //load elements
  //load layout
  //load shortcuts
  //attach elements
  //add events
  //add events to tab! = repair title file path,midi off all
  //loaddefaultimages();
  vs_loadBuildVersion();
  vs_checkVersion();
  //uncloud_setup();
}
void main_draw() {
  KyUI.render(g);
  pushMatrix();
  scale(KyUI.scaleGlobal);
  //draw other things
  popMatrix();
}

//if (selectAll) {//Ctrl-A
//  current.selectAll();
//  current.line=current.lines()-1;
//  current.point=current.getLine(current.line).length();
//}
//if (copy) {//Ctrl-C
//  if (current.hasSelection())textTransfer.setClipboardContents(current.getSelection());
//} 
//if (cut) {//Ctrl-X
//  if (current.hasSelection()) {
//    textTransfer.setClipboardContents(current.getSelection());
//    current.deleteSelection();
//  }
//  current.resetSelection();
//  current.recorder.recordLog();
//  pkey='\0';
//}
//if (paste) {//Ctrl-V
//  if (current.hasSelection()) {
//    current.deleteSelection();
//  } 
//  String pasteString1=textTransfer.getClipboardContents().replace("\r\n", "\n").replace("\r", "\n");
//  if (pasteString1.length()>0) {
//    current.insert(pasteString1);
//  }
//  current.resetSelection();
//  current.recorder.recordLog();
//  pkey='\0';
//}
//if (registerQ) {//Ctrl+Q
//  userMacro1=current.getSelection();
//  Button num1=((Button)UI[getUIid("I_NUMBER1")]);
//  num1.text=userMacro1.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
//  num1.render();
//}
//if (registerE) {//Ctrl+E
//  //processing...don't stop!!
//  userMacro2=current.getSelection();
//  Button num2=((Button)UI[getUIid("I_NUMBER2")]);
//  num2.text=userMacro2.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
//  num2.render();
//}