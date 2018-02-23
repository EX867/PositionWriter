package pw2.beads;
import beads.AudioContext;
import beads.Buffer;
import beads.Glide;
import beads.WavePlayer;
import kyui.util.Task;
public class WavePlayerW extends UGenW {
  public WavePlayer player;
  Glide frequency_;
  public Task setFrequency=(Object d) -> {//assert d instanceof Double
    frequency_.setValue(((Double)d).floatValue());
  };
  public WavePlayerW(AudioContext ac, Buffer buffer) {
    super(ac, 0, 1);
    player=new WavePlayer(ac, 0, buffer);
    frequency_=new Glide(ac, 22000, GLIDE_TIME);
    player.setFrequency(frequency_);
    //player.setPhase();//not auto set...
    drawFromChainInput(player);
    addToChainOutput(player);
  }
}
