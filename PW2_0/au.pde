import it.sauronsoftware.jave.*;
import java.util.Arrays;
import java.util.List;
import pw2.beads.SampleLoader;
AudioContext globalAc;
String sampleTimeFormat(double d) {//d is milliseconds
  int floored=(int)d;
  int sec=(floored)/1000;
  //return intFormat(sec)+":"+intFormat(floored-sec);
  return sec+":"+(floored-sec*1000);
}
class SamplePlayer2 extends SamplePlayer {
  Slider mp3_slider;
  Button mp3_time;
  public SamplePlayer2(AudioContext ac, int channels) {
    super(ac, channels);
    mp3_slider=(Slider)KyUI.get("mp3_slider");
    mp3_time=(Button)KyUI.get("mp3_time");
  }
  void updateTime() {
    if (sample==null) {
      return;
    }
    mp3_time.text=sampleTimeFormat(getPosition())+"/"+sampleTimeFormat(sample.getLength());
    mp3_time.invalidate();
  }
  void setPositionBySlider() {
    if (sample==null) {
      return;
    }
    setPosition(sample.getLength()*mp3_slider.value/mp3_slider.max);
  }
  public void calculateBuffer() {
    if (!isPaused()&&KyUI.getRoot()==frame_mp3) {//externalFrame==MP3_CONVERTER
      mp3_slider.set(0, (float)sample.getLength(), (float)getPosition());
      mp3_slider.invalidate();
      updateTime();
    }
    if (position>sample.getLength()&&loopType==LoopType.NO_LOOP_FORWARDS) {
      position=sample.getLength();
      pause(true);
      return;
    }
    super.calculateBuffer();
  }
  //String intFormat(int i) {
  //  if (i<10) {
  //    return "0"+i;
  //  } else {
  //    return ""+i;
  //  }
  //}
}
SamplePlayer2 globalSamplePlayer;
void au_setup() {
  globalAc=new AudioContext();
  globalSamplePlayer=new SamplePlayer2(globalAc, 2);
  globalSamplePlayer.setKillOnEnd(false);
  globalAc.out.addInput(globalSamplePlayer);
  //globalSamplePlayer.setEndListener(new Bead() {
  //  public void messageReceived(Bead message) {
  //    //globalAc.stop();
  //  }
  //});
}
void globalSamplePlayerPlay(String path) {//use for temporary play files
  try {
    globalSamplePlayer.setSample(new Sample(path));
    //println("play : "+globalSamplePlayer.getSample().getFileName());
    if (!globalAc.isRunning()) {
      globalAc.start();
    }
    globalSamplePlayer.setPosition(0);
    globalSamplePlayer.start();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
FFmpegConverter converter=new FFmpegConverter();
public class FFmpegConverter {//play with globalSamplePlayer
  int converting=0;
  int converted=0;
  int successCount=0;
  String selection="";
  boolean checkDecodable(String input) {
    return new File(input).isFile();
    //MultimediaInfo info=new it.sauronsoftware.jave.Encoder().getInfo(file);
  }
  boolean checkEncodable(String outputFormat, String outputCodec) throws Exception {
    List<String> encodings=Arrays.asList(new it.sauronsoftware.jave.Encoder().getSupportedEncodingFormats());
    List<String> formats=Arrays.asList(new it.sauronsoftware.jave.Encoder().getAudioEncoders());
    return encodings.contains(outputFormat)&&formats.contains(outputCodec);
  }
  class ModEncodingListener implements EncoderProgressListener {
    String filename;
    ModEncodingListener(String filename_) {
      filename=filename_;
    }
    public void sourceInfo(MultimediaInfo info) {
    }
    public void progress(int permil) {//0 to 1000
      if (permil>=1000) {
        ((ConsoleEdit)KyUI.get("log_content")).addLine("File : "+filename+"\n   / convert finised\n");
        converted++;
        if (converting==converted) {
          ((ConsoleEdit)KyUI.get("log_content")).addLine("Event : converting all files finished ("+converted+" of "+converting+")\n   successed : "+successCount+"\n");
          ((ImageButton)KyUI.get("log_exit")).setEnabled(true);
          ((ImageButton)KyUI.get("log_exit")).invalidate();
          converting=0;
          converted=0;
          setTitleProcessing();
        }
        ((ConsoleEdit)KyUI.get("log_content")).invalidate();
      }
    }
    public void message(java.lang.String message) {
      //do nothing
    }
  }
  void convertAll(String[] input, String outputFolder, String outputFormat, String outputCodec, int outputBitRate, int outputChannels, int outputSampleRate) {
    if (input.length==0)return;
    new Thread(new ThreadConverter(input, outputFolder, outputFormat, outputCodec, outputBitRate, outputChannels, outputSampleRate)).start();
  }
  public class ThreadConverter implements Runnable {
    String[] input;
    String output;
    String outputFormat;
    String outputCodec;
    int outputBitRate;
    int outputChannels;
    int outputSampleRate;
    ThreadConverter(String[] input_, String output_, String outputFormat_, String outputCodec_, int outputBitRate_, int outputChannels_, int outputSampleRate_) {
      input=input_;
      output=output_;
      outputFormat=outputFormat_;
      outputCodec=outputCodec_;
      outputBitRate=outputBitRate_;
      outputChannels=outputChannels_;
      outputSampleRate=outputSampleRate_;
    }
    @Override
      public void run() {
      ((ImageButton)KyUI.get("log_exit")).setEnabled(false);
      ((ImageButton)KyUI.get("log_exit")).invalidate();
      converted=0;
      successCount=0;
      converting=input.length;
      for (int a=0; a<input.length; a++) {
        setTitleProcessing("converting...("+converted+"/"+converting+")");
        if (converter.checkDecodable(input[a])) {
          try {
            String input=this.input[a];
            String output=joinPath(this.output, changeFormat(getFileName(input), outputFormat));
            it.sauronsoftware.jave.Encoder encoder=new it.sauronsoftware.jave.Encoder();
            MultimediaInfo info=encoder.getInfo(new File(input));
            ((ConsoleEdit)KyUI.get("log_content")).addLine("File : "+output+"\n   / format : "+info.getFormat()+"\n   / bitRate : "+info.getAudio().getBitRate()+"\n   / channels : "+info.getAudio().getChannels()+"\n   / sampleRate : "+info.getAudio().getSamplingRate()+"\n   / decoder : "+info.getAudio().getDecoder()+"\n").invalidate();
            //check this is decodable(important!)
            if (!Arrays.asList(encoder.getAudioDecoders()).contains(info.getAudio().getDecoder())) {
              throw new Exception("file is not decodable");
            }
            AudioAttributes audio = new AudioAttributes();
            audio.setCodec(outputCodec); // - getAudioEncoders()
            audio.setBitRate(outputBitRate);
            audio.setChannels(outputChannels);
            audio.setSamplingRate(outputSampleRate);
            EncodingAttributes attrs = new EncodingAttributes();
            attrs.setFormat(outputFormat);
            attrs.setAudioAttributes(audio);
            ((ConsoleEdit)KyUI.get("log_content")).addLine("Event : conversion started : "+input+"\n   to "+output+"\n").invalidate();
            println("conversion start "+input+" to "+output);
            encoder.encode(new File(input), new File(output), attrs, new ModEncodingListener(input));
            successCount++;
          }
          catch(Exception e) {
            converted++;
            ((ConsoleEdit)KyUI.get("log_content")).addLine("Error : cannot convert file : "+input[a]+"\n   "+e.toString()+"\n").invalidate();
            e.printStackTrace();
          }
        } else {
          ((ConsoleEdit)KyUI.get("log_content")).addLine("Error : cannot convert file : "+input[a]+"\n   file not exists!\n").invalidate();
          println("cannot convert file : "+input[a]);
          converted++;
        }
      }
      if (successCount==0) {
        ((ConsoleEdit)KyUI.get("log_content")).addLine("Event : none of input files converted.\n").invalidate();
        ((ImageButton)KyUI.get("log_exit")).setEnabled(true);
        ((ImageButton)KyUI.get("log_exit")).invalidate();
        converting=0;
        converted=0;
        setTitleProcessing();
      }
    }
  }
}
public class AutomationButton extends LinearList.SelectableButton {
  public Runnable onPress;
  public AutomationButton(String name) {
    super("AutomationButton_"+((name==null)?"":name));
    if (name==null) {
      name="";
    }
    text=name;
    final MouseEventListener l=getPressListener();
    setPressListener(new MouseEventListener() {
      public boolean onEvent(MouseEvent e, int index) {
        onPress.run();
        return l.onEvent(e, index);
      }
    }
    );
  }
}
void wav_setup(final WavTab tab, final DivisionLayout wv_dv2) {//add listeners (with crazy children.get uses)
  LinearLayout wv_lin1=(LinearLayout)wv_dv2.children.get(0).children.get(0).children.get(0);
  LinearLayout wv_lin2=(LinearLayout)wv_dv2.children.get(0).children.get(0).children.get(1).children.get(0);
  TabLayout wv_fxtabs=(TabLayout)wv_dv2.children.get(0).children.get(1);
  //KyUI.addDragAndDrop(KyUI.get("wv_fxlib"), wv_dv2.children.get(0).children.get(1), new DropEventListener() {
  //  public void onEvent(DropMessenger d, MouseEvent e, int index) {
  //    //add new plugin
  //  }
  //}
  //);
  //wv_fxtabs.tabRemoveListener=new ItemSelectListener() {
  //  public void onEvent(int index) {
  //    tab.editor.player.removeUGenAndAutos(index, tab.autos);
  //  }
  //};
  final Slider ratio=((Slider)wv_dv2.children.get(1));
  ratio.setMin(0);
  ratio.setMax(1);
  final DivisionLayout wv_dv3=((DivisionLayout)wv_dv2.children.get(0));
  ratio.set(1-wv_dv3.value);
  ratio.setAdjustListener(new EventListener() {
    public void onEvent(Element e) {
      wv_dv3.value=1-ratio.value;
      wv_dv3.localLayout();
    }
  }
  );
  ((Button)wv_lin1.children.get(0)).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      WavEditor editor=tab.editor;
      if (editor.player.getPosition() == editor.player.getLoopEndUGen().getValue()) {
        editor.player.setPosition(editor.player.getLoopStartUGen().getValue());
        editor.player.pause(false);
      } else {
        editor.player.pause(!editor.player.isPaused());
      }
      return false;
    }
  }
  );
  //add stop
  tab.editor.setToggleLoop((ImageToggleButton)wv_lin1.children.get(2));
  tab.editor.setToggleSnap((ImageToggleButton)wv_lin2.children.get(0));
  tab.editor.setToggleAutoscroll((ImageToggleButton)wv_lin2.children.get(1));
  tab.editor.setToggleAutomationMode((ImageToggleButton)wv_lin2.children.get(2));
  tab.editor.setSnapGridPlus((Button)wv_lin2.children.get(5));
  tab.editor.setSnapGridMinus((Button)wv_lin2.children.get(6));
  //add defualt plugin (current version only)
  AudioContext ac=tab.wvac;
  TDCompW comp=new TDCompW(ac, tab.editor.sample.getNumChannels());
  AutoFaderW fader=new AutoFaderW(ac, tab.editor.sample.getNumChannels());
  final Slider slider=(Slider)wv_lin1.children.get(3);
  final Button time=(Button)wv_lin1.children.get(4);
  final AutoControlSamplePlayer sp=tab.editor.player;
  wv_fxtabs.addTab("TDComp", tab.compControl=new TDCompControl("wv_tdcomp").initialize(comp));
  wv_fxtabs.addTab("Wavcut", tab.faderControl=new AutoFaderControl("wv_autofader").initialize(fader));
  wv_fxtabs.localLayout();
  tab.faderControl.setPath(joinPath(path_global, path_sources+"/"+getExtensionElse(getFileName(sp.getSample().getFileName()))));
  tab.faderControl.setAsMirror(tab.editor);
  tab.faderControl.view.onAutomationChanged=new Runnable() {//why two times??
    public void run() {
      tab.editor.automationInvalid=true;
      tab.editor.invalidate();
    }
  };
  tab.faderControl.view.snap=false;
  tab.editor.onAutomationChanged=new Runnable() {
    public void run() {
      tab.faderControl.view.automationInvalid=true;
      tab.faderControl.view.invalidate();
    }
  };
  tab.faderControl.progressListener=new BiConsumer<Long, Long>() {
    public void accept(Long count, Long totalCount) {
      setTitleProcessing("saved... (" + count + "/" + totalCount + ")");
    }
  };
  tab.faderControl.endListener=new Consumer<String>() {
    public void accept(String path) {
      setTitleProcessing();
      openFileExplorer(path);
    }
  };
  sp.addInputTo(ac.out);
  sp.onUpdate=new Runnable() {
    public void run() {
      if (/*!sp.isPaused()&&*/mainTabs_selected==WAV_EDITOR&&currentWav==tab) {
        slider.set(0, (float)sp.getSample().getLength(), (float)sp.getPosition());
        time.text=sampleTimeFormat(sp.getPosition())+"/"+sampleTimeFormat(sp.getSample().getLength());
        slider.invalidate();
        time.invalidate();
      }
    }
  };
  slider.setAdjustListener(new EventListener() {
    public void onEvent(Element e) {
      sp.setPosition(sp.getSample().getLength()*slider.value/slider.max);
      sp.onUpdate.run();
      tab.editor.invalidate();
    }
  }
  );
  List<KnobAutomation> autos;
  autos=sp.addUGenAndGetAutos(fader);
  for (KnobAutomation auto : autos) {
    sp.addAuto(auto);
  }
  autos=sp.addUGenAndGetAutos(comp);
  for (KnobAutomation auto : autos) {
    sp.addAuto(auto);
  }
  //
  final TextBox offset = new TextBox("", "grid offset (milliseconds)", "1386.0545");
  offset.setNumberOnly(TextBox.NumberType.FLOAT);
  offset.onTextChangeListener = new EventListener() {
    public void onEvent(Element e) {
      tab.editor.snapOffset = offset.valueF;
      tab.editor.invalidate();
    }
  };
  offset.setText("0");
  final TextBox bpm = new TextBox("", "bpm", "140");
  bpm.setNumberOnly(TextBox.NumberType.FLOAT);
  bpm.onTextChangeListener = new EventListener() {
    public void onEvent(Element e) {
      tab.editor.snapBpm = bpm.valueF;
      tab.editor.invalidate();
    }
  };
  bpm.setText("120");
  Knob speedKnob = new Knob("");
  speedKnob.label = "speed";
  speedKnob.attach(ac, sp, sp.setSpeed, 0.4, 2, 1, 1, false);
  AlterLinearLayout layout=new AlterLinearLayout("");
  DivisionLayout ud=new DivisionLayout("");
  ud.mode=DivisionLayout.Behavior.PROPORTIONAL;
  ud.value=0.5;
  ud.rotation=Attributes.Rotation.UP;
  ud.addChild(bpm);
  ud.addChild(offset);
  layout.addChild(ud);
  layout.addChild(speedKnob);
  //
  KyUI.taskManager.executeAll();
  //
  layout.set(ud, AlterLinearLayout.LayoutType.STATIC, 1);
  layout.set(speedKnob, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1);
  wv_fxtabs.addTab("Other", layout);
  wv_fxtabs.localLayout();
  //
  wv_fxtabs.selectTab(1);
  tab.editor.automation=fader.cuePoint;
  LinearList autoList=(LinearList)KyUI.get("wv_points");
  if (autoList.size()==0) {
    for (int a=0; a<sp.autos.size(); a++) {
      AutomationButton b=new AutomationButton(sp.autos.get(a).getName());
      final int a_=a;
      b.onPress=new Runnable() {
        public void run() {
          currentWav.editor.automation=currentWav.editor.player.autos.get(a_);
          currentWav.editor.automationInvalid=true;
          currentWav.editor.invalidate();
        }
      };
      autoList.addItem(b);
    }
  }
  sp.pause(true);
}
void wav_setup() {
  ((TabLayout)KyUI.get("wv_filetabs")).tabSelectListener=new ItemSelectListener() {
    public void onEvent(int index) {
      selectWavTab(index-1);
    }
  };
  ((TabLayout)KyUI.get("wv_filetabs")).tabRemoveListener=new ItemSelectListener() {
    public void onEvent(final int index) {
      final Runnable run=new Runnable() {
        public void run() {
          wavTabs.get(index).close();
          wavTabs.remove(index);
          if (wavTabs.size()==0) {
            //instead of adding new tab, just set current to null. it can be done becauase waveditor has no extra sharing state.
            selectWavTab(-1);
          }
          KyUI.get("wv_filetabs").localLayout();
          ((TabLayout)KyUI.get("wv_filetabs")).removeTab(index);
        }
      };
      externalFrame=DIALOG;
      ((Button)KyUI.get("dialog_yes")).setPressListener(new MouseEventListener() {
        public boolean onEvent(MouseEvent e, int i) {
          KyUI.removeLayer();
          externalFrame=NONE;
          saveWav(wavTabs.get(index));
          run.run();
          return false;
        }
      }
      );
      ((Button)KyUI.get("dialog_no")).setPressListener(new MouseEventListener() {
        public boolean onEvent(MouseEvent e, int i) {
          KyUI.removeLayer();
          externalFrame=NONE;
          run.run();
          return false;
        }
      }
      );
      KyUI.addLayer(frame_dialog);
    }
  };
}
static class WavTab {
  AudioContext wvac=new AudioContext();//so we have 1+kstabs_count+wavtabs_count audiocontexts...is it okay???(or I can optimize it to 2+kstabs_count...)
  WavEditor editor;
  TDCompControl compControl;
  AutoFaderControl faderControl;
  public ArrayList<KnobAutomation> autos=new ArrayList<KnobAutomation>();
  WavTab(WavEditor editor_) {
    editor=editor_;
    editor.initPlayer(wvac);
    //setup finished in wav_setup()
    wvac.start();
  }
  void close() {
    editor.player.kill();
    wvac.stop();
  }
}
void addWavTab(final String filename) {//no null filename!
  SampleLoader.loadSample(filename, joinPath(path_global, path_tempSamples), 
    new Consumer<Sample>() {
    public void accept(Sample sample) {//is sample loading failed, nothing happen.
      TabLayout tabs=((TabLayout)KyUI.get("wv_filetabs"));
      Element e=tabs.addTabFromXmlPath(getFileName(filename), layout_wv_frame_xml, "layout_wv_frame.xml", null);
      KyUI.taskManager.executeAll();//add elements
      final DivisionLayout dv11=(DivisionLayout)e.children.get(0).children.get(0).children.get(0).children.get(1).children.get(1);//crazy!!!
      WavEditor editor=null;
      dv11.addChild(editor=new WavEditor("wv_editor"));
      dv11.addChild(editor.getSlider());
      WavTab tab=new WavTab(editor);
      editor.setSample(sample);
      tab.wvac.out.setGain((float)1/sample.getNumChannels());
      editor.globalKeyFocus=false;
      wavTabs.add(tab);
      tabs.onLayout();
      tabs.onLayout();
      KyUI.get("wv_frame").onLayout();
      tabs.selectTab(wavTabs.size());
      wav_setup(tab, (DivisionLayout)e.children.get(0));
    }
  }
  , null, null);//ADD tell user why this audio is not loaded
  //always changed and save with autosave.
}
void addWavFileTab(String filename) {
  for (int a=0; a<wavTabs.size(); a++) {//anti duplication
    WavTab t=wavTabs.get(a);
    if (t.editor.sample!=null&&new File(t.editor.sample.getFileName()).equals(new File(filename))) {//same sample
      led_filetabs.selectTab(a+1);
      return;
    }
  }
  /*WavTab tab=*/  addWavTab(filename);
}
void selectWavTab(int index) {
  if (index<0||index>=wavTabs.size()) {
    currentWav=null;
    KyUI.get("wv_text").setEnabled(true);
  } else {
    currentWav=wavTabs.get(index);
  }
  AutomationButton b=(AutomationButton)((LinearList)KyUI.get("wv_points")).getSelection();
  if (b!=null) {
    b.onPress.run();
  }
  KyUI.get("wv_frame").invalidate();
}
void saveWav(WavTab wav) {
  if (wav==null) {
    return;
  }
  //ADD
}