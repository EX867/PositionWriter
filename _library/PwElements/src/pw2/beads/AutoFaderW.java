package pw2.beads;
import beads.AudioContext;
import beads.UGen;
import beads.UGenW;
import pw2.element.Knob;
public class AutoFaderW extends UGenW {
  public AutoFader ugen;
  public KnobAutomation gain;
  public KnobAutomation preCount;
  public KnobAutomation postCount;
  public Parameter setPreCount=new Parameter((Object d) -> {
    gain.preCount=((Number)d).doubleValue();
  }, (Knob target) -> {
    preCount.attach(target);
  });
  public Parameter setPostCount=new Parameter((Object d) -> {
    gain.postCount=((Number)d).doubleValue();
  }, (Knob target) -> {
    postCount.attach(target);
  });
  public AutoFaderW(AudioContext ac, int channels) {
    super(ac, channels, channels);
    ugen=new AutoFader(ac, channels);
    ugen.setFader(gain=new KnobAutomation(ac, 1));
    preCount=new KnobAutomation(ac, 10);
    postCount=new KnobAutomation(ac, 10);
    setStartPoint(ugen);
    gain.preCounter=(KnobAutomation.Point p) -> {
      if (gain.preCount != 0) {
        ugen.pos=1 * ((p.position - gain.getPosition()) / gain.preCount);//1 to 0
        if (ugen.pos > 1) {
          ugen.pos=1;
        } else if (ugen.pos < 0) {
          ugen.pos=0;
        }
      }
    };
    gain.postCounter=(KnobAutomation.Point p) -> {
      if (gain.postCount != 0) {
        ugen.pos=1 * ((gain.getPosition() - p.position) / gain.postCount);//0 to 1
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
    gain.update();
    ugen.update();
    return ugen;
  }
  @Override
  public void kill() {
    ugen.kill();
    gain.kill();
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
}
