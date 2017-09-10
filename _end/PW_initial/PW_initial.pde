import java.io.SequenceInputStream;
import java.util.*;
import java.text.*;
import java.io.*;



int ScreenWidth=1200;
int ScreenHeight=724;
int[] CS=new int[100];//ComponentSize
char[] keyMap_Action=new char[30];
char[] keyMap=new char[30];

boolean sR=true;//check during draw() if need refresh
boolean R=sR;//need Refresh, at last of draw() set R to sR
int Destination=0;

//ScrollView Vars
int ChainScrollX=0;//NoUse
int MultiMapScrollX=0;
int PadScrollX=0;
int PadScrollY=0;
int PadRate=1;
//int 
int textEditMode=0;
int dragMode=0;//select is 1
char keyBuf=0;
int keyAfterFrame=0;
char[] tempStr=new char[100];

boolean isMenuOpened=false;
int subMenuMode=0;

//Constant
int MAX_TOTAL=1000000;
int MAX_CHAIN=8;
int MAX_NODES=100;
int MAX_MULTI=20;
int MAX_LEDFRAME=500;
int MAX_LEDNODES=1000;
int ProjectN=1000;
int EProjectN=1000;

//Save
String ProjectPath=sketchPath("");
String[] Paths=new String[ProjectN];
String[] EPaths=new String[EProjectN];
BufferedReader Read;
String tmpTitle;

//url
String NaverCafe="http://cafe.naver.com/unipad";
String cmd[]=null;
//never change constants
int[] Llist=new int[128];

//Projct Datas
String Title="";//title
String ProducerName="";//producerName
int Width=8;//buttonX
int Height=8;//ButtonY
int NofChains=1;//chain
boolean SquareButtons=true;//squareButtons
boolean Landscape=true;//landscape
//
int[] NofMultiMap=new int[MAX_NODES*MAX_CHAIN];//node
String[][] Filenames= new String[MAX_NODES*MAX_CHAIN][MAX_MULTI];//node,multiMap
short[][] Loops= new short[MAX_NODES*MAX_CHAIN][MAX_MULTI];//node,multiMap
int[][] NofLedFrame=new int[MAX_NODES*MAX_CHAIN][MAX_MULTI];//node,multiMap
int[][] LedLoops=new int[MAX_NODES*MAX_CHAIN][MAX_MULTI];

int[][][] Delays=new int[MAX_NODES*MAX_CHAIN][MAX_MULTI][MAX_LEDFRAME];//node,mulyimap,ledframes

int[][][] Color=new int[MAX_LEDFRAME][MAX_NODES][MAX_LEDNODES];//frames,nodes,stack(ledframes*node)//  R*16^4+G*16^2+B
short[][][] L=new short[MAX_LEDFRAME][MAX_NODES][MAX_LEDNODES];//
int[][] LedPointer=new int[MAX_NODES*MAX_CHAIN][MAX_MULTI];//node,multiMap


int NofLedPointer=0;
//Project Attributes
int Chainindex=1;
//Pad Attributes
boolean isPadSelected=true;//false;
int X=1;
int Y=1;
int Node=Width*Height*(Chainindex-1)+Width*(Y-1)+X;//This controls all of attributes.
String Filename="";
int Loop=1;
int MultiMapindex=1;//Multi Mappings
//LedFrame Attributes
boolean isLedFrameSelected=false;
int Frameindex=0;//LED Frame
int Delay=0;//milliseconds
//LedElement Attributes
boolean isLedElementSelected=false;
int LX=1;
int LY=1;
int LNode=-1;
int Lcolor=-1;
short LL=-1;
/*

 Node(Chainindex,X,Y)>>MultiMapping>>File,LEDSequence>>LED Node>>color,l
 
 
 
 
 
 
 */
