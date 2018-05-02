package pw2.macro;
import java.util.function.*;
import java.util.ArrayList;
public class PwMacroPreproc {
  public String addHeaderToSource(String className, String macroName, String source) {//use .getTypeName() for className.
    return "import " + className + ";" +
        "import pw2.macro.PwMacro;" +
        "pubic class " + macroName + " extends PwMacro {" +
        className + " __parent" +
        source +
        "}";
  }
}
