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
    WavePlayer n=new WavePlayer(ac, 800, Buffer.SAW);
    BiquadFilter filter=new BiquadFilter(ac, 2, BiquadFilter.LP);
    Reverb rev=new Reverb(ac, 2);
    rev.addInput(n);
    filter.addInput(rev);
    ac.out.addInput(filter);
    VUMeter k=new VUMeter("asdf");
    k.attach(ac.out);
    ac.out.setGain(0.4F);
    Knob[] b=new Knob[10];
    b[0]=new Knob("b1").attach(ac, (UGen u) -> {
      n.setFrequency(u);
    }, 20, 120000, 20, 800, true);
    b[2]=new Knob("b3").attach((Double d) -> {
      rev.setSize(d.floatValue());
    }, 0, 1, 0, 1);
    b[3]=new Knob("b4").attach((Double d) -> {
      rev.setDamping(d.floatValue());
    }, 0, 1, 0, 1);
    b[4]=new Knob("b5").attach(ac, (UGen u) -> {
      filter.setFrequency(u);
    }, 20, 22000, 20, 22000, true);
    b[5]=new Knob("b6").attach(ac, (UGen u) -> {
      filter.setQ(u);
    }, 0.6, 6, 1, 1, true);
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
