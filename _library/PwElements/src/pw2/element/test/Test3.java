package pw2.element.test;
import beads.AudioContext;
import beads.Sample;
import beads.SampleManager;
import beads.SamplePlayer;
import kyui.core.Attributes;
import kyui.core.KyUI;
import kyui.element.DivisionLayout;
import kyui.element.RangeSlider;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import pw2.element.WavEditor;
public class Test3 extends PApplet {
  public static void main(String[] args) {
    PApplet.main("pw2.element.test.Test3");
  }
  @Override
  public void settings() {
    size(1500, 600);
  }
  @Override
  public void setup() {
    KyUI.start(this);
    AudioContext ac=new AudioContext();
    WavEditor w=new WavEditor("wav");
    DivisionLayout dv=new DivisionLayout("dv");
    dv.rotation=Attributes.Rotation.DOWN;
    RangeSlider s=w.getSlider();
    dv.addChild(w);
    dv.addChild(s);
    KyUI.add(dv);
    dv.setPosition(new Rect(0, 0, width, height));
    KyUI.changeLayout();
    w.initPlayer(ac);
    String path="C:\\Users\\user\\Documents\\[Projects]\\PositionWriter\\AlsExtractor\\data\\Love_u1.wav";
    w.setSample(SampleManager.sample(path));
    w.player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    ac.out.addInput(w.player);
    ac.start();
  }
  public void keyPressed(){
    if(keyPressed&&key==' '){
      KyUI.<WavEditor>get2("wav").player.pause(!KyUI.<WavEditor>get2("wav").player.isPaused());
    }
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
