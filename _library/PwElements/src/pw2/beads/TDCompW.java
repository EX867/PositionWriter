package pw2.beads;
import beads.AudioContext;
import beads.SamplePlayer;
import pw2.element.Knob;
public class TDCompW extends UGenW {
  public TDComp ugen;
  public KnobAutomation attack;
  public KnobAutomation release;
  public KnobAutomation knee;
  public KnobAutomation ratio;
  public KnobAutomation threshold;
  public KnobAutomation outputGain;
  public Parameter setAttack=new Parameter((Object d) -> {
    ugen.setAttack(((Double)d).doubleValue());
  }, (Knob target) -> {
    attack.target=target;
  });
  public Parameter setRelease=new Parameter((Object d) -> {
    ugen.setRelease(((Double)d).doubleValue());
  }, (Knob target) -> {
    release.target=target;
  });
  public Parameter setKnee=new Parameter((Object d) -> {
    ugen.setKnee(((Double)d).doubleValue());
  }, (Knob target) -> {
    knee.target=target;
  });
  public Parameter setRatio=new Parameter((Object d) -> {
    ugen.setRatio(((Double)d).doubleValue());
  }, (Knob target) -> {
    ratio.target=target;
  });
  public Parameter setThreshold=new Parameter((Object d) -> {
    ugen.setThreshold(((Double)d).doubleValue());
  }, (Knob target) -> {
    threshold.target=target;
  });
  public Parameter setOutputGain=new Parameter((Object d) -> {
    ugen.setOutputGain(((Double)d).floatValue());
  }, (Knob target) -> {
    outputGain.target=target;
  });
  public Parameter setSideChain=new Parameter((Object d) -> {
    startSample((Double)d);
  }, (Knob target) -> {
  });
  SamplePlayer sideChain;
  public TDCompW(AudioContext ac, int in) {
    super(ac, in, in);
    ugen=new TDComp(ac, in);
    attack=new KnobAutomation(ac, 1);
    release=new KnobAutomation(ac, 0.5F);
    knee=new KnobAutomation(ac, 0.1F);
    ratio=new KnobAutomation(ac, 2);
    threshold=new KnobAutomation(ac, -3);
    outputGain=new KnobAutomation(ac, 1);
    sideChain=new SamplePlayer(ac, 2);
    sideChain.setKillOnEnd(false);
    ugen.setSideChain(sideChain);
    drawFromChainInput(ugen);
    addToChainOutput(ugen);
  }
  public TDCompW(AudioContext ac, int in, int out) {
    super(ac, in, out);
  }
  @Override
  protected void onBypass(boolean v) {
    ugen.pause(v);
  }
  @Override
  public void kill() {
    ugen.kill();
    sideChain.kill();
    attack.kill();
    release.kill();
    threshold.kill();
    ratio.kill();
    knee.kill();
    outputGain.kill();
    super.kill();
  }
  public void startSample(double v) {
    //works with ranges...
    //sampleplayer..
  }
}
