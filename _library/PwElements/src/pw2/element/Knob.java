package pw2.element;
import beads.AudioContext;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.event.EventListener;
import kyui.util.ColorExt;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.event.MouseEvent;
import beads.UGenW;

import java.text.DecimalFormat;
import java.util.function.Function;
public class Knob extends Element {
  public int strokeWeight=6;
  public int indicatorWidth=12;
  final float minAngle=PApplet.TWO_PI / 3;
  final float totalAngle=PApplet.TWO_PI * 5 / 6;
  public double min=0;
  public double max=1;
  public double center=0;
  public double initialValue=0;
  public double value=0.0F;
  public int fgColor;//knob color
  public int highlightColor;
  public float sensitivity=1;
  public String label="";
  //
  static DecimalFormat cut2=new DecimalFormat("0.00");
  double clickValue=0;
  long lastClicked=0;
  boolean doubleClickReady=false;
  public boolean selected=false;
  public Function<Double, Double> get;
  public Function<Double, Double> getInv;
  public Runnable doubleClickListener;
  public EventListener adjustListener;
  public EventListener selectListener;
  boolean logScale=false;
  boolean adjusted;
  public Knob(String s) {
    super(s);
    init();
  }
  public Knob(String s, String label_) {
    super(s);
    label=label_;
    init();
  }
  private void init() {
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
    initialValue=value;
    return this;
  }
  public Knob attach(AudioContext ac, UGenW ugen, UGenW.Parameter param, Function<Double, Double> get_, Function<Double, Double> getInv_, double min_, double max_, double center_, double value_) {
    get=get_;
    getInv=getInv_;
    set(min_, max_, center_, value_);
    param.attacher.accept(this);
    adjustListener=(e) -> {
      ugen.changeParameter(param, get.apply(value).doubleValue());
    };
    return this;
  }
  public Knob attach(AudioContext ac, UGenW ugen, UGenW.Parameter param, double min_, double max_, double center_, double value_, boolean logScale_) {
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
      return attach(ac, ugen, param, (Double in) -> {
        return Math.pow(10, in);
      }, (Double in) -> {
        return Math.log10(in);
      }, min_, max_, center_, value_);
    } else {
      return attach(ac, ugen, param, (Double in) -> {
        return in;
      }, (Double in) -> {
        return in;
      }, min_, max_, center_, value_);
    }
  }
  @Override
  public void render(PGraphics g) {
    g.fill(bgColor);
    pos.render(g);
    indicatorWidth=12;
    strokeWeight=6;
    float radius;
    float offsetX=pos.left + padding;
    float offsetY=pos.top + padding;
    if (pos.right - pos.left > pos.bottom - pos.top) {//width is longer than height
      radius=(pos.bottom - pos.top) / 2 - padding;
      offsetX=(pos.left + pos.right - pos.bottom + pos.top) / 2 + padding;
    } else {
      radius=(pos.right - pos.left) / 2 - padding;
      offsetY=(pos.top + pos.bottom - pos.right + pos.left) / 2 + padding;
    }
    if (radius < 120) {
      indicatorWidth=Math.max(1, (int)(radius / 10));
      strokeWeight=Math.max(1, (int)(radius / 20));
    }
    float innerRadius=radius * 2 / 3;
    float pointRadius=radius / 6;
    float paddingAngle=indicatorWidth / (radius + strokeWeight + indicatorWidth / 2);
    int color=fgColor;
    if (pressedL || pressedR) {
      color=ColorExt.brighter(color, 20);
    } else if (entered) {
      color=ColorExt.brighter(color, 10);
    }
    g.ellipseMode(PApplet.RADIUS);
    g.fill(color);
    g.stroke(color);
    g.strokeWeight(strokeWeight);
    arc(g, offsetX + radius, offsetY + radius, radius, radius, minAngle - paddingAngle, minAngle + totalAngle + paddingAngle, PApplet.PIE);
    g.noStroke();
    g.fill(highlightColor);
    arc(g, offsetX + radius, offsetY + radius, radius - strokeWeight + 3, radius - strokeWeight + 3, minAngle + totalAngle * (center - min) / (max - min), minAngle + totalAngle * (value - min) / (max - min), PApplet.PIE);
    g.strokeWeight(strokeWeight);
    g.stroke(color);
    g.fill(color);
    arc(g, offsetX + radius, offsetY + radius, innerRadius + strokeWeight, innerRadius + strokeWeight, minAngle + totalAngle * (center - min) / (max - min), minAngle + totalAngle * (value - min) / (max - min), PApplet.PIE);
    g.noStroke();
    g.fill(bgColor);
    g.ellipse(offsetX + radius, offsetY + radius, innerRadius, innerRadius);
    //draw indicator and text
    g.pushMatrix();
    g.translate(offsetX + radius, offsetY + radius);
    g.fill(color);
    g.stroke(strokeWeight);
    g.rotate((float)(minAngle + totalAngle * (value - min) / (max - min)));
    g.stroke(bgColor);
    g.rect(-indicatorWidth, indicatorWidth, radius + strokeWeight, -indicatorWidth);
    g.popMatrix();
    g.textSize(Math.max(1, Math.abs(pointRadius * 4 / 3)));
    g.noStroke();
    g.text(label, offsetX + radius, offsetY + radius - pointRadius * 2 - 2);
    g.text(cut2.format(get.apply(value)), offsetX + radius, offsetY + radius + pointRadius * 2 - 2);
    g.ellipse(offsetX + radius, offsetY + radius, pointRadius, pointRadius);
  }
  @Override
  public boolean mouseEvent(MouseEvent e, int index) {
    if (e.getAction() == MouseEvent.PRESS) {
      clickValue=value;
      if (selectListener != null) {
        selectListener.onEvent(this);
      }
      long time=System.currentTimeMillis();
      if (e.getButton() == PApplet.LEFT && doubleClickReady && time - lastClicked < KyUI.DOUBLE_CLICK_INTERVAL) {
        adjust(initialValue);
        doubleClickReady=false;
      } else {
        doubleClickReady=true;
      }
      lastClicked=time;
      return false;
    } else if (e.getAction() == MouseEvent.DRAG) {
      float centerX=(pos.left + pos.right) / 2;
      if (pressedL || pressedR) {
        value=clickValue;
      }
      if (pressedL) {
        value=value + (max - min) * (KyUI.mouseGlobal.getLast().x - KyUI.mouseClick.getLast().x - KyUI.mouseGlobal.getLast().y + KyUI.mouseClick.getLast().y) * sensitivity / 2 / (pos.right - pos.left);
      }
      if (pressedR) {
        value=value + (max - min) * (KyUI.mouseGlobal.getLast().x - KyUI.mouseClick.getLast().x - KyUI.mouseGlobal.getLast().y + KyUI.mouseClick.getLast().y) * sensitivity / 20 / (pos.bottom - pos.top);
      }
      if (pressedL || pressedR) {
        adjust(value);
        return false;
      }
    }
    return true;
  }
  public void arc(PGraphics g, float x, float y, float rx, float ry, double s, double e, int mode) {
    g.arc(x, y, rx, ry, (float)Math.min(s, e), (float)Math.max(s, e), mode);
  }
  public void adjust(double value_) {
    value=Math.min(max, Math.max(min, value_));
    adjusted=true;
    if (adjustListener != null) {
      adjustListener.onEvent(this);
    }
  }
  public boolean hold() {
    return (pressedL || pressedR) && KyUI.Ref.mousePressed;
  }
  @Override
  public void update() {
    //adjust(PApplet.sin((float)(System.currentTimeMillis() % 100000) / 300));
    if (adjusted) {
      adjusted=false;
      invalidate();
    }
  }
}
