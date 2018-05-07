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
  ArrayList<String[][]> countText;
  ArrayList<String[][]> autoPlayOrder;
  //
  IntVector2 selection=new IntVector2(0, 0);
  int chain=0;//selected chain
  KsSession(String name_) {
    name=getFileName(name_);
    file=new File(name_);
    Thread thread=new Thread(light=new LightThread());
    light.thread=thread;
    player = new MultiSamplePlayer(ksac, 10);
    resize(info.buttonX, info.buttonY, 8);
    thread.start();
  }
  void textControl() {
    if (currentKs==this) {
      if (ksControl_selected==1) {
        ks_pad.textControl(countText.get(chain));
      } else {
        ks_pad.textControl(autoPlayOrder.get(chain));
      }
    }
  }
  KsButton getSelected() {
    return KS.get(chain)[selection.x][selection.y];
  }
  KsButton get(int c, int x, int y) {
    if (c<0||c>=KS.size()) {
      System.err.println("error occurred!");
      c=KS.size()-1;//...
    }
    return KS.get(c)[x][y];
  }
  void resize(int x, int y, int c) {//parameter order...fix
    info.buttonX=x;
    info.buttonY=y;
    info.chain=c;
    notePress=new boolean[info.buttonX][info.buttonY];
    ArrayList<KsButton[][]> KS_=KS;
    ArrayList<String[][]> countText_=countText;
    ArrayList<String[][]> autoPlayOrder_=autoPlayOrder;
    KS=new ArrayList<KsButton[][]>();
    countText=new ArrayList<String[][]>();
    autoPlayOrder=new ArrayList<String[][]>();
    for (int ch=0; ch<info.chain; ch++) {
      KS.add(new KsButton[info.buttonX][info.buttonY]);
      countText.add(new String[info.buttonX][info.buttonY]);
      autoPlayOrder.add(new String[info.buttonX][info.buttonY]);
      for (int a=0; a<info.buttonX; a++) {
        for (int b=0; b<info.buttonY; b++) {
          if (KS_!=null&&ch<KS_.size()&&a<KS_.get(ch).length&&b<KS_.get(ch)[a].length) {
            KS.get(ch)[a][b]=KS_.get(ch)[a][b];
            countText.get(ch)[a][b]=countText_.get(ch)[a][b];
            autoPlayOrder.get(ch)[a][b]=autoPlayOrder_.get(ch)[a][b];
          } else {
            KS.get(ch)[a][b]=new KsButton(this, new IntVector3(a, b, ch));
            countText.get(ch)[a][b]="0\n0";
            autoPlayOrder.get(ch)[a][b]="";
          }
        }
      }
    }
    setChanged(true, false);
  }
  void selectChain(int c) {
    chain=c;
    textControl();//#TEST
    resetIndex(chain);
  }
  void resetIndex(int chain) {
    if (chain<0||chain>=KS.size()) {
      return;
    }
    KsButton[][] btns=KS.get(chain);
    for (int a=0; a<btns.length; a++) {
      for (int b=0; b<btns[a].length; b++) {
        btns[a][b].resetIndex();
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
  LinkedList<InspectorButton1> ledList;
  LinkedList<InspectorButton1> soundList;
  int ledIndex=0;
  int soundIndex=0;
  public KsButton(KsSession session_, IntVector3 pos_) {
    session=session_;
    pos=pos_;
    led=new ArrayList<LedCounter>();
    sound=new ArrayList<MultiSamplePlayer.SampleState>();
    ledList=new LinkedList<InspectorButton1>();
    soundList=new LinkedList<InspectorButton1>();
  }
  @Override void finalize() {//when KsButton is deleted...still samples are alive.
    for (int a=sound.size()-1; a>=0; a--) {
      removeSound(a);
    }
  }
  void set(KsButton other) {
    led=other.led;
    sound=other.sound;
    ledIndex=other.ledIndex;
    soundIndex=other.soundIndex;
  }
  void setSoundIndex(int index) {
    soundIndex=max(0, min(index, sound.size()-1));
    session.setChanged(true, false);
  }
  void setLedIndex(int index) {
    ledIndex=max(0, min(index, led.size()-1));
    session.setChanged(true, false);
  }
  void loadSound(String path, int loop) {
    loadSound(sound.size(), path, loop);
  } 
  void loadSound(int index, String path, int loop) {//must path exists!
    if (!new File(path).isFile()) {
      return;
    }
    final MultiSamplePlayer.SampleState sample=session.player.load(path);
    if (samples.containsKey(sample.sample)) {
      samples.get(sample.sample).add(this);
    } else {
      ArrayList<KsButton> list =new ArrayList<KsButton>();
      list.add(this);
      samples.put(sample.sample, list);
    }
    sound.add(index, sample);
    sample.link=this;
    setSoundLoop(index, loop);
    final InspectorButton1<Integer, TextBox> ins=new InspectorButton1<Integer, TextBox>("", new TextBox("").setNumberOnly(TextBox.NumberType.INTEGER));
    ins.addedTo(((LinearList)KyUI.get("ks_sound")).listLayout);
    soundList.add(index, ins);
    ins.setDataChangeListener(new EventListener() {
      public void onEvent(Element e) {
        setSoundLoop(sound.indexOf(sample), (int)ins.get());
      }
    }
    );
    ins.set(loop);
    ins.text=getFileName(path);
    if (this==currentKs.getSelected()) {
      KyUI.taskManager.addTask(new Task() {
        public void execute(Object o) {
          onSelect();
        }
      }
      , null);
    }
    session.countText.get(pos.z)[pos.x][pos.y]=sound.size()+"\n"+led.size();
    session.setChanged(true, false);
  }
  void reorderSound(int a, int b) {//must in range!
    Collections.swap(sound, a, b);
    session.setChanged(true, false);
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
    soundList.remove(index);
    session.countText.get(pos.z)[pos.x][pos.y]=sound.size()+"\n"+led.size();
    if (this==currentKs.getSelected()) {
      KyUI.taskManager.addTask(new Task() {
        public void execute(Object o) {
          onSelect();
        }
      }
      , null);
    }
    session.setChanged(true, false);
  }
  String getSound(int index) {
    return sound.get(index).sample.getFileName();
  }
  void setSoundLoop(int index, int loop) {
    //println("set loop to "+loop);
    sound.get(index).loopCount=loop;
    session.setChanged(true, false);
  }
  int getSoundLoop(int index) {
    return sound.get(index).loopCount;
  }
  void loadLed(String path, int loop) {
    loadLed(led.size(), path, loop);
  }
  public void loadLed(int index, String path, int loop) {
    if (!new File(path).isFile()) {
      return;
    }
    loadLed(index, loadLedScript(path, readLed(path)), loop);
  }
  void loadLed(LedScript script, int loop) {
    loadLed(led.size(), script, loop);
  }
  void loadLed(final int index, LedScript script, int loop) {
    script.displayPad=ks_pad;
    led.add(index, session.light.addTrack(script));
    led.get(index).link=this;
    setLedLoop(index, loop);
    final InspectorButton1<Integer, TextBox> ins=new InspectorButton1<Integer, TextBox>("", new TextBox("").setNumberOnly(TextBox.NumberType.INTEGER));
    ins.addedTo(((LinearList)KyUI.get("ks_led")).listLayout);
    ledList.add(index, ins);
    ins.setDataChangeListener(new EventListener() {
      public void onEvent(Element e) {
        setLedLoop(led.indexOf(led.get(index)), (int)ins.get());
      }
    }
    );
    ins.set(loop);
    ins.text=script.name;
    if (this==currentKs.getSelected()) {
      KyUI.taskManager.addTask(new Task() {
        public void execute(Object o) {
          onSelect();
        }
      }
      , null);
    }
    session.countText.get(pos.z)[pos.x][pos.y]=sound.size()+"\n"+led.size();
    session.setChanged(true, false);
  }
  void reorderLed(int a, int b) {
    Collections.swap(led, a, b);
    session.setChanged(true, false);
  }
  void removeLed(int index) {
    session.light.removeTrack(led.get(index));
    led.remove(index);
    soundList.remove(index);
    session.countText.get(pos.z)[pos.x][pos.y]=sound.size()+"\n"+led.size();
    if (this==currentKs.getSelected()) {
      KyUI.taskManager.addTask(new Task() {
        public void execute(Object o) {
          onSelect();
        }
      }
      , null);
    }
    session.setChanged(true, false);
  }
  LedScript getLed(int index) {
    return led.get(index).script;
  }
  void setLedLoop(int index, int loop) {
    led.get(index).loopCount=loop;
    session.setChanged(true, false);
  }
  int getLedLoop(int index) {
    return led.get(index).loopCount;
  }
  void resetIndex() {
    ledIndex=0;
    soundIndex=0;
  }
  void onSelect() {
    //update led,sound list and indexes.
    ((LinearList)KyUI.get("ks_led")).setItems((java.util.List)ledList);
    ((LinearList)KyUI.get("ks_sound")).setItems((java.util.List)soundList);
    KyUI.get("ks_led").onLayout();
    KyUI.get("ks_led").invalidate();
    KyUI.get("ks_sound").onLayout();
    KyUI.get("ks_sound").invalidate();
    ((TextBox)KyUI.get("ks_ledindex")).setText(ledIndex+"");
    ((TextBox)KyUI.get("ks_soundindex")).setText(soundIndex+"");
    ((TextBox)KyUI.get("ks_ledindex")).error=false;
    ((TextBox)KyUI.get("ks_soundindex")).error=false;
    KyUI.get("ks_ledindex").invalidate();
    KyUI.get("ks_soundindex").invalidate();
  }
  void noteOn() {
    noteOff();
    //if (!session.notePress[pos.x][pos.y]) {
    if (sound.size()>0) {
      if (soundIndex>=sound.size()) {
        soundIndex=0;
      }
      session.player.rewind(sound.get(soundIndex));
      session.player.play(sound.get(soundIndex));
      soundIndex++;
    }
    if (led.size()>0) {
      if (ledIndex>=led.size()) {
        ledIndex=0;
      }
      session.light.start(led.get(ledIndex), 0);
      ledIndex++;
    }
    session.notePress[pos.x][pos.y]=true;
    println("chain "+pos.z+", ("+pos.x+", "+pos.y+") note on");
    //}
  }
  void noteOff() {
    if (session.notePress[pos.x][pos.y]) {
      if (sound.size()>0&&soundIndex-1>=0&&soundIndex-1<sound.size()&&sound.get(soundIndex-1).loopCount==0) {
        session.player.stop(sound.get(soundIndex-1));
      }
      if (led.size()>0&&ledIndex-1>=0&&ledIndex-1<led.size()&&led.get(ledIndex-1).loopCount==0) {
        //session.light.stop(led.get(ledIndex-1));
        synchronized(led.get(ledIndex-1)) {
          led.get(ledIndex-1).loopIndex=-1;
        }
        session.light.midiControl(session.light.velDisplay);
        ks_pad.invalidate();
      }
      println("chain "+pos.z+", ("+pos.x+", "+pos.y+") note off");
      session.notePress[pos.x][pos.y]=false;
    }
  }
}
void ks_setup() {
  ((TabLayout)KyUI.get("ks_control")).tabSelectListener=new ItemSelectListener() {
    public void onEvent(int index) {
      ksControl_selected=index;
      currentKs.textControl();
      ks_pad.invalidate();
    }
  };
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
      externalFrame=KS_INFO;
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
            currentKs.info.set(ksinfo_title.getText(), ksinfo_producername.getText(), ksinfo_buttony.valueI, ksinfo_buttonx.valueI, ksinfo_chain.valueI, ksinfo_squarebuttons.value);
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
            externalFrame=NONE;
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
        currentKs.get(currentKs.chain, coord.x, coord.y).noteOn();
      } else if (action==PadButton.RELEASE_R) {
        currentKs.selection.set(coord);
        //ks_pad.selected.set(coord);
        currentKs.getSelected().onSelect();
      } else if (action==PadButton.DRAG_L||action==PadButton.DRAG_R) {
        if (!coord.equals(click)) {
          currentKs.get(currentKs.chain, click.x, click.y).noteOff();
        }
      } else if (action==PadButton.RELEASE_L) {
        currentKs.selection.set(coord);
        //ks_pad.selected.set(coord);
        currentKs.get(currentKs.chain, coord.x, coord.y).noteOff();
        currentKs.getSelected().onSelect();
      }
    }
  };
  ((PadButton)KyUI.get("ks_chain")).buttonListener=new PadButton.ButtonListener() {
    public void accept(IntVector2 click, IntVector2 coord, int action) {
      if (action==PadButton.PRESS_L) {
        currentKs.selectChain(coord.y);
        currentKs.getSelected().onSelect();
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
      if ( currentKs.getSelected().sound.size()!=0) {
        ui_textValueRange((TextBox)e, 1, currentKs.getSelected().sound.size());
        currentKs.getSelected().setSoundIndex(((TextBox)e).valueI-1);
      }
    }
  };
  ((TextBox)KyUI.get("ks_ledindex")).onTextChangeListener=new EventListener() {
    public void onEvent(Element e) {
      if ( currentKs.getSelected().led.size()!=0) {
        ui_textValueRange((TextBox)e, 1, currentKs.getSelected().led.size());
        currentKs.getSelected().setLedIndex(((TextBox)e).valueI-1);
      }
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
KsSession loadKs(String filename) {
  File file=new File(filename);
  println("load ks : "+filename);
  if (file.isDirectory()) {//and exists
    File infof=new File(joinPath(filename, "info"));
    File keySoundf=new File(joinPath(filename, "keySound"));
    File soundsf=new File(joinPath(filename, "sounds"));
    File keyLEDf=new File(joinPath(filename, "keyLED"));
    File autoPlayf=new File(joinPath(filename, "autoPlay"));
    KsSession session=new KsSession(filename);
    UnipackInfo infoBackup=info;
    if (infof.isFile()) {
      println("load info "+infof.getAbsolutePath());
      session.info=UnipackInfo.loadUnipackInfo(filename, readFile(infof.getAbsolutePath()));
      session.resize( session.info.buttonX, session.info.buttonY, session.info.chain);
      info=session.info;
    } else {
      System.err.println("info is not a file : "+infof.getAbsolutePath());
    }
    if (keySoundf.isFile()) {
      println("load sound "+soundsf.getAbsolutePath());
      CommandScript script=new CommandScript(keySoundf.getAbsolutePath().replace("\\", "/")).setAnalyzer(new DelimiterParser(ksCommands, LineCommandProcessor.DEFAULT_PROCESSOR));
      script.insert(readFile(keySoundf.getAbsolutePath()));
      ArrayList<Command> commands=script.getCommands();
      for (Command cmd_ : commands) {
        if (cmd_ instanceof KsCommand) {
          KsCommand cmd=(KsCommand)cmd_;
          //println("load : "+cmd.filename);
          if (0<cmd.x&&cmd.x<=session.info.buttonX&&0<cmd.y&&cmd.y<=session.info.buttonY&&0<cmd.c&&cmd.c<=session.info.chain) {
            if (cmd.relative) {
              session.get(cmd.c-1, cmd.x-1, cmd.y-1).loadSound(joinPath(soundsf.getAbsolutePath(), cmd.filename), cmd.loop);
            } else {
              println(cmd.filename);
              session.get(cmd.c-1, cmd.x-1, cmd.y-1).loadSound(cmd.filename, cmd.loop);
            }
          } else {
            System.err.println("chain out of range found in keyLED file! loading ignored");
          }
        }
      }
    } else {
      System.err.println("keySound is not a file : "+keySoundf.getAbsolutePath());
    }
    if (keyLEDf.isDirectory()) {
      println("load led "+keyLEDf.getAbsolutePath());
      File[] files=keyLEDf.listFiles();
      for (int a=0; a<files.length; a++) {
        String[] tokens=split(getExtensionElse(getFileName(files[a].getAbsolutePath())), " ");
        if (tokens.length>3) {
          if (Analyzer.isInt(tokens[0])&&Analyzer.isInt(tokens[1])&&Analyzer.isInt(tokens[2])&&Analyzer.isInt(tokens[3])) {
            int c=int(tokens[0]);
            int x=int(tokens[2]);
            int y=int(tokens[1]);
            int loop=int(tokens[3]);
            if (0<x&&x<=session.info.buttonX&&0<y&&y<=session.info.buttonY&&0<c&&c<=session.info.chain) {
              println("load : "+files[a].getAbsolutePath());
              session.get(c-1, x-1, y-1).loadLed(files[a].getAbsolutePath().replace("\\", "/"), loop);
            } else {
              System.err.println("chain out of range found in keyLED file! loading ignored");
            }
          }
        }
      }
    } else if (keyLEDf.isFile()) {
      println("load led(file) "+keyLEDf.getAbsolutePath());
      CommandScript script=new CommandScript(keyLEDf.getAbsolutePath().replace("\\", "/")).setAnalyzer(new DelimiterParser(ksCommands, LineCommandProcessor.DEFAULT_PROCESSOR));
      script.insert(readFile(keyLEDf.getAbsolutePath()));
      ArrayList<Command> commands=script.getCommands();
      for (Command cmd_ : commands) {
        if (cmd_ instanceof KsCommand) {
          KsCommand cmd=(KsCommand)cmd_;
          if (cmd.relative) {
            System.err.println("relative path found in keyLED file! loading ignored");
            //session.get(cmd.c-1, cmd.x-1, cmd.y-1).loadLed(joinPath(file.getAbsolutePath(), cmd.filename),cmd.loop);
          } else {
            if (0<cmd.x&&cmd.x<=session.info.buttonX&&0<cmd.y&&cmd.y<=session.info.buttonY&&0<cmd.c&&cmd.c<=session.info.chain) {
              session.get(cmd.c-1, cmd.x-1, cmd.y-1).loadLed(cmd.filename, cmd.loop);
            } else {
              System.err.println("chain out of range found in keyLED file! loading ignored");
            }
          }
        }
      }
    }//else just ignore.
    if (autoPlayf.isFile()) {
      String autoPlayPath=autoPlayf.getAbsolutePath();
      session.autoPlay=loadApScript(autoPlayPath, readFile(autoPlayPath));
    }
    info=infoBackup;
    return session;
  } else {
    System.err.println("folder not exists : "+filename);
  }
  return null;
}
void saveKs(KsSession ks, boolean canonical) {
  if (ks.changed||canonical) {
    String path=joinPath(path_global, path_projects+"/"+filterString(ks.file.getAbsolutePath(), new String[]{"\\", "/", ":", "*", "?", "\"", "<", ">", "|"}));
    //new File(joinPath(path,"sounds")).mkdirs();
    //setting canonical to true copies all sounds and led. unipack export is canonical true.
    String text="";
    String ledtext="";
    int a=0;
    while (a<ks.KS.size()) {
      int b=0;
      while (b<ks.KS.get(a).length) {
        int c=0;
        while (c<ks.KS.get(a)[b].length) {
          int d=0;
          while (d<ks.get(a, b, c).sound.size()) {
            if (canonical) {
              text=text+"\n"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" "+getFileName(ks.get(a, b, c).sound.get(d).sample.getFileName()).replace(" ", "_")+" "+ks.get(a, b, c).getSoundLoop(d);
            } else {
              text=text+"\n"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" \""+ks.get(a, b, c).sound.get(d)+"\" "+ks.get(a, b, c).sound.get(d);
            }
            d=d+1;
          }
          d=0;
          if (canonical) {
            while (d<ks.get(a, b, c).sound.size()) {
              copyFile(ks.get(a, b, c).sound.get(d).sample.getFileName(), joinPath(path, "sounds/"+getFileName(ks.get(a, b, c).sound.get(d).sample.getFileName()).replace(" ", "_")));
              d=d+1;
            }
            d=0;
            while (d<ks.KS.get(a)[b][c].led.size()) {//not just copy, clear and rename.
              try {
                writeFile(joinPath(path, "keyLED/"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" "+ks.get(a, b, c).getLedLoop(d)+" "+str(char(d+'a'))), ToUnipadLed(ks.get(a, b, c).led.get(d).script));
              }
              catch(Exception e) {
                e.printStackTrace();
              }
              d=d+1;
            }
          } else {
            while (d<ks.KS.get(a)[b][c].led.size()) {
              ledtext=ledtext+"\n"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" \""+ks.get(a, b, c).led.get(d)+"\" "+ks.get(a, b, c).getLedLoop(d);
              d=d+1;
            }
          }
          c=c+1;
        }
        b=b+1;
      }
      a=a+1;
    }
    writeFile(joinPath(path, "keySound"), text);
    if (canonical==false)writeFile(joinPath(path, "keyLED"), ledtext);
    writeFile(joinPath(path, "info"), ks.info.toString());
  }
  ks.setChanged(false, false);
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
KsSession addKsFileTab(String filename) {
  TabLayout tabs=((TabLayout)KyUI.get("ks_filetabs"));
  tabs.addTab(getFileName(filename), new Element("ks_"+filename));
  KyUI.taskManager.executeAll();
  KsSession tab=loadKs(filename);
  ksTabs.add(tab);
  tabs.onLayout();
  tabs.onLayout();//????
  tabs.selectTab(ksTabs.size());
  return tab;
}
void selectKsTab(int index) {
  //index<selection sequence change
  if (index>=ksTabs.size()) {
    System.err.println("selectks index : "+index);
  }
  currentKs=ksTabs.get(index);
  ((ImageToggleButton)KyUI.get("ks_loop")).value=currentKs.loop;
  ((FrameSlider)KyUI.get("ks_frameslider")).valueS=currentKs.loopStart;
  ((FrameSlider)KyUI.get("ks_frameslider")).valueE=currentKs.loopEnd;
  ks_pad.size.set(currentKs.info.buttonX, currentKs.info.buttonY);
  ks_pad.selected.set(currentKs.selection);
  currentKs.light.checkDisplay(ks_pad);
  ks_pad.displayControl(currentKs.light.display);
  currentKs.light.midiControl(currentKs.light.velDisplay);
  currentKs.textControl();
  currentKs.getSelected().onSelect();
  ((PadButton)KyUI.get("ks_chain")).size.set(1, currentKs.info.chain);
  ((PadButton)KyUI.get("ks_chain")).selected.set(0, currentKs.chain);
  ks_pad.invalidate();
  ((PadButton)KyUI.get("ks_chain")).invalidate();
}