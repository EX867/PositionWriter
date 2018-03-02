package pw2.element;
import beads.UGen;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PImage;
import pw2.beads.UGenListener;
import beads.UGenW;
public class Scope extends Element {
  int strokeWeight=4;
  PImage image;
  UGen attachedUGen;
  int fgColor;
  UGenListener power;
  int size;
  //temp
  boolean canDraw=false;
  boolean changed=false;
  @Override
  public void setPosition(Rect rect) {
    if (rect.left != rect.right && rect.top != rect.bottom) {
      canDraw=false;
      image=KyUI.Ref.createImage(Math.max(1, (int)(rect.right - rect.left)), Math.max(1, (int)(rect.bottom - rect.top)), PApplet.ARGB);
      canDraw=true;
    }
    super.setPosition(rect);
  }
  public void attach(UGenW ugen) {
    setPosition(pos);
    attachedUGen=ugen;
    size=ugen.getContext().getBufferSize() / 2;
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
        java.util.Arrays.fill(image.pixels, 0);
        int start=0;
        while (start + 1 < bufOut[0].length) {
          if (bufOut[0][start] < 0 && bufOut[0][start + 1] >= 0) {
            break;
          }
          start++;
        }
        if (start + 1 >= bufOut[0].length) {
          start=0;
        }
        int pvOffset=image.height / 2;
        for (int a=0; a < image.width; a++) {
          int buffIndex=start + a * size / image.width;
          if (buffIndex >= bufOut[0].length) {
            break;
          }
          int vOffset=(int)((1 - bufOut[0][buffIndex]) * image.height / 2);
          vOffset=Math.min(image.height - 1, Math.max(0, vOffset));
          line(a, pvOffset, vOffset);
          pvOffset=vOffset;
        }
        //WARNING>>synchronized!
        image.updatePixels();
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
    g.stroke(fgColor);
    g.strokeWeight(strokeWeight);
    g.fill(bgColor);
    pos.render(g, -strokeWeight / 2);
    g.line(pos.left, (pos.top + pos.bottom) / 2, pos.right, (pos.top + pos.bottom) / 2);
    g.noStroke();
    if (image == null) {
      return;
    }
    g.imageMode(PApplet.CENTER);
    //WARNING>>synchronized!
    canDraw=false;
    g.image(image, (pos.right + pos.left) / 2, (pos.bottom + pos.top) / 2);
    canDraw=true;
  }
  @Override
  public void update() {
    if (changed) {
      changed=false;
      invalidate();
    }
  }
}
