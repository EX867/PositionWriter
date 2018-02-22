package pw2.element;
import beads.*;
import kyui.core.Element;
import kyui.core.KyUI;
import processing.core.PGraphics;
public class VUMeter extends Element {
  int strokeWeight=4;
  Power[] power;
  ShortFrameSegmenter[] segmenter;
  UGen attachedUGen;
  int fgColor;
  int highlightColor;
  int errorColor;
  float head=20;
  public void attach(UGen ugen) {
    attachedUGen=ugen;
    segmenter=new ShortFrameSegmenter[ugen.getIns()];
    power=new Power[ugen.getIns()];
    for (int a=0; a < power.length; a++) {
      segmenter[a]=new ShortFrameSegmenter(ugen.getContext());
      power[a]=new Power();
      ugen.getContext().out.addDependent(segmenter[a]);
      segmenter[a].addInput(0, ugen, a);
      segmenter[a].addListener(power[a]);
    }
  }
  public void deattach() {
    for (int a=0; a < power.length; a++) {
      segmenter[a].kill();
      power[a].kill();
    }
    attachedUGen=null;
  }
  public VUMeter(String s) {
    super(s);
    bgColor=KyUI.Ref.color(50);
    fgColor=KyUI.Ref.color(127);
    highlightColor=KyUI.Ref.color(0, 0, 255);
    errorColor=KyUI.Ref.color(255, 0, 0);
  }
  @Override
  public void render(PGraphics g) {
    if (attachedUGen == null) {//no!!
      return;
    }
    if (power.length == 0) {//???
      return;
    }
    g.fill(bgColor);
    pos.render(g);
    float interval=(pos.right - pos.left) / power.length;
    for (int a=0; a < power.length; a++) {
      Float features=power[a].getFeatures();
      if (features != null) {
        features*=power.length;//mult with channels
        float db=(float)linToDb(features);
        g.fill(fgColor);
        g.rect(pos.left + a * interval + 2, pos.top + head, pos.left + (a + 1) * interval - 4, pos.bottom);
        if (db < 0) {
          g.fill(highlightColor);
          g.rect(pos.left + a * interval + 3, pos.bottom - (pos.bottom - pos.top - head) * features, pos.left + (a + 1) * interval - 5, pos.bottom);
        } else {
          g.fill(errorColor);
          g.rect(pos.left + a * interval + 3, pos.bottom - (pos.bottom - pos.top - head) * features, pos.left + (a + 1) * interval - 5, pos.bottom);
        }
      }
    }
  }
  public static double linToDb(double in) {
    return 20 * Math.log10(in);
  }
  public static double dbToLin(float in) {
    return Math.pow(10, 0.05 * in);
  }
  @Override
  public void update() {
    if (!attachedUGen.isPaused() && attachedUGen.getContext().isRunning()) {
      invalidate();
    }
  }
}
