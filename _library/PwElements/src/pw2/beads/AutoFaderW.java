package pw2.beads;
import beads.AudioContext;
import beads.UGen;
import beads.UGenW;
import pw2.element.Knob;

import java.util.List;
import java.util.Arrays;
public class AutoFaderW extends UGenW {
  public AutoFader ugen;
  public KnobAutomation cuePoint;
  public KnobAutomation preCount;
  public KnobAutomation postCount;
  public Parameter setPreCount=new Parameter((Object d) -> {
    cuePoint.preCount=((Number)d).doubleValue();
  }, (Knob target) -> {
    preCount.attach(target);
  });
  public Parameter setPostCount=new Parameter((Object d) -> {
    cuePoint.postCount=((Number)d).doubleValue();
  }, (Knob target) -> {
    postCount.attach(target);
  });
  public AutoFaderW(AudioContext ac, int channels) {
    super(ac, channels, channels);
    ugen=new AutoFader(ac, channels);
    ugen.setFader(cuePoint=new KnobAutomation(ac, 1));
    preCount=new KnobAutomation(ac, 10);
    postCount=new KnobAutomation(ac, 10);
    setStartPoint(ugen);
    cuePoint.preCounter=(KnobAutomation.Point p) -> {
      if (cuePoint.preCount != 0) {
        ugen.pos=1 * ((p.position - cuePoint.getPosition()) / cuePoint.preCount);//1 to 0
        if (ugen.pos > 1) {
          ugen.pos=1;
        } else if (ugen.pos < 0) {
          ugen.pos=0;
        }
      }
    };
    cuePoint.postCounter=(KnobAutomation.Point p) -> {
      if (cuePoint.postCount != 0) {
        ugen.pos=1 * ((cuePoint.getPosition() - p.position) / cuePoint.postCount);//0 to 1
        if (ugen.pos > 1) {
          ugen.pos=1;
        } else if (ugen.pos < 0) {
          ugen.pos=0;
        }
      }
    };
  }
  @Override
  protected UGen updateUGens() {
    giveInputTo(ugen);
    updateUGen(cuePoint);
    updateUGen(ugen);
    return ugen;
  }
  @Override
  public void kill() {
    ugen.kill();
    cuePoint.kill();
    super.kill();
  }
  public static class AutoFader extends UGen {
    UGen fader;
    double pos=1;
    public AutoFader(AudioContext audioContext, int channels) {
      super(audioContext, channels, channels);
    }
    public AutoFader setFader(UGen u) {
      fader=u;
      return this;
    }
    public UGen getFader() {
      return fader;
    }
    @Override
    public void calculateBuffer() {
      for (int c=0; c < outs; c++) {
        for (int a=0; a < bufferSize; a++) {
          bufOut[c][a]=(float)(bufIn[c][a] * pos);
        }
      }
      pos=1;
    }
  }
  @Override
  public List<KnobAutomation> getAutomations() {
    return Arrays.asList(new KnobAutomation[]{preCount, postCount, cuePoint});
  }
}
