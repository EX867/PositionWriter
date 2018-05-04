package pw2.macro;
import processing_mode_java.preproc.PdePreprocessor;
public class PwMacroPreproc {
  //process string or ast
  //
  //in pw2, call addHeaderToSource(PW2_0.Macro.class,"testMacro",source)
  public static String addHeaderToSource(Class<? extends PwMacro> extendClass, String macroName, String source, PdePreprocessor.Mode mode) {
    //importClass is seperated because importing no package class fails.
    if (mode == PdePreprocessor.Mode.STATIC) {
      return "public class " + macroName + " extends " + extendClass.getCanonicalName() + " {" +
          "  void setup(){" +
          source +
          "}}";
    } else {//including java and active
      return "public class " + macroName + " extends " + extendClass.getCanonicalName() + " {" +
          source +
          "}";
    }
  }
}
