package pw2.beads;
import beads.AudioContext;
import beads.Sample;
import beads.SamplePlayer;

import java.util.ArrayList;
public class AutoControlSamplePlayer extends SamplePlayer {
  ArrayList<KnobAutomation> autos=new ArrayList<>();
  public AutoControlSamplePlayer(AudioContext audioContext, int i) {
    super(audioContext, i);
  }
  public AutoControlSamplePlayer(AudioContext audioContext, Sample sample) {
    super(audioContext, sample);
  }
  public void addAuto(KnobAutomation a) {
    synchronized (this) {
      autos.add(a);
    }
  }
  @Override
  public void calculateBuffer() {
    synchronized (this) {
      for (int a=0; a < autos.size(); a++) {//disable KnobAutomation's position contro ability! (synchronize with me)
        if (autos.get(a).isDeleted()) {
          autos.remove(a);
          a--;
        } else {
          autos.get(a).setPosition(position);
        }
      }
    }
    super.calculateBuffer();
  }
  protected void calculateNextPosition(int i) {//this is pasted from sampleplayer
    super.calculateNextPosition(i);
    if (loopType == LoopType.NO_LOOP_FORWARDS) {
      loopStart=loopStartEnvelope.getValue(0, i);
      loopEnd=loopEndEnvelope.getValue(0, i);
      if (position > Math.max(loopStart, loopEnd)) {
        position=Math.max(loopStart, loopEnd);
        pause(true);
      }
    }
  }
}
