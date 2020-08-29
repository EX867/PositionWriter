import java.util.LinkedList;
import java.util.TreeSet;
import java.util.Collections;
class LedCounter implements Comparable<LedCounter> {
  boolean active=false;//if not active, it will removed from list.
  //
  LedScript script;
  long offset;//start point of this script.
  int loopCount=1;
  int loopIndex=1;//count by 1 until it reach loop count!
  KsButton link;//oh I had to find that led is assigned to what button
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
    int ret= (int)(offset+script.displayTime-other.offset-other.script.displayTime);
    if (ret==0) {
      return 1;
    }
    return ret;
  }
}
class LightThread implements Runnable {
  Thread thread;//must set!!
  boolean active=true;//set inactive to exit.
  TreeSet<LedCounter> queue=new TreeSet<LedCounter>();//new LinkedList<LedCounter>()
  Device device;
  int[][] display=new int[0][0];//used to not change LED array values...
  int[][] velDisplay=new int[0][0];
  boolean sleeping=false;
  //
  //syncs are needed when ui thread access this thread. and interrupt.
  //use these when load/remove led.
  LedCounter addTrack(LedScript script) {//meaningless...
    LedCounter counter=new LedCounter(script, System.currentTimeMillis());
    return counter;
  }
  void removeTrack(LedCounter script) {
    script.active=false;//auto remove
  }
  //use this when user press led play.
  void start(LedCounter led, long displayTime) {
    synchronized(queue) {
      synchronized(led) {
        led.offset=System.currentTimeMillis()-displayTime;
        led.active=true;
        led.paused=false;
        led.loopIndex=1;
        led.script.setDisplayFrame(led.script.getFrameByTime(displayTime));
        led.script.setTimeByFrame();
      }
      checkDisplay(led.script.displayPad);
      if (led.script.displayPad==led_pad) {
        copyFrame(led.script.LED.get(led.script.displayFrame), led.script.velLED.get(led.script.displayFrame));
      }
      queue.remove(led);
      queue.add(led);
      //println(displayTime+" -> start");
    }
    if (sleeping) {
      thread.interrupt();
    }
  }
  void stop(LedCounter led) {
    led.active=false;
    synchronized(queue) {
      queue.remove(led);
      //println(" -> remove");
    }
  }
  void pause(LedCounter led) {
    led.paused=true;
    synchronized(queue) {
      queue.remove(led);
    }
    led.script.displayTime=(int)(System.currentTimeMillis()-led.offset);
    led.script.setFrameByTime();
    if (sleeping) {
      thread.interrupt();
    }
  }
  void unPause(LedCounter led) {
    synchronized(queue) {
      led.paused=false;
      led.offset=System.currentTimeMillis()-led.script.displayTime;
      queue.remove(led);
      queue.add(led);
      //println(" -> reset");
    }
    if (sleeping) {
      thread.interrupt();
    }
  }
  void checkDisplay(PadButton pad) {
    if (pad==null) {
      System.err.println("seq : pad is null!");
      return;
    }
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
      //if (led.paused) {
      //  unPause(led);
      //}
      if (sleeping) {
        thread.interrupt();
      }
    }
  }
  void updateFs(long time) {
    fs.set(time);
    fs.invalidate();
    fsTime.text=time+"/"+fs.maxI;
    fsTime.invalidate();
  }
  void stopAll() {
    synchronized(queue) {
      while (queue.size()>0) {
        LedCounter led=queue.pollFirst();
        led.active=false;
      }
    }
    for (int a=0; a<display.length; a++) {//assert display.length>0
      for (int b=0; b<display[a].length; b++) {
        display[a][b]=0;
        velDisplay[a][b]=0;
      }
    }
  }
  public void run() {
    while (active) {
      boolean calcDisplay=false;
      LedCounter first=null;
      synchronized(queue) {
        if (queue.size()>0&&!(mainTabs_selected==LED_EDITOR&&fs.hold())) {
          LedCounter led=queue.pollFirst();
          if (led.active&&!led.paused) {
            PadButton pad=led.script.displayPad;
            checkDisplay(pad);
            if ((mainTabs_selected==LED_EDITOR&&led==currentLed.led)||(mainTabs_selected==KS_EDITOR&&(led.link==null||led.link.session==currentKs))) {
              synchronized(pad) {
                pad.displayControl(display);
                displayControlSequence(led.script, display, velDisplay);//write script's displayFrame frame to display.
              }
            } else {
              displayControlSequence(led.script, display, velDisplay);//write script's displayFrame frame to display.
            }
            midiControl(velDisplay);
            boolean notEnd=led.script.displayFrame<led.script.DelayPoint.size()-1;
            if (led.loopStart<led.loopEnd) {
              notEnd=notEnd&&led.script.displayTime<led.loopEnd;//led.script.getTimeByFrame(led.script.displayFrame+1)
            }
            if (notEnd) {//not end
              if (mainTabs_selected==LED_EDITOR&&led==currentLed.led) {
                updateFs(currentLedEditor.displayTime);//led.script.displayTime
              }
              led.script.displayTime=led.script.getTimeByFrame(led.script.displayFrame+1);
              if (led.loopStart<led.loopEnd) {
                led.script.displayTime=Math.min(led.script.displayTime, led.loopEnd);
              }
              int frame=led.script.getFrameByTime(led.script.displayTime);
              led.script.setDisplayFrame(frame);
              //led.script.setDisplayFrame(min(led.script.displayFrame+1, frame));
              //println(" -> continue");
              queue.remove(led);
              queue.add(led);
            } else {//frame out of range.
              synchronized(led) {
                if (led.loop||(led.loopCount==0&&led.loopIndex!=-1)||(led.loopIndex!=-1&&led.loopIndex<led.loopCount)) {
                  led.script.displayTime=0;
                  if (led.loopStart<led.loopEnd) {
                    led.script.displayTime=led.loopStart;
                  }
                  led.offset=System.currentTimeMillis()-led.script.displayTime;
                  led.script.setDisplayFrame(led.script.getFrameByTime(led.script.displayTime)+1);
                  led.script.setTimeByFrame();
                  queue.remove(led);
                  queue.add(led);
                  led.loopIndex++;
                } else {
                  if (led.loopCount==0) {
                    led.script.infiniteLoopOff(display, velDisplay);
                  }
                  if (led.loopStart<led.loopEnd) {
                    led.script.displayTime=led.loopEnd;
                    led.script.setFrameByTime();
                  }
                  led.active=false;
                  midiControl(velDisplay);
                  //println(" -> end");
                }
              }
              if (mainTabs_selected==LED_EDITOR) {
                copyFrame(led.script.LED.get(led.script.displayFrame), led.script.velLED.get(led.script.displayFrame));
                if (led==currentLed.led) {
                  updateFs(currentLedEditor.displayTime);
                }
              }
            }
          }
          if (queue.size()>0) {
            first=queue.first();
            calcDisplay=!(mainTabs_selected==LED_EDITOR&&fs.hold());
          }
        }
      }//synchronized
      if (mainTabs_selected==LED_EDITOR||mainTabs_selected==KS_EDITOR) {
        frame_main.invalidated=true;
      }
      if (calcDisplay) {
        long nextTime=0;
        synchronized(first) {
          nextTime=first.script.displayTime-System.currentTimeMillis()+first.offset;
          if (first.loopStart<first.loopEnd) {
            nextTime=Math.min(nextTime, first.loopEnd+first.offset-System.currentTimeMillis());
          }
        }
        if (nextTime>0) {
          sleeping=true;
          try {
            //println("["+frameCount+"] delay : "+(nextTime));
            Thread.sleep(nextTime);
          }
          catch(InterruptedException e) {
          }
          sleeping=false;
        }
      } else {
        sleeping=true;
        try {
          Thread.sleep(10000);
        }
        catch(InterruptedException e) {
        }
        sleeping=true;
      }
    }
  }
  void displayControlSequence(LedScript script, int[][] display, int[][] velDisplay) {
    int last=script.getCommands().size();
    if (script.displayFrame+1<script.DelayPoint.size()) {
      last=min(last, script.DelayPoint.get(script.displayFrame+1));
    } else if (script.displayFrame>=script.DelayPoint.size()) {
      return;//escape from error
    }
    //synchronized(script.displayPad) {
    for (int c=script.DelayPoint.get(script.displayFrame)+1; c<last; c++) {
      Command cmd=script.getCommands().get(c);
      if (cmd instanceof OnCommand) {
        OnCommand onCmd=(OnCommand)cmd;
        for (int b=max(1, onCmd.y1); b<=onCmd.y2&&b<=display[0].length; b++) {
          for (int a=max(1, onCmd.x1); a<=onCmd.x2&&a<=display.length; a++) {
            if (onCmd.vel!=0) {//velocity
              if (onCmd.vel>=0&&onCmd.vel<128) {
                display[a-1][b-1]=color_vel[onCmd.vel];
                velDisplay[a-1][b-1]=onCmd.vel;
              }
            } else if (onCmd.htmlc==COLOR_RND) {//random
              velDisplay[a-1][b-1]=floor(random(1, 128));
              display[a-1][b-1]=color_vel[velDisplay[a-1][b-1]];
            } else {//there are people off with on auto 0.
              display[a-1][b-1]=onCmd.htmlc;
              velDisplay[a-1][b-1]=COLOR_OFF;
            }
          }
        }
      } else if (cmd instanceof OffCommand) {
        OffCommand offCmd=(OffCommand)cmd;
        for (int b=max(1, offCmd.y1); b<=offCmd.y2&&b<=display[0].length; b++) {
          for (int a=max(1, offCmd.x1); a<=offCmd.x2&&a<=display.length; a++) {
            if (a>0&&b>0&&a<=display.length&&b<=display[0].length) {
              display[a-1][b-1]=COLOR_OFF;
              velDisplay[a-1][b-1]=COLOR_OFF;
            }
          }
        }
      } else if (cmd instanceof ChainCommand) {
        IntVector2 vec=new IntVector2(0, ((ChainCommand)cmd).c-1);
        ((PadButton)KyUI.get("ks_chain")).buttonListener.accept(vec, vec, PadButton.PRESS_L);
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
      } else if (cmd instanceof ApOnCommand) {
        ApOnCommand apOn=(ApOnCommand)cmd;
        for (int a=max(1, apOn.x1); a<=apOn.x2&&a<=display.length; a++) {
          for (int b=max(1, apOn.y1); b<=apOn.y2&&b<=display[a].length; b++) {
            IntVector2 vec=new IntVector2(a-1, b-1);
            ks_pad.buttonListener.accept(vec, vec, PadButton.PRESS_L);
          }
        }
      } else if (cmd instanceof ApOffCommand) {
        ApOffCommand apOff=(ApOffCommand)cmd;
        for (int a=max(1, apOff.x1); a<=apOff.x2&&a<=display.length; a++) {
          for (int b=max(1, apOff.y1); b<=apOff.y2&&b<=display[a].length; b++) {
            IntVector2 vec=new IntVector2(a-1, b-1);
            ks_pad.buttonListener.accept(vec, vec, PadButton.RELEASE_L);
          }
        }
      }
    }
    //}
    script.displayPad.invalidate();
  }
  void midiControl(int[][] velDisplay) {
    if (device==null) {
      return;
    }
    if (velDisplay==null) {
      return;
    }
    println("send frame data to "+device.name);
    for (int b=0; b<velDisplay[0].length; b++) {//assert display.length>0 //it is okay to send all?
      for (int a=0; a<velDisplay.length; a++) {
        //println(a+" "+b+" : "+velDisplay[a][b]);

        device.output("led", velDisplay[a][b], a, b);//linkDevice...
        //if (velDisplay[a][b]==NONE) {
        //  device.output("off", velDisplay[a][b], a, b);//linkDevice...
        //}
      }
    }
  }
}
Multiset<Long> calculateDelayValue(LedScript script, Multiset<Long> delayValue) {//for led 
  delayValue.clear();
  delayValue.add(0L);
  long before=0;
  for (int a=1; a<script.DelayPoint.size(); a++) {//assert point is DelayCommand
    int line=script.DelayPoint.get(a);
    delayValue.add(before+script.getDelayValue(line));
    before=delayValue.get(delayValue.size()-1);
  }
  return delayValue;
}
