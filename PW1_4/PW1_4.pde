import java.text.*;
import java.util.*;
import java.io.*;
import java.net.*;
import processing.net.*;
import sojamo.drop.*;
import java.lang.reflect.*;
/*<<FIX!>>
 v refactoring
 
 */
String currentFileName= "saved/"+new SimpleDateFormat("yyyy_mm_dd_hh_mm_ss").format(new Date(System.currentTimeMillis()));
boolean loaded=false;
boolean changed=false;

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
int Mode=1;
int mouseState=0;//0:nothing 1:click 2:press 3:released
boolean isPlaying=false;
boolean inFrameInput=false;

/* Display global */
boolean R=true;
boolean sR=false;//drawing refresh
boolean tR=false;//text refresh=readframe
boolean editorFocus=false;
float scale=1;

/* Log global */
String Log="";//displayed in screen
String LogTemp="";//displayed in screen
String LogRead="";//use in finding error in led script
String LogFull="";//use in updating text

/* Undo global */
int UndoMax=0;
int MAX_UNDO=20;
String[] Undo=new String[MAX_UNDO];//Undo[0] is current state
int UndoIndex=0;//Undo[10] is older than Undo[0], if you do something after undo, Undo[0]=Undo[UndiIndex];, slide.

void settings() {
  if (displayWidth>=displayHeight)scale=(float)displayHeight/1080;
  else scale=(float)displayWidth/1080;
  scale=1;
  size(floor(scale*1100), floor(scale*840));
  println("display size : "+displayWidth+" "+displayHeight);
}
SDrop drop;
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
  EX_loadIni();
  //NT_checkVersion();

  //configure jframes
  configureTextEditor();
  configureFindReplace();

  //reset editor
  CF_resetEditor();
  IM_colorImage();
  resetArrayFull();

  //...https://stackoverflow.com/questions/1555658/is-it-possible-in-java-to-access-private-fields-via-reflection
  try {
    Field f= surface.getClass().getDeclaredField("canvas");
    f.setAccessible(true);//Very important, this allows the setting to work.
    drop=new SDrop((java.awt.Canvas)f.get(surface));
    drop.addDropListener(new DropListener() {
      @Override
        public void dropEvent(DropEvent de) {
        try {
          String filename=de.toString().replace("\\", "/");
          BufferedReader read=createReader(filename);
          println("createReader : "+filename);
          loaded=true;
          currentFileName=filename;
          surface.setTitle("PositionWriter 1.4.3 - "+filename);
          String line="";
          String text="";
          while (line!=null) {
            text=text+line+"\n";
            line=read.readLine();
          }
          if (text.length()>0) {
            if (text.charAt(0)=='\n')text=text.substring(1, text.length());
          }
          read.close();
          display.setText(text);
        }
        catch(Exception e) {
          e.printStackTrace();
        }
      }
    }
    );
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  surface.setTitle("PositionWriter 1.4.3 - new file");
  autosave_start=0;
  autosave_end=System.currentTimeMillis();

  Log="PositionWriter "+version;
}
@ Override 
  public void exit() {
  EX_autoSave("onExit", display.getText());
  errorLog.close();
  tframe.dispose();
  findReplace.dispose();
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
  if (isPlaying) {//PLAY MODE
    scale(scale);    
    strokeWeight(1);
    if (autorun_finished_oneshot==false||autorun_time==totalPlayTime) {
      autorun_start=autorun_end;
      //start
      if (autorun_loopCount<autorun_loopCountTotal) {
        autorun_loopCount++;
      } else {
        autorun_isLoopLeft=false;
      }
      autorun_displayFrame();
      //println(autorun_time+" "+autorun_endIndex);
      autoRunExceptionRefresh();
      displayAutoRun();
      fill(0);
      stroke(0);
      quad(385, 400, 400, 385, 415, 400, 400, 415);
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
    try {
      if (mousePressed) {
        if (mouseState==1||mouseState==3)mouseState=2;
        else if (mouseState==0)mouseState=1;
      } else {
        if (mouseState==2||mouseState==1)mouseState=3;
        else if (mouseState==3)mouseState=0;
      }
      if (R)background(255);
      scale(scale);    
      strokeWeight(1);

      LogTemp="";

      UI_positionButtons();
      UI_colorPanel();

      try {
        displayFrame();
      }
      catch(Exception e) {
        errorLog.write(e.toString());
        errorLog.flush();
        Log=e.toString();
        sR=true;
      }

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

      //manuals
      DS_displayShortcuts();
      DS_displayManual();

      if (R) {//last add
        textSize(15);
        fill(255);//this is NOT infinite.move to rececntNumber
        rect(910, 745, 40, 20);
        rect(910, 770, 40, 20);
        fill(0);
        text(Recent1, 930, 755);
        text(Recent2, 930, 780);
      }


      //end of frame

      if (tR==true||(frameCount%600==599&&isPlaying==false)) readFrame();//read per 30 secs
      autosave_end=System.currentTimeMillis();
      if (autosave_end-autosave_start>AUTOSAVE_TIME) {

        thread("EX_autoSaveThread_time");
        autosave_start=autosave_end;
      }
      CF_displayLog();

      DS_displayTutorial();//for effect

      CF_checkFocus();
      longPress();
      R=sR;
      sR=false;
    }
    catch(Exception e) {
      errorLog.write(e.toString());
      errorLog.flush();
    }
  }
}

//=====================================================================
void CF_displayLog() {
  if (R) {
    textAlign(LEFT);
    fill(235);
    textSize(30);
    rect(0, 800, 300, 40);
    fill(120, 155, 255);
    rect(0, 800, 300, 8);
    fill(235);
    rect(300, 800, 750, 40);
    if (LogTemp.equals("")) {
      if (correctSyntax==false)fill(158, 10, 10);
      else fill(120, 155, 255);
      rect(300, 800, 750, 8);
      fill(0);
      text(LogRead, 320, 829);
    } else {
      rect(300, 800, 300, 40);
      fill(120, 155, 255);
      rect(300, 800, 300, 8);
      fill(0);
      text(LogTemp, 320, 829);
    }
    fill(0);
    text(Log, 20, 829);
    textAlign(CENTER, CENTER);
  }
}

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