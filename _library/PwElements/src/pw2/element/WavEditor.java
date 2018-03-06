package pw2.element;
import beads.Sample;
import beads.SamplePlayer;
import com.karnos.commandscript.Difference;
import kyui.core.Attributes;
import kyui.core.Element;
import kyui.element.Button;
import kyui.element.RangeSlider;
import kyui.element.ToggleButton;
import processing.core.PGraphics;
import processing.event.MouseEvent;
import pw2.beads.KnobAutomation;
public class WavEditor extends Element {
  Sample sample;
  SamplePlayer player;
  float scale;
  float offsetX;
  RangeSlider slider;//add it manually...
  int fgColor;
  double length;
  public boolean autoscroll=false;
  public boolean snap=false;
  public boolean automationMode=false;
  public double snapInterval=2000;//milliseconds
  public double snapOffset=0;//milliseconds, mod snapInterval
  public KnobAutomation automation;
  public class ChangeData {
  }
  public class Change extends Difference<ChangeData> {
    public Change(ChangeData before_, ChangeData after_) {
      super(before_, after_);
    }
    @Override
    public void undo() {
    }
    @Override
    public void redo() {
    }
  }
  //
  WaveformDraw waveformDraw=new WaveformDraw();
  public WavEditor(String s) {
    super(s);
    bgColor=0xFF323232;
    fgColor=0xFF7F7F7F;
    slider=new RangeSlider(getName() + ":slider");
    slider.direction=Attributes.Direction.HORIZONTAL;
    slider.setAdjustListener((Element e) -> {
      invalidate();
    });
  }
  public void setSample(Sample sample_) {
    sample=sample_;
    length=sample.getLength();
  }
  public RangeSlider getSlider() {
    return slider;
  }
  public void getLoopStart() {
  }
  public void getLoopEnd() {
  }
  void setSlider() {//when move slider
    slider.setLength((pos.right - pos.left) * scale, pos.right - pos.left);
    slider.setOffset((pos.right - pos.left) * scale, offsetX);
  }
  @Override
  public void render(PGraphics g) {
    //draw background
    super.render(g);
    g.textSize(15);
    g.fill(0);
    g.text("(waveform is here, it's incompleted.)", (pos.left + pos.right) / 2, (pos.top + pos.bottom) / 2);
    if (autoscroll) {
      //update offsetX
    }
    //draw waveform
    waveformDraw.render(g, pos, sample, fgColor, offsetX, scale);
    //draw vertical grids(snap)
    //draw loop mark - sampleplayer's loop
    double loopStart=player.getLoopStartUGen().getValue();//static!
    double loopEnd=player.getLoopEndUGen().getValue();//static!
    //draw automations
    //draw cursor
  }
  public float timeToPos(double time) {
    return (float)((pos.right - pos.left) * (time / length) * scale - offsetX);
  }
  @Override
  public void update() {
    if (!player.isPaused() && autoscroll) {
      invalidate();
    }
  }
  public void cutSelection(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      player.pause(true);
      Sample cutSample=new Sample(1);//selection length
      //copy sample
      //implement
      setSample(cutSample);
      player.pause(false);
      invalidate();
      return false;
    });
  }
  public void setReverse(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      return false;
    });
  }
  public void setSnapGridPlus(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      return false;
    });
  }
  public void setSnapGridMinus(Button button) {
    button.setPressListener((MouseEvent e, int index) -> {
      return false;
    });
  }
  public void setToggleSnap(ToggleButton button) {
    button.setPressListener((MouseEvent e, int index) -> {
      snap=button.value;
      return false;
    });
  }
  public void setToggleAutomationMode(ToggleButton button) {
    button.setPressListener((MouseEvent e, int index) -> {
      automationMode=button.value;
      return false;
    });
  }
}
