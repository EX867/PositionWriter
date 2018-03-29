package pw2.element;
import beads.AudioContext;
import beads.Sample;
import beads.Static;
import com.karnos.commandscript.Difference;
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
  LinkedList<KnobAutomation.Point> selectedPoints=new LinkedList<>();
  KnobAutomation.Point clickPoint;
  double clickTime=0;
  double clickValue=0;
  public class ChangeData {//represents automation add/move/delete and reverse action
  }
  public class Change extends Difference<ChangeData> {
    public Change(ChangeData before_, ChangeData after_) {
      super(before_, after_);
    }
    @Override
    public void undo() {
    }
    @Override
    public void redo() {
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
  }
  public void setAutomationMode(boolean v) {
    automationInvalid=true;
    clickPoint=null;
    automationMode=v;
  }
  public boolean getAutomationMode() {
    return automationMode;
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
    if (autoscroll && !slider.isPressedL() && !player.isPaused()) {
      //update offset
      offsetX=offsetX + timeToPos(player.getPosition()) - (pos.right - pos.left) / 2;
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
      float firstPoint=timeToPos(snapOffset);
      float posInterval=(pos.right - pos.left) * (float)((snapInterval * 240000 / snapBpm/*duration*/) * scale / length);
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
      firstPoint=timeToPos(snapOffset);
      posInterval=(pos.right - pos.left) * (float)((240000 / snapBpm/*duration*/) * scale / length);
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
        float startPos=timeToPos(player.getLoopStartUGen().getValue());
        if (isInRange(startPos + loopHead, pos.left, pos.right) || isInRange(startPos, pos.left, pos.right)) {
          if (isInRange(startPos, pos.left, pos.right)) {
            g.line(startPos, pos.top + 2, startPos, pos.bottom - 2);
          }
          g.rect(Math.max(pos.left, startPos), pos.top + 2, Math.min(pos.right, startPos + loopHead), pos.top + loopHead);
        }
        g.stroke(0, 0, 255, 150);
        g.fill(g.strokeColor);
        float endPos=timeToPos(player.getLoopEndUGen().getValue());
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
            automationG.line(timeToPos(p.position), pos.top + 2, timeToPos(p.position), pos.bottom - 2);
            automationG.stroke(255);
            automationG.line(timeToPos(p.position), (pos.bottom - pos.top) * automation.map(p.value), timeToPos(beforePos), beforeValue);
            automationG.rect(timeToPos(p.position), (pos.bottom - pos.top) * automation.map(p.value), 10, 10);
            beforePos=p.position;
            beforeValue=(pos.bottom - pos.top) * automation.map(p.value);
          }
          automationG.stroke(255);
          if (end >= automation.points.size()) {//draw until end
            automationG.line(pos.right, beforeValue, timeToPos(beforePos), beforeValue);
          } else {
            automationG.line(timeToPos(automation.points.get(end).position), (pos.bottom - pos.top) * automation.map(automation.points.get(end).value), timeToPos(beforePos), beforeValue);
          }
          automationInvalid=false;
          //
          automationG.strokeWeight(3);
          automationG.noFill();
          automationG.stroke(highlightColor);
          for (KnobAutomation.Point p : selectedPoints) {
            automationG.rect(timeToPos(p.position), (pos.bottom - pos.top) * automation.map(p.value), 10, 10);
          }
          automationG.endDraw();
          //
        }
        g.image(automationG, pos.left, pos.top);
      }
      //draw cursor
      g.strokeWeight(2);
      g.stroke(0, 0, 0, 200);
      float point=timeToPos(player.getPosition());
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
  public float timeToPos(double time) {
    return (float)((pos.right - pos.left) * (time / length) * scale - offsetX);
  }
  public double posToTime(float point) {//pos is relative.
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
  public void cutSelection(Button button) {
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
  public Button setReverse(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      return false;
    });
    return button;
  }
  public Button setSnapGridPlus(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      for (int a=0; a < Beat.length; a++) {
        if (snapInterval == Beat[a]) {
          snapInterval=Math.min(Beat.length - 1, a + 1);
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
          snapInterval=Math.max(0, a - 1);
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
  public Button setDeletePoint(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      if (selectedPoints.isEmpty()) return false;
      for (KnobAutomation.Point p : selectedPoints) {
        //ADD memento
        automation.removePoint(p);
      }
      selectedPoints.clear();
      automationInvalid=true;
      return false;
    });
    return button;
  }
  public double snap(double in) {
    if (!snap) return in;
    float posInterval=(pos.right - pos.left) * (float)((snapInterval * 240000 / snapBpm/*duration*/) * scale / length);
    if (posInterval != 0) {
      while (posInterval < minGridSize) {
        posInterval*=2;
      }
      float posLeft=timeToPos(snapOffset);
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
          synchronized (automation.points) {
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
              synchronized (automation.points) {
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
                if (!selected) {
                  selectedPoints.clear();
                }
                if (selected) {
                  selectedPoints.add(clickPoint=automation.points.get(a));
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
                  //ADD memento
                }
              }
            }
            automationInvalid=true;
          } else {//FIX to more cleaner method
            if (clickPoint != null) {
              selected=true;
              double apos=clickTime + posToTime(x - cx - offsetX);
              double avalue=clickValue - automation.unmap(1 - (y - cy) / (pos.bottom - pos.top));
              //
              double origialPos=clickPoint.position;
              double origialValue=clickPoint.value;
              if (snap) {
                apos=posToTime((float)snap(timeToPos(apos)));
                avalue=automation.unmap(1 - snapAutomationGrid((pos.bottom - pos.top) * (1 - automation.map(avalue))) / (pos.bottom - pos.top));
              }
              if (apos < 0) {
                automation.changePoint(clickPoint, 0, avalue);
              } else if (apos > length) {
                automation.changePoint(clickPoint, length, avalue);
              } else {
                automation.changePoint(clickPoint, apos, avalue);
              }
              for (KnobAutomation.Point p : selectedPoints) {
                if (p != clickPoint) {
                  double apos2=p.position + apos - origialPos;
                  if (apos2 < 0) {
                    automation.changePoint(p, 0, p.value + avalue - origialValue);
                  } else if (apos2 > length) {
                    automation.changePoint(p, length, p.value + avalue - origialValue);
                  } else {
                    automation.changePoint(p, apos2, p.value + avalue - origialValue);
                  }
                }
              }
              //ADD memento
            }
            automationInvalid=true;
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
          long time=System.currentTimeMillis();
          if (doubleClickReady && time - lastClicked < KyUI.DOUBLE_CLICK_INTERVAL) {//e.getButton() == PApplet.LEFT
            if ((!automationMode || automationMode && e.getButton() == PApplet.RIGHT) && !selected) {
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
            doubleClickReady=false;
          } else {
            doubleClickReady=true;
          }
          lastClicked=time;
          invalidate();
          return false;
        }
        if (pressedL || pressedR) {
          invalidate();
          return false;
        }
      }
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
  @Override
  public void keyEvent(KeyEvent e) {
    if (e.getAction() == KeyEvent.PRESS) {
      if (e.getKey() == PApplet.CODED) {
        if (e.getKeyCode() == PApplet.LEFT) {
          offsetX-=8;
          if (offsetX < 0) {
            offsetX=0;
          }
          setSlider();
          slider.invalidate();
          waveformInvalid=true;
          automationInvalid=true;
          invalidate();
        } else if (e.getKeyCode() == PApplet.RIGHT) {
          offsetX+=8;
          if (offsetX > (pos.right - pos.left) * (scale - 1)) {
            offsetX=(float)((pos.right - pos.left) * (scale - 1));
          }
          setSlider();
          slider.invalidate();
          waveformInvalid=true;
          automationInvalid=true;
          invalidate();
        }
      }
    }
  }
}
