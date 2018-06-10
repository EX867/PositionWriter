package pw2.beads;
import beads.*;
import pw2.element.Knob;

import java.util.Arrays;
import java.util.List;
public class ReverbW extends UGenW {
  public Throughput chainOut;
  public Reverb[] ugen;
  public KnobAutomation size;
  public KnobAutomation damping;
  public KnobAutomation earlyReflection;
  public KnobAutomation length;
  public Parameter setSize = new Parameter((Object d) -> {//assert d instanceof Double
    for (int a = 0; a < ugen.length; a++) {
      ugen[a].setSize(((Number)d).floatValue());
    }
  }, (Knob target) -> {
    size.attach(target);
  });
  public Parameter setDamping = new Parameter((Object d) -> {
    for (int a = 0; a < ugen.length; a++) {
      ugen[a].setDamping(((Number)d).floatValue());
    }
  }, (Knob target) -> {
    damping.attach(target);
  });
  public Parameter setEarlyReflection = new Parameter((Object d) -> {
    for (int a = 0; a < ugen.length; a++) {
      ugen[a].setEarlyReflectionsLevel(((Number)d).floatValue());
    }
  }, (Knob target) -> {
    earlyReflection.attach(target);
  });
  public Parameter setLength = new Parameter((Object d) -> {
    for (int a = 0; a < ugen.length; a++) {
      ugen[a].setLateReverbLevel(((Number)d).floatValue());
    }
  }, (Knob target) -> {
    length.attach(target);
  });
  public ReverbW(AudioContext ac, int in, int out) {
    super(ac, in, out);
    chainOut = new Throughput(ac, out);
    ugen = new Reverb[in];
    size = new KnobAutomation(ac, "size", 0.5F);
    damping = new KnobAutomation(ac, "damping", 0.7F);
    earlyReflection = new KnobAutomation(ac, "earlyReflection", 1);
    length = new KnobAutomation(ac, "length", 1);
    for (int a = 0; a < ugen.length; a++) {
      ugen[a] = new Reverb(ac, out);
      chainOut.addInput(ugen[a]);
      setStartPoint(ugen[a]);
    }
  }
  @Override
  protected UGen updateUGens() {
    for (int a = 0; a < ugen.length; a++) {
      giveInputTo(ugen[a], a, 0);
    }
    chainOut.update();
    return chainOut;
  }
  @Override
  public void kill() {
    for (int a = 0; a < ugen.length; a++) {
      ugen[a].kill();
    }
  }
  @Override
  public List<KnobAutomation> getAutomations() {
    return Arrays.asList(new KnobAutomation[]{size, damping, earlyReflection, length});
  }
}
