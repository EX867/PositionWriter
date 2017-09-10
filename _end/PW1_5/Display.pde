
//===================================================================

//ui

void UI_positionButtons() {//UI_position buttons
  fill(205);
  if (R)rect(0, 0, 800, 800);
  stroke(0);
  int a=0;
  if (R) {
    line(900, 0, 900, 840);
    while (a<9) {
      line(100*a, 0, 100*a, 800);
      line(0, a*100, 900, a*100);
      a=a+1;
    }
    if (Tab==TAB_KEYSOUND) {
      fill(0, 100);
      rect(100*Xpos, 100*Ypos, 100, 100);
    }
  }
  if (colorPress==0&&velocityPress==0&&modePress==0) {//mousepress exception for position button!
    int X=mouseX/100;
    int Y=mouseY/100;
    if (X>=0&&Y>=0&&X<8&&Y<8) {//press pad
      if (mouseState!=AN_RELEASED)sR=true;//for indicator update
      if (R&&(mouseState!=AN_RELEASED)) {//draw Marker
        fill(0, 70);
        rect(100*X, 0, 100, 800);
        rect(0, 100*Y, 800, 100);
        if (Tab==TAB_LED) {
          if (Mode==CHAINMODE)LogTemp="Chain "+str(Chain+1)+" ( "+str(X+1)+", "+str(Y+1)+")";
          else LogTemp="( "+str(X+1)+", "+str(Y+1)+")";
        } else {
          LogTemp="Chain "+str(Chain+1)+" ( "+str(X+1)+", "+str(Y+1)+")";
        }
      }
      if (mouseState==AN_RELEASE) {//when release
        sR=true;
        if (Tab==TAB_LED) {
          if (Mode==DEFAULT) {
            Log=str(X+1)+", "+str(Y+1);
            WriteDisplay(" "+str(Y+1)+" "+str(X+1));
          } else if (Mode==AUTOINPUT) {//on y x if(sel==html){ selectedC | auto selectedV }
            Log=str(X+1)+", "+str(Y+1);
            if (isLastOff(X, Y)) {
              if (selectedHorV==DS_HTML)WriteDisplay("\non "+str(Y+1)+" "+str(X+1)+" "+hex((recentColor[selectedHTML]>>16)&0xFF, 2)+hex((recentColor[selectedHTML]>>8)&0xFF, 2)+hex((recentColor[selectedHTML]&0xFF), 2));
              else WriteDisplay("\non "+str(Y+1)+" "+str(X+1)+" auto "+selectedVelocity);
            } else {
              if (SE_ON_DELETABLE) {
                int linen=LEX_LED_getLineNum("on", X, Y, sliderIndex);
                if (linen!=-1)deleteLine(linen);
                else WriteDisplay("\noff "+str(Y+1)+" "+str(X+1));
              } else {
                WriteDisplay("\noff "+str(Y+1)+" "+str(X+1));
              }
            }
          } else if (Mode==CHAINMODE) {//on y x
            Log=str(X+1)+", "+str(Y+1);
            WriteDisplay("\n"+str(Chain+1)+" "+str(Y+1)+" "+str(X+1));
          } else if (Mode==AUTOPLAY) {//on y x
            Log=str(X+1)+", "+str(Y+1);
            WriteDisplay(" "+str(Y+1)+" "+str(X+1));
          }
        } else if (Tab==TAB_KEYSOUND) {
          Log=str(X+1)+", "+str(Y+1);
          if (Xpos!=X||Ypos!=Y)SelectedFile2=-1;
          Xpos=X;
          Ypos=Y;
        }
      }
    }
    if (X==8&&Y<8) {//press chain
      if (mouseState!=AN_RELEASED)sR=true;
      if (R&&(mouseState!=AN_RELEASED)) {//draw marker
        fill(0, 100);
        rect(800, 100*Y, 100, 100);
        if (Tab==TAB_LED) {
          if (Mode==CHAINMODE) {
            LogTemp=str(Y+1);
          }
        } else if (Tab==TAB_KEYSOUND) {
          LogTemp=str(Y+1);
        }
      }
      if (mouseState==AN_RELEASE) {//when release
        sR=true;
        if (Tab==TAB_LED) {
          if (Mode==CHAINMODE) {
            Chain=Y;
            if (Language==LC_ENG) Log=DS_ENG_SETCHAIN+str(Chain+1);
            else Log=DS_KOR_SETCHAIN+str(Chain+1);
          } else if (Mode==AUTOPLAY) {//chain c
            Chain=Y;
            WriteDisplay("\nchain "+str(Chain+1));
            if (Language==LC_ENG) Log=DS_ENG_SETCHAIN+str(Chain+1);
            else Log=DS_KOR_SETCHAIN+str(Chain+1);
          }
        } else if (Tab==TAB_KEYSOUND) {
          if (Chain!=Y)SelectedFile2=-1;
          Chain=Y;
        }
      }
    }
  }
  if (R&&((Tab==TAB_LED&&Mode==CHAINMODE)||Tab==TAB_KEYSOUND)) {
    fill(0, 100);
    rect(800, 100*Chain, 100, 100);
  }
  if (R) {
    fill(0);
    stroke(0);
    quad(385, 400, 400, 385, 415, 400, 400, 415);
  }
  fill(255);
  stroke(255);
}

