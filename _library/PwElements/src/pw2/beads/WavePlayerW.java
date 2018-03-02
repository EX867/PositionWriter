package pw2.beads;
import beads.AudioContext;
import beads.Buffer;
import beads.UGen;
import beads.WavePlayer;
import beads.UGenW;
import pw2.element.Knob;
public class WavePlayerW extends UGenW {
  public WavePlayer player;
  public KnobAutomation frequency;
  public Parameter setFrequency=new Parameter((Object d) -> {//assert d instanceof Double
    frequency.setValue(((Number)d).floatValue());
  }, (Knob target) -> {
    frequency.attach(target);
  });
  public WavePlayerW(AudioContext ac, Buffer buffer) {
    super(ac, 0, 1);
    player=new WavePlayer(ac, 0, buffer);
    frequency=new KnobAutomation(ac, 800);
    player.setFrequency(frequency);
    //player.setPhase();//not auto set...
    setStartPoint(player);
  }
  @Override
  protected UGen updateUGens() {
    //giveInputTo(player);//no input
    player.update();
    return player;
  }
  @Override
  public void kill() {
    super.kill();
    player.kill();
    frequency.kill();
  }
}
