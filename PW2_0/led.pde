java.util.function.Consumer<String> action_print;
java.util.function.BiConsumer<IntVector2, IntVector2> action_on;
java.util.function.BiConsumer<IntVector2, IntVector2> action_off;
void led_setup() {
  action_print=new java.util.function.Consumer<String>() {
    public void accept(String in) {
      int line=currentLedEditor.lines()-1;
      int point=0;
      if (InFrameInput&&currentLedEditor.displayFrame<currentLedEditor.DelayPoint.size()-1) {
        line=currentLedEditor.DelayPoint.get(currentLedEditor.displayFrame+1)-1;
      }
      if (line<0) {
        line=0;
        point=0;
        if (in.length()>0&&in.charAt(0)=='\n') {
          in=in.substring(1, in.length())+"\n";
        }
      } else {
        point=currentLedEditor.getLine(line).length();
      }
      if (line==0&&point==0) {
        in=in.substring(1, in.length());
      }
      currentLedEditor.insert(line, point, in);
    }
  };
  action_on=new java.util.function.BiConsumer<IntVector2, IntVector2>() {
    public void accept(IntVector2 click, IntVector2 coord) {//#ADD inframeinput and start cut
      String pos;
      if (click==null) {
        pos=(coord.y+1)+" "+(coord.x+1);
      } else {//range commands
        pos=(min(click.y, coord.y)+1)+"~"+(max(click.y, coord.y)+1)+" "+(min(click.x, coord.x)+1)+"~"+(max(click.x, coord.x)+1);
      }
      if (currentLedEditor.cmdset==ledCommands) {
        if (ColorMode==VEL) {
          action_print.accept("\non "+pos+" auto "+SelectedColor);
        } else if (ColorMode==HTML) {
          action_print.accept("\non "+pos+" "+hex(SelectedColor, 6));
        }
      } else if (currentLedEditor.cmdset==apCommands) {
        action_print.accept("\non "+pos);
      }
    }
  };
  action_off=new java.util.function.BiConsumer<IntVector2, IntVector2>() {
    public void accept(IntVector2 click, IntVector2 coord) {
      String pos;
      if (click==null) {
        pos=(coord.y+1)+" "+(coord.x+1);
      } else {//range commands
        pos=(min(click.y, coord.y)+1)+"~"+(max(click.y, coord.y)+1)+" "+(min(click.x, coord.x)+1)+"~"+(max(click.x, coord.x)+1);
      }
      action_print.accept("\noff "+pos);
    }
  };
  final java.util.function.Consumer<IntVector2> autoInput=new java.util.function.Consumer<IntVector2>() {
    public void accept(IntVector2 coord) {
      int line=currentLedEditor.getCommands().size();
      int frame=currentLedEditor.LED.size()-1;
      if (InFrameInput) {
        if (currentLedEditor.displayFrame<currentLedEditor.DelayPoint.size()-1)line=currentLedEditor.DelayPoint.get(currentLedEditor.displayFrame+1);
      }
      int aframe=currentLedEditor.getFrame(line);
      int a;
      for (a=line-1; a>=0&&a>currentLedEditor.DelayPoint.get(aframe); a--) {
        Command cmd= currentLedEditor.getCommands().get(a);
        if (cmd instanceof OnCommand) {
          LightCommand info=(LightCommand)cmd;
          if (info.x1<=coord.x+1&&coord.x+1<=info.x2&&info.y1<=coord.y+1&&coord.y+1<=info.y2) {
            if (info.x1==info.x2&&info.y1==info.y2) {
              if (a==0&&currentLedEditor.lines()==1) {
                currentLedEditor.setLine(0, "");
              } else {
                currentLedEditor.deleteLine(a);
              }
            } else {
              action_off.accept(null, coord);
            }
            return;
          }
        } else if (cmd instanceof OffCommand) {
          LightCommand info=(LightCommand)cmd;
          if (info.x1<=coord.x+1&&coord.x+1<=info.x2&&info.y1<=coord.y+1&&coord.y+1<=info.y2) {
            if (info.x1==info.x2&&info.y1==info.y2) {
              if (a==0&&currentLedEditor.lines()==1) {
                currentLedEditor.setLine(0, "");
              } else {
                currentLedEditor.deleteLine(a);
              }
            }
            if (color_vel[SelectedColor]!=currentLedEditor.LED.get(frame)[coord.x][coord.y])action_on.accept(null, coord);//not same
            return;
          }
        }
      }
      for (a--; a>=0; a--) {
        Command cmd= currentLedEditor.getCommands().get(a);
        if (cmd instanceof OnCommand) {
          LightCommand info=(LightCommand)cmd;
          if (info.x1<=coord.x+1&&coord.x+1<=info.x2&&info.y1<=coord.y+1&&coord.y+1<=info.y2) {
            action_off.accept(null, coord);
            return;
          }
        } else if (cmd instanceof OffCommand) {
          LightCommand info=(LightCommand)cmd;
          if (info.x1<=coord.x+1&&coord.x+1<=info.x2&&info.y1<=coord.y+1&&coord.y+1<=info.y2) {
            break;
          }
        }
      }
      action_on.accept(null, coord);
    }
  };
  ((PadButton)KyUI.get("led_pad")).buttonListener=new PadButton.ButtonListener() {
    public void accept(IntVector2 click, IntVector2 coord, int action) {//only sends in-range events.
      boolean edited=false;
      if (InputMode==AUTOINPUT) {
        if (action==PadButton.RELEASE_L) {
          edited=true;
          for (int b=min(coord.y, click.y); b<=max(coord.y, click.y); b++) {
            for (int a=min(coord.x, click.x); a<=max(coord.x, click.x); a++) {
              autoInput.accept(new IntVector2(a, b));
            }
          }
        }
      } else if (InputMode==RIGHTOFFMODE) {
        if (action==PadButton.RELEASE_L) {
          edited=true;
          if (click.equals(coord)) {
            action_on.accept(null, coord);
          } else {
            action_on.accept(click, coord);
          }
        } else if (action==PadButton.RELEASE_R) {
          edited=true;
          if (click.equals(coord)) {
            action_off.accept(null, coord);
          } else {
            action_off.accept(click, coord);
          }
        }
      }
      if (edited) {
        currentLedEditor.editor.updateSlider(); 
        currentLedEditor.editor.invalidate();
      }
    }
  };
  VelocityType=((VelocityButton)KyUI.get("led_lp"));
  VelocityType.colorSelectListener=new EventListener() {
    public void onEvent(Element e) {
      ColorMode=VEL;
      ((ColorPickerFull)KyUI.get("led_cp")).setSelectable(false);
      ((VelocityButton)e).selectionVisible=true;
      SelectedColor=((VelocityButton)e).selectedVelocity;
      VelocityType=(VelocityButton)e;
    }
  };
  ((VelocityButton)KyUI.get("led_mf")).colorSelectListener=VelocityType.colorSelectListener;
  ((ColorPickerFull)KyUI.get("led_cp")).colorSelectListener=new EventListener() {
    public void onEvent(Element e) {
      ColorMode=HTML;
      ((ColorPickerFull)KyUI.get("led_cp")).setSelectable(true);
      ((VelocityButton)KyUI.get("led_lp")).selectionVisible=false;
      SelectedColor=((ColorButton)e).c;
    }
  };
  fs=((FrameSlider)KyUI.get("led_frameslider"));
  fsTime=((Button)KyUI.get("led_time"));
  fs.setAdjustListener(new EventListener() {
    public void onEvent(Element e) {
      synchronized(currentLedEditor) {
        currentLedEditor.displayTime=fs.valueI;
        fsTime.text=currentLedEditor.displayTime+"/"+fs.maxI;
        currentLedEditor.setFrameByTime();
        fs.set(currentLedEditor.getTimeByFrame(currentLedEditor.displayFrame));
        currentLedEditor.FrameSliderBackup=currentLedEditor.displayTime;//user input
        currentLedEditor.displayPad.displayControl(currentLedEditor.LED.get(currentLedEditor.displayFrame));
        midiControl(currentLedEditor.velLED.get(currentLedEditor.displayFrame));
      }
      currentLedEditor.displayPad.invalidate();
      fsTime.invalidate();
    }
  }
  );
  fs.loopAdjustListener=new EventListener() {
    public void onEvent(Element e) {
      //synchronized(currentLedEditor) {
      if (fs.valueS<fs.valueE) {
        currentLed.led.loopStart=fs.valueS;
        currentLed.led.loopEnd=fs.valueE;
      }
      //}
    }
  };
  fs.frameMarker=new ExtendedRenderer() {
    public void render(PGraphics g) {
      int sum=0;
      float size=(fs.pos.right-fs.pos.left-2*fs.padding);
      for (int a=1; a < currentLedEditor.DelayPoint.size(); a++) {
        sum=sum + currentLedEditor.getDelayValue(currentLedEditor.DelayPoint.get(a));
        g.line(fs.pos.left + fs.padding+size * sum / (fs.maxI - fs.minI), fs.pos.top+fs.padding+2, fs.pos.left +  fs.padding+size * sum / (fs.maxI - fs.minI), fs.pos.bottom-fs.padding-2);
      }
      g.strokeWeight(2);
      g.stroke(0, 255, 0);
      if (StartFromCursor) {
        g.line(fs.pos.left + fs.padding+size * currentLedEditor.FrameSliderBackup / (fs.maxI - fs.minI), fs.pos.top+fs.padding+2, fs.pos.left +  fs.padding+size * currentLedEditor.FrameSliderBackup / (fs.maxI - fs.minI), (fs.pos.top+fs.pos.bottom)/2);
      }
      if (AutoStop) {
        g.line(fs.pos.left + fs.padding+size* currentLedEditor.FrameSliderBackup / (fs.maxI - fs.minI), (fs.pos.top+fs.pos.bottom)/2, fs.pos.left + fs.padding+size * currentLedEditor.FrameSliderBackup / (fs.maxI - fs.minI), fs.pos.bottom-fs.padding-2);
      }
    }
  };
  fs.unholdListener=new EventListener() {
    public void onEvent(Element e) {
      ledTabs.get(0).light.unhold();
    }
  };
}