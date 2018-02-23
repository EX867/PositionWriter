package pw2.beads;
import beads.AudioContext;
import beads.UGenChain;
import kyui.util.Task;
import kyui.util.TaskManager;

import java.util.ArrayList;
import java.util.LinkedList;
public abstract class UGenW extends UGenChain {//solve synchronization error with task system.
  public static float GLIDE_TIME=30;
  TaskManager tm=new TaskManager();
  ArrayList<UGenListener> listener=new ArrayList<>();
  //Task setFrequency...
  public UGenW(AudioContext audioContext, int in, int out) {
    super(audioContext, in, out);
  }
  public void changeParameter(Task task, Double value) {
    tm.addTask(task, value);
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
}
