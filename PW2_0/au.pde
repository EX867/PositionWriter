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