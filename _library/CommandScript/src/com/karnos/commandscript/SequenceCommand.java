package com.karnos.commandscript;
import java.util.Iterator;
//this is not perfect code for now because if executing command duration is long, process will be just delayed. add system.gettime() between time measurements and set time to real time.
public class SequenceCommand implements Runnable, Iterable<SequenceCommand.TimeCommand> {
  protected TimeCommand progress;// stores time
  protected int start = 0;
  protected int end = 0;// end is not included.
  protected Multiset<TimeCommand> commands = new Multiset<TimeCommand>();
  protected boolean finished;
  protected Thread thread;// for interrupt

  public SequenceCommand() {
    finished = true;
    progress = new TimeCommand(0, null);
  }

  synchronized public void add(int time, Command command) {
    commands.add(new TimeCommand(time, command));
    if (!finished && thread != null) {//change this interrupts to - if command is added into time and next command.
      thread.interrupt();
    }
  }

  public TimeCommand get(int index) {
    return commands.get(index);
  }

  public void remove(int index) {
    commands.remove(index);
  }

  synchronized public void setTime(int time) {
    if (time < 0)
      time = 0;
    setNext();
    if (!finished && thread != null) {
      thread.interrupt();
    }
  }

  synchronized public void finish() {
    finished = true;
    if (!finished && thread != null) {
      thread.interrupt();
    }
  }

  public void start() {
    thread = new Thread(this);
    thread.start();
  }

  @Override
    public void run() {
    setTime(progress.time);
    finished = false;
    while (!finished) {
      if (start < commands.size()) {
        int t = progress.time;
        progress.time = commands.get(start).time;
        try {
          Thread.sleep(progress.time - t);
        }
        catch (InterruptedException e) {
        }
      } else {// no next command
        start = 0;
        end = 0;
        try {
          Thread.sleep(10000);// 10 seconds
        }
        catch (InterruptedException e) {
          // just wake thread.
        }
      }
      // if commands left, execute.
      while (start < end) {
        commands.get(start).command.execute(progress.time);
        start++;
      }
      setNext();
      // search for next command
    }
  }

  synchronized private void setNext() {
    start = commands.getBeforeIndex(progress);// time is past.
    if(start>=commands.size())end=start;
    else end = commands.getBeforeIndex(commands.get(start));
  }

  public static class TimeCommand implements Comparable<TimeCommand> {
    public int time;
    public Command command;

    public TimeCommand(int time_, Command command_) {// all time is ms.
      time = time_;
      command = command_;
    }

    @Override
      public int compareTo(TimeCommand other) {
      return time - other.time;
    }
  }

  @Override
    public Iterator<TimeCommand> iterator() {
    return commands.iterator();
  }
}
