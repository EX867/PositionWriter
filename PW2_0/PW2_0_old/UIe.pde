

class Slider extends UIelement {
    boolean react() {
    if (name.equals("I_RESOLUTION")) {
      if (valueF<=0)valueF=1;
      surface.setSize(floor(initialWidth*valueF), floor(initialHeight*valueF));
      setSize(floor(initialWidth*valueF), floor(initialHeight*valueF));
    }
    scale=valueF;
    return false;
  }
}
void a() {
  if (name.equals("I_AUTOSAVETIME")) {
    value=max(10, value);
  } else if (name.equals("I_DESCRIPTIONTIME")) {
    value=max(1, value);
  } else if (name.equals("I_BUTTONX")||name.equals("I_BUTTONY")) {
    value=max(1, min(value, PAD_MAX));
  } else if (name.equals("I_CHAIN")) {
    value=min(max(1, value), 8);
  } else if (name.equals("I_TEXTSIZE")) {
    value=max(1, min(50, value));
  } else if (name.equals("I_FINDTEXTBOX")) {
    patternMatcher.findUpdated=false;
    patternMatcher.registerFind(text, ((Button)UI[getUIidRev("I_CALCULATE")]).value);
    findData=patternMatcher.findAll(keyled_textEditor.current.toString());//WARNING!!!
  } else if (name.equals("I_REPLACETEXTBOX")) {
    patternMatcher.registerReplace(text, ((Button)UI[getUIidRev("I_CALCULATE")]).value);
  } else if (name.equals("KS_SOUNDMULTI")) {
    KS.get(ksChain)[ksX][ksY].multiSound=min(max(1, value), KS.get(ksChain)[ksX][ksY].ksSound.size())-1;
  } else if (name.equals("KS_LEDMULTI")) {
    KS.get(ksChain)[ksX][ksY].multiLed=min(max(1, value), KS.get(ksChain)[ksX][ksY].ksLedFile.size())-1;
    KS.get(ksChain)[ksX][ksY].multiLedBackup=KS.get(ksChain)[ksX][ksY].multiLed;
  } else if (name.equals("KS_LOOP")) {
    if (soundLoopEdit) {
      if (((ScrollList)UI[getUIid("I_SOUNDVIEW")]).selected==-1)return;
      KS.get(ksChain)[ksX][ksY].ksSoundLoop.set(((ScrollList)UI[getUIid("I_SOUNDVIEW")]).selected, value);
    } else {
      if (((ScrollList)UI[getUIid("I_LEDVIEW")]).selected==-1)return;
      KS.get(ksChain)[ksX][ksY].ksLedLoop.set(((ScrollList)UI[getUIid("I_LEDVIEW")]).selected, value);
    }
  } else if (name.equals("SKIN_PACKAGE")) {
    description.content="com.kimjisub.launchpad.theme."+text;
  }
}
class ScrollList extends UIelement {
  void setSelect(int sel) {
    selected=sel;
    if (name.equals("I_SOUNDVIEW")) {
      soundLoopEdit=true;
      if (selected==-1) {
        UI[getUIidRev("KS_LOOP")].disabled=true;
        UI[getUIidRev("KS_LOOP")].registerRender=false;
        registerRender();//inefficient!
      } else {
        if (selected>=KS.get(ksChain)[ksX][ksY].ksSoundLoop.size())return;
        ((TextBox)UI[getUIidRev("KS_LOOP")]).value=KS.get(ksChain)[ksX][ksY].ksSoundLoop.get(selected);
        ((TextBox)UI[getUIidRev("KS_LOOP")]).text=""+((TextBox)UI[getUIidRev("KS_LOOP")]).value;
        UI[getUIidRev("KS_LOOP")].disabled=false;
        UI[getUIidRev("KS_LOOP")].registerRender=true;
      }
    } else if (name.equals("I_LEDVIEW")) {
      soundLoopEdit=false;
      if (selected==-1) {
        UI[getUIidRev("KS_LOOP")].disabled=true;
        UI[getUIidRev("KS_LOOP")].registerRender=false;
        registerRender();//inefficient!
      } else {
        if (selected>=KS.get(ksChain)[ksX][ksY].ksLedLoop.size())return;
        ((TextBox)UI[getUIidRev("KS_LOOP")]).value=KS.get(ksChain)[ksX][ksY].ksLedLoop.get(selected);
        ((TextBox)UI[getUIidRev("KS_LOOP")]).text=""+((TextBox)UI[getUIidRev("KS_LOOP")]).value;
        UI[getUIidRev("KS_LOOP")].disabled=false;
        UI[getUIidRev("KS_LOOP")].registerRender=true;
      }
    } else if (name.equals("UN_LIST")) {
      uncloud_select(selected);
    }
  }
  @Override
    boolean react() {
    if (isMouseOn(position.x, position.y, size.x, size.y)) {
      if (mouseState==AN_PRESS) {
        focus=ID;
        if ((isMousePressed(position.x+size.x-SLIDER_HALFWIDTH, position.y, SLIDER_HALFWIDTH, size.y)||(sliderClicked/*&&mousePressed&&mouseButtonLast==RIGHT*/))) {
          sliderClicked=true;
        } else {//isMousePressed(position.x-SLIDER_HALFWIDTH, position.y, size.x-SLIDER_HALFWIDTH, size.y)
          setSelect((int)(MouseY-(position.y-size.y-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2))))/ITEM_HEIGHT);
          if (selected<0||selected>=View.length)setSelect(-1);
          if (selected!=-1) {
            itemClicked=true;
            if (keyInterval<DOUBLE_CLICK&&doubleClicked==0&&doubleClickDist<10) {//double click (10 hardcoded!!)
              doubleClicked=1;
              if (name.equals("I_LEDVIEW")) {
                if (mouseButtonLast==RIGHT) {
                  skip=true;
                  focus=DEFAULT;
                  resetFocus();
                  skip=false;
                  Frames[getFrameid("F_KEYLED")].prepare();
                  String filename=getSelection();
                  try {
                    analyzer.loadKeyLedGlobal(filename);
                    title_filename=filename;
                  }
                  catch(Exception e) {
                    displayLogError(e);
                  }
                  title_edited="";
                  surface.setTitle(title_filename+title_edited+title_suffix);
                } else {
                  KS.get(ksChain)[ksX][ksY].autorun_startLedIndex(selected);
                }
              } else if (name.equals("I_SOUNDVIEW")) {
                KS.get(ksChain)[ksX][ksY].autorun_startSoundIndex(selected);
              } else if (name.equals("I_FILEVIEW1")) {
                if (fileList[selected].isDirectory())setItems(listFilePaths_related(fileList[selected].getAbsolutePath()));
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
              } else if (name.equals("MP3_INPUT")) {
                removeItem(selected);
              }
            }
          }
        }
      } else if (mouseState==AN_PRESSED) {
        focus=ID;
        if (reorderable&&selected!=-1&&itemClicked) {
          reordering=(int)(MouseY-(position.y-size.y-ITEM_HEIGHT/2-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2))))/ITEM_HEIGHT;
          if (selected==reordering||selected+1==reordering||reordering<0||reordering>View.length)reordering=-1;
        } else if (draggedListId!=-1) {
          //update drag and drop thing in here(cannot occur in same time with reordering)
          if (((ScrollList)UI[draggedListId]).dragging&&((ScrollList)UI[draggedListId]).selected!=-1&&((ScrollList)UI[draggedListId]).itemClicked) {
            adding=(int)(MouseY-(position.y-size.y-ITEM_HEIGHT/2-(sliderPos-(position.y-size.y+sliderLength))*(max(1, View.length*ITEM_HEIGHT-size.y*2)/max(1, size.y*2-sliderLength*2))))/ITEM_HEIGHT;
            if (adding<0)adding=-1;
            if (adding>View.length)adding=View.length;
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
        sliderClicked=false;
        itemClicked=false;
        reordering=-1;
        adding=-1;
      } else {
        sliderClicked=false;
        itemClicked=false;
        reordering=-1;
        adding=-1;
      }
      if (skipRendering==false)render();
    } else {
      reordering=-1;
      if (mouseState==AN_PRESSED||mouseState==AN_RELEASE) {
        if (pressed&&sliderClicked==false/*&&dragging==false*/) {//?????
          draggedListId=ID;
          dragging=true;
        }
      } else {
        if (dragging&&selected!=-1) {
          Frames[currentFrame].render();
          skipRendering=true;
          dragging=false;
        }
        itemClicked=false;
        sliderClicked=false;
      }
    }
    return false;
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
  void printLed(int X, int Y) {
    printLed(X, Y, false, 0);
  }
  void triggerButton(int X, int Y) {
    triggerButton(X, Y, false);
  }
  synchronized void triggerButton(int X, int Y, boolean async) {
    if (X<0||Y<0||X>=ButtonX||Y>=ButtonY)return;
    KS.get(ksChain)[X][Y].autorun();
    int id=getUIidRev("KS_SOUNDMULTI");
    ((TextBox)UI[id]).value=max(1, min(KS.get(ksChain)[X][Y].multiSound, KS.get(ksChain)[X][Y].ksSound.size()));
    ((TextBox)UI[id]).text=""+((TextBox)UI[id]).value;
    if (async)UI[id].registerRender=true;
    else UI[id].render();
    id=getUIidRev("KS_LEDMULTI");
    ((TextBox)UI[id]).value=max(1, min(KS.get(ksChain)[X][Y].multiLed, KS.get(ksChain)[X][Y].ksLedFile.size()));
    ((TextBox)UI[id]).text=""+((TextBox)UI[id]).value;
    if (async)UI[id].registerRender=true;
    else UI[id].render();
    noteOn(X, Y);
  }
  synchronized void noteOn(int x, int y) {//uses in midi section too.
    if (isNoteOn(x, y)==false)CurrentNoteOn.add(new IntVector2(x, y));
  }
  private void notePressing(int x, int y) {//using local variable! don't use this in else.
    if (padClickX==-2)return;//resets on noteOn in padbutton.
    if (padClickX!=x||padClickY!=y) {//mouse moved.
      noteOff(x, y);
      padClickX=-2;
      padClickY=-2;
    }
  }
  synchronized void noteOff(int x, int y) {//if note is not in list, ignore.
    if (x<0||y<0||x>=ButtonX||y>=ButtonY)return;
    int a=0;
    while (a<CurrentNoteOn.size()) {
      if (CurrentNoteOn.get(a).equals(x, y)) {
        CurrentNoteOn.remove(a);
        if (KS.get(ksChain)[x][y].multiSound>0&&KS.get(ksChain)[x][y].ksSoundLoop.size()>0&&KS.get(ksChain)[x][y].ksSoundLoop.get(KS.get(ksChain)[x][y].multiSound-1)==0) {
          KS.get(ksChain)[x][y].stopSound();
          KS.get(ksChain)[x][y].autorun_soundFlag=true;
        }
        if (KS.get(ksChain)[x][y].multiLed>0&&KS.get(ksChain)[x][y].ksLedLoop.size()>0&&KS.get(ksChain)[x][y].ksLedLoop.get(KS.get(ksChain)[x][y].multiLed-1)==0) {
          int c=0;
          while (c<ledstack.size()) {//pointer
            if (ledstack.get(c).bX==x&&ledstack.get(c).bY==y) {
              ledstack.get(c).isInStack=false;
              ledstack.get(c).autorun_resetLed();
              ledstack.remove(c);
            } else {
              c=c+1;
            }
          }
        }
      } else {
        a=a+1;
      }
    }
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
    int soundviewid=getUIid("I_SOUNDVIEW");
    int ledviewid=getUIid("I_LEDVIEW");
    ((ScrollList)UI[soundviewid]).setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
    ((ScrollList)UI[ledviewid]).setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
    if (UI[soundviewid].disabled==false)UI[soundviewid].registerRender=true;
    if (UI[ledviewid].disabled==false)UI[ledviewid].registerRender=true;
  }
}