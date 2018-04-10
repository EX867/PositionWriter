package pw2.element;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PImage;
import pw2.beads.TDComp;
import pw2.beads.TDCompW;
public class TDCompWave extends Element {
  int strokeWeight=4;
  TDComp attachedUGen;
  int fgColor;
  //temp
  PGraphics wave=null;
  @Override
  public void setPosition(Rect rect) {
    if (attachedUGen != null) {
      attachedUGen.canDraw=false;//sync error warning
      synchronized (attachedUGen) {
        PGraphics waveOld=wave;
        wave=KyUI.Ref.createGraphics(Math.max(1, (int)(rect.right - rect.left)), Math.max(1, (int)(rect.bottom - rect.top)));
        attachedUGen.wave=wave;
      }
      attachedUGen.canDraw=true;
    }
    super.setPosition(rect);
  }
  public TDCompWave attach(TDComp ugen) {
    attachedUGen=ugen;
    setPosition(pos);
    return this;
  }
  public TDCompWave attach(TDCompW ugen) {
    attachedUGen=ugen.ugen;
    setPosition(pos);
    return this;
  }
  public void deattach() {
    attachedUGen=null;
  }
  public TDCompWave(String s) {
    super(s);
    bgColor=KyUI.Ref.color(127);
    fgColor=KyUI.Ref.color(50);
  }
  @Override
  public void render(PGraphics g) {
    if (attachedUGen == null) {//no!!
      return;
    }
    if (wave == null) {
      return;
    }
    g.fill(bgColor);
    pos.render(g, -strokeWeight / 2);
    g.imageMode(PApplet.CORNER);
    //System.out.println("c");
    if (attachedUGen.canDraw) {
      attachedUGen.canDraw=false;
      g.image(wave, pos.left, pos.top);
      attachedUGen.canDraw=true;
    }
    //System.out.println("d");
    g.strokeWeight(strokeWeight);
    g.noFill();
    g.stroke(fgColor);
    pos.render(g, -strokeWeight / 2);
    g.noStroke();
  }
  @Override
  public void update() {
    if (attachedUGen != null && !attachedUGen.isPaused() && attachedUGen.getContext().isRunning()) {
      invalidate();
    }
  }
}
