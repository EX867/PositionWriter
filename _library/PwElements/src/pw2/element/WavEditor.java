package pw2.element;
import beads.AudioContext;
import beads.Sample;
import beads.SamplePlayer;
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
import pw2.beads.KnobAutomation;
public class WavEditor extends Element {
  public Sample sample;
  public SamplePlayer player;
  double scale=1;
  float offsetX=0;
  RangeSlider slider;//add it manually...
  int fgColor;
  double length;
  public boolean autoscroll=false;
  public boolean snap=false;
  public boolean automationMode=false;
  public double snapInterval=2000;//milliseconds
  public double snapOffset=0;//milliseconds, mod snapInterval
  public KnobAutomation automation;
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
  boolean doubleClickReady=false;
  long lastClicked=0;
  PGraphics waveformG;
  boolean waveformInvalidated=true;
  public WavEditor(String s) {
    super(s);
    bgColor=0xFF323232;
    fgColor=0xFF7F7F7F;
    slider=new RangeSlider(getName() + ":slider");
    slider.direction=Attributes.Direction.HORIZONTAL;
    slider.setAdjustListener((Element e) -> {
      waveformInvalidated=true;
      offsetX=slider.getOffset((float)((pos.right - pos.left) * scale));
      invalidate();
    });
  }
  @Override
  public void setPosition(Rect rect) {
    super.setPosition(rect);
    waveformG=KyUI.Ref.createGraphics((int)(pos.right - pos.left), (int)(pos.bottom - pos.top));
    waveformInvalidated=true;
    setSlider();
  }
  public void initPlayer(AudioContext ac) {
    player=new SamplePlayer(ac, 2);
    player.setKillOnEnd(false);
    if (sample != null) {
      player.setSample(sample);
    }
  }
  public void setSample(Sample sample_) {
    sample=sample_;
    length=sample.getLength();
    if (player != null) {
      player.setSample(sample);
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
        if (waveformInvalidated) {
          waveformG.beginDraw();
          waveformG.clear();
          float interval=(pos.bottom - pos.top) / sample.getNumChannels();
          for (int a=0; a < sample.getNumChannels(); a++) {
            cacheRect.set(pos.left, pos.top + a * interval + 1, pos.right, pos.top + (a + 1) * interval - 1);
            waveformDraw.render(waveformG, player.getContext(), cacheRect, sample, fgColor, offsetX, scale, a);
          }
          waveformG.endDraw();
          waveformInvalidated=false;
        }
      }
      g.imageMode(PApplet.CORNER);
      g.image(waveformG, pos.left, pos.top);
      float loopHead=(pos.bottom - pos.top) / 12;//8
      //draw vertical grids(snap)
      //draw loop mark - sampleplayer's loop (complete)
      if (player.getLoopType() == SamplePlayer.LoopType.LOOP_FORWARDS) {
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
      //draw cursor (complete)
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
  public void setReverse(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      return false;
    });
  }
  public void setSnapGridPlus(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      return false;
    });
  }
  public void setSnapGridMinus(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      return false;
    });
  }
  public void setToggleSnap(ToggleButton button) {
    button.setPressListener((MouseEvent e, int index) -> {
      snap=button.value;
      return false;
    });
  }
  public void setToggleAutomationMode(ToggleButton button) {
    button.setPressListener((MouseEvent e, int index) -> {
      automationMode=button.value;
      return false;
    });
  }
  @Override
  public boolean mouseEvent(MouseEvent e, int index) {
    if (e.getAction() == MouseEvent.PRESS || e.getAction() == MouseEvent.DRAG) {
      float loopHead=(pos.bottom - pos.top) / 12;//8
      float y=KyUI.mouseClick.getLast().y;
      float x=KyUI.mouseGlobal.getLast().x;
      if (pressedL) {
        //snap x
      }
      if (pressedL || pressedR) {
        if (player.getLoopType() == SamplePlayer.LoopType.LOOP_FORWARDS && isInRange(y, pos.top, pos.top + loopHead)) {
          player.setLoopStart(new beads.Static(player.getContext(), Math.min(player.getLoopEndUGen().getValue(), (float)posToTime(x - pos.left))));
        } else if (player.getLoopType() == SamplePlayer.LoopType.LOOP_FORWARDS && isInRange(y, pos.bottom - loopHead, pos.bottom)) {
          player.setLoopEnd(new beads.Static(player.getContext(), Math.max(player.getLoopStartUGen().getValue(), (float)posToTime(x - pos.left))));
        } else {
          player.setPosition((float)posToTime(x - pos.left));
        }
      }
      if (e.getAction() == MouseEvent.PRESS) {
        long time=System.currentTimeMillis();
        if (e.getButton() == PApplet.LEFT && doubleClickReady && time - lastClicked < KyUI.DOUBLE_CLICK_INTERVAL) {
          //set loop range to automation interval
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
        waveformInvalidated=true;
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
          waveformInvalidated=true;
          invalidate();
        } else if (e.getKeyCode() == PApplet.RIGHT) {
          offsetX+=8;
          if (offsetX > (pos.right - pos.left) * (scale - 1)) {
            offsetX=(float)((pos.right - pos.left) * (scale - 1));
          }
          setSlider();
          slider.invalidate();
          waveformInvalidated=true;
          invalidate();
        }
      }
    }
  }
}
