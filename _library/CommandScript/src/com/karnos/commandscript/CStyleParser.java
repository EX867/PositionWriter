package com.karnos.commandscript;
import java.util.LinkedList;
public class CStyleParser extends Analyzer {
  public CStyleParser(LineCommandType commandType_, LineCommandProcessor processer_) {
    super(commandType_, processer_);
  }
  /*
  ex)
  if(1==2){
    int a=0;
    a=a+1;
  }
  ->
  Block (if = void type lambda with 1 parameters)
  -- Exp (==)
  ---- Val (1)
  ---- Val (2)
  -- Exp (=)
  ---- Declare
  ------ Ident (int)
  ------ Ident (a)
  ---- Val (0)
  -- Exp (=)
  ---- Ident (a)
  ---- Exp (+)
  ------ Ident (a)
  ------ Val (1)
  ex)
  List<List<int>>[][] a; (2 dimensional generic x 2)
  Declare
  -- Ident (Array) : Array of Type
  ---- Ident (Array) : Array of Type
  ------ Ident (List) : List of Type
  -------- Ident (List) : List of Type
  ---------- Ident (int)
  -- Ident (a)
  equals : Array<Array<List<List<int>>>> (generic x 4)
  ex)
  print(f1(a,b,c)+f2(f3(a+1),c));
  ->
  Exp (print)
  -- Exp (+)
  ---- Exp (f1)
  ------ Ident (a)
  ------ Ident (b)
  ------ Ident (c)
  ---- Exp (f2)
  ------ Exp (f3)
  -------- Exp (+)
  ---------- Ident (a)
  ---------- Val (1)
  ------ Ident (c)
  Blocks : if, for, while, foreach,... (starts with {, ends with }.)
  Exp : functions (start with (, ends with ).)
  1+(2+3) -> also parse as function with no parameters.
  Exp = Exp|Ident|Val
  Ident = Ident|Declare
  ex) (int a)->{return;}
  ->
  Block (void type lambda with 1 parameters. )
  -- Empty (this means this block is incomplete, it is not executable.
  keywords : true false, blocks,
  */
  int counter;//string counter
  boolean error=false;//detect error in other functions.
  @Override
  public Command parse(int line, String location_, String text) {//working with line, so I not have to skip \n charters.
    location=location_;
    text=text.substring(text.indexOf("//")).trim();//remove comment
    counter=0;
    error=false;
    while (counter < text.length()) {
      ParseNode ch=nextToken(text, line);
      if (error) {
        return commandType.getErrorCommand();
      }
    }
    return commandType.getEmptyCommand();
  }
  ParseNode nextToken(String text, int line) {//get one token from counter.
    while (text.charAt(counter) == ' ' && counter < text.length()) {
      counter++;
    }
    StringBuilder token=new StringBuilder();
    while (counter < text.length()) {
      //detect Val
      if (text.charAt(counter) == '\'') {//char
      } else if (text.charAt(counter) == '\"') {//string
        counter++;
        if (counter >= text.length()) {
          addError(new LineError(LineError.ERROR, line, text.length(), text.length(), location, "unterminated string literal."));
          error=true;
        }
        while (text.charAt(counter) != '\'') {
          if (counter >= text.length()) {
            addError(new LineError(LineError.ERROR, line, text.length(), text.length(), location, "unterminated string literal."));
            error=true;
          }
          token.append(text.charAt(counter));
          counter++;
        }
        counter++;//ignore ' character.
        return new Val(ValType.String, removeEscape(token.toString()));
      } else if ('0' <= text.charAt(counter) && text.charAt(counter) <= '9') {//int or float.
      }
    }
    return null;
  }
  public String removeEscape(String in) {
    return in.replace("\\n", "\n").replace("\\r", "\r").replace("\\t", "\t").replace("\\b", "\b").replace("\\f", "\f").replace("\\\'", "\'").replace("\\\"", "\"").replace("\\\\", "\\");
  }
  public class ParseNode implements Command {//node of parse tree
    public LinkedList<ParseNode> children;
    public boolean complete=true;
    String content=null;
    public ParseNode() {
      children=new LinkedList<>();
    }
    public ParseNode(String content_) {//terminal nodes's content must not null.
      children=new LinkedList<>();
      content=content_;
    }
  }
  public class Block extends ParseNode {
  }
  public class Exp extends ParseNode {
    public Exp() {
    }
    public Exp(String s) {
      super(s);
    }
  }
  public class Declare extends ParseNode {
  }
  public class Ident extends Exp {
    public Ident(String s) {
      super(s);
    }
  }
  public class Val extends Exp {
    ValType type;
    public Val(ValType type_, String s) {
      super(s);
    }
  }
  public enum ValType {
    Int, Float, Bool, String, Char
  }
}