package pw2.element.test;
import beads.AudioContext;
import beads.Sample;
import beads.SampleManager;
import beads.SamplePlayer;
import kyui.core.Attributes;
import kyui.core.KyUI;
import kyui.element.*;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import pw2.beads.GainW;
import pw2.beads.KnobAutomation;
import pw2.element.Knob;
import pw2.element.WavEditor;
public class Test3 extends PApplet {
  KnobAutomation aa;
  public static void main(String[] args) {
    PApplet.main("pw2.element.test.Test3");
  }
  @Override
  public void settings() {
    size(1500, 600);
  }
  WavEditor w;
  @Override
  public void setup() {
    KyUI.start(this);
    AudioContext ac=new AudioContext();
    w=new WavEditor("wav");
    w.snapBpm=140;
    w.snapOffset=1386.05453381616781;//->???
    w.snapInterval=WavEditor.Beat[7];
    LinearLayout lin1=new LinearLayout("lin1");
    lin1.setDirection(Attributes.Direction.VERTICAL);
    lin1.setMode(LinearLayout.Behavior.STATIC);
    DivisionLayout dv2=new DivisionLayout("dv2");
    dv2.rotation=Attributes.Rotation.RIGHT;
    dv2.value=60;
    DivisionLayout dv=new DivisionLayout("dv");
    dv.rotation=Attributes.Rotation.DOWN;
    RangeSlider s=w.getSlider();
    dv.addChild(w);
    dv.addChild(s);
    dv2.addChild(dv);
    Button b;
    lin1.addChild(w.setDeletePoint(b=new Button("delete")));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="DELETE";
    lin1.addChild(w.setToggleAutoscroll((ToggleButton)(b=new ToggleButton("autoscroll"))));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="AUTOSCROLL";
    dv2.addChild(lin1);
    KyUI.add(dv2);
    dv2.setPosition(new Rect(0, 0, width, height));
    KyUI.changeLayout();
    w.initPlayer(ac);
    String path="C:\\Users\\user\\Documents\\[Projects]\\PositionWriter\\AlsExtractor\\data\\Love_u1.wav";
    w.setSample(SampleManager.sample(path));
    //w.player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    GainW g=new GainW(ac, 2);
    g.addInput(w.player);
    ac.out.addInput(g);
    new Knob("a", "a").attach(ac, g, g.setGain, 0, 2, 1, 1, false);
    w.player.addAuto(g.gain);
    //    for (int a=0; a < 10; a++) {
    //      g.gain.addPoint(((float)a / 10) * w.sample.getLength(), Math.random());
    //    }
    w.automation=g.gain;
    aa=g.gain;
    ac.start();
  }
  @Override
  public void keyPressed(KeyEvent e) {
    if (keyPressed) {
      if (key == ' ') {
        KyUI.<WavEditor>get2("wav").player.pause(!KyUI.<WavEditor>get2("wav").player.isPaused());
      }
      if (key == 'a') {
        KyUI.<WavEditor>get2("wav").setAutomationMode(!KyUI.<WavEditor>get2("wav").getAutomationMode());
        KyUI.get("wav").invalidate();
      }
      if (key == 'd') {
        KyUI.<Button>get2("delete").getPressListener().onEvent(null, 0);
        KyUI.get("wav").invalidate();
      }
      if (key == 'q') {//processing's limit
        aa.addPoint(w.snapTime(
            Math.max(Math.min(w.player.getPosition() + (double)(((java.awt.event.KeyEvent)e.getNative()).getWhen() - System.currentTimeMillis()), w.sample.getLength()), 0)
        ), 1);
        KyUI.<WavEditor>get2("wav").automationInvalid=true;
        KyUI.get("wav").invalidate();
      }
    }
  }
  @Override
  public void draw() {
    KyUI.render(g);
    w.selectionMode=keyPressed && key == CODED && keyCode == CONTROL;
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
