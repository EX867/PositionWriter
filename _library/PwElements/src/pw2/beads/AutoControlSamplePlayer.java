package pw2.beads;
import beads.AudioContext;
import beads.Sample;
import beads.SamplePlayer;
import beads.UGen;

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
  public void setLoopEnd(UGen u) {
    for (KnobAutomation a : autos) {
      a.setLoopEnd(u.getValue());
    }
    super.setLoopEnd(u);
  }
  @Override
  public void setLoopStart(UGen u) {
    for (KnobAutomation a : autos) {
      a.setLoopStart(u.getValue());
    }
    super.setLoopStart(u);
  }
  //  @Override
  //  public void setPosition(UGen u) {
  //    for (KnobAutomation a : autos) {
  //      a.setPosition(u.getValue());
  //    }
  //    super.setPosition(u);
  //  }
  @Override
  public void setLoopType(LoopType l) {
    super.setLoopType(l);
    if (loopType == LoopType.NO_LOOP_FORWARDS || loopType == LoopType.NO_LOOP_BACKWARDS) {
      for (KnobAutomation a : autos) {
        a.setLoop(false);
      }
    } else {//all is loop.
      for (KnobAutomation a : autos) {
        a.setLoop(true);
      }
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
