void mouseWheel(MouseEvent event) {
  if (Tab==TAB_KEYSOUND) {
    if (Focus==1) {
      FV_sliderPos=FV_sliderPos+event.getCount()*15;
      if (FV_sliderPos<0)FV_sliderPos=0;
      else if (FV_sliderPos>30*max((View.length-15), 0))FV_sliderPos=30*max((View.length-15), 0);
    } else if (Focus==2) {
      FV_sliderPos2=FV_sliderPos2+event.getCount()*15;
      if (FV_sliderPos2<0)FV_sliderPos2=0;
      else if (FV_sliderPos2>30*max(getLength(Chain, Xpos, Ypos), 0))FV_sliderPos2=30*max(getLength(Chain, Xpos, Ypos), 0);
    }
  }
}
//================================================================================================================================================-----------------------------------------------------------============================================////////
String buffer="";//stores numder temporary(for vels)
boolean ctrlPressed=false;
boolean shiftPressed=false;
boolean keyStateSingle=false;//
boolean keyStateSingleFull=false;
int keyStateElapsedFrame=0;
boolean keyPressedFirst=false;
//https://processing.org/discourse/beta/num_1249757306.html
String recentNumber1="";
String recentNumber2="";
void keyTyped() {
  if (Tab==TAB_LED) {
    if (isPlaying==false) {
      if (key==ON) {
        Log="on";
        WriteDisplay("\n"+Log);
      }
      if (key==OFF) {
        Log="off";
        WriteDisplay("\n"+Log);
      }
      if (key==DELAY) {
        Log="delay";
        WriteDisplay("\n"+Log);
      }
      if (key==AUTO) {
        Log="auto";
        WriteDisplay(" "+Log);
      }
      if (key==FILENAME) {
        Log="filename";
        WriteDisplay("\n"+Log);
      }
      if (key==BPM) {
        Log="bpm";
        WriteDisplay("\n"+Log);
      }
      if (key==RECENT_NUMBER_1) {
        Log=recentNumber1;
        if (recentNumber1.equals("")==false) {
          if (inFrameInput) {
            if (caretPos[sliderIndex]>0) {
              if (LogFull.charAt(caretPos[sliderIndex]-1)=='/') {
                WriteDisplay(buffer);
              } else {
                WriteDisplay(" "+buffer);
              }
            }
          } else {
            LogFull=display.getText();
            if (LogFull.charAt(LogFull.length()-1)=='/') {
              WriteDisplay(buffer);
            } else {
              WriteDisplay(" "+buffer);
            }
            if (Tab==TAB_LED&&(Mode==DEFAULT||Mode==AUTOINPUT)) {
              readFrame();
              sliderTime=totalPlayTime;
              sliderIndex=totalFrames-1;
            }
          }
        }
      }
      if (key==RECENT_NUMBER_2) {
        Log=recentNumber2;
        if (recentNumber2.equals("")==false) {
          if (inFrameInput) {
            if (caretPos[sliderIndex]>0) {
              if (LogFull.charAt(caretPos[sliderIndex]-1)=='/') {
                WriteDisplay(Log);
              } else {
                WriteDisplay(" "+Log);
              }
            }
          } else {
            LogFull=display.getText();
            if (LogFull.charAt(LogFull.length()-1)=='/') {
              WriteDisplay(Log);
            } else {
              WriteDisplay(" "+Log);
            }
          }
          if (Tab==TAB_LED&&(Mode==DEFAULT||Mode==AUTOINPUT)) {
            readFrame();
            sliderTime=totalPlayTime;
            sliderIndex=totalFrames-1;
          }
        }
      }
      if (key==ENTER) {
        WriteDisplay("\n");
      }
      if (key==BACKSPACE) {
        if (inFrameInput) {
          if (caretPos[sliderIndex]>0) {
            LogFull=display.getText().substring(0, caretPos[sliderIndex]-1)+display.getText().substring(caretPos[sliderIndex], display.getText().length());
            RecordLog();
            display.setText(LogFull);
          }
        } else {
          LogFull=display.getText();
          if (LogFull.length()>0) {
            LogFull=LogFull.substring(0, LogFull.length()-1);
            RecordLog();
            display.setText(LogFull);
          }
        }
      }
      if (key=='!') buffer=buffer+"1";
      if (key=='@') buffer=buffer+"2";
      if (key=='#') buffer=buffer+"3";
      if (key=='$') buffer=buffer+"4";
      if (key=='%') buffer=buffer+"5";
      if (key=='^') buffer=buffer+"6";
      if (key=='&') buffer=buffer+"7";
      if (key=='*') buffer=buffer+"8";
      if (key=='(') buffer=buffer+"9";
      if (key==')') buffer=buffer+"0";  

      if (key==18)/*Ctrl+R*/ readFrame();
      if (key==6)/*Ctrl+F*/ {
        if (Language==LC_ENG) Log=KE_ENG_FINDREPLACE;
        else Log=KE_KOR_FINDREPLACE;
        createFindReplace();
      }
      if (key==4)/*Ctrl+D*/ {
        if (Language==LC_ENG) Log=KE_ENG_DISPLAY;
        else Log=KE_KOR_DISPLAY;
        createDisplay();
      }
      //if (key==8)/*Ctrl+h*/ {
      //  createHelp();
      //}
      if (key==26&&ctrlPressed)/*Ctrl+Z*/ {
        tR=true;
        if (UndoIndex<MAX_UNDO-1&& UndoMax>UndoIndex) {
          UndoIndex=UndoIndex+=1;
          LogFull=Undo[UndoIndex];
          display.setText(LogFull);
          readFrame();
        } else {
          if (Language==LC_ENG) Log=KE_ENG_NOTUNDO;
          else Log=KE_KOR_NOTUNDO;
        }
      }
      if (key==25&&ctrlPressed)/*Ctrl+Y*/ {
        tR=true;
        if (UndoIndex>0) {
          UndoIndex=UndoIndex-1;
          LogFull=Undo[UndoIndex];
          display.setText(LogFull);
          readFrame();
        } else {
          if (Language==LC_ENG) Log=KE_ENG_NOTREDO;
          else Log=KE_KOR_NOTREDO;
        }
      }
      if (key==5)/*Ctrl+E*/ {
        if (Language==LC_ENG) Log=(KE_ENG_EXPORT);
        else Log=(KE_KOR_EXPORT);
        EX_export();
        //try {
        //  thread("EX_export");
        //}
        //catch(Exception e) {
        //  if (Language==LC_ENG) Log=KE_ENG_NOTEXPORT+e.toString();
        //  else Log=KE_KOR_NOTEXPORT+e.toString();
        //}
      }
      if (key==62||key==TAB) {//>
        sR=true;
        sliderTime=sliderTime+delay[sliderIndex];
        if (sliderTime<0) sliderTime=0;
        if (sliderTime>totalPlayTime) sliderTime=totalPlayTime;
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
      }
      if (key==60) {//<
        sR=true;
        if (sliderIndex>0) {
          sliderTime=sliderTime-delay[sliderIndex-1];
          if (sliderTime<0) sliderTime=0;
          if (sliderTime>totalPlayTime) sliderTime=totalPlayTime;
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
        }
      }
      if (key=='/') {
        Log="/";
        WriteDisplay(Log);
      }
    }
    if (key==' ') {//play
      CF_autoRun();
    }
    if (key==16||key==112) {//p stop
      isPlaying=false;
      println("play end");
    }
  } else if (Tab==TAB_KEYSOUND) {
    if (key==RECENT_NUMBER_1) {
      Log=recentNumber1;
      if (recentNumber1.equals("")==false) {
        if (inFrameInput) {
          if (caretPos[sliderIndex]>0) {
            if (LogFull.charAt(caretPos[sliderIndex]-1)=='/') {
              WriteDisplay(buffer);
            } else {
              WriteDisplay(" "+buffer);
            }
          }
        } else {
          LogFull=display.getText();
          if (LogFull.charAt(LogFull.length()-1)=='/') {
            WriteDisplay(buffer);
          } else {
            WriteDisplay(" "+buffer);
          }
        }
      }
    }
    if (key==RECENT_NUMBER_2) {
      Log=recentNumber2;
      if (recentNumber2.equals("")==false) {
        if (inFrameInput) {
          if (caretPos[sliderIndex]>0) {
            if (LogFull.charAt(caretPos[sliderIndex]-1)=='/') {
              WriteDisplay(Log);
            } else {
              WriteDisplay(" "+Log);
            }
          }
        } else {
          LogFull=display.getText();
          if (LogFull.charAt(LogFull.length()-1)=='/') {
            WriteDisplay(Log);
          } else {
            WriteDisplay(" "+Log);
          }
        }
      }
    }
    if (key==ENTER) {
      WriteDisplay("\n");
    }
    if (key==BACKSPACE) {
      if (inFrameInput) {
        if (caretPos[sliderIndex]>0) {
          LogFull=display.getText().substring(0, caretPos[sliderIndex]-1)+display.getText().substring(caretPos[sliderIndex], display.getText().length());
          RecordLog();
          display.setText(LogFull);
        }
      } else {
        LogFull=display.getText();
        if (LogFull.length()>0) {
          LogFull=LogFull.substring(0, LogFull.length()-1);
          RecordLog();
          display.setText(LogFull);
        }
      }
    }
    if (key=='!') buffer=buffer+"1";
    if (key=='@') buffer=buffer+"2";
    if (key=='#') buffer=buffer+"3";
    if (key=='$') buffer=buffer+"4";
    if (key=='%') buffer=buffer+"5";
    if (key=='^') buffer=buffer+"6";
    if (key=='&') buffer=buffer+"7";
    if (key=='*') buffer=buffer+"8";
    if (key=='(') buffer=buffer+"9";
    if (key==')') buffer=buffer+"0";  

    if (key==18)/*Ctrl+R*/ readFrame();
    if (key==6)/*Ctrl+F*/ {
      if (Language==LC_ENG) Log=KE_ENG_FINDREPLACE;
      else Log=KE_KOR_FINDREPLACE;
      createFindReplace();
    }
    if (key==4)/*Ctrl+D*/ {
      if (Language==LC_ENG) Log=KE_ENG_DISPLAY;
      else Log=KE_KOR_DISPLAY;
      createDisplay();
    }
    if (key==8)/*Ctrl+h*/ {
      createHelp();
    }
    if (key==26&&ctrlPressed)/*Ctrl+Z*/ {
      tR=true;
      if (UndoIndex<MAX_UNDO-1&& UndoMax>UndoIndex) {
        UndoIndex=UndoIndex+=1;
        LogFull=Undo[UndoIndex];
        display.setText(LogFull);
        readFrame();
      } else {
        if (Language==LC_ENG) Log=KE_ENG_NOTUNDO;
        else Log=KE_KOR_NOTUNDO;
      }
    }
    if (key==25&&ctrlPressed)/*Ctrl+Y*/ {
      tR=true;
      if (UndoIndex>0) {
        UndoIndex=UndoIndex-1;
        LogFull=Undo[UndoIndex];
        display.setText(LogFull);
        readFrame();
      } else {
        if (Language==LC_ENG) Log=KE_ENG_NOTREDO;
        else Log=KE_KOR_NOTREDO;
      }
    }
    if (key==5)/*Ctrl+E*/ {
      if (Language==LC_ENG) Log=(KE_ENG_EXPORT);
      else Log=(KE_KOR_EXPORT);
      EX_export();
    }
  } else if (Tab==TAB_INFO) {
    if (key==5)/*Ctrl+E*/ {
      if (Language==LC_ENG) Log=(KE_ENG_EXPORT);
      else Log=(KE_KOR_EXPORT);
      EX_export();
    } else if (key==TAB||key==ENTER) {
    } else if (key==BACKSPACE) {
      sR=true;
      LEX_Info_erase(info.Focused);
    } else {
      sR=true;
      LEX_Info_insert(info.Focused, key);
    }
  } else if (Tab==TAB_WAVCUTTER) {
  } else if (Tab==TAB_SETTINGS) {
  }
}

