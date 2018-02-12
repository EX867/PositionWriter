
class ScrollList extends UIelement {
  @Override
    boolean react() {
    if (isMouseOn(position.x, position.y, size.x, size.y)) {
      if (mouseState==AN_PRESS) {
        itemClicked=true;
        if (keyInterval<DOUBLE_CLICK&&doubleClicked==0&&doubleClickDist<10) {//double click (10 hardcoded!!)
          doubleClicked=1;
          if (name.equals("I_LEDVIEW")) {
            if (mouseButtonLast==RIGHT) {
              Frames[getFrameid("F_KEYLED")].prepare();
              String filename=getSelection();
              analyzer.loadKeyLedGlobal(filename);
            } else {
              KS.get(ksChain)[ksX][ksY].autorun_startLedIndex(selected);
            }
          } else if (name.equals("I_SOUNDVIEW")) {
            KS.get(ksChain)[ksX][ksY].autorun_startSoundIndex(selected);
          } else if (name.equals("I_FILEVIEW1")) {
            else if (isSoundFile(fileList[selected])) {
              UI[getUIid("MP3_TIME")].disabled=true;
              //from converter play button
              if (converter.converterPlayer.fileLoaded)SampleManager.removeSample(converter.converterPlayer.sample);
              converter.converterPlayer.load(fileList[selected].getAbsolutePath().replace("\\", "/"));
              converter.converterPlayer.setValue(0);
              if (converter.converterPlayer.fileLoaded) {
                converter.converterPlayer.loop(false);
                converter.converterPlayer.play();
              }
              //
            }
          }
        }
      }
    }
  } else if (mouseState==AN_RELEASE) {
  if (reordering!=-1) {
    String temp=View[selected];
    if (selected<reordering) {
      reordering--;
      int a=selected;
      while (a<reordering) {
        if (name.equals("I_LEDVIEW")) {
          KS.get(ksChain)[ksX][ksY].reorderLed(a, a+1);
          title_edited="*";
          surface.setTitle(title_filename+title_edited+title_suffix);
        } else if (name.equals("I_SOUNDVIEW")) {
          KS.get(ksChain)[ksX][ksY].reorderSound(a, a+1);
          title_edited="*";
          surface.setTitle(title_filename+title_edited+title_suffix);
        } else {
          View[a]=View[a+1];
        }
        a=a+1;
      }
      View[reordering]=temp;
    } else {
      int a=selected;
      while (a>reordering) {
        if (name.equals("I_LEDVIEW")) {
          KS.get(ksChain)[ksX][ksY].reorderLed(a, a-1);
          title_edited="*";
          surface.setTitle(title_filename+title_edited+title_suffix);
        } else if (name.equals("I_SOUNDVIEW")) {
          KS.get(ksChain)[ksX][ksY].reorderSound(a, a-1);
          title_edited="*";
          surface.setTitle(title_filename+title_edited+title_suffix);
        } else {
          View[a]=View[a-1];
        }
        a=a-1;
      }
      View[reordering]=temp;
    }
    if (name.equals("I_LEDVIEW")) {
      setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
    } else if (name.equals("I_SOUNDVIEW")) {
      setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
    }
  } else if (draggedListId!=-1) {
    //update drag an drop thing in here(cannot occur in same time with reordering)
    if (((ScrollList)UI[draggedListId]).dragging) {
      //adding=(int)(MouseY-(position.y-size.y-ITEM_HEIGHT/2-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2))))/ITEM_HEIGHT;
      if (adding!=-1) {
        if (name.equals("I_LEDVIEW")&&UI[draggedListId].name.equals("I_FILEVIEW1")) {
          if (fileList[((ScrollList)UI[draggedListId]).selected].isDirectory()==false) {
            if (isSoundFile(fileList[((ScrollList)UI[draggedListId]).selected])==false) {
              KS.get(ksChain)[ksX][ksY].loadLed(adding, ((ScrollList)UI[draggedListId]).View[((ScrollList)UI[draggedListId]).selected]);
              setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
              title_edited="*";
              surface.setTitle(title_filename+title_edited+title_suffix);
              UI[getUIid("KEYSOUND_PAD")].render();
            }
          }
        } else if (name.equals("I_SOUNDVIEW")&&UI[draggedListId].name.equals("I_FILEVIEW1")) {
          if (fileList[((ScrollList)UI[draggedListId]).selected].isDirectory()==false) {
            if (isSoundFile(fileList[((ScrollList)UI[draggedListId]).selected])) {
              KS.get(ksChain)[ksX][ksY].loadSound(adding, ((ScrollList)UI[draggedListId]).View[((ScrollList)UI[draggedListId]).selected]);
              setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
              title_edited="*";
              surface.setTitle(title_filename+title_edited+title_suffix);
              UI[getUIid("KEYSOUND_PAD")].render();
            }
          }
        } else if (name.equals("I_FILEVIEW1")&&UI[draggedListId].name.equals("I_LEDVIEW")) {
          KS.get(ksChain)[ksX][ksY].removeLed(((ScrollList)UI[draggedListId]).selected);
          ((ScrollList)UI[draggedListId]).setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
          ((ScrollList)UI[draggedListId]).dragging=false;
          dragging=false;
          title_edited="*";
          surface.setTitle(title_filename+title_edited+title_suffix);
          UI[draggedListId].render();
          UI[getUIid("KEYSOUND_PAD")].render();
        } else if (name.equals("I_FILEVIEW1")&&UI[draggedListId].name.equals("I_SOUNDVIEW")) {
          KS.get(ksChain)[ksX][ksY].removeSound(((ScrollList)UI[draggedListId]).selected);
          ((ScrollList)UI[draggedListId]).setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
          ((ScrollList)UI[draggedListId]).dragging=false;
          title_edited="*";
          surface.setTitle(title_filename+title_edited+title_suffix);
          UI[draggedListId].render();
          UI[getUIid("KEYSOUND_PAD")].render();
        }
        draggedListId=-1;
      }
    }
  }
}
}

