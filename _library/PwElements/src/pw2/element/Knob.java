package pw2.element;
import beads.AudioContext;
import beads.Glide;
import beads.UGen;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.event.EventListener;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.event.MouseEvent;

import java.util.function.Consumer;
import java.util.function.Function;
public class Knob extends Element {
  public int strokeWeight=6;
  public int indicatorWidth=12;
  final float minAngle=PApplet.TWO_PI / 3;
  final float totalAngle=PApplet.TWO_PI * 5 / 6;
  public double min=0;
  public double max=1;
  public double center=0;
  public double value=0.0F;
  public int fgColor;//knob color
  public int highlightColor;
  public float sensitivity=1;
  //
  double clickValue=0;
  public boolean selected=false;
  public EventListener adjustListener;
  public EventListener selectListener;
  public Glide glide;//change this to envelope plus glide control custom ugen!
  boolean logScale=false;
  public Knob(String s) {
    super(s);
    bgColor=KyUI.Ref.color(127);
    fgColor=KyUI.Ref.color(50);
    highlightColor=KyUI.Ref.color(0, 0, 255);
    padding=12;
  }
  public Knob set(double min_, double max_, double center_, double value_) {
    if (logScale) {
      min=Math.log10(min_);
      max=Math.log10(max_);
      center=Math.log10(Math.min(max_, Math.max(min_, center_)));
      value=Math.log10(Math.min(max_, Math.max(min_, value_)));
    } else {
      min=min_;
      max=max_;
      center=Math.min(max, Math.max(min, center_));
      value=Math.min(max, Math.max(min, value_));
    }
    return this;
  }
  public Knob attach(AudioContext ac, Consumer<UGen> set, Function<Double, Double> get, double min_, double max_, double center_, double value_) {
    set(min_, max_, center_, value_);
    glide=new Glide(ac, get.apply(value).floatValue(), 30);
    set.accept(glide);
    adjustListener=(e) -> {
      glide.setValue(get.apply(value).floatValue());
    };
    return this;
  }
  public Knob attach(AudioContext ac, Consumer<UGen> set, double min_, double max_, double center_, double value_, boolean logScale_) {
    logScale=logScale_;
    if (logScale) {
      if (min_ <= 0) {
        min_=PApplet.EPSILON;
      }
      if (max_ <= 0) {
        max_=PApplet.EPSILON;
      }
      if (center_ <= 0) {
        center_=PApplet.EPSILON;
      }
      if (value_ <= 0) {
        value_=PApplet.EPSILON;
      }
      return attach(ac, set, (Double in) -> {
        return Math.pow(10, in);
      }, min_, max_, center_, value_);
    } else {
      return attach(ac, set, (Double in) -> {
        return in;
      }, min_, max_, center_, value_);
    }
  }
  public Knob attach(Consumer<Double> set, double min_, double max_, double center_, double value_) {
    set(min_, max_, center_, value_);
    adjustListener=(e) -> {
      set.accept(value);
    };
    return this;
  }
  @Override
  public void render(PGraphics g) {
    g.fill(bgColor);
    pos.render(g);
    float radius;
    float offsetX=pos.left + padding;
    float offsetY=pos.top + padding;
    if (pos.right - pos.left > pos.bottom - pos.top) {//width is longer than height
      radius=(pos.bottom - pos.top - padding * 2) / 2;
      offsetX=(pos.left + pos.right - pos.bottom + pos.top + padding * 2) / 2 + padding;
    } else {
      radius=(pos.right - pos.left - padding * 2) / 2;
      offsetY=(pos.top + pos.bottom - pos.right + pos.left + padding * 2) / 2 + padding;
    }
    float innerRadius=radius * 2 / 3;
    float pointRadius=radius / 6;
    float paddingAngle=indicatorWidth / (radius + indicatorWidth + indicatorWidth / 2);
    g.ellipseMode(PApplet.RADIUS);
    g.fill(fgColor);
    g.stroke(fgColor);
    g.strokeWeight(strokeWeight);
    arc(g, offsetX + radius, offsetY + radius, radius, radius, minAngle - paddingAngle, minAngle + totalAngle + paddingAngle, PApplet.PIE);
    g.noStroke();
    g.fill(highlightColor);
    arc(g, offsetX + radius, offsetY + radius, radius - strokeWeight + 3, radius - strokeWeight + 3, minAngle + totalAngle * (center - min) / (max - min), minAngle + totalAngle * (value - min) / (max - min), PApplet.PIE);
    g.strokeWeight(strokeWeight);
    g.stroke(fgColor);
    g.fill(fgColor);
    arc(g, offsetX + radius, offsetY + radius, innerRadius + strokeWeight, innerRadius + strokeWeight, minAngle + totalAngle * (center - min) / (max - min), minAngle + totalAngle * (value - min) / (max - min), PApplet.PIE);
    g.noStroke();
    g.fill(bgColor);
    g.ellipse(offsetX + radius, offsetY + radius, innerRadius, innerRadius);
    g.fill(fgColor);
    g.stroke(strokeWeight);
    g.pushMatrix();
    g.translate(offsetX + radius, offsetY + radius);
    g.rotate((float)(minAngle + totalAngle * (value - min) / (max - min)));
    g.stroke(bgColor);
    g.rect(-indicatorWidth, indicatorWidth, radius + indicatorWidth, -indicatorWidth);
    g.popMatrix();
    g.noStroke();
    g.ellipse(offsetX + radius, offsetY + radius, pointRadius, pointRadius);
  }
  @Override
  public boolean mouseEvent(MouseEvent e, int index) {
    if (e.getAction() == MouseEvent.PRESS) {
      clickValue=value;
      if (selectListener != null) {
        selectListener.onEvent(this);
      }
    } else if (e.getAction() == MouseEvent.DRAG) {
      float centerX=(pos.left + pos.right) / 2;
      if (pressedL) {
        value=clickValue + (max - min) * (KyUI.mouseGlobal.getLast().x - KyUI.mouseClick.getLast().x - KyUI.mouseGlobal.getLast().y + KyUI.mouseClick.getLast().y) * sensitivity / 2 / (pos.right - pos.left);
      }
      if (pressedR) {
        value=clickValue + (max - min) * (KyUI.mouseGlobal.getLast().x - KyUI.mouseClick.getLast().x - KyUI.mouseGlobal.getLast().y + KyUI.mouseClick.getLast().y) * sensitivity / 20 / (pos.bottom - pos.top);
      }
      if (pressedL || pressedR) {
        value=Math.min(max, Math.max(min, value));
        if (adjustListener != null) {
          adjustListener.onEvent(this);
        }
        invalidate();
        return false;
      }
    }
    return true;
  }
  public void arc(PGraphics g, float x, float y, float rx, float ry, double s, double e, int mode) {
    g.arc(x, y, rx, ry, (float)Math.min(s, e), (float)Math.max(s, e), mode);
  }
  public void adjust(float value_) {
    value=Math.min(max, Math.max(min, value_));
    if (adjustListener != null) {
      adjustListener.onEvent(this);
    }
  }
  //  @Override
  //  public void update() {
  //    adjust(PApplet.sin((float)(System.currentTimeMillis() % 100000) / 300));
  //    invalidate();
  //  }
}
