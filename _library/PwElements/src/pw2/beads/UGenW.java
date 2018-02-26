package pw2.beads;
import beads.*;
import kyui.util.Task;
import kyui.util.TaskManager;
import pw2.element.Knob;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.function.Consumer;
public abstract class UGenW extends UGenChain {//solve synchronization error with task system.
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
  protected Field reflectedChainOutField;
  protected UGen reflectedChainOut;
  protected Field bufOutField;
  protected Transfer transfer;
  @Override
  public void kill() {
    transfer.kill();
    super.kill();
  }
  public UGenW(AudioContext ac, int in, int out) {
    super(ac, in, out);
    transfer=new Transfer(ac, in, out);
    try {
      reflectedChainOutField=UGenChain.class.getDeclaredField("chainOut");
      reflectedChainOutField.setAccessible(true);
      reflectedChainOut=(UGen)reflectedChainOutField.get(this);
      Field field=UGenChain.class.getDeclaredField("chainIn");
      field.setAccessible(true);
      bufOutField=UGen.class.getDeclaredField("bufOut");
      bufOutField.setAccessible(true);
      bufOutField.set(transfer, bufOut);
      transfer.addInput((UGen)field.get(this));
    } catch (Exception e) {
      System.err.println("reflection failed");
      e.printStackTrace();
    }
  }
  public void changeParameter(Task task, Double value) {
    tm.addTask(task, value);
  }
  public void changeParameter(Parameter task, Double value) {
    tm.addTask(task.setter, value);
  }
  @Override
  protected void preFrame() {
    tm.executeAll();
  }
  @Override
  protected void postFrame() {
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
      try {
        if (v) {
          reflectedChainOutField.set(this, transfer);
        } else {
          reflectedChainOutField.set(this, reflectedChainOut);
        }
      } catch (Exception e) {
        e.printStackTrace();
      }
      onBypass(v);
    }, null);
  }
  protected abstract void onBypass(boolean v);
}
