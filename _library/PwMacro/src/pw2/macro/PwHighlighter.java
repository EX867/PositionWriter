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
import java.util.ArrayList;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
public class PwHighlighter implements CommandEdit.TextRenderer {
  CommandEdit edit;
  public PwHighlighter(CommandEdit edit_, Class<? extends PwMacro> cl) {//add keywords!!
    edit=edit_;
    edit.keywords.put("int", 0xFF33997E);
    edit.keywords.put("float", 0xF33997E);
    edit.keywords.put("char", 0xFF33997E);
    edit.keywords.put("double", 0xFF33997E);
    edit.keywords.put("long", 0xFF33997E);
    edit.keywords.put("void", 0xFF33997E);
    edit.keywords.put("public", 0xFF33997E);
    edit.keywords.put("private", 0xFF33997E);
    edit.keywords.put("protected", 0xFF33997E);
    edit.keywords.put("class", 0xFF33997E);
    edit.keywords.put("extends", 0xFF33997E);
    edit.keywords.put("implements", 0xFF33997E);
    edit.keywords.put("final", 0xFF33997E);
    edit.keywords.put("static", 0xFF33997E);
    edit.keywords.put("true", 0xFF33997E);
    edit.keywords.put("false", 0xFF33997E);
    edit.keywords.put("null", 0xFF33997E);
    edit.keywords.put("while", 0xFF669900);
    edit.keywords.put("if", 0xFF669900);
    edit.keywords.put("for", 0xFF669900);
    edit.keywords.put("do", 0xFF669900);
    edit.keywords.put("try", 0xFF669900);
    edit.keywords.put("catch", 0xFF669900);
    edit.keywords.put("finally", 0xFF669900);
    edit.keywords.put("__method", 0xFF336699);
    edit.keywords.put("__string", 0xFF7D4793);
    Method[] methods=cl.getDeclaredMethods();//only contains api.
    for (Method m : methods) {
      edit.keywords.put(m.getName(), 0xFF006699);
    }
    Field[] fields=cl.getDeclaredFields();
    for (Field f : fields) {
      edit.keywords.put(f.getName(), 0xFFD94A7A);
    }
    Class[] classes=cl.getDeclaredClasses();
    for (Class c : classes) {
      edit.keywords.put(c.getName(), 0xFFE2661A);
    }
  }
  //lexing happens every frame. only lex visible area of text. lexing can be done per line.
  //higlighter only highlights keywords, predefined functions,variables so it is fast!
  static Pattern identifier=Pattern.compile("[a-zA-Z_\\$]([a-zA-Z0-9_\\$])*");
  @Override
  public void render(PGraphics g, String text, int line, CommandEdit cmd) {
    final ArrayList<Token> tokens=new ArrayList<Token>();
    final PdeLexer lexer=new PdeLexer(new ByteArrayInputStream(text.getBytes()));
    try {
      for (Token token=lexer.nextToken(); token.getType() != Token.EOF_TYPE; token=lexer.nextToken()) {
        //got token!
        tokens.add(token);
      }
    } catch (TokenStreamException e) {
      e.printStackTrace();
    }
    float width=0;
    for (int a=0; a < tokens.size(); a++) {
      Token token=tokens.get(a);
      boolean isFunction=false;
      if (identifier.matcher(token.getText()).matches()) {
        for (int b=a + 1; b < tokens.size(); b++) {
          if (tokens.get(b).getText().equals("(")) {
            isFunction=true;
            break;//it is function!
          }
          if (tokens.get(b).getText().trim().length() != 0) {
            break;
          }
        }
      }
      int fill;
      g.fill(fill=cmd.keywords.getOrDefault(token.getText(), cmd.textColor));
      if (fill == cmd.textColor) {//not a keyword.
        if (isFunction) {
          g.fill(cmd.keywords.getOrDefault("__method", cmd.textColor));
        } else if (token.getText().length() >= 1 && token.getText().charAt(0) == '\"') {
          g.fill(cmd.keywords.getOrDefault("__string", cmd.textColor));
        } else if (token.getText().startsWith("//") || token.getText().startsWith("/*")) {//comment
          //multiline comment add
          g.fill(cmd.commentColor);
        }
      }
      g.text(token.getText(), width + cmd.pos.left + cmd.lineNumSize + cmd.padding, cmd.pos.top + (line + 0.5F) * cmd.textSize - cmd.offsetY + cmd.padding);
      width=width + g.textWidth(token.getText());
    }
  }
}
