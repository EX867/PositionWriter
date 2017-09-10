boolean isMouseIsOn(int x, int y, int w, int h) {
  if ((x*scale<mouseX)&&(mouseX<(x+w)*scale)&&(y*scale<mouseY)&&(mouseY<(y+h)*scale))return true;
  return false;
}
boolean isMouseIsPressed(int x, int y, int w, int h) {
  if (mousePressed==true&&mouseButton==LEFT&&(x*scale<mouseX)&&(mouseX<(x+w)*scale)&&(y*scale<mouseY)&&(mouseY<(y+h)*scale)) {
    sR=true;
    return true;
  }
  return false;
}
/*Positioning globals*/
int Chain=0;
int X=0;
int Y=0;
float Bpm=0;

/* Color globals */
int cR=255;
int cG=255;
int cB=255;
int colorMode=0;//0 : rgb 1 : hsb
color[] recentColor=new color[10];
//only work in autoinput mode
boolean selectedHorV;//true==HTML false==velocity
int selectedHTML;//recentColor index
int selectedVelocity;

/* Exception globals */
//pressing exception
int colorPress=0; //-3 : fontslider,velocity -2 : recentcolor -1~3 : colorSliders -8 : play -9 : pause
int velocityPress=0;//1 : velocity
int modePress=0;
boolean modeClicked=false;

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
  }
  if (colorPress==0&&velocityPress==0&&modePress==0) {//mousepress exception for position button!
    int X=mouseX/100;
    int Y=mouseY/100;
    if (X<8&&Y<8) {//press pad
      if (mouseState==1||mouseState==2)sR=true;//for indicator update
      if (R&&(mouseState==2||mouseState==3)) {//draw Marker
        fill(0, 70);
        rect(100*X, 0, 100, 800);
        rect(0, 100*Y, 800, 100);
        if (Mode==CHAINMODE)LogTemp="Chain "+str(Chain+1)+" ( "+str(X+1)+", "+str(Y+1)+")";
        else LogTemp="( "+str(X+1)+", "+str(Y+1)+")";
      }
      if (mouseState==3) {//when release
        sR=true;
        if (Mode==DEFAULT) {
          Log=str(X+1)+", "+str(Y+1);
          WriteDisplay(" "+str(Y+1)+" "+str(X+1));
        } else if (Mode==AUTOINPUT) {//on y x if(sel==html){ selectedC | auto selectedV }
          Log=str(X+1)+", "+str(Y+1);  
          if (isLastOff(X, Y)||(key!=ALT&&keyPressed)) {//last add
            if (selectedHorV==DS_HTML)WriteDisplay("\non "+str(Y+1)+" "+str(X+1)+" "+hex((recentColor[selectedHTML]>>16)&0xFF, 2)+hex((recentColor[selectedHTML]>>8)&0xFF, 2)+hex((recentColor[selectedHTML]&0xFF), 2));
            else WriteDisplay("\non "+str(Y+1)+" "+str(X+1)+" auto "+selectedVelocity);
          } else {
            WriteDisplay("\noff "+str(Y+1)+" "+str(X+1));
          }
        } else if (Mode==CHAINMODE) {//on y x
          Log=str(X+1)+", "+str(Y+1);
          WriteDisplay("\n"+str(Chain+1)+" "+str(Y+1)+" "+str(X+1));
        } else if (Mode==AUTOPLAY) {//on y x
          Log=str(X+1)+", "+str(Y+1);
          WriteDisplay("\non "+str(Y+1)+" "+str(X+1));
        }
      }
    }
    if (X==8&&Y<8) {//press chain
      if (mouseState==1||mouseState==2)sR=true;
      if (R&&(mouseState==2||mouseState==3)) {//draw marker
        fill(0, 100);
        rect(800, 100*Y, 100, 100);
        if (Mode==CHAINMODE) {
          LogTemp=str(Chain+1);
        }
      }
      if (mouseState==3) {//when release
        sR=true;
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
      }
    }
  }
  if (R&&Mode==CHAINMODE) {
    fill(225);
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

void IM_colorImage() {
  colorMode(HSB, 180, 180, 180);
  int a=0;
  while (a<90) {
    stroke(a*2, 180, 180);
    fill(a*2, 180, 180);
    rect(910+a*2, 200, 2, 20);
    a=a+1;
  }
  a=0;
  int b=0;
  while (a<18) {
    b=0;
    while (b<18) {
      colorMode(RGB, 255, 255, 255);
      color tmp=color(cR, cG, cB);
      colorMode(HSB, 180, 180, 180);
      stroke(hue(tmp), a*10, 180-b*10);
      fill(hue(tmp), a*10, 180-b*10);
      rect(910+a*10, 10+b*10, 10, 10);
      b=b+1;
    }
    a=a+1;
  }
  //colorMode(ARGB, 255, 255, 255, 255);
  colorMode(RGB, 255, 255, 255);
}
void UI_colorPanel() {
  if (R) {
    //control panel
    rect(905, 0, 200, 700);

    //color image
    IM_colorImage();
    stroke(0);
    noFill();
    rect(910, 10, 180, 180);
    rect(910, 200, 180, 20);
    ellipse(910+saturation(color(cR, cG, cB))*180/255, 190-(brightness(color(cR, cG, cB)))*180/255, 7, 7);
    rect(910+hue(color(cR, cG, cB))*180/255-3, 200-2, 6, 24);

    //color info
    textSize(25);
    fill(0);
    if (colorMode==0) {//color mode text
      text("R", 925, 248);//910 210
      text("G", 925, 278);
      text("B", 925, 308);
    } else {
      text("H", 925, 248);//910 210
      text("S", 925, 278);
      text("B", 925, 308);
    }
    fill(255);
    strokeWeight(2);
    line(940, 250, 1090, 250);//slider
    line(940, 280, 1090, 280);
    line(940, 310, 1090, 310);
    strokeWeight(1);
    rect(940+150*(float(cR)/256)-5, 240, 10, 20);//slider holder
    rect(940+150*(float(cG)/256)-5, 270, 10, 20);
    rect(940+150*(float(cB)/256)-5, 300, 10, 20);
    rect(910, 335, 10, 20);
    rect(930, 335, 45, 20);//color value rect
    rect(990, 335, 45, 20);
    rect(1050, 335, 45, 20);
    fill(0);
    textSize(20);
    text(str(cR), 952, 343);//color value text
    text(str(cG), 1012, 343);
    text(str(cB), 1072, 343);
    fill(255);//fill(225);-after hsb update
    if (colorMode==0) rect(910, 335, 10, 10);
    else rect(910, 345, 10, 10);
  }
}

void UI_recentColors() {//recent colors view
  strokeWeight(1);
  int a=0;
  while (a<10) {
    if (isMouseIsPressed(a*35-175*floor(a/5)+910, 35*floor(a/5)+365, 30, 30)) {//old method yet. please modify to new algorithm!
      sR=true;
      if (R) {
        fill(225);
        rect(a*35-175*floor(a/5)+910, 35*floor(a/5)+365, 30, 30);
      }
      if (colorPress==0) {
        Log=hex((recentColor[a]>>16)&0xFF, 2)+hex((recentColor[a]>>8)&0xFF, 2)+hex((recentColor[a]&0xFF), 2);
        if (Mode==DEFAULT) {
          WriteDisplay(" "+Log);
          display.setText(LogFull);
          if (changed==false) {
            if (loaded==false)surface.setTitle("PositionWriter 1.4.3 - new file*");
            else surface.setTitle("PositionWriter 1.4.3 - "+currentFileName+"*");
          }
          changed=true;
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
    } else if (R) {
      fill(recentColor[a]);
      rect(a*35-175*floor(a/5)+910, 35*floor(a/5)+365, 30, 30);
    }
    textSize(25);
    a=a+1;
  }
  recentColor[0]=color(cR, cG, cB);
  if (R) {
    fill(cR, cG, cB);
    rect(912, 367, 26, 26);
  }
  if (R&&Mode==AUTOINPUT&&selectedHorV==DS_HTML) {
    drawIndicator(selectedHTML*35-175*floor(selectedHTML/5)+910, 35*floor(selectedHTML/5)+365, 30, 30, 6);
  }
  strokeWeight(1);
  a=0;
  while (a<10) {
    if (isMouseIsOn(a*35-175*floor(a/5)+910, 35*floor(a/5)+360, 30, 30)) {
      sR=true;
      textSize(15);
      if (a/5==0) {//upper
        fill(255, 200);
        rect(a*35-175*floor(a/5)+830, 35*floor(a/5)+403, 140, 25);
        fill(0);
        text("("+red(recentColor[a])+", "+green(recentColor[a])+", "+blue(recentColor[a])+")", a*35-175*floor(a/5)+900, 35*floor(a/5)+415);
      } else {
        fill(255, 200);
        rect(a*35-175*floor(a/5)+830, 35*floor(a/5)+333, 140, 25);
        fill(0);
        text("("+red(recentColor[a])+", "+green(recentColor[a])+", "+blue(recentColor[a])+")", a*35-175*floor(a/5)+900, 35*floor(a/5)+345);
      }
      fill(recentColor[a]);
      rect(a*35-175*floor(a/5)+910, 35*floor(a/5)+365, 30, 30);
    } 
    a=a+1;
  }
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
  } else {
    if (colorPress!=0&&mousePressed==false) colorPress=0;
  }
}

//what is this???
//a=0;
//while (a <128) {
//  fill (color (k [a]));
//  rect(x+((a%16)*((float)w/16)), y+(round (a/16)*((float)h/8)), ((float)w/16), ((float)h/8));
//  a=a+1;
//}

//utils

void DS_displayVelocity() {
  int a;
  if (isMouseIsPressed(300, 240, 600, 300)&&velocityPress==1&&colorPress==0) {
    a=floor(((mouseY/scale)-240)*8/300)*16+floor(((mouseX/scale)-300)*16/600);
    colorPress=-3;
    Log=str(a);
    selectedVelocity=a;
    selectedHorV=DS_VEL;
    if (Mode==DEFAULT) {
      WriteDisplay(" "+Log);
    }
  }
  if (R) {
    drawVel(900, 440, 200, 100);//small vel
    if (Mode==AUTOINPUT&&selectedHorV==DS_VEL)drawIndicator(900+(selectedVelocity%16)*200/16, 440+(selectedVelocity/16)*100/8, 200/16, 100/8, 4);
  }
  if (((900*scale<mouseX)&&(mouseX<1100*scale)&&(440*scale<mouseY)&&(mouseY<540*scale))||(velocityPress==1&&(300*scale<mouseX)&&(mouseX<900*scale)&&(240*scale<mouseY)&&(mouseY<540*scale))) {
    sR=true;
    strokeWeight(1);
    if (R)drawVel(300, 240, 600, 300);//big vel
    if (R&&Mode==AUTOINPUT&&selectedHorV==DS_VEL) drawIndicator(300+(selectedVelocity%16)*600/16, 240+(selectedVelocity/16)*300/8, 600/16, 300/8, 8);
    velocityPress=1;
  } else {
    if (velocityPress==1) sR=true;
    velocityPress=0;
  }
}

void DS_font() {
  //12 15 20 25
  if (R) {
    fill(255);
    strokeWeight(2);
    line(910, 730, 1090, 730);
    strokeWeight(1);
    rect(910+180*(float(fontSize)/3)-5, 720, 10, 20);
  }
  if ((isMouseIsPressed(900, 720, 200, 20)&&colorPress==0) || (mousePressed&&colorPress==-3) &&velocityPress==0) {
    sR=true;
    fontSize=floor((/*float*/((mouseX/scale)-910)*3)/180);
    if (fontSize<0) fontSize=0;
    if (fontSize>3) fontSize=3;
    if (fontSize==0) {
      display.setFont(font12);
      display.setColumns(40);
      display.setRows(48);
    } else if (fontSize==1) {
      display.setFont(font15);
      display.setColumns(40);
      display.setRows(36);
    } else if (fontSize==2) {
      display.setFont(font20);
      display.setColumns(30);
      display.setRows(32);
    } else if (fontSize==3) {
      display.setFont(font25);
      display.setColumns(24);
      display.setRows(27);
    } else fontSize=1;
    colorPress=-3;
  }
  line(910, 720, 910, 740);
  line(970, 720, 970, 740);
  line(1030, 720, 1030, 740);
  line(1090, 720, 1090, 740);
}

void DS_language() {//MODIFY!!!!
  if (R) {
    fill(235);
    rect(1050, 800, 50, 40);
    fill(255);
    rect(1080, 810, 10, 20);
    fill(225);
    if (Language==LC_ENG) rect(1080, 810, 10, 10);
    else rect(1080, 820, 10, 10);
  }
  if (isMouseIsPressed(1080, 810, 10, 20)&&mouseState==1&&colorPress==0) {
    tR=true;
    sR=true;
    if (Language==LC_ENG) Language=1;
    else Language=0;
    colorPress=-10;
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
  if (isMouseIsPressed(1060, 810, 10, 20)&&mouseState==1&&colorPress==0) {
    tR=true;
    sR=true;
    if (inFrameInput) inFrameInput=false;
    else inFrameInput=true;
    colorPress=-10;
  }
}

void DS_infinite() {//MODIFY!!!!
  if (R) {
    fill(255);
    rect(1060, 760, 20, 20);
    rect(1080, 760, 10, 20);
    fill(225);
    if (autorun_infinite) rect(1080, 760, 10, 10);
    else rect(1080, 770, 10, 10);
  }
  if (isMouseIsPressed(1080, 760, 10, 20)&&mouseState==1&&colorPress==0) {
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
  fill(255);
  if (R)rect(910, 550, 30, 30);
  fill(0);
  textSize(25);
  /*if (isMouseIsPressed(700, 420, 200, 160)&&modePress==1) {
   modePress=1;
   }*/
  if (colorPress==0&&isMouseIsPressed(910, 550, 30, 30)&&mouseState==1) {
    // duplicate no focus check!
    modeClicked=true;
    sR=true;
  }
  if (modeClicked) {
    sR=true;
    if (R) {
      fill(255);
      rect(700, 540, 200, 160);
      line(700, 580, 900, 580);
      line(700, 620, 900, 620);
      line(700, 660, 900, 660);
      fill(0);
      text("default", 800, 555);
      text("autoInput", 800, 595);
      text("chainMode", 800, 635);
      text("autoPlay", 800, 675);
    }
    if (isMouseIsOn(700, 540, 200, 160)) {
      if (mouseState==2||mouseState==1) {
        int a=floor((mouseY-540)/40);
        fill(0, 100);
        rect(700, 540+a*40, 200, 40);
      }
      if (mouseState==3) {
        int a=floor((mouseY-540)/40);
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
    }
    modePress=1;
  } else {
    if (modePress==-1) sR=true;
    if (mousePressed==false)modePress=0;
    if (R)text("M", 925, 565);
  }
  if (mousePressed==false) {
    modeClicked=false;
  }
  if (R) {
    textSize(20);
    fill(255);
    rect(910, 590, 110, 25);
    fill(0);
    if (Mode==DEFAULT)text("default", 964, 600);
    if (Mode==AUTOINPUT)text("autoInput", 964, 600);
    if (Mode==CHAINMODE)text("chainMode", 964, 600);
    if (Mode==AUTOPLAY)text("autoPlay", 964, 600);
  }
}

void DS_displayTutorial() {//UI_display tutorial
  fill(255);
  if (R)rect(960, 550, 30, 30);
  fill(0);
  textSize(20);
  if (isMouseIsOn(960, 550, 30, 30)&&colorPress==0&&velocityPress==0) {
    sR=true;
    if (R) {
      fill(255, 170);
      rect(0, 0, width, height);
      fill(0);
      stroke(0, 200, 0);
      text("Here is Position button", 400, 400);//padsize/2
      text("Mode", 925, 565);
      text("Tutorial, help, \nshortcuts", 1015, 565);
      text("Log", 540, 820);
      text("select html", 990, 270);
      text("recent used\nhtml color", 1000, 400);
      text("velocity", 1000, 490);
      text("frame slider", 1000, 640);
      text("led test", 1000, 680);
      text("text size", 1000, 730);
      text("led test loop", 1000, 768);
      text("print in frame, language", 940, 810);
    }
  } else {
    if (R)text("T", 975, 565);
  }
}

void DS_displayManual() {//UI_display manual
  fill(255);
  if (R)rect(1010, 550, 30, 30);
  fill(0);
  textSize(25);
  if (isMouseIsOn(1010, 550, 30, 30)&&colorPress==0&&velocityPress==0) {
    sR=true;
    if (R) {
      fill(255, 200);
      rect(50, 50, 1000, 700);
      fill(0);
      textAlign(LEFT, CENTER);
      if (Language==LC_KOR) text("<문법>\n// : 주석\n*on [on y x html][on y x auto vel][on y x html vel][on y x vel]\n    led를 켠다\n*off [off y x]\n    led를 끈다\n*delay [delay 시간][delay 분자/분모]\n    위의 문구들과 아래의 문구들의 시간 격차.\n    분수는 bpm에 맞춘 박자를 의미하며,[bpm value]가 위로 하나라도 있어야한다.\n*filename [filename chain y x loop][filename chain y x loop 옵션]\n    파일제목을 지정해준다.순서와 상관없이 샐행된다.\n    옵션은 \"L-R\",\"U-\"D,\"180-R\",\"180-L\",\"90-L\",\"Y-X\",\"Y=-X\"\n    과 좌표출력기 대칭기에서 사용하였던 1-7 숫자가 사용 가능하다.\n*bpm [bpm 숫자]\n    아래의 문구들에 대해 bpm을 지정해준다. [delay 시간]은 영향을 받지 않는다.\n", 80, 400);
      else text("<Expressions>\n// : comment\n*on [on y x html][on y x auto vel][on y x html vel][on y x vel]\n    turn on led\n*off [off y x]\n   turn off led\n*delay [delay time][delay num/den]\n    delay between expressions in up and down.\n    num/den syncs with bpm, requires [bpm value] above.\n*filename [filename chain y x loop][filename chain y x loop option]\n    export led with filename. it is not relative with sequence.\n    options can be : \"L-R\",\"U-\"D,\"180-R\",\"180-L\",\"90-L\",\"Y-X\",\"Y=-X\" \n    and numbers 1-7 used in PositionWriter-Converter.\n*bpm [bpm value]\n    set bpm for expressions below. it is not nessessary for [delay time].\n", 80, 400);
      textAlign(CENTER, CENTER);
    }
  } else {
    if (R)text("H", 1025, 565);
  }
}

void DS_displayShortcuts() {//UI_display shortcuts
  fill(255);
  if (R)rect(1060, 550, 30, 30);
  fill(0);
  textSize(18);
  if (isMouseIsOn(1060, 550, 30, 30)&&colorPress==0&&velocityPress==0) {
    sR=true;
    if (R) {
      fill(255, 200);
      rect(50, 50, 1000, 700);
      fill(0);
      if (Language==LC_KOR)text("<단축키>\n"+ON+" : 줄바꾸고 \"on\"\n"+OFF+" : 줄바꾸고 \"off\"\n"+DELAY+" : 줄바꾸고 \"delay\"\n"+AUTO+" : 한칸띄고 \"auto\"\n"+FILENAME+" : 줄바꾸고 \"filename\"\n"+BPM+" : 줄바꾸고 \"bpm\"\nENTER : 줄바꿈\nBACKSPACE : 한칸 지우기\nCTRL+R : 화면 강제 동기화\nCTRL+D : 텍스트 에디터 열기(기본 열려있음)\nCTRL+F : 찾기 바꾸기\nSHIFT+숫자 : 숫자 입력\nCTRL+숫자(1~6) : 최근 사용한 html 색 입력\nALT+RGB 슬라이더 : 색상 슬라이더 미세조정\nCTRL+e : 파일로 출력하기\nCTRL+z : 되돌리기\nCTRL+y : 다시하기\n<,> : 이전 프레임, 다음 프레임 보기\n[]{}(AutoInput모드만 사용가능) : 색 선택\n/ : / 출력('/' 다음에는 shift+숫자는 빈칸없이 출력됩니다.)\nSPACE : led 테스트\np 또는 P : led 테스트 멈추기", 550, 400);
      else text("<shortcuts>\n"+ON+" : change line and print \"on\"\n"+OFF+" : change line and print \"off\"\n"+DELAY+" : change line and print \"delay\"\n"+AUTO+" : print space and \"auto\"\n"+FILENAME+" : change line and print \"filename\"\n"+BPM+" : change line and print \"bpm\"\nENTER : change line\nBACKSPACE : erase one character\nCTRL+R : screen refresh\nCTRL+D : open text editor\nCTRL+F : open find replace window\nSHIFT+number : print number\nCTRL+number(1~6) : print recent used html color\nALT+RGB slider : slider fine tuning\nCTRL+e : export to text\nCTRL+z : undo\nCTRL+y : redo\n<,> : previous frame,next frame\n[]{}(AutoInput only) : move selected color\n/ : print /(next to '/' shift+number will print no space.)\nSPACE : led preview\np or P : stop led preview", 550, 400);
    }
  } else {
    if (R)text("S", 1075, 565);
  }
}