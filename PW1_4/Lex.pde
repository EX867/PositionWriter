int MAX_FRAMES=1000;
color[][][] tmpframes=new color[MAX_FRAMES][8][8];//color
color[][][] frames=new color[MAX_FRAMES][8][8];//color
int[] tmpdelay=new int[MAX_FRAMES];
int[] delay=new int[MAX_FRAMES];
int[] tmpcaretPos=new int[MAX_FRAMES];
int[] caretPos=new int[MAX_FRAMES];
String[] temp;
int sliderTime=0;//slider milliseconds time
int sliderIndex=0;//slider frame index
int totalPlayTime;//total milliseconds of led
int totalFrames;//total number of frames
boolean correctSyntax=true;

void copyCaretArray() {
  int a=0;
  while (a<MAX_FRAMES) {
    caretPos[a]=tmpcaretPos[a];
    a=a+1;
  }
}
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
    delay[a]=tmpdelay[a];
    caretPos[a]=tmpcaretPos[a];
    a=a+1;
  }
}
void resetArrayFull() {
  int a;
  int b;
  int c;
  a=0;
  while (a<MAX_FRAMES) {
    b=0;
    while (b<8) {
      c=0;
      while (c<8) {
        frames[a][b][c]=color(0, 0);
        tmpframes[a][b][c]=color(0, 0);
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
        tmpframes[a][b][c]=color(0, 0);
        c=c+1;
      }
      b=b+1;
    }
    a=a+1;
  }
}
void shiftArray(int n) {
  if (n==0) {
  } else {
    int a;
    int b;
    a=0;
    while (a<8) {
      b=0;
      while (b<8) {
        if (tmpframes[n-1][a][b]==color(0, 0)) {
          tmpframes[n][a][b]=color(0, 0);
        } else {
          tmpframes[n][a][b]=tmpframes[n-1][a][b];
        }
        b=b+1;
      }
      a=a+1;
    }
  }
}
void readFrame() {//frame 0 equals first on. frame n equals the frame after n-1 times of delay

  if (Mode==CHAINMODE) {
    readFrameChainMode();
    return;
  } else if (Mode==AUTOPLAY) {
    readFrameAutoplay();
    return;
  }
  //tmpframes on n/off -128
  correctSyntax=false;
  if (Language==LC_ENG) LogRead=LX_ENG_READING;
  else LogRead=LX_KOR_READING;

  temp=split(display.getText(), "\n");
  String[] tokens;

  resetArray();
  int a=0;
  int len=exports.size();
  while (a<len) {
    exports.remove(0);
    a=a+1;
  }

  totalPlayTime=0;
  totalFrames=1;

  Bpm=0;
  int totalLength=0;

  a=0;
  len=temp.length;
  int index=0;
  while (a<len) {
    if (temp[a].length()==0) {//is empty
    } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {//is comment
    } else {
      tokens=split(temp[a], " ");
      int tokensCount=tokens.length;
      if (tokens[0].equals("on") || tokens[0].equals("o")) {//==========================================================================================================================================================================o
        if (tokensCount>5 || tokensCount<4) {//few or many parameters(4 is [on y x html][on y x vel] 5 is [on y x html vel][on y x auto vel]
          printError(a, "too few or many parameters");
          break;
        }
        if (tokens[1].length()==0||tokens[2].length()==0) {//position is empty
          printError(a, "can't read position. maybe two blanks?");
          break;
        }
        if (isInt(tokens[1])==false||isInt(tokens[2])==false) {
          printError(a, "position is not integer");
          break;
        }
        if (int(tokens[1])<1||int(tokens[1])>8||int(tokens[2])<1||int(tokens[2])>8) {
          printError(a, "position is out of range");
          break;
        }
        if (tokensCount==5) {//[on y x html vel][on y x auto vel]
          if (tokens[3].equals("auto") || tokens[3].equals("a")) {//[on y x auto vel]
            if (tokens[4].length()>3 || tokens[4].length()<=0||127<int(tokens[4])||int(tokens[4])<0) {//velocity is not correct
              printError(a, "velocity is not correct");
              break;
            }
            tmpframes[index][int(tokens[2])-1][int(tokens[1])-1]=color(k[int(tokens[4])]);//apply
          } else {//[on y x html vel]
            if (isInt(tokens[3])==false) {
              printError(a, "velocity is not correct");
              break;
            }
            if (tokens[4].length()>3 || tokens[4].length()<0||127<int(tokens[4])||int(tokens[4])<=0) {//velocity is not correct
              printError(a, "velocity is not correct");
              break;
            }
            if (tokens[3].length()!=6||16777216<=unhex(tokens[3])||unhex(tokens[3])<0) {//html is not correct
              printError(a, "html color is not correct");
              break;
            }
            tmpframes[index][int(tokens[2])-1][int(tokens[1])-1]=color(round(unhex(tokens[3])/65536), round((unhex(tokens[3])%65536)/256), round(unhex(tokens[3])%256));//apply
          }
        } else if (tokensCount==4) {//[on y x html][on y x vel]
          if (tokens[3].equals("auto")||tokens[3].equals("a")) {
            printError(a, "enter velocity number");
            break;
          }
          if (tokens[3].length()==6) {//[on y x html]
            if (tokens[3].length()!=6||16777216<=unhex(tokens[3])||unhex(tokens[3])<0) {//html is not correct
              printError(a, "html color is not correct");
              break;
            }
            tmpframes[index][int(tokens[2])-1][int(tokens[1])-1]=color(round(unhex(tokens[3])/65536), round((unhex(tokens[3])%65536)/256), round(unhex(tokens[3])%256));//apply
          } else {//[on y x vel]
            if (isInt(tokens[3])==false) {
              printError(a, "velocity is not correct");
              break;
            }
            if (tokens[3].length()>3 || tokens[3].length()<0||127<int(tokens[3])||int(tokens[3])<=0) {//velocity is not correct
              printError(a, "velocity is not correct");
              break;
            }
            tmpframes[index][int(tokens[2])-1][int(tokens[1])-1]=color(k[int(tokens[3])]);//apply
          }
        }
      } else if (tokens[0].equals("off") || tokens[0].equals("f")) {//==========================================================================================================================================================================f
        if (tokensCount!=3) {//few or many parameters([off y x])
          printError(a, "too few or many parameters");
          break;
        }
        if (tokens[1].length()==0||tokens[2].length()==0) {//position is empty
          printError(a, "can't read position. maybe two blanks?");
          break;
        }
        if (isInt(tokens[1])==false||isInt(tokens[2])==false) {
          printError(a, "position is not integer");
          break;
        }
        if (int(tokens[1])<1||int(tokens[1])>8||int(tokens[2])<1||int(tokens[2])>8) {
          printError(a, "position is out of range");
          break;
        }
        tmpframes[index][int(tokens[2])-1][int(tokens[1])-1]=color(0, 0);
      } else if (tokens[0].equals("delay") || tokens[0].equals("d")) {//==========================================================================================================================================================================d
        if (tokensCount!=2) {//few or many parameters([delay t])
          printError(a, "too few or many parameters");
          break;
        }
        if (tokens[1].length()==0) {//time is empty
          printError(a, "enter time");
          break;
        }
        //bpm sync
        String[] isdivided=split(tokens[1], "/");
        if (isdivided.length==2) {
          if (Bpm==0) {
            printError(a, "set bpm before using bpm expression");
            break;
          }
          if (isInt(isdivided[0])==false||isInt(isdivided[1])==false) {
            printError(a, "fraction is incorrect!");
            break;
          }
          if (int(isdivided[0])==0) {
            printError(a, "delay can't be 0");
            break;
          }
          if (int(isdivided[0])<0||int(isdivided[1])<=0) {
            printError(a, "delay is bigger than 0");
            break;
          }
          tmpcaretPos[index]=totalLength-1;//before the delay
          int value=floor((int(isdivided[0])*2400/(Bpm*int(isdivided[1])))*100);
          tmpdelay[index]=value;//apply
          index=index+1;
          shiftArray(index);
          totalPlayTime=totalPlayTime+int(value);
          totalFrames=totalFrames+1;
        } else if (isdivided.length==1) {
          if (isInt(tokens[1])==false) {
            printError(a, "time is incorrect!");
            break;
          }
          if (int(tokens[1])<=0) {//time is not correct
            printError(a, "time is not correct");
            break;
          }
          tmpcaretPos[index]=totalLength-1;//before the delay
          tmpdelay[index]=int(tokens[1]);//apply
          index=index+1;
          shiftArray(index);
          totalPlayTime=totalPlayTime+int(tokens[1]);
          totalFrames=totalFrames+1;
        } else {
          printError(a, "time is not correct");
          break;
        }
      } else if (tokens[0].equals("filename")) {//==========================================================================================================================================================================fn
        if (tokensCount<5||tokensCount>6) {//few or many parameters([filename name<c y x l>][filename name<c y x l> convertoption])
          printError(a, "too few or many parameters");
          break;
        }
        String newName=tokens[1]+" "+tokens[2]+" "+tokens[3]+" "+tokens[4];
        if (tokensCount==5) {
          if (tokens[4].equals("default")||tokens[4].equals("L-R")||tokens[4].equals("U-D")||tokens[4].equals("90-R")||tokens[4].equals("180-R")||tokens[4].equals("180-L")||tokens[4].equals("90-L")||tokens[4].equals("Y=X")||tokens[4].equals("Y=-X")) {
            printError(a, "enter loop count");
            break;
          }
          exports.add(new FileExport(newName));
        } else if (tokensCount==6) {
          if (tokens[5].equals("")) {
            printError(a, "delete space");
            break;
          }
          if (tokens[5].equals("default")||tokens[5].equals("d")||tokens[5].equals("0")) {
            exports.add(new FileExport(newName, 0));
          } else if (tokens[5].equals("L-R")||tokens[5].equals("1")) {
            exports.add(new FileExport(newName, 1));
          } else if (tokens[5].equals("U-D")||tokens[5].equals("2")) {
            exports.add(new FileExport(newName, 2));
          } else if (tokens[5].equals("90-R")||tokens[5].equals("3")) {
            exports.add(new FileExport(newName, 3));
          } else if (tokens[5].equals("180-R")||tokens[5].equals("180-L")||tokens[5].equals("4")) {
            exports.add(new FileExport(newName, 4));
          } else if (tokens[5].equals("90-L")||tokens[5].equals("5")) {
            exports.add(new FileExport(newName, 5));
          } else if (tokens[5].equals("Y=X")||tokens[5].equals("6")) {
            exports.add(new FileExport(newName, 6));
          } else if (tokens[5].equals("Y=-X")||tokens[5].equals("7")) {
            exports.add(new FileExport(newName, 7));
          } else {
            printError(a, "option incorrect");
            break;
          }
        }
      } else if (tokens[0].equals("bpm")) {//==========================================================================================================================================================================d
        //[bpm s]
        if (tokensCount!=2) {
          printError(a, "too few or many parameters");
          break;
        }
        if (tokens[1].equals("")) {
          printError(a, "enter bpm");
          break;
        }
        if (float(tokens[1])<=0) {
          printError(a, "bpm is bigger than 0");
          break;
        }
        Bpm=float(tokens[1]);
      } else {
        printError(a, "unknown token \""+tokens[0]+"\"");
        break;
      }
    }
    totalLength=totalLength+temp[a].length()+1;
    a=a+1;
  }
  tmpcaretPos[index]=totalLength-1;//before the delay
  index++;
  if (a==len) {
    shiftArray(index);
    if (Language==LC_ENG) LogRead=LX_ENG_READCOMPLETE;
    else LogRead=LX_KOR_READCOMPLETE;
    correctSyntax=true;
    copyArray();
  }
  sR=true;
  tR=false;
  println("read completed "+str(correctSyntax));
}

