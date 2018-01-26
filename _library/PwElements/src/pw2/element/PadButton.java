package pw2.element;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.editor.Attribute;
import kyui.util.Vector2;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.event.MouseEvent;
import pw2.element.IntVector2;

import java.util.function.BiConsumer;
public class PadButton extends Element {
  public static final int PRESS_L=1;
  public static final int DRAG_L=2;
  public static final int RELEASE_L=3;
  public static final int PRESS_R=4;
  public static final int DRAG_R=5;
  public static final int RELEASE_R=6;
  public static final int DRAG=7;
  public BiConsumer<IntVector2, Integer> buttonListener=(IntVector2 v, Integer a) -> {//must not be null.
  };//position,action
  @Attribute(type=Attribute.COLOR)
  public int fgColor;
  @Attribute
  public boolean selectable=true;
  //temp vars
  public IntVector2 clickL=new IntVector2(-1, -1);
  public IntVector2 clickR=new IntVector2(-1, -1);
  public IntVector2 coord=new IntVector2(-1, -1);
  public IntVector2 size=new IntVector2(1, 1);
  public IntVector2 selected=new IntVector2(1, 1);
  public int[][] display=null;
  public String[][] text=null;//readonly
  public PadButton(String s) {
    super(s);
    bgColor=KyUI.Ref.color(50);
    fgColor=KyUI.Ref.color(127);
    resizePad(8, 8);
  }
  public void resizePad(int x, int y) {
    size.set(x, y);
    display=new int[size.x][size.y];
    text=new String[size.x][size.y];
    for (int a=0; a < size.x; a++) {
      for (int b=0; b < size.y; b++) {
        display[a][b]=0;
        text[a][b]="";
      }
    }
  }
  public void asyncDisplayControl(int[][] display_) {
    synchronized (this) {
      display=display_;
    }
  }
  public void textControl(String[][] text_) {
    text=text_;
  }
  @Override
  public void render(PGraphics g) {//use coord.
    float w=pos.right - pos.left;
    float h=pos.bottom - pos.top;
    float offsetX=0;
    float offsetY=0;
    float interval=1;
    float padding2=interval / 5;
    if (w * size.y > h * size.x) {//width is longer than height
      interval=h / size.y;
      offsetX=(pos.left + pos.right - interval * size.x) / 2;
    } else {
      interval=w / size.x;
      offsetY=(pos.top + pos.bottom - interval * size.y) / 2;
    }
    //draw bg
    g.noStroke();
    fill(g, bgColor);
    g.rect(offsetX, offsetY, offsetX + interval * size.x, offsetY + interval * size.y);
    //draw mouse rectx2
    if (entered && !(coord.x < 0 || coord.y < 0 || coord.x >= size.x || coord.y >= size.y)) {
      fill(g, 0x32000000);//64...
      g.rect(offsetX + selected.x * interval, pos.top, offsetX + selected.x * interval + interval, pos.bottom);
      g.rect(pos.left, offsetY + selected.y * interval, pos.right, offsetY + selected.y * interval + interval);
    }
    //draw selected x2
    if (selectable /*&& !coord.equals(selected)*/ && !(selected.x < 0 || selected.y < 0 || selected.x >= size.x || selected.y >= size.y)) {
      fill(g, 0x32000000);
      g.rect(offsetX + selected.x * interval, offsetY + selected.y * interval, offsetX + selected.x * interval + interval, offsetY + selected.y * interval + interval);
    }
    //draw lines
    g.stroke(fgColor);
    g.strokeWeight(1);
    for (int a=1; a < size.x; a++) {
      g.line(offsetX + a * interval, pos.top, offsetX + a * interval, pos.bottom);
    }
    for (int a=1; a <= size.y; a++) {
      g.line(pos.left, offsetY + a * interval, pos.right, offsetY + a * interval);
    }
    //draw pad color
    g.noStroke();
    g.textSize(Math.min(1, padding2));
    synchronized (this) {
      for (int a=0; a < size.x; a++) {
        for (int b=0; b < size.y; b++) {
          g.fill(display[a][b]);
          g.rect(offsetX + coord.x * interval + padding2, offsetY + coord.y * interval + padding2, offsetX + coord.x * interval + interval - padding2, offsetY + coord.y * interval + interval - padding2);
          if (!text[a][b].isEmpty()) {
            g.text(text[a][b], offsetX + (coord.x + 0.5F) * interval, offsetY + (coord.y + 0.5F) * interval);
          }
        }
      }
    }
    if (selectable && !(selected.x < 0 || selected.y < 0 || selected.x >= size.x || selected.y >= size.y)) {
      drawIndicator(g, offsetX + selected.x * interval, offsetY + selected.y * interval, offsetX + selected.x * interval + interval, offsetY + selected.y * interval + interval, 4);
    }
  }
  @Override
  public boolean mouseEvent(MouseEvent e, int index) {
    float w=pos.right - pos.left;
    float h=pos.bottom - pos.top;
    float offsetX=0;
    float offsetY=0;
    float interval=1;
    Vector2 mouse=KyUI.mouseGlobal.getLast();
    if (w * size.y > h * size.x) {//width is longer than height
      interval=h / size.y;
      offsetX=(pos.left + pos.right - interval * size.x) / 2;
    } else {
      interval=w / size.x;
      offsetY=(pos.top + pos.bottom - interval * size.y) / 2;
    }
    coord.set(PApplet.floor((mouse.x - offsetX) / interval), PApplet.floor((mouse.y - offsetY) / interval));
    if (coord.x < 0 || coord.y < 0 || coord.x >= size.x || coord.y >= size.y) {
      return true;
    }
    if (e.getAction() == MouseEvent.PRESS) {
      if (e.getButton() == PApplet.LEFT) {
        clickL.set(coord);
        buttonListener.accept(coord, PRESS_L);
      }
      if (e.getButton() == PApplet.RIGHT) {
        clickR.set(coord);
        buttonListener.accept(coord, PRESS_R);
      }
      invalidate();
      return false;
    } else if (e.getAction() == MouseEvent.DRAG) {
      if (pressedL) {
        buttonListener.accept(coord, DRAG_L);
      }
      if (pressedR) {
        buttonListener.accept(coord, DRAG_R);
      }
      invalidate();
      return false;
    } else if (e.getAction() == MouseEvent.RELEASE) {
      if (pressedL) {
        buttonListener.accept(coord, RELEASE_L);
      }
      if (pressedR) {
        buttonListener.accept(coord, RELEASE_R);
      }
      invalidate();
      return false;
    } else if (e.getAction() == MouseEvent.MOVE) {
      if (entered) {
        buttonListener.accept(coord, RELEASE_L);
        invalidate();
        return true;
      }
    }
    return true;
  }
  void drawIndicator(PGraphics g, float x, float y, float w, float h, int thick) {
    g.noFill();
    g.stroke(255.0F);
    g.strokeWeight(thick * 2);
    g.rect(x, y, w, h);
    g.stroke(0.0F);
    g.strokeWeight(thick);
    g.rect(x, y, w + thick, h + thick);
    g.rect(x, y, w - thick, h - thick);
    g.noStroke();
  }
}
