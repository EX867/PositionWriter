package pw2.beads;
import beads.AudioContext;
import beads.Reverb;
import kyui.util.Task;
public class ReverbW extends UGenW {
  public Reverb[] reverb;
  public Task setSize=(Object d) -> {//assert d instanceof Double
    for (int a=0; a < reverb.length; a++) {
      reverb[a].setSize(((Double)d).floatValue());
    }
  };
  public Task setDamping=(Object d) -> {
    for (int a=0; a < reverb.length; a++) {
      reverb[a].setDamping(((Double)d).floatValue());
    }
  };
  public Task setEarlyReflection=(Object d) -> {
    for (int a=0; a < reverb.length; a++) {
      reverb[a].setEarlyReflectionsLevel(((Double)d).floatValue());
    }
  };
  public Task setLength=(Object d) -> {
    for (int a=0; a < reverb.length; a++) {
      reverb[a].setLateReverbLevel(((Double)d).floatValue());
    }
  };
  public ReverbW(AudioContext ac, int in, int out) {
    super(ac, in, out);
    reverb=new Reverb[in];
    for (int a=0; a < reverb.length; a++) {
      reverb[a]=new Reverb(ac, out);
      drawFromChainInput(a,reverb[a]);
      addToChainOutput(reverb[a]);
    }
  }
}