//==========================================================================================================================
void readFrameChainMode() {//[c x y]
  correctSyntax=false;
  if (Language==LC_ENG) LogRead=LX_ENG_READING;
  else LogRead=LX_KOR_READING;
  temp=split(display.getText(), "\n");
  String[] tokens;
  int a=0;
  int len=temp.length;
  totalPlayTime=0;
  while (a<len) {
    if (temp[a].length()==0) {//is empty
    } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {//is comment
    } else {
      tokens=split(temp[a], " ");
      //int tokensCount=tokens.length;
      //nothing!!
    }
    a=a+1;
  }
  if (a==len) {
    if (Language==LC_ENG) LogRead=LX_ENG_READCOMPLETE;
    else LogRead=LX_KOR_READCOMPLETE;
    correctSyntax=true;
  }
  sR=true;
  tR=false;
  println("read completed "+str(correctSyntax));
}

void readFrameAutoplay() {//[on y x][off y x][chain c]
  //tmpframes on n/off -128
  correctSyntax=false;
  if (Language==LC_ENG) LogRead=LX_ENG_READING;
  else LogRead=LX_KOR_READING;
  temp=split(display.getText(), "\n");
  String[] tokens;
  int len=temp.length;
  int a=0;
  totalPlayTime=0;
  Bpm=0;
  while (a<len) {
    if (temp[a].length()==0) {//is empty
    } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {//is comment
    } else {
      tokens=split(temp[a], " ");
      int tokensCount=tokens.length;
      if (tokens[0].equals("on") || tokens[0].equals("o")) { 
        if (tokensCount!=3) {
          printError(a, "too few or many parameters");
          break;
        }
        if (tokens[1].length()==0||tokens[2].length()==0) {//position is empty
          printError(a, "can't read position. maybe two blanks?");
          break;
        }
        if (isInt(tokens[1])==false||isInt(tokens[2])==false) {
          printError(a, "position is not integer");
          break;
        }
        if (int(tokens[1])<1||int(tokens[1])>8||int(tokens[2])<1||int(tokens[2])>8) {
          printError(a, "position is out of range");
          break;
        }
      } else if (tokens[0].equals("off") || tokens[0].equals("f")) {
        if (tokensCount!=3) {
          printError(a, "too few or many parameters");
          break;
        }
        if (tokens[1].length()==0||tokens[2].length()==0) {//position is empty
          printError(a, "can't read position. maybe two blanks?");
          break;
        }
        if (isInt(tokens[1])==false||isInt(tokens[2])==false) {
          printError(a, "position is not integer");
          break;
        }
        if (int(tokens[1])<1||int(tokens[1])>8||int(tokens[2])<1||int(tokens[2])>8) {
          printError(a, "position is out of range");
          break;
        }
      } else if (tokens[0].equals("chain") || tokens[0].equals("c")) {
        if (tokensCount!=2) {
          printError(a, "too few or many parameters");
          break;
        }
        if (tokens[1].length()==0) {//position is empty
          printError(a, "can't read position. maybe two blanks?");
          break;
        }
        if (8<int(tokens[1])||int(tokens[1])<=0) {//chain is out of range(temporary)
          printError(a, "chain is out of range");
          break;
        }
      } else {
        printError(a, "unknown token \""+tokens[0]+"\"");
        break;
      }
    }
    a=a+1;
  }
  if (a==len) {
    if (Language==LC_ENG) LogRead=LX_ENG_READCOMPLETE;
    else LogRead=LX_KOR_READCOMPLETE;
    correctSyntax=true;
  }
  sR=true;
  tR=false;
  println("read completed "+str(correctSyntax));
}
//==========================================================================================================================

