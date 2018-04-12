package pw2.element.test;
import beads.*;
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
import pw2.element.ugens.TDCompControl;
public class Test3 extends PApplet {
  public static void main(String[] args) {
    PApplet.main("pw2.element.test.Test3");
  }
  int h=400;
  @Override
  public void settings() {
    size(954 + h, h);
  }
  @Override
  public void setup() {
    KyUI.start(this, 30, true);
    surface.setResizable(true);
    AudioContext ac=new AudioContext();
    //WavePlayerW n=new WavePlayerW(ac, Buffer.SAW);
    String path="C:\\Users\\user\\Documents\\[Projects]\\PositionWriter\\AlsExtractor\\data\\Love_u1.wav";
    SamplePlayer p=null;
    p=new SamplePlayer(ac,2);
    p.setKillOnEnd(false);
    Sample sample;
    try {
      p.setSample(sample=new Sample(path));
    } catch (Exception e) {
      e.printStackTrace();
    }
    //
    UGen u=p;
    TDCompW comp=new TDCompW(ac, 2);
    TDCompControl c=new TDCompControl("control").initialize(comp);
    comp.addInput(u);
    ac.out.addInput(comp);
    ac.out.setGain(0.2F);
    //c.addSample("C:\\Users\\user\\Documents\\Studio One\\Samples\\MainDrum\\14.wav");
    //c.addSample("C:\\Users\\user\\Documents\\Studio One\\Samples\\MainDrum\\1.wav");
    //
    //Knob freq=new Knob("freq").attach(ac, n, n.setFrequency, 1, 20000, 0, 400, true);
    DivisionLayout dv=new DivisionLayout("dv");
    dv.setPosition(new Rect(0, 0, width, height));
    dv.rotation=Attributes.Rotation.LEFT;
    dv.value=h;
    //dv.addChild(freq);
    dv.addChild(c);
    KyUI.add(dv);
    KyUI.changeLayout();
    KyUI.addResizeListener((int w, int h) -> {
      dv.pos.set(0, 0, w, h);
      dv.value=h;
      KyUI.changeLayout();
    });
    comp.sideChain.addPoint(0,1);
    comp.sideChain.addPoint((float)60000/140,2);
    comp.sideChain.setLoopEnd((float)60000/70);
    comp.sideChain.setLoop(true);
    ac.start();
    p.start();
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