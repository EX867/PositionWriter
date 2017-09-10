class Display {
  int X;
  int Y;
  String Text;
  int Cursur=0;
  int Cursurdown=0;
  int Cursurup=0;
  int textLines=1;
  int CursurLine=1;

  int scrollMode=0; 
  boolean firstTouch=false;
  int firstTouchX=987654321;
  int firstTouchY=987654321;
  int firstTouchCount=0;
  float firstscrolldown=0;
  float vscrolldown=0;
  float firstscrollright=0;
  float vscrollright=0;

  float scrolldown=0;
  float scrollright=0;
  
  int maxCurs=0;
  int pmaxCurs=0;
  boolean expectancy=false;

  public Display() {
    Text="";
    X=0;
    Y=0;
    //btns[KEYBOARD].colorEnabled=color (245);
    //btns [KEYBOARD].colorPressed=color (180);
  }
  String getText() {
    return Text;
  }
  void setText (String string) {
    Text=string;
  }

  void scroll () {
    if (isOnRegion(0, 0, Screen_Width, Screen_Height-KEY_HEIGHT-(Screen_Width-PADSIZE))&&LayoutMode ==false) {
      if (firstTouch==false) {
        firstTouchX=mouseX;
        firstTouchY=mouseY;
        firstTouchCount=0;
        //if (DEBUG)println ("mousepointer:"+" "+mouseX+" "+mouseY);
      } else {
        firstTouchCount+=1;
      }
      //if (DEBUG)println (str (mouseY-firstTouchY)+" "+firstTouchCount);
      if ((abs (firstTouchY-mouseY)>10 || abs(firstTouchX-mouseX)>10)&&(firstTouchX <10000 && firstTouchY <10000)&&firstTouchCount<=1&&scrollMode==0) {
        if (scrollMode==0) {
          firstscrolldown=scrolldown;
          firstscrollright=scrollright;
        }
        scrollMode=2;
        //println ("scrollmode");
      } else if (abs (firstTouchY-mouseY)<10 && abs (firstTouchX-mouseX)<10 &&firstTouchCount>75&&scrollMode==0) {
        scrollMode=1;
      }
      firstTouch=true;
    } else if (btns [KEYBOARD].isTouched ()&&LayoutMode&&velOpened==false&&keyType[PLAYER]==false) {
      if (firstTouch==false) {
        firstTouchX=mouseX;
        firstTouchY=mouseY;
        firstTouchCount=0;
        //if (DEBUG)println ("mousepointer:"+" "+mouseX+" "+mouseY);
      } else {
        firstTouchCount+=1;
      }
       if (scrollMode==0) {
          firstscrolldown=scrolldown;
          firstscrollright=scrollright;
        }
        scrollMode=2;
        //println ("scrollmode");
      firstTouch=true;
    } else {
      firstTouch=false;
      firstTouchX=987654321;
      firstTouchY=987654321;
      scrollMode=0;
      firstTouchCount=0;
    }
    if (scrollMode==2) {
      scrolldown=firstscrolldown+((float)firstTouchY-mouseY)/displayD;
      scrollright=firstscrollright+((float)firstTouchX-mouseX)/displayD;
      vscrolldown=(pmouseY-mouseY)*0.5F;
      vscrollright=(pmouseX-mouseX)*0.5F;
    } else {
      vscrolldown=vscrolldown*0.8F;
      vscrollright=vscrollright*0.8F;
      scrolldown=scrolldown+vscrolldown;
      scrollright=scrollright+vscrollright;
      if (abs (vscrolldown)<1) {
        vscrolldown =0;
      }
      if(abs (vscrollright)<1){
        vscrollright=0;
      }
    }
    if (scrolldown>textLines*20) {//multiple displayD
      scrolldown=textLines*20;
      //vscrolldown=-0.1F*vscrolldown;
    }
    if (scrolldown<0) {
      scrolldown=0;
     // vscrolldown=-0.1F*vscrolldown;
    }
    if(scrollright>16*maxCurs){
      scrollright=16*maxCurs;
      //
    }
    if (scrollright <0){
      scrollright=0;
    //  vscrollright=-0.1F*vscrollright;
    }
  }
  void drawDisplay () {
  }
  String [] splitText;
  //=====================================================================================================================CONSOLE(DISABLED)
  void drawConsole() {
    int line=0;
    int totalCurs=0;
    int linetotalCurs=0;
    boolean cursurDrew=false;
    splitText=split(Text, "\n");
    textLines=splitText.length;
    maxCurs=0;
    textSize (20*displayD);
    while (line <splitText.length) {
      String[] splitLine =split (splitText[line], ' ');
      int curs=-1;
      int b=0;
      expectancy=false;
      while (b <splitLine.length) {
        if (b==0&&splitLine [0].length ()>=2&&splitLine[0].substring(0,2).equals ("//")){
          expectancy=true;
        }
        curs=curs+1;
        if(expectancy){
          fill (130);
        }else if (splitLine [b].equals ("on") || splitLine [b].equals ("o") || splitLine [b].equals ("off") || splitLine [b].equals ("f") || splitLine [b].equals ("delay") || splitLine [b].equals ("d")) {
          fill(65, 155, 155);
        } else if (splitLine [b].equals ("auto") || splitLine [b].equals ("a")) {
          fill (65, 135, 165);
        } else {
          fill (0);
        }
        int d=0;
        while (d <splitLine [b].length ()) {
          if (LayoutMode) {
            if ((20+line*20-scrolldown)*displayD>0) {
              text (splitLine[b].charAt (d), (5+curs*16-scrollright)*displayD, PADSIZE+3*RGB_HEIGHT+PLAYER_HEIGHT+(30+line*20-scrolldown)*displayD);
            }
          } else {
            if ((30+line*20-scrolldown)*displayD<Screen_Height-KEY_HEIGHT) {
              text (splitLine [b].charAt (d), (5+curs*16-scrollright)*displayD, (30+line*20-scrolldown)*displayD);
            }
          }
          d=d+1;
          curs=curs+1;
        }
        totalCurs=totalCurs+splitLine [b].length ()+1;
        if (totalCurs>Cursur&&cursurDrew==false&&LayoutMode==false) {
          if ((30+line*20-scrolldown)>0) {//multiple displayD
            fill (0);
            text("|", (1+16*(Cursur+(curs+1)-totalCurs)-scrollright)*displayD, (30+line*20-scrolldown)*displayD);
            triangle  ((5+16*(Cursur+(curs+1)-totalCurs)-scrollright)*displayD, (50+line*20-scrolldown)*displayD, (-15+16*(Cursur+(curs+1)-totalCurs)-scrollright)*displayD, (80+line*20-scrolldown)*displayD, (20+16*(Cursur+(curs+1)-totalCurs)-scrollright)*displayD, (80+line*20-scrolldown)*displayD);
          }
          if (line>0) {
            Cursurup=splitText [line-1].length()+1;
          }
          if (line<splitText.length-1) {
            Cursurdown=splitText[line].length()+1;
          }
          CursurLine=line;
          cursurDrew=true;
        }
        b=b+1;
      }
      if (line==splitText.length -1) {
        if (isOnRegion(0, 0, Screen_Width, Screen_Height-KEY_HEIGHT)&&((line*20+70-scrolldown)*displayD <=mouseY&&mouseY<((line+5)*20+70-scrolldown)*displayD)&&LayoutMode==false&&scrollMode==0) {
          if ((mouseX+scrollright*displayD-10*displayD)<=curs*displayD*16) {
            Cursur =floor (linetotalCurs+(mouseX+scrollright*displayD-10)/(16*displayD));
            if (Cursur <linetotalCurs) {
              Cursur =linetotalCurs;
            }
          }
        }
      } else {
        if (isOnRegion(0, 0, Screen_Width, Screen_Height-KEY_HEIGHT)&&((line*20+70-scrolldown)*displayD <=mouseY&&mouseY<((line+1)*20+70-scrolldown)*displayD)&&LayoutMode==false&&scrollMode==0) {
          if ((mouseX+scrollright*displayD-10*displayD)<=curs*displayD*16) {
            Cursur =floor (linetotalCurs+(mouseX+scrollright*displayD-10)/(16*displayD));
            if (Cursur <linetotalCurs) {
              Cursur =linetotalCurs;
            }
          }
        }
      }
      linetotalCurs=linetotalCurs+curs+1;
      if (line==splitText.length-1) {
        if (isOnRegion(0, 0, Screen_Width, Screen_Height-KEY_HEIGHT)&&((line*20+70-scrolldown)*displayD<=mouseY&&mouseY<((line+5)*20+70-scrolldown)*displayD)&&LayoutMode==false&&scrollMode==0) {
          if ((mouseX+scrollright*displayD-40*displayD)>curs*displayD*16) {
            Cursur =linetotalCurs-1;
          }
        }
      } else {
        if (isOnRegion(0, 0, Screen_Width, Screen_Height-KEY_HEIGHT)&&((line*20+70-scrolldown)*displayD<=mouseY&&mouseY<((line+1)*20+70-scrolldown)*displayD)&&LayoutMode==false&&scrollMode==0) {
          if ((mouseX+scrollright*displayD-40*displayD)>curs*displayD*16) {
            Cursur =linetotalCurs-1;
          }
        }
      }
      if(curs>maxCurs){
        maxCurs=curs;
      }
      line=line+1;
    }
    if (isOnRegion(0, 0, Screen_Width, Screen_Height-KEY_HEIGHT)&&(((line+10)*20+70-scrolldown)*displayD<=mouseY&&mouseY <Screen_Height-KEY_HEIGHT-(Screen_Width-PADSIZE))) {
      Cursur=Text.length();
    }
    if (Cursur<0) {
      Cursur=0;
    } else if (Cursur>Text. length()) {
      Cursur =Text.length ();
    }
  pmaxCurs=maxCurs;
  }
}
