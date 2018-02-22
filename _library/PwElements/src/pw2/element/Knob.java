package pw2.element;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.event.EventListener;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.event.MouseEvent;
public class Knob extends Element {
  public int strokeWeight=12;
  final float minAngle=PApplet.TWO_PI / 3;
  final float totalAngle=PApplet.TWO_PI * 5 / 6;
  public float min=0;
  public float max=1;
  public float center=0;
  public float value=0.0F;
  public int fgColor;//knob color
  public int highlightColor;
  public float sensitivity=1;
  //
  float clickValue=0;
  public boolean selected=false;
  public EventListener adjustListener;
  public EventListener selectListener;
  //boolean logScale=false;
  public Knob(String s) {
    super(s);
    bgColor=KyUI.Ref.color(127);
    fgColor=KyUI.Ref.color(50);
    highlightColor=KyUI.Ref.color(0, 0, 255);
    padding=12;
  }
  public Knob set(float min_, float max_, float center_, float value_) {
    min=min_;
    max=max_;
    center=center_;
    value=value_;
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
    float paddingAngle=strokeWeight / (radius + strokeWeight + strokeWeight / 2);
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
    g.rotate(minAngle + totalAngle * (value - min) / (max - min));
    g.stroke(bgColor);
    g.rect(-strokeWeight, strokeWeight, radius + strokeWeight, -strokeWeight);
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
    } else if (e.getAction() == MouseEvent.DRAG && pressedL) {
      float centerX=(pos.left + pos.right) / 2;
      value=clickValue + (max - min) * (KyUI.mouseGlobal.getLast().x - KyUI.mouseClick.getLast().x) * sensitivity / (pos.right - pos.left);
      value=Math.min(max, Math.max(min, value));
      if (adjustListener != null) {
        adjustListener.onEvent(this);
      }
      invalidate();
      return false;
    }
    return true;
  }
  public void arc(PGraphics g, float x, float y, float rx, float ry, float s, float e, int mode) {
    g.arc(x, y, rx, ry, Math.min(s, e), Math.max(s, e), mode);
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
