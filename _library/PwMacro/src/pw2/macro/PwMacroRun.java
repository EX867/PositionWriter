package pw2.macro;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.core.compiler.IProblem;
import org.eclipse.jdt.core.dom.AST;
import org.eclipse.jdt.core.dom.ASTParser;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.jdt.internal.compiler.IProblemFactory;
import org.eclipse.jdt.internal.compiler.batch.Main;
import org.eclipse.jdt.internal.compiler.lookup.ProblemBinding;
import org.eclipse.jdt.internal.compiler.problem.ProblemReporter;
import processing.app.Util;
import processing.core.PApplet;
import processing_mode_java.AutoFormat;
import processing_mode_java.pdex.SourceUtils;
import processing_mode_java.TextTransform;
import processing_mode_java.preproc.PdePreprocessor;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.security.CodeSource;
import java.security.ProtectionDomain;
import java.util.*;
public class PwMacroRun {
  AutoFormat formatter;
  static ASTParser parser=ASTParser.newParser(AST.JLS8);
  IProgressMonitor a;
  public PwMacroRun() {
    formatter=new AutoFormat();
  }
  public String autoFormat(String source) {
    return formatter.format(source);
  }
  public static void run(Class<? extends PwMacro> extendClass, String macroName, String source,//generation
                         Object param, PrintWriter logger,//runtime
                         String buildPath/*, String libraryPath*/) throws Exception {//for now, log and err is same.
    //
    // 0. preprocess it.
    //
    PdePreprocessor.Mode sketchMode=PdePreprocessor.parseMode(SourceUtils.scrubCommentsAndStrings(source));
    source=PwMacroPreproc.addHeaderToSource(extendClass, macroName, source, sketchMode);
    //
    // get classpaths from code folder
    //
    ArrayList<String> classPathArray_=new ArrayList<>();
    //classPathArray_.add(joinPath(buildPath, "bin"));
    classPathArray_.add(new File("bin\\production\\PwMacro").getAbsolutePath());//pass positionwriter classpath.
    //
    //    File[] codeFolder=new File(libraryPath).listFiles(); //want libraries? no no for now
    //    for(File f : codeFolder){
    //      classPathArray_.add(f.getAbsolutePath());
    //    }
    //
    String[] classPathArray=classPathArray_.toArray(new String[]{});
    //
    // build ast
    //
    // Transform code to parsable state
    // Create intermediate AST for advanced preprocessing
    CompilationUnit parsableCU=makeAST(parser, source.toCharArray(), COMPILER_OPTIONS);
    //
    // do advanced transforms which operate on AST and get compilable source
    String compilableStage=new TextTransform(source).addAll(SourceUtils.preprocessAST(parsableCU)).apply();
    char[] compilableStageChars=compilableStage.toCharArray();
    //
    // Create compilable AST to get syntax problems
    CompilationUnit compilableCU=makeAST(parser, compilableStageChars, COMPILER_OPTIONS);
    //
    // Get syntax problems from compilable AST
    boolean hasSyntaxErrors=Arrays.stream(compilableCU.getProblems()).anyMatch(IProblem::isError);
    //
    // Generate bindings after getting problems - avoids
    // 'missing type' errors when there are syntax problems
    //
    if (hasSyntaxErrors) {//error1
    }
    //
    CompilationUnit bindingsCU=makeASTWithBindings(parser, compilableStageChars, COMPILER_OPTIONS, macroName, classPathArray);
    //
    // Get compilation problems
    boolean hasCompilationErrors=Arrays.asList(bindingsCU.getProblems()).stream().anyMatch(IProblem::isError);
    //
    //    bindingsProblems.stream().forEach((IProblem problem) -> {
    //      logger.println("Compile problem : "+problem.getMessage());
    //    });
    //
    if (hasCompilationErrors) {//error2
    }
    //
    // Update builder
    boolean hasError=hasSyntaxErrors || hasCompilationErrors;//merge
    String javaCode=compilableStage;
    CompilationUnit compilationUnit=bindingsCU;
    writeFile(joinPath(buildPath, "src/" + macroName + ".java"), javaCode);
    //
    //1. compile it to one jar (with library references).
    //
    String classPath="";//???
    for (int a=0; a < classPathArray.length; a++) {
      classPath+=classPathArray[a] + ";";//space chars???
    }
    ArrayList<String> command_=new ArrayList<>();
    command_.add("-g");
    command_.add("-Xemacs");
    command_.add("-source");
    command_.add("1.8");
    command_.add("-target");
    command_.add("1.8");
    command_.add("-classpath");
    command_.add(classPath);
    command_.add("-nowarn");
    command_.add("-d");
    command_.add(joinPath(buildPath, "bin"));
    String[] sourceFiles=Util.listFiles(new File(joinPath(buildPath, "src")), false, ".java");
    for (String s : sourceFiles) {
      command_.add(s);
    }
    String[] command=(String[])command_.toArray(new String[]{});
    //processing.core.PApplet.println(command);
    //2. load it. and also load dependencies.
    boolean success=Main.compile(command, logger, logger, null);
    File classPathFile=new File("C:\\Users\\user\\Documents\\[Projects]\\PositionWriter\\_library\\PwMacro\\bin\\bin");
    if (!classPathFile.isDirectory()) {
      System.err.println("PwMacroRun - failed to locate build path (bin folder)");
      return;
    }
    URLClassLoader loader=URLClassLoader.newInstance(new URL[]{classPathFile.toURI().toURL()}, PwMacro.class.getClassLoader());
    //load code folder jars to new classloader here??
    //4. run initialize
    try {
      Class<? extends PwMacro> c=(Class)Class.forName(macroName, true, loader);//must no ClassCastException here!!
      PwMacro macro=c.getConstructor().newInstance();
      //5. run setup
      macro.initialize(param);
      macro.setup();
      loader.close();///do this on x button (or macro end) in positionwriter.
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
      System.err.println("generated macro class not found.");
      return;
    }
  }
  static private final Map<String, String> COMPILER_OPTIONS;
  static {//copied from processing.mode.java.pdex.PreProcessingService
    Map<String, String> compilerOptions=new HashMap<>();
    JavaCore.setComplianceOptions(JavaCore.VERSION_1_8, compilerOptions);
    // See http://help.eclipse.org/mars/index.jsp?topic=%2Forg.eclipse.jdt.doc.isv%2Fguide%2Fjdt_api_options.htm&anchor=compiler
    final String[] generate={
        JavaCore.COMPILER_LINE_NUMBER_ATTR,
        JavaCore.COMPILER_SOURCE_FILE_ATTR
    };
    final String[] ignore={
        JavaCore.COMPILER_PB_UNUSED_IMPORT,
        JavaCore.COMPILER_PB_MISSING_SERIAL_VERSION,
        JavaCore.COMPILER_PB_RAW_TYPE_REFERENCE,
        JavaCore.COMPILER_PB_REDUNDANT_TYPE_ARGUMENTS,
        JavaCore.COMPILER_PB_UNCHECKED_TYPE_OPERATION
    };
    final String[] warn={
        JavaCore.COMPILER_PB_NO_EFFECT_ASSIGNMENT,
        JavaCore.COMPILER_PB_NULL_REFERENCE,
        JavaCore.COMPILER_PB_POTENTIAL_NULL_REFERENCE,
        JavaCore.COMPILER_PB_REDUNDANT_NULL_CHECK,
        JavaCore.COMPILER_PB_POSSIBLE_ACCIDENTAL_BOOLEAN_ASSIGNMENT,
        JavaCore.COMPILER_PB_UNUSED_LABEL,
        JavaCore.COMPILER_PB_UNUSED_LOCAL,
        JavaCore.COMPILER_PB_UNUSED_OBJECT_ALLOCATION,
        JavaCore.COMPILER_PB_UNUSED_PARAMETER,
        JavaCore.COMPILER_PB_UNUSED_PRIVATE_MEMBER
    };
    for (String s : generate) compilerOptions.put(s, JavaCore.GENERATE);
    for (String s : ignore) compilerOptions.put(s, JavaCore.IGNORE);
    for (String s : warn) compilerOptions.put(s, JavaCore.WARNING);
    COMPILER_OPTIONS=Collections.unmodifiableMap(compilerOptions);
  }
  private static CompilationUnit makeAST(ASTParser parser, char[] source, Map<String, String> options) {
    parser.setSource(source);
    parser.setKind(ASTParser.K_COMPILATION_UNIT);
    parser.setCompilerOptions(options);
    parser.setStatementsRecovery(true);
    return (CompilationUnit)parser.createAST(null);
  }
  private static CompilationUnit makeASTWithBindings(ASTParser parser, char[] source, Map<String, String> options, String className, String[] classPath) {
    parser.setSource(source);
    parser.setKind(ASTParser.K_COMPILATION_UNIT);
    parser.setCompilerOptions(options);
    parser.setStatementsRecovery(true);
    parser.setUnitName(className);
    parser.setEnvironment(classPath, null, null, false);
    parser.setResolveBindings(true);
    return (CompilationUnit)parser.createAST(null);
  }
  static String joinPath(String a, String b) {
    return a + "/" + b;//FIX
  }
  static void writeFile(String path, String text) {
    PrintWriter write=null;
    try {
      File file=new File(path);
      if (!file.isFile()) {
        file.getParentFile().mkdirs();
        file.createNewFile();
      }
      write=new PrintWriter(file);
      write.print(text);
      write.flush();
      write.close();
    } catch (IOException e) {
      e.printStackTrace();
    } finally {
      if (write != null) {
        write.close();
      }
    }
  }
  static String getClassPath(Class c) {
    ProtectionDomain pDomain=c.getProtectionDomain();
    CodeSource cSource=pDomain.getCodeSource();
    URL urlfrom=cSource.getLocation();
    return urlfrom.getFile();
  }
}
