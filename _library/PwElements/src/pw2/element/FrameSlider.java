package pw2.element;
import kyui.element.IntSlider;
import kyui.core.KyUI;
import kyui.util.ColorExt;
import kyui.event.EventListener;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.event.MouseEvent;
import pw2.event.ExtendedRenderer;

import java.util.ArrayList;
public class FrameSlider extends IntSlider {//direction is always horizontal.
  float loopDir=0;//loop area
  public int valueS=0;
  public int valueE=0;
  public ExtendedRenderer frameMarker;
  public EventListener unholdListener;
  public EventListener loopAdjustListener;
  public FrameSlider(String s) {
    super(s);
  }
  public int getValueByMouse(float mouse) {
    return (int)((minI + (maxI - minI) * (mouse - pos.left - padding) / (pos.right - pos.left - 2 * padding)));
  }
  @Override
  public boolean mouseEvent(MouseEvent e, int index) {
    if (e.getButton() == PApplet.RIGHT && (e.getAction() == MouseEvent.PRESS || (pressedR && e.getAction() == MouseEvent.DRAG))) {
      if (e.getAction() == MouseEvent.PRESS) {
        valueS=getValueByMouse(KyUI.mouseGlobal.getLast().x);
        valueE=valueS;
        loopDir=0;
      }
      if (loopDir == 0) {
        float mouse=getValueByMouse(KyUI.mouseGlobal.getLast().x);
        loopDir=mouse - valueS;
        if (Math.abs(KyUI.mouseGlobal.getLast().x - KyUI.mouseClick.getLast().x) < 10) loopDir=0;
      } else if (loopDir > 0) {
        valueE=getValueByMouse(KyUI.mouseGlobal.getLast().x);
      } else if (loopDir < 0) {
        valueS=getValueByMouse(KyUI.mouseGlobal.getLast().x);
      }
      valueE=Math.max(minI, Math.min(maxI, valueE));
      valueS=Math.max(minI, Math.min(maxI, valueS));
//      if (valueS >= valueE && loopDir != 0) {
      //        valueS=minI;
      //        valueE=minI;
      //      }
      if (loopAdjustListener != null) {
        loopAdjustListener.onEvent(this);
      }
      invalidate();
      return false;
    } else if (e.getAction() == MouseEvent.RELEASE) {
      if (pressedR) {
        invalidate();
      }
    }
    boolean ret=super.mouseEvent(e, index);
    if (e.getAction() == MouseEvent.RELEASE && e.getButton() == PApplet.LEFT) {
      if (unholdListener != null) {
        unholdListener.onEvent(this);
      }
    }
    return ret;
  }
  @Override
  public void render(PGraphics g) {
    super.render(g);
    g.stroke(ColorExt.brighter(fgColor, -10));
    g.strokeWeight(1);
    if (frameMarker != null) {
      frameMarker.render(g);
    }
    if (valueS < valueE) {
      g.strokeWeight(2);
      g.stroke(255, 0, 0);
      g.line(pos.left + padding + (pos.right - pos.left - 2 * padding) * valueS / (maxI - minI), pos.top + padding + 2, pos.left + padding + (pos.right - pos.left - 2 * padding) * valueS / (maxI - minI), pos.bottom - padding - 2);
      g.stroke(0, 0, 255);
      g.line(pos.left + padding + (pos.right - pos.left - 2 * padding) * valueE / (maxI - minI), pos.top + padding + 2, pos.left + padding + (pos.right - pos.left - 2 * padding) * valueE / (maxI - minI), pos.bottom - padding - 2);
    }
    g.noStroke();
  }
  public boolean hold() {
    return KyUI.Ref.mousePressed && pressedL;
  }
}
