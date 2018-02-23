package pw2.beads;
import beads.AudioContext;
import beads.BiquadFilter;
import beads.Glide;
import kyui.util.Task;
public class BiquadFilterW extends UGenW {
  public BiquadFilter filter;
  Glide frequency_;
  Glide q_;//0.7-7
  Glide gain_;
  public Task setFrequency=(Object d) -> {
    frequency_.setValue(((Double)d).floatValue());
  };
  public Task setQ=(Object d) -> {
    q_.setValue(((Double)d).floatValue());
  };
  public Task setGain=(Object d) -> {
    gain_.setValue(((Double)d).floatValue());
  };
  public BiquadFilterW(AudioContext ac, int channels, BiquadFilter.Type type) {
    super(ac, channels, channels);
    filter=new BiquadFilter(ac, channels, type);
    frequency_=new Glide(ac, 20000, GLIDE_TIME);
    q_=new Glide(ac, 1, GLIDE_TIME);
    gain_=new Glide(ac, 1, GLIDE_TIME);
    filter.setFrequency(frequency_);
    filter.setQ(q_);
    filter.setGain(gain_);
    drawFromChainInput(filter);
    addToChainOutput(filter);
  }
  @Override
  public void kill() {
    super.kill();
    filter.kill();
    frequency_.kill();
    q_.kill();
    gain_.kill();
  }
  @Override
  protected void onBypass(boolean v) {
    filter.pause(v);
  }
}
