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
    size(500, 500);
  }
  @Override
  public void setup() {
    KyUI.start(this);
    AudioContext ac=new AudioContext();
    OscillatorBank n=new OscillatorBank(ac, Buffer.SINE, 1);
    ac.out.addInput(n);
    VUMeter k=new VUMeter("asdf");
    k.attach(ac.out);
    Knob[] b=new Knob[2];
    b[0]=new Knob("b1").set(0, 2, 1, 1);
    b[0].adjustListener=(Element e) -> {
      n.getGains()[0]=b[0].value;
      n.setGains(n.getGains());
    };
    b[1]=new Knob("b2").set((float)Math.log10(1), (float)Math.log10(200000), (float)Math.log10(200000), (float)Math.log10(200000));
    b[1].adjustListener=(Element e) -> {
      n.getFrequencies()[0]=(float)Math.pow(10, b[1].value);
      n.setFrequencies(n.getFrequencies());
    };
    //
    DivisionLayout dv=new DivisionLayout("dv");
    dv.setPosition(new Rect(0, 0, 500, 500));
    dv.rotation=Attributes.Rotation.LEFT;
    dv.value=40;
    dv.addChild(k);
    LinearLayout ly=new LinearLayout("lin");
    dv.addChild(ly);
    ly.setMode(LinearLayout.Behavior.STATIC);
    for (int a=0; a < b.length; a++) {
      ly.addChild(b[a]);
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
