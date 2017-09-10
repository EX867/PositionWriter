//INITIALIZE
import android.graphics.*;

//system
boolean sR=false;//screen
boolean R=true;//screen
boolean tR=false;//readFrame

//Layout
Display display;
int colorPress=0;
boolean velOpened=false;

//pos
int X;
int Y;

//color
int cR=255;
int cG=255;
int cB=255;
color[] recentColor=new color[10];

//Log
String Log="started";
String LogRead="";
String LogFull="";

int UndoMax=0;
int MAX_UNDO=20;
String[] Undo=new String[MAX_UNDO];
int UndoIndex=0;


void checkVersion() {
  //check version
  /*String lines[] = loadStrings(downloadLink);
  try {
    String data=lines[0];
    if (DEBUG)print(data+" : connected with server");
    if (data.equals(version)==false) {
      if (DEBUG)println("need update");
      Log="need update";
      //link(downloadLink);
    } else {
      if (DEBUG)println("latest version");
      Log="latest version";
    }
  }
  catch(Exception e) {
    if (DEBUG)println("can't connect with server");
    Log="Can't connect with server";
  }*/
  Log="PositionWriter mobile version "+version;
}

void initUI() {
  int i;
  btns = new RectButton[NofButtons+keyboardButtons];
  for (i=0; i < NofButtons; i++) {
    btns[i] = new RectButton(i, btnText [i], btnInit [i*4+0], btnInit [i*4+1], btnInit[i*4+2], btnInit [i*4+3], btnLayout [i]);
    //println (str (btns[i].x)+" "+str (btns [i].y)+" "+str (btns [i].w)+" "+str (btns [i].h));
    keyType[i]=false;
  }
  for (i=i; i <NofButtons+keyboardButtons; i++) {
    btns[i] = new RectButton(i-NofButtons, keyText [i-NofButtons], keyX+keyInitX [i-NofButtons]*keyWidth, keyY+keyInitY [i-NofButtons]*keyHeight, keyWidth*keyWidths [i-NofButtons], keyHeight,3);
    //println (str (btns[i].x)+" "+str (btns [i].y)+" "+str (btns [i].w)+" "+str (btns [i].h));
    keyboardType[i-NofButtons]=false;
    btns[i].buttonTextSize=30;
  }
  mt = new MultiTouch[maxTouchEvents];
  for (i=0; i < maxTouchEvents; i++) {
    mt[i] = new MultiTouch();
  }
}

void initColor() {
  int a=0;
  while (a<10) {
    recentColor[a]=color(255, 255, 255);
    a=a+1;
  }
  btns [PAD].colorEnabled=color (205);
  btns [PAD].colorPressed=color (205);
}

void initLog() {
  int a=0;
  while (a<MAX_UNDO) {
    RecordLog();
    a=a+1;
  }
}

//========================================================================================================CHECKERS

void longPress() {
  if (colorPress!=0) {
    sR=true;
  }
}


void RecordLog() {
  if (UndoMax<MAX_UNDO-1) {
    UndoMax=UndoMax+1;
  }
  int i=UndoMax;
  while (i>UndoIndex) {
    Undo[i]=Undo[i-1];
    i=i-1;
  }
  i=0;
  while (i<UndoMax+1-UndoIndex) {
    Undo[i]=Undo[i+UndoIndex];
    i=i+1;
  }
  UndoMax=UndoMax-UndoIndex;
  UndoIndex=0;
  Undo[0]=LogFull;
  println("log recorded");
}

