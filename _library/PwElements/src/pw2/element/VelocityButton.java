package pw2.element;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.editor.Attribute;
import kyui.event.EventListener;
import kyui.util.ColorExt;
import kyui.util.Vector2;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
public class VelocityButton extends Element {
  public static int HOLD_TIME=500;
  int[] cData=color_lp;
  IntVector2 size=new IntVector2(8, 16);
  public int selectedVelocity=0;
  @Attribute
  public boolean selectionVisible=true;
  //temp
  long lastClickTime;
  boolean hold=false;
  /*
  1 2 3 4...
  5 6 7 8...
  */
  public EventListener colorSelectListener;
  public VelocityButton(String s) {
    super(s);
    bgColor=0xFF323232;
  }
  public void setData(int[] data, int width) {
    cData=data;
    size.set(width, (data.length % width == 0) ? (data.length / width) : (data.length / width + 1));
  }
  @Override
  public void update() {
    if (System.currentTimeMillis() - lastClickTime > HOLD_TIME) {
      hold=true;
      invalidate();
    }
  }
  @Override
  public boolean mouseEvent(MouseEvent e, int index) {
    if (cData == null || !pressedL) {
      return true;
    }
    if (e.getAction() == MouseEvent.PRESS || e.getAction() == MouseEvent.DRAG || e.getAction() == MouseEvent.RELEASE) {
      if (e.getAction() == MouseEvent.PRESS) {
        lastClickTime=System.currentTimeMillis();
        hold=false;
      }
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
      Vector2 mouse=KyUI.mouseGlobal.getLast();
      int x=PApplet.floor((mouse.x - offsetX) / interval);
      int y=PApplet.floor((mouse.y - offsetY) / interval);
      int temp=y * size.x + x;
      if (temp >= 0 && temp < cData.length && x >= 0 && y >= 0 && x < size.x && y < size.y) {
        selectedVelocity=temp;
      }
      if (colorSelectListener != null) {
        colorSelectListener.onEvent(this);
      }
      invalidate();
      return false;
    }
    return true;
  }
  @Override
  public void keyEvent(KeyEvent e) {
    if (e.getAction() == KeyEvent.PRESS) {
      if (e.getKey() == PApplet.CODED) {
        if (e.getKeyCode() == PApplet.LEFT) {
          selectedVelocity--;
          if (selectedVelocity < 0) selectedVelocity=0;
        } else if (e.getKeyCode() == PApplet.RIGHT) {
          selectedVelocity++;
          if (selectedVelocity >= cData.length) selectedVelocity=cData.length - 1;
        } else if (e.getKeyCode() == PApplet.UP) {
          selectedVelocity-=8;
          if (selectedVelocity < 0) selectedVelocity=0;
        } else if (e.getKeyCode() == PApplet.DOWN) {
          selectedVelocity+=8;
          if (selectedVelocity >= cData.length) selectedVelocity=cData.length - 1;
        }
      }
    }
  }
  @Override
  public void render(PGraphics g) {
    if (cData == null) {
      super.render(g);
      g.textSize(15);
      g.fill(0);
      g.text("<NO DATA>", (pos.left + pos.right) / 2, (pos.top + pos.bottom) / 2);
    } else {
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
      g.textSize(15);//fixed?
      g.textAlign(PApplet.LEFT, PApplet.TOP);
      for (int a=0; a < cData.length; a++) {
        fill(g, cData[a]);
        int x=a % size.x;
        int y=a / size.x;
        g.rect(offsetX + interval * x, offsetY + interval * y, offsetX + interval * x + interval, offsetY + interval * y + interval);
        g.fill(0);
        g.text("" + a, offsetX + interval * x + 2, offsetY + interval * y + 2);
      }
      g.textAlign(PApplet.CENTER, PApplet.CENTER);
      if (pressedL) {
        if (hold) {
          g.fill(bgColor, 200);
          g.rect(offsetX, offsetY, offsetX + interval * size.x, offsetY + interval * size.y);
        }
        fill(g, cData[selectedVelocity]);
        g.rect(offsetX + interval * (selectedVelocity % size.x), offsetY + interval * (selectedVelocity / size.x), offsetX + interval * (selectedVelocity % size.x) + interval, offsetY + interval * (selectedVelocity / size.x) + interval);
      } else {
        if (selectionVisible) {
          ColorExt.drawIndicator(g, offsetX + interval * (selectedVelocity % size.x) + 5, offsetY + interval * (selectedVelocity / size.x) + 5, offsetX + interval * (selectedVelocity % size.x) + interval - 5, offsetY + interval * (selectedVelocity / size.x) + interval - 5, 4);
        }
      }
    }
  }
  public static int[] color_lp=new int[]{
      0xff000000,
      0xffbdbdbd,
      0xffeeeeee,
      0xfffafafa, //3
      0xfff8bbd0,
      0xffef5350, //5
      0xffe57373,
      0xffef9a9a,
      0xfffff3e0,
      0xffffa726,
      0xffffb960, //10
      0xffffcc80,
      0xffffe0b2,
      0xffffee58,
      0xfffff59d,
      0xfffff9c4,
      0xffdcedc8,
      0xff8bc34a, //17
      0xffaed581,
      0xffbfdf9f,
      0xff5ee2b0,
      0xff00ce3c,
      0xff00ba43,
      0xff119c3f,
      0xff57ecc1,
      0xff00e864,
      0xff00e05c,
      0xff00d545,
      0xff7afddd,
      0xff00e4c5,
      0xff00e0b2,
      0xff01eec6,
      0xff49efef,
      0xff00e7d8,
      0xff00e5d1,
      0xff01efde,
      0xff6addff,
      0xff00dafe,
      0xff01d6ff,
      0xff08acdc,
      0xff73cefe,
      0xff0d9bf7,
      0xff148de4,
      0xff2a77c9,
      0xff8693ff,
      0xff2196f3, //45
      0xff4668f6,
      0xff4153dc,
      0xffb095ff,
      0xff8453fd,
      0xff634acd,
      0xff5749c5,
      0xffffb7ff,
      0xffe863fb,
      0xffd655ed,
      0xffd14fe9,
      0xfffc99e3,
      0xffe736c2,
      0xffe52fbe,
      0xffe334b6,
      0xffed353e,
      0xffffa726, //61
      0xfff4df0b,
      0xff66bb6a,
      0xff5cd100, //64
      0xff00d29e,
      0xff2388ff,
      0xff3669fd,
      0xff00b4d0,
      0xff475cdc,
      0xffb2bbcd,
      0xff95a0b2,
      0xfff72737,
      0xffd2ea7b,
      0xffc8df10,
      0xff7fe422,
      0xff00c931,
      0xff00d7a6,
      0xff00d8fc,
      0xff0b9bfc,
      0xff585cf5,
      0xffac59f0,
      0xffd980dc,
      0xffb8814a,
      0xffff9800,
      0xffabdf22,
      0xff9ee154,
      0xff66bb6a, //87
      0xff3bda47,
      0xff6fdeb9,
      0xff27dbda,
      0xff9cc8fd,
      0xff79b8f7,
      0xffafafef,
      0xffd580eb,
      0xfff74fca,
      0xffea8a1f,
      0xffdbdb08,
      0xff9cd60d,
      0xfff3d335,
      0xffc8af41,
      0xff00ca69,
      0xff24d2b0,
      0xff757ebe,
      0xff5388db,
      0xffe5c5a6,
      0xffe93b3b,
      0xfff9a2a1,
      0xffed9c65,
      0xffe1ca72,
      0xffb8da78,
      0xff98d52c,
      0xff626cbd,
      0xffcac8a0,
      0xff90d4c2,
      0xffceddfe,
      0xffbeccf7,
      0xffa3b1be,
      0xffb8c0d2,
      0xffd2e2f8,
      0xfffe1624,
      0xffcd2724,
      0xff9ccc65, //122
      0xff009c1b,
      0xffffff00, //124
      0xffbeb212,
      0xfff5d01d, //126
      0xffe37829,
  };
}