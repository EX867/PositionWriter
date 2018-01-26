package com.karnos.commandscript.test;
import com.karnos.commandscript.ConsoleEdit;
import kyui.core.Attributes;
import kyui.core.KyUI;
import kyui.element.DivisionLayout;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
public class Test2 extends PApplet {
  public static void main(String[] args) {
    PApplet.main("com.karnos.commandscript.test.Test2");
  }
  public void settings() {
    size(500, 500);
  }
  public void setup() {
    KyUI.start(this);
    ConsoleEdit edit=new ConsoleEdit("edit");
    DivisionLayout layout=new DivisionLayout("layout");
    layout.value=24;
    layout.setPosition(new Rect(0, 0, 500, 500));
    layout.rotation=Attributes.Rotation.RIGHT;
    layout.addChild(edit);
    layout.addChild(edit.getSlider());
    KyUI.add(layout);
    KyUI.changeLayout();
  }
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
