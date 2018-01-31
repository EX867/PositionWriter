package pw2.element;
import kyui.element.Button;
public class VelocityButton extends PadButton {//ADD>>
  public VelocityButton(String s) {
    super(s);
    selectable=true;
    lDragVisible=false;
    lDragVisible=false;
  }
  @Override
  public float getPadding(float interval) {
    return 0;
  }
}
