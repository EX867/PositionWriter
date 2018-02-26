package pw2.beads;
import beads.AudioContext;
import beads.Gain;
import pw2.element.Knob;
public class GainW extends UGenW {
  public Gain ugen;
  public KnobAutomation gain;
  public Parameter setGain=new Parameter((Object d) -> {//assert d instanceof Double
    gain.setValue(((Double)d).floatValue());
  }, (Knob target) -> {
    gain.target=target;
  });
  public GainW(AudioContext ac, int in) {
    super(ac, in, in);
    ugen=new Gain(ac, in);
    ugen.setGain(gain=new KnobAutomation(ac, 1));
    drawFromChainInput(ugen);
    addToChainOutput(ugen);
  }
  @Override
  protected void onBypass(boolean v) {
    ugen.pause(v);
  }
  @Override
  public void kill() {
    ugen.kill();
    gain.kill();
    super.kill();
  }
}