void UI_recentColors() {//recent colors view
  int a=0;
  while (a<10) {
    if (isMouseIsPressed(a*35-175*floor(a/5)+910, 35*floor(a/5)+365, 30, 30)) {//old method yet. please modify to new algorithm!
      sR=true;
      if (colorPress==0) {
        Log=hex((recentColor[a]>>16)&0xFF, 2)+hex((recentColor[a]>>8)&0xFF, 2)+hex((recentColor[a]&0xFF), 2);
        if (Mode==DEFAULT) {
          WriteDisplay(" "+Log);
          display.setText(LogFull);
        } else if (Mode==AUTOINPUT) {
          selectedHorV=DS_HTML;
          selectedHTML=a;
        }
        if (a==0&&recentColor[0]!=recentColor[1]) {
          int c=9;
          while (c>0) {
            recentColor[c]=recentColor[c-1];
            c=c-1;
          }
          selectedHTML+=1;
          if (selectedHTML>9)selectedHorV=DS_VEL;
        }
        colorPress=-2;
      }
    }
    if (isMouseIsOn(a*35-175*floor(a/5)+910, 35*floor(a/5)+360, 30, 30)) {
      sR=true;
    } 
    a=a+1;
  }
  recentColor[0]=color(cR, cG, cB);
}

void UI_colorSliders() {
  if ((isMouseIsPressed(930, 240, 170, 20)&&colorPress==0) || (mousePressed&&colorPress==1)) {
    if (keyPressed==true&&keyCode==ALT) cR=floor((/*float*/((mouseX/scale)-940+300)*64)/150);
    else cR=floor((/*float*/((mouseX/scale)-940)*256)/150);
    if (cR<0) cR=0;
    if (cR>255) cR=255;
    colorPress=1;
  } else if ((isMouseIsPressed(930, 270, 170, 20)&&colorPress==0) || (mousePressed&&colorPress==2)) {
    if (keyPressed==true&&keyCode==ALT) cG=floor((/*float*/((mouseX/scale)-940+300)*64)/150);
    else cG=floor((/*float*/((mouseX/scale)-940)*256)/150);
    if (cG<0) cG=0;
    if (cG>255) cG=255;
    colorPress=2;
  } else if ((isMouseIsPressed(930, 300, 170, 20)&&colorPress==0) || (mousePressed&&colorPress==3)) {
    if (keyPressed==true&&keyCode==ALT) cB=floor((/*float*/((mouseX/scale)-940+300)*64)/150);
    else cB=floor((/*float*/((mouseX/scale)-940)*256)/150);
    if (cB<0) cB=0;
    if (cB>255) cB=255;
    colorPress=3;
  } else if (isMouseIsPressed(910, 335, 10, 20)&&colorPress==0) {
    /*if (colorMode==1) colorMode=0;
     else colorMode=1;
     colorPress=-1;*/
  }
}
//utils

void DS_displayVelocity() {
  int a;
  if (isMouseIsPressed(300, 240, 600, 300)&&velocityPress==1&&colorPress==0) {
    a=floor(((mouseY/scale)-240)*8/300)*16+floor(((mouseX/scale)-300)*16/600);
    colorPress=-3;
    Log=str(a);
    selectedVelocity=a;
    selectedHorV=DS_VEL;
    if (Mode==DEFAULT) WriteDisplay(" "+Log);
  }
  if (isMouseIsOn(900, 440, 200, 100)||(isMouseIsOn(300, 240, 600, 300)&&velocityPress==1)) {
    sR=true;
    velocityPress=1;
  } else {
    if (velocityPress==1) sR=true;
    velocityPress=0;
  }
}



