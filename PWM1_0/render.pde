


void renderPad() {
  int a=0;
  if (R) {
    stroke(0);
    //fill();
    //rect(0, 0, PADSIZE, PADSIZE);
    while (a<7) {
      line((PADSIZE/8)*a+(PADSIZE/8), 0, (PADSIZE/8)*a+(PADSIZE/8), PADSIZE);
      a=a+1;
    }
    a=0;
    while (a<7) {
      line(0, (PADSIZE/8)*a+(PADSIZE/8), PADSIZE, (PADSIZE/8)*a+(PADSIZE/8));
      a=a+1;
    }
    quad((PADSIZE-20*displayD)/2, PADSIZE/2, PADSIZE/2, (PADSIZE-20*displayD)/2, (PADSIZE+20*displayD)/2, PADSIZE/2, PADSIZE/2, (PADSIZE+20*displayD)/2);
  }
}












boolean mouseOnVel=false;
//=====================================================================================================================VELOCITY(DISABLED)
void velocity() {
  int a=0;
  a=(mouseY-PADSIZE)*16/PADSIZE*16+((mouseX)*16/PADSIZE);
  if (isOnRegion(0, PADSIZE, PADSIZE, PADSIZE/2)&&velOpened&&colorPress==0) {
    mouseOnVel=true;
    Log=str (a);
  } else{
    if (mouseOnVel&&mousePressed==false) {
      colorPress=-3;
      if (DEBUG)print(a);
      LogFull=display.getText();
      Log=str(a);
      LogFull=LogFull+" "+Log;
      tR=true;
      RecordLog();
      display.setText(LogFull);
      mouseOnVel=false;
    }
    mouseOnVel=false;
  }
  drawVel(PADSIZE, 4*((Screen_Width-PADSIZE)/2), Screen_Width-PADSIZE, (Screen_Width-PADSIZE)/2, false);
  noFill ();
  rect(PADSIZE, 4*((Screen_Width-PADSIZE)/2), Screen_Width-PADSIZE, (Screen_Width-PADSIZE)/2);
  if (velOpened) {
    drawVel(0, PADSIZE, PADSIZE, PADSIZE/2, true);
    noFill();
    rect(0, PADSIZE, PADSIZE, PADSIZE/2);
  }
}

//=====================================================================================================================LOG

void drawLog() {
  fill(205);
  stroke(0);
  textSize(30*displayD);
  rect(0, Screen_Height-LOG_HEIGHT, Screen_Width/3, LOG_HEIGHT);
  rect(Screen_Width/3, Screen_Height-LOG_HEIGHT, Screen_Width*2/3, LOG_HEIGHT);
  fill(0);  
  text(Log, 20*displayD, Screen_Height-LOG_HEIGHT+27*displayD);
  text(LogRead, Screen_Width/3+20*displayD, Screen_Height-LOG_HEIGHT+27*displayD);
}

//=====================================================================================================================FRAME
void frameSlider() {
  int a=0;
  int b=0;
  strokeWeight(2*displayD);
  line(10*displayD+((Screen_Width-PADSIZE)/2), PADSIZE+3*RGB_HEIGHT+(PLAYER_HEIGHT)/2, PADSIZE-10*displayD, PADSIZE+3*RGB_HEIGHT+(PLAYER_HEIGHT)/2);
  strokeWeight(1*displayD);
  fill(255);
  if (LengthTotal==0) {
  } else {
    rect(10*displayD+(Screen_Width-PADSIZE)/2+(PADSIZE-20*displayD-((Screen_Width-PADSIZE)/2))*(float(frameT)/LengthTotal)-5*displayD, PADSIZE+3*RGB_HEIGHT+10*displayD, 20*displayD, (PLAYER_HEIGHT)-20*displayD);
  }
  if (((isOnRegion((Screen_Width-PADSIZE)/2, (PADSIZE+3*RGB_HEIGHT), PADSIZE-(Screen_Width-PADSIZE)/2, PLAYER_HEIGHT)&&colorPress==0) || (mousePressed&&colorPress==-1))&&velOpened==false) {
    frameT=floor(((mouseX-(10*displayD+(Screen_Width-PADSIZE)/2))*LengthTotal)/(PADSIZE-20*displayD-(Screen_Width-PADSIZE)/2));
    if (frameT<0) {
      frameT=0;
    }
    if (frameT>LengthTotal) {
      frameT=LengthTotal;
    }
    a=0;
    int cnt=0;
    if (frameT==LengthTotal&&LengthTotal>0) {
      frameN=LengthFrame-1;
    } else {
      while (a<LengthFrame) {
        if (cnt<=frameT && cnt+delay[a]>frameT) {
          frameT=cnt;
          frameN=a;
          break;
        }
        cnt=cnt+delay[a];
        a=a+1;
      }
    }
    colorPress=-1;
  }
  stroke(0);
  if (frameN==LengthFrame) {
  } else {
    a=0;
    while (a<8) {
      b=0;
      while (b<8) {
        if (frames[frameN][a][b]==-129 ||frames[frameN][a][b]==-128) {
        } else {
          fill (frames[frameN][a][b]);
          rect((PADSIZE/8)*a+5, (PADSIZE/8)*b+5, (PADSIZE/8)-10, (PADSIZE/8)-10);
        }
        b=b+1;
      }
      a=a+1;
    }
  }
}
//=====================================================================================================================COLOR_UI

