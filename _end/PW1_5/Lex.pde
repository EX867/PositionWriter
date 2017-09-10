int MAX_FRAMES=500;
int MAX_MULTISOUND=200;//change to resizable array!
color[][][] tmpframes=new color[MAX_FRAMES][8][8];//color
color[][][] frames=new color[MAX_FRAMES][8][8];//color
int[] tmpdelay=new int[MAX_FRAMES];
int[] delay=new int[MAX_FRAMES];
int[] tmpcaretPos=new int[MAX_FRAMES];
int[] caretPos=new int[MAX_FRAMES];
int[] tmpdelayLine=new int[MAX_FRAMES];//stores first line position of the frame
int[] delayLine=new int[MAX_FRAMES];
String[] temp;
int sliderTime=0;//slider milliseconds time
int sliderIndex=0;//slider frame index
int totalPlayTime;//total milliseconds of led
int totalFrames;//total number of frames
boolean correctSyntax=true;

String keySoundPath=sketchPath();//if keysound==absolute : use absolute/else :use keysoundpath 
String[][][][] tmpkeySound=new String[8][8][8][MAX_MULTISOUND];
int[][][][] tmpkeySoundLoop=new int[8][8][8][MAX_MULTISOUND];
int[][][] tmpkeySoundMulti=new int[8][8][8];
String[][][][] keySound=new String[8][8][8][MAX_MULTISOUND];
int[][][][] keySoundLoop=new int[8][8][8][MAX_MULTISOUND];
int[][][] keySoundMulti=new int[8][8][8];

