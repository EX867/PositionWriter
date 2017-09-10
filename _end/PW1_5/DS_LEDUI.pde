void drawAutorunQuad() {
  fill(0);
  stroke(0);
  quad(385, 400, 400, 385, 415, 400, 400, 415);
  fill(205);
  stroke(205);
  quad(385, 399, 399, 385, 399, 380, 380, 399);
  quad(401, 380, 401, 385, 415, 399, 420, 399);
  quad(401, 420, 420, 401, 415, 401, 401, 415);
  quad(385, 401, 380, 401, 399, 420, 399, 415);
  stroke(0);
  line(395, 385, 385, 395);
  line(405, 385, 415, 395);
  line(405, 415, 415, 405);
  line(385, 405, 395, 415);
}
void drawIndicator(int x, int y, int w, int h, int thick) {
  if (R==false)return;
  noFill();
  stroke(255);
  strokeWeight(thick);
  rect(x, y, w, h);
  stroke(0);
  strokeWeight(2);
  rect(x-thick/2, y-thick/2, w+thick, h+thick);
  rect(x+thick/2, y+thick/2, w-thick, h-thick);
}
void drawColorImage() {
  if (R==false)return;
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
  colorMode(RGB, 255, 255, 255);
}
void drawColorPanel() {
  if (R==false)return;
  //control panel
  rect(905, 0, 200, 700);
  //color image
  drawColorImage();
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
void drawRecentColors() {
  if (R==false)return;
  strokeWeight(1);
  int a=0;
  while (a<10) {
    if (isMouseIsPressed(a*35-175*floor(a/5)+910, 35*floor(a/5)+365, 30, 30)) {
      fill(225);
      rect(a*35-175*floor(a/5)+910, 35*floor(a/5)+365, 30, 30);
    }
    fill(recentColor[a]);
    rect(a*35-175*floor(a/5)+910, 35*floor(a/5)+365, 30, 30);
    a=a+1;
  }
  fill(cR, cG, cB);
  rect(912, 367, 26, 26);
  textSize(25);
  if (Mode==AUTOINPUT&&selectedHorV==DS_HTML) drawIndicator(selectedHTML*35-175*floor(selectedHTML/5)+910, 35*floor(selectedHTML/5)+365, 30, 30, 6);
  strokeWeight(1);
  textSize(15);
  a=0;
  while (a<10) {
    if (isMouseIsOn(a*35-175*floor(a/5)+910, 35*floor(a/5)+360, 30, 30)) {
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
void drawVel (int x, int y, int w, int h) {
  if (R==false)return;
  int a=0;
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
void drawVelocity() {
  drawVel(900, 440, 200, 100);//small vel
  if (Mode==AUTOINPUT&&selectedHorV==DS_VEL)drawIndicator(900+(selectedVelocity%16)*200/16, 440+(selectedVelocity/16)*100/8, 200/16, 100/8, 4);
  strokeWeight(1);
  if (isMouseIsOn(900, 440, 200, 100)||(isMouseIsOn(300, 240, 600, 300)&&velocityPress==1)) {
    drawVel(300, 240, 600, 300);//big vel
    if (Mode==AUTOINPUT&&selectedHorV==DS_VEL) drawIndicator(300+(selectedVelocity%16)*600/16, 240+(selectedVelocity/16)*300/8, 600/16, 300/8, 8);
  }
  strokeWeight(1);
}
//manuals
void drawManuals() {
  if (R==false)return;
  fill(255);
  rect(1010, 550, 30, 30);
  rect(1060, 550, 30, 30);
  rect(960, 550, 30, 30);
  fill(0);
  textSize(25);
  if (isMouseIsOn(1010, 550, 30, 30)&&colorPress==0&&velocityPress==0) {
    fill(255, 200);
    rect(50, 50, 1000, 700);
    fill(0);
    textAlign(LEFT, CENTER);
    if (Language==LC_KOR) text("<문법>\n// : 주석\n*on [on y x html][on y x auto vel][on y x html vel][on y x vel]\n    led를 켠다\n*off [off y x]\n    led를 끈다\n*delay [delay 시간][delay 분자/분모]\n    위의 문구들과 아래의 문구들의 시간 격차.\n    분수는 bpm에 맞춘 박자를 의미하며,[bpm value]가 위로 하나라도 있어야한다.\n*filename [filename chain y x loop][filename chain y x loop 옵션]\n    파일제목을 지정해준다.순서와 상관없이 샐행된다.\n    옵션은 \"L-R\",\"U-\"D,\"180-R\",\"180-L\",\"90-L\",\"Y-X\",\"Y=-X\"\n    과 좌표출력기 대칭기에서 사용하였던 1-7 숫자가 사용 가능하다.\n*bpm [bpm 숫자]\n    아래의 문구들에 대해 bpm을 지정해준다. [delay 시간]은 영향을 받지 않는다.\n", 80, 400);
    else text("<Expressions>\n// : comment\n*on [on y x html][on y x auto vel][on y x html vel][on y x vel]\n    turn on led\n*off [off y x]\n   turn off led\n*delay [delay time][delay num/den]\n    delay between expressions in up and down.\n    num/den syncs with bpm, requires [bpm value] above.\n*filename [filename chain y x loop][filename chain y x loop option]\n    export led with filename. it is not relative with sequence.\n    options can be : \"L-R\",\"U-\"D,\"180-R\",\"180-L\",\"90-L\",\"Y-X\",\"Y=-X\" \n    and numbers 1-7 used in PositionWriter-Converter.\n*bpm [bpm value]\n    set bpm for expressions below. it is not nessessary for [delay time].\n", 80, 400);
    textAlign(CENTER, CENTER);
  } else {
    textSize(25);
    text("E", 1025, 565);
  }
  //SHORTCUTS
  fill(0);
  textSize(18);
  if (isMouseIsOn(1060, 550, 30, 30)&&colorPress==0&&velocityPress==0) {
    fill(255, 200);
    rect(50, 50, 1000, 700);
    fill(0);
    if (Language==LC_KOR)text("<단축키>\n"+ON+" : 줄바꾸고 \"on\"\n"+OFF+" : 줄바꾸고 \"off\"\n"+DELAY+" : 줄바꾸고 \"delay\"\n"+AUTO+" : 한칸띄고 \"auto\"\n"+FILENAME+" : 줄바꾸고 \"filename\"\n"+BPM+" : 줄바꾸고 \"bpm\"\nENTER : 줄바꿈\nBACKSPACE : 한칸 지우기\nCTRL+R : 화면 강제 동기화\nCTRL+D : 텍스트 에디터 열기(기본 열려있음)\nCTRL+F : 찾기 바꾸기\nSHIFT+숫자 : 숫자 입력\nCTRL+숫자(1~6) : 최근 사용한 html 색 입력\nALT+RGB 슬라이더 : 색상 슬라이더 미세조정\nCTRL+e : 파일로 출력하기\nCTRL+z : 되돌리기\nCTRL+y : 다시하기\n<,> : 이전 프레임, 다음 프레임 보기\n[]{}(AutoInput모드만 사용가능) : 색 선택\n/ : / 출력('/' 다음에는 shift+숫자는 빈칸없이 출력됩니다.)\nSPACE : led 테스트\np 또는 P : led 테스트 멈추기", 550, 400);
    else text("<shortcuts>\n"+ON+" : change line and print \"on\"\n"+OFF+" : change line and print \"off\"\n"+DELAY+" : change line and print \"delay\"\n"+AUTO+" : print space and \"auto\"\n"+FILENAME+" : change line and print \"filename\"\n"+BPM+" : change line and print \"bpm\"\nENTER : change line\nBACKSPACE : erase one character\nCTRL+R : screen refresh\nCTRL+D : open text editor\nCTRL+F : open find replace window\nSHIFT+number : print number\nCTRL+number(1~6) : print recent used html color\nALT+RGB slider : slider fine tuning\nCTRL+e : export to text\nCTRL+z : undo\nCTRL+y : redo\n<,> : previous frame,next frame\n[]{}(AutoInput only) : move selected color\n/ : print /(next to '/' shift+number will print no space.)\nSPACE : led preview\np or P : stop led preview", 550, 400);
  } else {
    textSize(25);
    text("S", 1075, 565);
  }
  //TUTORIAL
  fill(0);
  textSize(20);
  if (isMouseIsOn(960, 550, 30, 30)&&colorPress==0&&velocityPress==0) {
    fill(255, 170);
    rect(0, 0, width, height);
    fill(0);
    stroke(0, 200, 0);
    text("Here is Position button", 400, 400);//padsize/2
    text("Mode", 925, 565);
    text("Tutorial, manual, \nshortcuts", 1015, 565);
    text("Log", 540, 820);
    text("select html", 990, 270);
    text("recent used\nhtml color", 1000, 400);
    text("velocity", 1000, 490);
    text("frame slider", 1000, 640);
    text("led test", 1000, 680);
    text("text size", 1000, 730);
    text("led test loop", 1000, 768);
    text("print in frame, language", 940, 810);
  } else {
    textSize(20);
    text("ui", 975, 565);
  }
}
void drawMode() {
  if (R==false)return;
  fill(255);
  rect(910, 550, 30, 30);
  fill(0);
  textSize(25);
  if (colorPress==0&&(isMouseIsPressed(910, 550, 30, 30)||isMouseIsPressed(900, 550, 10, 120)||(isMouseIsOn(700, 540, 200, 160)&&modePress==1))) {
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
    if (mouseState==AN_PRESS||mouseState==AN_PRESSED) {
      fill(0, 100);
      rect(700, 540+floor((mouseY/scale-540)/40)*40, 200, 40);
    }
  } else text("M", 925, 565);
  textSize(20);
  fill(255);
  rect(910, 590, 110, 25);
  fill(0);
  if (Mode==DEFAULT)text("default", 964, 600);
  if (Mode==AUTOINPUT)text("autoInput", 964, 600);
  if (Mode==CHAINMODE)text("chainMode", 964, 600);
  if (Mode==AUTOPLAY)text("autoPlay", 964, 600);
}