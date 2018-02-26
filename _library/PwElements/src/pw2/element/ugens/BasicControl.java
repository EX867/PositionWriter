package pw2.element.ugens;
import beads.Gain;
import beads.Panner;
import processing.core.PApplet;
import processing.core.PGraphics;
import pw2.element.Knob;
import pw2.element.UGenViewer;
public class BasicControl extends UGenViewer {
  public Knob gainControl;
  public Knob panControl;
  public Gain gain;
  //public Panner panner;
  //
  public BasicControl(String s) {
    super(s);
  }
}
