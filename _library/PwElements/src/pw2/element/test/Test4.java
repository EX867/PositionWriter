package pw2.element.test;
import beads.*;
import kyui.core.Attributes;
import kyui.core.KyUI;
import kyui.element.DivisionLayout;
import kyui.element.LinearLayout;
import kyui.element.ToggleButton;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import pw2.beads.*;
import pw2.element.*;
import pw2.element.ugens.AutoFaderControl;
import pw2.element.ugens.TDCompControl;
public class Test4 extends PApplet {
  public static void main(String[] args) {
    PApplet.main("pw2.element.test.Test4");
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
    WavePlayerW n=new WavePlayerW(ac, Buffer.SAW);
    String path="C:\\Users\\user\\Documents\\[Projects]\\PositionWriter\\AlsExtractor\\data\\Love_u1.wav";
    //    SamplePlayer p=null;
    //    p=new SamplePlayer(ac, 2);
    //    p.setKillOnEnd(false);
    Sample sample=null;
    //    try {
    //      p.setSample(sample=new Sample(path));
    //    } catch (Exception e) {
    //      e.printStackTrace();
    //    }
    UGen u=n;
    //tdcomp test
    AutoFaderW fader=new AutoFaderW(ac, 2);
    AutoFaderControl f=new AutoFaderControl("control").initialize(fader);
    //
    WavEditor v=new WavEditor("VV").initPlayer(ac);
    try {
      v.setSample(sample=new Sample(path));
    } catch (Exception e) {
      e.printStackTrace();
    }
    //
    f.setAsMirror(v);
    //Knob freq=new Knob("freq").attach(ac, n, n.setFrequency, 1, 20000, 0, 400, true);
    DivisionLayout dv=new DivisionLayout("dv");
    dv.setPosition(new Rect(0, 0, width, height));
    dv.rotation=Attributes.Rotation.LEFT;
    dv.value=30;
    dv.addChild(new VUMeter("v").attach(ac.out));
    dv.addChild(f);
    KyUI.add(dv);
    KyUI.changeLayout();
    KyUI.addResizeListener((int w, int h) -> {
      dv.pos.set(0, 0, w, h);
      dv.value=h;
      KyUI.changeLayout();
    });
    //
    v.player.addAuto(fader.preCount);
    v.player.addAuto(fader.postCount);
    v.player.addAuto(fader.cuePoint);
    fader.addInput(v.player);//do not use f.view.player...
    ac.out.addInput(fader);
    ac.out.setGain(0.5F);
    ac.start();
    v.player.start();
  }
  @Override
  public void draw() {
    KyUI.render(g);
  }
  public void keyPressed() {
    if (key == 'a') {
      WavEditor c=KyUI.<AutoFaderControl>get2("control").view;
      c.setAutomationMode(!c.getAutomationMode());
    }
    if (key == ' ') {
      WavEditor w=KyUI.<WavEditor>get2("VV");
      if (w.player.getPosition() == w.player.getLoopEndUGen().getValue()) {
        w.player.setPosition(w.player.getLoopStartUGen().getValue());
        w.player.pause(false);
      } else {
        w.player.pause(!w.player.isPaused());
      }
    }
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