void copyCaretArray() {
  int a=0;
  while (a<MAX_FRAMES) {
    caretPos[a]=tmpcaretPos[a];
    delayLine[a]=tmpdelayLine[a];
    a=a+1;
  }
}
void copyArray() {
  if (Tab==TAB_LED) {
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
      delayLine[a]=tmpdelayLine[a];
      a=a+1;
    }
  } else if (Tab==TAB_KEYSOUND) {
    int a=0;
    while (a<8) {
      int b=0;
      while (b<8) {
        int c=0;
        while (c<8) {
          int d=0;
          while (d<MAX_MULTISOUND) {
            keySound[a][b][c][d]=tmpkeySound[a][b][c][d];
            keySoundLoop[a][b][c][d]=tmpkeySoundLoop[a][b][c][d];
            d=d+1;
          }
          keySoundMulti[a][b][c]=tmpkeySoundMulti[a][b][c];
          c=c+1;
        }
        b=b+1;
      }
      a=a+1;
    }
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
    delay[a]=0;
    tmpdelay[a]=0;
    a=a+1;
  }
  a=0;
  while (a<8) {
    b=0;
    while (b<8) {
      c=0;
      while (c<8) {
        int d=0;
        while (d<MAX_MULTISOUND) {
          tmpkeySound[a][b][c][d]="";
          tmpkeySoundLoop[a][b][c][d]=1;
          keySound[a][b][c][d]="";
          keySoundLoop[a][b][c][d]=1;
          d=d+1;
        }
        tmpkeySoundMulti[a][b][c]=0;
        keySoundMulti[a][b][c]=0;
        c=c+1;
      }
      b=b+1;
    }
    a=a+1;
  }
}
void resetArray() {
  if (Tab==TAB_LED) {
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
      tmpcaretPos[a]=0;
      tmpdelay[a]=0;
      tmpdelayLine[a]=0;
      a=a+1;
    }
  } else if (Tab==TAB_KEYSOUND) {
    int a=0;
    while (a<8) {
      int b=0;
      while (b<8) {
        int c=0;
        while (c<8) {
          int d=0;
          while (d<MAX_MULTISOUND) {
            tmpkeySound[a][b][c][d]="";
            tmpkeySoundLoop[a][b][c][d]=1;
            d=d+1;
          }
          tmpkeySoundMulti[a][b][c]=0;
          c=c+1;
        }
        b=b+1;
      }
      a=a+1;
    }
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
  if (Tab==TAB_LED) {
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
    tmpdelayLine[0]=0;
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
          if (int(tokens[1])<=0||int(tokens[2])<=0) {
            printError(a, "button number is bigger than 0");
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
          if (int(tokens[1])<=0||int(tokens[2])<=0) {
            printError(a, "button number is bigger than 0");
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
            tmpdelayLine[index]=a;
            shiftArray(index);
            totalPlayTime=totalPlayTime+int(value);
            totalFrames=totalFrames+1;
          } else if (isdivided.length==1) {
            if (int(tokens[1])<=0) {//time is not correct
              printError(a, "time is not correct");
              break;
            }
            tmpcaretPos[index]=totalLength-1;//before the delay
            tmpdelay[index]=int(tokens[1]);//apply
            index=index+1;
            tmpdelayLine[index]=a;
            shiftArray(index);
            totalPlayTime=totalPlayTime+int(tokens[1]);
            totalFrames=totalFrames+1;
          } else {
            printError(a, "time is not correct");
            break;
          }
        } else if (tokens[0].equals("filename")) {//==========================================================================================================================================================================fn
          if (tokensCount<5||tokensCount>7) {//few or many parameters([filename name<c y x l>][filename name<c y x l> convertoption][filename name<c y x l loop>][filename name<c y x l loop> convertoption])
            printError(a, "too few or many parameters");
            break;
          }
          if (tokensCount==5) {
            String newName=tokens[1]+" "+tokens[2]+" "+tokens[3]+" "+tokens[4];
            if (tokens[4].equals("default")||tokens[4].equals("L-R")||tokens[4].equals("U-D")||tokens[4].equals("90-R")||tokens[4].equals("180-R")||tokens[4].equals("180-L")||tokens[4].equals("90-L")||tokens[4].equals("Y=X")||tokens[4].equals("Y=-X")) {
              printError(a, "enter loop count");
              break;
            }
            exports.add(new FileExport(newName));
          } else if (tokensCount==6) {
            String newName=tokens[1]+" "+tokens[2]+" "+tokens[3]+" "+tokens[4];
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
              newName=newName+" "+tokens[5];
              exports.add(new FileExport(newName));
            }
          } else if (tokensCount==7) {
            String newName=tokens[1]+" "+tokens[2]+" "+tokens[3]+" "+tokens[4]+" "+tokens[5];
            if (tokens[6].equals("")) {
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
    tmpdelayLine[index]=a-1;
    if (a==len) {
      shiftArray(index);
      if (Language==LC_ENG) LogRead=LX_ENG_READCOMPLETE;
      else LogRead=LX_KOR_READCOMPLETE;
      correctSyntax=true;
      copyArray();
    }
  } else if (Tab==TAB_KEYSOUND) {
    correctSyntax=false;
    if (Language==LC_ENG) LogRead=LX_ENG_READING;
    else LogRead=LX_KOR_READING;
    temp=split(display.getText(), "\n");
    String[] tokens;
    resetArray();
    int a=0;
    while (a<temp.length) {
      if (temp[a].length()==0) {//is empty
      } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {//is comment
      } else {
        tokens=split(temp[a], "\"");
        int tokensCount=tokens.length;//[c y x sound][c y x sound loop]
        if (tokensCount!=3) {//
          printError(a, "can't read line!");
          break;
        }
        if (tokens[2].equals("")) {//no loop
          String filen=tokens[1];
          if (filen.length()>0) {
            if (filen.charAt(0)=='/'||filen.charAt(0)=='\\') {
              printError(a, "path is incorrect(remove / or \\ on end)");
              break;
            }
          } else {
            printError(a, "enter path.");
            break;
          }
          if (isAbsolutePath(filen)==false)filen=keySoundPath+"/"+filen;
          tokens=split(tokens[0], " ");
          if (tokens[0].length()==0||tokens[1].length()==0||tokens[2].length()==0) {//position is empty
            printError(a, "can't read position.");
            break;
          }
          if (int(tokens[0])<=0||int(tokens[1])<=0||int(tokens[2])<=0) {
            printError(a, "button number is bigger than 0");
            break;
          }
          tmpkeySound[int(tokens[0])-1][int(tokens[2])-1][int(tokens[1])-1][tmpkeySoundMulti[int(tokens[0])-1][int(tokens[2])-1][int(tokens[1])-1]]=filen;
        } else {
          String loopn=tokens[2];
          if (loopn.length()<=0) {
            printError(a, "loop is incorrect. maybe there is a space");
            break;
          }
          if (isNumber(loopn)==false||0<int(loopn)) {
            printError(a, "loop is incorrect. loop is same or bigger than 0");
          }
          tmpkeySoundLoop[int(tokens[0])-1][int(tokens[2])-1][int(tokens[1])-1][tmpkeySoundMulti[int(tokens[0])-1][int(tokens[2])-1][int(tokens[1])-1]]=int(tokens[tokens.length-1]);
          String filen=tokens[1];
          if (isAbsolutePath(filen)==false)filen=keySoundPath+"/"+filen;
          tokens=split(tokens[0], " ");
          if (tokens[0].length()==0||tokens[1].length()==0||tokens[2].length()==0) {//position is empty
            printError(a, "can't read position.");
            break;
          }
          tmpkeySound[int(tokens[0])-1][int(tokens[2])-1][int(tokens[1])-1][tmpkeySoundMulti[int(tokens[0])-1][int(tokens[2])-1][int(tokens[1])-1]]=filen;
        }
        tmpkeySoundMulti[int(tokens[0])-1][int(tokens[2])-1][int(tokens[1])-1]++;
      }
      a=a+1;
    }
    if (a==temp.length) {
      if (Language==LC_ENG) LogRead=LX_ENG_READCOMPLETE;
      else LogRead=LX_KOR_READCOMPLETE;
      copyArray();
      correctSyntax=true;
    }
  } else if (Tab==TAB_INFO) {
    correctSyntax=true;
    LogRead="can't detect error in info [v2.0]";
    temp=split(display.getText(), "\n");
    //info.Title="Enter Title";
    //info.Producer="Enter Producer";
    //info.Chain=8;
    //info.ButtonX=8;
    //info.ButtonY=8;
    //info.Landscape=true;
    //info.SquareButton=true;
    String[] tokens;
    int a=0;
    while (a<temp.length) {
      if (temp[a].equals("")||temp.length<2) {
      } else if (temp[a].substring(0, 2).equals("//")) {
      } else {
        tokens=split(temp[a], "=");
        if (tokens.length!=2) {
          correctSyntax=false;
          LogRead="maybe there is an error!";
        } else {
          if (tokens[0].equals("title")) {
            info.Title=tokens[1];
          } else if (tokens[0].equals("producerName")) {
            info.Producer=tokens[1];
          } else if (tokens[0].equals("buttonX")) {
            info.ButtonX=int(tokens[1]);
          } else if (tokens[0].equals("buttonY")) {
            info.ButtonY=int(tokens[1]);
          } else if (tokens[0].equals("chain")) {
            info.Chain=int(tokens[1]);
          } else if (tokens[0].equals("squareButton")) {
            if (tokens[1].equals("true")||tokens[1].equals("t"))info.SquareButton=true;
            else  if (tokens[1].equals("false")||tokens[1].equals("f"))info.SquareButton=false;
            else {
              correctSyntax=false;
              LogRead="squarebutton is incorrect \""+tokens[1]+"\"";
              if (tokens.length>2)LogRead=LogRead+"...";
            }
          } else if (tokens[0].equals("landscape")) {
            if (tokens[1].equals("true")||tokens[1].equals("t")) info.Landscape=true;
            else if (tokens[1].equals("false")||tokens[1].equals("f"))info.Landscape=false;
            else {
              correctSyntax=false;
              LogRead="landscape is incorrect \""+tokens[1]+"\"";
              if (tokens.length>2)LogRead=LogRead+"...";
            }
          } else {
            correctSyntax=false;
            LogRead="maybe there is an error!";
          }
        }
      }
      a=a+1;
    }
  }
  if (totalFrames==0) {
    sliderIndex=0;
  }
  sR=true;
  tR=false;
  print("read_"+str(correctSyntax)+" ");
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
        if (int(tokens[1])<=0||int(tokens[2])<=0) {
          printError(a, "button number is bigger than 0");
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
        if (int(tokens[1])<=0||int(tokens[2])<=0) {
          printError(a, "button number is bigger than 0");
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
        if (8<int(tokens[1].length())||int(tokens[1].length())<=0) {//chain is out of range(temporary)
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
int getSliderTime(int ind) {
  int index=0;
  int time=0;
  while (index<ind) {
    time=time+delay[index];
    index=index+1;
  }
  return time;
}
void displayFrame() {
  if (R) {
    strokeWeight(2);
    line(910, 640, 1090, 640);
    strokeWeight(1);
    fill(255);
  }
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
  String errstr=temp[a];
  if (errstr.length()>10) {
    errstr=errstr.substring(0, 10)+"...";
  }
  if (Language==LC_ENG) LogRead=LX_ENG_ERR+str(a+1)+" \""+errstr+"\" "+add;
  else LogRead=LX_KOR_ERR+str(a+1)+" \""+errstr+"\" "+add;
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
  if (frames[index][x][y]==color(0, 0)) {
    return true;
  }
  return false;
}
int LEX_keySound_getLineNum(int c, int x, int y, String path) {
  int a=0;
  String[] lines=split(display.getText(), "\n");
  String tof=str(c+1)+" "+str(y+1)+" "+str(x+1)+" "+"\""+path+"\"";
  String tof2=str(c+1).charAt(0)+" "+str(y+1)+" "+str(x+1)+" "+"\""+path+"\"";
  while (a<lines.length) {
    if (lines[a].length()>=tof2.length()) {
      if (lines[a].substring(0, tof2.length()).equals(tof2)) {
        return a;
      }
    }
    if (lines[a].length()>=tof.length()) {
      if (lines[a].substring(0, tof.length()).equals(tof)) {
        return a;
      }
    }
    a=a+1;
  }
  Log="can't find line";
  return -1;
}

int LEX_LED_getLineNum(String com, int x, int y, int index) {
  if (inFrameInput==false)index=totalFrames-1;
  int a=delayLine[index+1];
  String[] lines=split(display.getText(), "\n");
  String tof=com+" "+str(y+1)+" "+str(x+1);
  String tof2=com.charAt(0)+" "+str(y+1)+" "+str(x+1);
  while (a>delayLine[index]) {
    if (lines[a].length()>=tof2.length()) {
      if (lines[a].substring(0, tof2.length()).equals(tof2)) {
        return a;
      }
    }
    if (lines[a].length()>=tof.length()) {
      if (lines[a].substring(0, tof.length()).equals(tof)) {
        return a;
      }
    }
    a=a-1;
  }
  return -1;
}

void LEX_Info_insert(int focus, char c) {
  String[] lines=split(display.getText(), "\n");
  int a=lines.length-1;
  String tof;
  if (focus==1)tof="title";
  else if (focus==2)tof="producerName";
  else if (focus==3)tof="buttonX";
  else if (focus==4)tof="buttonY";
  else if (focus==5)tof="chain";
  else if (focus==6)tof="squareButton";
  else if (focus==7)tof="landscape";
  else return;
  while (a>=0) {
    if (lines[a].length()>=tof.length()) {
      if (lines[a].substring(0, tof.length()).equals(tof)) {
        String[] tokens=split(lines[a], "=");
        if (tokens.length>=2) {
          String rep=tokens[1];
          int b=2;
          while (b<tokens.length) {
            rep=rep+"="+tokens[2];
            b=b+1;
          }
          replaceLine(a, tof+"="+rep+c);
        }
        return;
      }
    }
    a=a-1;
  }
  Log="can't find line";
  correctSyntax=false;
}
void LEX_Info_erase(int focus) {
  String[] lines=split(display.getText(), "\n");
  int a=lines.length-1;
  String tof;
  if (focus==1)tof="title";
  else if (focus==2)tof="producerName";
  else if (focus==3)tof="buttonX";
  else if (focus==4)tof="buttonY";
  else if (focus==5)tof="chain";
  else if (focus==6)tof="squareButton";
  else if (focus==7)tof="landscape";
  else return;
  while (a>=0) {
    if (lines[a].length()>=tof.length()) {
      if (lines[a].substring(0, tof.length()).equals(tof)) {
        String[] tokens=split(lines[a], "=");
        if (tokens.length>=2) {
          String rep=tokens[1];
          int b=2;
          while (b<tokens.length) {
            rep=rep+"="+tokens[2];
            b=b+1;
          }
          if (rep.length()<=0)return;
          replaceLine(a, tof+"="+rep.substring(0, rep.length()-1));
        }
        return;
      }
    }
    a=a-1;
  }
  Log="can't find line";
  correctSyntax=false;
}