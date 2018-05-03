package pw2.macro.test;
import pw2.macro.PwMacro;
import pw2.macro.PwMacroRun;

import java.io.PrintWriter;
public class Test {
  public static void main(String[] args) throws Exception {
    new Test().run();
  }
  public void run() throws Exception {
    PwMacroRun run=new PwMacroRun();
    PrintWriter out=new PrintWriter(System.out);
    run.run(MacroTest.class, "NewMacro", "super.setup();println(\"Hello, world\");color a=1;println(a);", this, out, "C:\\Users\\user\\Documents\\[Projects]\\PositionWriter\\_library\\PwMacro\\bin");
  }
  public void println(Object o) {
    System.out.println(o);
  }
  public static class MacroTest extends PwMacro {
    Test t;
    //you can do no constructor
    @Override
    public void initialize(Object param) {
      t=(Test)param;
    }
    public void println(Object o) {
      t.println(o);
    }
  }
}
