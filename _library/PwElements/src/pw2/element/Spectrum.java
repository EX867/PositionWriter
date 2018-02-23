package pw2.element;
import beads.*;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PImage;
public class Spectrum extends Element {
  int strokeWeight=4;
  ScalingMixer mono;
  FFT fft;
  PowerSpectrum power;
  ShortFrameSegmenter segmenter;
  UGen attachedUGen;
  int fgColor;
  //temp
  PImage image;
  boolean canDraw=false;
  @Override
  public void setPosition(Rect rect) {
    canDraw=false;
    if (image == null) {
      image=KyUI.Ref.createImage((int)(rect.right - rect.left), (int)(rect.bottom - rect.top), PApplet.ARGB);
    } else {
      image.resize((int)(rect.right - rect.left), (int)(rect.bottom - rect.top));
    }
    canDraw=true;
    super.setPosition(rect);
  }
  public void attach(AudioContext ac, UGen ugen) {
    attachedUGen=ugen;
    mono=new ScalingMixer(ac);
    segmenter=new ShortFrameSegmenter(ac);
    mono.addInput(ugen);
    segmenter.addInput(mono);
    fft=new FFT();
    power=new PowerSpectrum();
    segmenter.addListener(fft);
    fft.addListener(power);
    ac.out.addDependent(segmenter);
  }
  public void deattach() {
    segmenter.kill();
    fft.kill();
    power.kill();
    attachedUGen=null;
  }
  public Spectrum(String s) {
    super(s);
    bgColor=KyUI.Ref.color(127);
    fgColor=KyUI.Ref.color(50);
  }
  private void line(int x, int y1, int y2) {
    if (y1 > y2) {
      int temp=y1;
      y1=y2;
      y2=temp;
    }
    for (int a=y1; a <= y2; a++) {
      image.pixels[a * image.width + x]=fgColor;
    }
  }
  @Override
  public void render(PGraphics g) {
    if (attachedUGen == null) {//no!!
      return;
    }
    g.fill(bgColor);
    pos.render(g);
    g.imageMode(PApplet.CENTER);
    if (!canDraw) return;
    image.loadPixels();
    java.util.Arrays.fill(image.pixels, 0);
    g.imageMode(PApplet.CENTER);
    float[] features=power.getFeatures();
    int pvOffset=0;
    if (features != null) {
      for (int i=0; i < image.width; i++) {
        int featureIndex=i * features.length / image.width;
        int vOffset=image.height - 1 - Math.min((int)((120 - features[featureIndex]) * image.height), image.height - 1);
        vOffset=Math.min(image.height - 1, Math.max(0, vOffset));
        line(i, pvOffset, vOffset);
        pvOffset=vOffset;
      }
    }
    image.updatePixels();
    g.image(image, (pos.right + pos.left) / 2, (pos.bottom + pos.top) / 2);
  }
  public static double linToDb(double in) {
    return 20 * Math.log10(in);
  }
  public static double dbToLin(float in) {
    return Math.pow(10, 0.05 * in);
  }
  @Override
  public void update() {
    if (attachedUGen != null && !attachedUGen.isPaused() && attachedUGen.getContext().isRunning()) {
      invalidate();
    }
  }
}
