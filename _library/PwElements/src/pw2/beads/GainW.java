package pw2.beads;
import beads.AudioContext;
import beads.Gain;
import beads.UGen;
import beads.UGenW;
import pw2.element.Knob;
public class GainW extends UGenW {
  public Gain ugen;
  public KnobAutomation gain;
  public Parameter setGain=new Parameter((Object d) -> {//assert d instanceof Double
    gain.setValue(((Number)d).floatValue());
  }, (Knob target) -> {
    gain.attach(target);
  });
  public GainW(AudioContext ac, int in) {
    super(ac, in, in);
    ugen=new Gain(ac, in);
    ugen.setGain(gain=new KnobAutomation(ac, 1));
    setStartPoint(ugen);
  }
  @Override
  protected UGen updateUGens() {
    giveInputTo(ugen);
    ugen.calculateBuffer();
    return ugen;
  }
  @Override
  public void kill() {
    ugen.kill();
    gain.kill();
    super.kill();
  }
}