void DS_inputInFrame() {//MODIFY!!!!
  if (R) {
    fill(255);
    rect(1060, 810, 10, 20);
    fill(225);
    if (inFrameInput) rect(1060, 810, 10, 10);
    else rect(1060, 820, 10, 10);
  }
  if (isMouseIsOn(1060, 810, 10, 20)) {
    sR=true;
    if (R) {
      textSize(15);
      fill(255, 200);
      rect(950, 780, 140, 20);
      fill(0);
      if (inFrameInput)text("input in frame=true", 1020, 788);
      else text("input in frame=false", 1020, 788);
    }
  }
  if (isMouseIsPressed(1060, 810, 10, 20)&&mouseState==AN_PRESS&&colorPress==0) {
    tR=true;
    sR=true;
    if (inFrameInput) inFrameInput=false;
    else inFrameInput=true;
    colorPress=-10;
  }
}

void DS_infinite() {//MODIFY!!!!
  if (R) {
    textSize(15);
    fill(255);//this is NOT infinite.move to rececntNumber
    rect(910, 745, 40, 20);
    rect(910, 770, 40, 20);
    fill(0);
    text(recentNumber1, 930, 755);
    text(recentNumber2, 930, 780);

    fill(255);
    rect(1060, 760, 20, 20);
    rect(1080, 760, 10, 20);
    fill(225);
    if (autorun_infinite) rect(1080, 760, 10, 10);
    else rect(1080, 770, 10, 10);
  }
  if (isMouseIsOn(1080, 760, 10, 20)) {
    sR=true;
    if (R) {
      textSize(15);
      fill(255, 200);
      rect(970, 780, 120, 20);
      fill(0);
      if (autorun_infinite)text("infinite play=true", 1030, 788);
      else text("infinite play=false", 1030, 788);
    }
  }
  if (isMouseIsPressed(1080, 760, 10, 20)&&mouseState==AN_PRESS&&colorPress==0) {
    sR=true;
    if (autorun_infinite) autorun_infinite=false;
    else autorun_infinite=true;
    colorPress=-10;
  }
  fill(0);
  if (R&&autorun_infinite)text("∞", 1070, 768);
}

//manuals


