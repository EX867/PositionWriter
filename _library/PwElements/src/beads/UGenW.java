package beads;
import beads.*;
import kyui.util.Task;
import kyui.util.TaskManager;
import pw2.beads.KnobAutomation;
import pw2.beads.UGenListener;
import pw2.element.Knob;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.function.Consumer;
public abstract class UGenW extends UGen {//solve synchronization error with task system.
  public class Parameter {
    public Task setter;
    public Consumer<Knob> attacher;
    public Parameter(Task setter_, Consumer<Knob> attacher_) {
      setter=setter_;
      attacher=attacher_;
    }
  }
  TaskManager tm=new TaskManager();
  ArrayList<UGenListener> listener=new ArrayList<>();
  boolean bypass=false;
  //Task setFrequency...
  public UGenW(AudioContext ac, int in, int out) {
    super(ac, in, out);
  }
  public void changeParameter(Task task, Double value) {
    tm.addTask(task, value);
  }
  public void changeParameter(Parameter task, Double value) {
    tm.addTask(task.setter, value);
  }
  protected abstract UGen updateUGens();//to output.
  protected final void updateUGen(UGen ugen) {
    ugen.initializeOuts();
    ugen.calculateBuffer();
  }
  protected final void setStartPoint(UGen ugen) {
    ugen.outputInitializationRegime=OutputInitializationRegime.RETAIN;
  }
  protected final void giveInputTo(UGen ugen, int inputIndex, int ugenInputIndex) {
    ugen.bufIn[ugenInputIndex]=bufIn[inputIndex];
  }
  protected final void giveInputTo(UGen ugen) {//if ugen.getIns() and is different ,it fails.
    ugen.bufIn=bufIn;
  }
  @Override
  public void calculateBuffer() {
    tm.executeAll();
    if (bypass) {
      for (int c=0; c < outs; c++) {
        //for (int a=0; a < bufferSize; a++) {
        bufOut[c]=bufIn[c % ins];
        //}
      }
    } else {
      UGen out=updateUGens();
      for (int c=0; c < out.outs; c++) {
        //for (int a=0; a < bufferSize; a++) {
        bufOut[c]=out.bufOut[c];
        //}
      }
    }
    for (int a=0; a < listener.size(); a++) {
      UGenListener l=listener.get(a);
      if (l != null) {
        if (l.isDeleted()) {
          listener.remove(a);
          a--;
        } else if (bufOut != null && bufOut.length > 0 && !l.isPaused()) {
          l.accept(bufOut);
        }
      }
    }
  }
  public void addListener(UGenListener l) {
    listener.add(l);
  }
  public void bypass(boolean v) {
    tm.addTask((o) -> {
      bypass=v;
    }, null);
  }
  public abstract List<KnobAutomation> getAutomations();
  public void removeAutomationsFrom(List<KnobAutomation> list) {
    list.removeAll(getAutomations());
  }
}
