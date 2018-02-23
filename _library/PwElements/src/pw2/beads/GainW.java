package pw2.beads;
import beads.AudioContext;
import beads.Gain;
import beads.Glide;
import kyui.util.Task;
public class GainW extends UGenWrapper {
  public Gain gain;
  Glide gain_;
  public Task setGain=(Object d) -> {//assert d instanceof Double
    gain_.setValue(((Double)d).floatValue());
  };
  public GainW(AudioContext ac, int in) {
    super(ac, in, in);
    gain=new Gain(ac, in);
    gain_=new Glide(ac, 1, GLIDE_TIME);
    gain.setGain(gain_);
    drawFromChainInput(gain);
    addToChainOutput(gain);
  }
}
