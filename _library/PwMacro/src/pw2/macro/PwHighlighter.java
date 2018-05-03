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
import java.util.ArrayList;
public class PwHighlighter implements CommandEdit.TextRenderer {
  CommandEdit edit;
  public PwHighlighter(CommandEdit edit_) {
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
  }
  //lexing happens every frame. only lex visible area of text. lexing can be done per line.
  //higlighter only highlights keywords, predefined functions,variables so it is fast!
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
    for (Token token : tokens) {
      g.fill(cmd.keywords.getOrDefault(token.getText(), cmd.textColor));
      g.text(token.getText(), width + cmd.pos.left + cmd.lineNumSize + cmd.padding, cmd.pos.top + (line + 0.5F) * cmd.textSize - cmd.offsetY + cmd.padding);
      width=width + g.textWidth(token.getText());
    }
  }
}
