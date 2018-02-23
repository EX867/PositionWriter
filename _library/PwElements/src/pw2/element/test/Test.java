package pw2.element.test;
import beads.*;
import kyui.core.Attributes;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.element.Button;
import kyui.element.DivisionLayout;
import kyui.element.LinearLayout;
import kyui.element.ToggleButton;
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
    size(1500, 600);
  }
  @Override
  public void setup() {
    KyUI.start(this);
    AudioContext ac=new AudioContext();
    WavePlayerW n=new WavePlayerW(ac, Buffer.SAW);
    ///String path="C:\\Users\\user\\Downloads\\Sine_440hz_0dB_10seconds_44.1khz_16bit_mono.wav";
    //SamplePlayer p=new SamplePlayer(ac, SampleManager.sample(path));
    //p.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    BiquadFilterW filter=new BiquadFilterW(ac, 2, BiquadFilter.LP);
    ReverbW rev=new ReverbW(ac, 2, 2);
    rev.addInput(n);
    filter.addInput(rev);
    ac.out.addInput(filter);
    VUMeter k=new VUMeter("asdf");
    k.attach(ac.out);
    ac.out.setGain(0.5F);
    Knob[] b=new Knob[10];
    b[0]=new Knob("b1", "Freq").attach(ac, n, n.setFrequency, 20, 20000, 20, 800, true);
    b[2]=new Knob("b3", "Size").attach(ac, rev, rev.setSize, 0, 1, 0, 0.2, false);
    b[3]=new Knob("b4", "Damping").attach(ac, rev, rev.setDamping, 0, 1, 0, 0.5, false);
    b[4]=new Knob("b5", "Freq").attach(ac, filter, filter.setFrequency, 20, 20000, 20, 20000, true);
    b[5]=new Knob("b6", "Q").attach(ac, filter, filter.setQ, 0.7, 7, 1, 1, true);
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
    ly.addChild(scope);
    scope.attach(filter);
    Spectrum sp=new Spectrum("spec");
    DivisionLayout dv3=new DivisionLayout("dv3");
    dv3.rotation=Attributes.Rotation.RIGHT;
    dv3.value=40;
    dv2.addChild(dv3);
    dv3.addChild(sp);
    sp.attach(ac, filter);
    DivisionLayout dv4=new DivisionLayout("dv4");
    dv4.rotation=Attributes.Rotation.UP;
    dv4.mode=DivisionLayout.Behavior.PROPORTIONAL;
    dv4.value=0.5F;
    dv3.addChild(dv4);
    Button btn=new Button("btn");
    btn.rotation=Attributes.Rotation.RIGHT;
    btn.text="Change buf";
    ToggleButton btn2=new ToggleButton("btn2");
    btn2.rotation=Attributes.Rotation.RIGHT;
    btn2.text="Toggle Rev";
    btn2.value=true;
    dv4.addChild(btn);
    dv4.addChild(btn2);
    btn.setPressListener((e, index) -> {
      if (n.player.getBuffer() == Buffer.SINE) {
        n.player.setBuffer(Buffer.SAW);
      } else if (n.player.getBuffer() == Buffer.SAW) {
        n.player.setBuffer(Buffer.SQUARE);
      } else if (n.player.getBuffer() == Buffer.SQUARE) {
        n.player.setBuffer(Buffer.SINE);
      }
      return false;
    });
    btn2.setPressListener((e, index) -> {
      rev.bypass(!btn2.value);
      return false;
    });
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
