import java.util.ArrayList;
public class Primitives {
  public class Array<T> {//no java.lang.Array, it is generic array class for token replacement.
    final ArrayList<T> array;
    public Array(int length) {
      array=new ArrayList<T>();
      array.ensureCapacity(length);
      for (int a=0; a < length; a++) {
        array.add(null);
      }
    }
    public T get(int index) {
      return array.get(index);
    }
    public void set(int index, T val) {
      array.set(index, val);
    }
  }
  public Integer add(int a) {//for unary operators
    return a;
  }
  public Float add(float a) {
    return a;
  }
  public Long add(long a) {
    return a;
  }
  public Double add(double a) {
    return a;
  }
  public Integer add(int a, int b) {
    return a + b;
  }
  public Long add(long a, int b) {
    return a + b;
  }
  public Long add(int a, long b) {
    return a + b;
  }
  public Long add(long a, long b) {
    return a + b;
  }
  public Float add(float a, int b) {
    return a + b;
  }
  public Float add(int a, float b) {
    return a + b;
  }
  public Float add(float a, float b) {
    return a + b;
  }
  public Float add(long a, float b) {
    return a + b;
  }
  public Float add(float a, long b) {
    return a + b;
  }
  public Double add(int a, double b) {
    return a + b;
  }
  public Double add(double a, int b) {
    return a + b;
  }
  public Double add(long a, double b) {
    return a + b;
  }
  public Double add(double a, long b) {
    return a + b;
  }
  public Double add(float a, double b) {
    return a + b;
  }
  public Double add(double a, float b) {
    return a + b;
  }
  public Double add(double a, double b) {
    return a + b;
  }
  public String add(String a, Object b) {
    return a + b;
  }
  public String add(Object a, String b) {
    return a + b;
  }
  //sub
  public Integer sub(int a, int b) {
    return a - b;
  }
  public Long sub(long a, int b) {
    return a - b;
  }
  public Long sub(int a, long b) {
    return a - b;
  }
  public Long sub(long a, long b) {
    return a - b;
  }
  public Float sub(float a, int b) {
    return a - b;
  }
  public Float sub(int a, float b) {
    return a - b;
  }
  public Float sub(float a, float b) {
    return a - b;
  }
  public Float sub(long a, float b) {
    return a - b;
  }
  public Float sub(float a, long b) {
    return a - b;
  }
  public Double sub(int a, double b) {
    return a - b;
  }
  public Double sub(double a, int b) {
    return a - b;
  }
  public Double sub(long a, double b) {
    return a - b;
  }
  public Double sub(double a, long b) {
    return a - b;
  }
  public Double sub(float a, double b) {
    return a - b;
  }
  public Double sub(double a, float b) {
    return a - b;
  }
  public Double sub(double a, double b) {
    return a - b;
  }
  public Integer sub(int a) {//for unary operators
    return -a;
  }
  public Float sub(float a) {
    return -a;
  }
  public Long sub(long a) {
    return -a;
  }
  public Double sub(double a) {
    return -a;
  }
  //mult
  public Integer mult(int a, int b) {
    return a * b;
  }
  public Long mult(long a, int b) {
    return a * b;
  }
  public Long mult(int a, long b) {
    return a * b;
  }
  public Long mult(long a, long b) {
    return a * b;
  }
  public Float mult(float a, int b) {
    return a * b;
  }
  public Float mult(int a, float b) {
    return a * b;
  }
  public Float mult(float a, float b) {
    return a * b;
  }
  public Float mult(long a, float b) {
    return a * b;
  }
  public Float mult(float a, long b) {
    return a * b;
  }
  public Double mult(int a, double b) {
    return a * b;
  }
  public Double mult(double a, int b) {
    return a * b;
  }
  public Double mult(long a, double b) {
    return a * b;
  }
  public Double mult(double a, long b) {
    return a * b;
  }
  public Double mult(float a, double b) {
    return a * b;
  }
  public Double mult(double a, float b) {
    return a * b;
  }
  public Double mult(double a, double b) {
    return a * b;
  }
  //div
  public Integer div(int a, int b) {
    return a / b;
  }
  public Long div(long a, int b) {
    return a / b;
  }
  public Long div(int a, long b) {
    return a / b;
  }
  public Long div(long a, long b) {
    return a / b;
  }
  public Float div(float a, int b) {
    return a / b;
  }
  public Float div(int a, float b) {
    return a / b;
  }
  public Float div(float a, float b) {
    return a / b;
  }
  public Float div(long a, float b) {
    return a / b;
  }
  public Float div(float a, long b) {
    return a / b;
  }
  public Double div(int a, double b) {
    return a / b;
  }
  public Double div(double a, int b) {
    return a / b;
  }
  public Double div(long a, double b) {
    return a / b;
  }
  public Double div(double a, long b) {
    return a / b;
  }
  public Double div(float a, double b) {
    return a / b;
  }
  public Double div(double a, float b) {
    return a / b;
  }
  public Double div(double a, double b) {
    return a / b;
  }
  //remainder
  public Integer remainder(int a, int b) {
    return a % b;
  }
  public Long remainder(long a, int b) {
    return a % b;
  }
  public Long remainder(int a, long b) {
    return a % b;
  }
  public Long remainder(long a, long b) {
    return a % b;
  }
  public Float remainder(float a, int b) {
    return a % b;
  }
  public Float remainder(int a, float b) {
    return a % b;
  }
  public Float remainder(float a, float b) {
    return a % b;
  }
  public Float remainder(long a, float b) {
    return a % b;
  }
  public Float remainder(float a, long b) {
    return a % b;
  }
  public Double remainder(int a, double b) {
    return a % b;
  }
  public Double remainder(double a, int b) {
    return a % b;
  }
  public Double remainder(long a, double b) {
    return a % b;
  }
  public Double remainder(double a, long b) {
    return a % b;
  }
  public Double remainder(float a, double b) {
    return a % b;
  }
  public Double remainder(double a, float b) {
    return a % b;
  }
  public Double remainder(double a, double b) {
    return a % b;
  }
  //less
  public Boolean lt(int a, int b) {
    return a < b;
  }
  public Boolean lt(long a, int b) {
    return a < b;
  }
  public Boolean lt(int a, long b) {
    return a < b;
  }
  public Boolean lt(long a, long b) {
    return a < b;
  }
  public Boolean lt(float a, int b) {
    return a < b;
  }
  public Boolean lt(int a, float b) {
    return a < b;
  }
  public Boolean lt(float a, float b) {
    return a < b;
  }
  public Boolean lt(long a, float b) {
    return a < b;
  }
  public Boolean lt(float a, long b) {
    return a < b;
  }
  public Boolean lt(int a, double b) {
    return a < b;
  }
  public Boolean lt(double a, int b) {
    return a < b;
  }
  public Boolean lt(long a, double b) {
    return a < b;
  }
  public Boolean lt(double a, long b) {
    return a < b;
  }
  public Boolean lt(float a, double b) {
    return a < b;
  }
  public Boolean lt(double a, float b) {
    return a < b;
  }
  public Boolean lt(double a, double b) {
    return a < b;
  }
  //lessEq
  public Boolean ltEq(int a, int b) {
    return a <= b;
  }
  public Boolean ltEq(long a, int b) {
    return a <= b;
  }
  public Boolean ltEq(int a, long b) {
    return a <= b;
  }
  public Boolean ltEq(long a, long b) {
    return a <= b;
  }
  public Boolean ltEq(float a, int b) {
    return a <= b;
  }
  public Boolean ltEq(int a, float b) {
    return a <= b;
  }
  public Boolean ltEq(float a, float b) {
    return a <= b;
  }
  public Boolean ltEq(long a, float b) {
    return a <= b;
  }
  public Boolean ltEq(float a, long b) {
    return a <= b;
  }
  public Boolean ltEq(int a, double b) {
    return a <= b;
  }
  public Boolean ltEq(double a, int b) {
    return a <= b;
  }
  public Boolean ltEq(long a, double b) {
    return a <= b;
  }
  public Boolean ltEq(double a, long b) {
    return a <= b;
  }
  public Boolean ltEq(float a, double b) {
    return a <= b;
  }
  public Boolean ltEq(double a, float b) {
    return a <= b;
  }
  public Boolean ltEq(double a, double b) {
    return a <= b;
  }
  //greater
  public Boolean gt(int a, int b) {
    return a > b;
  }
  public Boolean gt(long a, int b) {
    return a > b;
  }
  public Boolean gt(int a, long b) {
    return a > b;
  }
  public Boolean gt(long a, long b) {
    return a > b;
  }
  public Boolean gt(float a, int b) {
    return a > b;
  }
  public Boolean gt(int a, float b) {
    return a > b;
  }
  public Boolean gt(float a, float b) {
    return a > b;
  }
  public Boolean gt(long a, float b) {
    return a > b;
  }
  public Boolean gt(float a, long b) {
    return a > b;
  }
  public Boolean gt(int a, double b) {
    return a > b;
  }
  public Boolean gt(double a, int b) {
    return a > b;
  }
  public Boolean gt(long a, double b) {
    return a > b;
  }
  public Boolean gt(double a, long b) {
    return a > b;
  }
  public Boolean gt(float a, double b) {
    return a > b;
  }
  public Boolean gt(double a, float b) {
    return a > b;
  }
  public Boolean gt(double a, double b) {
    return a > b;
  }
  //gtEq
  public Boolean gtEq(int a, int b) {
    return a >= b;
  }
  public Boolean gtEq(long a, int b) {
    return a >= b;
  }
  public Boolean gtEq(int a, long b) {
    return a >= b;
  }
  public Boolean gtEq(long a, long b) {
    return a >= b;
  }
  public Boolean gtEq(float a, int b) {
    return a >= b;
  }
  public Boolean gtEq(int a, float b) {
    return a >= b;
  }
  public Boolean gtEq(float a, float b) {
    return a >= b;
  }
  public Boolean gtEq(long a, float b) {
    return a >= b;
  }
  public Boolean gtEq(float a, long b) {
    return a >= b;
  }
  public Boolean gtEq(int a, double b) {
    return a >= b;
  }
  public Boolean gtEq(double a, int b) {
    return a >= b;
  }
  public Boolean gtEq(long a, double b) {
    return a >= b;
  }
  public Boolean gtEq(double a, long b) {
    return a >= b;
  }
  public Boolean gtEq(float a, double b) {
    return a >= b;
  }
  public Boolean gtEq(double a, float b) {
    return a >= b;
  }
  public Boolean gtEq(double a, double b) {
    return a >= b;
  }
  //eq
  public Boolean eq(Object a, Object b) {
    return a == b;
  }
  //notEq
  public Boolean notEq(Object a, Object b) {
    return a != b;
  }
  //others
  public Boolean not(boolean a) {
    return !a;
  }
  public Boolean and(boolean a, boolean b) {
    return a && b;
  }
  public Boolean or(boolean a, boolean b) {
    return a || b;
  }
  public Boolean instanceOf(Object a, Class b) {
    return b.isAssignableFrom(a.getClass());
  }
}
