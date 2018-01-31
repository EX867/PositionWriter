import java.util.LinkedList;
class LedCounter {
  boolean active=false;//if not active, it will removed from list.
  LedScript script;
  long offset;//start point of this script.
  //controls
  boolean paused=true;//if paused,counter will not increase.
  boolean loop=false;
  int loopStart=0;
  int loopEnd=100;
  LedCounter(LedScript script_, long offset_) {
    script=script_;
    offset=offset_;
  }
}
class LightThread implements Runnable {
  Thread thread;//must set!!
  HashMap<IntVector2, LedCounter> scripts=new HashMap<IntVector2, LedCounter>();
  LinkedList<LedCounter> active=new LinkedList<LedCounter>();
  MidiMapDevice deviceLink;
  //
  //syncs are needed when ui thread access this thread. and interrupt.
  //use these when load/remove led.
  void addTrack(IntVector2 coord, LedScript script) {
    synchronized(this) {
      scripts.put(coord, new LedCounter(script, System.currentTimeMillis()));
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
    synchronized(led.script) {
      led.offset=System.currentTimeMillis()-displayTime;
      led.script.displayTime=displayTime;
      led.script.setFrameByTime();
      led.active=true;
      led.paused=false;
    }
    thread.interrupt();
  }
  void pause(LedCounter led) {
    synchronized(led.script) {
      led.paused=true;
      led.script.displayTime=(int)(System.currentTimeMillis()-led.offset);
    }
    thread.interrupt();
  }
  void unPause(LedCounter led) {
    synchronized(led.script) {
      led.paused=false;
      led.offset=System.currentTimeMillis()-led.script.displayTime;
    }
    thread.interrupt();
  }

  public void run() {
    while (true) {
      long nextDelay=0;
      int d=0;
      while (d<active.size()) {
        if (active.get(d).active) {
          d++;
        } else {
          active.remove(d);
        }
      }
      for (LedCounter led : active) {
        synchronized(this) {
          led.script.displayTime=(int)(System.currentTimeMillis()-led.offset);
          led.script.setFrameByTime();
          int[][] display=led.script.displayPad.display;
          displayControl(led.script, display);//process script's displayFrame frame.
          for (int b=1; b<=display[0].length; b++) {//assert display.length>0
            for (int a=1; a<=display.length; a++) {
              //MidiCommand.execute("led", line.vel, a-1, b-1);
            }
          }
          if (led.script.displayFrame<led.script.DelayPoint.size()-1) {//not end
            led.script.displayFrame++;
            //nextDelay=
          } else {
            led.script.displayFrame=0;
            if (led.loop) {
              led.offset=System.currentTimeMillis()-led.loopStart;
            } else {
              led.offset=System.currentTimeMillis();
              led.active=false;
            }
          }
        }//synchronized
      }//for counter
      try {
        Thread.sleep(nextDelay);
      }
      catch(InterruptedException e) {
      }
    }
  }
  void displayControl(LedScript script, int[][] display) {
    int last=script.getCommands().size();
    if (script.displayFrame+1<script.DelayPoint.size()) {
      last=min(last, script.DelayPoint.get(script.displayFrame+1));
    }
    synchronized(script.displayPad) {
      for (int c=script.DelayPoint.get(script.displayFrame); c<last; c++) {
        Command cmd=script.getCommands().get(c);
        if (cmd instanceof OnCommand) {//#ADD midi command in here
          OnCommand info=(OnCommand)cmd;
          for (int b=max(1, info.y1); b<=info.y2&&b<=display[0].length; b++) {
            for (int a=max(1, info.x1); a<=info.x2&&a<=display.length; a++) {
              if (info.htmlc==COLOR_OFF) {//velocity
                if (info.vel>=0&&info.vel<128) {
                  display[a-1][b-1]=color_lp[info.vel];
                }
              } else if (info.htmlc==COLOR_RND) {//random
                display[a-1][b-1]=floor(random(0, 128));
              } else {
                display[a-1][b-1]=info.htmlc;
              }
            }
          }
        } else if (cmd instanceof OffCommand) {
          OffCommand info=(OffCommand)cmd;
          for (int b=max(1, info.y1); b<=info.y2&&b<=display[0].length; b++) {
            for (int a=max(1, info.x1); a<=info.x2&&a<=display.length; a++) {
              if (a>0&&b>0&&a<=display.length&&b<=display[0].length) {
                display[a-1][b-1]=COLOR_OFF;
              }
            }
          }
        } else if (cmd instanceof ChainCommand) {
          //ksChainListener.accept(0,((ChainCommand)cmd).chain-1,PadButton.PRESS_L);
        } else if (cmd instanceof MappingCommand) {
          //MappingCommand info=(MappingCommand)cmd;
          //KsButton btn=KS.get(ksChain)[info.x-1][info.y-1];
          //if (btn.vel!=0) {
          //  int size=btn.ksSound.size();
          //  if (btn.vel>=0&&btn.vel<size)btn.multiSound=min(max(1, btn.vel+1), size)-1;
          //} else {
          //  int size=btn.ksLedFile.size();
          //  if (btn.vel>=0&&btn.vel<size) {
          //    btn.multiLed=min(max(1, btn.vel+1), size)-1;
          //    btn.multiLedBackup=btn.multiLed;
          //  }
          //}
        }
      }
      script.editor.invalidate();
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