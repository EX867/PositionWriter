package processing_mode_java.pdex;
import org.eclipse.jdt.core.dom.ASTVisitor;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.jdt.core.dom.MethodDeclaration;
import org.eclipse.jdt.core.dom.SimpleType;
import processing_mode_java.TextTransform;

import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
public class SourceUtils {
  public static final Pattern IMPORT_REGEX=
      Pattern.compile("(?:^|;)\\s*(import\\s+(?:(static)\\s+)?((?:\\w+\\s*\\.)*)\\s*(\\S+)\\s*;)",
          Pattern.MULTILINE | Pattern.DOTALL);
  public static final Pattern IMPORT_REGEX_NO_KEYWORD=
      Pattern.compile("^\\s*((?:(static)\\s+)?((?:\\w+\\s*\\.)*)\\s*(\\S+))",
          Pattern.MULTILINE | Pattern.DOTALL);
  public static List<ImportStatement> parseProgramImports(CharSequence source) {
    List<ImportStatement> result=new ArrayList<>();
    Matcher matcher=IMPORT_REGEX.matcher(source);
    while (matcher.find()) {
      ImportStatement is=ImportStatement.parse(matcher.toMatchResult());
      result.add(is);
    }
    return result;
  }
  public static List<TextTransform.Edit> parseProgramImports(CharSequence source,
                                                             List<ImportStatement> outImports) {
    List<TextTransform.Edit> result=new ArrayList<>();
    Matcher matcher=IMPORT_REGEX.matcher(source);
    while (matcher.find()) {
      ImportStatement is=ImportStatement.parse(matcher.toMatchResult());
      outImports.add(is);
      int idx=matcher.start(1);
      int len=matcher.end(1) - idx;
      // Remove the import from the main program
      // Substitute with white spaces
      result.add(TextTransform.Edit.move(idx, len, 0));
      result.add(TextTransform.Edit.insert(0, "\n"));
    }
    return result;
  }
  public static List<TextTransform.Edit> insertImports(List<ImportStatement> imports) {
    List<TextTransform.Edit> result=new ArrayList<>();
    for (ImportStatement imp : imports) {
      result.add(TextTransform.Edit.insert(0, imp.getFullSourceLine() + "\n"));
    }
    return result;
  }
  // Verifies that whole input String is floating point literal. Can't be used for searching.
  // https://docs.oracle.com/javase/specs/jls/se8/html/jls-3.html#jls-DecimalFloatingPointLiteral
  public static final Pattern FLOATING_POINT_LITERAL_VERIFIER;
  static {
    final String DIGITS="(?:[0-9]|[0-9][0-9_]*[0-9])";
    final String EXPONENT_PART="(?:[eE][+-]?" + DIGITS + ")";
    FLOATING_POINT_LITERAL_VERIFIER=Pattern.compile(
        "(?:^" + DIGITS + "\\." + DIGITS + "?" + EXPONENT_PART + "?[fFdD]?$)|" +
            "(?:^\\." + DIGITS + EXPONENT_PART + "?[fFdD]?$)|" +
            "(?:^" + DIGITS + EXPONENT_PART + "[fFdD]?$)|" +
            "(?:^" + DIGITS + EXPONENT_PART + "?[fFdD]$)");
  }
  // Mask to quickly resolve whether there are any access modifiers present
  private static final int ACCESS_MODIFIERS_MASK=
      Modifier.PUBLIC | Modifier.PRIVATE | Modifier.PROTECTED;
  public static List<TextTransform.Edit> preprocessAST(CompilationUnit cu) {
    final List<TextTransform.Edit> edits=new ArrayList<>();
    // Walk the tree
    cu.accept(new ASTVisitor() {
      @Override
      public boolean visit(SimpleType node) {
        // replace "color" with "int"
        if ("color".equals(node.getName().toString())) {
          edits.add(TextTransform.Edit.replace(node.getStartPosition(), node.getLength(), "int"));
        }
        return super.visit(node);
      }
      //      @Override//no this
      //      public boolean visit(NumberLiteral node) {
      //        // add 'f' to floats
      //        String s = node.getToken().toLowerCase();
      //        if (FLOATING_POINT_LITERAL_VERIFIER.matcher(s).matches() && !s.endsWith("f") && !s.endsWith("d")) {
      //          edits.add(Edit.insert(node.getStartPosition() + node.getLength(), "f"));
      //        }
      //        return super.visit(node);
      //      }
      @Override
      public boolean visit(MethodDeclaration node) {
        // add 'public' to methods with default visibility
        int accessModifiers=node.getModifiers() & ACCESS_MODIFIERS_MASK;
        if (accessModifiers == 0) {
          edits.add(TextTransform.Edit.insert(node.getStartPosition(), "public "));
        }
        return super.visit(node);
      }
    });
    return edits;
  }
  public static final Pattern COLOR_TYPE_REGEX=
      Pattern.compile("(?:^|^\\p{javaJavaIdentifierPart})(color)\\s(?!\\s*\\()",
          Pattern.MULTILINE | Pattern.UNICODE_CHARACTER_CLASS);
  public static List<TextTransform.Edit> replaceColorRegex(CharSequence source) {
    final List<TextTransform.Edit> edits=new ArrayList<>();
    Matcher matcher=COLOR_TYPE_REGEX.matcher(source);
    while (matcher.find()) {
      int offset=matcher.start(1);
      edits.add(TextTransform.Edit.replace(offset, 5, "int"));
    }
    return edits;
  }
  public static final Pattern NUMBER_LITERAL_REGEX=
      Pattern.compile("[-+]?[0-9]*\\.?[0-9]+(?:[eE][-+]?[0-9]+)?");
  public static List<TextTransform.Edit> fixFloatsRegex(CharSequence source) {
    final List<TextTransform.Edit> edits=new ArrayList<>();
    Matcher matcher=NUMBER_LITERAL_REGEX.matcher(source);
    while (matcher.find()) {
      int offset=matcher.start();
      int end=matcher.end();
      String group=matcher.group().toLowerCase();
      boolean isFloatingPoint=group.contains(".") || group.contains("e");
      boolean hasSuffix=end < source.length() &&
          Character.toLowerCase(source.charAt(end)) != 'f' &&
          Character.toLowerCase(source.charAt(end)) != 'd';
      if (isFloatingPoint && !hasSuffix) {
        edits.add(TextTransform.Edit.insert(offset, "f"));
      }
    }
    return edits;
  }
  static public String scrubCommentsAndStrings(String p) {
    StringBuilder sb=new StringBuilder(p);
    return scrubCommentsAndStrings(sb).toString();
  }
  static public StringBuilder scrubCommentsAndStrings(StringBuilder p) {
    final int length=p.length();
    final int OUT=0;
    final int IN_BLOCK_COMMENT=1;
    final int IN_EOL_COMMENT=2;
    final int IN_STRING_LITERAL=3;
    final int IN_CHAR_LITERAL=4;
    int blockStart=-1;
    int prevState=OUT;
    int state=OUT;
    for (int i=0; i <= length; i++) {
      char ch=(i < length) ? p.charAt(i) : 0;
      char pch=(i == 0) ? 0 : p.charAt(i - 1);
      // Get rid of double backslash immediately, otherwise
      // the second backslash incorrectly triggers a new escape sequence
      if (pch == '\\' && ch == '\\') {
        p.setCharAt(i - 1, ' ');
        p.setCharAt(i, ' ');
        pch=' ';
        ch=' ';
      }
      switch (state) {
        case OUT:
          switch (ch) {
            case '\'':
              state=IN_CHAR_LITERAL;
              break;
            case '"':
              state=IN_STRING_LITERAL;
              break;
            case '*':
              if (pch == '/') state=IN_BLOCK_COMMENT;
              break;
            case '/':
              if (pch == '/') state=IN_EOL_COMMENT;
              break;
          }
          break;
        case IN_BLOCK_COMMENT:
          if (pch == '*' && ch == '/' && (i - blockStart) > 1) {
            state=OUT;
          }
          break;
        case IN_EOL_COMMENT:
          if (ch == '\r' || ch == '\n') {
            state=OUT;
          }
          break;
        case IN_STRING_LITERAL:
          if ((pch != '\\' && ch == '"') || ch == '\r' || ch == '\n') {
            state=OUT;
          }
          break;
        case IN_CHAR_LITERAL:
          if ((pch != '\\' && ch == '\'') || ch == '\r' || ch == '\n') {
            state=OUT;
          }
          break;
      }
      // Terminate ongoing block at last char
      if (i == length) {
        state=OUT;
      }
      // Handle state changes
      if (state != prevState) {
        if (state != OUT) {
          // Entering block
          blockStart=i + 1;
        } else {
          // Exiting block
          int blockEnd=i;
          if (prevState == IN_BLOCK_COMMENT && i < length) blockEnd--; // preserve star in '*/'
          for (int j=blockStart; j < blockEnd; j++) {
            char c=p.charAt(j);
            if (c != '\n' && c != '\r') p.setCharAt(j, ' ');
          }
        }
      }
      prevState=state;
    }
    return p;
  }
}
