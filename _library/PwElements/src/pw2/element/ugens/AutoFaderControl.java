package pw2.element.ugens;
import kyui.element.AlterLinearLayout;
import kyui.element.Button;
import kyui.element.DivisionLayout;
import kyui.element.TextBox;
import pw2.beads.AutoFaderW;
import pw2.element.Knob;
import pw2.element.UGenViewer;
import pw2.element.WavEditor;
public class AutoFaderControl extends UGenViewer {
  //views
  protected Knob preCount;
  protected Knob postCount;
  protected TextBox path;
  protected Button export;
  protected Button previous;
  protected Button center;
  protected Button next;
  protected WavEditor view;
  //
  protected DivisionLayout layout;
  protected DivisionLayout dvl;
  protected DivisionLayout dvlu;
  protected DivisionLayout dvld;
  protected DivisionLayout dvr;
  protected AlterLinearLayout dv;
  //
  public AutoFaderW fader;
  public AutoFaderControl(String name) {
    super(name);
  }
}
