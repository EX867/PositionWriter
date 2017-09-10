import java.text.*;
import java.util.*;
import java.io.*;
import java.net.*;
import processing.net.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.channels.FileChannel;
/*<<FIX!>>
 changed manual buttons
 ctrl+h manual(shortcuts) window(default hide)=function hided[key duplicate issues]
 recent used number top 2->q/w->shortcut.ini and ui.
 preview in switch
 *autorun quad*
 filename multi mapping name support
 mode select drag and drop
 
 //hard-to-do
 use kmp in nextfind
 next update hsb to rgb
 next update display line number
 find on regex
 if loop, don't erase colors
 autoInput-erase on instead print off in same frame
 
 error : there is an error when audio file length is very short. looper is not working!
 
 //to-do
 **tabs
 optionize switches
 everything to no enter
 tab to nextframe
 shortcut edit in settings**
 
 **sample led and macro
 
 //next
 led file drag and drop
 led and sound preview in keysound
 
 
 */

/* Environment */
String version="";
int bit=0;
int Language=0;

/* Net */
//String ip="";
//int port=80;
String downloadLink="";
String versionInfo="";

/* Font */
PFont velocityFont;
PFont editorFont;
int fontSize=1;//slider position

/* Editor global */
int Tab=0;
int Mode=0;
int mouseState=3;
boolean isPlaying=false;
boolean inFrameInput=false;
boolean drawOutFocus=false;//dont modify until success windowstatelistener!!
String globalPath=sketchPath();
int Focus=0;

/* Display global */
boolean R=true;
boolean sR=false;//drawing refresh
boolean tR=false;//text refresh=readframe
boolean editorFocus=false;
float scale=1;

/* Text global */
String Str_LED="//===EX867_Position_Writer===//";
String Str_Sound="//===EX867_Position_Writer===//";
String Str_Info="//===EX867_Position_Writer===//\ntitle=Enter title\nproducerName=Enter Producer\nbuttonX=8\nbuttonY=8\nchain=1\nsquareButton=true\nlandscape=true";
String Str_WavCut="//===EX867_Position_Writer===//";

/* Log global */
String Log="";//displayed in screen
String LogTemp="";//displayed in screen
String LogRead="";//use in finding error in led script
String LogFull="";//use in updating text
String LogCaution="";

/* Undo global */
int UndoMax=0;
int MAX_UNDO=20;
String[] Undo=new String[MAX_UNDO];//Undo[0] is current state
int UndoIndex=0;//Undo[10] is older than Undo[0], if you do something after undo, Undo[0]=Undo[UndiIndex];, slide.

void settings() {
  if (displayWidth>=displayHeight)scale=(float)displayHeight/1080;
  else scale=(float)displayWidth/1080;
  scale=1;//PLEASE! MODIFY ALL MOUSEXS INTO NEW VARIABLE!!!
  size(floor(scale*1150), floor(scale*840));
  println("display size : "+displayWidth+" "+displayHeight);
}
void setup() {
  //configure frame
  //this.frame.setLocation(200, 0);
  frameRate(30);
  fill(200);

  //configure text
  textSize(25);
  velocityFont=createFont("Gulim_Black", 18);
  editorFont=  createFont("Gulim_Black", 25);
  textFont(editorFont);
  textAlign(CENTER, CENTER);

  //configure editor
  getPath();
  fileViewDir=globalPath;
  keySoundPath=globalPath+"/sounds";
  EX_loadIni();
  //NT_checkVersion();

  //configure jframes
  configureTextEditor();
  configureFindReplace();
  configureHelp();

  //reset editor
  CF_resetEditor();
  resetArrayFull();
  autosave_start=0;
  autosave_end=System.currentTimeMillis();

  //CF_initAudio();

  Log="PositionWriter "+version;
}
@ Override 
  public void exit() {
  EX_autoSave("onExit", display.getText());
  errorLog.close();
  tframe.dispose();
  findReplace.dispose();
  help.dispose();
  super.exit();
}
/* AutoRun time vars */
boolean autorun_infinite=false;//set by ui
boolean autorun_isLoopLeft=false;
boolean autorun_finished_oneshot=false;
int autorun_loopCountTotal=1;//set by ui
int autorun_loopCount=0;

long autorun_start=0;
long autorun_end=0;
int autorun_endIndex=0;
int autorun_time=0;
boolean autorun_finished=true;

/* autosave vars */
long autosave_start=0;
long autosave_end=0;

