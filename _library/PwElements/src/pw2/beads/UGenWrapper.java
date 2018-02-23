package pw2.beads;
import beads.AudioContext;
import beads.UGenChain;
import kyui.util.Task;
import kyui.util.TaskManager;

import java.util.LinkedList;
public abstract class UGenWrapper extends UGenChain {//solve synchronization error with task system.
  public static float GLIDE_TIME=30;
  TaskManager tm=new TaskManager();
  //Task setFrequency...
  public UGenWrapper(AudioContext audioContext, int in, int out) {
    super(audioContext, in, out);
  }
  public void changeParameter(Task task, Double value) {
    tm.addTask(task, value);
  }
  @Override
  protected void preFrame() {
    tm.executeAll();
  }
}
