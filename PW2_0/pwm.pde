import antlr.Token;
import java.io.ByteArrayInputStream;
import java.io.PrintStream;
import pw2.macro.*;
public static class PW2_0Param {
  public PW2_0 sketch;
  public PrintStream console;
  public PW2_0Param(PW2_0 sketch_, PrintStream console_) {
    sketch=sketch_;
    console=console_;
  }
}
public static class PwMacroApi extends PwMacro {
  public PW2_0 __parent;//you can use it...
  public PrintStream __console;
  //you can do no constructor
  @Override
    public final void initialize(Object param) {
    __parent=((PW2_0Param)param).sketch;
    __console=((PW2_0Param)param).console;
  }
  public void println(Object o) {
    __console.println(o);
  }
}
/*
kyui.element.Button b;
kyui.core.KyUI.get("m_lin1").addChild(b=new kyui.element.Button("asdf"));
b.setPressListener((e,i)->{
  println(__parent.frameCount+" button pressed.");
  return false;
});
kyui.core.KyUI.changeLayout();
*/