void DS_displayMode() {//UI_display tutorial
  if (isMouseIsPressed(700, 420, 200, 160)&&modePress==1) modePress=1;
  if (colorPress==0&&(isMouseIsPressed(910, 550, 30, 30)||isMouseIsPressed(900, 550, 10, 120)||(isMouseIsOn(700, 540, 200, 160)&&modePress==1))) {
    sR=true;
    if (mouseState==AN_RELEASE) {
      int a=floor((mouseY/scale-540)/40);
      if (a==DEFAULT) {
        Log="Mode : default";
        Mode=DEFAULT;
      } else if (a==AUTOINPUT) {
        Log="Mode : autoinput";
        Mode=AUTOINPUT;
      } else if (a==CHAINMODE) {
        Log="Mode : chainmode";
        Mode=CHAINMODE;
      } else if (a==AUTOPLAY) {
        Log="Mode : autoplay";
        Mode=AUTOPLAY;
      }
    }
    modePress=1;
  } else {
    if (modePress==-1) sR=true;
    if (mousePressed==false)modePress=0;
  }
}
void DS_displayManuals() {
  if (isMouseIsOn(960, 550, 30, 30)&&colorPress==0&&velocityPress==0) sR=true;
  if (isMouseIsOn(1010, 550, 30, 30)&&colorPress==0&&velocityPress==0) sR=true;
  if (isMouseIsOn(1060, 550, 30, 30)&&colorPress==0&&velocityPress==0) sR=true;
}
void saveDisplayText() {
  RecordLog();
  AD_clearMemory();
  if (Tab==TAB_LED) {
    Str_LED=display.getText();
  } else if (Tab==TAB_KEYSOUND) {
    Str_Sound=display.getText();
  } else if (Tab==TAB_INFO) { 
    Str_Info=display.getText();
  } else if (Tab==TAB_WAVCUTTER) {
    Str_WavCut=display.getText();
  }
}
void displayTab() {
  if (isMouseIsOn(1100, 0, 50, 120)&&mouseState==AN_RELEASE&&colorPress==20) {
    saveDisplayText();
    Tab=TAB_LED;
    display.setText(Str_LED);
    RecordLog();
    readFrame();
  } else if (isMouseIsOn(1100, 120, 50, 140)&&mouseState==AN_RELEASE&&colorPress==20) {
    saveDisplayText();
    Tab=TAB_KEYSOUND;
    display.setText(Str_Sound);
    readFrame();
    EX_listFiles(fileViewDir);
    RecordLog();
  } else if (isMouseIsOn(1100, 260, 50, 100)&&mouseState==AN_RELEASE&&colorPress==20) {
    saveDisplayText();
    Tab=TAB_INFO;
    display.setText(Str_Info);
    RecordLog();
  } else if (isMouseIsOn(1100, 360, 50, 120)&&mouseState==AN_RELEASE&&colorPress==20) {
    saveDisplayText();
    Tab=TAB_WAVCUTTER;
    display.setText(Str_WavCut);
    RecordLog();
  } else if (isMouseIsOn(1100, 480, 50, 120)&&mouseState==AN_RELEASE&&colorPress==20) {
    saveDisplayText();
    Tab=TAB_SETTINGS;
    colorPress=20;
  } else if (isMouseIsOn(1100, 600, 50, 100)&&mouseState==AN_RELEASE&&colorPress==20) {
    saveDisplayText();
    Tab=TAB_MACROS;
    colorPress=20;
  }
  if (isMouseIsOn(1100, 0, 50, 700)&&mouseState==AN_PRESS)colorPress=20;
}
File[] View=new File[0];
String fileViewDir=sketchPath();
int SelectedFile=-1;
int FV_sliderPos=0;
int FV_sliderLength=480;
void FileView(int hei) {//hei is 480
  int select=-1;
  int a=0;
  if (R) {
    fill(255);
    rect(900, 0, 200, 520);
    textSize(20);
    textAlign(LEFT, CENTER);
    if (FV_sliderPos<=30) {
      noFill();
      rect(900, 40-FV_sliderPos, 180, 30);
      fill(0);
      text("/...", 910, 55-FV_sliderPos);
    }
    while (a<View.length) {
      if (10<=70+30*a-FV_sliderPos&&70+30*a-FV_sliderPos<520) {
        noFill();
        rect(900, min(70+30*a-FV_sliderPos, 520), 180, min(30, 450-30*a+FV_sliderPos));
        fill(0);
        if (View[a].isDirectory())text("/"+View[a].getName(), 910, 85+30*a-FV_sliderPos);
        else text(View[a].getName(), 910, 85+30*a-FV_sliderPos);
      }
      a=a+1;
    }
    if (SelectedFile>=0&&40<=70+SelectedFile*30-FV_sliderPos&&70+SelectedFile*30-FV_sliderPos<520) {
      fill(0, 120);
      rect(900, min(70+SelectedFile*30-FV_sliderPos, 520), 180, min(30, 450-SelectedFile*30+FV_sliderPos));
    }
    textAlign(CENTER, CENTER);
  }
  if (isMouseIsOn(900, 40, 180, 480)) {
    Focus=VIEW_FILEVIEW;
    select=floor((mouseY/scale-40+FV_sliderPos)/30);
    if (mouseState==AN_PRESS)colorPress=1000+select;//---------------------------code=1000
    sR=true;
    if (R&&select-1<View.length) {
      fill(0, 90);
      rect(900, 40+select*30-FV_sliderPos, 180, 30);
      if (select-1>=0) {
        fill(255, 200);
        int len=floor(4+textWidth(View[select-1].getName()));
        rect(900-len, 40+select*30-FV_sliderPos, len, 30);
        fill(0);
        text(View[select-1].getName(), 900-len/2, 55+select*30-FV_sliderPos);
      }
    }
    if (select+1000==colorPress) {
      if (mouseState==AN_RELEASE) {
        if (select==0) {
          String[] tokens;
          boolean left=false;
          if (fileViewDir.contains("\\")) {
            tokens=split(fileViewDir, "\\");
            left=true;
          } else tokens=split(fileViewDir, "/");
          a=1;
          fileViewDir=tokens[0];
          while (a<tokens.length-1) {
            if (left)fileViewDir=fileViewDir+"\\"+tokens[a];
            else fileViewDir=fileViewDir+"/"+tokens[a];
            a=a+1;
          }
          if (left)tokens=split(fileViewDir, "\\");
          else tokens=split(fileViewDir, "/");
          if (tokens.length<=1||tokens[1].equals("")) {
            if (left)fileViewDir=fileViewDir+"\\";
            else fileViewDir=fileViewDir+"/";
          }
          SelectedFile=-1;
          FV_sliderPos=0;
          EX_listFiles(fileViewDir);
        }
      } else if (mouseState==AN_PRESS) {
        if (select-1<View.length&&select!=0) {
          if (View[select-1].isDirectory()) {
            String backup=fileViewDir;
            boolean left=false;
            if (fileViewDir.contains("\\"))left=true;
            if (left)fileViewDir=fileViewDir+"\\"+View[select-1].getName();
            else fileViewDir=fileViewDir+"/"+View[select-1].getName();
            SelectedFile=-1;
            File[] fbackup=View;
            EX_listFiles(fileViewDir);
            if (View==null) {
              fileViewDir=backup;
              View=fbackup;
            } else {
              FV_sliderPos=0;
            }
          } else {
            if (SelectedFile!=select-1)AD_reload=true;
            SelectedFile=select-1;
            SelectedFile2=-1;
          }
        }
      }
    }
  } else {
    if (SelectedFile!=-1&&colorPress==SelectedFile+1001&&mouseState==AN_PRESSED) {
      sR=true;
      fill(255, 200);
      int len=floor(4+textWidth(View[SelectedFile].getName()));
      rect(mouseX/scale-len/2, mouseY/scale-15, len, 30);
      fill(0);
      text(View[SelectedFile].getName(), mouseX/scale, mouseY/scale);
    }
  }
  if (isMouseIsOn(0, 0, 800, 800)&&(mouseState==AN_RELEASE&&SelectedFile!=-1)&&colorPress>=1000) {
    int X=floor(mouseX/scale/100);
    int Y=floor(mouseY/scale/100);
    WriteDisplay("\n"+str(Chain+1)+" "+str(Y+1)+" "+str(X+1)+" \""+View[SelectedFile].getAbsolutePath()+"\"");
    readFrame();
  }
  FV_sliderLength=480;
  if (R) {
    fill(255);
    rect(900, 0, 200, 40);
    fill(0);
    textSize(25);
    text("Files", 1000, 20);
    //slide
    fill(255);
    rect(1080, 40, 20, 480);
    FV_sliderLength=min(480*16/max(16, (View.length+1)), 480);
    rect(1082, 42+FV_sliderPos*16/(View.length+1), 16, max(FV_sliderLength-4, 4));
  }
  if ((isMouseIsPressed(1080, 40, 20, 480)&&colorPress==0)||colorPress==1) {
    sR=true;
    int pos=floor(max(min(mouseY/scale-40-FV_sliderLength/2, 480-FV_sliderLength), 0));//360-sliderLength/2
    FV_sliderPos=30*max((View.length-15), 0)*pos/max((480-FV_sliderLength), 1);
    colorPress=1;
  }
}


