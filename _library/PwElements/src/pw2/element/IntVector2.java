package pw2.element;
public class IntVector2 {
  public static final IntVector2 zero=new IntVector2(0, 0);
  public int x;
  public int y;
  public IntVector2() {
    x=0;
    y=0;
  }
  public IntVector2(int x_, int y_) {
    x=x_;
    y=y_;
  }
  public void set(int x_, int y_) {
    x=x_;
    y=y_;
  }
  public void set(IntVector2 v) {
    x=v.x;
    y=v.y;
  }
  @Override
  public boolean equals(Object o) {
    if (o instanceof IntVector2) {
      IntVector2 v=(IntVector2)o;
      return v.x == x && v.y == y;
    }
    return false;
  }
  @Override
  public int hashCode() {
    return x * 40009 + y;//can overflow
  }
}