void recentColors() {
  int a=0;
  while (a<6) {
    recentColor[0]=color(cR, cG, cB);
    btns[COLOR+0].colorEnabled=recentColor[0];
    a=a+1;
  }
}


void drawColorUITrue() {
  if (R) {
    stroke(0);
    fill(0);
    textSize(40*displayD);
    text("R", 5*displayD, PADSIZE+35*displayD);
    text("G", 5*displayD, PADSIZE+RGB_HEIGHT+35*displayD);
    text("B", 5*displayD, PADSIZE+RGB_HEIGHT*2+35*displayD);
    strokeWeight(2);
    line(40*displayD, PADSIZE+(RGB_HEIGHT/2), PADSIZE-60*displayD, PADSIZE+(RGB_HEIGHT/2));
    line(40*displayD, PADSIZE+RGB_HEIGHT+(RGB_HEIGHT/2), PADSIZE-60*displayD, PADSIZE+RGB_HEIGHT+(RGB_HEIGHT/2));
    line(40*displayD, PADSIZE+RGB_HEIGHT*2+(RGB_HEIGHT/2), PADSIZE-60*displayD, PADSIZE+RGB_HEIGHT*2+(RGB_HEIGHT/2));
    strokeWeight(1);
    fill(255);
    rect(40*displayD+(PADSIZE-100*displayD)*(float(cR)/255)-10*displayD, PADSIZE+5*displayD, 20*displayD, 40*displayD);
    rect(40*displayD+(PADSIZE-100*displayD)*(float(cG)/255)-10*displayD, PADSIZE+RGB_HEIGHT+5*displayD, 20*displayD, 40*displayD);
    rect(40*displayD+(PADSIZE-100*displayD)*(float(cB)/255)-10*displayD, PADSIZE+2*RGB_HEIGHT+5, 20*displayD, 40*displayD);
    fill(0);
    textSize(30*displayD);
    text(str(cR), PADSIZE-55*displayD, PADSIZE+35*displayD);
    text(str(cG), PADSIZE-55*displayD, PADSIZE+RGB_HEIGHT+35*displayD);
    text(str(cB), PADSIZE-55*displayD, PADSIZE+RGB_HEIGHT*2+35*displayD);
  }
  if (((isOnRegion(0, PADSIZE, PADSIZE, RGB_HEIGHT)&&colorPress==0) || (mousePressed&&colorPress==1))&&velOpened==false) {//=====
    cR=floor(((mouseX-40*displayD)*255)/(PADSIZE-100*displayD));
    if (cR<0) {
      cR=0;
    }
    if (cR>255) {
      cR=255;
    }
    colorPress=1;
  } else if (((isOnRegion(0, PADSIZE+RGB_HEIGHT, PADSIZE, RGB_HEIGHT)&&colorPress==0) || (mousePressed&&colorPress==2))&&velOpened==false) {//=====
    cG=floor(((mouseX-40*displayD)*255)/(PADSIZE-100*displayD));
    if (cG<0) {
      cG=0;
    }
    if (cG>255) {
      cG=255;
    }
    colorPress=2;
  } else if (((isOnRegion(0, PADSIZE+RGB_HEIGHT*2, PADSIZE, RGB_HEIGHT)&&colorPress==0) || (mousePressed&&colorPress==3))&&velOpened==false) {//=====
    cB=floor(((mouseX-40*displayD)*255)/(PADSIZE-100*displayD));
    if (cB<0) {
      cB=0;
    }
    if (cB>255) {
      cB=255;
    }
    colorPress=3;
  } else {
    if (colorPress!=0&&mousePressed==false) {
      colorPress=0;
    }
  }
}



//=========================================================================================================VELOCITY

void drawVel (int x, int y, int w, int h, boolean text) {
  int a;
  a=0;
  textSize(15*displayD);
  while (a <128) {
    stroke (color (k [a]));
    fill (color (k [a]));
    rect(x+((a%16)*((float)w/16)), y+(round (a/16)*((float)h/8)), ((float)w/16), ((float)h/8));
    if (text) {//500..........
      fill(0);
      text (str (a), x+((a%16)*((float)w/16)), y+(round (a/16)*((float)h/8))+((float)h/8)-2);
    }
    a=a+1;
  }
  stroke(0);
  fill(255);
}
