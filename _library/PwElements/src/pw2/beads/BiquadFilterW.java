package pw2.beads;
import beads.AudioContext;
import beads.BiquadFilter;
import beads.UGen;
import beads.UGenW;
import pw2.element.Knob;
public class BiquadFilterW extends UGenW {
  public BiquadFilter ugen;
  public KnobAutomation frequency;
  public KnobAutomation q;//0.7-7
  public KnobAutomation gain;
  public Parameter setFrequency=new Parameter((Object d) -> {
    frequency.setValue(((Number)d).floatValue());
  }, (Knob target) -> {
    frequency.attach(target);
  });
  public Parameter setQ=new Parameter((Object d) -> {
    q.setValue(((Number)d).floatValue());
  }, (Knob target) -> {
    q.attach(target);
  });
  public Parameter setGain=new Parameter((Object d) -> {
    gain.setValue(((Number)d).floatValue());
  }, (Knob target) -> {
    gain.attach(target);
  });
  public BiquadFilterW(AudioContext ac, int channels, BiquadFilter.Type type) {
    super(ac, channels, channels);
    ugen=new BiquadFilter(ac, channels, type);
    frequency=new KnobAutomation(ac, 20000);
    q=new KnobAutomation(ac, 1);
    gain=new KnobAutomation(ac, 1);
    ugen.setFrequency(frequency);
    ugen.setQ(q);
    ugen.setGain(gain);
    setStartPoint(ugen);
  }
  @Override
  protected UGen updateUGens() {
    giveInputTo(ugen);
    ugen.update();
    return ugen;
  }
  @Override
  public void kill() {
    super.kill();
    ugen.kill();
    frequency.kill();
    q.kill();
    gain.kill();
  }
}
