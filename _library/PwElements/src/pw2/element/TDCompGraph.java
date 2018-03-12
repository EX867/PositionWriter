package pw2.element;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.core.PGraphics;
import pw2.beads.TDComp;
import pw2.beads.TDCompW;
public class TDCompGraph extends Element {
  int strokeWeight=4;
  TDComp attachedUGen;
  int fgColor;
  //temp
  PGraphics graph=null;
  @Override
  public void setPosition(Rect rect) {
    if (attachedUGen != null) {
      attachedUGen.canDraw=false;//sync error warning
      int size=Math.max(1, (int)Math.min(rect.right - rect.left, rect.bottom - rect.top));
      graph=KyUI.Ref.createGraphics(size, size);
      attachedUGen.graph=graph;
      attachedUGen.canDraw=true;
    }
    super.setPosition(rect);
  }
  public TDCompGraph attach(TDComp ugen) {
    attachedUGen=ugen;
    setPosition(pos);
    return this;
  }
  public TDCompGraph attach(TDCompW ugen) {
    attachedUGen=ugen.ugen;
    setPosition(pos);
    return this;
  }
  public void deattach() {
    attachedUGen=null;
  }
  public TDCompGraph(String s) {
    super(s);
    bgColor=KyUI.Ref.color(127);
    fgColor=KyUI.Ref.color(50);
  }
  @Override
  public void render(PGraphics g) {
    if (attachedUGen == null) {//no!!
      return;
    }
    if (graph == null) {
      return;
    }
    g.fill(bgColor);
    pos.render(g, -strokeWeight / 2);
    g.imageMode(PApplet.CORNER);
    //System.out.println("a");
    if (attachedUGen.canDraw) {
      attachedUGen.canDraw=false;
      g.image(graph, pos.left, pos.top);
      attachedUGen.canDraw=true;
    }
    //System.out.println("b");
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
