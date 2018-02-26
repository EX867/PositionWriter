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
    power.addListener(new FeatureExtractor<Object, float[]>() {
      @Override
      public void process(TimeStamp timeStamp, TimeStamp timeStamp1, float[] features) {
        if (!canDraw) return;
        image.loadPixels();
        java.util.Arrays.fill(image.pixels, 0);
        //float[] features=power.getFeatures();
        int pvOffset=0;
        int pfeatureIndex=0;
        if (features != null) {
          for (int i=0; i < features.length; i++) {
            int featureIndex=(int)(image.width * Math.log10((double)i * (10 - 1) / features.length + 1));
            int vOffset=(int)((1 - 2 * Math.sqrt(features[i]) / fft.getNumberOfFeatures()) * image.height);
            vOffset=Math.min(image.height - 1, Math.max(0, vOffset));
            line(pfeatureIndex, pvOffset, featureIndex, vOffset);
            pvOffset=vOffset;
            pfeatureIndex=featureIndex;
          }
        }
        image.updatePixels();
      }
    });
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
  private void line(int x1, int y1, int x2, int y2) {
    if (y1 > y2) {
      int temp=y1;
      y1=y2;
      y2=temp;
      temp=x1;
      x1=x2;
      x2=temp;
    } else if (y1 == y2 && x1 > x2) {
      int temp=x1;
      x1=x2;
      x2=temp;
    }
    if (y1 < y2) {
      for (int a=y1; a < y2; a++) {
        image.pixels[a * image.width + (x1 + (x2 - x1) * (a - y1) / (y2 - y1))]=fgColor;
      }
    }
  }
  @Override
  public void render(PGraphics g) {
    if (attachedUGen == null) {//no!!
      return;
    }
    g.strokeWeight(strokeWeight);
    g.fill(bgColor);
    g.stroke(fgColor);
    pos.render(g, -strokeWeight / 2);
    g.noStroke();
    if (image == null) {
      return;
    }
    g.imageMode(PApplet.CENTER);
    canDraw=false;//WARNING>sometimes of this, spectrum will not be drawn.
    g.image(image, (pos.right + pos.left) / 2, (pos.bottom + pos.top) / 2);
    canDraw=true;
  }
  @Override
  public void update() {
    if (attachedUGen != null && !attachedUGen.isPaused() && attachedUGen.getContext().isRunning()) {
      invalidate();
    }
  }
}