void keyPressed() {
  if (Tab==TAB_LED) {
    if (isPlaying==false) {
      if (key == CODED) {
        if (keyCode == CONTROL) ctrlPressed = true;
        if (keyCode==SHIFT) {//shift is for velocity
          if (shiftPressed==false) buffer="";
          shiftPressed=true;
        }
      } else {
        if (ctrlPressed) {
          if (key=='1') {
            Log=hex((recentColor[0]>>16)&0xFF, 2)+hex((recentColor[0]>>8)&0xFF, 2)+hex((recentColor[0])&0xFF, 2);
            WriteDisplay(" "+Log);
          }
          if (key=='2') {
            Log=hex((recentColor[1]>>16)&0xFF, 2)+hex((recentColor[1]>>8)&0xFF, 2)+hex((recentColor[1])&0xFF, 2);
            WriteDisplay(" "+Log);
          }
          if (key=='3') {
            Log=hex((recentColor[2]>>16)&0xFF, 2)+hex((recentColor[2]>>8)&0xFF, 2)+hex((recentColor[2])&0xFF, 2);
            WriteDisplay(" "+Log);
          }
          if (key=='4') {
            Log=hex((recentColor[3]>>16)&0xFF, 2)+hex((recentColor[3]>>8)&0xFF, 2)+hex((recentColor[3])&0xFF, 2);
            WriteDisplay(" "+Log);
          }
          if (key=='5') {
            Log=hex((recentColor[4]>>16)&0xFF, 2)+hex((recentColor[4]>>8)&0xFF, 2)+hex((recentColor[4])&0xFF, 2);
            WriteDisplay(" "+Log);
          }
          if (key=='6') {
            Log=hex((recentColor[5]>>16)&0xFF, 2)+hex((recentColor[5]>>8)&0xFF, 2)+hex((recentColor[5])&0xFF, 2);
            WriteDisplay(" "+Log);
          }
          if (key=='7') {
            Log=hex((recentColor[6]>>16)&0xFF, 2)+hex((recentColor[6]>>8)&0xFF, 2)+hex((recentColor[6])&0xFF, 2);
            WriteDisplay(" "+Log);
          }
          if (key=='8') {
            Log=hex((recentColor[7]>>16)&0xFF, 2)+hex((recentColor[7]>>8)&0xFF, 2)+hex((recentColor[7])&0xFF, 2);
            WriteDisplay(" "+Log);
          }
          if (key=='9') {
            Log=hex((recentColor[8]>>16)&0xFF, 2)+hex((recentColor[8]>>8)&0xFF, 2)+hex((recentColor[8])&0xFF, 2);
            WriteDisplay(" "+Log);
          }
          if (key=='0') {
            Log=hex((recentColor[9]>>16)&0xFF, 2)+hex((recentColor[9]>>8)&0xFF, 2)+hex((recentColor[9])&0xFF, 2);
            WriteDisplay(" "+Log);
          }
        }
      }
      if (keyStateSingle==false) {
        if ((key==CODED&&keyCode==LEFT)&&Mode==AUTOINPUT) {
          sR=true;
          if (selectedHorV==DS_HTML) {
            selectedHTML--;
            if (selectedHTML<0)selectedHTML=0;
          } else {
            selectedVelocity--;
            if (selectedVelocity<0)selectedVelocity=0;
          }
        }
        if ((key==CODED&&keyCode==RIGHT)&&Mode==AUTOINPUT) {
          sR=true;
          if (selectedHorV==DS_HTML) {
            selectedHTML++;
            if (selectedHTML>9)selectedHTML=9;
          } else {
            selectedVelocity++;
            if (selectedVelocity>127)selectedVelocity=127;
          }
        }
        if ((key==CODED&&keyCode==UP)&&Mode==AUTOINPUT) {
          sR=true;
          if (selectedHorV==DS_HTML) {
            if (selectedHTML>=5)selectedHTML-=5;
          } else {
            if (selectedVelocity>=16)selectedVelocity-=16;
          }
        }
        if ((key==CODED&&keyCode==DOWN)&&Mode==AUTOINPUT) {
          sR=true;
          if (selectedHorV==DS_HTML) {
            if (selectedHTML<=4)selectedHTML+=5;
          } else {
            if (selectedVelocity<=111)selectedVelocity+=16;
          }
        }
      }
    }
  } else if (Tab==TAB_KEYSOUND) {
  } else if (Tab==TAB_INFO) {
    if (keyStateSingle==false) {
      if (key==CODED&&keyCode==UP) {
        sR=true;
        info.Focused--;
        if (info.Focused<0)info.Focused=0;
      } else if (key==CODED&&keyCode==DOWN) {
        sR=true;
        info.Focused++;
        if (info.Focused>7)info.Focused=7;
      }
    }
  } else if (Tab==TAB_WAVCUTTER) {
  } else if (Tab==TAB_SETTINGS) {
  }
  if (keyStateSingleFull==false) keyPressedFirst=true;
  keyStateSingle=true;
  keyStateSingleFull=true;
  keyStateElapsedFrame++;
  keyStateSingle=false;
  if (keyStateElapsedFrame>25&&keyPressedFirst==false) {
    keyStateElapsedFrame=0;
  } else if (keyStateElapsedFrame>40) {
    keyStateElapsedFrame=0;
    keyPressedFirst=false;
    keyStateSingle=false;
  }
}