class PadButton extends UIelement {
  int padClickX=-1;
  int padClickY=-1;
  color[][] before=new color[ButtonX][ButtonY];
  public PadButton( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
  }
  //boolean onl=false;
  @Override
    boolean react() {
    float padX=position.x-(size.x-size.y);
    float interval=2*min(size.y/ButtonX, size.y/ButtonY);
    if (isMouseOn(padX, position.y, size.y, size.y)) {
      int X=floor((MouseX-padX+(ButtonX*interval/2))/interval);
      int Y=floor((MouseY-position.y+(ButtonY*interval/2))/interval);
      if (name.equals("KEYSOUND_PAD")) {
        if (mouseState==AN_RELEASE) {
          noteOff(X, Y);
          if (draggedListId!=-1&&((ScrollList)UI[draggedListId]).dragging) {
            if (((ScrollList)UI[draggedListId]).selected!=-1) {
              //update drag and drop thing in here(cannot occur in same time with reordering)
              if (UI[draggedListId].name.equals("I_FILEVIEW1")) {//||UI[draggedListId].name.equals("I_LEDVIEW")||UI[draggedListId].name.equals("I_SOUNDVIEW")) {
                if (fileList[((ScrollList)UI[draggedListId]).selected].isFile()) {
                  if (isSoundFile(fileList[((ScrollList)UI[draggedListId]).selected])) {
                    KS.get(ksChain)[X][Y].loadSound(((ScrollList)UI[draggedListId]).View[((ScrollList)UI[draggedListId]).selected]);
                    title_edited="*";
                    surface.setTitle(title_filename+title_edited+title_suffix);
                    if (X==ksX&&Y==ksY) {
                      int soundviewid=getUIid("I_SOUNDVIEW");
                      ((ScrollList)UI[soundviewid]).setItems(KS.get(ksChain)[X][Y].ksSound.toArray(new String[0]));
                      if (UI[soundviewid].disabled==false)UI[soundviewid].render();
                    }
                  } else {
                    KS.get(ksChain)[X][Y].loadLed(((ScrollList)UI[draggedListId]).View[((ScrollList)UI[draggedListId]).selected]);
                    title_edited="*";
                    surface.setTitle(title_filename+title_edited+title_suffix);
                    if (X==ksX&&Y==ksY) {
                      int ledviewid=getUIid("I_LEDVIEW");
                      ((ScrollList)UI[ledviewid]).setItems(KS.get(ksChain)[X][Y].ksLedFile.toArray(new String[0]));
                      if (UI[ledviewid].disabled==false)UI[ledviewid].render();
                    }
                  }
                }
              }
            }
          } else if (pressed) {
            ksX=X;
            ksY=Y;
            int soundviewid=getUIid("I_SOUNDVIEW");
            int ledviewid=getUIid("I_LEDVIEW");
            ((ScrollList)UI[soundviewid]).setItems(KS.get(ksChain)[X][Y].ksSound.toArray(new String[0]));
            ((ScrollList)UI[ledviewid]).setItems(KS.get(ksChain)[X][Y].ksLedFile.toArray(new String[0]));
            if (UI[soundviewid].disabled==false) {
              UI[soundviewid].registerRender=true;
            }
            if (UI[ledviewid].disabled==false) {
              UI[ledviewid].registerRender=true;
            }
          }
        } else if (mouseState==AN_PRESS&&mouseButtonLast==LEFT) {
          padClickX=X;
          padClickY=Y;
          triggerButton(X, Y);
        } else if (mouseState==AN_PRESSED) {
          notePressing(X, Y);
        }
      }
    } else if (isMouseOn(position.x, position.y, size.x, size.y)) {
      //onl=false;
      int Y=floor((MouseY-position.y+size.y)*4/size.y);
      if (Y<Chain) {
        if (name.equals("KEYLED_PAD")) {
          if (Mode==CYXMODE&&pressed) {
            if ((jeonjehong==false&&mouseState==AN_RELEASE)||(jeonjehong&&mouseState==AN_PRESS)) {
              writeDisplayLine("chain "+str(Y+1));
            }
          }
        } else if (name.equals("KEYSOUND_PAD")) {
          if (mouseState==AN_RELEASE&&pressed) {
            triggerChain(Y);
          }
        }
        render();
      }
    }
    return false;
  }
  synchronized void triggerButton(int X, int Y, boolean async) {
    KS.get(ksChain)[X][Y].autorun();
    KS_SOUNDMULTI.value=max(1, min(KS.get(ksChain)[X][Y].multiSound, KS.get(ksChain)[X][Y].ksSound.size()));
    KS_LEDMULTI.value=max(1, min(KS.get(ksChain)[X][Y].multiLed, KS.get(ksChain)[X][Y].ksLedFile.size()));
    noteOn(X, Y);
  }
  synchronized void triggerChain(int c) {
    if (c<0||c>=Chain)return;
    ksChain=c;
    int a=0;
    while (a<ButtonX) {
      int b=0;
      while (b<ButtonY) {
        KS.get(ksChain)[a][b].multiLed=0;
        KS.get(ksChain)[a][b].multiLedBackup=0;
        KS.get(ksChain)[a][b].multiSound=0;
        b=b+1;
      }
      a=a+1;
    }
    I_SOUNDVIEW.setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
    I_LEDVIEW.setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
  }
}