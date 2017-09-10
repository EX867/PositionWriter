//>>multitouch and interface classes
//multitouch
//rectbutton

int NofButtons=29;
RectButton[] btns;
int maxTouchEvents=5;
MultiTouch[] mt;
boolean[] keyType=new boolean[40];

public class MultiTouch {
  float motionX, motionY;
  float pmotionX, pmotionY;
  float size, psize;
  int id;
  boolean touched = false;
  void update(MotionEvent me, int index) {
    pmotionX = motionX;
    pmotionY = motionY;
    psize = size;
    motionX = me.getX(index);
    motionY = me.getY(index);
    size = me.getSize(index);
    id = me.getPointerId(index);
    touched = true;
  }
  // Executed if this index hasn't been touched:
  void update() {
    pmotionX = motionX;
    pmotionY = motionY;
    psize = size;
    touched = false;
  }
}


void mouseRelease () {
  if (mousePressed ==false) {
    int a=0;
    while (a <maxTouchEvents) {
      mt [a].touched =false;
      a=a+1;
    }
  }
}











//========================================
public class RectButton {
  int ID;
  String text;
  int x;
  int y;
  int w;
  int h;
  color colorEnabled;
  color colorPressed;
  boolean isVisible;
  boolean isEnabled;
  int layout;
  int buttonTextSize;

  RectButton (int tid, String ttext, int tx, int ty, int tw, int th, int tlayout) {
    ID=tid;
    text=ttext;
    x=tx;
    y=ty;
    w=tw;
    h=th;
    isVisible=true;
    isEnabled=true;
    colorPressed=color(165);
    colorEnabled=color(255);
    layout=tlayout;
    buttonTextSize=20;
  }
  void drawButton() {
    if (isVisible) {
      if (isTouched()) {
        fill(colorPressed);
        stroke(0);
        rect(x, y, w, h);
      } else {
        fill(colorEnabled);
        stroke(0);
        rect(x, y, w, h);
      }
      if (text.equals ("")==false) {
        fill (0);
        textSize (buttonTextSize*displayD);
        text (text, x+w/2-(text.length ()*buttonTextSize*3/5*displayD/2), y+h/2+(8*displayD));
        fill (255);
      }
    }
  }
  boolean isTouched() {
    if (isEnabled&&isVisible&&mousePressed) {
      for (int i=0; i < maxTouchEvents; i++) {
        if ((x<mt [i].motionX)&&(mt [i].motionX<(x+w))&&(y<mt [i].motionY)&&(mt [i].motionY <(y+h))) {
          if (mt[i].touched) {
            //println (str (mt [i].motionX)+" "+str (mt [i].motionY));
            return true;
          }
        }
      }
    }
    return false;
  }
}

void drawButtons() {
  int a=0;
  while (a<NofButtons+keyboardButtons) {
    if (LayoutMode==true) {
      if (btns [a].layout==1) {
        btns[a].drawButton();
      }
    } else {
      if (btns [a].layout==2) {
        btns[a].drawButton();
      }
      if (keyboardOn==true){
        if (btns [a].layout==3){
          btns [a].drawButton();
        }
        if (keyLayout==1 ||keyLayout==2||keyLayout==3){
      if (btns [a].layout==4){
        btns [a].drawButton();
      }
      }
      }
    }
    a=a+1;
  }
}













//=======================================
//DEBUG things
void DRAWmultiTouch() {
  stroke (0);
  sR=true;
  //popMatrix ();
  int a=0;
  while (a <maxTouchEvents) {
    if (mt [a].touched) {
      line (mt [a].motionX, 0, mt [a].motionX, height);
      line (0, mt [a].motionY, width, mt [a].motionY);
      fill (255);
      ellipse (mt [a].motionX, mt [a].motionY, 20*displayD, 20*displayD);
      noFill ();
      ellipse (mt [a].motionX, mt [a].motionY, 120*displayD, 120*displayD);
    }
    a=a+1;
  }
  fill (255);
  //noStroke ();
  //pushMatrix();
}
