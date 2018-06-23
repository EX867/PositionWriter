package pw2.beads;
import beads.AudioContext;
import beads.Sample;
import beads.UGen;
import beads.UGenW;
import pw2.element.Knob;

import javax.swing.filechooser.FileSystemView;
import java.io.File;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.List;
import java.util.Arrays;
import java.util.TreeSet;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
public class AutoFaderW extends UGenW {//break the rule!!! I miss designed preCount postCount system ah...
  public AutoFader ugen;
  public KnobAutomation cuePoint;
  public KnobAutomation preCount;//unit = ms
  public KnobAutomation postCount;
  public Parameter setPreCount = new Parameter((Object d) -> {
    cuePoint.preCount = ((Number)d).doubleValue();
  }, (Knob target) -> {
    preCount.attach(target);
  });
  public Parameter setPostCount = new Parameter((Object d) -> {
    cuePoint.postCount = ((Number)d).doubleValue();
  }, (Knob target) -> {
    postCount.attach(target);
  });
  public AutoFaderW(AudioContext ac, int channels) {
    super(ac, channels, channels);
    ugen = new AutoFader(ac, channels);
    cuePoint = new KnobAutomation(ac, "cuePoint", 1);//setFader???
    preCount = new KnobAutomation(ac, "preCount", 10);
    postCount = new KnobAutomation(ac, "postCount", 10);
    setStartPoint(ugen);
    cuePoint.preCounter = (KnobAutomation.Point p) -> {
      if (cuePoint.preCount != 0) {
        //it is safe to do this
        ugen.pos = 1 * ((p.position - cuePoint.getPosition()) / cuePoint.preCount);//1 to 0
        if (ugen.pos > 1) {
          ugen.pos = 1;
        } else if (ugen.pos < 0) {
          ugen.pos = 0;
        }
      }
      ugen.calculate(cuePoint.bufferIndex);
    };
    cuePoint.postCounter = (KnobAutomation.Point p) -> {
      if (cuePoint.postCount != 0) {
        ugen.pos = 1 * ((cuePoint.getPosition() - p.position) / cuePoint.postCount);//0 to 1
        if (ugen.pos > 1) {
          ugen.pos = 1;
        } else if (ugen.pos < 0) {
          ugen.pos = 0;
        }
      }
      ugen.calculate(cuePoint.bufferIndex);
    };
    cuePoint.setRange(-1, 1);
  }
  public double getPreCount() {
    return cuePoint.preCount;
  }
  public double getPostCount() {
    return cuePoint.postCount;
  }
  @Override
  protected UGen updateUGens() {
    giveInputTo(ugen);
    updateUGen(ugen);//do nothing but initializeOuts
    return ugen;
  }
  @Override
  public void kill() {
    ugen.kill();
    cuePoint.kill();
    super.kill();
  }
  public class AutoFader extends UGen {
    //    UGen fader;
    double pos = 1;
    public AutoFader(AudioContext ac, int channels) {
      super(ac, channels, channels);
    }
    @Override
    public void calculateBuffer() {
      for (int c = 0; c < outs; c++) {
        bufOut[c] = bufIn[c];
      }
      cuePoint.calculateBuffer();
    }
    public void calculate(int index) {
      for (int c = 0; c < outs; c++) {
        bufOut[c][index] = (float)(bufIn[c][index] * pos);
      }
    }
  }
  @Override
  public List<KnobAutomation> getAutomations() {
    return Arrays.asList(new KnobAutomation[]{preCount, postCount, cuePoint});
  }
  static DecimalFormat xxxx = new DecimalFormat("0000");
  public void audioCut(Sample sample, TreeSet<Integer> times, String path_, BiConsumer<Long, Long> progressListener, Consumer<String> endListener, boolean postfade) {//save to documents/wavcut/<wav_title.wav>/<count>.wav
    //assert sample!=null
    //times= sorted samples list
    //prefade uses other algorithm
    boolean pbypass = isBypassed();
    if (postfade) {
      bypass(true);
    }
    //set sample processed!!
    String path;
    if (path_.endsWith("/") || path_.endsWith("\\")) {
      path = path_.substring(0, path_.length() - 1);
    } else {
      path = path_;
    }
    //new Thread(() -> {
    int totalCount = times.size() + 1;
    int start = 0;
    int count = 1;
    while (!times.isEmpty()) {
      int time = times.pollFirst();
      int length = time - start;
      if (postfade) {
        length += getPostCount();
      }
      float[][] buffer = new float[sample.getNumChannels()][length];
      sample.getFrames(start, buffer);
      {//process post fade.
        int original = time - start;
        for (int a = original; a < length; a++) {
          for (int c = 0; c < buffer.length; c++) {
            buffer[c][a] *= ((float)(a - original) / (length - original));
          }
        }
      }
      Sample split = new Sample(sample.samplesToMs(length), sample.getNumChannels(), sample.getSampleRate());
      split.putFrames(0, buffer);
      try {
        File file = new File(path + "/" + xxxx.format(count) + ".wav");
        if (split.getLength() == 0) {
          start = time;
          continue;
        } else {
          System.out.println("save audio : " + file.getAbsolutePath() + " length : " + split.getLength() / 1000 + " start : " + start + " end : " + time + " (" + count + "/" + totalCount + ")");
          progressListener.accept((long)count, (long)totalCount);
          if (!file.isFile()) {
            file.getParentFile().mkdirs();
            file.createNewFile();
          }
          split.write(file.getAbsolutePath());
        }
      } catch (IOException e) {
        e.printStackTrace();
      }
      count++;
      start = time;
    }
    //
    last_block:
    {
      int time = (int)Math.floor(sample.msToSamples(sample.getLength()));
      float[][] buffer = new float[sample.getNumChannels()][time - start];
      sample.getFrames(start, buffer);
      Sample split = new Sample(sample.samplesToMs(time - start), sample.getNumChannels(), sample.getSampleRate());
      split.putFrames(0, buffer);
      try {
        File file = new File(path + "/" + xxxx.format(count) + ".wav");
        if (split.getLength() == 0) {
          break last_block;
        } else {
          System.out.println("save audio : " + file.getAbsolutePath() + " length : " + split.getLength() / 1000 + " start : " + start + " end : " + time + " (" + count + "/" + totalCount + ")");
          progressListener.accept((long)count, (long)totalCount);
          if (!file.isFile()) {
            file.getParentFile().mkdirs();
            file.createNewFile();
          }
          split.write(file.getAbsolutePath());
        }
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
    //
    endListener.accept(path + "/");
    bypass(pbypass);
    //}).start();
  }
}
