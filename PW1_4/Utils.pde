
void getDelayPos() {
  temp=split(display.getText(), "\n");
  String[] tokens;

  int a=0;
  int totalLength=0;
  int len=temp.length;
  boolean delayCorrect=false;
  int textLen=display.getText ().length ();
  int index=0;
  while (a<len) {
    if (temp[a].length()==0) {//is empty
    } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {//is comment
    } else {
      tokens=split(temp[a], " ");
      int tokensCount=tokens.length;
      if (tokens[0].equals("delay") || tokens[0].equals("d")) {//==========================================================================================================================================================================d
        if (tokensCount!=2) {//few or many parameters([delay t])
          printError(a, "too few or many parameters");
          totalLength=totalLength+temp[a].length()+1;
          a=a+1;
          continue;
        }
        if (tokens[1].length()==0) {//time is empty
          printError(a, "enter time");
          totalLength=totalLength+temp[a].length()+1;
          a=a+1;
          continue;
        }
        //bpm sync
        String[] isdivided=split(tokens[1], "/");
        if (isdivided.length==2) {
          if (Bpm==0) {
            printError(a, "set bpm before using bpm expression");
            totalLength=totalLength+temp[a].length()+1;
            a=a+1;
            continue;
          }
          if (int(isdivided[0])==0) {
            printError(a, "delay can't be 0");
            totalLength=totalLength+temp[a].length()+1;
            a=a+1;
            continue;
          }
          if (int(isdivided[0])<0||int(isdivided[1])<=0) {
            printError(a, "delay is bigger than 0");
            totalLength=totalLength+temp[a].length()+1;
            a=a+1;
            continue;
          }
          tmpcaretPos[index]=min(textLen, max(0, totalLength-1));//before the delay
          index=index+1;
        } else if (isdivided.length==1) {
          if (int(tokens[1])<=0) {//time is not correct
            printError(a, "time is not correct");
            totalLength=totalLength+temp[a].length()+1;
            a=a+1;
            continue;
          }
          tmpcaretPos[index]=min (textLen, max(0, totalLength-1));//before the delay
          index=index+1;
        } else {
          printError(a, "time is not correct");
          totalLength=totalLength+temp[a].length()+1;
          a=a+1;
          continue;
        }
      }
    }
    totalLength=totalLength+temp[a].length()+1;
    a=a+1;
  }
  //if (a==len) {
  tmpcaretPos[index]=min (textLen, max(0, totalLength-1));//before the delay
  index++;
  //delayCorrect=true;
  copyCaretArray();
  //}
  sR=true;
  println("read completed "+str(delayCorrect));
}
//================================================================================================================================
color [] k=new color[]{
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

void drawVel (int x, int y, int w, int h) {
  int a;
  a=0;
  textSize(12);
  textAlign(LEFT, CENTER);
  while (a <128) {
    stroke (color (k [a]));
    fill (color (k [a]));
    rect(x+((a%16)*((float)w/16)), y+(round (a/16)*((float)h/8)), ((float)w/16), ((float)h/8));
    if (w>500) {//500..........
      textFont(velocityFont);
      fill(0);
      text (str (a), x+((a%16)*((float)w/16))+2, y+(round (a/16)*((float)h/8))+h/32+18);
    }
    a=a+1;
  }
  textFont(editorFont);
  textAlign(CENTER, CENTER);
  stroke(0);
  noFill();
  rect(x, y, w, h);
}


//================================================================================================================================
void RecordLog() {
  tR=true;
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

void WriteDisplay(String text) {
  if (text.equals(""))return;
  if (inFrameInput) {
    readFrame();
    getDelayPos();
    if (sliderIndex>=caretPos.length)sliderIndex=caretPos.length-1;//last add/
    if (caretPos[sliderIndex]==0) {
      text=text+"\n";
    }
    LogFull=display.getText().substring(0, caretPos[sliderIndex])+text+display.getText().substring(caretPos[sliderIndex], display.getText().length());
    RecordLog();
    display.setText(LogFull);
  } else {
    LogFull=display.getText()+text;
    RecordLog();
    display.setText(LogFull);
  }
  if (changed==false) {
    if (loaded==false)surface.setTitle("PositionWriter 1.4.3 - new file*");
    else surface.setTitle("PositionWriter 1.4.3 - "+currentFileName+"*");
  }
  changed=true;
}
void drawIndicator(int x, int y, int w, int h, int thick) {
  noFill();
  stroke(255);
  strokeWeight(thick);
  rect(x, y, w, h);
  stroke(0);
  strokeWeight(2);
  rect(x-thick/2, y-thick/2, w+thick, h+thick);
  rect(x+thick/2, y+thick/2, w-thick, h-thick);
}
public boolean isInt(String str) {
  if (str.equals("")) return false;
  if (str.length() > 9) return false;
  // just int or float is needed!
  int a = 0;
  if (str.charAt(0) == int('-')) a = 1;
  while (a < str.length()) {
    if ((int('0') <= str.charAt(a) && str.charAt(a) <= int('9')) == false)return false;
    a = a + 1;
  }
  return true;
}