package pw2.element;
import beads.AudioContext;
import beads.Sample;
import beads.SamplePlayer;
import beads.Static;
import com.karnos.commandscript.Difference;
import com.karnos.commandscript.EditRecorder;
import kyui.core.Attributes;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.element.Button;
import kyui.element.RangeSlider;
import kyui.element.ToggleButton;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import pw2.beads.AutoControlSamplePlayer;
import pw2.beads.KnobAutomation;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
public class WavEditor extends Element {
  public Sample sample;
  public AutoControlSamplePlayer player;
  double scale=1;
  float offsetX=0;
  RangeSlider slider;//add it manually...
  public int fgColor;
  public int highlightColor;
  public int snapGridColor;
  double length;
  public boolean autoscroll=false;
  public boolean snap=true;
  protected boolean automationMode=false;
  public boolean selectionMode=false;//in selectionMode, all of editing is disabled, /click=start select/drag=edit select/
  public static float minGridSize=10;
  public static double[] Beat=new double[]{1.0, (double)1 / 2, (double)1 / 3, (double)1 / 4, (double)1 / 6, (double)1 / 8, (double)1 / 12, (double)1 / 16, (double)1 / 24, (double)1 / 32, (double)1 / 48, (double)1 / 64};
  public float snapBpm=120;
  public double snapInterval=Beat[7];
  public double snapOffset=0;//milliseconds, mod snapInterval
  //
  public KnobAutomation automation;
  public LinkedList<KnobAutomation.Point> selectedPoints=new LinkedList<>();
  public LinkedList<KnobAutomation.Point> copyPoints=new LinkedList<>();
  KnobAutomation.Point clickPoint;
  public Runnable onAutomationChanged=() -> {
  };
  double clickTime=0;
  double clickValue=0;
  EditRecorder recorder=new EditRecorder();
  public class ChangeData {//represents automation add/move/delete and reverse action
    double position;
    double value;
    public ChangeData(KnobAutomation.Point point) {
      position=point.position;
      value=point.value;
    }
  }
  public class Change extends Difference<ChangeData> {
    public Change(ChangeData before_, ChangeData after_) {
      super(before_, after_);
    }
    @Override
    public void undo() {
      if (before == null) {//add action
        //System.out.println("undo add action "+after.c);
        automation.removePoint(after.position, after.value);
      } else if (after == null) {//remove action
        //System.out.println("undo remove action "+before.c);
        selectedPoints.add(automation.addPoint(before.position, before.value));
      } else {
        //System.out.println("undo change action "+before.c+" to "+after.c);
        selectedPoints.add(automation.changePoint(automation.indexOf(after.position, after.value), before.position, before.value));
      }
      automationInvalid=true;
    }
    @Override
    public void redo() {
      if (before == null) {//add action
        //System.out.println("redo add action "+after.c);
        selectedPoints.add(automation.addPoint(after.position, after.value));
      } else if (after == null) {//remove action
        //System.out.println("redo remove action "+before.c);
        automation.removePoint(before.position, before.value);
      } else {
        //System.out.println("redo change action "+before.c+" to "+after.c);
        selectedPoints.add(automation.changePoint(automation.indexOf(before.position, before.value), after.position, after.value));
      }
      automationInvalid=true;
    }
  }
  //
  WaveformDraw waveformDraw=new WaveformDraw();
  Rect cacheRect=new Rect();
  KnobAutomation.Point cachePoint=new KnobAutomation.Point(0, 0);
  boolean doubleClickReady=false;
  long lastClicked=0;
  PGraphics waveformG;
  PGraphics automationG;
  public boolean waveformInvalid=true;
  public boolean automationInvalid=true;
  public WavEditor(String s) {
    super(s);
    bgColor=0xFF323232;
    fgColor=0x9F7F7F7F;
    highlightColor=KyUI.Ref.color(50, 50, 200);
    snapGridColor=KyUI.Ref.color(0, 0, 0, 50);
    slider=new RangeSlider(getName() + ":slider");
    slider.direction=Attributes.Direction.HORIZONTAL;
    slider.setAdjustListener((Element e) -> {
      waveformInvalid=true;
      automationInvalid=true;
      offsetX=slider.getOffset((float)((pos.right - pos.left) * scale));
      invalidate();
    });
    setSlider();
  }
  public void setAutomationMode(boolean v) {
    automationInvalid=true;
    clickPoint=null;
    automationMode=v;
    invalidate();
  }
  public boolean getAutomationMode() {
    return automationMode;
  }
  public KnobAutomation.Point addPoint(double pos, double value) {
    if (automation != null) {
      KnobAutomation.Point p=automation.addPoint(pos, value);
      recorder.add(new Change(null, new ChangeData(p)));
      recorder.recordLog();
      onAutomationChanged.run();
      return p;
    }
    return null;
  }
  public void undo() {
    selectedPoints.clear();
    recorder.undo();
    onAutomationChanged.run();
    invalidate();
  }
  public void redo() {
    selectedPoints.clear();
    recorder.redo();
    onAutomationChanged.run();
    invalidate();
  }
  @Override
  public void setPosition(Rect rect) {
    super.setPosition(rect);
    waveformG=KyUI.Ref.createGraphics((int)(pos.right - pos.left), (int)(pos.bottom - pos.top));
    automationG=KyUI.Ref.createGraphics((int)(pos.right - pos.left), (int)(pos.bottom - pos.top));
    waveformInvalid=true;
    automationInvalid=true;
    setSlider();
  }
  public void initPlayer(AudioContext ac) {
    player=new AutoControlSamplePlayer(ac, 2);
    player.setKillOnEnd(false);
    if (sample != null) {
      player.setSample(sample);
      player.setLoopStart(new Static(player.getContext(), 0));
      player.setLoopEnd(new Static(player.getContext(), (float)sample.getLength()));
    }
  }
  public void setSample(Sample sample_) {
    sample=sample_;
    length=sample.getLength();
    if (player != null) {
      player.setSample(sample);
      player.setLoopStart(new Static(player.getContext(), 0));
      player.setLoopEnd(new Static(player.getContext(), (float)sample.getLength()));
    }
    setSlider();
  }
  public RangeSlider getSlider() {
    return slider;
  }
  void setSlider() {//when move slider
    slider.setLength((float)((pos.right - pos.left) * scale), pos.right - pos.left);
    slider.setOffset((float)((pos.right - pos.left) * scale), offsetX);
  }
  @Override
  public void render(PGraphics g) {
    //draw background
    super.render(g);
    if (autoscroll && sample != null && !slider.isPressedL() && !player.isPaused()) {
      //update offset
      offsetX=offsetX + (float)timeToPos(player.getPosition()) - (pos.right - pos.left) / 2;
      if (offsetX > (pos.right - pos.left) * (scale - 1)) {
        offsetX=(float)((pos.right - pos.left) * (scale - 1));
      }
      if (offsetX < 0) {
        offsetX=0;
      }
      setSlider();
      waveformInvalid=true;
      automationInvalid=true;
    }
    if (player != null) {
      //draw vertical grids(snap)
      float firstPoint=(float)timeToPos(snapOffset);
      float posInterval=(pos.right - pos.left) * (float)((snapInterval * 240000 / Math.max(1, snapBpm)/*duration*/) * scale / length);
      if (posInterval != 0) {
        while (posInterval < minGridSize) {
          posInterval*=2;
        }
        if (firstPoint < pos.left) {
          firstPoint=pos.left - (pos.left - firstPoint) % posInterval;
        }
        g.strokeWeight(1);
        g.stroke(snapGridColor);
        for (float p=firstPoint; p < pos.right; p+=posInterval) {
          g.line(p, pos.top + 2, p, pos.bottom - 2);
        }
      }
      //draw bars
      firstPoint=(float)timeToPos(snapOffset);
      posInterval=(pos.right - pos.left) * (float)((240000 / Math.max(1, snapBpm)/*duration*/) * scale / length);
      if (posInterval != 0) {
        while (posInterval < minGridSize) {
          posInterval*=2;
        }
        if (firstPoint < pos.left) {
          firstPoint=pos.left - (pos.left - firstPoint) % posInterval;
        }
        g.strokeWeight(2);
        g.stroke(snapGridColor);
        for (float p=firstPoint; p < pos.right; p+=posInterval) {
          g.line(p, pos.top + 2, p, pos.bottom - 2);
        }
      }
      //draw waveform (complete)
      if (sample != null) {
        if (waveformInvalid) {
          waveformG.beginDraw();
          waveformG.clear();
          float interval=(pos.bottom - pos.top) / sample.getNumChannels();
          for (int a=0; a < sample.getNumChannels(); a++) {
            cacheRect.set(pos.left, pos.top + a * interval + 1, pos.right, pos.top + (a + 1) * interval - 1);
            waveformDraw.render(waveformG, player.getContext(), cacheRect, sample, fgColor, offsetX, scale, a);
          }
          waveformG.endDraw();
          waveformInvalid=false;
        }
      }
      g.imageMode(PApplet.CORNER);
      g.image(waveformG, pos.left, pos.top);
      //draw horizontal grid
      if (automation != null) {
        firstPoint=pos.top + (pos.bottom - pos.top) * automation.map(automation.gridOffset);
        if (automation.gridInterval != 0) {
          posInterval=(float)((pos.bottom - pos.top) * (1 - automation.map(automation.gridInterval)));
          while (posInterval < minGridSize) {
            posInterval*=2;
          }
          g.strokeWeight(1);
          g.stroke(snapGridColor);
          for (float p=firstPoint; p >= pos.top; p-=posInterval) {
            g.line(pos.left + 2, p, pos.right - 2, p);
          }
        }
      }
      //draw loop mark - sampleplayer's loop
      float loopHead=(pos.bottom - pos.top) / 12;//8
      if (true) {//player.getLoopType() == SamplePlayer.LoopType.LOOP_FORWARDS
        g.strokeWeight(4);
        g.stroke(255, 0, 0, 150);
        g.fill(g.strokeColor);
        float startPos=(float)timeToPos(player.getLoopStartUGen().getValue());
        if (isInRange(startPos + loopHead, pos.left, pos.right) || isInRange(startPos, pos.left, pos.right)) {
          if (isInRange(startPos, pos.left, pos.right)) {
            g.line(startPos, pos.top + 2, startPos, pos.bottom - 2);
          }
          g.rect(Math.max(pos.left, startPos), pos.top + 2, Math.min(pos.right, startPos + loopHead), pos.top + loopHead);
        }
        g.stroke(0, 0, 255, 150);
        g.fill(g.strokeColor);
        float endPos=(float)timeToPos(player.getLoopEndUGen().getValue());
        if (isInRange(endPos - loopHead, pos.left, pos.right) || isInRange(endPos, pos.left, pos.right)) {
          if (isInRange(endPos, pos.left, pos.right)) {
            g.line(endPos, pos.top + 2, endPos, pos.bottom - 2);
          }
          g.rect(Math.min(pos.right, endPos), pos.bottom - 2, Math.max(pos.left, endPos - loopHead), pos.bottom - loopHead);
        }
      }
      //draw automations
      if (automation != null && !automation.points.isEmpty()) {
        if (automationInvalid) {
          automationG.beginDraw();
          automationG.clear();
          automationG.translate(-pos.left, -pos.top);
          automationG.strokeWeight(1);
          automationG.fill(255, automationMode ? 200 : 50);
          automationG.rectMode(PApplet.RADIUS);
          cachePoint.position=posToTime(-10);
          int start=automation.points.getBeforeIndex(cachePoint);
          cachePoint.position=posToTime(pos.right - pos.left + 10);
          int end=automation.points.getBeforeIndex(cachePoint);
          float beforeValue=0;
          double beforePos=0;
          if (start > 0) {
            beforeValue=(pos.bottom - pos.top) * automation.map(automation.points.get(start - 1).value);
            beforePos=automation.points.get(start - 1).position;
          } else {
            beforeValue=(pos.bottom - pos.top) * automation.map(automation.points.get(0).value);
            beforePos=0;
          }
          for (int a=start; a < end; a++) {
            KnobAutomation.Point p=automation.points.get(a);
            automationG.stroke(255, 100);
            automationG.line((float)timeToPos(p.position), pos.top + 2, (float)timeToPos(p.position), pos.bottom - 2);
            automationG.stroke(255);
            automationG.line((float)timeToPos(p.position), (pos.bottom - pos.top) * automation.map(p.value), (float)timeToPos(beforePos), beforeValue);
            automationG.rect((float)timeToPos(p.position), (pos.bottom - pos.top) * automation.map(p.value), 10, 10);
            beforePos=p.position;
            beforeValue=(pos.bottom - pos.top) * automation.map(p.value);
          }
          automationG.stroke(255);
          if (end >= automation.points.size()) {//draw until end
            automationG.line(pos.right, beforeValue, (float)timeToPos(beforePos), beforeValue);
          } else {
            automationG.line((float)timeToPos(automation.points.get(end).position), (pos.bottom - pos.top) * automation.map(automation.points.get(end).value), (float)timeToPos(beforePos), beforeValue);
          }
          automationInvalid=false;
          //
          automationG.strokeWeight(3);
          automationG.noFill();
          automationG.stroke(highlightColor);
          for (KnobAutomation.Point p : selectedPoints) {
            if (p != null) {
              automationG.rect((float)timeToPos(p.position), (pos.bottom - pos.top) * automation.map(p.value), 10, 10);
            }
          }
          automationG.endDraw();
          //
        }
        g.image(automationG, pos.left, pos.top);
      }
      //draw cursor
      g.strokeWeight(2);
      g.stroke(0, 0, 0, 200);
      float point=(float)timeToPos(player.getPosition());
      if (isInRange(point, pos.left, pos.right)) {
        g.line(point, pos.top + 2, point, pos.bottom - 2);
      }
      //draw snap cursor
      if (snap) {
        g.stroke(20, 20, 20);
        point=(float)snap(KyUI.mouseGlobal.getLast().x);
        if (isInRange(point, pos.left, pos.right)) {
          g.line(point, pos.top + 2, point, pos.bottom - 2);
        }
      }
      //draw selection area
      if (selectionMode && automation != null && KyUI.Ref.mousePressed) {
        g.stroke(highlightColor);
        g.fill(highlightColor, 50);
        g.rect(KyUI.mouseClick.getLast().x, KyUI.mouseClick.getLast().y, KyUI.mouseGlobal.getLast().x, KyUI.mouseGlobal.getLast().y);
      }
    }
    g.noStroke();
  }
  public double timeToPos(double time) {
    return ((pos.right - pos.left) * (time / length) * scale - offsetX);
  }
  public double posToTime(double point) {//pos is relative.
    return length * (point + offsetX) / (scale * (pos.right - pos.left));
  }
  public boolean isInRange(float v, float min, float max) {
    return v >= min && v <= max;
  }
  @Override
  public void update() {
    if (player != null && !player.isPaused()) {// autoscroll
      invalidate();
      if (autoscroll) {
        slider.invalidate();
      }
    }
  }
  private void cutSelection(Button button) {//no add
    button.setPressListener((MouseEvent e, int index) -> {
      player.pause(true);
      Sample cutSample=new Sample(1);//selection length
      //copy sample
      //implement
      setSample(cutSample);
      player.pause(false);
      invalidate();
      return false;
    });
  }
  public Button setSnapGridPlus(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      for (int a=0; a < Beat.length; a++) {
        if (snapInterval == Beat[a]) {
          snapInterval=Beat[Math.min(Beat.length - 1, a + 1)];
          //System.out.println(snapInterval);
          invalidate();
          return false;
        }
      }
      return false;
    });
    return button;
  }//no undo
  public Button setSnapGridMinus(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      for (int a=0; a < Beat.length; a++) {
        if (snapInterval == Beat[a]) {
          snapInterval=Beat[Math.max(0, a - 1)];
          //System.out.println(snapInterval);
          invalidate();
          return false;
        }
      }
      return false;
    });
    return button;
  }//no undo
  public Button setToggleSnap(ToggleButton button) {
    button.setPressListener((MouseEvent e, int index) -> {
      snap=button.value;
      return false;
    });
    return button;
  }//no undo
  public Button setToggleAutomationMode(ToggleButton button) {
    button.setPressListener((MouseEvent e, int index) -> {
      setAutomationMode(button.value);
      return false;
    });
    return button;
  }//no undo
  public Button setToggleAutoscroll(ToggleButton button) {
    button.setPressListener((MouseEvent e, int index) -> {
      autoscroll=button.value;
      return false;
    });
    return button;
  }//no undo
  public Button setToggleLoop(ToggleButton button) {
    button.setPressListener((MouseEvent e, int index) -> {
      if (button.value) {
        player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
      } else {
        player.setLoopType(SamplePlayer.LoopType.NO_LOOP_FORWARDS);
      }
      return false;
    });
    return button;
  }//no undo
  public Button setDeletePoint(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      if (selectedPoints.isEmpty()) return false;
      for (KnobAutomation.Point p : selectedPoints) {
        ChangeData before=new ChangeData(p);
        automation.removePoint(p);
        recorder.add(new Change(before, null));
      }
      recorder.recordLog();
      onAutomationChanged.run();
      selectedPoints.clear();
      automationInvalid=true;
      invalidate();
      return false;
    });
    return button;
  }
  public Button setUndo(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      undo();
      return false;
    });
    return button;
  }
  public Button setRedo(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      redo();
      return false;
    });
    return button;
  }
  public Button setCopy(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      copy();
      return false;
    });
    return button;
  }
  public Button setPaste(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      paste();
      return false;
    });
    return button;
  }
  public Button setZoomIn(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      double pscale=scale;
      scale=scale * 2;
      //float time=(pos.left + pos.right) / 2;
      float time=KyUI.mouseGlobal.getLast().x;//warning. not including transform
      offsetX=(float)((offsetX + (time - pos.left)) * scale / pscale) - (time - pos.left);
      if (offsetX > (pos.right - pos.left) * (scale - 1)) {
        offsetX=(float)((pos.right - pos.left) * (scale - 1));
      }
      if (offsetX < 0) {
        offsetX=0;
      }
      waveformInvalid=true;
      automationInvalid=true;
      invalidate();
      setSlider();
      slider.invalidate();
      return false;
    });
    return button;
  }
  public Button setZoomOut(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      double pscale=scale;
      scale=scale / 2;
      if (scale < 1) {
        scale=1;
      }
      //float time=(pos.left + pos.right) / 2;
      float time=KyUI.mouseGlobal.getLast().x;//warning. not including transform
      offsetX=(float)((offsetX + (time - pos.left)) * scale / pscale) - (time - pos.left);
      if (offsetX > (pos.right - pos.left) * (scale - 1)) {
        offsetX=(float)((pos.right - pos.left) * (scale - 1));
      }
      if (offsetX < 0) {
        offsetX=0;
      }
      waveformInvalid=true;
      automationInvalid=true;
      invalidate();
      setSlider();
      slider.invalidate();
      return false;
    });
    return button;
  }
  public double snap(double in) {
    if (!snap) return in;
    float posInterval=(pos.right - pos.left) * (float)((snapInterval * 240000 / Math.max(1, snapBpm)/*duration*/) * scale / length);
    if (posInterval != 0) {
      while (posInterval < minGridSize) {
        posInterval*=2;
      }
      float posLeft=(float)timeToPos(snapOffset);
      return posLeft + posInterval * Math.round((in - posLeft) / posInterval);
    }
    return in;
  }
  public double snapTime(double in) {//time
    return posToTime((float)snap(timeToPos(in)));
  }
  public double snapAutomationGrid(double in) {
    if (automation == null || !snap || automation.gridInterval == 0) return in;
    float firstPoint=pos.top + (pos.bottom - pos.top) * automation.map(automation.gridOffset);
    float posInterval=(float)((pos.bottom - pos.top) * (1 - automation.map(automation.gridInterval)));
    while (posInterval < minGridSize) {
      posInterval*=2;
    }
    return firstPoint - posInterval * Math.round((firstPoint - in) / posInterval);
  }
  @Override
  public boolean mouseEvent(MouseEvent e, int index) {
    if (selectionMode) {
      if (e.getAction() == MouseEvent.DRAG) {
        if (automation != null) {
          double size=(pos.bottom - pos.top);
          float minx=Math.min(KyUI.mouseClick.getLast().x, KyUI.mouseGlobal.getLast().x);
          float maxx=Math.max(KyUI.mouseClick.getLast().x, KyUI.mouseGlobal.getLast().x);
          float miny=(float)automation.unmap((Math.max(KyUI.mouseClick.getLast().y, KyUI.mouseGlobal.getLast().y) - pos.top) / size);
          float maxy=(float)automation.unmap((Math.min(KyUI.mouseClick.getLast().y, KyUI.mouseGlobal.getLast().y) - pos.top) / size);
          cachePoint.position=posToTime(minx - pos.left);
          int start=automation.points.getBeforeIndex(cachePoint);
          cachePoint.position=posToTime(maxx - pos.left);
          int end=automation.points.getBeforeIndex(cachePoint);
          selectedPoints.clear();
          for (int a=start; a < end && a < automation.points.size(); a++) {
            double v=automation.points.get(a).value;
            if (miny <= v && v <= maxy) {
              selectedPoints.addLast(automation.points.get(a));
            }
          }
        }
        automationInvalid=true;
        invalidate();
      }
    } else {
      if (e.getAction() == MouseEvent.RELEASE) {
        clickPoint=null;
      }
      if (e.getAction() == MouseEvent.PRESS || e.getAction() == MouseEvent.DRAG) {
        float loopHead=(pos.bottom - pos.top) / 12;//8
        float cy=KyUI.mouseClick.getLast().y;
        float y=KyUI.mouseGlobal.getLast().y;
        float cx=KyUI.mouseClick.getLast().x;
        float x=KyUI.mouseGlobal.getLast().x;
        boolean selected=false;
        if (pressedL) {
          //snap x
          x=(float)snap(x);
          //snap y
          y=(float)snapAutomationGrid(y);
          //if (automationMode) {
          if (e.getAction() == MouseEvent.PRESS) {
            if (automation != null) {
              cachePoint.position=posToTime(-10);
              int start=automation.points.getBeforeIndex(cachePoint);
              cachePoint.position=posToTime(pos.right - pos.left + 10);
              int end=automation.points.getBeforeIndex(cachePoint);
              int a=start;
              for (; a < end; a++) {//search if overlay
                KnobAutomation.Point p=automation.points.get(a);
                if (Math.abs(timeToPos(p.position) - KyUI.mouseGlobal.getLast().x) < 10 && Math.abs((pos.bottom - pos.top) * automation.map(p.value) - y) < 10) {
                  selected=true;
                  break;
                }
              }
              if (!selected || !selectedPoints.contains(automation.points.get(a))) {
                selectedPoints.clear();
              }
              if (selected) {
                clickPoint=automation.points.get(a);
                if (!selectedPoints.contains(automation.points.get(a))) {
                  selectedPoints.add(clickPoint);
                }
                clickValue=clickPoint.value;
                clickTime=clickPoint.position;
                if (snap) {
                  clickTime=posToTime((float)snap(timeToPos(clickTime)));
                  double size=(pos.bottom - pos.top);
                  clickValue=automation.unmap(1 - snapAutomationGrid(size * (1 - automation.map(clickValue))) / size);
                }
              } else if (automationMode) {
                selectedPoints.add(clickPoint=automation.addPoint(posToTime(x), automation.unmap((y - pos.top) / (pos.bottom - pos.top))));
                clickValue=clickPoint.value;
                clickTime=clickPoint.position;
                recorder.add(new Change(null, new ChangeData(clickPoint)));
                recorder.recordLog();
                onAutomationChanged.run();
              }
            }
            automationInvalid=true;
          } else if (e.getAction() == MouseEvent.DRAG) {//FIX to more cleaner method
            if (clickPoint != null) {
              selected=true;
              double apos=clickTime + posToTime(x - cx - offsetX);
              double avalue=clickValue - automation.unmap(1 - (y - cy) / (pos.bottom - pos.top));
              //
              ChangeData before=new ChangeData(clickPoint);
              double origialPos=clickPoint.position;
              double origialValue=clickPoint.value;
              if (snap) {
                apos=posToTime((float)snap(timeToPos(apos)));
                avalue=automation.unmap(1 - snapAutomationGrid((pos.bottom - pos.top) * (1 - automation.map(avalue))) / (pos.bottom - pos.top));
              }
              if (apos < 0) {
                clickPoint=automation.changePoint(clickPoint, 0, avalue);
              } else if (apos > length) {
                clickPoint=automation.changePoint(clickPoint, length, avalue);
              } else {
                clickPoint=automation.changePoint(clickPoint, apos, avalue);
              }
              if (clickPoint != null) {
                recorder.add(new Change(before, new ChangeData(clickPoint)));
                for (KnobAutomation.Point p : selectedPoints) {
                  if (p != clickPoint) {
                    before=new ChangeData(p);
                    double apos2=p.position + apos - origialPos;
                    if (apos2 < 0) {
                      p=automation.changePoint(p, 0, p.value + avalue - origialValue);
                    } else if (apos2 > length) {
                      p=automation.changePoint(p, length, p.value + avalue - origialValue);
                    } else {
                      p=automation.changePoint(p, apos2, p.value + avalue - origialValue);
                    }
                    recorder.add(new Change(before, new ChangeData(p)));
                  }
                }
              }
              onAutomationChanged.run();
              automationInvalid=true;
            }
          }
          //}
          if (!automationMode && !selected) {
            //player.getLoopType() == SamplePlayer.LoopType.LOOP_FORWARDS
            if (isInRange(cy, pos.top, pos.top + loopHead)) {
              player.setLoopStart(new Static(player.getContext(), Math.min(player.getLoopEndUGen().getValue(), Math.max(0, (float)Math.min(length, posToTime(x - pos.left))))));
            } else if (isInRange(cy, pos.bottom - loopHead, pos.bottom)) {
              player.setLoopEnd(new Static(player.getContext(), Math.max(player.getLoopStartUGen().getValue(), Math.max(0, (float)Math.min(length, posToTime(x - pos.left))))));
            } else {
              player.setPosition((float)posToTime(x - pos.left));
            }
          }
        }
        if (e.getAction() == MouseEvent.PRESS) {
          //long time=System.currentTimeMillis();
          //if (doubleClickReady && time - lastClicked < KyUI.DOUBLE_CLICK_INTERVAL) {//e.getButton() == PApplet.LEFT
          if ((/*!automationMode || automationMode &&*/ e.getButton() == PApplet.RIGHT) && !selected) {
            AudioContext ac=player.getContext();
            if (automation.points.isEmpty()) {
              player.setLoopStart(new Static(ac, 0));
              player.setLoopEnd(new Static(ac, (float)length));
            } else {
              cachePoint.position=posToTime(KyUI.mouseGlobal.getLast().x);
              int i=automation.points.getBeforeIndex(cachePoint);
              if (i <= 0) {
                player.setLoopStart(new Static(ac, 0));
                player.setLoopEnd(new Static(ac, Math.max(0, (float)Math.min(length, automation.points.get(0).position))));
              } else if (i >= automation.points.size()) {
                player.setLoopStart(new Static(ac, Math.max(0, (float)Math.min(length, automation.points.get(automation.points.size() - 1).position))));
                player.setLoopEnd(new Static(ac, (float)length));
              } else {
                player.setLoopStart(new Static(ac, Math.max(0, (float)Math.min(length, automation.points.get(i - 1).position))));
                player.setLoopEnd(new Static(ac, Math.max(0, (float)Math.min(length, automation.points.get(i).position))));
              }
              player.setPosition(player.getLoopStartUGen().getValue());
              player.pause(false);
            }
          }
          //  doubleClickReady=false;
          //} else {
          //  doubleClickReady=true;
          //}
          //lastClicked=time;
          invalidate();
          return false;
        }
        if (pressedL || pressedR) {
          invalidate();
          return false;
        }
      }
    }
    if (e.getAction() == MouseEvent.RELEASE) {
      recorder.recordLog();
    }
    if (e.getAction() == MouseEvent.WHEEL) {
      if (pos.contains(KyUI.mouseGlobal.getLast().x, KyUI.mouseGlobal.getLast().y)) {
        double pscale=scale;
        if (e.getCount() > 0) {
          for (int a=0; a < e.getCount(); a++) {
            scale=scale * 0.97F;
          }
          if (scale < 1) {
            scale=1;
          }
        } else {
          for (int a=0; a < -e.getCount(); a++) {
            scale=scale * 1.03F;
          }
        }
        offsetX=(float)((offsetX + (KyUI.mouseGlobal.getLast().x - pos.left)) * scale / pscale) - (KyUI.mouseGlobal.getLast().x - pos.left);
        if (offsetX > (pos.right - pos.left) * (scale - 1)) {
          offsetX=(float)((pos.right - pos.left) * (scale - 1));
        }
        if (offsetX < 0) {
          offsetX=0;
        }
        setSlider();
        slider.invalidate();
        waveformInvalid=true;
        automationInvalid=true;
        invalidate();
        return false;
      }
    } else if (e.getAction() == MouseEvent.MOVE) {
      if (snap && pos.contains(KyUI.mouseGlobal.getLast().x, KyUI.mouseGlobal.getLast().y)) {
        invalidate();
      }
    }
    return true;
  }
  public void left(int mul) {
    offsetX-=(pos.right+pos.left)*mul/12;
    if (offsetX < 0) {
      offsetX=0;
    }
    setSlider();
    slider.invalidate();
    waveformInvalid=true;
    automationInvalid=true;
    invalidate();
  }
  public void right(int mul) {
    offsetX+=(pos.right+pos.left)*mul/12;
    if (offsetX > (pos.right - pos.left) * (scale - 1)) {
      offsetX=(float)((pos.right - pos.left) * (scale - 1));
    }
    setSlider();
    slider.invalidate();
    waveformInvalid=true;
    automationInvalid=true;
    invalidate();
  }
  @Override
  public void keyEvent(KeyEvent e) {
    if (e.getAction() == KeyEvent.PRESS) {
      if (e.getKey() == PApplet.CODED) {
        if (e.getKeyCode() == PApplet.LEFT) {
          left(1);
        } else if (e.getKeyCode() == PApplet.RIGHT) {
          right(1);
        }
      }
    }
  }
  void copy() {
    if (automation == null || selectedPoints.isEmpty()) return;
    copyPoints.clear();
    double startTime=Double.MAX_VALUE;
    double endTime=0;
    for (KnobAutomation.Point p : selectedPoints) {
      if (p.position < startTime) {
        startTime=p.position;
      }
      if (p.position > endTime) {
        endTime=p.position;
      }
    }
    if (snap) {
      startTime=posToTime(snap(timeToPos(startTime)));
      endTime=posToTime(snap(timeToPos(endTime)));
    }
    for (KnobAutomation.Point p : selectedPoints) {
      copyPoints.add(new KnobAutomation.Point(p.position - startTime, p.value));
    }
    player.setPosition(endTime);
    invalidate();
  }
  void paste() {
    if (automation == null || copyPoints.isEmpty()) return;
    recorder.recordLog();
    double startTime=player.getPosition();
    selectedPoints.clear();
    double endTime=0;
    if (snap) {
      startTime=posToTime(snap(timeToPos(startTime)));
    }
    for (KnobAutomation.Point p : copyPoints) {
      KnobAutomation.Point point=automation.addPoint(p.position + startTime, p.value);
      recorder.add(new Change(null, new ChangeData(point)));
      selectedPoints.add(point);
    }
    for (KnobAutomation.Point p : selectedPoints) {
      if (p.position > endTime) {
        endTime=p.position;
      }
    }
    if (snap) {
      endTime=posToTime(snap(timeToPos(endTime)));
    }
    recorder.recordLog();
    automationInvalid=true;
    player.setPosition(endTime);
    invalidate();
  }
}