void displayFrame() {
  if (R) {
    strokeWeight(2);
    line(910, 640, 1090, 640);
    strokeWeight(1);
    fill(255);
  }
  if (sliderTime>totalPlayTime)sliderTime=totalPlayTime;
  if ((isMouseIsPressed(900, 630, 200, 20)&&colorPress==0) || (mousePressed&&colorPress==-1)) {//slider
    sliderTime=floor((((float(mouseX)/scale)-910)*totalPlayTime)/180);
    if (sliderTime<0) sliderTime=0;
    if (sliderTime>totalPlayTime) sliderTime=totalPlayTime;
    sR=true;

    //slider snap-get time and index
    if (sliderTime==totalPlayTime) sliderIndex=totalFrames-1;//because it is array
    else {
      int index=0;
      int time=0;
      while (index<totalFrames) {
        if (time<=sliderTime && time+delay[index]>sliderTime) {
          sliderTime=time;
          sliderIndex=index;
          break;
        }
        time=time+delay[index];
        index=index+1;
      }
    }
    colorPress=-1;
  }
  if (R) {
    if (totalPlayTime!=0) {
      rect(910+(180*(sliderTime)/totalPlayTime)-5, 630, 10, 20);
      line(910, 630, 910, 650);
      int index=0;
      int time=0;
      while (index<totalFrames) {
        time=time+delay[index];
        if (R)line(910+180*time/totalPlayTime, 630, 910+180*time/totalPlayTime, 650);
        index=index+1;
      }
    }
    stroke(0);
    if (sliderIndex!=totalFrames) {
      int a=0;
      while (a<8) {
        int b=0;
        while (b<8) {
          if (frames[sliderIndex][a][b]==color(0, 0)) {
          } else {
            fill (frames[sliderIndex][a][b]);//round(frames[sliderIndex][a][b]/65536), round((frames[sliderIndex][a][b]%65536)/256), round(frames[sliderIndex][a][b]%256));
            rect(100*a+5, 100*b+5, 100-10, 100-10);
          }
          b=b+1;
        }
        a=a+1;
      }
    }
    if (R) {
      fill(255);
      if (inFrameInput) {
        if (totalPlayTime==0) {
          triangle(1090, 625, 1085, 615, 1095, 615);
        } else {
          triangle(910+(180*(sliderTime)/totalPlayTime), 625, 910+(180*(sliderTime)/totalPlayTime)-5, 615, 910+(180*(sliderTime)/totalPlayTime)+5, 615);
        }
      } else {
        triangle(1090, 625, 1085, 615, 1095, 615);
      }
    }
  }
}
void printError(int a, String add) {
  if (Language==LC_ENG) LogRead=LX_ENG_ERR+str(a+1)+" \""+temp[a]+"\" "+add;
  else LogRead=LX_KOR_ERR+str(a+1)+" \""+temp[a]+"\" "+add;
}

