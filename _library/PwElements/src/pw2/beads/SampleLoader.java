package pw2.beads;
import beads.Sample;
import it.sauronsoftware.jave.*;

import java.io.File;
import java.util.Arrays;
import java.util.function.Consumer;
public class SampleLoader {
  public static void loadSample(String path, String tempdir, Consumer<Sample> onFinished, Consumer<Integer> onProgress, Runnable onFailed) {
    new Thread(() -> {
      String filename=path.replace("\\", "/");
      String temp=tempdir.replace("\\", "/");
      Sample sample=null;
      //
      try {
        sample=new Sample(filename);
        onFinished.accept(sample);//successfully loaded.
        return;
      } catch (Exception e) {
        System.err.println("SampleLoader - beads failed to load " + filename + " (cause : " + e + ")");
        e.printStackTrace();
      }
      if (sample == null) {//retry
        System.out.println("SampleLoader - retrying...");
        Encoder encoder=new Encoder();
        //        try {
        //          MultimediaInfo info=encoder.getInfo(new File(filename));
        //          if (!Arrays.asList(encoder.getAudioDecoders()).contains(info.getAudio().getDecoder())) {
        //            System.err.println("SampleLoader - file is not decodable.");
        //          }
        //        } catch (Exception e) {
        //          System.err.println("SampleLoader - ffmpeg failed to get decoder info. (cause : " + e + ")");
        //        }
        AudioAttributes audio=new AudioAttributes();
        audio.setCodec("pcm_s16le"); // - getAudioEncoders()
        audio.setBitRate(192000);
        audio.setChannels(2);
        audio.setSamplingRate(44100);
        EncodingAttributes attrs=new EncodingAttributes();
        attrs.setFormat("wav");
        attrs.setAudioAttributes(audio);
        String name=filename.substring(filename.lastIndexOf("/") + 1, filename.length());
        if (name.contains(".")) {
          name=name.substring(0, name.lastIndexOf("."));
        }
        if (temp.charAt(temp.length() - 1) == '/') {
          temp=temp.substring(0, temp.length() - 1);
        }
        temp=temp + "/" + name + ".wav";
        final String temp_=temp;
        File file=new File(temp);
        System.out.println("SampleLoader - set path to " + temp);
        if (file.isFile()) {
          System.out.println("SampleLoader - file exists. try to load.");
          try {
            sample=new Sample(temp);
            onFinished.accept(sample);//successfully loaded.
            return;
          } catch (Exception e) {
            System.err.println("SampleLoader - wav already exists and load failed (cause : " + e + ")");
            if (onFailed != null) {
              onFailed.run();
            }
          }
        } else {
          System.out.println("SampleLoader - encoding with ffmpeg...");
          try {
            encoder.encode(new File(filename), file, attrs, new EncoderProgressListener() {
              @Override
              public void sourceInfo(MultimediaInfo multimediaInfo) {
              }
              @Override
              public void progress(int i) {
                if (i % 100 == 0) {
                  System.out.println("SampleLoader - progress (" + (i / 10) + "/100)");
                  if (onProgress != null) {
                    onProgress.accept(i / 10);//so called 10 times.
                  }
                }
                if (i == 1000) {
                  try {
                    Sample sample=new Sample(temp_);
                    onFinished.accept(sample);//successfully loaded.
                    return;
                  } catch (Exception e) {
                    System.err.println("SampleLoader - ffmpeg converted file, but failed to load. (cause : " + e + ")");
                    if (onFailed != null) {
                      onFailed.run();
                    }
                  }
                }
              }
              @Override
              public void message(String s) {
              }
            });
          } catch (EncoderException e) {
            System.err.println("SampleLoader - ffmpeg failed to convert. (cause : " + e + ")");
            if (onFailed != null) {
              onFailed.run();
            }
          }
        }
      }
    }).start();
  }
}
