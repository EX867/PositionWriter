//constants
int PADSIZE;
int RGB_HEIGHT;
int PLAYER_HEIGHT;
int LOG_HEIGHT;
int VELOCITY_HEIGHT;
int COLOR_HEIGHT;
int KEY_HEIGHT;
void initConstant1 () {
  PADSIZE=floor(560*displayD);
  RGB_HEIGHT=floor (50*displayD);
  PLAYER_HEIGHT=floor (80*displayD);
  LOG_HEIGHT=floor (40*displayD);
  VELOCITY_HEIGHT=floor (80*displayD);
  COLOR_HEIGHT=((Screen_Width-PADSIZE)/2*3+VELOCITY_HEIGHT);
  KEY_HEIGHT=floor (480*displayD*Screen_Width_FULL/Screen_Width);
  initKeyConstants ();
}


//constants
final int KEYBOARD=0;
final int UNDO=1;
final int REDO=2;
final int EXPORT=3;
final int PAD=4;
final int COLOR=5;//x6
final int ON=11;
final int OFF=12;
final int DELAY=13;
final int AUTO=14;
final int PLAYER=15;
final int ENTERKEY=16;
final int BACKSPACEKEY=17;
final int VELOCITY=18;
final int KEYBOARD2=19;
final int KEYBOARD3=20;
final int LEFT=21;
final int DOWN=22;
final int RIGHT=23;
final int UP=24;
final int TEXTMODE=25;
final int COPY=26;
final int PASTE=27;
final int CLEAR=28;

