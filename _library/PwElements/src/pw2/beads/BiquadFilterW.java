package pw2.beads;
import beads.AudioContext;
import beads.BiquadFilter;
import pw2.element.Knob;
public class BiquadFilterW extends UGenW {
  public BiquadFilter ugen;
  public KnobAutomation frequency;
  public KnobAutomation q;//0.7-7
  public KnobAutomation gain;
  public Parameter setFrequency=new Parameter((Object d) -> {
    frequency.setValue(((Double)d).floatValue());
  }, (Knob target) -> {
    frequency.attach(target);
  });
  public Parameter setQ=new Parameter((Object d) -> {
    q.setValue(((Double)d).floatValue());
  }, (Knob target) -> {
    q.attach(target);
  });
  public Parameter setGain=new Parameter((Object d) -> {
    gain.setValue(((Double)d).floatValue());
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
    drawFromChainInput(ugen);
    addToChainOutput(ugen);
  }
  @Override
  public void kill() {
    super.kill();
    ugen.kill();
    frequency.kill();
    q.kill();
    gain.kill();
  }
  @Override
  protected void onBypass(boolean v) {
    ugen.pause(v);
  }
}
