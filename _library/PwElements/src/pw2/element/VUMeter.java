package pw2.element;
import beads.*;
import kyui.core.Element;
import kyui.core.KyUI;
import processing.core.PGraphics;
public class VUMeter extends Element {
  int strokeWeight=4;
  ModifiedPower[] power;
  ShortFrameSegmenter[] segmenter;
  UGen attachedUGen;
  int fgColor;
  int highlightColor;
  int errorColor;
  float head=20;
  float[] peaks;
  public VUMeter attach(UGen ugen) {
    attachedUGen=ugen;
    segmenter=new ShortFrameSegmenter[ugen.getIns()];
    power=new ModifiedPower[ugen.getIns()];
    peaks=new float[ugen.getIns()];
    for (int a=0; a < power.length; a++) {
      segmenter[a]=new ShortFrameSegmenter(ugen.getContext());
      power[a]=new ModifiedPower();
      ugen.getContext().out.addDependent(segmenter[a]);
      segmenter[a].addInput(0, ugen, a);
      segmenter[a].addListener(power[a]);
    }
    return this;
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
    //System.out.println("e");
    float interval=(pos.right - pos.left) / power.length;
    for (int a=0; a < power.length; a++) {
      float[] features=power[a].getFeatures();
      if (features != null) {
        features[0]*=power.length;//mult with channels
        float db=(float)linToDb(features[1]);
        g.fill(fgColor);
        g.rect(pos.left + a * interval + 2, pos.top + head, pos.left + (a + 1) * interval - 4, pos.bottom);
        if (db < 0) {
          g.fill(highlightColor);
          g.rect(pos.left + a * interval + 3, pos.bottom - (pos.bottom - pos.top - head) * features[0], pos.left + (a + 1) * interval - 5, pos.bottom);
        } else {
          g.fill(errorColor);
          g.rect(pos.left + a * interval + 3, pos.bottom - (pos.bottom - pos.top - head) * features[0], pos.left + (a + 1) * interval - 5, pos.bottom);
        }
        features[0]=features[0] / power.length;
        features[1]=features[1];// power.length;
        if (peaks[a] < features[1]) {//0~1
          peaks[a]=features[1];
        } else {
          peaks[a]=peaks[a] - 0.01f;
          if (peaks[a] < 0) {
            peaks[a]=0;
          }
        }
        float y=pos.bottom - (pos.bottom - pos.top - head) * peaks[a];
        g.strokeWeight(4);
        g.stroke(0);
        g.line(pos.left + a * interval + 1, y, pos.left + (a + 1) * interval - 3, y);
        g.noStroke();
      }
    }
    //System.out.println("f");
  }
  public static double linToDb(double in) {
    return 20 * Math.log10(in);
  }
  public static double dbToLin(double in) {
    return Math.pow(10, 0.05 * in);
  }
  @Override
  public void update() {
    if (attachedUGen != null && !attachedUGen.isPaused() && attachedUGen.getContext().isRunning()) {
      invalidate();
    }
  }
  public static class ModifiedPower extends FeatureExtractor<float[], float[]> {
    public ModifiedPower() {
      features=new float[2];
    }
    public int getNumberOfFeatures() {//float[1]
      return 2;
    }
    public void process(TimeStamp startTime, TimeStamp endTime, float[] audioData) {
      features[0]=0.0f;//lets get rms
      features[1]=0.0f;
      for (int i=0; i < audioData.length; i++) {
        if (features[1] < Math.abs(audioData[i])) {//and get peak too.
          features[1]=Math.abs(audioData[i]);
        }
        features[0]=features[0] + audioData[i] * audioData[i];
      }
      features[0]=(float)Math.sqrt(features[0] / (float)audioData.length);
    }
  }
}