boolean isOnRegion(int x, int y, int w, int h) {
  if (mousePressed==true) {
    if ((x<mouseX)&&(mouseX<(x+w))&&(y<mouseY)&&(mouseY<(y+h))) {
      sR=true;
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}




void apiOption (){
  println (android.os.Build.VERSION.SDK_INT);
  if(android.os.Build.VERSION.SDK_INT >=21){
 //   Window window=this.getWindow ();
//window.setNavigationBarColor(Color.parseColor("#CECECE"));
}
else{
} 
 
}





















//=====================================================================================================================FRAME_UPDATE

int MAX_FRAMES=1000;
color[][][] tmpframes=new color[MAX_FRAMES][8][8];//color
color[][][] frames=new color[MAX_FRAMES][8][8];//color
int[] delay=new int[MAX_FRAMES];
String[] temp;
int frameT=0;//total
int frameN=0;
int LengthTotal;
int LengthFrame;
boolean correctSyntax=true;

void copyArray() {
  int a;
  int b;
  int c;
  a=0;
  while (a<MAX_FRAMES) {
    b=0;
    while (b<8) {
      c=0;
      while (c<8) {
        frames[a][b][c]=tmpframes[a][b][c];
        c=c+1;
      }
      b=b+1;
    }
    a=a+1;
  }
}
void resetArray() {
  int a;
  int b;
  int c;
  a=0;
  while (a<MAX_FRAMES) {
    b=0;
    while (b<8) {
      c=0;
      while (c<8) {
        tmpframes[a][b][c]=-129;
        c=c+1;
      }
      b=b+1;
    }
    a=a+1;
  }
}
void sftArray(int n) {
  if (n==0) {
  } else {
    int a;
    int b;
    a=0;
    while (a<8) {
      b=0;
      while (b<8) {
        if (tmpframes[n-1][a][b]!=-128 && tmpframes[n][a][b]==-129) {
          tmpframes[n][a][b]=tmpframes[n-1][a][b];
        }
        b=b+1;
      }
      a=a+1;
    }
  }
}
void readFrame() {
  String Full=LogFull;
  correctSyntax=false;
  LogRead="reading...";
  temp=split(Full, "\n");
  int a=0;
  String[] ttemp;
  int l=temp.length;
  resetArray();
  LengthTotal=0;
  int framen=0;
  LengthFrame=1;
  while (a<l) {
    if (temp[a].length()==0) {
    } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {
    } else {
      ttemp=split(temp[a], " ");
      int tl=ttemp.length;
      //=====
      if (ttemp[0].equals("on") || ttemp[0].equals("o")) {//==========================o
        if (tl>5 || tl<4) {//error
          LogRead="line "+str (a+1)+":on has 3 or 4 arguments";
          break;
        } else {
          if (ttemp[1].length()!=0 &&ttemp[2].length()!=0) {//error
            if (int (ttemp [1])>0 &&int (ttemp [1])<=8&&int (ttemp [2])>0&&int (ttemp[2])<=8) {
              if (tl==5) {
                if (ttemp[3].equals("auto") || ttemp[3].equals("a")) {
                  if (ttemp[4].length()<=0) {
                    LogRead="line "+str(a+1)+":auto has 1 arguments found 0";
                    break;
                  } else if (int (ttemp [4])<0 || int (ttemp [4])>127){
                    LogRead="line "+str(a+1)+":invalid velocity";
                  } else {
                    tmpframes[framen][int(ttemp[2])-1][int(ttemp[1])-1]=color(k[int(ttemp[4])]);
                  }
                } else {
                  tmpframes[framen][int(ttemp[2])-1][int(ttemp[1])-1]=color(round(unhex(ttemp[3])/65536), round((unhex(ttemp[3])%65536)/256), round(unhex(ttemp[3])%256));
                }
              } else {
                if (ttemp[3].length()==0) {
                } else {
                  if (ttemp[3].equals("auto") ||ttemp[3].equals("a")) {
                    LogRead="line "+str (a+1)+":auto has 1 argumuments found 0";
                    break;
                  } else {
                    if (ttemp[3].length()!=6) {
                      if (0<=int(ttemp[3])&& int(ttemp[3])<=127) {
                        tmpframes[framen][int(ttemp[2])-1][int(ttemp[1])-1]=color(k[int(ttemp[3])]);
                        LogRead="line "+str(a+1)+":invalid velocity";
                      }
                      LogRead=str(k[int(ttemp[3])]);
                    } else {
                      tmpframes[framen][int(ttemp[2])-1][int(ttemp[1])-1]=color(round(unhex(ttemp[3])/65536), round((unhex(ttemp[3])%65536)/256), round(unhex(ttemp[3])%256));
                    }
                  }
                }
              }
            } else {
              LogRead="line "+str(a+1)+":invalid position";
            }
          } else {
            LogRead="line "+str(a+1)+":two blanks";
            break;
          }
        }
      } else if (ttemp[0].equals("off") || ttemp[0].equals("f")) {//==============================f
        if (tl==3) {
          if (ttemp[1].length()!=0 && ttemp[2].length()!=0) {
            if (int (ttemp [1])>0&&int (ttemp [1])<=8 &&int(ttemp [2])>0&&int (ttemp [2])<=8) {
              tmpframes[framen][int(ttemp[2])-1][int(ttemp[1])-1]=-128;
            } else {
              LogRead="line "+str(a+1)+":invalid position";
            }
          } else {
            LogRead="line "+str(a+1)+":two blanks";
            break;
          }
        } else {
          LogRead="line "+str(a+1)+":off has 2 arguments";
          break;
        }
      } else if (ttemp[0].equals("delay") || ttemp[0].equals("d")) {//=================================d
        if (tl==2) {
          if (ttemp[1].length()!=0) {
            if (int(ttemp[1])>=0) {
              delay[framen]=int(ttemp[1]);
              sftArray(framen);
              framen=framen+1;
              LengthTotal=LengthTotal+int(ttemp[1]);
              LengthFrame=LengthFrame+1;
            } else {
              LogRead="line "+str(a+1)+":invalid time";
              break;
            }
          } else {
            LogRead="line "+str(a+1)+":delay has 1 arguments found 0";
            break;
          }
        } else {
          LogRead="line "+str(a+1)+":delay has 1 arguments";
          break;
        }
      } else {
        LogRead="line "+str(a+1)+"invalid token \""+ttemp [0]+"\"";
        break;
      }
      //=====
    }
    a=a+1;
  }
  sftArray(framen);
  if (a==l) {
    LogRead="read completed";
    if (DEBUG)println (LogRead);
    correctSyntax=true;
  }
  copyArray();
  tR=false;
}
//=====================================================================================================================READ/WRITE
//BufferedReader reader;
PrintWriter write;
void export() {//=====
  if (correctSyntax==true) {
    long time = System.currentTimeMillis(); 
    SimpleDateFormat dayTime = new SimpleDateFormat("yyyy_mm_dd_hh_mm_ss");
    String str = dayTime.format(new Date(time));
    if (DEBUG)println(Environment.getExternalStorageDirectory().getAbsolutePath()+"/Positionwriter/export/"+str);
    String filePath=Environment.getExternalStorageDirectory().getAbsolutePath()+"/PositionWriter/export";
     write=createWriter (filePath+"/"+str);
     write.write(LEDformat());
     write.flush();
    Log="export completed";
  } else {
    Log="incorrect syntax export incomplete";
  }
}
void loadIni() {//=====
  /*reader=createReader("setup.ini");
  try {
    version=reader.readLine();
    println(version);
    versionLink=reader.readLine();
    downloadLink=reader.readLine();
    println(versionLink);
    println(downloadLink);
  }
  catch(Exception e) {
    println(e);
  }*/
}
String LEDformat() {//=====
  temp=split(display.getText(), "\n");
  String ret="";
  int a=0;
  int l=temp.length;
  String[] ttemp;
  while (a<l) {
    if (temp[a].equals("") ||temp[a].length()<=1) {
    } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {
    } else {
      ttemp=split(temp[a], " ");
      if ((ttemp[0].equals("on") || ttemp[0].equals("o"))&&(!(ttemp[3].equals("auto")||(ttemp[3].equals("a"))&&ttemp[3].length()!=6))) {
        ret=ret+ttemp[0]+" "+ttemp[1]+" "+ttemp[2]+" auto "+ttemp[3]+"\n";
      } else {
        ret=ret+temp[a]+"\n";
      }
    }
    a=a+1;
  }
  if (DEBUG)println(ret);
  return ret;
}
