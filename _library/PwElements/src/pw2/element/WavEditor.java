package pw2.element;
import beads.AudioContext;
import beads.Sample;
import beads.SamplePlayer;
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
  double length;
  public boolean autoscroll=false;
  public boolean snap=false;
  protected boolean automationMode=false;
  public double snapInterval=2000;//milliseconds
  public double snapOffset=0;//milliseconds, mod snapInterval
  public KnobAutomation automation;
  ArrayList<KnobAutomation.Point> selectedPoints=new ArrayList<>();
  KnobAutomation.Point clickPoint;
  double clickPos=0;
  double clickValue=0;
  public class ChangeData {
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
    fgColor=0xFF7F7F7F;
    highlightColor=KyUI.Ref.color(0, 0, 255);
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
    if (autoscroll) {
      //update offsetX
    }
    //draw waveform (complete)
    if (player != null) {
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
      float loopHead=(pos.bottom - pos.top) / 12;//8
      //draw vertical grids(snap)
      //draw loop mark - sampleplayer's loop
      if (true) {//player.getLoopType() == SamplePlayer.LoopType.LOOP_FORWARDS
        g.strokeWeight(2);
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
          cachePoint.position=posToTime(0);
          int start=automation.points.getBeforeIndex(cachePoint);
          cachePoint.position=posToTime(pos.right - pos.left);
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
          if (end >= automation.points.size()) {//draw until end
            automationG.line(pos.right, beforeValue, timeToPos(beforePos), beforeValue);
          } else {
            automationG.line(timeToPos(automation.points.get(end).position), (pos.bottom - pos.top) * automation.map(automation.points.get(end).value), timeToPos(beforePos), beforeValue);
          }
          automationG.endDraw();
          automationInvalid=false;
        }
        g.image(automationG, pos.left, pos.top);
        g.strokeWeight(3);
        g.noFill();
        g.rectMode(PApplet.RADIUS);
        g.stroke(highlightColor);
        for (KnobAutomation.Point p : selectedPoints) {
          g.rect(timeToPos(p.position), (pos.bottom - pos.top) * automation.map(p.value), 10, 10);
        }
        g.rectMode(PApplet.CORNERS);
      }
      //draw cursor
      g.strokeWeight(2);
      g.stroke(0, 0, 0, 200);
      float point=timeToPos(player.getPosition());
      if (isInRange(point, pos.left, pos.right)) {
        g.line(point, pos.top + 2, point, pos.bottom - 2);
      }
    }
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
      return false;
    });
    return button;
  }
  public Button setSnapGridMinus(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      return false;
    });
    return button;
  }
  public Button setToggleSnap(ToggleButton button) {
    button.setPressListener((MouseEvent e, int index) -> {
      snap=button.value;
      return false;
    });
    return button;
  }
  public Button setToggleAutomationMode(ToggleButton button) {
    button.setPressListener((MouseEvent e, int index) -> {
      automationMode=button.value;
      return false;
    });
    return button;
  }
  public Button setDeletePoint(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      for (KnobAutomation.Point p : selectedPoints) {
        automation.removePoint(p);
      }
      selectedPoints.clear();
      automationInvalid=true;
      return false;
    });
    return button;
  }
  @Override
  public boolean mouseEvent(MouseEvent e, int index) {
    if (e.getAction() == MouseEvent.RELEASE) {
      clickPoint=null;
    }
    if (e.getAction() == MouseEvent.PRESS || e.getAction() == MouseEvent.DRAG) {
      float loopHead=(pos.bottom - pos.top) / 12;//8
      float cy=KyUI.mouseClick.getLast().y;
      float y=KyUI.mouseGlobal.getLast().y;
      float cx=KyUI.mouseClick.getLast().x;
      float x=KyUI.mouseGlobal.getLast().x;
      if (pressedL) {
        //snap x
        if(snap){

        }
        if (automationMode) {
          if (e.getAction() == MouseEvent.PRESS) {
            cachePoint.position=posToTime(0);
            int start=automation.points.getBeforeIndex(cachePoint);
            cachePoint.position=posToTime(pos.right - pos.left);
            int end=automation.points.getBeforeIndex(cachePoint);
            boolean selected=false;
            int a=start;
            for (; a < end; a++) {//search if overlay
              KnobAutomation.Point p=automation.points.get(a);
              if (Math.abs(timeToPos(p.position) - x) < 10 && Math.abs((pos.bottom - pos.top) * automation.map(p.value) - y) < 10) {
                selected=true;
                break;
              }
            }
            selectedPoints.clear();
            KnobAutomation.Point p;
            if (selected) {
              selectedPoints.add(p=automation.points.get(a));
              clickPoint=p;
              clickValue=p.value;
              clickPos=p.position;
            } else {
              selectedPoints.add(p=automation.addPoint(posToTime(x), automation.unmap((y - pos.top) / (pos.bottom - pos.top))));
              clickPoint=p;
              clickValue=p.value;
              clickPos=p.position;
            }
            automationInvalid=true;
          } else {//FIX to more cleaner method
            if (clickPoint != null) {
              double offsetPos=posToTime(x - cx - offsetX);
              double offsetV=-automation.unmap(1 - (KyUI.mouseGlobal.getLast().y - cy) / (pos.bottom - pos.top));
              automation.changePoint(clickPoint, clickPos + offsetPos, clickValue + offsetV);
              for (KnobAutomation.Point p : selectedPoints) {
                if (p != clickPoint) {
                  automation.changePoint(p, p.position + clickPos + offsetPos - clickPoint.position, p.value + clickValue + offsetV - clickPoint.value);
                }
              }
            }
            automationInvalid=true;
          }
        } else {
          clickPoint=null;
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
          AudioContext ac=player.getContext();
          if (automation.points.isEmpty()) {
            player.setLoopStart(new Static(ac, 0));
            player.setLoopEnd(new Static(ac, (float)length));
          } else {
            cachePoint.position=posToTime(x);
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
    } else if (e.getAction() == MouseEvent.WHEEL) {
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
