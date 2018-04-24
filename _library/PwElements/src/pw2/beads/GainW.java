package pw2.beads;
import beads.AudioContext;
import beads.Gain;
import beads.UGen;
import beads.UGenW;
import pw2.element.Knob;

import java.util.Arrays;
import java.util.List;
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
    //gain.gridInterval=0.1;test
    setStartPoint(ugen);
  }
  @Override
  protected UGen updateUGens() {
    giveInputTo(ugen);
    updateUGen(ugen);
    return ugen;
  }
  @Override
  public void kill() {
    ugen.kill();
    gain.kill();
    super.kill();
  }
  @Override
  public List<KnobAutomation> getAutomations() {
    return Arrays.asList(new KnobAutomation[]{gain});
  }
}
