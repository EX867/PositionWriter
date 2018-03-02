package pw2.beads;
import beads.AudioContext;
import beads.Reverb;
import pw2.element.Knob;
public class ReverbW extends UGenW {
  public Reverb[] ugen;
  public KnobAutomation size;
  public KnobAutomation damping;
  public KnobAutomation earlyReflection;
  public KnobAutomation length;
  public Parameter setSize=new Parameter((Object d) -> {//assert d instanceof Double
    for (int a=0; a < ugen.length; a++) {
      ugen[a].setSize(((Double)d).floatValue());
    }
  }, (Knob target) -> {
    size.attach(target);
  });
  public Parameter setDamping=new Parameter((Object d) -> {
    for (int a=0; a < ugen.length; a++) {
      ugen[a].setDamping(((Double)d).floatValue());
    }
  },(Knob target) -> {
    damping.attach(target);
  });
  public Parameter setEarlyReflection=new Parameter((Object d) -> {
    for (int a=0; a < ugen.length; a++) {
      ugen[a].setEarlyReflectionsLevel(((Double)d).floatValue());
    }
  },(Knob target) -> {
    earlyReflection.attach(target);
  });
  public Parameter setLength=new Parameter((Object d) -> {
    for (int a=0; a < ugen.length; a++) {
      ugen[a].setLateReverbLevel(((Double)d).floatValue());
    }
  },(Knob target) -> {
    length.attach(target);
  });
  public ReverbW(AudioContext ac, int in, int out) {
    super(ac, in, out);
    ugen=new Reverb[in];
    size=new KnobAutomation(ac,0.5F);
    damping=new KnobAutomation(ac,0.7F);
    earlyReflection=new KnobAutomation(ac,1);
    length=new KnobAutomation(ac,1);
    for (int a=0; a < ugen.length; a++) {
      ugen[a]=new Reverb(ac, out);
      drawFromChainInput(a, ugen[a]);
      addToChainOutput(ugen[a]);
    }
  }
  @Override
  public void kill() {
    for (int a=0; a < ugen.length; a++) {
      ugen[a].kill();
    }
  }
  @Override
  protected void onBypass(boolean v) {
    for (int a=0; a < ugen.length; a++) {
      ugen[a].pause(v);
    }
  }
}
