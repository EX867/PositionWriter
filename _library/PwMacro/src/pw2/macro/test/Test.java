package pw2.macro.test;
import pw2.macro.PwMacro;
import pw2.macro.PwMacroRun;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.PrintWriter;
public class Test {
  public static void main(String[] args) throws Exception {
    new Test().run();
  }
  public void run() throws Exception {
    PrintWriter out = new PrintWriter(new PrintStream(new OutputStream() {
      @Override
      public void write(int b) throws IOException {
        System.out.print((char)b);
      }
    }));
    //PwMacroRun.run(MacroTest.class, "NewMacro", "import pw2.macro.test.Test;super.setup();println(\"Hello, world\");color a=1;println(a);", this, out, "C:\\Users\\user\\Documents\\PositionWriter\\temp\\pwmacro", new String[]{getClassPath()});
  }
  public void println(Object o) {
    System.out.println(o);
  }
  public static class MacroTest extends PwMacro {
    Test t;
    //you can do no constructor
    @Override
    public void initialize(Object param) {
      t = (Test)param;
    }
    @Override public void exit() {
    }
    public void println(Object o) {
      t.println(o);
    }
  }
  String getClassPath() {
    ClassLoader loader = this.getClass().getClassLoader();
    return loader.getResource(this.getClass().getTypeName() + ".class").getFile();
  }
}
