package pw2.element.test;
import beads.AudioContext;
import beads.Buffer;
import kyui.core.Attributes;
import kyui.core.KyUI;
import kyui.element.DivisionLayout;
import kyui.element.LinearLayout;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import pw2.beads.*;
import pw2.element.Knob;
import pw2.element.Scope;
import pw2.element.TDCompWave;
import pw2.element.VUMeter;
public class Test2 extends PApplet {
  public static void main(String[] args) {
    PApplet.main("pw2.element.test.Test2");
  }
  @Override
  public void settings() {
    size(1500, 600);
  }
  @Override
  public void setup() {
    KyUI.start(this);
    AudioContext ac=new AudioContext();
    WavePlayerW n=new WavePlayerW(ac, Buffer.SQUARE);
    WavePlayerW n2=new WavePlayerW(ac, Buffer.SQUARE);
    GainW inputgain=new GainW(ac, 2);
    GainW gain=new GainW(ac, 2);
    TDCompW comp=new TDCompW(ac, 2);
    inputgain.addInput(n);
    comp.addInput(inputgain);
    inputgain.setGain.setter.execute(0.5);
    ac.out.addInput(comp);
    gain.addInput(n2);
    comp.ugen.setSideChain(gain);
    VUMeter k=new VUMeter("asdf");
    k.attach(ac.out);
    ac.out.setGain(0.5F);
    Knob[] b=new Knob[10];
    // b[0]=new Knob("b1", "Freq").attach(ac, n, n.setFrequency, 20, 20000, 20, 1600, true);
    b[1]=new Knob("b2", "Attack").attach(ac, comp, comp.setAttack, 0, 1000, 100, 100, false);
    b[2]=new Knob("b3", "Release").attach(ac, comp, comp.setRelease, 0, 1000, 300, 300, false);
    b[3]=new Knob("b4", "Threshold").attach(ac, comp, comp.setThreshold, -12, 0, -6, -6, false);
    b[4]=new Knob("b5", "Ratio").attach(ac, comp, comp.setRatio, 1, 12, 2, 2, false);
    b[5]=new Knob("b6", "Knee").attach(ac, comp, comp.setKnee, 0, 0.5, 0.1, 0.1, false);
    b[6]=new Knob("b7", "Gain").attach(ac, gain, gain.setGain, 0, 4, 0.5, 1, false);
    //
    gain.gain.setLoop(true);
    gain.gain.addPoint(0, 1);
    gain.gain.addPoint(1000, 1);
    gain.gain.addPoint(1001, 0.3);
    gain.gain.addPoint(2000, 0.3);
    gain.gain.addPoint(2001, 1);
    gain.gain.setLoopStart(0);
    gain.gain.setLoopStart((float)gain.gain.getLength());
    //
    DivisionLayout dv=new DivisionLayout("dv");
    dv.setPosition(new Rect(0, 0, width, height));
    dv.rotation=Attributes.Rotation.LEFT;
    dv.value=40;
    dv.addChild(k);
    DivisionLayout dv2=new DivisionLayout("dv2");
    dv2.rotation=Attributes.Rotation.UP;
    dv2.mode=DivisionLayout.Behavior.PROPORTIONAL;
    dv2.value=0.5F;
    dv.addChild(dv2);
    LinearLayout ly=new LinearLayout("lin");
    dv2.addChild(ly);
    ly.setMode(LinearLayout.Behavior.STATIC);
    for (int a=0; a < b.length; a++) {
      if (b[a] != null) {
        ly.addChild(b[a]);
      }
    }
    Scope scope=new Scope("scope");
    Scope scope2=new Scope("scope2");
    ly.addChild(scope);
    ly.addChild(scope2);
    scope.attach(comp);
    scope2.attach(gain);
    dv2.addChild(new TDCompWave("wave").attach(comp));
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