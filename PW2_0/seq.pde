import java.util.LinkedList;
class LedCounter {
  LedScript script;
  int counter;
  long offset;//start point of this script.
  boolean active=false;//if not active, it will removed from list.
  boolean paused=true;//if paused,counter will not increase.
  LedCounter(LedScript script_, int counter_, long offset_) {
    script=script_;
    counter=counter_;
    offset=offset_;
  }
}
class LightThread implements Runnable {
  Thread thread;//must set!!
  int current;//current time (display time(ms))
  HashMap<IntVector2, LedCounter> scripts=new HashMap<IntVector2, LedCounter>();
  LinkedList<LedCounter> active=new LinkedList<LedCounter>();
  //MidiDevice deviceLink;
  //
  //syncs are needed when ui thread access this thread. and interrupt.
  //use these when load/remove led.
  void addTrack(IntVector2 coord, LedScript script) {
    synchronized(this) {
      scripts.put(coord, new LedCounter(script, 0, System.currentTimeMillis()));
    }
    thread.interrupt();
  }
  void removeTrack(IntVector2 coord) {
    synchronized(this) {
      scripts.get(coord).active=false;//auto remove
      scripts.remove(coord);
    }
    thread.interrupt();
  }
  //use this when user pressed keySound button
  void start(IntVector2 coord) {
    LedCounter led=scripts.get(coord);
    if (led!=null) {
      start(led, 0);
    }
  }
  //use this when user press led play.
  void start(LedCounter led, int displayTime) {
    synchronized(this) {
      led.offset=System.currentTimeMillis()-displayTime;
      led.script.displayTime=displayTime;
      led.script.setFrameByTime();
      led.counter=led.script.DelayPoint.get(led.script.displayFrame);
      led.active=true;
      led.paused=false;
    }
    thread.interrupt();
  }
  void pause(LedCounter led) {
    synchronized(this) {
      led.paused=true;
      led.script.displayTime=(int)(System.currentTimeMillis()-led.offset);
    }
    thread.interrupt();
  }
  void unPause(LedCounter led) {
    synchronized(this) {
      led.paused=false;
      led.offset=System.currentTimeMillis()-led.script.displayTime;
    }
    thread.interrupt();
  }

  long checkNextDelay() {
    return 0;
  }
  public void run() {
    while (true) {
      synchronized(this) {
      }
      try {
        Thread.sleep(checkNextDelay());
      }
      catch(InterruptedException e) {
      }
    }
  }
}
Multiset<Integer> calculateDelayValue(LedScript script, Multiset<Integer> delayValue) {//for led 
  delayValue.clear();
  int before=0;
  for (int a=1; a<script.DelayPoint.size(); a++) {//assert point is DelayCommand
    int line=script.DelayPoint.get(a);
    delayValue.add(before+((DelayCommand)script.getCommands().get(line)).getValue(script.getBpm(line)));
    before=delayValue.get(delayValue.size()-1);
  }
  return delayValue;
}