void displyPadButtonText() {
  if (R==false)return;
  fill(0);
  textSize(15);
  textLeading(15);
  int a=0;
  while (a<8) {
    int b=0;
    while (b<8) {
      String tow="";
      int c=0;
      int len=getLength(Chain, a, b);
      while (c<len) {
        String txtcut=getFileName(keySound[Chain][a][b][c]);
        if (txtcut.length()>14) txtcut=txtcut.substring(0, 11)+"...";
        tow=tow+txtcut+"\n";
        if (c>3) {
          tow=tow+"...";
          break;
        }
        c=c+1;
      }
      if (tow.equals("")==false)text(tow, a*100+50, b*100+50);
      b=b+1;
    }
    a=a+1;
  }
}

int SelectedFile2=-1;
int FV_sliderPos2=0;
int FV_sliderLength2=480;
void PadButtonView() {
  int select=-1;
  int a=0;
  if (R) {
    fill(255);
    rect(900, 520, 200, 190);
    textSize(20);
    textAlign(LEFT, CENTER);
    while (a<getLength(Chain, Xpos, Ypos)) {
      if (530<=560+30*a-FV_sliderPos2&&560+30*a-FV_sliderPos2<740) {
        noFill();
        rect(900, min(560+30*a-FV_sliderPos2, 710), 180, min(30, 670-30*a+FV_sliderPos2));
        fill(0);
        if (keySound[Chain][Xpos][Ypos][a].equals("")==false)text(getFileName(keySound[Chain][Xpos][Ypos][a]), 910, 575+30*a-FV_sliderPos2);
      }
      a=a+1;
    }
    if (SelectedFile2>=0&&-30<=SelectedFile2*30-FV_sliderPos2&&SelectedFile2*30-FV_sliderPos2<180) {
      fill(0, 120);
      rect(900, min(560+SelectedFile2*30-FV_sliderPos2, 710), 180, min(30, 710-SelectedFile2*30+FV_sliderPos2));
    }
    textAlign(CENTER, CENTER);
  }
  if (isMouseIsOn(900, 560, 180, 150)) {
    Focus=VIEW_SOUNDVIEW;
    select=floor((mouseY/scale-560+FV_sliderPos2)/30);
    if (mouseState==AN_PRESS)colorPress=2000+select;//---------------------------code=2000
    sR=true;
    if (R&&select<getLength(Chain, Xpos, Ypos)) {
      fill(0, 90);
      rect(900, 560+select*30-FV_sliderPos, 180, 30);
      if (select>=0) {
        fill(255, 200);
        int len=floor(4+textWidth(getFileName(keySound[Chain][Xpos][Ypos][select])));
        rect(900-len, 560+select*30-FV_sliderPos2, len, 30);
        fill(0);
        text(getFileName(keySound[Chain][Xpos][Ypos][select]), 900-len/2, 575+select*30-FV_sliderPos2);
      }
    }
    if (mouseState==AN_PRESS&&select+2000==colorPress) {
      if (select>=0&&select<getLength(Chain, Xpos, Ypos)) {
        if (SelectedFile2!=select)AD_reload=true;
        SelectedFile=-1;
        SelectedFile2=select;
      }
    }
  } else {
    if (SelectedFile2!=-1&&colorPress==SelectedFile2+2000&&mouseState==AN_PRESSED) {
      sR=true;
      fill(255, 200);
      int len=floor(4+textWidth(getFileName(keySound[Chain][Xpos][Ypos][SelectedFile2])));
      rect(mouseX/scale-len/2, mouseY/scale-15, len, 30);
      fill(0);
      text(getFileName(keySound[Chain][Xpos][Ypos][SelectedFile2]), mouseX/scale, mouseY/scale);
    }
  }
  if (isMouseIsOn(0, 0, 900, 800)&&(mouseState==AN_RELEASE&&SelectedFile2!=-1)&&colorPress>=2000) {
    int linen=LEX_keySound_getLineNum(Chain, Xpos, Ypos, keySound[Chain][Xpos][Ypos][SelectedFile2]);
    if (linen!=-1)deleteLine(linen);
    readFrame();
  }
  FV_sliderLength2=150;
  if (R) {
    fill(255);
    rect(900, 520, 200, 40);
    fill(0);
    textSize(25);
    text("["+str(Chain+1)+" "+str(Xpos+1)+" "+str(Ypos+1)+"]", 1000, 540);
    //slide
    fill(255);
    rect(1080, 560, 20, 150);
    FV_sliderLength2=min(150*5/max(5, (max(getLength(Chain, Xpos, Ypos), 1))), 150);
    rect(1082, 562+FV_sliderPos2*5/(max(getLength(Chain, Xpos, Ypos), 1)), 16, max(FV_sliderLength2-4, 4));
  }
  if ((isMouseIsPressed(1080, 560, 20, 150)&&colorPress==0)||colorPress==2) {
    sR=true;
    int pos=floor(max(min(mouseY/scale-560-FV_sliderLength2/2, 150-FV_sliderLength2), 0));//360-sliderLength/2
    FV_sliderPos2=30*max(getLength(Chain, Xpos, Ypos)-5, 0)*pos/max((150-FV_sliderLength2), 1);
    colorPress=2;
  }
}

