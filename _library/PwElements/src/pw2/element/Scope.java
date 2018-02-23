package pw2.element;
import beads.UGen;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PImage;
import pw2.beads.UGenListener;
import pw2.beads.UGenW;
public class Scope extends Element {
  int strokeWeight=4;
  PImage image;
  UGen attachedUGen;
  int fgColor;
  UGenListener power;
  //temp
  boolean canDraw=false;
  boolean changed=false;
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
  public void attach(UGenW ugen) {
    attachedUGen=ugen;
    power=new UGenListener() {
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
      public void accept(float[][] bufOut) {
        if (!canDraw) return;
        image.loadPixels();
        synchronized (image) {//slowing down...thread safe...
          java.util.Arrays.fill(image.pixels, 0);
          int size=bufOut[0].length;
          while (size > 0 && PApplet.abs(bufOut[0][bufOut[0].length - size]) > 0.05F) {
            size--;
          }
          if (size == 0) {
            size=bufOut[0].length;
          }
          int pvOffset=image.height / 2;
          for (int a=0; a < image.width; a++) {
            int buffIndex=bufOut[0].length - size + a * size / image.width;
            int vOffset=(int)((1 - bufOut[0][buffIndex]) * image.height / 2);
            vOffset=Math.min(image.height - 1, Math.max(0, vOffset));
            line(a, pvOffset, vOffset);
            pvOffset=vOffset;
          }
          image.updatePixels();
        }
        changed=true;
      }
    };
    ugen.addListener(power);
  }
  public void deattach() {
    power.kill();
    attachedUGen=null;
  }
  public Scope(String s) {
    super(s);
    bgColor=KyUI.Ref.color(127);
    fgColor=KyUI.Ref.color(50);
  }
  @Override
  public void render(PGraphics g) {
    if (attachedUGen == null) {//no!!
      return;
    }
    g.fill(bgColor);
    pos.render(g);
    if (image == null) {
      return;
    }
    g.imageMode(PApplet.CENTER);
    synchronized (image) {//slowing down...thread safe...
      g.image(image, (pos.right + pos.left) / 2, (pos.bottom + pos.top) / 2);
    }
  }
  @Override
  public void update() {
    if (changed) {
      changed=false;
      invalidate();
    }
  }
}
