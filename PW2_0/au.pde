import it.sauronsoftware.jave.*;
import java.util.Arrays;
import java.util.List;
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
      ((ConsoleEdit)KyUI.get("log_content")).addLine("File : "+filename).addLine("   / format : "+info.getFormat()+" / bitRate : "+info.getAudio().getBitRate()+" / channels : "+info.getAudio().getChannels()).addLine("   / sampleRate : "+info.getAudio().getChannels()+" / decoder : "+info.getAudio().getDecoder()).invalidate();
    }
    public void progress(int permil) {//0 to 1000
      if (permil==1000) {
        ((ConsoleEdit)KyUI.get("log_content")).addLine("File : "+filename).addLine("   / convert finised");
        converted++;
        if (converting==converted) {
          ((ConsoleEdit)KyUI.get("log_content")).addLine("Event : converting all files finised ("+converted+" of "+converting+")");
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
      int successCount=0;
      converted=0;
      converting=input.length;
      for (int a=0; a<input.length; a++) {
        setTitleProcessing("convertng...("+converted+"/"+converting+")");
        try {
          if (converter.checkDecodable(input[a])) {
            String input=this.input[a];
            String output=joinPath(this.output, changeFormat(getFileName(input), outputFormat));
            AudioAttributes audio = new AudioAttributes();
            audio.setCodec(outputCodec); // - getAudioEncoders()
            audio.setBitRate(outputBitRate);
            audio.setChannels(outputChannels);
            audio.setSamplingRate(outputSampleRate);
            EncodingAttributes attrs = new EncodingAttributes();
            attrs.setFormat(outputFormat);
            attrs.setAudioAttributes(audio);
            new it.sauronsoftware.jave.Encoder().encode(new File(input), new File(output), attrs, new ModEncodingListener(input));
            successCount++;
          } else {
            ((ConsoleEdit)KyUI.get("log_content")).addLine("Event : cannot convert file : "+input[a]).invalidate();
          }
        }
        catch(Exception e) {
          e.printStackTrace();
        }
      }
      if (successCount==0) {
        ((ConsoleEdit)KyUI.get("log_content")).addLine("Event : none of input files converted.").invalidate();
        ;
        ((ImageButton)KyUI.get("log_exit")).setEnabled(true);
        ((ImageButton)KyUI.get("log_exit")).invalidate();
      }
    }
  }
}