//Utilities============================================================================================================================================================================================================================================
boolean isOnRegion(int x, int y, int w, int h) {
  if (mousePressed==true&&mouseButton==LEFT) {
    if ((x<mouseX&&mouseX<x+w)&&(y<mouseY&&pmouseY<y+h)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
boolean isROnRegion(int x, int y, int w, int h) {
  if (mousePressed==true&&mouseButton==RIGHT) {
    if ((x<mouseX&&mouseX<x+w)&&(y<mouseY&&pmouseY<y+h)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
void setup() {
  size(1200, 724);
  int a;
  frameRate(20);
  //Component Size Initialize
  //>Scrollbar=20
  CS[0]=40;//Select Tool
  CS[1]=(ScreenWidth-ScreenHeight)/8+2;//Chain Selector
  CS[2]=(ScreenWidth-ScreenHeight)/8+2;//Multi-Mapping System
  CS[3]=240;
  CS[4]=80;//led frames (other space is color picker)
  LoadKeyMap();
  a=0;
  while (a<ProjectN) {
    Paths[a]=null;
    a=a+1;
  }
  LoadLInfo();
  ReSetup();
}
void ReSetup() {
  int a, b, c;
  Date date=new Date();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy_MM_dd_hh_mm_ss"); 
  Title=sdf.format(date).toString(); 

  ProducerName="user";
  Width=8;
  Height=8;
  NofChains=1;
  SquareButtons=true;
  Landscape=true;

  a=0;
  while (a<MAX_NODES*MAX_CHAIN) {
    NofMultiMap[a]=1;
    a=a+1;
  }
  a=0;
  while (a<MAX_NODES*MAX_CHAIN) {
    b=0;
    while (b<MAX_MULTI) {
      c=0;
      while (c<MAX_LEDFRAME) {
        Delays[a][b][c]=0;
        c=c+1;
      }
      Filenames[a][b]="";
      Loops[a][b]=1;
      NofLedFrame[a][b]=0;
      LedLoops[a][b]=1;
      b=b+1;
    }
    a=a+1;
  }
  a=0;
  while (a<MAX_LEDFRAME) {
    b=0;
    while (b<MAX_NODES) {
      c=0;
      while (c<MAX_LEDNODES) {
        Color[a][b][c]=-1;
        L[a][b][c]=-1;
        c=c+1;
      }
      b=b+1;
    }
    a=a+1;
  }
  a=0;
  while (a<MAX_NODES*MAX_CHAIN) {
    b=0;
    while (b<MAX_MULTI) {
      LedPointer[a][b]=-1;
      b=b+1;
    }
    a=a+1;
  }
  //LedPointer[0][0]=0;//
  NofLedFrame[0][0]=1;
  LoadInfo();
}
void draw() {//Start====================================================================================================================================================================================================================================
  int a, b;
  /*
  fill(255);
   rect(100, 50, 200, 100);
   fill(0);
   text(frameRate, 100, 100);
   fill(255);
   */
  //Layout Drawing=====================================================================================================================================================================================================================================
  //>Frame Render
  textSize(30);
  if (R==true) {
    background(255);
    stroke(0);
    strokeWeight(8);
    line(0, 0, ScreenWidth, 0);
    line(0, 0, 0, ScreenHeight);
    line(ScreenWidth, ScreenHeight, ScreenWidth, 0);
    line(ScreenWidth, ScreenHeight, 0, ScreenHeight);

    strokeWeight(4);
    fill(225);
    rect(2, 2, ScreenHeight-20-2, ScreenHeight-20-2);
    fill(255);
    rect(ScreenHeight-20, 2, 20, 20);
    rect(ScreenHeight-20, ScreenHeight-20-20, 20, 20);
    rect(2, ScreenHeight-20, 20, 18);
    rect(ScreenHeight-20-20, ScreenHeight-20, 20, 18);

    line(ScreenHeight, 0, ScreenHeight, ScreenHeight);
    fill(225);
    rect(ScreenHeight, 2, ScreenWidth-ScreenHeight-2, CS[0]-2);
    rect(ScreenHeight, CS[0], ScreenWidth-ScreenHeight-2, CS[1]);
    fill(255);
    rect(ScreenHeight, CS[0]+CS[1], 20, 20);
    rect(ScreenWidth-22, CS[0]+CS[1], 20, 20);
    fill(225);
    rect(ScreenHeight, CS[0]+CS[1]+20, ScreenWidth-ScreenHeight-2, CS[2]);
    fill(255);
    rect(ScreenHeight, CS[0]+CS[1]+CS[2]+20, 20, 20);
    rect(ScreenWidth-22, CS[0]+CS[1]+CS[2]+20, 20, 20);
    fill(225);
    line(ScreenHeight, CS[0]+CS[1]+CS[2]+40, ScreenWidth, CS[0]+CS[1]+CS[2]+40);

    fill(225);
    rect(ScreenHeight, CS[0]+CS[1]+CS[2]+60, ScreenWidth-ScreenHeight-2, 120);
    fill(255);
    rect(ScreenHeight, CS[0]+CS[1]+CS[2]+60, 40, 120);
    rect(ScreenHeight+120, CS[0]+CS[1]+CS[2]+60, 100, 120);
    fill(0);
    text("#", ScreenHeight+10, CS[0]+CS[1]+CS[2]+90);
    text("X", ScreenHeight+10, CS[0]+CS[1]+CS[2]+130);
    text("Y", ScreenHeight+10, CS[0]+CS[1]+CS[2]+170);
    text("chain", ScreenHeight+135, CS[0]+CS[1]+CS[2]+90);
    text("loop", ScreenHeight+140, CS[0]+CS[1]+CS[2]+130);
    text("file", ScreenHeight+150, CS[0]+CS[1]+CS[2]+170);
    if (isPadSelected==true) {
      text(MultiMapindex, ScreenHeight+50, CS[0]+CS[1]+CS[2]+90);
      text(X, ScreenHeight+50, CS[0]+CS[1]+CS[2]+130);
      text(Y, ScreenHeight+50, CS[0]+CS[1]+CS[2]+170);
      text(Chainindex, ScreenHeight+230, CS[0]+CS[1]+CS[2]+90);
      text(Loop, ScreenHeight+230, CS[0]+CS[1]+CS[2]+130);
      if (Filename==null) {
        text("none", ScreenHeight+230, CS[0]+CS[1]+CS[2]+170);
      } else {
        text(Filename, ScreenHeight+230, CS[0]+CS[1]+CS[2]+170);
      }
    }
    line(ScreenHeight, CS[0]+CS[1]+CS[2]+100, ScreenWidth, CS[0]+CS[1]+CS[2]+100);
    line(ScreenHeight, CS[0]+CS[1]+CS[2]+140, ScreenWidth, CS[0]+CS[1]+CS[2]+140);

    fill(225);
    rect(ScreenHeight, CS[0]+CS[1]+CS[2]+200, ScreenWidth-ScreenHeight-2, 40);
    fill(255);
    rect(ScreenHeight, CS[0]+CS[1]+CS[2]+200, 40, 40);
    rect(ScreenHeight+120, CS[0]+CS[1]+CS[2]+200, 100, 40);
    fill(0);
    if (isLedFrameSelected==true) {
      text("#", ScreenHeight+10, CS[0]+CS[1]+CS[2]+230);
      text("delay", ScreenHeight+130, CS[0]+CS[1]+CS[2]+230);
      text(Frameindex, ScreenHeight+50, CS[0]+CS[1]+CS[2]+230);
      text(Delay, ScreenHeight+230, CS[0]+CS[1]+CS[2]+230);
    }
    fill(225);
    rect(ScreenHeight, CS[0]+CS[1]+CS[2]+260, ScreenWidth-ScreenHeight-2, 80);
    fill(255);
    rect(ScreenHeight, CS[0]+CS[1]+CS[2]+260, 40, 80);
    rect(ScreenHeight+120, CS[0]+CS[1]+CS[2]+260, 120, 80);
    fill(0);
    if (isLedElementSelected==true&&isLedFrameSelected==true) {
      text("X", ScreenHeight+10, CS[0]+CS[1]+CS[2]+290);
      text("Y", ScreenHeight+10, CS[0]+CS[1]+CS[2]+330);
      text("launch", ScreenHeight+135, CS[0]+CS[1]+CS[2]+290);
      text("color", ScreenHeight+145, CS[0]+CS[1]+CS[2]+330);
      text(LX, ScreenHeight+50, CS[0]+CS[1]+CS[2]+290);
      text(LY, ScreenHeight+50, CS[0]+CS[1]+CS[2]+330);
      if (LL==-1) {
        text("none", ScreenHeight+250, CS[0]+CS[1]+CS[2]+290);
      } else {
        text(LL, ScreenHeight+250, CS[0]+CS[1]+CS[2]+290);
      }
      if (Lcolor==-1) {
        text("none", ScreenHeight+250, CS[0]+CS[1]+CS[2]+330);
      } else {
        text("#"+Integer.toHexString(Lcolor), ScreenHeight+250, CS[0]+CS[1]+CS[2]+330);
      }
    }
    line(ScreenHeight, CS[0]+CS[1]+CS[2]+300, ScreenWidth, CS[0]+CS[1]+CS[2]+300);

    fill(225);
    rect(ScreenHeight, CS[0]+CS[1]+CS[2]+CS[3]+120, ScreenWidth-ScreenHeight-2, CS[4]);
    rect(ScreenHeight*2-(CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120), CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120, ScreenWidth-2*ScreenHeight+(CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120)-2, 120);// ScreenHeight-(CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120+2));
    fill(255);
    rect(ScreenHeight*2-(CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120), CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120, 40, 120);
    rect(ScreenHeight*2-(CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120)+160, CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120, 40, 120);
    rect(ScreenHeight+8, CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120+8, ScreenHeight-(CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120+8)-8, ScreenHeight-(CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120+8)-8);
    line(ScreenHeight*2-(CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120), CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+160, ScreenWidth, CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+160);
    line(ScreenHeight*2-(CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+120), CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+200, ScreenWidth, CS[0]+CS[1]+CS[2]+CS[3]+CS[4]+200);
  }
  //===================================================================================================================================================================================================================================================

  //Inspector Render===================================================================================================================================================================================================================================
  a=0;
  while (a<NofChains) {
    if (isOnRegion(ScreenHeight+(ScreenWidth-ScreenHeight)/8*a+8, CS[0]+8, (ScreenWidth-ScreenHeight)/8-16, (ScreenWidth-ScreenHeight)/8-16)&&isMenuOpened==false&&subMenuMode==0) {
      sR=true;
      Chainindex=a+1;
      fill(225);
    } else if (Chainindex-1==a) {
      fill(150, 201, 255);
    } else {
      fill(255);
    }
    if (R==true) {
      rect(ScreenHeight+(ScreenWidth-ScreenHeight)/8*a+8, CS[0]+8, (ScreenWidth-ScreenHeight)/8-16, (ScreenWidth-ScreenHeight)/8-16);
      line(ScreenHeight+(ScreenWidth-ScreenHeight)/8*(a+1), CS[0], ScreenHeight+(ScreenWidth-ScreenHeight)/8*(a+1), CS[0]+CS[1]);
      fill(0);
      text(a+1, ScreenHeight+(ScreenWidth-ScreenHeight)/8*a+20, CS[0]+(ScreenWidth-ScreenHeight)/8-20);
    }
    a=a+1;
  }
  if (isOnRegion(ScreenHeight+(ScreenWidth-ScreenHeight)/8*NofChains+8, CS[0]+8, (ScreenWidth-ScreenHeight)/8-16, (ScreenWidth-ScreenHeight)/8-16)&&isMenuOpened==false&&subMenuMode==0) {
    sR=true;
    NofChains=NofChains+1;
  }
  if (R==true) {
    fill(255);
    rect(ScreenHeight+(ScreenWidth-ScreenHeight)/8*NofChains+8, CS[0]+8, (ScreenWidth-ScreenHeight)/8-16, (ScreenWidth-ScreenHeight)/8-16);
    fill(0);
    text("+", ScreenHeight+(ScreenWidth-ScreenHeight)/8*NofChains+18, CS[0]+(ScreenWidth-ScreenHeight)/8-20);
  }
  //MultiMapSelect
  a=0;
  while (a<NofMultiMap[Node-1] && dragMode==0) {
    if (isOnRegion(ScreenHeight+(ScreenWidth-ScreenHeight)/8*a+8, CS[0]+CS[1]+8, (ScreenWidth-ScreenHeight)/8-16, (ScreenWidth-ScreenHeight)/8-16)&&isMenuOpened==false&&subMenuMode==0) {
      sR=true;
      MultiMapindex=a+1;
      fill(225);
    } else if (isROnRegion(ScreenHeight+(ScreenWidth-ScreenHeight)/8*a+8, CS[0]+CS[1]+8, (ScreenWidth-ScreenHeight)/8-16, (ScreenWidth-ScreenHeight)/8-16)&&isMenuOpened==false&&subMenuMode==0) {
      sR=true;
      MultiMapindex=a+1;
      fill(225);
      dragMode=2;
    } else if (MultiMapindex-1==a) {//editeditediteidteditediteditediteditediteditediteditedtieidteiteditediteditediediteidteditedte!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1111111!!!!!!!!!!!!!!!!!!!!11
      fill(255, 0, 0, 80);
    } else {
      fill(255);
    }
    if (R==true) {
      rect(ScreenHeight+(ScreenWidth-ScreenHeight)/8*a+8, CS[0]+CS[1]+20+8, (ScreenWidth-ScreenHeight)/8-16, (ScreenWidth-ScreenHeight)/8-16);
      line(ScreenHeight+(ScreenWidth-ScreenHeight)/8*(a+1), CS[0]+CS[1]+20, ScreenHeight+(ScreenWidth-ScreenHeight)/8*(a+1), CS[0]+CS[1]+CS[2]+20);
      fill(0);
      text(a+1, ScreenHeight+(ScreenWidth-ScreenHeight)/8*a+20, CS[0]+CS[1]+20+(ScreenWidth-ScreenHeight)/8-20);
    }
    a=a+1;
  }
  if (isOnRegion(ScreenHeight+(ScreenWidth-ScreenHeight)/8*NofMultiMap[Node-1]+8, CS[0]+CS[1]+20+8, (ScreenWidth-ScreenHeight)/8-16, (ScreenWidth-ScreenHeight)/8-16)&&isMenuOpened==false&&subMenuMode==0) {
    sR=true;
    NofMultiMap[Node-1]=NofMultiMap[Node-1]+1;
  }
  if (R==true) {
    fill(255);
    rect(ScreenHeight+(ScreenWidth-ScreenHeight)/8*NofMultiMap[Node-1]+8, CS[0]+CS[1]+20+8, (ScreenWidth-ScreenHeight)/8-16, (ScreenWidth-ScreenHeight)/8-16);
    fill(0);
    text("+", ScreenHeight+(ScreenWidth-ScreenHeight)/8*NofMultiMap[Node-1]+18, CS[0]+CS[1]+20+(ScreenWidth-ScreenHeight)/8-20);
  }
  if (dragMode==2) {
    a=0;
    while (a<NofMultiMap[Node-1]) {
      if (mousePressed==true&&mouseButton==LEFT) {
        if (isROnRegion(ScreenHeight+(ScreenWidth-ScreenHeight)/8*a+8-(CS[2]/2), CS[0]+CS[1]+20+8, (ScreenWidth-ScreenHeight)/8-16, (ScreenWidth-ScreenHeight)/8-16)) {
          if (!(Destination==a)) {
            sR=true;
          }
          Destination=a;
        }
      } else {
        dragMode=0;
      }
      a=a+1;
    }
    stroke(255, 0, 0, 80);
    line(ScreenHeight+(ScreenWidth-ScreenHeight)/8*Destination, CS[0]+CS[1]+20+8, ScreenHeight+(ScreenWidth-ScreenHeight)/8*Destination, CS[0]+CS[1]+CS[2]+20+8);
    stroke(0);
  }

  //Selection End
  a=0;
  if (isPadSelected==true) {
    while (a<NofLedFrame[Node-1][MultiMapindex-1]) {
      if (isOnRegion(ScreenHeight+8+a*CS[4], CS[0]+CS[1]+CS[2]+CS[3]+120+8, CS[4]-16, CS[4]-16)) {
        isLedFrameSelected=true;
        sR=true;
        fill(225);
        Frameindex=a+1;
      } else if (Frameindex-1==a) {
        fill(180, 240, 130);
      } else {
        fill(255);
      }
      if (R==true) {
        rect(ScreenHeight+8+a*CS[4], CS[0]+CS[1]+CS[2]+CS[3]+120+8, CS[4]-16, CS[4]-16);
      }
      a=a+1;
    }
  }
  if (R==true) {
    fill(255);
    rect(ScreenHeight+8+NofLedFrame[Node-1][MultiMapindex-1]*CS[4], CS[0]+CS[1]+CS[2]+CS[3]+120+8, CS[4]-16, CS[4]-16);
    fill(0);
    text("+", ScreenHeight+8+NofLedFrame[Node-1][MultiMapindex-1]*CS[4]+20, CS[0]+CS[1]+CS[2]+CS[3]+120+8+42);
  }
  if (isOnRegion(ScreenHeight+8+NofLedFrame[Node-1][MultiMapindex-1]*CS[4], CS[0]+CS[1]+CS[2]+CS[3]+120+8, CS[4]-16, CS[4]-16)) {
    sR=true;
    NofLedFrame[Node-1][MultiMapindex-1]+=1;
  }


  //Grid Render=============================================================================================================================================================================================================================================
  fill(255);
  a=0;
  while (a<Width) {
    if (R==true) {
      line((ScreenHeight-20)/8*a*PadRate+2, 0, (ScreenHeight-20)/8*a*PadRate, ScreenHeight-20);
    }
    if (isOnRegion((ScreenHeight-20)/8*a*PadRate+2, 0, (ScreenHeight-20)/8*PadRate, ScreenHeight-20)&&subMenuMode==0) {
      isPadSelected=true;
      isLedElementSelected=false;
      sR=true;
      X=a+1;
    } else if (isROnRegion((ScreenHeight-20)/8*a*PadRate+2, 0, (ScreenHeight-20)/8*PadRate, ScreenHeight-20)&&subMenuMode==0) {// && isLedFrameSelected==true) {
      isLedElementSelected=true;
      sR=true;
      LX=a+1;
    }
    a=a+1;
  }
  a=0;
  while (a<Height) {
    if (R==true) {
      line(0, (ScreenHeight-20)/8*a*PadRate+2, ScreenHeight-20, (ScreenHeight-20)/8*a*PadRate);
    }
    if (isOnRegion(2, (ScreenHeight-20)/8*a*PadRate+2, ScreenHeight-20, (ScreenHeight-20)/8*PadRate)&&subMenuMode==0) {
      isPadSelected=true;
      isLedElementSelected=false;
      sR=true;
      Y=a+1;
    } else if (isROnRegion(2, (ScreenHeight-20)/8*a*PadRate+2, ScreenHeight-20, (ScreenHeight-20)/8*PadRate)&&subMenuMode==0) {// && isLedFrameSelected==true) {
      isLedElementSelected=true;
      sR=true;
      LY=a+1;
    }
    a=a+1;
  }
  if (R==true) {
    //middle point
    fill(0);
    a=(ScreenHeight-20)/8*4*PadRate;
    b=(ScreenHeight-20)/8*4*PadRate;
    quad(a+20, b, a, b-20, a-20, b, a, b+20);
    fill(255);
  }
  if (R==true) {
    b=0;
    while (b<Height) {
      a=0;
      while (a<Width) {
        if (LedPointer[Node-1][MultiMapindex-1]>=0&&isLedFrameSelected==true) {
          if (!(Color[Frameindex-1][Width*b+a][LedPointer[Node-1][MultiMapindex-1]]==-1)) {
            fill(round((Color[Frameindex-1][Width*b+a][LedPointer[Node-1][MultiMapindex-1]]%16777216)/65536), round((Color[Frameindex-1][Width*b+a][LedPointer[Node-1][MultiMapindex-1]]%65536)/256), round(Color[Frameindex-1][Width*b+a][LedPointer[Node-1][MultiMapindex-1]]%256));
            rect((ScreenHeight-20)/8*a*PadRate+1, (ScreenHeight-20)/8*b*PadRate+1, (ScreenHeight-20)/8*PadRate, (ScreenHeight-20)/8*PadRate);
          } else if (!(L[Frameindex-1][Width*b+a][LedPointer[Node-1][MultiMapindex-1]]==-1)&&(L[Frameindex-1][Width*b+a][LedPointer[Node-1][MultiMapindex-1]]<128)) {
            fill(round((Llist[L[Frameindex-1][Width*b+a][LedPointer[Node-1][MultiMapindex-1]]]%16777216)/65536), round((Llist[L[Frameindex-1][Width*b+a][LedPointer[Node-1][MultiMapindex-1]]]%65536)/256), round(Llist[L[Frameindex-1][Width*b+a][LedPointer[Node-1][MultiMapindex-1]]]%256));
            rect((ScreenHeight-20)/8*a*PadRate+1, (ScreenHeight-20)/8*b*PadRate+1, (ScreenHeight-20)/8*PadRate, (ScreenHeight-20)/8*PadRate);
          }
        }
        a=a+1;
      }
      b=b+1;
    }
  }
  fill(255);
  if (R==true) {
    if (NofMultiMap[Node-1]<MultiMapindex) {
      MultiMapindex=NofMultiMap[Node-1];
      if (MultiMapindex<=0) {
        MultiMapindex=1;
      }
    }
    if (NofLedFrame[Node-1][MultiMapindex-1]<Frameindex) {
      Frameindex=NofLedFrame[Node-1][MultiMapindex-1];
      isLedElementSelected=false;
      if (Frameindex<=0) {
        isLedFrameSelected=false;
        Frameindex=0;
      }
    }
    if (isPadSelected==true) {
      fill(0, 0, 0, 0);
      stroke(150, 201, 255);
      strokeWeight(12);
      rect((ScreenHeight-20)/8*(X-1)*PadRate, (ScreenHeight-20)/8*(Y-1)*PadRate, (ScreenHeight-20)/8*PadRate, (ScreenHeight-20)/8*PadRate);
      stroke(0);
      strokeWeight(4);
      rect((ScreenHeight-20)/8*(X-1)*PadRate-8, (ScreenHeight-20)/8*(Y-1)*PadRate-8, (ScreenHeight-20)/8*PadRate+16, (ScreenHeight-20)/8*PadRate+16);
      rect((ScreenHeight-20)/8*(X-1)*PadRate+8, (ScreenHeight-20)/8*(Y-1)*PadRate+8, (ScreenHeight-20)/8*PadRate-16, (ScreenHeight-20)/8*PadRate-16);
      fill(255);
    }
    if (isLedElementSelected==true&&isLedFrameSelected==true) {
      fill(0, 0, 0, 0);
      stroke(180, 240, 130);
      strokeWeight(12);
      rect((ScreenHeight-20)/8*(LX-1)*PadRate, (ScreenHeight-20)/8*(LY-1)*PadRate, (ScreenHeight-20)/8*PadRate, (ScreenHeight-20)/8*PadRate);
      stroke(0);
      strokeWeight(4);
      rect((ScreenHeight-20)/8*(LX-1)*PadRate-8, (ScreenHeight-20)/8*(LY-1)*PadRate-8, (ScreenHeight-20)/8*PadRate+16, (ScreenHeight-20)/8*PadRate+16);
      rect((ScreenHeight-20)/8*(LX-1)*PadRate+8, (ScreenHeight-20)/8*(LY-1)*PadRate+8, (ScreenHeight-20)/8*PadRate-16, (ScreenHeight-20)/8*PadRate-16);
      fill(255);
    }
  }
  //Selection====================================================================================================================================================================================================================================================
  Node=Width*Height*(Chainindex-1)+Width*(Y-1)+X;//node ref
  Loop=Loops[Node-1][MultiMapindex-1];
  Filename=Filenames[Node-1][MultiMapindex-1];
  if (isLedFrameSelected==true) {
    Delay= Delays[Node-1][MultiMapindex-1][Frameindex-1];
  }
  LNode=Width*(LY-1)+LX;
  if (isLedElementSelected==true&&isLedFrameSelected==true&&!(LedPointer[Node-1][MultiMapindex-1]==-1)) {//ledcursur info ref
    LL=L[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]];
    if (LL>=128) {
      L[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]=127;
    } else if (L[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]<-1) {
      L[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]=-1;
    }
    if (Color[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]>=16777216) {
      Color[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]=16777215;
    } else if (Color[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]<-1) {
      Color[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]=-1;
    }
    Lcolor=Color[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]];
    /*
    LR=round((Color[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]%16777216/65536);
     LG=round((Color[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]%65536)/256);
     LB=round(Color[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]%256);
     */
  }
  //textEdit======================================================================================================================================================================================================================================================
  if (!(textEditMode==0)&&mousePressed==true) {
    sR=true;
  }
  if (isOnRegion(ScreenHeight+220, CS[0]+CS[1]+CS[2]+100, ScreenWidth-ScreenHeight-220, 40)&&isMenuOpened==false&&subMenuMode==0) {
    sR=true;
    textEditMode=5;
  } else if (isOnRegion(ScreenHeight+220, CS[0]+CS[1]+CS[2]+140, ScreenWidth-ScreenHeight-220, 40)&&isMenuOpened==false&&subMenuMode==0) {
    sR=true;
    textEditMode=6;
  } else if (isOnRegion(ScreenHeight+220, CS[0]+CS[1]+CS[2]+200, ScreenWidth-ScreenHeight-220, 40)&&isMenuOpened==false&&subMenuMode==0) {
    sR=true;
    textEditMode=8;
  } else if (isOnRegion(ScreenHeight+240, CS[0]+CS[1]+CS[2]+260, ScreenWidth-ScreenHeight-240, 40)&&isMenuOpened==false&&subMenuMode==0) {
    sR=true;
    textEditMode=11;
  } else if (isOnRegion(ScreenHeight+240, CS[0]+CS[1]+CS[2]+300, ScreenWidth-ScreenHeight-240, 40)&&isMenuOpened==false&&subMenuMode==0) {
    sR=true;
    textEditMode=12;
  } else if (mousePressed==true) {
    textEditMode=0;
  }
  if (textEditMode==0) {
  } else if (textEditMode==13||textEditMode==14||textEditMode==15||textEditMode==16||textEditMode==17||textEditMode==18||textEditMode==19) {
    //title,producerName,buttonX,buttonY,chain
  } else if (textEditMode==5) {
    fill(120);
    rect(ScreenHeight+220, CS[0]+CS[1]+CS[2]+100, ScreenWidth-ScreenHeight-220-2, 40);
    if (isPadSelected==true) {
      fill(255);
      text(Loop+"_", ScreenHeight+230, CS[0]+CS[1]+CS[2]+130);
      if (keyPressed==true) {//key
        if (!(insertNum()==-1)) {
          if (keyAfterFrame==0||!(keyBuf==insertNum())) {
            keyBuf=(char)insertNum();
            keyAfterFrame=3;
            Loop=Loop*10+insertNum();
            if (Loop<0) {
              Loops[Node-1][MultiMapindex-1]=0;
              Loop=0;
            } else {
              Loops[Node-1][MultiMapindex-1]=(short)Loop;
            }
          }
        }
        if (key==BACKSPACE) {
          if (keyAfterFrame==0) {
            keyBuf=key;
            keyAfterFrame=3;
            if (Loop<0) {
              Loops[Node-1][MultiMapindex-1]=0;
              Loop=0;
            } else {
              Loop=round(Loop/10);
            }
            Loops[Node-1][MultiMapindex-1]=(short)Loop;
          }
        }
        keyAfterFrame-=1;
        if (keyAfterFrame<0) {
          keyAfterFrame=0;
        }
      } else {
        keyBuf=0;
      }//end
    } else {
      textEditMode=0;
    }
  } else if (textEditMode==6) {
    fill(120);
    rect(ScreenHeight+220, CS[0]+CS[1]+CS[2]+140, ScreenWidth-ScreenHeight-220-2, 40);
    if (isPadSelected==true) {
      fill(255);
      if (Filename==null || Filename=="") {
        text("_", ScreenHeight+230, CS[0]+CS[1]+CS[2]+170);
      } else {
        text(Filename+"_", ScreenHeight+230, CS[0]+CS[1]+CS[2]+170);
      }
      if (keyPressed==true) {//key
        if (key==BACKSPACE) {
          if (keyAfterFrame==0) {
            keyBuf=key;
            keyAfterFrame=3;
            if (Filename==null || Filename=="") {
            } else {
              tempStr=Filename.toCharArray();
              a=Filename.length();
              b=0;
              Filename="";
              while (b<a-1) {
                Filename=Filename+str(tempStr[b]);
                b=b+1;
              }
              Filenames[Node-1][MultiMapindex-1]=Filename;
            }
          }
        } else {
          if (keyAfterFrame==0||!(keyBuf==key)) {
            keyBuf=key;
            keyAfterFrame=3;
            if (Filename==null) {
              Filename="";
            }
            Filename=Filename+key;
            Filenames[Node-1][MultiMapindex-1]=Filename;
          }
        }
        keyAfterFrame-=1;
        if (keyAfterFrame<0) {
          keyAfterFrame=0;
        }
      } else {
        keyBuf=0;
      }//end
    } else {
      textEditMode=0;
    }
  } else if (textEditMode==8) {
    fill(120);
    rect(ScreenHeight+220, CS[0]+CS[1]+CS[2]+200, ScreenWidth-ScreenHeight-220-2, 40);
    if (isLedFrameSelected==true) {
      fill(255);
      text(Delay+"_", ScreenHeight+230, CS[0]+CS[1]+CS[2]+230);
      if (!(insertNum()==-1)) {
        if (keyAfterFrame==0||!(keyBuf==insertNum())) {
          keyBuf=(char)insertNum();
          keyAfterFrame=3;
          Delay=Delay*10+insertNum();
          if (Delay<0) {
            Delays[Node-1][MultiMapindex-1][Frameindex-1]=0;
            Delay=0;
          } else {
            Delays[Node-1][MultiMapindex-1][Frameindex-1]=Delay;
          }
        }
        if (key==BACKSPACE) {
          if (keyAfterFrame==0) {
            keyBuf=key;
            keyAfterFrame=3;
            Delay=round(Delay/10);
            if (Loop<0) {
              Delays[Node-1][MultiMapindex-1][Frameindex-1]=0;
              Delay=0;
            } else {
              Delays[Node-1][MultiMapindex-1][Frameindex-1]=Delay;
            }
          }
        }
        keyAfterFrame-=1;
        if (keyAfterFrame<0) {
          keyAfterFrame=0;
        }
      } else {
        keyBuf=0;
      }//end
    } else {
      textEditMode=0;
    }
  } else if (textEditMode==11) {
    fill(120);
    rect(ScreenHeight+240, CS[0]+CS[1]+CS[2]+260, ScreenWidth-ScreenHeight-240-2, 40);
    if (isLedElementSelected==true) {
      fill(255);
      if (LL==-1) {
        text("_", ScreenHeight+250, CS[0]+CS[1]+CS[2]+290);
      } else {
        text(LL+"_", ScreenHeight+250, CS[0]+CS[1]+CS[2]+290);
      }
      if (keyPressed==true) {//key
        if (!(insertNum()==-1)) {
          if (keyAfterFrame==0||!(keyBuf==insertNum())) {
            keyBuf=(char)insertNum();
            keyAfterFrame=3;
            if (isPointerExists(Node, MultiMapindex)==false) {
              CreatePointer(Node, MultiMapindex);
            }
            if (LL<0) {
              LL=(short)insertNum();
            } else {
              LL=(short)(LL*10+insertNum());
            }
            L[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]=LL;
          }
        }
        if (key==BACKSPACE) {
          if (keyAfterFrame==0) {
            keyBuf=key;
            keyAfterFrame=3;
            if (LL==0) {
              LL=-1;
            } else {
              LL=(short)round(LL/10);
            }
            L[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]=LL;
          }
          keyAfterFrame-=1;
          if (keyAfterFrame<0) {
            keyAfterFrame=0;
          }
        }
      } else {
        keyBuf=0;
      }//end
    } else {
      textEditMode=0;
    }
  } else if (textEditMode==12) {
    fill(120);
    rect(ScreenHeight+240, CS[0]+CS[1]+CS[2]+300, ScreenWidth-ScreenHeight-240-2, 40);
    if (isLedElementSelected==true) {
      fill(255);
      if (Lcolor==-1) {
        text("#"+"_", ScreenHeight+250, CS[0]+CS[1]+CS[2]+330);
      } else {
        text("#"+hex(Lcolor, 6)+"_", ScreenHeight+250, CS[0]+CS[1]+CS[2]+330);
      }
      if (keyPressed==true) {//key
        if (!(insertHNum()==-1)) {
          if (keyAfterFrame==0||!(keyBuf==insertHNum())) {
            keyBuf=(char)insertHNum();
            keyAfterFrame=3;
            if (isPointerExists(Node, MultiMapindex)==false) {
              CreatePointer(Node, MultiMapindex);
            }
            if (Lcolor<0) {
              Lcolor=insertHNum();
            } else {
              Lcolor=Lcolor*16+insertHNum();
            }
            if (Lcolor>16777216) {
              Lcolor=Color[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]];
            } else {
              Color[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]=Lcolor;
            }
          }
        }
        if (key==BACKSPACE) {
          if (keyAfterFrame==0) {
            keyBuf=key;
            keyAfterFrame=3;
            if (Lcolor==0) {
              Lcolor=-1;
            } else {
              Lcolor=round(Lcolor/16);
            }
          }
          if (isPointerExists(Node, MultiMapindex)==false) {
            CreatePointer(Node, MultiMapindex);
          }
          Color[Frameindex-1][LNode-1][LedPointer[Node-1][MultiMapindex-1]]=Lcolor;
        }
        keyAfterFrame-=1;
        if (keyAfterFrame<0) {
          keyAfterFrame=0;
        }
      } else {
        keyBuf=0;
      }//end
    } else {
      textEditMode=0;
    }
  }
  fill(255);
  //Menus=========================================================================================================================================================================================================================================================
  //mainmenu
  rect(ScreenHeight, 2, 80, CS[0]-2);
  fill(0);
  text("File", ScreenHeight+15, 33);
  fill(255);
  if (R==true) {
    if (isMenuOpened==true||!(subMenuMode==0)) {
      fill(0, 40);
      rect(0, 0, ScreenWidth, ScreenHeight);
      fill(255);
    }
  }
  if (isMenuOpened==true) {
    fill(255);
    rect(ScreenHeight, CS[0], 250, 40);
    rect(ScreenHeight, CS[0]+40, 250, 40);
    rect(ScreenHeight, CS[0]+80, 250, 40);
    rect(ScreenHeight, CS[0]+120, 250, 40);
    rect(ScreenHeight, CS[0]+160, 250, 40);
    rect(ScreenHeight, CS[0]+200, 250, 40);
    rect(ScreenHeight, CS[0]+240, 250, 40);
    rect(ScreenHeight, CS[0]+280, 250, 40);
    rect(ScreenHeight, CS[0]+320, 250, 40);
    rect(ScreenHeight, CS[0]+360, 250, 40);
    fill(0);
    textSize(28);
    text("New project", ScreenHeight+5, CS[0]+30);//
    text("Open project", ScreenHeight+5, CS[0]+70);//in progress
    text("Save project", ScreenHeight+5, CS[0]+110);//in progress
    text("Import Unipack", ScreenHeight+5, CS[0]+150);
    text("Export Unipack", ScreenHeight+5, CS[0]+190);
    text("Compress to .uni", ScreenHeight+5, CS[0]+230);
    text("Project settings", ScreenHeight+5, CS[0]+270);
    text("Settings", ScreenHeight+5, CS[0]+310);
    text("Open Community", ScreenHeight+5, CS[0]+350);//completed
    text("Help", ScreenHeight+5, CS[0]+390);//completed
    fill(255);
    textSize(30);
  }
  if (isOnRegion(ScreenHeight, 2, 80, CS[0]-2)&&subMenuMode==0) {
    sR=true;
    isMenuOpened=true;
  } else if (isOnRegion(ScreenHeight, CS[0], 250, 40)&&isMenuOpened==true) {
    sR=true;
    fill(225);
    rect(ScreenHeight, CS[0], 250, 40);
    fill(255);
    subMenuMode=1;
  } else if (isOnRegion(ScreenHeight, CS[0]+40, 250, 40)&&isMenuOpened==true) {
    sR=true;
    fill(225);
    rect(ScreenHeight, CS[0]+40, 250, 40);
    fill(255);
    subMenuMode=2;
  } else if (isOnRegion(ScreenHeight, CS[0]+80, 250, 40)&&isMenuOpened==true) {
    sR=true;
    fill(225);
    rect(ScreenHeight, CS[0]+80, 250, 40);
    fill(255);
    subMenuMode=3;
  } else if (isOnRegion(ScreenHeight, CS[0]+120, 250, 40)&&isMenuOpened==true) {
    sR=true;
    fill(225);
    rect(ScreenHeight, CS[0]+120, 250, 40);
    fill(255);
    subMenuMode=4;
  } else if (isOnRegion(ScreenHeight, CS[0]+160, 250, 40)&&isMenuOpened==true) {
    sR=true;
    fill(225);
    rect(ScreenHeight, CS[0]+160, 250, 40);
    fill(255);
    subMenuMode=5;
  } else if (isOnRegion(ScreenHeight, CS[0]+200, 250, 40)&&isMenuOpened==true) {
    sR=true;
    fill(225);
    rect(ScreenHeight, CS[0]+200, 250, 40);
    fill(255);
    LoadInfo();
    subMenuMode=6;
  } else if (isOnRegion(ScreenHeight, CS[0]+240, 250, 40)&&isMenuOpened==true) {
    sR=true;
    fill(225);
    rect(ScreenHeight, CS[0]+240, 250, 40);
    fill(255);
    subMenuMode=7;
  } else if (isOnRegion(ScreenHeight, CS[0]+280, 250, 40)&&isMenuOpened==true) {
    sR=true;
    fill(225);
    rect(ScreenHeight, CS[0]+280, 250, 40);
    fill(255);
    subMenuMode=8;
  } else if (isOnRegion(ScreenHeight, CS[0]+320, 250, 40)&&isMenuOpened==true) {
    sR=true;
    fill(225);
    rect(ScreenHeight, CS[0]+320, 250, 40);
    fill(255);
    subMenuMode=9;
  } else if (isOnRegion(ScreenHeight, CS[0]+360, 250, 40)&&isMenuOpened==true) {
    sR=true;
    fill(225);
    rect(ScreenHeight, CS[0]+360, 250, 40);
    fill(255);
    subMenuMode=10;
  } else if (mousePressed==true) {
    sR=true;
    isMenuOpened=false;
  }
  if (subMenuMode==1) {
    isMenuOpened=false;
    sR=true;
    //Dialog==========
    fill(255);
    rect(400, 250, ScreenWidth-800, ScreenHeight-500);
    rect(440, 380, 100, 60);
    rect(550, 380, 100, 60);
    rect(660, 380, 100, 60);
    fill(0);
    text("save file?", 450, 300);
    text("yes", 460, 420);
    text("no", 580, 420);
    text("cancel", 665, 420);
    if (isOnRegion(440, 380, 100, 60)) {
      SaveProject(Title);
      subMenuMode=0;
      sR=true;
      ReSetup();
    }
    if (isOnRegion(550, 380, 100, 60)) {
      subMenuMode=0;
      sR=true;
      ReSetup();
    }
    if (isOnRegion(660, 380, 100, 60)) {
      subMenuMode=0;
      sR=true;
    }
  } else if (subMenuMode==2) {
    isMenuOpened=false;
    if (R==true) {
      rect(100, 100, ScreenWidth-300, ScreenHeight-200);
      fill(255, 130, 130);
      rect(ScreenWidth-230, 80, 40, 40);
      a=0;
      while (a<ProjectN) {
        try {
          if (!(Paths[a]==null)) {
            if (isOnRegion(120, 130+a*40, ScreenWidth-500, 40)) {
              LoadProject(Paths[a]);
              subMenuMode=0;
              sR=true;
              break;
            }
            fill(255);
            rect(120, 130+a*40, ScreenWidth-500, 40);
            fill(0);
            text(Paths[a], 130, 160+a*40);
          }
        }
        catch(Exception e) {
        }
        a=a+1;
      }
      text("X", ScreenWidth-219, 111);
      fill(255);
      if (isOnRegion(ScreenWidth-230, 80, 40, 40)) {
        subMenuMode=0;
        sR=true;
      }
    }
  } else if (subMenuMode==3) {//save
    SaveProject(Title);
    subMenuMode=0;
    sR=true;
  } else if (subMenuMode==4) {
  } else if (subMenuMode==5) {//export
    Export();
    subMenuMode=0;
    sR=true;
  } else if (subMenuMode==6) {
    isMenuOpened=false;
    if (R==true) {
      rect(100, 100, ScreenWidth-300, ScreenHeight-200);
      fill(255, 130, 130);
      rect(ScreenWidth-230, 80, 40, 40);
      a=0;
      while (a<EProjectN) {
        try {
          if (!(EPaths[a]==null)) {
            if (isOnRegion(120, 130+a*40, ScreenWidth-500, 40)) {
              //compress.zip("/data/export/"+EPaths[a]+"/", "/data/export/"+EPaths[a]+"/"+EPaths[a]+".uni");
              subMenuMode=0;
              sR=true;
              break;
            }
            fill(255);
            rect(120, 130+a*40, ScreenWidth-500, 40);
            fill(0);
            text(Paths[a], 130, 160+a*40);
          }
        }
        catch(Exception e) {
        }
        a=a+1;
      }
      text("X", ScreenWidth-219, 111);
      fill(255);
      if (isOnRegion(ScreenWidth-230, 80, 40, 40)) {
        subMenuMode=0;
        sR=true;
      }
    }
  } else if (subMenuMode==7) {//project settings
    isMenuOpened=false;
    fill(255);
    rect(200, 100, ScreenWidth-400, ScreenHeight-200);
    fill(225);
    rect(250, 150, ScreenWidth-500, 320);
    fill(255);
    rect(250, 150, 250, 320);
    a=1;
    while (a<8) {
      line(250, 150+40*a, ScreenWidth-250, 150+40*a);
      a=a+1;
    }
    rect(ScreenWidth-285, 355, 35, 30);
    rect(ScreenWidth-285, 395, 35, 30);
    fill(0);
    text("Title", 255, 180);
    text("ProducerName", 255, 220);
    text("ButtonX", 255, 260);
    text("ButtonY", 255, 300);
    text("Chain", 255, 340);
    text("Square buttons", 255, 380);
    text("Landscape", 255, 420);

    text(Title, 505, 180);
    text(ProducerName, 505, 220);
    text(Width, 505, 260);
    text(Height, 505, 300);
    text(NofChains, 505, 340);
    text(str(SquareButtons), 505, 380);
    if (SquareButtons==true) {
      stroke(255, 130, 130);
      line(ScreenWidth-290, 350, ScreenWidth-270, 370);
      line(ScreenWidth-270, 370, ScreenWidth-240, 345);
      stroke(0);
    }
    text(str(Landscape), 505, 420);
    if (Landscape==true) {
      stroke(255, 130, 130);
      line(ScreenWidth-290, 390, ScreenWidth-270, 410);
      line(ScreenWidth-270, 410, ScreenWidth-240, 385);
      stroke(0);
    }

    fill(255, 130, 130);
    rect(ScreenWidth-230, 80, 40, 40);
    fill(0);
    text("X", ScreenWidth-219, 111);
    fill(255);
    //TextEditMode
    if (textEditMode==13) {
      fill(120);
      rect(500, 150, ScreenWidth-750, 40);
      fill(255);
      text(Title+"_", 505, 180);
      if (keyPressed==true) {//key
        if (key==BACKSPACE) {
          if (keyAfterFrame==0) {
            keyBuf=key;
            keyAfterFrame=3;
            if (Title==null || Title=="") {
            } else {
              tempStr=Title.toCharArray();
              a=Title.length();
              b=0;
              Title="";
              while (b<a-1) {
                Title=Title+str(tempStr[b]);
                b=b+1;
              }
            }
          }
        } else {
          if (keyAfterFrame==0||!(keyBuf==key)) {
            keyBuf=key;
            keyAfterFrame=3;
            if (Title==null) {
              Title="";
            }
            Title=Title+key;
          }
        }
        keyAfterFrame-=1;
        if (keyAfterFrame<0) {
          keyAfterFrame=0;
        }
      } else {
        keyBuf=0;
      }//end
    } else if (textEditMode==14) {
      fill(120);
      rect(500, 190, ScreenWidth-750, 40);
      fill(255);
      text(ProducerName+"_", 505, 220);
      if (keyPressed==true) {//key
        if (key==BACKSPACE) {
          if (keyAfterFrame==0) {
            keyBuf=key;
            keyAfterFrame=3;
            if (ProducerName==null || ProducerName=="") {
            } else {
              tempStr=ProducerName.toCharArray();
              a=ProducerName.length();
              b=0;
              ProducerName="";
              while (b<a-1) {
                ProducerName=ProducerName+str(tempStr[b]);
                b=b+1;
              }
            }
          }
        } else {
          if (keyAfterFrame==0||!(keyBuf==key)) {
            keyBuf=key;
            keyAfterFrame=3;
            if (ProducerName==null) {
              ProducerName="";
            }
            ProducerName=ProducerName+key;
          }
        }
        keyAfterFrame-=1;
        if (keyAfterFrame<0) {
          keyAfterFrame=0;
        }
      } else {
        keyBuf=0;
      }//end
    } else if (textEditMode==15) {//height,unblock in next release with scrollbar
      fill(120);
      rect(500, 230, ScreenWidth-750, 40);
      textEditMode=0;
    } else if (textEditMode==16) {//Width, unblock in next release with scrollbar
      fill(120);
      rect(500, 270, ScreenWidth-750, 40);
      textEditMode=0;
    } else if (textEditMode==17) {//chain, It can be edited on mainscreen so i blocked
      fill(120);
      rect(500, 310, ScreenWidth-750, 40);
      if (mousePressed==true) {
        fill(255);
        text("edit on mainscreen", 505, 340);
      } else {
        textEditMode=0;
      }
    } else if (textEditMode==18) {//squareButtons,boolean
      if (mousePressed==false) {
        if (SquareButtons==true) {
          SquareButtons=false;
        } else {
          SquareButtons=true;
        }
        textEditMode=0;
      }
    } else if (textEditMode==19) {//landscape,boolean
      if (mousePressed==false) {
        if (Landscape==true) {
          Landscape=false;
        } else {
          Landscape=true;
        }
        textEditMode=0;
      }
    }
    if (isOnRegion(500, 150, ScreenWidth-500, 40)) {
      textEditMode=13;
    } else if (isOnRegion(500, 190, ScreenWidth-500, 40)) {
      textEditMode=14;
    } else if (isOnRegion(500, 230, ScreenWidth-500, 40)) {
      textEditMode=15;
    } else if (isOnRegion(500, 270, ScreenWidth-500, 40)) {
      textEditMode=16;
    } else if (isOnRegion(500, 310, ScreenWidth-500, 40)) {
      textEditMode=17;
    } else if (isOnRegion(ScreenWidth-285, 355, 35, 30)) {
      textEditMode=18;
    } else if (isOnRegion(ScreenWidth-285, 395, 35, 30)) {
      textEditMode=19;
    } else if (mousePressed==true) {
      textEditMode=0;
    }

    //end
    if (isOnRegion(ScreenWidth-230, 80, 40, 40)) {
      subMenuMode=0;
      sR=true;
    }
  } else if (subMenuMode==8) {//
  } else if (subMenuMode==9) {//naver cafe
    isMenuOpened=false;
    subMenuMode=0;
    sR=true;
    cmd = new String[] {"rundll32", "url.dll", "FileProtocolHandler", NaverCafe};
    Process process = null;
    try {
      process = new ProcessBuilder(cmd).start();
      SequenceInputStream seqIn = new SequenceInputStream(
        process.getInputStream(), process.getErrorStream());
      Scanner s = new Scanner(seqIn);
      while (s.hasNextLine() == true) {
        System.out.println(s.nextLine());
      }
    } 
    catch (IOException e) {
      println("error in opening internet");
    }
  } else if (subMenuMode==10) {
    isMenuOpened=false;
    if (R==true) {
      rect(100, 100, ScreenWidth-300, ScreenHeight-200);
      fill(255, 130, 130);
      rect(ScreenWidth-230, 80, 40, 40);
      fill(0);
      text("Unipad by JiSeop\nEditor by EX867", 130, 160);
      text("X", ScreenWidth-219, 111);
    }
    fill(255);
    if (isOnRegion(ScreenWidth-230, 80, 40, 40)) {
      subMenuMode=0;
      sR=true;
    }
  }


  R=sR;
  sR=false;
}
//Insert=============================================================================================================================================================================================================================================================
int insertNum() {
  if (keyPressed==true) {
    if (key=='0') {
      return 0;
    } else if (key=='1') {
      return 1;
    } else if (key=='2') {
      return 2;
    } else if (key=='3') {
      return 3;
    } else if (key=='4') {
      return 4;
    } else if (key=='5') {
      return 5;
    } else if (key=='6') {
      return 6;
    } else if (key=='7') {
      return 7;
    } else if (key=='8') {
      return 8;
    } else if (key=='9') {
      return 9;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}
int insertHNum() {
  if (keyPressed==true) {
    if (key=='0') {
      return 0;
    } else if (key=='1') {
      return 1;
    } else if (key=='2') {
      return 2;
    } else if (key=='3') {
      return 3;
    } else if (key=='4') {
      return 4;
    } else if (key=='5') {
      return 5;
    } else if (key=='6') {
      return 6;
    } else if (key=='7') {
      return 7;
    } else if (key=='8') {
      return 8;
    } else if (key=='9') {
      return 9;
    } else if (key=='a') {
      return 10;
    } else if (key=='b') {
      return 11;
    } else if (key=='c') {
      return 12;
    } else if (key=='d') {
      return 13;
    } else if (key=='e') {
      return 14;
    } else if (key=='f') {
      return 15;
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}
boolean isPointerExists(int node, int multiMapindex) {
  if (LedPointer[node-1][multiMapindex-1]==-1) {
    return false;
  } else {
    return true;
  }
}
void CreatePointer(int node, int multiMapindex) {
  int a=0;
  int b;
  byte[] cnt=new byte[MAX_LEDNODES];
  while (a<MAX_NODES*MAX_CHAIN) {
    b=0;
    while (b<MAX_MULTI) {
      if (LedPointer[a][b]<0) {//==-1
      } else {
        cnt[LedPointer[a][b]]=1;
      }
      b=b+1;
    }
    a=a+1;
  }
  a=0;
  while (a<MAX_LEDNODES) {
    if (!(cnt[a]==1)) {
      break;
    }
    a=a+1;
  }
  if (a==MAX_LEDNODES) {
    println("cant create pointer");
  } else {
    NofLedPointer+=1;
  }
  LedPointer[node-1][multiMapindex-1]=a;
  println("new pointer for node="+node+" multi="+multiMapindex+" is "+a);
}
void ErasePointer(int node, int multiMapindex) {
  int a=0;
  int b;
  int ledp=LedPointer[node-1][multiMapindex-1];
  while (a<MAX_LEDFRAME) {
    b=0;
    while (b<MAX_NODES) {
      L[a][b][ledp]=-1;
      Color[a][b][ledp]=-1;
      b=b+1;
    }
    a=a+1;
  }
  LedPointer[node-1][multiMapindex-1]=-1;
}
//System=============================================================================================================================================================================================================================================
void LoadKeyMap() {//none=0
  //main menu
  keyMap_Action[0]=CONTROL;//New Project
  keyMap[0]='n';
  keyMap_Action[1]=CONTROL;//Open Project
  keyMap[1]='o';
  keyMap_Action[2]=CONTROL;//Save Project
  keyMap[2]='s';
  keyMap_Action[3]=0;
  keyMap[3]='0';
  keyMap_Action[4]=CONTROL;//Import Project
  keyMap[4]='i';
  keyMap_Action[5]=CONTROL;//Export Project
  keyMap[5]='e';
  keyMap_Action[6]=ALT;//Compress Project to .uni
  keyMap[6]='e';
  keyMap_Action[7]=CONTROL;//Project Settings
  keyMap[7]='9';
  keyMap_Action[8]=CONTROL;//Settings
  keyMap[8]='0';
  keyMap_Action[9]=CONTROL;//Open Naver cafe
  keyMap[9]='w';
  keyMap_Action[10]=CONTROL;//Help
  keyMap[10]='h';
  //inside_settings
  keyMap_Action[11]=CONTROL;//Language
  keyMap[11]='l';
  keyMap_Action[12]=CONTROL;//Keyboard shortcuts
  keyMap[12]='8';
  keyMap_Action[13]=CONTROL;//Set Save Route 
  keyMap[2]='r';
  keyMap_Action[14]=ALT;//Configure Constants and Reload
  keyMap[14]='r';
  //edit
  keyMap_Action[15]=CONTROL;//copy
  keyMap[15]='c';
  keyMap_Action[16]=CONTROL;//paste
  keyMap[16]='v';
  keyMap_Action[17]=CONTROL;//cut
  keyMap[17]='x';
  keyMap_Action[18]=CONTROL;//undo
  keyMap[18]='z';
  keyMap_Action[19]=CONTROL;//redo
  keyMap[19]='y';
  keyMap_Action[20]=CONTROL;//Select All
  keyMap[20]='a';
  keyMap_Action[21]=SHIFT;//Lasso Select Key
  keyMap[21]=0;//Fixed
  //run
  keyMap_Action[22]=CONTROL;//play led sequence
  keyMap[22]='p';
  keyMap_Action[23]=ALT;//open file tab
  keyMap[23]='7';
  /*
  keyMap_Action[24]=CONTROL;//
   keyMap[24]=
   keyMap_Action[25]=CONTROL;//
   keyMap[25]=
   keyMap_Action[26]=CONTROL;//
   keyMap[26]=
   keyMap_Action[27]=CONTROL;//
   keyMap[27]=
   */
}
void LoadLInfo() {
  Read=createReader("/data/settings/Llist");
  int a=0;
  while (a<128) {
    try {
      Llist[a]=unhex(Read.readLine());
      print(str(Llist[a])+" ");
    }
    catch(Exception e) {
      println("Load failed");
    }
    a=a+1;
  }
}
//===================================================================================================================================================================================================================================================================
//File I/O
void LoadInfo() {
  File file=new File(dataPath("")+"/projects/");
  File Efile=new File(dataPath("")+"/export/");
  try {
    if (file.isDirectory()) {
      Paths=file.list();
    }
    if (Efile.isDirectory()) {
      EPaths=Efile.list();
    }
  }
  catch(Exception e) {
    println("error in load info");
  }
}
//Load===============================================================================================================================================================================================================================================================
void LoadProject(String title) {
  Read=createReader("/data/projects/"+title+"/"+title+".une");
  String Verify;
  String DataType=null;
  int F;
  int S;
  int T;
  int Val;
  String SVal;
  ReSetup();
  try {
    Verify=Read.readLine();
    if (Verify.equals("ThisIsEX867EditorFile")) {
      Title=Read.readLine();
      ProducerName=Read.readLine();
      Width=Integer.parseInt(Read.readLine());
      Height=Integer.parseInt(Read.readLine());
      NofChains=Integer.parseInt(Read.readLine());
      if (Read.readLine().equals("true")) {
        SquareButtons=true;
      } else {
        SquareButtons=false;
      }
      if (Read.readLine().equals("true")) {
        Landscape=true;
      } else {
        Landscape=false;
      }
      println(Title+"  "+ProducerName+"  "+Width+"  "+Height+"  "+NofChains+"  "+Landscape);
      while (true) {
        DataType=Read.readLine();
        if (DataType.equals("NofMultiMap")) {
          F=Integer.parseInt(Read.readLine());
          Val=Integer.parseInt(Read.readLine());
          NofMultiMap[F]=Val;
          println(DataType+" "+F+" "+Val);
        } else if (DataType.equals("Filenames")) {
          F=Integer.parseInt(Read.readLine());
          S=Integer.parseInt(Read.readLine());
          SVal=Read.readLine();
          Filenames[F][S]=SVal;
          println(DataType+" "+F+" "+S+" "+SVal);
        } else if (DataType.equals("Loops")) {
          F=Integer.parseInt(Read.readLine());
          S=Integer.parseInt(Read.readLine());
          Val=Integer.parseInt(Read.readLine());
          Loops[F][S]=(short)Val;
          println(DataType+" "+F+" "+S+" "+Val);
        } else if (DataType.equals("NofLedFrame")) {
          F=Integer.parseInt(Read.readLine());
          S=Integer.parseInt(Read.readLine());
          Val=Integer.parseInt(Read.readLine());
          NofLedFrame[F][S]=Val;
          println(DataType+" "+F+" "+S+" "+Val);
        } else if (DataType.equals("LedLoops")) {
          F=Integer.parseInt(Read.readLine());
          S=Integer.parseInt(Read.readLine());
          Val=Integer.parseInt(Read.readLine());
          LedLoops[F][S]=Val;
          println(DataType+" "+F+" "+S+" "+Val);
        } else if (DataType.equals("Delays")) {
          F=Integer.parseInt(Read.readLine());
          S=Integer.parseInt(Read.readLine());
          T=Integer.parseInt(Read.readLine());
          Val=Integer.parseInt(Read.readLine());
          Delays[F][S][T]=Val;
          println(DataType+" "+F+" "+S+" "+T+" "+Val);
        } else if (DataType.equals("Color")) {
          F=Integer.parseInt(Read.readLine());
          S=Integer.parseInt(Read.readLine());
          T=Integer.parseInt(Read.readLine());
          Val=Integer.parseInt(Read.readLine());
          Color[F][S][T]=Val;
          println(DataType+" "+F+" "+S+" "+T+" "+Val);
        } else if (DataType.equals("L")) {
          F=Integer.parseInt(Read.readLine());
          S=Integer.parseInt(Read.readLine());
          T=Integer.parseInt(Read.readLine());
          Val=Integer.parseInt(Read.readLine());
          L[F][S][T]=(short)Val;
          println(DataType+" "+F+" "+S+" "+T+" "+Val);
        } else if (DataType.equals("LedPointer")) {
          F=Integer.parseInt(Read.readLine());
          S=Integer.parseInt(Read.readLine());
          Val=Integer.parseInt(Read.readLine());
          LedPointer[F][S]=Val;
          println(DataType+" "+F+" "+S+" "+Val);
        } else if (DataType.equals("EndofFile")) {
          println("end");
          break;
        } else {
          println("error in loading file");
          break;
        }
      }
    } else {
      println("error this is not une file "+Verify);
    }

    Read.close();
  }
  catch(Exception e) {
    fill(255);
    rect(100, 100, ScreenWidth-300, ScreenHeight-200);
    fill(0);
    text("Error:"+e.toString(), 130, 160);
  }
  sR=true;
}
//Save================================================================================================================================================================================================================================================================
void SaveProject(String title) {
  File file=new File("/data/projects/"+title+"/"+title+".une");
  PrintWriter Write;
  file.delete();
  /*if (file.isFile()) {
   println("file exists and Overwrite");
   file.delete();
   }*/
  println("save on "+file.getAbsolutePath());
  Write=createWriter(file.getPath());
  LoadInfo();
  String DataType=null;
  int F;
  int S;
  int T;
  int Val;
  String SVal;
  try {
    Write.write("ThisIsEX867EditorFile\n");
    Write.write(Title+"\n");
    Write.write(ProducerName+"\n");
    Write.write(Width+"\n");
    Write.write(Height+"\n");
    Write.write(NofChains+"\n");
    Write.write(str(SquareButtons)+"\n");
    Write.write(str(Landscape)+"\n");
    Write.flush();
    DataType="NofMultiMap";
    F=0;
    while (F<MAX_NODES*MAX_CHAIN) {
      Val=NofMultiMap[F];
      if (Val==1) {
      } else {
        Write.write(DataType+"\n");
        Write.write(F+"\n");
        Write.write(Val+"\n");
      }
      F=F+1;
    }
    Write.flush();

    DataType="Filenames";
    F=0;
    while (F<MAX_NODES*MAX_CHAIN) {
      S=0;
      while (S<MAX_MULTI) {
        SVal=Filenames[F][S];
        if (SVal==null || SVal=="" ) {
        } else {
          Write.write(DataType+"\n");
          Write.write(F+"\n");
          Write.write(S+"\n");
          Write.write(SVal+"\n");
        }
        S=S+1;
      }
      F=F+1;
    }
    Write.flush();

    DataType="Loops";
    F=0;
    while (F<MAX_NODES*MAX_CHAIN) {
      S=0;
      while (S<MAX_MULTI) {
        Val=Loops[F][S];
        if (Val==1) {
        } else {
          Write.write(DataType+"\n");
          Write.write(F+"\n");
          Write.write(S+"\n");
          Write.write(Val+"\n");
        }
        S=S+1;
      }
      F=F+1;
    }
    Write.flush();

    DataType="NofLedFrame";
    F=0;
    while (F<MAX_NODES*MAX_CHAIN) {
      S=0;
      while (S<MAX_MULTI) {
        Val=NofLedFrame[F][S];
        if (Val==0) {
        } else {
          Write.write(DataType+"\n");
          Write.write(F+"\n");
          Write.write(S+"\n");
          Write.write(Val+"\n");
        }
        S=S+1;
      }
      F=F+1;
    }
    Write.flush();

    DataType="LedLoops";
    F=0;
    while (F<MAX_NODES*MAX_CHAIN) {
      S=0;
      while (S<MAX_MULTI) {
        Val=LedLoops[F][S];
        if (Val==0) {
        } else {
          Write.write(DataType+"\n");
          Write.write(F+"\n");
          Write.write(S+"\n");
          Write.write(Val+"\n");
        }
        S=S+1;
      }
      F=F+1;
    }
    Write.flush();
    DataType="Delays";
    F=0;
    while (F<MAX_NODES*MAX_CHAIN) {
      S=0;
      while (S<MAX_MULTI) {
        T=0;
        while (T<MAX_LEDFRAME) {
          Val=Delays[F][S][T];
          if (Val==0) {
          } else {
            Write.write(DataType+"\n");
            Write.write(F+"\n");
            Write.write(S+"\n");
            Write.write(T+"\n");
            Write.write(Val+"\n");
          }
          T=T+1;
        }
        S=S+1;
      }
      F=F+1;
    }
    Write.flush();

    DataType="Color";
    F=0;
    while (F<MAX_LEDFRAME) {
      S=0;
      while (S<MAX_NODES) {
        T=0;
        while (T<MAX_LEDNODES) {
          Val=Color[F][S][T];
          if (Val==-1) {
          } else {
            Write.write(DataType+"\n");
            Write.write(F+"\n");
            Write.write(S+"\n");
            Write.write(T+"\n");
            Write.write(Val+"\n");
          }
          T=T+1;
        }
        S=S+1;
      }
      F=F+1;
    }
    Write.flush();

    DataType="L";
    F=0;
    while (F<MAX_LEDFRAME) {
      S=0;
      while (S<MAX_NODES) {
        T=0;
        while (T<MAX_LEDNODES) {
          Val=L[F][S][T];
          if (Val==-1) {
          } else {
            Write.write(DataType+"\n");
            Write.write(F+"\n");
            Write.write(S+"\n");
            Write.write(T+"\n");
            Write.write(Val+"\n");
          }
          T=T+1;
        }
        S=S+1;
      }
      F=F+1;
    }
    Write.flush();

    DataType="LedPointer";
    F=0;
    while (F<MAX_NODES*MAX_CHAIN) {
      S=0;
      while (S<MAX_MULTI) {
        Val=LedPointer[F][S];
        if (Val==-1) {
        } else {
          Write.write(DataType+"\n");
          Write.write(F+"\n");
          Write.write(S+"\n");
          Write.write(Val+"\n");
        }
        S=S+1;
      }
      F=F+1;
    }
    Write.flush();
    Write.write("EndofFile");
    Write.flush();
    Read.close();
  }
  catch(Exception e) {
    fill(255);
    rect(100, 100, ScreenWidth-300, ScreenHeight-200);
    fill(0);
    text("Error:"+e.toString(), 130, 160);
  }
}
void Export() {
  SaveProject(Title);
  int a, b, c, d;
  String f;
  File file;
  PrintWriter Info;
  PrintWriter KeySound;
  //info===
  file=new File("/data/export/"+Title+"/info");
  if (file.delete()==true) {
  }
  try {
    file.createNewFile();
  }
  catch(Exception e) {
  }
  try {
    Info=createWriter(file.getPath());
    Info.write("title="+Title+"\n");
    Info.write("producerName="+ProducerName+"\n");
    Info.write("buttonX="+Width+"\n");
    Info.write("buttonY="+Height+"\n");
    Info.write("chain="+NofChains+"\n");
    Info.write("squareButtons="+str(SquareButtons)+"\n");
    Info.write("landscape="+str(Landscape));
    Info.flush();
    Info.close();
  }
  catch(Exception e) {
    println("error on export1");
  }
  //KeySound
  file=new File("/data/export/"+Title+"/keySound");
  if (file.delete()==true) {
  }
  try {
    file.createNewFile();
  }
  catch(Exception e) {
  }
  try {
    KeySound=createWriter(file.getPath());
    a=0;
    while (a<MAX_NODES*MAX_CHAIN) {
      b=0;
      while (b<MAX_MULTI) {
        if (!(Filenames[a][b]=="" ||Filenames[a][b]==null)) {
          KeySound.write(str(a/(Width*Height)+1)+" "+str((a%(Width*Height))%Height+1)+" "+str((a%(Width*Height))/Height+1)+" "+Filenames[a][b]);
          println(str(a/(Width*Height)+1)+" "+str((a%(Width*Height))%Height+1)+" "+str((a%(Width*Height))/Height+1)+" "+Filenames[a][b]);
          if (!(Loops[a][b]==1)) {
            KeySound.write(" "+Loops[a][b]);
          }
          KeySound.write("\n");
          KeySound.flush();
        }
        b=b+1;
      }
      a=a+1;
    }
    KeySound.close();
  }
  catch(Exception e) {
    println("error on expor2t");
  }
  //KeyLED
  c=0;
  while (c<MAX_NODES*MAX_CHAIN) {
    d=0;
    while (d<MAX_MULTI) {
      if (!(NofLedFrame[c][d]==0)) {
        PrintWriter KeyLED;
        file=new File("/data/export/"+Title+"/keyLED/"+str(c/(Width*Height)+1)+" "+str((c%(Width*Height))%Height+1)+" "+str((c%(Width*Height))/Height+1)+" "+LedLoops[c][d]+" "+NtoA(d));
        if (file.delete()==true) {
        }
        try {
          file.createNewFile();
        }
        catch(Exception e) {
        }
        KeyLED=createWriter(file.getPath());
        /*try {*/
        a=0;
        while (a<NofLedFrame[c][d]) {
          if (a==0) {
            b=0;
            while (b<MAX_NODES) {
              if (!(LedPointer[c][d]==-1)) {
                if (!(Color[a][b][LedPointer[c][d]]==-1)&&!(L[a][b][LedPointer[c][d]]==-1)) {
                  KeyLED.write("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+hex(Color[a][b][LedPointer[c][d]], 6)+" "+str(L[a][b][LedPointer[c][d]]));
                  KeyLED.write("\n");
                  println("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+hex(Color[a][b][LedPointer[c][d]], 6)+" "+str(L[a][b][LedPointer[c][d]]));
                } else if (!(Color[a][b][LedPointer[c][d]]==-1)) {
                  KeyLED.write("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+hex(Color[a][b][LedPointer[c][d]], 6));
                  KeyLED.write("\n");
                  println("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+hex(Color[a][b][LedPointer[c][d]], 6));
                } else if (!(L[a][b][LedPointer[c][d]]==-1)) {
                  KeyLED.write("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+str(L[a][b][LedPointer[c][d]]));
                  KeyLED.write("\n");
                  println("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+str(L[a][b][LedPointer[c][d]]));
                } else {
                }
                KeyLED.flush();
              }
              b=b+1;
            }
          } else if (a>0) {
            b=0;
            while (b<MAX_NODES) {
              if (!(LedPointer[c][d]==-1)) {
                if (!((Color[a][b][LedPointer[c][d]]==Color[a-1][b][LedPointer[c][d]])&&(L[a][b][LedPointer[c][d]]==L[a-1][b][LedPointer[c][d]]))&&!(Color[a-1][b][LedPointer[c][d]]==-1&&L[a-1][b][LedPointer[c][d]]==-1)) {
                  KeyLED.write("off "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+"\n");
                  println("off "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1));
                }
                if (!(Color[a][b][LedPointer[c][d]]==-1)&&!(L[a][b][LedPointer[c][d]]==-1)) {
                  KeyLED.write("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+hex(Color[a][b][LedPointer[c][d]], 6)+" "+str(L[a][b][LedPointer[c][d]]));
                  KeyLED.write("\n");
                  println("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+hex(Color[a][b][LedPointer[c][d]], 6)+" "+str(L[a][b][LedPointer[c][d]]));
                } else if (!(Color[a][b][LedPointer[c][d]]==-1)) {
                  f=hex(Color[a][b][LedPointer[c][d]]);
                  while (f.length()<6) {
                    f="0"+f;
                  }
                  KeyLED.write("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+hex(Color[a][b][LedPointer[c][d]], 6));
                  KeyLED.write("\n");
                  println("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+hex(Color[a][b][LedPointer[c][d]], 6));
                } else if (!(L[a][b][LedPointer[c][d]]==-1)) {
                  KeyLED.write("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+str(L[a][b][LedPointer[c][d]]));
                  KeyLED.write("\n");
                  println("on "+str((b%(Width*Height))%Height+1)+" "+str((b%(Width*Height))/Height+1)+" "+str(L[a][b][LedPointer[c][d]]));
                } else {
                }
                KeyLED.flush();
              }
              b=b+1;
            }
          }
          KeyLED.write("delay "+Delays[c][d][a]+"\n");
          a=a+1;
        }
        /*}
         catch(Exception e) {
         println("error on expor3t");
         }*/
        KeyLED.close();
      }
      d=d+1;
    }
    c=c+1;
  }
}
String NtoA(int n) {//parameters is from 0.
  if (n==0) {
    return "a";
  } else if (n==1) {
    return "b";
  } else if (n==2) {
    return "c";
  } else if (n==3) {
    return "d";
  } else if (n==4) {
    return "e";
  } else if (n==5) {
    return "f";
  } else if (n==6) {
    return "g";
  } else if (n==7) {
    return "h";
  } else if (n==8) {
    return "i";
  } else if (n==9) {
    return "j";
  } else if (n==10) {
    return "k";
  } else if (n==11) {
    return "l";
  } else if (n==12) {
    return "n";
  } else if (n==13) {
    return "m";
  } else if (n==14) {
    return "o";
  } else if (n==15) {
    return "p";
  } else if (n==16) {
    return "q";
  } else if (n==17) {
    return "r";
  } else if (n==18) {
    return "s";
  } else if (n==19) {
    return "t";
  } else {
    return "";
  }
}
void Encode(String s) {
  byte[] BOM = new byte[4];
  BOM = s.getBytes();

  if ( (BOM[0] & 0xFF) == 0xEF && (BOM[1] & 0xFF) == 0xBB && (BOM[2] & 0xFF) == 0xBF )
    println("UTF-8");
  else if ( (BOM[0] & 0xFF) == 0xFE && (BOM[1] & 0xFF) == 0xFF )
    println("UTF-16BE");
  else if ( (BOM[0] & 0xFF) == 0xFF && (BOM[1] & 0xFF) == 0xFE )
    println("UTF-16LE");
  else if ( (BOM[0] & 0xFF) == 0x00 && (BOM[1] & 0xFF) == 0x00 && 
    (BOM[0] & 0xFF) == 0xFE && (BOM[1] & 0xFF) == 0xFF )
    println("UTF-32BE");
  else if ( (BOM[0] & 0xFF) == 0xFF && (BOM[1] & 0xFF) == 0xFE && 
    (BOM[0] & 0xFF) == 0x00 && (BOM[1] & 0xFF) == 0x00 )
    println("UTF-32LE");
  else
    println("EUC-KR");
}