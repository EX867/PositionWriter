package pw2.macro;
import antlr.CharStreamException;
import antlr.Token;
import antlr.TokenStreamException;
import com.karnos.commandscript.CommandEdit;
import com.karnos.commandscript.CommandScript;
import processing.core.PGraphics;
import processing_mode_java.preproc.PdeLexer;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.TreeSet;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
public class PwHighlighter implements CommandEdit.TextRenderer {
  CommandEdit edit;
  TreeSet<String> apiMethods = new TreeSet<>();
  static final int NONE = 0;
  static final int FUNCTION = 1;
  static final int API_FUNCTION = 2;
  public PwHighlighter(CommandEdit edit_, Class<? extends PwMacro> cl) {//add keywords!!
    edit = edit_;
    //no used
    edit.keywords.put("const", 0xFFFF0000);
    edit.keywords.put("goto", 0xFFFF0000);
    edit.keywords.put("package", 0xFFFF0000);
    //commands
    edit.keywords.put("import", 0xFF33997E);
    edit.keywords.put("assert", 0xFF33997E);
    edit.keywords.put("break", 0xFF33997E);
    edit.keywords.put("continue", 0xFF33997E);
    edit.keywords.put("return", 0xFF33997E);
    edit.keywords.put("throw", 0xFF33997E);
    //primitive types
    edit.keywords.put("int", 0xFF33997E);
    edit.keywords.put("byte", 0xF33997E);
    edit.keywords.put("short", 0xFF33997E);
    edit.keywords.put("float", 0xF33997E);
    edit.keywords.put("char", 0xFF33997E);
    edit.keywords.put("double", 0xFF33997E);
    edit.keywords.put("long", 0xFF33997E);
    edit.keywords.put("boolean", 0xFF33997E);
    edit.keywords.put("void", 0xFF33997E);
    //modifiers
    edit.keywords.put("public", 0xFF33997E);
    edit.keywords.put("private", 0xFF33997E);
    edit.keywords.put("protected", 0xFF33997E);
    edit.keywords.put("abstract", 0xFF33997E);
    edit.keywords.put("final", 0xFF33997E);
    edit.keywords.put("static", 0xFF33997E);
    edit.keywords.put("volitile", 0xFF33997E);
    edit.keywords.put("strictfp", 0xFF33997E);
    edit.keywords.put("native", 0xFF33997E);
    edit.keywords.put("transient", 0xFF33997E);
    //basic structure
    edit.keywords.put("class", 0xFF33997E);
    edit.keywords.put("interface", 0xFF33997E);
    edit.keywords.put("enum", 0xFF33997E);
    edit.keywords.put("extends", 0xFF33997E);
    edit.keywords.put("implements", 0xFF33997E);
    edit.keywords.put("throws", 0xFF33997E);
    edit.keywords.put("new", 0xFF33997E);
    edit.keywords.put("instanceof", 0xFF33997E);
    edit.keywords.put("this", 0xFF33997E);
    edit.keywords.put("super", 0xFF33997E);
    //values
    edit.keywords.put("true", 0xFF33997E);
    edit.keywords.put("false", 0xFF33997E);
    edit.keywords.put("null", 0xFF33997E);
    //control statements
    edit.keywords.put("while", 0xFF669900);
    edit.keywords.put("if", 0xFF669900);
    edit.keywords.put("else", 0xFF669900);
    edit.keywords.put("for", 0xFF669900);
    edit.keywords.put("do", 0xFF669900);
    edit.keywords.put("try", 0xFF669900);
    edit.keywords.put("catch", 0xFF669900);
    edit.keywords.put("finally", 0xFF669900);
    edit.keywords.put("switch", 0xFF669900);
    edit.keywords.put("case", 0xFF669900);
    edit.keywords.put("default", 0xFF669900);
    edit.keywords.put("synchronized", 0xFF669900);
    //
    edit.keywords.put("__method", 0xFF3388BB);
    edit.keywords.put("__apimethod", 0xFF228899);
    edit.keywords.put("__string", 0xFF7D4793);
    Method[] methods = cl.getDeclaredMethods();//only contains api.
    for (Method m : methods) {
      //      if (!Modifier.isPrivate(m.getModifiers())) {
      //        edit.keywords.put(m.getName(), 0xFF228899);
      //      }
      apiMethods.add(m.getName());
    }
    Field[] fields = cl.getDeclaredFields();
    for (Field f : fields) {
      if (!Modifier.isPrivate(f.getModifiers())) {
        edit.keywords.put(f.getName(), 0xFFD94A7A);
      }
    }
    Class[] classes = cl.getDeclaredClasses();
    for (Class c : classes) {
      if (!Modifier.isPrivate(c.getModifiers())) {
        edit.keywords.put(c.getCanonicalName(), 0xFFE2661A);
        edit.keywords.put(c.getSimpleName(), 0xFFE2661A);
      }
    }
    edit.keywords.put("__parent", 0xFFFF0000);//for discourage use (overwrite)
  }
  //lexing happens every frame. only lex visible area of text. lexing can be done per line.
  //higlighter only highlights keywords, predefined functions,variables so it is fast!
  static Pattern identifier = Pattern.compile("[a-zA-Z_\\$]([a-zA-Z0-9_\\$])*");
  @Override
  public void render(PGraphics g, String text, int line, CommandEdit cmd) {
    final ArrayList<Token> tokens = new ArrayList<Token>();
    final PdeLexer lexer = new PdeLexer(new ByteArrayInputStream(text.getBytes()));
    try {
      for (Token token = lexer.nextToken(); token.getType() != Token.EOF_TYPE; token = lexer.nextToken()) {
        //got token!
        tokens.add(token);
      }
    } catch (TokenStreamException e) {
      e.printStackTrace();
    }
    float width = 0;
    for (int a = 0; a < tokens.size(); a++) {
      Token token = tokens.get(a);
      int functionType = NONE;
      if (apiMethods.contains(token.getText())) {
        for (int b = a + 1; b < tokens.size(); b++) {
          if (tokens.get(b).getText().equals("(")) {
            functionType = API_FUNCTION;
            break;//it is function!
          }
          if (tokens.get(b).getText().trim().length() != 0) {
            break;
          }
        }
      } else {
        if (identifier.matcher(token.getText()).matches()) {
          for (int b = a + 1; b < tokens.size(); b++) {
            if (tokens.get(b).getText().equals("(")) {
              functionType = FUNCTION;
              break;//it is function!
            }
            if (tokens.get(b).getText().trim().length() != 0) {
              break;
            }
          }
        }
      }
      int fill;
      g.fill(fill = cmd.keywords.getOrDefault(token.getText(), cmd.textColor));
      if (fill == cmd.textColor) {//not a keyword.
        if (functionType == FUNCTION) {
          g.fill(cmd.keywords.getOrDefault("__method", cmd.textColor));
        } else if (functionType == API_FUNCTION) {
          g.fill(cmd.keywords.getOrDefault("__apimethod", cmd.textColor));
        } else if (token.getText().length() >= 1 && (token.getText().charAt(0) == '\"' || token.getText().charAt(0) == '\'')) {
          g.fill(cmd.keywords.getOrDefault("__string", cmd.textColor));
        } else if (token.getText().startsWith("//")) {//|| token.getText().startsWith("/*")) {//comment
          //multiline comment add
          g.fill(cmd.commentColor);
        }
      }
      //ADD if still default color and it is identifier, check if it is type. (be aware that scope can hide things!)
      g.text(token.getText(), width + cmd.pos.left + cmd.lineNumSize + cmd.padding, cmd.pos.top + (line + 0.5F) * cmd.textSize - cmd.offsetY + cmd.padding);
      width = width + g.textWidth(token.getText());
    }
  }
}
