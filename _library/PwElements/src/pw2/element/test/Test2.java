package pw2.element.test;
import beads.AudioContext;
import beads.Buffer;
import beads.SampleManager;
import beads.SamplePlayer;
import kyui.core.Attributes;
import kyui.core.KyUI;
import kyui.element.DivisionLayout;
import kyui.element.LinearLayout;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import pw2.beads.*;
import pw2.element.*;
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
    String path="C:\\Users\\user\\Documents\\Studio One\\Songs\\THE 6TH\\Mixdown\\THE 6TH_1.wav";
    SamplePlayer p=new SamplePlayer(ac, SampleManager.sample(path));
    p.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    WavePlayerW n2=new WavePlayerW(ac, Buffer.SQUARE);
    GainW inputgain=new GainW(ac, 2);
    GainW gain=new GainW(ac, 2);
    TDCompW comp=new TDCompW(ac, 2);
    inputgain.addInput(p);
    comp.addInput(inputgain);
    inputgain.setGain.setter.execute(1);
    ac.out.addInput(comp);
    gain.addInput(n2);
    VUMeter k=new VUMeter("asdf");
    k.attach(comp);
    ac.out.setGain(0.5F);
    //comp.ugen.setSideChain(gain);
    Knob[] b=new Knob[10];
    b[0]=new Knob("b1", "Freq").attach(ac, n, n.setFrequency, 20, 20000, 20, 800, true);
    b[1]=new Knob("b2", "Attack").attach(ac, comp, comp.setAttack, 0, 1000, 100, 100, false);
    b[2]=new Knob("b3", "Release").attach(ac, comp, comp.setRelease, 0, 1000, 300, 300, false);
    b[3]=new Knob("b4", "Threshold").attach(ac, comp, comp.setThreshold, -60, 0, -6, -6, false);
    b[4]=new Knob("b5", "Ratio").attach(ac, comp, comp.setRatio, 1, 12, 2, 2, false);
    b[5]=new Knob("b6", "Knee").attach(ac, comp, comp.setKnee, 0, 1, 0.1, 0.1, false);
    b[6]=new Knob("b7", "Gain").attach(ac, comp, comp.setOutputGain, 0, 3, 1, 1, false);
    //
    comp.sideChain.setLoop(true);
    comp.sideChain.addPoint(0, 1);
    comp.sideChain.addPoint(500, 2);
    comp.sideChain.setLoopStart(0);
    comp.sideChain.setLoopEnd(1000);
    //
    comp.addSample("C:\\Users\\user\\Documents\\Studio One\\Samples\\MainDrum\\14.wav");
    comp.addSample("C:\\Users\\user\\Documents\\Studio One\\Samples\\MainDrum\\1.wav");
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
    scope.attach(inputgain);
    scope2.attach(comp);
    DivisionLayout dv3=new DivisionLayout("dv3");
    dv3.value=height / 2;
    dv3.rotation=Attributes.Rotation.RIGHT;
    dv2.addChild(dv3);
    dv3.addChild(new TDCompWave("wave").attach(comp));
    dv3.addChild(new TDCompGraph("graph").attach(comp));
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