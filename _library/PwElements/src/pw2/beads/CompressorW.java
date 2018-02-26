package pw2.beads;
import beads.AudioContext;
import beads.Compressor;
import pw2.element.Knob;
public class CompressorW extends UGenW {
  public Compressor ugen;
  public KnobAutomation attack;
  public KnobAutomation decay;
  public KnobAutomation knee;
  public KnobAutomation ratio;
  public KnobAutomation threshold;
  public KnobAutomation sideChain;
  public Parameter setAttack=new Parameter((Object d) -> {
    ugen.setAttack(((Double)d).floatValue());
  }, (Knob target) -> {
    attack.target=target;
  });
  public Parameter setDecay=new Parameter((Object d) -> {
    ugen.setDecay(((Double)d).floatValue());
  }, (Knob target) -> {
    decay.target=target;
  });
  public Parameter setKnee=new Parameter((Object d) -> {
    ugen.setKnee(((Double)d).floatValue());
  }, (Knob target) -> {
    knee.target=target;
  });
  public Parameter setRatio=new Parameter((Object d) -> {
    ugen.setRatio(((Double)d).floatValue());
  }, (Knob target) -> {
    ratio.target=target;
  });
  public Parameter setThreshold=new Parameter((Object d) -> {
    ugen.setThreshold(((Double)d).floatValue());
  }, (Knob target) -> {
    threshold.target=target;
  });
  public Parameter setSideChain=new Parameter((Object d) -> {
    sideChain.setValue(((Double)d).floatValue());
  }, (Knob target) -> {
    sideChain.target=target;
  });
  public CompressorW(AudioContext ac, int in) {
    super(ac, in, in);
    ugen=new Compressor(ac, in);
    attack=new KnobAutomation(ac, 1);
    decay=new KnobAutomation(ac, 0.5F);
    knee=new KnobAutomation(ac, 0.5F);
    ratio=new KnobAutomation(ac, 2);
    threshold=new KnobAutomation(ac, 0.5F);
    ugen.setSideChain(sideChain=new KnobAutomation(ac, 1));
    drawFromChainInput(ugen);
    addToChainOutput(ugen);
  }
  public CompressorW(AudioContext ac, int in, int out) {
    super(ac, in, out);
  }
  @Override
  protected void onBypass(boolean v) {
  }
  @Override
  public void kill() {
    ugen.kill();
    //kill others
    super.kill();
  }
}