void draw() {
  if (R&&isPlaying==false)background(255);
  scale(scale);    
  strokeWeight(1);
  stroke(0);
  LogTemp="";
  LogCaution="";
  if (Tab==TAB_LED) {
    if (isPlaying) {//PLAY MODE
      if (autorun_finished_oneshot==false||autorun_time==totalPlayTime) {
        autorun_start=autorun_end;
        //start
        if (autorun_loopCount<autorun_loopCountTotal) autorun_loopCount++;
        else autorun_isLoopLeft=false;
        autorun_displayFrame();
        //println(autorun_time+" "+autorun_endIndex);
        autoRunExceptionRefresh();
        displayAutoRun();
        drawAutorunQuad();
        //end
        autorun_end = System.currentTimeMillis(); 
        int interval=int(autorun_end-autorun_start);
        if (interval<0)interval=0;

        autorun_time=autorun_time+interval;
        if (autorun_time<0) autorun_time=0;
        if (autorun_time>totalPlayTime) {
          if (autorun_isLoopLeft||autorun_infinite&&totalPlayTime!=0)autorun_time=autorun_time%totalPlayTime;
          else {
            autorun_finished_oneshot=true;
            autorun_time=totalPlayTime;
          }
        }
      }
      if (autorun_finished==true) {
        isPlaying=false;
        println("play end");
      }
    } else {//EDITOR MODE
      UI_positionButtons();
      drawColorPanel();
      drawRecentColors();
      if (Mode==DEFAULT||Mode==AUTOINPUT)displayFrame();
      drawTab();
      displayTab();
      DS_displayVelocity();
      UI_recentColors();
      UI_colorSliders();
      displayAutoRun();
      //utils
      DS_font();
      DS_language();
      DS_inputInFrame();
      DS_infinite();
      DS_displayMode();
      DS_displayManuals();
      //draw!
      drawVelocity();
      drawMode();
      drawLog();
      drawManuals();
      CF_checkFocus();
      longPress();
    }
  } else if (Tab==TAB_KEYSOUND) {
    //UI_positionButtons();
    stroke(0);
    FileView(480);//
    PadButtonView();//
    DS_displayFileInfo();//
    displyPadButtonText();//
    drawTab();
    displayTab();
    drawLog();
    CF_checkFocus();
  } else if (Tab==TAB_INFO) {
    drawTab();
    displayTab();
    drawLog();
    info.drawUI();
    info.interactUI();
    info.update();
    CF_checkFocus();
  } else if (Tab==TAB_WAVCUTTER) {
    drawTab();
    displayTab();
    drawLog();
    CF_checkFocus();
  } else if (Tab==TAB_SETTINGS) {
    drawTab();
    displayTab();
    drawLog();
  } else if (Tab==TAB_MACROS) {
    drawTab();
    displayTab();
    drawLog();
  }
  if (tR==true||(frameCount%600==599&&isPlaying==false)) readFrame();//read per 30 secs
  if (mousePressed) {
    if (mouseState==AN_PRESS)mouseState=AN_PRESSED;
    if (mouseState==AN_RELEASE||mouseState==AN_RELEASED)mouseState=AN_PRESS;
  } else {
    if (mouseState==AN_RELEASE)mouseState=AN_RELEASED;
    if (mouseState==AN_PRESS||mouseState==AN_PRESSED)mouseState=AN_RELEASE;
  }
  /*if (focused==false) {
   mouseState=AN_RELEASED;
   if (textFocused) {
   if (drawOutFocus) {
   if (inFrameInput==false&&Tab==TAB_LED&&(Mode==DEFAULT||Mode==AUTOINPUT)) {
   readFrame();
   sliderTime=totalPlayTime;
   sliderIndex=totalFrames-1;
   }
   }
   }
   }*/
  if (mouseState==AN_RELEASED)colorPress=0;
  autosave_end=System.currentTimeMillis();
  if (autosave_end-autosave_start>AUTOSAVE_TIME) {
    thread("EX_autoSaveThread_time");
    autosave_start=autosave_end;
  }
  R=sR;
  sR=false;
}

//=====================================================================

void longPress() {
  if (colorPress!=0) {
    sR=true;
  }
}

void CF_checkFocus() {
  if (focused==true&&editorFocus==false) {
    println("CF_Position editor gets focus");
    LogFull=display.getText();
    RecordLog();
    editorFocus=true;
    //
    readFrame();
    sR=true;
  }
  if (focused==false&&editorFocus==true) {
    println("CF_Text editor gets focus");
    LogFull=display.getText();
    RecordLog();
    tR=true;
    editorFocus=false;
  }
}

void CF_resetEditor() {
  int a=0;
  while (a<10) {
    recentColor[a]=color(255, 255, 255);
    a=a+1;
  }
  a=0;
  while (a<MAX_UNDO) {
    RecordLog();
    a=a+1;
  }
}