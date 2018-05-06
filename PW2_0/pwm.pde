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
// default presets :
// - mc converter with gui
// - remove unitor commands
//- api : led utils
public static class PwMacroApi extends PwMacro {
  protected PW2_0 __parent;//you can use it...
  protected PrintStream __console;
  //you can do no constructor
  @Override
    public final void initialize(Object param) {
    __parent=((PW2_0Param)param).sketch;
    __console=((PW2_0Param)param).console;
  }
  public void println(Object o) {
    __console.println(o);
  }
  public void print(Object o) {
    __console.print(o);
  }
  public void send(MidiDevice device, byte note, byte vel) {
    //device.sendMessage();
  }
}