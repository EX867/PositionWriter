package pw2.beads;
import beads.*;

import java.util.ArrayList;
import java.util.List;
public class AutoControlSamplePlayer extends SamplePlayer {
  public ArrayList<UGen> ugensBefore=new ArrayList<UGen>();
  public ArrayList<UGen> outputs=new ArrayList<>();//I need reflection to get outputs, but I can also manually add it.
  public ArrayList<KnobAutomation> autos=new ArrayList<>();
  public AutoControlSamplePlayer(AudioContext ac, int i) {
    super(ac, i);
  }
  public AutoControlSamplePlayer(AudioContext ac, Sample s) {
    super(ac, s);
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
  public void addInputTo(UGen out) {//sampleplayer cannot add input.
    out.addInput(this);
    outputs.add(out);
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
  /*
  input -> ugenBefore[0] -> ugenBefore[1] -> ... -> this
  */
  public List<KnobAutomation> addUGenAndGetAutos(UGen u) {
    return addUGenAndGetAutos(autos.size(), u);
  }
  public List<KnobAutomation> addUGenAndGetAutos(int index, UGen u) {//add ugen to before ugen list.
    if (index == 0) {
      for (UGen output : outputs) {
        if (ugensBefore.size() == 0) {
          output.removeAllConnections(this);
        } else {
          output.removeAllConnections(ugensBefore.get(0));
        }
      }
      for (UGen output : outputs) {
        output.addInput(u);
      }
      if (ugensBefore.size() == 0) {
        u.addInput(this);
      } else {
        u.addInput(ugensBefore.get(0));
      }
    } else if (index == ugensBefore.size()) {
      removeAllConnections(ugensBefore.get(ugensBefore.size() - 1));
      ugensBefore.get(ugensBefore.size() - 1).addInput(u);
      u.addInput(this);
    } else {
      ugensBefore.get(index).removeAllConnections(ugensBefore.get(index - 1));
      ugensBefore.get(index - 1).addInput(u);
      u.addInput(ugensBefore.get(index));
    }
    ugensBefore.add(index, u);
    if (u instanceof UGenW) {
      return ((UGenW)u).getAutomations();
    }
    return new ArrayList<>();
  }
  public UGen removeUGenAndAutos(int index, List<KnobAutomation> list) {
    if (autos.size() == 0) return null;
    UGen remove=ugensBefore.get(index);
    UGen after=null;
    if (index == ugensBefore.size() - 1) {
      after=this;
    } else {
      after=ugensBefore.get(index + 1);
    }
    if (index == 0) {
      for (UGen output : outputs) {
        output.removeAllConnections(remove);
      }
      for (UGen output : outputs) {
        output.addInput(after);
      }
    } else {
      ugensBefore.get(index - 1).removeAllConnections(remove);
      ugensBefore.get(index - 1).addInput(after);
    }
    remove.removeAllConnections(after);
    if (list != null && remove instanceof UGenW) {
      ((UGenW)remove).removeAutomationsFrom(list);
    }
    return ugensBefore.remove(index);
  }
  public void reorderUGens(int a, int b) {
    if (a == b) {
      return;
    }
    if (b < a) {
      int temp=a;
      a=b;
      b=temp;
    }
    UGen bb=removeUGenAndAutos(b, null);
    UGen aa=removeUGenAndAutos(a, null);
    addUGenAndGetAutos(a, bb);
    addUGenAndGetAutos(b, aa);
  }
}
