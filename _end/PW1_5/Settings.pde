
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
void DS_language() {//SETTINGS
  if (R) {
    fill(235);
    rect(1050, 800, 50, 40);
    fill(255);
    rect(1080, 810, 10, 20);
    fill(225);
    if (Language==LC_ENG) rect(1080, 810, 10, 10);
    else rect(1080, 820, 10, 10);
  }
  if (isMouseIsOn(1080, 810, 10, 20)) {
    sR=true;
    if (R) {
      textSize(15);
      fill(255, 200);
      rect(980, 780, 110, 20);
      fill(0);
      if (Language==LC_ENG)text("language=ENG", 1035, 788);
      else text("language=KOR", 1035, 788);
    }
  }
  if (isMouseIsPressed(1080, 810, 10, 20)&&mouseState==AN_PRESS&&colorPress==0) {
    tR=true;
    sR=true;
    if (Language==LC_ENG) {
      Language=1;
      label.setText("<html>&lt;단축키&gt;<br>"+ON+" : 줄바꾸고 \"on\"<br>"+OFF+" : 줄바꾸고 \"off\"<br>"+DELAY+" : 줄바꾸고 \"delay\"<br>"+AUTO+" : 한칸띄고 \"auto\"<br>"+FILENAME+" : 줄바꾸고 \"filename\"<br>"+BPM+" : 줄바꾸고 \"bpm\"<br>ENTER : 줄바꿈<br>BACKSPACE : 한칸 지우기<br>CTRL+R : 화면 강제 동기화<br>CTRL+D : 텍스트 에디터 열기(기본 열려있음)<br>CTRL+F : 찾기 바꾸기<br>SHIFT+숫자 : 숫자 입력<br>CTRL+숫자(1~6) : 최근 사용한 html 색 입력<br>ALT+RGB 슬라이더 : 색상 슬라이더 미세조정<br>CTRL+e : 파일로 출력하기<br>CTRL+z : 되돌리기<br>CTRL+y : 다시하기<br>&lt;,&gt; : 이전 프레임, 다음 프레임 보기<br>[]{}(AutoInput모드만 사용가능) : 색 선택<br>/ : / 출력('/' 다음에는 shift+숫자는 빈칸없이 출력됩니다.)<br>SPACE : led 테스트<br>p 또는 P : led 테스트 멈추기</html>");
    } else { 
      Language=0;
      label.setText("<html>&lt;shortcuts&gt;<br>"+ON+" : change line and print \"on\"<br>"+OFF+" : change line and print \"off\"<br>"+DELAY+" : change line and print \"delay\"<br>"+AUTO+" : print space and \"auto\"<br>"+FILENAME+" : change line and print \"filename\"<br>"+BPM+" : change line and print \"bpm\"<br>ENTER : change line<br>BACKSPACE : erase one character<br>CTRL+R : screen refresh<br>CTRL+D : open text editor<br>CTRL+F : open find replace window<br>SHIFT+number : print number<br>CTRL+number(1~6) : print recent used html color<br>ALT+RGB slider : slider fine tuning<br>CTRL+e : export to text<br>CTRL+z : undo<br>CTRL+y : redo<br>&lt;,&gt; : previous frame,next frame<br>[]{}(AutoInput only) : move selected color<br>/ : print /(next to '/' shift+number will print no space.)<br>SPACE : led preview<br>p or P : stop led preview</html>");
    }
    colorPress=-10;
  }
}