
//next update play mode
//next update display line number
import java.text.*;
import java.util.*;
import java.io.*;
import android.os.*;
import android.content.*;
import android.view.*;
import android.view.Window;
import android.text.*;
//system
boolean DEBUG=false;
String version="1.0";

//JAVA vars
boolean LayoutMode=true;//true=no keyboard false=keyboard open

//display settings
float displayD;
int Screen_Width;
int Screen_Height;
int Screen_Width_FULL;
void setup() {
  //size(1000, 1280);
   size(displayWidth, displayHeight);
  //size (1440,1920);
  //println (displayWidth);
  //println (displayHeight);
  Screen_Height=height;
  Screen_Width_FULL=width;
  println (Screen_Height);
  Screen_Width=width;//floor((float)Screen_Height*9/16);
  displayD=(float)Screen_Width/720;
  println (displayD);
  initConstant1 ();
  initBackPress();
  frameRate(20);
  textSize(25);
  fill(200);
  strokeWeight(1*displayD);
  initButton();
  //loadIni();
  checkVersion();
  //Log=str (displayWidth)+" "+str (displayHeight)+" " +str (Screen_Width)+" "+str (Screen_Height)+" "+str (Screen_Height/1280)+" "+str (displayD);
  initUI();
  initColor();
  display=new Display();
  display.setText("//===EX867_PositionWriter_mobile===//");
  LogFull=display.getText();
  initLog ();
  readTemporary ();
  //apiOption ();
}
void draw() {
  try {
  if (R==true) {
    if (LayoutMode) {
      background(205);
    } else {
      background(205);
    }
  }
  if (R==true) {
    drawButtons();
  }
  display.drawConsole ();
  display.scroll ();
  fill (255);
  if (LayoutMode ==true) {
    renderPad();
    drawColorUITrue();
    recentColors ();
    frameSlider ();
    velocity ();
    drawLog();
  } else {
  }

  if (tR==true) {
    readFrame();
  }
  buttonRelease();
  if (mousePressed==false) {
    resetType();
  }
  //Looper.prepare();
  buttonPress ();
  DRAWmultiTouch ();
  longPress();
  if (DEBUG)LogRead=str (frameRate);
  }catch (Exception e){
    Log="error! "+e.toString ();
  }
  R=sR;
  sR=false;
  //Looper.loop ();
}



//==================================================================================MAIN
public boolean surfaceTouchEvent(MotionEvent me) {
  int pointers = me.getPointerCount();
  for (int i=0; i < maxTouchEvents; i++) {
    mt[i].touched = false;
  }
  for (int i=0; i < maxTouchEvents; i++) {
    if (i < pointers) {
      mt[i].update(me, i);
    } else {
      mt[i].update();
    }
  }
  return super.surfaceTouchEvent(me);
}


	@Override
	public void onBackPressed() {
		//super.onBackPressed();
if (LayoutMode){
		backPressCloseHandler.onBackPressed();
}else {
  LayoutMode=true;
    LogFull=display.getText();
    RecordLog();
    if (DEBUG)println("tframe lost focus");
    tR=true;
    sR=true;
}
	}

BufferedReader tempRead ;
void readTemporary (){
  try {
    tempRead=createReader (Environment.getExternalStorageDirectory ().getAbsolutePath()+"/PositionWriter/process/process.tmp");
    int a=0;
    int l=int (tempRead.readLine ());
    display.setText ("");
    while (a <l){
      if(a==0){
        display.setText(tempRead.readLine ());
      }else {
      display.setText (display.getText ()+"\n"+tempRead.readLine ());
      }
      a=a+1;
    }
  tempRead.close ();
  }catch (Exception e){
    println ("failed");
  }
  tR=true;
  sR=true;
  RecordLog ();
  readFrame();
  frameSlider ();
  LogRead="";
}
PrintWriter tempWrite;
void writeTemporary (){
  if (display.getText ().equals("")==false){
  //tempWrite=createWriter ("process.tmp"); 
  String filePath=Environment.getExternalStorageDirectory().getAbsolutePath()+"/PositionWriter/process";
     tempWrite=createWriter (filePath+"/process.tmp");
  //println (tempWrite.getPath ());
  println (new File (filePath+"/process.tmp").getAbsolutePath ());
  String [] splitText=split (display.getText (),"\n");
  int a=0;
  tempWrite.write (str(splitText.length));
  while (a <splitText.length){
    if (splitText [a].equals ("")||splitText [a].equals (null)){
      tempWrite.write("\n");
      }else {
    tempWrite.write("\n"+splitText [a]);
    }
    tempWrite.flush ();
    a=a+1;
  }
  }
}