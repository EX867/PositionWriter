import it.sauronsoftware.jave.*;
import java.util.Arrays;
import java.util.List;
import pw2.beads.SampleLoader;
AudioContext globalAc;
SamplePlayer globalSamplePlayer;
void au_setup() {
  globalAc=new AudioContext();
  globalSamplePlayer=new SamplePlayer(globalAc, 2);
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
  wv_fxtabs.addTab("TDComp", new TDCompControl("wv_tdcomp").initialize(comp));
  final AutoFaderControl control;
  wv_fxtabs.addTab("Wavcut", control=new AutoFaderControl("wv_autofader").initialize(fader));
  wv_fxtabs.localLayout();
  control.setAsMirror(tab.editor);
  control.view.onAutomationChanged=new Runnable() {//why two times??
    public void run() {
      tab.editor.automationInvalid=true;
      tab.editor.invalidate();
    }
  };
  control.view.snap=false;
  tab.editor.onAutomationChanged=new Runnable() {
    public void run() {
      control.view.automationInvalid=true;
      control.view.invalidate();
    }
  };
  AutoControlSamplePlayer sp=tab.editor.player;
  sp.addInputTo(ac.out);
  List<KnobAutomation> autos;
  autos=sp.addUGenAndGetAutos(fader);
  for (KnobAutomation auto : autos) {
    sp.addAuto(auto);
  }
  autos=sp.addUGenAndGetAutos(comp);
  for (KnobAutomation auto : autos) {
    sp.addAuto(auto);
  }
  KyUI.taskManager.executeAll();
  wv_fxtabs.selectTab(1);
  tab.editor.automation=fader.cuePoint;
}
void wav_setup() {
  ((TabLayout)KyUI.get("wv_filetabs")).tabSelectListener=new ItemSelectListener() {
    public void onEvent(int index) {
      selectWavTab(index-1);
    }
  };
  ((TabLayout)KyUI.get("wv_filetabs")).tabRemoveListener=new ItemSelectListener() {
    public void onEvent(int index) {
      wavTabs.get(index).close();
      wavTabs.remove(index);
      if (ksTabs.size()==0) {
        //instead of adding new tab, just set current to null. it can be done becauase waveditor has no extra sharing state.
        selectWavTab(-1);
      }
      KyUI.get("wv_filetabs").localLayout();
    }
  };
}
static class WavTab {
  AudioContext wvac=new AudioContext();//so we have 1+kstabs_count+wavtabs_count audiocontexts...is it okay???(or I can optimize it to 2+kstabs_count...)
  WavEditor editor;
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
  KyUI.get("wv_frame").invalidate();
}