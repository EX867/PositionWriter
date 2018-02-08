HashMap<Sample, ArrayList<KsButton>> samples=new HashMap<Sample, ArrayList<KsButton>>();
ArrayList<KsButton> emptyKsButtonArray=new ArrayList<KsButton>();
class KsSession {//
  String name;
  LightThread light;//includes display.
  File file;//project name
  UnipackInfo info;
  LedScript autoPlay;//#ADD
  AudioContext ksac=new AudioContext();
  MultiSamplePlayer player = new MultiSamplePlayer(ksac, 10);
  IntVector2 selection=new IntVector2(1, 1);
  int chain=0;//selected chain
  ArrayList<KsButton[][]> KS=new ArrayList<KsButton[][]>();
  KsSession(String name_) {
    name=getFileName(name_);
    file=new File(name_);
    Thread thread=new Thread(light=new LightThread());
    light.thread=thread;
    player.onEnd=new Predicate<MultiSamplePlayer.SampleState>() {
      public boolean test(MultiSamplePlayer.SampleState sample) {
        return true;
      }
    };
    light.onEnd=new Predicate<LedCounter>() {
      public boolean test(LedCounter counter) {
        return true;
      }
    };
    info=new UnipackInfo();
    thread.start();
  }
  KsButton getSelected() {
    return KS.get(chain)[selection.x][selection.y];
  }
  void close() {
    light.active=false;
    ksac.stop();
    player.close();
  }
}
class KsButton {
  IntVector2 pos;
  KsSession session;
  ArrayList<LedCounter> led;
  ArrayList<Sample> sound;
  int ledIndex=0;
  int soundIndex=0;
  public KsButton(KsSession session_, IntVector2 pos_) {
    session=session_;
    pos=pos_;
    led=new ArrayList<LedCounter>();
    sound=new ArrayList<Sample>();
  }
  void loadSound(String path) {
    loadSound(sound.size(), path);
  } 
  void loadSound(int index, String path) {//must path exists!
    Sample sample=session.player.load(path);
    if (samples.containsKey(sample)) {
      samples.get(sample).add(this);
    } else {
      ArrayList<KsButton> list =new ArrayList<KsButton>();
      list.add(this);
      samples.put(sample, list);
    }
    sound.add(index, sample);
  }
  void reorderSound(int a, int b) {//must in range!
    Collections.swap(sound, a, b);
  }
  void removeSound(int index) {//must in range!
    Sample sample=sound.get(index);
    if (samples.getOrDefault(sample, emptyKsButtonArray).size()==1) {
      samples.remove(sample);
      SampleManager.removeSample(sample);
    } else {//must contains!
      samples.get(sample).remove(this);
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
  void forwardSound() {
  }
  void forwardLed() {
  }
}
void ks_setup() {
  ((TextBox)KyUI.get("ks_soundindex")).onTextChangeListener=new EventListener() {
    public void onEvent(Element e) {
    }
  };
  ((TextBox)KyUI.get("ks_ledindex")).onTextChangeListener=new EventListener() {
    public void onEvent(Element e) {
      currentKs.getSelected().ledIndex=((TextBox)KyUI.get("ks_ledindex")).valueI;
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
  KsSession tab=new KsSession(filename);
  ksTabs.add(tab);
  tabs.onLayout();
  tabs.onLayout();//???????????
  tabs.selectTab(ksTabs.size());
  return tab;
}
void selectKsTab(int index) {
  currentKs=ksTabs.get(index);
  midiOffAll(currentKs.light.deviceLink);
  currentLedEditor.displayControl();
  ((ImageToggleButton)KyUI.get("led_loop")).value=currentLed.led.loop;
  currentLedEditor.displayPad.size.set(info.buttonX, info.buttonY);
  currentLedEditor.displayPad.invalidate();
}