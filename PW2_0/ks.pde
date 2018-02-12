HashMap<Sample, ArrayList<KsButton>> samples=new HashMap<Sample, ArrayList<KsButton>>();
ArrayList<KsButton> emptyKsButtonArray=new ArrayList<KsButton>();
static class IntVector3 {
  static final IntVector3 zero=new IntVector3(0, 0, 0);
  int x=0, y=0, z=0;
  public IntVector3() {
  }
  public IntVector3(int x_, int y_, int z_) {
    x=x_;
    y=y_;
    z=z_;
  }
  void set(IntVector3 other) {
    x=other.x;
    y=other.y;
    z=other.z;
  }
}
class KsSession {//
  String name;
  LightThread light;//includes display.
  boolean[][] notePress;//
  File file;//project name
  UnipackInfo info=new UnipackInfo(((TextBox)KyUI.get("set_dbuttony")).valueI, ((TextBox)KyUI.get("set_dbuttonx")).valueI);
  boolean changed=false;
  //ap
  LedScript autoPlay;//#ADD
  boolean loop=false;
  int loopStart=0;
  int loopEnd=0;
  //
  AudioContext ksac=new AudioContext();
  MultiSamplePlayer player;
  ArrayList<KsButton[][]> KS;
  //
  IntVector2 selection=new IntVector2(0, 0);
  int chain=0;//selected chain
  KsSession(String name_) {
    name=getFileName(name_);
    file=new File(name_);
    Thread thread=new Thread(light=new LightThread());
    light.thread=thread;
    player = new MultiSamplePlayer(ksac, 10);
    //player.onEnd=new Predicate<MultiMultiSamplePlayer.SampleStatePlayer.MultiSamplePlayer.SampleStateState>() {
    //  public boolean test(MultiMultiSamplePlayer.SampleStatePlayer.MultiSamplePlayer.SampleStateState sample) {
    //    return true;
    //  }
    //};
    //light.onEnd=new Predicate<LedCounter>() {
    //  public boolean test(LedCounter counter) {
    //    return true;
    //  }
    //};
    resize(info.buttonX, info.buttonY, 8);
    thread.start();
  }
  KsButton getSelected() {
    return KS.get(chain)[selection.x][selection.y];
  }
  void resize(int x, int y, int c) {
    info.buttonX=x;
    info.buttonY=y;
    info.chain=c;
    notePress=new boolean[info.buttonX][info.buttonY];
    KS=new ArrayList<KsButton[][]>();
    for (int ch=0; ch<info.chain; ch++) {
      KS.add(new KsButton[info.buttonX][info.buttonY]);
      for (int a=0; a<info.buttonX; a++) {
        for (int b=0; b<info.buttonY; b++) {
          KS.get(ch)[a][b]=new KsButton(this, new IntVector3(a, b, ch));
        }
      }
    }
  }
  void close() {
    light.active=false;
    ksac.stop();
    player.close();
  }
  void setChanged(boolean v, boolean force) {
    if (v) {
      if ((!changed||force)) {
        int index=ksTabs.indexOf(this);
        if (index>=0) {
          ks_filetabs.setTabName(index, getFileName(file.getAbsolutePath())+"*");
        }
        ks_filetabs.invalidate();
      }
      changed=true;
    } else {
      if ((changed||force)) {
        int index=ksTabs.indexOf(this);
        if (index>=0) {
          ks_filetabs.setTabName(index, getFileName(file.getAbsolutePath()));
        }
        ks_filetabs.invalidate();
      }
      changed=false;
    }
  }
}
class KsButton {
  IntVector3 pos;
  KsSession session;
  //
  ArrayList<LedCounter> led;
  ArrayList<MultiSamplePlayer.SampleState> sound;
  int ledIndex=0;
  int soundIndex=0;
  public KsButton(KsSession session_, IntVector3 pos_) {
    session=session_;
    pos=pos_;
    led=new ArrayList<LedCounter>();
    sound=new ArrayList<MultiSamplePlayer.SampleState>();
  }
  void set(KsButton other) {
    led=other.led;
    sound=other.sound;
    ledIndex=other.ledIndex;
    soundIndex=other.soundIndex;
  }
  void setSoundIndex(int index) {
    soundIndex=max(0, min(index, sound.size()-1));
  }
  void setLedIndex(int index) {
    ledIndex=max(0, min(index, led.size()-1));
  }
  void loadSound(String path) {
    loadSound(sound.size(), path);
  } 
  void loadSound(int index, String path) {//must path exists!
    MultiSamplePlayer.SampleState sample=session.player.load(path);
    if (samples.containsKey(sample.sample)) {
      samples.get(sample.sample).add(this);
    } else {
      ArrayList<KsButton> list =new ArrayList<KsButton>();
      list.add(this);
      samples.put(sample.sample, list);
    }
    sound.add(index, sample);
  }
  void reorderSound(int a, int b) {//must in range!
    Collections.swap(sound, a, b);
  }
  void removeSound(int index) {//must in range!
    MultiSamplePlayer.SampleState sample=sound.get(index);
    if (samples.getOrDefault(sample.sample, emptyKsButtonArray).size()==1) {
      samples.remove(sample.sample);
      SampleManager.removeSample(sample.sample);
    } else {//must contains!
      samples.get(sample.sample).remove(this);
    }
    session.player.stop(sample);
    sound.remove(index);
  }
  void loadLed(String path) {
    loadLed(led.size(), path);
  }
  void loadLed(int index, String path) {
    LedScript script=loadLedScript(path, readFile(path));
    led.add(index, session.light.addTrack(pos, script));
  }
  void reorderLed(int a, int b) {
    Collections.swap(led, a, b);
  }
  void removeLed(int index) {
    session.light.removeTrack(pos);
    led.remove(index);
  }
  void resetIndex() {
    ledIndex=0;
    soundIndex=0;
  }
  void noteOn() {
    if (!session.notePress[pos.x][pos.y]) {
      if (sound.size()>0) {
        if (soundIndex>=sound.size()) {
          soundIndex=0;
        }
        session.player.play(sound.get(soundIndex));
        soundIndex++;
      }
      if (led.size()>0) {
        if (ledIndex>=led.size()) {
          ledIndex=0;
        }
        session.light.start(pos);
        ledIndex++;
      }
      session.notePress[pos.x][pos.y]=true;
      println("chain "+pos.z+", ("+pos.x+", "+pos.y+") note on");
    }
  }
  void noteOff() {
    if (session.notePress[pos.x][pos.y]) {
      if (sound.size()>0&&soundIndex-1>0&&soundIndex-1<sound.size()&&sound.get(soundIndex-1).loopCount==0) {
        session.player.stop(sound.get(soundIndex-1));
      }
      if (led.size()>0&&ledIndex-1>0&&ledIndex-1<led.size()&&led.get(ledIndex-1).loopCount==0) {
        session.light.stop(led.get(ledIndex-1));
      }
      println("chain "+pos.z+", ("+pos.x+", "+pos.y+") note off");
      session.notePress[pos.x][pos.y]=false;
    }
  }
}
void ks_setup() {
  final TextBox ksinfo_edit=((TextBox)KyUI.get("ksinfo_edit"));
  final TextBox ksinfo_title=((TextBox)KyUI.get("ksinfo_title"));
  final TextBox ksinfo_producername=((TextBox)KyUI.get("ksinfo_producername"));
  final TextBox ksinfo_buttony=((TextBox)KyUI.get("ksinfo_buttony"));
  final TextBox ksinfo_buttonx=((TextBox)KyUI.get("ksinfo_buttonx"));
  final TextBox ksinfo_chain=((TextBox)KyUI.get("ksinfo_chain"));
  final ToggleButton ksinfo_squarebuttons=((ToggleButton)KyUI.get("ksinfo_squarebuttons"));
  final ImageButton ksinfo_exit=((ImageButton)KyUI.get("ksinfo_exit"));
  ksinfo_buttony.setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      ui_textValueRange((TextBox)e, 1, PAD_MAX);
    }
  }
  );
  ksinfo_buttonx.setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      ui_textValueRange((TextBox)e, 1, PAD_MAX);
    }
  }
  );
  ksinfo_chain.setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      ui_textValueRange((TextBox)e, 1, 8);
    }
  }
  );
  ((Button)KyUI.get("ks_info")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.addLayer(frame_ksinfo);
      final String beforeEdit=currentKs.file.getAbsolutePath();
      final String beforeTitle=currentKs.info.title;
      final String beforeProducerName=currentKs.info.producerName;
      final int beforeButtonX=currentKs.info.buttonX;
      final int beforeButtonY=currentKs.info.buttonY;
      final int beforeChain=currentKs.info.chain;
      final boolean beforeSquareButtons=currentKs.info.squareButtons;
      ksinfo_edit.onTextChangeListener=new EventListener() {
        public void onEvent(Element e) {
          String text=ksinfo_edit.getText().replace("\\", "/");
          boolean er=!isValidFileName(text);
          for (KsSession t : ksTabs) {//anti duplication
            if (t!=currentKs&&t.file.getAbsolutePath().replace("\\", "/").equals(text)) {
              er=true;
              break;
            }
          }
          ksinfo_edit.error=er;
        }
      };
      ksinfo_exit.setPressListener(new MouseEventListener() {
        public boolean onEvent(MouseEvent e, int index) {
          if (!ksinfo_edit.error&&!ksinfo_buttonx.error&&!ksinfo_buttony.error&&!ksinfo_chain.error) {
            currentKs.file=new File(ksinfo_edit.getText());
            currentKs.info.title=ksinfo_title.getText();
            currentKs.info.producerName=ksinfo_producername.getText();
            currentKs.info.buttonX=ksinfo_buttony.valueI;
            currentKs.info.buttonY=ksinfo_buttonx.valueI;
            currentKs.info.chain=ksinfo_chain.valueI;
            currentKs.info.squareButtons=ksinfo_squarebuttons.value;
            if (!beforeTitle.equals(currentKs.info.title)||!beforeProducerName.equals(currentKs.info.producerName)||beforeButtonY!=currentKs.info.buttonY||beforeButtonX!=currentKs.info.buttonX||beforeChain!=currentKs.info.chain||beforeSquareButtons!=currentKs.info.squareButtons) {
              currentKs.setChanged(true, true);
            } else if (!beforeEdit.equals(currentKs.file.getAbsolutePath())) {
              currentKs.setChanged(true, true);
            }
            currentKs.resize( currentKs.info.buttonX, currentKs.info.buttonY, currentKs.info.chain);
            ks_pad.size.set(currentKs.info.buttonX, currentKs.info.buttonY);
            ((PadButton)KyUI.get("ks_chain")).size.set(1, currentKs.info.chain);
            ks_pad.invalidate();
            KyUI.removeLayer();
          }
          return false;
        }
      }
      );
      ksinfo_edit.setText(currentKs.file.getAbsolutePath().replace("\\", "/"));
      ksinfo_title.setText(currentKs.info.title);
      ksinfo_producername.setText(currentKs.info.producerName);
      ksinfo_buttony.setText(""+currentKs.info.buttonX);
      ksinfo_buttonx.setText(""+currentKs.info.buttonY);
      ksinfo_chain.setText(""+currentKs.info.chain);
      ksinfo_squarebuttons.value=currentKs.info.squareButtons;
      return false;
    }
  }
  );
  ((PadButton)KyUI.get("ks_pad")).buttonListener=new PadButton.ButtonListener() {
    public void accept(IntVector2 click, IntVector2 coord, int action) {//only sends in-range events.
      if (action==PadButton.PRESS_L) {
        currentKs.selection.set(coord);
        currentKs.getSelected().noteOn();
      } else if (action==PadButton.PRESS_R) {
        currentKs.selection.set(coord);
      } else if (action==PadButton.DRAG_L||action==PadButton.DRAG_R) {
        currentKs.getSelected().noteOff();
      } else if (action==PadButton.RELEASE_L) {
        currentKs.getSelected().noteOff();
      }
    }
  };
  final FrameSlider ksfs=((FrameSlider)KyUI.get("ks_frameslider"));
  final Button ksfsTime=((Button)KyUI.get("ks_time"));
  ksfs.unholdListener=new EventListener() {
    public void onEvent(Element e) {
      if (currentKs.autoPlay==null) {
        return;
      }
      synchronized(currentKs.autoPlay) {
        currentKs.autoPlay.displayTime=ksfs.valueI;
        ksfsTime.text=currentKs.autoPlay.displayTime+"/"+ksfs.maxI;
        currentKs.autoPlay.setFrameByTime();
        ksfs.set(currentKs.autoPlay.getTimeByFrame(currentKs.autoPlay.displayFrame));
        currentKs.autoPlay.FrameSliderBackup=currentKs.autoPlay.displayTime;//user input
      }
      ksfsTime.invalidate();
    }
  };
  ksfs.loopAdjustListener=new EventListener() {
    public void onEvent(Element e) {
      //synchronized(currentKs.autoPlay) {
      currentKs.loopStart=ksfs.valueS;
      currentKs.loopEnd=ksfs.valueE;
      //}
    }
  };
  ksfs.frameMarker=new ExtendedRenderer() {
    public void render(PGraphics g) {
      if (currentKs.autoPlay==null) {
        return;
      }
      float size=(ksfs.pos.right-ksfs.pos.left-2*ksfs.padding);
      g.strokeWeight(2);
      g.stroke(0, 255, 0);
      g.line(ksfs.pos.left + ksfs.padding+size * currentKs.autoPlay.FrameSliderBackup / (ksfs.maxI - ksfs.minI), ksfs.pos.top+ksfs.padding+2, ksfs.pos.left +  ksfs.padding+size * currentKs.autoPlay.FrameSliderBackup / (ksfs.maxI - ksfs.minI), (ksfs.pos.top+ksfs.pos.bottom)/2);
    }
  };
  ((TextBox)KyUI.get("ks_soundindex")).onTextChangeListener=new EventListener() {
    public void onEvent(Element e) {
      currentKs.getSelected().setSoundIndex(((TextBox)KyUI.get("ks_soundindex")).valueI);
    }
  };
  ((TextBox)KyUI.get("ks_ledindex")).onTextChangeListener=new EventListener() {
    public void onEvent(Element e) {
      currentKs.getSelected().setLedIndex(((TextBox)KyUI.get("ks_ledindex")).valueI);
    }
  };
  ((TabLayout)KyUI.get("ks_filetabs")).tabSelectListener=new ItemSelectListener() {
    public void onEvent(int index) {
      selectKsTab(index-1);
    }
  };
  ((TabLayout)KyUI.get("ks_filetabs")).tabRemoveListener=new ItemSelectListener() {
    public void onEvent(int index) {
      ksTabs.get(index).close();
      ksTabs.remove(index);
      if (ksTabs.size()==0) {
        addKsTab(createNewKs());
      }
      ((TabLayout)KyUI.get("ks_filetabs")).onLayout();
    }
  };
  ((TabLayout)KyUI.get("ks_filetabs")).addTabListener=new EventListener() {
    public void onEvent(Element e) {
      addKsTab(createNewKs());
    }
  };
}
void loadKs() {
}
void saveKs(KsSession ks) {
  String filename=joinPath(path_global, path_projects+"/"+filterString(ks.file.getAbsolutePath(), new String[]{"\\", "/", ":", "*", "?", "\"", "<", ">", "|"}));
}
KsSession addKsTab(String filename) {
  TabLayout tabs=((TabLayout)KyUI.get("ks_filetabs"));
  tabs.addTab(getFileName(filename), new Element("ks_"+filename));
  KyUI.taskManager.executeAll();
  KsSession tab=new KsSession(filename);
  ksTabs.add(tab);
  tabs.onLayout();
  tabs.onLayout();//????
  tabs.selectTab(ksTabs.size());
  return tab;
}
void selectKsTab(int index) {
  currentKs=ksTabs.get(index);
  ((ImageToggleButton)KyUI.get("ks_loop")).value=currentKs.loop;
  ((FrameSlider)KyUI.get("ks_frameslider")).valueS=currentKs.loopStart;
  ((FrameSlider)KyUI.get("ks_frameslider")).valueE=currentKs.loopEnd;
  ((PadButton)KyUI.get("ks_pad")).size.set(info.buttonX, info.buttonY);
  KyUI.get("ks_pad").invalidate();
}