void DS_displayFileInfo() {
  boolean canPlay=false;
  if (R) {
    fill(255);
    rect(900, 710, 200, 90);
    textAlign(LEFT, TOP);
    textSize(15);
    fill(0);
  }
  if (SelectedFile2!=-1) {
    String format=getFormat(keySound[Chain][Xpos][Ypos][SelectedFile2]);
    if (R)text("File : "+getFileName(keySound[Chain][Xpos][Ypos][SelectedFile2]), 905, 710);
    if (R)text("Type : "+format, 905, 730);
    if (isPlayable(format)) {
      canPlay=true;
      if (AD_reload) {
        if (isApplyable(keySound[Chain][Xpos][Ypos][SelectedFile2])==false) {
          LogCaution="selected file is not applicable to unipad";
        }
      }
    } else {
      LogCaution="selected file is not applicable to unipad";
    }
  } else if (SelectedFile!=-1) {
    String format=getFormat(View[SelectedFile].getAbsolutePath());
    if (R)text("File : "+View[SelectedFile].getName(), 905, 710);
    if (R)text("Type : "+format, 905, 730);
    if (isPlayable(format)) {
      canPlay=true;
      if (AD_reload) {
        if (isApplyable(View[SelectedFile].getAbsolutePath())==false) {
          LogCaution="selected file is not applicable to unipad";
        }
      }
    } else {
      LogCaution="selected file is not applicable to unipad";
    }
  } else if (AD_playingFileName.equals("")==false) {
    fill(100);
    if (R)text("File : "+AD_playingFileName, 905, 710);
    if (R)text("Type : "+AD_playingFileFormat, 905, 730);
  }
  if (R)textAlign(CENTER, CENTER);
  if (R) {
    fill(255);
    rect(900, 750, 200, 50);
    //play button
    fill(255);
    rect(905, 755, 30, 30);
  }
  AD_looping();
  if (canPlay) {
    if (R) {
      strokeWeight(2);
      fill(115, 225, 120);
      triangle(930, 770, 910, 760, 910, 780);
      strokeWeight(1);
    }
    if (isMouseIsPressed(905, 755, 30, 30)) {
      if (colorPress==0) {
        if (SelectedFile2!=-1) {
          if (AD_reload) {
            AD_loadSample(keySound[Chain][Xpos][Ypos][SelectedFile2]);
            AD_playingFileFormat=getFormat(keySound[Chain][Xpos][Ypos][SelectedFile2]);
            AD_playingFileName=getFileName(keySound[Chain][Xpos][Ypos][SelectedFile2]);
            if (player!=null)AD_playingFileLength=player.length();
          }
          AD_play();
        } else if (SelectedFile!=-1) {
          if (AD_reload) {
            AD_loadSample(View[SelectedFile].getAbsolutePath());
            AD_playingFileFormat=getFormat(View[SelectedFile].getAbsolutePath());
            AD_playingFileName=View[SelectedFile].getName();
            if (player!=null)AD_playingFileLength=player.length();
          } 
          AD_play();
        }
        colorPress=-18;
      }
    }
  }
  if (R) {
    //stop button
    fill(255);
    rect(940, 755, 30, 30);
    strokeWeight(2);
    fill(1208, 140, 140);
    rect(945, 760, 20, 20);
  }
  if (isMouseIsPressed(940, 755, 30, 30)) {
    if (colorPress==0) {
      AD_pause();
      colorPress=-19;
    }
  }
  if (R) {
    //play slider
    fill(255);
    strokeWeight(2);
    line(980, 770, 1055, 770);
    strokeWeight(1);
    if (colorPress==-20) rect(max(min(mouseX/scale, 1055), 980)-5, 770-15, 10, 30);
    else if (player!=null)rect(980+75*player.position()/AD_playingFileLength-5, 770-15, 10, 30);
  }
  if ((isMouseIsOn(975, 755, 85, 30)&&colorPress==0)||colorPress==-20) {
    if (mouseState==AN_RELEASE) {
      setPosition(0, 75, floor(max(min(mouseX/scale-980, 75), 0)));
    }
    colorPress=-20;
  }
  if (R) {
    //infinite button
    fill(255);
    rect(1065, 755, 30, 30);
    strokeWeight(2);
    if (AD_loop)fill(0);
    else fill(150);
    text("∞", 1080, 770);
    strokeWeight(1);
  }
  if (isMouseIsPressed(1065, 755, 30, 30)) {
    if (colorPress==0) {
      if (AD_loop)AD_loop=false;
      else AD_loop=true;
      colorPress=-21;
    }
  }
}