void autorun_displayFrame() {
  int index=0;
  if (autorun_time==totalPlayTime) index=totalFrames-1;
  else {
    int time=0;
    while (index<totalFrames) {
      if (time<=autorun_time && time+delay[index]>autorun_time) {
        //index calced
        break;
      }
      time=time+delay[index];
      index=index+1;
    }
  }
  int a=0;
  while (a<8) {
    int b=0;
    while (b<8) {
      int indexi=index;
      while (indexi>autorun_endIndex&&frames[indexi][a][b]==color(0, 0)&&indexi>0) {
        indexi--;
      }
      fill (frames[indexi][a][b]);
      if (frames[indexi][a][b]==color(0, 0)) {
        stroke(205);
        fill(205);
      } else {
        stroke(0);
      }
      rect(100*a+5, 100*b+5, 100-10, 100-10);
      b=b+1;
    }
    a=a+1;
  }
  autorun_endIndex=index;
}

void CF_autoRun() {
  readFrame();
  if (correctSyntax==true&&totalPlayTime!=0) {
    println("play start");
    //key refresh
    shiftPressed=false;
    ctrlPressed=false;
    buffer="";
    //
    autorun_isLoopLeft=true;
    autorun_finished_oneshot=false;
    autorun_loopCount=0;
    long time=System.currentTimeMillis();
    autorun_start= time;
    autorun_end= time; 
    autorun_endIndex=0;
    autorun_time=0;
    autorun_finished=false;
    if (isPlaying==false) {
      fill(255, 200);
      rect(900, 0, width/scale-900, height/scale);
    }
    isPlaying=true;
  }
}
void autoRunExceptionRefresh() {    
  if (colorPress!=0&&mousePressed==false) colorPress=0;
}
void displayAutoRun() {
  stroke(0);
  textSize(20);
  //play button
  fill(255);
  rect(910, 665, 30, 30);
  strokeWeight(2);
  fill(115, 225, 120);
  triangle(935, 680, 915, 670, 915, 690);
  strokeWeight(1);
  if (isMouseIsPressed(910, 665, 30, 30)) {
    if (colorPress==0) {
      CF_autoRun();
      colorPress=-8;
    }
  }
  //stop button
  fill(255);
  rect(950, 665, 30, 30);
  strokeWeight(2);
  fill(1208, 140, 140);
  rect(955, 670, 20, 20);
  strokeWeight(1);
  fill(255);
  if (isMouseIsPressed(950, 665, 30, 30)) {
    if (colorPress==0) {
      isPlaying=false;
      println("play end");
      colorPress=-9;
    }
  }
  //indicator(time/totalTime)
  rect(990, 665, 100, 30);
  fill(0);
  text(autorun_time+"/"+totalPlayTime, 1040, 675);
}
boolean isLastOff(int x, int y) {
  readFrame();
  int index;
  if (inFrameInput)index=sliderIndex;
  else index=totalFrames;
  if (index<0)index=0;
  println(index);
  if (frames[index][x][y]==color(0, 0)) {
    return true;
  }
  return false;
}