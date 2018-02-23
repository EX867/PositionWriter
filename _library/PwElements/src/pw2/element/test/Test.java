package pw2.element.test;
import beads.*;
import kyui.core.Attributes;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.element.DivisionLayout;
import kyui.element.LinearLayout;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import pw2.element.*;
import pw2.beads.*;
public class Test extends PApplet {
  public static void main(String[] args) {
    PApplet.main("pw2.element.test.Test");
  }
  @Override
  public void settings() {
    size(1300, 300);
  }
  @Override
  public void setup() {
    KyUI.start(this);
    AudioContext ac=new AudioContext();
    WavePlayerW n=new WavePlayerW(ac, Buffer.SAW);
    BiquadFilterW filter=new BiquadFilterW(ac, 2, BiquadFilter.LP);
    ReverbW rev=new ReverbW(ac, 1, 2);
    rev.addInput(n);
    filter.addInput(rev);
    ac.out.addInput(filter);
    VUMeter k=new VUMeter("asdf");
    k.attach(ac.out);
    ac.out.setGain(0.5F);
    Knob[] b=new Knob[10];
    b[0]=new Knob("b1").attach(ac, n, n.setFrequency, 20, 20000, 20, 800, true);
    b[2]=new Knob("b3").attach(ac, rev, rev.setSize, 0, 1, 0, 1, false);
    b[3]=new Knob("b4").attach(ac, rev, rev.setDamping, 0, 1, 0, 1, false);
    b[4]=new Knob("b5").attach(ac, filter, filter.setFrequency, 20, 20000, 20, 20000, true);
    b[5]=new Knob("b6").attach(ac, filter, filter.setQ, 0.7, 7, 1, 1, true);
    //
    DivisionLayout dv=new DivisionLayout("dv");
    dv.setPosition(new Rect(0, 0, width, height));
    dv.rotation=Attributes.Rotation.LEFT;
    dv.value=40;
    dv.addChild(k);
    LinearLayout ly=new LinearLayout("lin");
    dv.addChild(ly);
    ly.setMode(LinearLayout.Behavior.STATIC);
    for (int a=0; a < b.length; a++) {
      if (b[a] != null) {
        ly.addChild(b[a]);
      }
    }
    KyUI.add(dv);
    KyUI.changeLayout();
    ac.start();
  }
  @Override
  public void draw() {
    KyUI.render(g);
  }
  @Override
  protected void handleKeyEvent(KeyEvent event) {
    super.handleKeyEvent(event);
    KyUI.handleEvent(event);
  }
  @Override
  protected void handleMouseEvent(MouseEvent event) {
    super.handleMouseEvent(event);
    KyUI.handleEvent(event);
  }
}