int[] btnInit;
String [] btnText;
int [] btnLayout;
void initButton () {
  btnInit=new int [] {
    0, PADSIZE+3*RGB_HEIGHT+PLAYER_HEIGHT, Screen_Width, Screen_Height-PADSIZE-3*RGB_HEIGHT-PLAYER_HEIGHT-LOG_HEIGHT, //keyboard//bottom
    PADSIZE+10, 10+3*((Screen_Width-PADSIZE)/2)+COLOR_HEIGHT, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //unde//row 3
    PADSIZE+(Screen_Width-PADSIZE)/2+10, 10+3*(Screen_Width-PADSIZE)/2+COLOR_HEIGHT, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //redo//row 3
    PADSIZE+10, 10, ((Screen_Width-PADSIZE)/2)-20, (Screen_Width-PADSIZE)/2-20, //export//row 0
    0, 0, PADSIZE, PADSIZE, //pad
    PADSIZE+10, 10+((Screen_Width-PADSIZE)/2), (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //color1
    PADSIZE+(Screen_Width-PADSIZE)/2+10, 10+(Screen_Width-PADSIZE)/2, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //color2
    PADSIZE+10, 10+2*((Screen_Width-PADSIZE)/2), (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //color3
    PADSIZE+(Screen_Width-PADSIZE)/2+10, 10+2*(Screen_Width-PADSIZE)/2, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //color4
    PADSIZE+10, 10+3*((Screen_Width-PADSIZE)/2), (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //color5
    PADSIZE+(Screen_Width-PADSIZE)/2+10, 10+3*(Screen_Width-PADSIZE)/2, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //color6
    PADSIZE+10, 10+((Screen_Width-PADSIZE)/2)+COLOR_HEIGHT, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //on//row 1
    PADSIZE+(Screen_Width-PADSIZE)/2+10, 10+(Screen_Width-PADSIZE)/2+COLOR_HEIGHT, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //off//row 1
    PADSIZE+10, 10+2*((Screen_Width-PADSIZE)/2)+COLOR_HEIGHT, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //delay//row 2
    PADSIZE+(Screen_Width-PADSIZE)/2+10, 10+2*((Screen_Width-PADSIZE)/2)+COLOR_HEIGHT, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //auto//row 2
    PADSIZE+(Screen_Width-PADSIZE)/2+10, 10, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //player//row 0
    PADSIZE+10, 10+4*((Screen_Width-PADSIZE)/2)+COLOR_HEIGHT, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //enter//row 4
    PADSIZE+(Screen_Width-PADSIZE)/2+10, 10+4*(Screen_Width-PADSIZE)/2+COLOR_HEIGHT, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //backspace//row 4
    PADSIZE, 4*((Screen_Width-PADSIZE)/2), Screen_Width-PADSIZE, (Screen_Width-PADSIZE)/2, 
    //layout 2
    10, Screen_Height-KEY_HEIGHT-((Screen_Width-PADSIZE)/2)-10, ((Screen_Width-PADSIZE)/2)-20, (Screen_Width-PADSIZE)/2-20, //keyboard
    (Screen_Width-PADSIZE)/2+10, Screen_Height-KEY_HEIGHT-((Screen_Width-PADSIZE)/2)-10, ((Screen_Width-PADSIZE)/2)-20, (Screen_Width-PADSIZE)/2-20, //

    PADSIZE-(Screen_Width-PADSIZE)/2+1, Screen_Height-KEY_HEIGHT-(Screen_Width-PADSIZE)/2+1, ((Screen_Width-PADSIZE)/2)-2, (Screen_Width-PADSIZE)/2-2, //left
    PADSIZE+1, Screen_Height-KEY_HEIGHT-(Screen_Width-PADSIZE)/2+1, ((Screen_Width-PADSIZE)/2)-2, (Screen_Width-PADSIZE)/2-2, //down
    PADSIZE+(Screen_Width-PADSIZE)/2+1, Screen_Height-KEY_HEIGHT-(Screen_Width-PADSIZE)/2, ((Screen_Width-PADSIZE)/2)-2, (Screen_Width-PADSIZE)/2-2, //right
    PADSIZE+1, Screen_Height-KEY_HEIGHT-(Screen_Width-PADSIZE)+1, ((Screen_Width-PADSIZE)/2)-2, (Screen_Width-PADSIZE)/2-2, //up

    10, PADSIZE+3*RGB_HEIGHT+10, ((Screen_Width-PADSIZE)/2)-20, (Screen_Width-PADSIZE)/2-20, //keyboard
    
    PADSIZE+10, 10, ((Screen_Width-PADSIZE)/2)-20, (Screen_Width-PADSIZE)/2-20, //copy
    PADSIZE+(Screen_Width-PADSIZE)/2+10, 10, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //paste
    PADSIZE-(Screen_Width-PADSIZE)/2+10, 10, (Screen_Width-PADSIZE)/2-20, (Screen_Width-PADSIZE)/2-20, //clear
  };
  btnText=new String [] {
    "", "UNDO", "REDO", "EXPORT", "", "", "", "", "", "", "", "ON", "OFF", "DELAY", "AUTO", ">>", "\\n", "<", "", "KEY", "", "<-", "v", "->", "^", "KEY","COPY ALL","PASTE","CLEAR",
  };
  btnLayout=new int [] {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1,2,2,2,
  };
}

void resetType() {
  int a=0;
  while (a<30) {
    keyType[a]=false;
    a=a+1;
  }
  a=0;
  while (a <keyboardButtons) {
    keyboardType[a]=false;
    a=a+1;
  }
}
void buttonRelease() {
  if (btns [PAD].isTouched ()==false&&keyType[PAD]==true) {
    LogFull=display.getText();
    Log=str(Y+1)+" "+str(X+1);
    if (DEBUG)println(Log);
    LogFull=LogFull+" "+Log;
    tR=true;
    RecordLog();
    display.setText(LogFull);
    sR=true;
    keyType [PAD]=false;
  }
  if (velOpened ==false){
  if (btns[TEXTMODE].isTouched()==false&&keyType[TEXTMODE]==true) {//=====
    LayoutMode=false;
    LogFull=display.getText();
    RecordLog();
    if (DEBUG)println("tfame get focus");
    keyType[TEXTMODE]=false;
    resetType();
  }
  if (btns [KEYBOARD2].isTouched()==false &&keyType [KEYBOARD2]==true&&display.scrollMode==0) {
    LayoutMode=true;
    LogFull=display.getText();
    RecordLog();
    if (DEBUG)println("tframe lost focus");
    tR=true;
    sR=true;
    keyType [KEYBOARD2]=false;
  }
  if (btns [KEYBOARD3].isTouched()==false &&keyType[KEYBOARD3]==true&&display.scrollMode==0) {
    if (keyboardOn==true) {
      keyboardOn=false;
    } else {
      keyboardOn=true;
    }
    keyType [KEYBOARD3]=false;
  }
  if (btns [COPY].isTouched()==false&&keyType [COPY]==true&&display.scrollMode==0){
    ClipboardCopy (display.getText());
    keyType [COPY]=false;
  }
  if (btns [PASTE].isTouched ()==false&&keyType [PASTE]==true&&display.scrollMode==0){
          String pasteString=ClipboardPaste();
          if (display.Cursur >0) {
            display.setText (display.getText().substring (0, display.Cursur)+(pasteString)+display.getText().substring (display.Cursur, display.getText().length ()));
          } else {
            display.setText((pasteString)+display.getText().substring (display.Cursur, display.getText().length ()));
          }
    keyType [PASTE]=false;
  }
  if (btns [CLEAR].isTouched()==false&&keyType [CLEAR]==true&&display.scrollMode==0){
    if (mousePressed==false){
      Log="reset";
      RecordLog();
      tR=true;
      sR=true;
      display.setText("//===EX867_PositionWriter_mobile===//");
      
    }
    keyType [CLEAR]=false;
  }
    if (keyboardOn) {
    keyboardRelease();
  }
  }
}
void buttonPress () {
  int a;
  if (LayoutMode) {
    if (colorPress==0 &&velOpened==false) {//cond
      if (btns[TEXTMODE].isTouched()&&keyType[TEXTMODE]==false) {//=====
        keyType[TEXTMODE]=true;
      }
    }
    if (colorPress==0) {//cond
      if (btns[UNDO].isTouched ()&&keyType[UNDO]==false) {//=====
        if (DEBUG) println("undo");
        if (UndoIndex<MAX_UNDO-1&& UndoMax>UndoIndex) {
          UndoIndex=UndoIndex+=1;
          LogFull=Undo[UndoIndex];
          display.setText(LogFull);
          readFrame();
        } else {
          Log="can't undo";
        }
        keyType[UNDO]=true;
      }
      if (btns[REDO].isTouched()&&keyType[REDO]==false) {//=====
        if (DEBUG)println("redo");
        if (UndoIndex>0) {
          UndoIndex=UndoIndex-1;
          LogFull=Undo[UndoIndex];
          display.setText(LogFull);
          readFrame();
        } else {
          Log="can't redo";
        }
        keyType[REDO]=true;
      }
      if (btns[EXPORT].isTouched()&&keyType[EXPORT]==false) {//=====
        Log=("exporting...");
        try {
          export ();
        }
        catch(Exception e) {
          Log="error on exporting : "+e.toString();
        }
        keyType[EXPORT]=true;
      }
      if (btns[PAD].isTouched()) {
        for (int i=0; i < maxTouchEvents; i++) {//=====
          if (mt[i].touched == true) {
            if ((btns[PAD].x<mt [i].motionX)&&(mt [i].motionX<(btns[PAD].x+btns[PAD].w))&&(btns[PAD].y<mt [i].motionY)&&(mt [i].motionY <(btns[PAD].y+btns[PAD].h))) {
              X=floor(mt[i].motionX/(PADSIZE/8));
              Y=floor(mt[i].motionY/(PADSIZE/8));
              break;
            }
          }
        }
        Log=str(Y+1)+" "+str(X+1);
        if (DEBUG)println (Log);
        fill(0, 50);
        rect(X*(PADSIZE/8), 0, (PADSIZE/8), PADSIZE);
        rect (0, Y*(PADSIZE/8), PADSIZE, (PADSIZE/8));
        keyType[PAD]=true;
      }
      a=0;
      while (a<6) {
        if (btns [COLOR+a].isTouched()&&keyType[COLOR+a]==false) {//=====
          fill(165);
          rect(btns[COLOR+a].x, btns[COLOR+a].y, btns[COLOR+a].w, btns[COLOR+a].h);
          LogFull=display.getText();
          Log=hex((recentColor[a]>>16)&0xFF, 2)+hex((recentColor[a]>>8)&0xFF, 2)+hex((recentColor[a]&0xFF), 2);
          if (DEBUG)println(Log);
          LogFull=LogFull+" "+Log;
          tR=true;
          RecordLog();
          display.setText(LogFull);
          if (a==0) {
            if (DEBUG)println("^recent color updated");
            int c=5;
            while (c>0) {
              recentColor[c]=recentColor[c-1];
              btns [COLOR+c].colorEnabled=recentColor [c];
              c=c-1;
            }
          }
          keyType[COLOR+a]=true;
        }
        a=a+1;
      }
      if (btns[ON].isTouched()&&keyType[ON]==false) {
        if(DEBUG)print ("ON ");
        LogFull=display.getText();
        Log="on";
        LogFull=LogFull+"\n"+Log;
        tR=true;
        RecordLog();
        display.setText(LogFull);
        keyType[ON]=true;
      }
      if (btns[OFF].isTouched()&&keyType[OFF]==false) {
        if(DEBUG)print ("OFF ");
        LogFull=display.getText();
        Log="off";
        LogFull=LogFull+"\n"+Log;
        tR=true;
        RecordLog();
        display.setText(LogFull);
        keyType[OFF]=true;
      }
      if (btns[DELAY].isTouched()&&keyType[DELAY]==false) {
        if(DEBUG)print ("DELAY ");
        LogFull=display.getText();
        Log="delay";
        LogFull=LogFull+"\n"+Log;
        tR=true;
        RecordLog();
        display.setText(LogFull);
        keyType[DELAY]=true;
      }
      if (btns[AUTO].isTouched()&&keyType[AUTO]==false) {
        if(DEBUG)print ("AUTO ");
        LogFull=display.getText();
        Log="auto";
        LogFull=LogFull+" "+Log;
        tR=true;
        RecordLog();
        display.setText(LogFull);
        keyType[AUTO]=true;
      }
      if (btns[PLAYER].isTouched()&&keyType[PLAYER]==false) {
        keyType[PLAYER]=true;
      }
      if (btns[ENTERKEY].isTouched ()&&keyType [ENTERKEY]==false) {
        if(DEBUG)print ("ENTER ");
        LogFull=display.getText();
        Log="ENTER";
        LogFull=LogFull+"\n";
        //tR=true;
        RecordLog();
        display.setText(LogFull);
        keyType [ENTERKEY]=true;
      }
      if (btns [BACKSPACEKEY].isTouched ()&&keyType [BACKSPACEKEY]==false) {
        if(DEBUG)print ("BACKSPACE ");
        LogFull=display.getText();
        Log="backspace";
        LogFull=LogFull.substring (0, LogFull.length ()-1);
        tR=true;
        RecordLog();
        display.setText(LogFull);
        keyType [BACKSPACEKEY]=true;
      }
      if (btns [VELOCITY].isTouched()&&keyType [VELOCITY]==false) {
        if (velOpened) {
          velOpened=false;
        } else {
          velOpened=true;
        }
        sR=true;
        keyType [VELOCITY]=true;
      }
    }
  } else {
    if (btns [KEYBOARD2].isTouched ()&&keyType [KEYBOARD2]==false) {
      keyType [KEYBOARD2]=true;
    }
    if (btns [LEFT].isTouched ()&&keyType [LEFT]==false) {
      if (display.Cursur>0) {
        display.Cursur=display.Cursur-1;
      }
      keyType [LEFT]=true;
    }
    if (btns [DOWN].isTouched ()&&keyType [DOWN]==false) {
      display.Cursur=display.Cursur+display.Cursurdown;
      if (display.Cursur>display.getText().length()) {
        display.Cursur=display.getText().length ();
      }
      keyType [DOWN]=true;
    }
    if (btns [RIGHT].isTouched ()&&keyType [RIGHT]==false) {
      if (display.Cursur<display.getText().length ()) {
        display.Cursur=display.Cursur+1;
      }
      keyType [RIGHT]=true;
    }
    if (btns [UP].isTouched ()&&keyType [UP]==false) {
      display.Cursur=display.Cursur-display.Cursurup;
      if (display.Cursur<0) {
        display.Cursur=0;
      }
      keyType [UP]=true;
    }
    if (btns [KEYBOARD3].isTouched()&&keyType [KEYBOARD3]==false) {
      keyType [KEYBOARD3]=true;
    }
    if(btns [COPY].isTouched ()&&keyType [COPY]==false){
      keyType [COPY]=true;
    }
    if (btns [PASTE].isTouched ()&&keyType [PASTE]==false){
      keyType [PASTE]=true;
    }
    if (btns [CLEAR].isTouched ()&&keyType [CLEAR]==false){
      keyType[CLEAR]=true;
    }
    if (keyboardOn) {
      keyboardButtons ();
    }
  }
}





color [] k=new color[] {
  #000000, 
  #bdbdbd, 
  #eeeeee, 
  #fafafa, //3
  #f8bbd0, 
  #ef5350, //5
  #e57373, 
  #ef9a9a, 

  #fff3e0, 
  #ffa726, 
  #ffb960, //10
  #ffcc80, 
  #ffe0b2, 
  #ffee58, 
  #fff59d, 
  #fff9c4, 

  #dcedc8, 
  #8bc34a, //17
  #aed581, 
  #bfdf9f, 
  #5ee2b0, 
  #00ce3c, 
  #00ba43, 
  #119c3f, 

  #57ecc1, 
  #00e864, 
  #00e05c, 
  #00d545, 
  #7afddd, 
  #00e4c5, 
  #00e0b2, 
  #01eec6, 

  #49efef, 
  #00e7d8, 
  #00e5d1, 
  #01efde, 
  #6addff, 
  #00dafe, 
  #01d6ff, 
  #08acdc, 

  #73cefe, 
  #0d9bf7, 
  #148de4, 
  #2a77c9, 
  #8693ff, 
  #2196f3, //45
  #4668f6, 
  #4153dc, 

  #b095ff, 
  #8453fd, 
  #634acd, 
  #5749c5, 
  #ffb7ff, 
  #e863fb, 
  #d655ed, 
  #d14fe9, 

  #fc99e3, 
  #e736c2, 
  #e52fbe, 
  #e334b6, 
  #ed353e, 
  #ffa726, //61
  #f4df0b, 
  #66bb6a, 

  #5cd100, //64
  #00d29e, 
  #2388ff, 
  #3669fd, 
  #00b4d0, 
  #475cdc, 
  #b2bbcd, 
  #95a0b2, 

  #f72737, 
  #d2ea7b, 
  #c8df10, 
  #7fe422, 
  #00c931, 
  #00d7a6, 
  #00d8fc, 
  #0b9bfc, 

  #585cf5, 
  #ac59f0, 
  #d980dc, 
  #b8814a, 
  #ff9800, 
  #abdf22, 
  #9ee154, 
  #66bb6a, //87

  #3bda47, 
  #6fdeb9, 
  #27dbda, 
  #9cc8fd, 
  #79b8f7, 
  #afafef, 
  #d580eb, 
  #f74fca, 

  #ea8a1f, 
  #dbdb08, 
  #9cd60d, 
  #f3d335, 
  #c8af41, 
  #00ca69, 
  #24d2b0, 
  #757ebe, 

  #5388db, 
  #e5c5a6, 
  #e93b3b, 
  #f9a2a1, 
  #ed9c65, 
  #e1ca72, 
  #b8da78, 
  #98d52c, 

  #626cbd, 
  #cac8a0, 
  #90d4c2, 
  #ceddfe, 
  #beccf7, 
  #a3b1be, 
  #b8c0d2, 
  #d2e2f8, 

  #fe1624, 
  #cd2724, 
  #9ccc65, //122
  #009c1b, 
  #ffff00, //124
  #beb212, 
  #f5d01d, //126
  #e37829,
};
