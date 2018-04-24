package pw2.beads;
import beads.AudioContext;
import beads.UGen;
import beads.UGenW;
import net.beadsproject.beads.ugens.RubberBandProcessor;
import pw2.element.Knob;

import java.util.Arrays;
import java.util.List;
public class RubberBandStretcherW extends UGenW {
  public RubberBandProcessor ugen;
  public KnobAutomation pitch;
  public KnobAutomation speed;
  public Parameter setPitch=new Parameter((Object d) -> {//assert d instanceof Double
    ugen.setPitch(((Number)d).floatValue());
  }, (Knob target) -> {
    pitch.attach(target);
  });
  public Parameter setSpeed=new Parameter((Object d) -> {//assert d instanceof Double
    ugen.setSpeed(((Number)d).floatValue());
  }, (Knob target) -> {
    speed.attach(target);
  });
  public RubberBandStretcherW(AudioContext ac, int in, int out) {
    super(ac, in, out);
    ugen=new RubberBandProcessor(ac, (int)ac.getSampleRate(), 1, 1);
    pitch=new KnobAutomation(ac, 0.5F);
    speed=new KnobAutomation(ac, 0.5F);
    setStartPoint(ugen);
  }
  @Override
  protected UGen updateUGens() {
    giveInputTo(ugen);
    updateUGen(ugen);
    return ugen;
  }
  @Override
  public List<KnobAutomation> getAutomations() {
    return Arrays.asList(new KnobAutomation[]{pitch, speed});
  }
  @Override
  public void kill() {
    ugen.kill();
    pitch.kill();
    speed.kill();
  }
}
