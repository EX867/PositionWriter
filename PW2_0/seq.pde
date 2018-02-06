import java.util.LinkedList;
import java.util.TreeSet;
class LedCounter implements Comparable<LedCounter> {
  boolean active=false;//if not active, it will removed from list.
  //
  LedScript script;
  long offset;//start point of this script.
  int loopCount=0;//count by 1 until it reach LedScript's loop count!
  //controls
  boolean paused=true;//if paused,counter will not increase.
  boolean loop=false;
  int loopStart=0;
  int loopEnd=0;
  LedCounter(LedScript script_, long offset_) {
    script=script_;
    offset=offset_;
  }
  public int compareTo(LedCounter other) {
    return (int)(offset+script.displayTime-other.offset-other.script.displayTime);
  }
}
class LightThread implements Runnable {
  Thread thread;//must set!!
  boolean active=true;//set inactive to exit.
  HashMap<IntVector2, LedCounter> scripts=new HashMap<IntVector2, LedCounter>();
  TreeSet<LedCounter> queue=new TreeSet<LedCounter>();//new LinkedList<LedCounter>()
  MidiMapDevice deviceLink;
  int[][] display;//used to not change LED array values...
  int[][] velDisplay;
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
      //led.script.displayTime=displayTime;
      //led.script.setFrameByTime();
      led.active=true;
      led.paused=false;
      led.loopCount=0;
      led.script.displayFrame=led.script.getFrameByTime(displayTime);
      led.script.setTimeByFrame();
      checkDisplay(led.script.displayPad);
      if (mainTabs_selected==LED_EDITOR) {
        copyFrame(led.script.LED.get(led.script.displayFrame), led.script.velLED.get(led.script.displayFrame));
      }
      queue.add(led);
    }
    thread.interrupt();
  }
  void pause(LedCounter led) {
    synchronized(led.script) {
      led.paused=true;
      queue.remove(led);
      led.script.displayTime=(int)(System.currentTimeMillis()-led.offset);
      led.script.setFrameByTime();
      //queue.add(led);
    }
    thread.interrupt();
  }
  void unPause(LedCounter led) {
    synchronized(led.script) {
      led.paused=false;
      led.offset=System.currentTimeMillis()-led.script.displayTime;
      queue.add(led);
    }
    thread.interrupt();
  }
  void checkDisplay(PadButton pad) {
    if (display==null||display.length!=pad.size.x||display[0].length!=pad.size.y) {
      display=new int[pad.size.x][pad.size.y];
    }
    if (velDisplay==null||velDisplay.length!=pad.size.x||velDisplay[0].length!=pad.size.y) {
      velDisplay=new int[pad.size.x][pad.size.y];
    }
  }
  void copyFrame(int[][] display_, int[][] velDisplay_) {
    for (int b=0; b<display[0].length; b++) {
      for (int a=0; a<display.length; a++) {
        display[a][b]=display_[a][b];
        velDisplay[a][b]=velDisplay_[a][b];
      }
    }
  }
  void unhold() {
    if (queue.size()>0) {
      LedCounter led=queue.first();  
      copyFrame(led.script.LED.get(led.script.displayFrame), led.script.velLED.get(led.script.displayFrame));
      led.offset=System.currentTimeMillis()-led.script.displayTime;
      thread.interrupt();
    }
  }
  void updateFs(int time) {
    fs.set(time);
    fs.invalidate();
    fsTime.text=time+"/"+fs.maxI;
    fsTime.invalidate();
  }
  public void run() {
    while (active) {
      if (queue.size()>0) {
        if (!(mainTabs_selected==LED_EDITOR&&fs.hold())) {
          LedCounter led=queue.pollFirst();
          if (led.active) {
            PadButton pad=led.script.displayPad;
            checkDisplay(pad);
            synchronized(led.script) {
              if (mainTabs_selected!=LED_EDITOR||led==currentLed.led) {
                pad.displayControl(display);
              }
              displayControlSequence(led.script, display, velDisplay);//write script's displayFrame frame to display.
              midiControl(velDisplay);
              boolean notEnd=led.script.displayFrame<led.script.DelayPoint.size()-1;
              if (led.loopStart<led.loopEnd) {
                notEnd=notEnd&&led.script.displayTime<led.loopEnd;//led.script.getTimeByFrame(led.script.displayFrame+1)
              }
              if (notEnd) {//not end
                //led.script.displayTime=(int)(System.currentTimeMillis()-led.offset);//led.script.displayFrame++;
                led.script.displayTime=led.script.getTimeByFrame(led.script.displayFrame+1);
                if (led.loopStart<led.loopEnd) {
                  led.script.displayTime=Math.min(led.script.displayTime, led.loopEnd);
                }
                led.script.setFrameByTime();
                if (mainTabs_selected==LED_EDITOR&&led==currentLed.led) {
                  updateFs(currentLedEditor.displayTime);//led.script.displayTime
                }
                queue.add(led);
              } else {//frame out of range.
                if (led.loop) {
                  led.script.displayTime=0;
                  if (led.loopStart<led.loopEnd) {
                    led.script.displayTime=led.loopStart;
                  }
                  led.offset=System.currentTimeMillis()-led.script.displayTime;
                  led.script.displayFrame=led.script.getFrameByTime(led.script.displayTime)+1;
                  led.script.setTimeByFrame();
                  queue.add(led);
                } else {
                  if (led.loopStart<led.loopEnd) {
                    led.script.displayTime=led.loopEnd;
                    led.script.setFrameByTime();
                  }
                  led.active=false;
                }
                if (mainTabs_selected==LED_EDITOR) {
                  copyFrame(led.script.LED.get(led.script.displayFrame), led.script.velLED.get(led.script.displayFrame));
                  if (led==currentLed.led) {
                    updateFs(currentLedEditor.displayTime);
                  }
                }
              }
            }//synchronized
          }
        }
      }
      if (queue.size()!=0&&!(mainTabs_selected==LED_EDITOR&&fs.hold())) {
        try {
          LedCounter led=queue.first();
          LedScript scr=led.script;
          long nextTime=scr.displayTime-System.currentTimeMillis()+led.offset;
          if (led.loopStart<led.loopEnd) {
            nextTime=Math.min(nextTime, led.loopEnd+led.offset-System.currentTimeMillis());
          }
          //println("["+frameCount+"] delay : "+(nextTime));
          if (nextTime>0) {
            Thread.sleep(nextTime);
          }
        }
        catch(InterruptedException e) {
        }
      } else {
        try {
          Thread.sleep(10000);
        }
        catch(InterruptedException e) {
        }
      }
    }
  }
  void displayControlSequence(LedScript script, int[][] display, int[][] velDisplay) {
    int last=script.getCommands().size();
    if (script.displayFrame+1<script.DelayPoint.size()) {
      last=min(last, script.DelayPoint.get(script.displayFrame+1));
    }
    synchronized(script.displayPad) {
      for (int c=script.DelayPoint.get(script.displayFrame)+1; c<last; c++) {
        Command cmd=script.getCommands().get(c);
        if (cmd instanceof OnCommand) {//#ADD midi command in here
          OnCommand info=(OnCommand)cmd;
          for (int b=max(1, info.y1); b<=info.y2&&b<=display[0].length; b++) {
            for (int a=max(1, info.x1); a<=info.x2&&a<=display.length; a++) {
              if (info.vel!=0) {//velocity
                if (info.vel>=0&&info.vel<128) {
                  display[a-1][b-1]=color_vel[info.vel];
                  velDisplay[a-1][b-1]=info.vel;
                }
              } else if (info.htmlc==COLOR_RND) {//random
                velDisplay[a-1][b-1]=floor(random(0, 128));
                display[a-1][b-1]=color_vel[velDisplay[a-1][b-1]];
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
                velDisplay[a-1][b-1]=COLOR_OFF;
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
    }
    script.displayPad.invalidate();
  }
}
void midiControl(int[][] velDisplay) {
  for (int b=0; b<velDisplay[0].length; b++) {//assert display.length>0
    for (int a=0; a<velDisplay.length; a++) {
      //println(a+" "+b+" : "+velDisplay[a][b]);
      MidiCommand.execute("led", velDisplay[a][b], a, b);
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