void keyReleased() {
  if (Tab==TAB_LED) {
    if (key == CODED) {
      if (keyCode == CONTROL) ctrlPressed = false;
      if (keyCode==SHIFT) {
        shiftPressed=false;
        Log=buffer;
        if (buffer.equals("")) {
        } else {
          if (buffer.equals(recentNumber1)) {
          } else {
            recentNumber2=recentNumber1;
            recentNumber1=buffer;
          }
          if (inFrameInput) {
            if (caretPos[sliderIndex]>0) {
              if (LogFull.charAt(caretPos[sliderIndex]-1)=='/') {
                WriteDisplay(buffer);
              } else {
                WriteDisplay(" "+buffer);
              }
            }
          } else {
            LogFull=display.getText();
            if (LogFull.charAt(LogFull.length()-1)=='/') {
              WriteDisplay(buffer);
            } else {
              WriteDisplay(" "+buffer);
            }
            if (Tab==TAB_LED&&(Mode==DEFAULT||Mode==AUTOINPUT)) {
              readFrame();
              sliderTime=totalPlayTime;
              sliderIndex=totalFrames-1;
            }
          }
        }
      }
    }
  } else if (Tab==TAB_KEYSOUND) {
  } else if (Tab==TAB_INFO) {
  } else if (Tab==TAB_WAVCUTTER) {
  } else if (Tab==TAB_SETTINGS) {
  }
  keyPressedFirst=false;
  keyStateElapsedFrame=0;
  keyStateSingle=false;
  keyStateSingleFull=false;
} 