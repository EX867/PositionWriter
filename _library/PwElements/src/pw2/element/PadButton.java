package pw2.element;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.editor.Attribute;
import kyui.util.ColorExt;
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
  public static final int MOVE=7;
  public static interface ButtonListener {
    public void accept(IntVector2 click, IntVector2 coord, int action);
  }
  public ButtonListener buttonListener=(IntVector2 click, IntVector2 coord, int action) -> {//must not be null.
  };//position,action
  @Attribute(type=Attribute.COLOR)
  public int fgColor;
  @Attribute(type=Attribute.COLOR)
  public int bgColor2;
  @Attribute
  public boolean selectable=true;
  @Attribute(setter="setX", getter="getX")
  public int X=8;
  @Attribute(setter="setY", getter="getY")
  public int Y=8;
  public void setX(int x) {
    resizePad(Math.max(1, x), size.y);
  }
  public int getX() {
    return size.x;
  }
  public void setY(int y) {
    resizePad(size.x, Math.max(1, y));
  }
  public int getY() {
    return size.y;
  }
  @Attribute
  public boolean lDragVisible=true;
  @Attribute
  public boolean rDragVisible=true;
  @Attribute
  public boolean alignTop=false;//for pw chain
  //temp vars
  public IntVector2 clickL=new IntVector2(0, 0);
  public IntVector2 clickR=new IntVector2(0, 0);
  public IntVector2 coord=new IntVector2(0, 0);
  public IntVector2 size=new IntVector2(1, 1);
  public IntVector2 selected=new IntVector2(0, 0);
  public int[][] display=null;
  public String[][] text=null;//readonly
  public PadButton(String s) {
    super(s);
    bgColor2=KyUI.Ref.color(127);
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
  public void displayControl(int[][] display_) {
    synchronized (this) {
      display=display_;
    }
  }
  public void textControl(String[][] text_) {
    text=text_;
  }
  public float getPadding(float interval) {
    return interval / 10;
  }
  @Override
  public void render(PGraphics g) {//use coord.
    float w=pos.right - pos.left;
    float h=pos.bottom - pos.top;
    float offsetX=pos.left;
    float offsetY=pos.top;
    float interval=1;
    if (w * size.y > h * size.x) {//width is longer than height
      interval=h / size.y;
      offsetX=(pos.left + pos.right - interval * size.x) / 2;
    } else {
      interval=w / size.x;
      offsetY=(pos.top + pos.bottom - interval * size.y) / 2;
    }
    if (alignTop) {
      offsetY=pos.top;
    }
    float padding2=getPadding(interval);
    //draw bg
    g.fill(bgColor2);
    pos.render(g);
    g.noStroke();
    fill(g, bgColor);
    g.rect(offsetX, offsetY, offsetX + interval * size.x, offsetY + interval * size.y);
    //draw mouse rectx2
    boolean coordInRange=!(coord.x < 0 || coord.y < 0 || coord.x >= size.x || coord.y >= size.y);
    if (entered && coordInRange) {
      if (size.x == 1 || size.y == 1) {
        if (pressedL) {
          g.fill(0, 192);
        } else {
          g.fill(0, 128);
        }
        g.rect(offsetX + coord.x * interval, offsetY + coord.y * interval, offsetX + coord.x * interval + interval, offsetY + coord.y * interval + interval);
      } else {
        if (pressedL) {
          g.fill(0, 96);
        } else {
          g.fill(0, 64);
        }
        g.rect(offsetX + coord.x * interval, offsetY, offsetX + coord.x * interval + interval, pos.bottom + pos.top - offsetY);
        g.rect(offsetX, offsetY + coord.y * interval, pos.right + pos.left - offsetX, offsetY + coord.y * interval + interval);
      }
    }
    //draw selected x2
    if (selectable /*&& !coord.equals(selected)*/ && !(selected.x < 0 || selected.y < 0 || selected.x >= size.x || selected.y >= size.y)) {
      g.fill(0, 64);
      g.rect(offsetX + selected.x * interval, offsetY + selected.y * interval, offsetX + selected.x * interval + interval, offsetY + selected.y * interval + interval);
    }
    //draw lines
    g.stroke(fgColor);
    g.strokeWeight(1);
    for (int a=1; a < size.x; a++) {
      g.line(offsetX + a * interval, offsetY, offsetX + a * interval, pos.bottom + pos.top - offsetY);
    }
    for (int a=1; a <= size.y; a++) {
      g.line(offsetX, offsetY + a * interval, pos.right + pos.left - offsetX, offsetY + a * interval);
    }
    //draw pad color
    g.noStroke();
    g.textSize(Math.max(1, padding2 * 2));
    g.textLeading(Math.max(1, padding2 * 2));
    synchronized (this) {
      for (int a=0; a < display.length; a++) {
        for (int b=0; b < display[a].length; b++) {
          fill(g, display[a][b]);
          g.rect(offsetX + a * interval + padding2, offsetY + b * interval + padding2, offsetX + a * interval + interval - padding2, offsetY + b * interval + interval - padding2);
          if (!text[a][b].isEmpty()) {
            g.fill(fgColor);
            g.text(text[a][b], offsetX + (a + 0.5F) * interval, offsetY + (b + 0.5F) * interval);
          }
        }
      }
    }
    if (selectable && !(selected.x < 0 || selected.y < 0 || selected.x >= size.x || selected.y >= size.y)) {
      ColorExt.drawIndicator(g, offsetX + selected.x * interval + 6, offsetY + selected.y * interval + 6, offsetX + selected.x * interval + interval - 6, offsetY + selected.y * interval + interval - 6, 4);
    }
    g.noFill();
    if (pressedR && rDragVisible && !coord.equals(clickR) && coordInRange && !(clickR.x < 0 || clickR.y < 0 || clickR.x >= size.x || clickR.y >= size.y)) {
      g.strokeWeight(4);
      g.stroke(0, 0, 200);
      g.rect(offsetX + interval * (clickR.x + 0.5F), offsetY + interval * (clickR.y + 0.5F), offsetX + interval * (coord.x + 0.5F), offsetY + interval * (coord.y + 0.5F));
    }
    if (pressedL && lDragVisible && !coord.equals(clickL) && coordInRange && !(clickL.x < 0 || clickL.y < 0 || clickL.x >= size.x || clickL.y >= size.y)) {
      g.strokeWeight(4);
      g.stroke(200, 0, 0);
      g.rect(offsetX + interval * (clickL.x + 0.5F) + 1, offsetY + interval * (clickL.y + 0.5F) + 1, offsetX + interval * (coord.x + 0.5F) + 1, offsetY + interval * (coord.y + 0.5F) + 1);
    }
    g.noStroke();
  }
  public IntVector2 getCoord() {
    IntVector2 coord=new IntVector2(-1, -1);
    KyUI.checkOverlayCondition((Element e, Vector2 mouse) -> {
      if (e == this) {
        float w=PadButton.this.pos.right - PadButton.this.pos.left;
        float h=pos.bottom - pos.top;
        float offsetX=pos.left;
        float offsetY=pos.top;
        float interval=1;
        if (w * size.y > h * size.x) {//width is longer than height
          interval=h / size.y;
          offsetX=(pos.left + pos.right - interval * size.x) / 2;
        } else {
          interval=w / size.x;
          offsetY=(pos.top + pos.bottom - interval * size.y) / 2;
        }
        if (alignTop) {
          offsetY=pos.top;
        }
        coord.set(PApplet.floor((mouse.x - offsetX) / interval), PApplet.floor((mouse.y - offsetY) / interval));
        return true;
      }
      return false;
    });
    if (coord.x < 0 || coord.y < 0 || coord.x >= size.x || coord.y >= size.y) {
      return null;
    }
    return coord;
  }
  @Override
  public boolean mouseEvent(MouseEvent e, int index) {
    float w=pos.right - pos.left;
    float h=pos.bottom - pos.top;
    float offsetX=pos.left;
    float offsetY=pos.top;
    float interval=1;
    Vector2 mouse=KyUI.mouseGlobal.getLast();
    if (w * size.y > h * size.x) {//width is longer than height
      interval=h / size.y;
      offsetX=(pos.left + pos.right - interval * size.x) / 2;
    } else {
      interval=w / size.x;
      offsetY=(pos.top + pos.bottom - interval * size.y) / 2;
    }
    if (alignTop) {
      offsetY=pos.top;
    }
    if (e.getAction() == MouseEvent.PRESS) {
      if (e.getButton() == PApplet.LEFT) {
        clickL.set(coord);
      }
      if (e.getButton() == PApplet.RIGHT) {
        clickR.set(coord);
      }
    }
    coord.set(PApplet.floor((mouse.x - offsetX) / interval), PApplet.floor((mouse.y - offsetY) / interval));
    if (coord.x < 0 || coord.y < 0 || coord.x >= size.x || coord.y >= size.y) {
      return true;
    }
    if (e.getAction() == MouseEvent.PRESS) {
      if (e.getButton() == PApplet.LEFT) {
        buttonListener.accept(clickL, coord, PRESS_L);
      }
      if (e.getButton() == PApplet.RIGHT) {
        buttonListener.accept(clickR, coord, PRESS_R);
      }
      invalidate();
      return false;
    } else if (e.getAction() == MouseEvent.DRAG) {
      if (pressedL) {
        buttonListener.accept(clickL, coord, DRAG_L);
      }
      if (pressedR) {
        buttonListener.accept(clickR, coord, DRAG_R);
      }
      invalidate();
      return false;
    } else if (e.getAction() == MouseEvent.RELEASE) {
      if (selectable && (pressedL || pressedR)) {//onselect...add listener.
        selected.set(coord);
      }
      if (pressedL) {
        buttonListener.accept(clickL, coord, RELEASE_L);
      }
      if (pressedR) {
        buttonListener.accept(clickR, coord, RELEASE_R);
      }
      invalidate();
      return false;
    } else if (e.getAction() == MouseEvent.MOVE) {
      if (entered) {
        buttonListener.accept(coord, coord, MOVE);
        invalidate();
        return true;
      }
    }
    return true;
  }
}
