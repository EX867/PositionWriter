import beads.*;
import javax.sound.midi.*;
import it.sauronsoftware.jave.*;
//ModPlayer wavplayer;
Visualizer visualizer;
void AU_setup() {
  visualizer=(Visualizer)UI[getUIidRev("I_VISUALIZER")];
  MidiCommand.addBehavior("press", new PadPressCommand());
  MidiCommand.addBehavior("release", new PadReleaseCommand());
  MidiCommand.addBehavior("chain", new PadChainCommand());
  reloadMidiDevices();
  //wavplayer = new ModPlayer();
  //wavplayer.load("C:/Users/user/Documents/again2.mp3");
  //wavplayer.load("C:/Users/user/Documents/Studio One/Songs/Forget_Remix/Mixdown/Forget_Remix_1.wav");
}
public class PadPressCommand implements CommandBehavior {
  @Override public void execute(MidiMessage msg, long timeStamp, int[] params) {//params[0]=x, params[1]=y
    if (msg instanceof ShortMessage) {
      ShortMessage info=(ShortMessage)msg;
      if (info.getData2()!=0) {
        if (params.length!=2)return;
        if (currentFrame==1) {
          keyLedPad.printLed(params[0], params[1], true, 0);
        } else if (currentFrame==2) {
          keySoundPad.triggerButton(params[0], params[1], true);
        }
      } else {
        if (currentFrame==2) {
          keySoundPad.noteOff(params[0], params[1]);
        }
      }
    }
  }
}
public class PadReleaseCommand implements CommandBehavior {
  @Override public void execute(MidiMessage msg, long timeStamp, int[] params) {//params[0]=x, params[1]=y
    if (currentFrame==2) {
      keySoundPad.noteOff(params[0], params[1]);
    }
  }
}
public class PadChainCommand implements CommandBehavior {
  @Override public void execute(MidiMessage msg, long timeStamp, int[] params) {//params[0]=x, params[1]=y
    if (currentFrame==2) {
      keySoundPad.triggerChain(params[0]);
    }
  }
}
FFmpegConverter converter=new FFmpegConverter();
public class FFmpegConverter {
  //AudioContext converterContext;
  //SamplePlayer converterPlayer;
  ModPlayer converterPlayer=new ModPlayer();
  public FFmpegConverter() {
    //converterContext=new AudioContext();
    //converterPlayer=new SamplePlayer(converterContext, 2);
  }
  int converting=0;
  int converted=0;
  //ArrayList<String> audioFiles=new ArrayList<String>();
  boolean checkDecodable(String input) {
    try {
      File file= new File(input);
      if (file.isFile()==false) {
        printLog("convert()", "input file not exists");
        return false;
      }
      MultimediaInfo info=new it.sauronsoftware.jave.Encoder().getInfo(file);
      //printLog("convert()", "input format is : "+info.getFormat());
      return true;
    }
    catch(Exception e) {
      return false;
    }
  }
  boolean checkEncodable(String outputFormat, String outputCodec) {
    try {
      int a=0;
      String[] encodings=new  it.sauronsoftware.jave.Encoder().getSupportedEncodingFormats();
      while (a<encodings.length) {
        if (outputFormat.equals(encodings[a]))break;
        a=a+1;
      }
      if (a==encodings.length)return false;
      a=0;
      String[] codecs=new it.sauronsoftware.jave.Encoder().getAudioEncoders();
      while (a<codecs.length) {
        if (outputCodec.equals(codecs[a]))break;
        a=a+1;
      }
      if (a==codecs.length)return false;
      return true;
    }
    catch(Exception e) {
      return false;
    }
  }
  void convert(String input, String output, String outputFormat, String outputCodec, int outputBitRate, int outputChannels, int outputSampleRate)throws Exception {
    convertWithEvent(input, output, outputFormat, outputCodec, outputBitRate, outputChannels, outputSampleRate, 0);
  }
  void convertWithEvent(String input, String output, String outputFormat, String outputCodec, int outputBitRate, int outputChannels, int outputSampleRate, int id)throws Exception {
    File source = new File(input);
    File target = new File(output);
    AudioAttributes audio = new AudioAttributes();
    audio.setCodec(outputCodec); // - getAudioEncoders()
    audio.setBitRate(outputBitRate);
    audio.setChannels(outputChannels);
    audio.setSamplingRate(outputSampleRate);
    EncodingAttributes attrs = new EncodingAttributes();
    attrs.setFormat(outputFormat);
    attrs.setAudioAttributes(audio);
    new it.sauronsoftware.jave.Encoder().encode(source, target, attrs, new ModEncodingListener(input, id));
  }
  class ModEncodingListener implements EncoderProgressListener {
    String filename;
    int UIid=0;
    ModEncodingListener(String filename_, int UIid_) {
      filename=filename_;
      UIid=UIid_;
    }
    public void sourceInfo(MultimediaInfo info) {
      Logger logui=((Logger)UI[getUIid("LOG_LOG")]);
      logui.logs.add("File : "+filename);
      logui.logs.add("   / format : "+info.getFormat()+" / bitRate : "+info.getAudio().getBitRate()+" / channels : "+info.getAudio().getChannels());
      logui.logs.add("   / sampleRate : "+info.getAudio().getChannels()+" / decoder : "+info.getAudio().getDecoder());
    }
    public void progress(int permil) {//0 to 1000
      if (permil==1000) {
        Logger logui=((Logger)UI[getUIid("LOG_LOG")]);
        logui.logs.add("File : "+filename);
        logui.logs.add("   / convert finised");
        converted++;
        if (converting==converted) {
          logui.logs.add("Event : converting all files finised ("+converted+" of "+converting+")");
          UI[UIid].disabled=false;
          UI[UIid].registerRender=true;
          focus=UIid;
          converting=0;
          converted=0;
          surface.setTitle(title_filename+title_edited+title_suffix);
        }
      }
    }
    public void message(java.lang.String message) {
      //do nothing
    }
  }
  void convertAll(String[] input, String outputFolder, String outputFormat, String outputCodec, int outputBitRate, int outputChannels, int outputSampleRate) {
    if (input.length==0)return;
    converting=input.length;
    converted=0;
    int id=getUIidRev("LOG_EXIT");
    new Thread(new ThreadConverter(input, outputFolder, outputFormat, outputCodec, outputBitRate, outputChannels, outputSampleRate, id)).start();
  }
  public class ThreadConverter implements Runnable {
    String[] localinput;
    String localoutput;
    String localoutputFormat;
    String localoutputCodec;
    int localoutputBitRate;
    int localoutputChannels;
    int localoutputSampleRate;
    int localid;
    ThreadConverter(String[] input, String output, String outputFormat, String outputCodec, int outputBitRate, int outputChannels, int outputSampleRate, int id) {
      localinput=input;
      localoutput=output;
      localoutputFormat=outputFormat;
      localoutputCodec=outputCodec;
      localoutputBitRate=outputBitRate;
      localoutputChannels=outputChannels;
      localoutputSampleRate=outputSampleRate;
      localid=id;
    }
    @Override
      public void run() {
      try {
        int a=0;
        while (a<localinput.length) {
          surface.setTitle(title_filename+title_edited+title_suffix+" - convertng...("+converted+"/"+converting+")");
          if (converter.checkDecodable(localinput[a])) {
            String filename=getNotDuplicatedFilename(localoutput, changeFormat(getFileName(localinput[a]), localoutputFormat));
            converter.convertWithEvent(localinput[a], filename, localoutputFormat, localoutputCodec, localoutputBitRate, localoutputChannels, localoutputSampleRate, localid);
          } else {
            printLog("convert()", "cannot convert file : "+localinput[a]);
          }
          a=a+1;
        }
      }
      catch(Exception e) {
        e.printStackTrace();
      }
    }
  }
  /*AudioInfo
   int getBitRate() 
   int getChannels() 
   java.lang.String getDecoder() 
   int getSamplingRate()  
   MultimediaInfo
   AudioInfo getAudio() 
   long getDuration() 
   java.lang.String getFormat() 
   Encoder
   void encode(java.io.File source, java.io.File target, EncodingAttributes attributes) 
   java.lang.String[] getAudioDecoders() 
   java.lang.String[] getAudioEncoders() 
   MultimediaInfo getInfo(java.io.File source) 
   java.lang.String[] getSupportedDecodingFormats() 
   java.lang.String[] getSupportedEncodingFormats() 
   */
}
class EnvPoint {
  int time;//follows sample rate
  float value;
}
ArrayList<EnvPoint> volumep=new ArrayList<EnvPoint>();
ArrayList<EnvPoint> panp=new ArrayList<EnvPoint>();
ArrayList<EnvPoint> pitchp=new ArrayList<EnvPoint>();
ArrayList<EnvPoint> speedp=new ArrayList<EnvPoint>();
public static enum UGenType {
  UNDEFINED, SIMPLETOOL, TIMESTRETCHER,
}
class UGenParameter {
  //AudioProsessor UGen;//pointer to change values->differs from type.
  UGenType type;
  public UGenParameter(UGenType type_/*, UGen UGen*/) {
    type=type_;
  }
}
UGenParameter createNewParameter(UGenType type, UGen UGen) {
  if (type==UGenType.SIMPLETOOL) {
    return new SimpleToolParameter(type, UGen);
  }
  return new UGenParameter(UGenType.UNDEFINED);
}
//UGens
public class SimpleTool extends UGenChain {//contains gain,pan control.
  Gain gain;
  Panner panner;
  public SimpleTool(AudioContext ac) {
    super(ac, 2, 2);
    gain=new Gain(ac, 2);
    panner=new Panner(ac);
    drawFromChainInput(gain);
    int a=0;
    while (a<outs) {
      addToChainOutput(a, panner);
      a=a+1;
    }
  }
}
public class SimpleToolParameter extends UGenParameter {
  SimpleTool ugen;
  private double gain;
  private double pan;
  SimpleToolParameter(UGenType type_, UGen ugen_) {
    super(type_);
    ugen=(SimpleTool)ugen_;
    gain=1.0;
    pan=1.0;
  }
  void setGain(double value) {
    gain=value;
    //procesor.setGain(vale);
    //,,,,
  }
  void setPan(double value) {
    pan=value;
  }
}