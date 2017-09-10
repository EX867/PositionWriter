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
int Xpos=0;
int Ypos=0;
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

void drawTab() {
  if (R==false)return;
  fill(255);
  textSize(25);
  rect(1100, 0, 50, 840);
  fill(245);
  rect(1100, 0, 50, 120);
  rect(1100, 120, 50, 140);
  rect(1100, 260, 50, 100);
  rect(1100, 360, 50, 120);
  rect(1100, 480, 50, 120);
  rect(1100, 600, 50, 100);
  pushMatrix();
  translate(1150, 0);
  rotate(radians(90));
  fill(0);
  text("keyLED", 60, 20);
  text("keySound", 190, 20);
  text("info", 310, 20);
  text("wavcut", 420, 20);
  text("settings", 540, 20);
  text("macros", 650, 20);
  if (Tab==TAB_LED) {
    fill(120, 155, 255);
    rect(0, 0, 120, 8);
    fill(205);
    rect(120, 0, 140, 8);
    rect(260, 0, 100, 8);
    rect(360, 0, 120, 8);
    rect(480, 0, 120, 8);
    rect(600, 0, 100, 8);
  } else if (Tab==TAB_KEYSOUND) {
    fill(120, 155, 255);
    rect(120, 0, 140, 8);
    fill(205);
    rect(0, 0, 120, 8);
    rect(260, 0, 100, 8);
    rect(360, 0, 120, 8);
    rect(480, 0, 120, 8);
    rect(600, 0, 100, 8);
  } else if (Tab==TAB_INFO) {
    fill(120, 155, 255);
    rect(260, 0, 100, 8);
    fill(205);
    rect(0, 0, 120, 8);
    rect(120, 0, 140, 8);
    rect(360, 0, 120, 8);
    rect(480, 0, 120, 8);
    rect(600, 0, 100, 8);
  } else if (Tab==TAB_WAVCUTTER) {
    fill(120, 155, 255);
    rect(360, 0, 120, 8);
    fill(205);
    rect(0, 0, 120, 8);
    rect(120, 0, 140, 8);
    rect(260, 0, 100, 8);
    rect(480, 0, 120, 8);
    rect(600, 0, 100, 8);
  } else if (Tab==TAB_SETTINGS) {
    fill(120, 155, 255);
    rect(480, 0, 120, 8);
    fill(205);
    rect(0, 0, 120, 8);
    rect(120, 0, 140, 8);
    rect(260, 0, 100, 8);
    rect(360, 0, 120, 8);
    rect(600, 0, 100, 8);
  } else if (Tab==TAB_MACROS) {
    fill(120, 155, 255);
    rect(600, 0, 100, 8);
    fill(205);
    rect(0, 0, 120, 8);
    rect(120, 0, 140, 8);
    rect(260, 0, 100, 8);
    rect(360, 0, 120, 8);
    rect(480, 0, 120, 8);
  }
  popMatrix();
  textFont(editorFont);
}
void drawLog() {
  if (R==false)return;
  textAlign(LEFT);
  fill(235);
  textSize(30);
  rect(0, 800, 300, 40);
  fill(120, 155, 255);
  rect(0, 800, 300, 8);
  fill(235);
  rect(300, 800, 750, 40);
  if (LogTemp.equals("")==false) {
    rect(300, 800, 300, 40);
    fill(120, 155, 255);
    rect(300, 800, 300, 8);
    fill(0);
    text(LogTemp, 320, 829);
  } else if (LogCaution.equals("")==false) {
    fill(255, 205, 40);
    rect(300, 800, 750, 8);
    fill(0);
    text(LogCaution, 320, 829);
  } else {
    if (correctSyntax==false)fill(158, 10, 10);
    else fill(120, 155, 255);
    rect(300, 800, 750, 8);
    fill(0);
    text(LogRead, 320, 829);
  }
  fill(0);
  text(Log, 20, 829);
  textAlign(CENTER, CENTER);
}