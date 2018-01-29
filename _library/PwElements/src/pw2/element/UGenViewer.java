package pw2.element;
import kyui.core.Element;
import processing.core.PGraphics;
public class UGenViewer extends Element {
  public UGenViewer(String s) {
    super(s);
    bgColor=0xFF323232;
  }
  @Override
  public void render(PGraphics g) {
    g.textSize(15);
    g.fill(0);
    g.text("(effect controls are here, it's incompleted.)", (pos.left + pos.right) / 2, (pos.top + pos.bottom) / 2);
  }
}
