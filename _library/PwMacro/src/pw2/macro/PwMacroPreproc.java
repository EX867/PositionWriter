package pw2.macro;
import processing_mode_java.preproc.PdePreprocessor;
public class PwMacroPreproc {
  //process string or ast
  //
  //in pw2, call addHeaderToSource(PW2_0.Macro.class,"testMacro",source)
  public static String addHeaderToSource(Class<? extends PwMacro> extendClass, String macroName, String source,PdePreprocessor.Mode mode) {
    if(mode== PdePreprocessor.Mode.STATIC) {
      return "import " + extendClass.getCanonicalName() + ";" +
          "public class " + macroName + " extends " + extendClass.getCanonicalName() + " {" +
          "  void setup(){"+
          source +
          "}}";
    }else{//including java and active
      return "import " + extendClass.getCanonicalName() + ";" +
          "public class " + macroName + " extends " + extendClass.getCanonicalName() + " {" +
          source +
          "}";
    }
  }
}
