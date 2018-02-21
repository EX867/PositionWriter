package com.karnos.commandscript;
import kyui.core.KyUI;

import java.lang.reflect.*;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
public class CStyleParser extends Analyzer {
  static CharType[] charArray;
  static List<String> operators;
  public CStyleParser() {
    super(new CommandType(), new Processor());
    ((CommandType)commandType).ref=this;
    ((Processor)processor).ref=this;
    charArray=new CharType[127];
    for (int a='0'; a < '9'; a++) {
      charArray[a]=CharType.Digit;
    }
    charArray['+']=CharType.Operator;
    charArray['-']=CharType.Operator;
    charArray['*']=CharType.Operator;
    charArray['/']=CharType.Operator;
    charArray['%']=CharType.Operator;
    charArray['&']=CharType.Operator;
    charArray['|']=CharType.Operator;
    charArray['<']=CharType.Operator;
    charArray['>']=CharType.Operator;
    charArray['=']=CharType.Operator;
    charArray['!']=CharType.Operator;
    charArray['(']=CharType.Seperator;
    charArray[')']=CharType.Seperator;
    charArray['[']=CharType.Seperator;
    charArray[']']=CharType.Seperator;
    charArray['{']=CharType.Seperator;
    charArray['}']=CharType.Seperator;
    charArray['.']=CharType.Operator;
    charArray[',']=CharType.Seperator;
    //for safety
    charArray['\'']=CharType.Operator;
    charArray['\"']=CharType.Operator;
    charArray[' ']=CharType.Blank;
    charArray['\n']=CharType.Blank;
    charArray['\t']=CharType.Blank;
    charArray['\r']=CharType.Blank;
    charArray['\f']=CharType.Blank;
    operators=java.util.Arrays.<String>asList("&&", "||", "<=", ">=", "==", "!=", "+", "-", "*", "/", "%", "<", ">", "=", "!", "(", ")", "[", "]", ".", ",");
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
  Blocks : if, for, while,... (starts with {, ends with }.)
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
  int line;
  int counter;//string counter
  boolean error=false;//detect error in other functions.
  /*
  parse errors:
  -
  */
  /*
  lex errors:
  - unexpexted token
  - undeclared identifier
  - no matching overloaded functions
  - duplicated import statements
  - ambiguous type reference
  - abstract class instantiation
  - invisible field/method access
  - generic parameter not matching
  - lambda expression incompatible return type (lambda is Executor here)
  */
  @Override
  public Command parse(int line, String location_, String text) {//working with line, so I not have to skip \n charters.
    location=location_;
    this.line=line;//access in local methods
    text=text.substring(0, text.indexOf("//")).trim();//remove comment
    counter=0;
    error=false;
    LinkedList<ParseNode> nodes=new LinkedList<>();
    while (counter < text.length()) {
      ParseNode ch=nextToken(text);
      if (error) {
        return commandType.getErrorCommand();
      }
      if (ch != null) {//just skip for blanks and weird things
        nodes.add(ch);//add all tokens to nodes.
      }
    }
    //make it to tree.
    java.util.Stack<ParseNode> operators=new java.util.Stack<>();
    //    for (int a=0; a < nodes.size(); a++) {
    //      Token t=original.get(a);
    //      if (t.tokenclass == TokenClass.Word || t.tokenclass == TokenClass.Constant) {
    //        tokens.add(t);
    //      } else if (t.type == TokenType.ElseOperator) {
    //      } else if (t.type == TokenType.Lparen) {
    //        operators.push(t);
    //      } else if (t.type == TokenType.Rparen) {
    //        while (operators.size() > 0 && operators.peek().type != TokenType.Lparen) {
    //          tokens.add(operators.pop());
    //        }
    //        if (operators.size() == 0) {
    //          error=true;//parse error : no matching ) to find.
    //        } else {
    //          operators.pop();
    //        }
    //      } else {
    //        while (operators.size() > 0 && operators.peek().priority >= t.priority) {
    //          tokens.add(operators.pop());
    //        }
    //        operators.push(t);
    //      }
    //      a=a + 1;
    //    }
    //    while (operators.size() > 0) {
    //      tokens.add(operators.pop());
    //    }
    return commandType.getEmptyCommand();
  }
  ParseNode nextToken(String text) {//get one token from counter.
    while (getCharType(text.charAt(counter)) == CharType.Blank) {
      counter++;
      if (counter >= text.length()) {
        return null;
      }
    }
    StringBuilder token=new StringBuilder();
    if (getCharType(text.charAt(counter)) == CharType.Seperator) {
      counter++;
      if (text.charAt(counter - 1) == '(') {
        return new Seperator(SeperatorType.Lparen, "(");
      } else if (text.charAt(counter - 1) == ')') {
        return new Seperator(SeperatorType.Rparen, ")");
      } else if (text.charAt(counter - 1) == '{') {
        return new Seperator(SeperatorType.Lbrace, "{");
      } else if (text.charAt(counter - 1) == '}') {
        return new Seperator(SeperatorType.Rbrace, "}");
      } else if (text.charAt(counter - 1) == '[') {
        return new Seperator(SeperatorType.Lindex, "[");
      } else if (text.charAt(counter - 1) == ']') {
        return new Seperator(SeperatorType.Rindex, "]");
      } else {// if(text.charAt(counter)==','){
        return new Seperator(SeperatorType.Comma, ",");
      }
    } else if (text.charAt(counter) == '\'') {//detect Val//char
      counter++;
      if (counter >= text.length()) {
        addError(new LineError(LineError.ERROR, line, text.length(), text.length(), location, "unterminated character literal."));
        error=true;
        return new Val(ValType.Char, "\0");//think character was there...
      }
      if (text.charAt(counter) == '\'') {//error
        addError(new LineError(LineError.ERROR, line, text.length(), text.length(), location, "empty character literal."));
        error=true;
        return new Val(ValType.Char, "\0");//think character was there...
      } else {
        if (text.charAt(counter) == '\\') {//escape
          token.append(text.charAt(counter));
          counter++;
          if (counter >= text.length()) {
            addError(new LineError(LineError.ERROR, line, text.length(), text.length(), location, "unterminated character literal."));
            error=true;
            return new Val(ValType.Char, "\0");//think character was there...
          }
        }
        token.append(text.charAt(counter));
        counter++;
        if (counter >= text.length()) {
          addError(new LineError(LineError.ERROR, line, text.length(), text.length(), location, "unterminated character literal."));
          error=true;
          return new Val(ValType.Char, "\0");//think character was there...
        } else if (text.charAt(counter) != '\'') {
          addError(new LineError(LineError.ERROR, line, text.length(), text.length(), location, "too many characters in character literal."));
          error=true;
          return new Val(ValType.Char, "\0");//think character was there...
        }
        return new Val(ValType.Char, removeEscape(token.toString()));
      }
    } else if (text.charAt(counter) == '\"') {//string
      counter++;
      if (counter >= text.length()) {
        addError(new LineError(LineError.ERROR, line, text.length(), text.length(), location, "unterminated string literal."));
        error=true;
      }
      while (text.charAt(counter) != '\"') {
        if (counter >= text.length()) {
          addError(new LineError(LineError.ERROR, line, text.length(), text.length(), location, "unterminated string literal."));
          error=true;
        }
        token.append(text.charAt(counter));
        counter++;
      }
      counter++;//ignore ' character.
      return new Val(ValType.String, removeEscape(token.toString()));
    } else if (getCharType(text.charAt(counter)) == CharType.Digit) {//int or float. no support for 0x, 0b and 0e.
      while (getCharType(text.charAt(counter)) == CharType.Digit) {
        token.append(text.charAt(counter));
        counter++;
        if (counter >= text.length()) {
          return new Val(ValType.Int, token.toString());
        }
      }
      if (text.charAt(counter) == '.') {
        counter++;
      }
      if (counter >= text.length()) {
        return new Val(ValType.Float, token.toString());
      }
      while (getCharType(text.charAt(counter)) == CharType.Digit) {
        token.append(text.charAt(counter));
        counter++;
        if (counter >= text.length()) {
          return new Val(ValType.Float, token.toString());
        }
      }
      return new Val(ValType.Float, token.toString());
    } else if (getCharType(text.charAt(counter)) == CharType.Operator) {//seperators and operators (exp)
      int counter_=counter;
      while (getCharType(text.charAt(counter_)) == CharType.Operator) {//matching not greedy
        token.append(counter_);
        counter_++;
      }
      //obtain a string of operators.
      //match 2-length operators
      if (operators.contains(token.substring(0, 2))) {
        counter+=2;
        return new Operator(token.substring(0, 2));
      }
      //if no,just return one character.
      counter+=1;
      return new Operator(token.substring(0, 1));
    } else if (getCharType(text.charAt(counter)) == CharType.Character) {//ident
      while (getCharType(text.charAt(counter)) == CharType.Character || getCharType(text.charAt(counter)) == CharType.Digit) {
        token.append(text.charAt(counter));
        counter++;
        if (counter >= text.length()) {
          return new Ident(token.toString());
        }
      }
      return new Ident(token.toString());
    } else {
      System.out.println("\"" + text.charAt(counter) + " encountered!");
      counter++;//preventing infinite loop
      //what a weird thing!
      return null;
    }
  }
  public String removeEscape(String in) {
    return in.replace("\\n", "\n").replace("\\r", "\r").replace("\\t", "\t").replace("\\b", "\b").replace("\\f", "\f").replace("\\\'", "\'").replace("\\\"", "\"").replace("\\\\", "\\");
  }
  public CharType getCharType(char in) {
    if (in > charArray.length) {
      return CharType.Character;
    }
    return charArray[in];
  }
  public class ParseNode implements Command {//node of parse tree
    public LinkedList<ParseNode> children;
    public boolean complete=true;
    String content=null;
    public ParseNode(String content_) {//terminal nodes's content must not null.
      children=new LinkedList<>();
      content=content_;
    }
  }
  public class Line implements Command {
    public ParseNode root;//if this is block line, root will be Block.
  }
  public class Block extends ParseNode {
    public Block(String content_) {
      super(content_);
    }
  }
  public class Exp extends ParseNode {
    public Exp(String s) {
      super(s);
    }
  }
  public class Declare extends ParseNode {
    public Declare(String content_) {
      super(content_);
    }
  }
  public class Ident extends Exp {
    Class type=null;
    Variable var=null;
    Field field=null;
    Method method=null;
    int priority=0;//used in operator order changing
    public Ident(String s) {
      super(s);
    }
  }
  public class Val extends Exp {
    ValType type;
    public Val(ValType type_, String s) {
      super(s);
      type=type_;
    }
  }
  public class Operator extends ParseNode {//temporary class for nextToken
    public Operator(String s) {
      super(s);
    }
    public Ident newIdent(String content, int priority) {
      Ident ident=new Ident(content);
      ident.priority=priority;
      return ident;
    }
    public Exp toIdent() {
      if (content.equals("&&")) {
        return newIdent("Primitives.and", 1);
      } else if (content.equals("||")) {
        return newIdent("Primitives.or", 1);
      }
      if (content.equals("<=")) {
        return newIdent("Primitives.ltEq", 2);
      }
      if (content.equals(">=")) {
        return newIdent("Primitives.gtEq", 2);
      }
      if (content.equals("==")) {
        return newIdent("Primitives.eq", 2);
      }
      if (content.equals("!=")) {
        return newIdent("Primitives.notEq", 2);
      }
      if (content.equals(">")) {
        return newIdent("Primitives.gt", 2);
      }
      if (content.equals("<")) {
        return newIdent("Primitives.lt", 2);
      }
      if (content.equals("+")) {//no unary check. is unary, its priority is 5.
        return newIdent("Primitives.add", 3);
      }
      if (content.equals("-")) {//no unary check
        return newIdent("Primitives.sub", 3);
      }
      if (content.equals("*")) {
        return newIdent("Primitives.mult", 4);
      }
      if (content.equals("/")) {
        return newIdent("Primitives.div", 4);
      }
      if (content.equals("%")) {
        return newIdent("Primitives.remainder", 4);
      }
      if (content.equals("=")) {
        return newIdent("Primitives.assign", 1);
      }
      if (content.equals("!")) {
        return newIdent("Primitives.not", 3);
      }
      if (content.equals(".")) {
        return newIdent("Primitives.reference", 5);
      }
      error=true;
      addError(new LineError(LineError.ERROR, line, 0, KyUI.INF, location, "no matching operator"));
      return new Ident(content);//what?? this will make unexpected
    }
  }
  public class Seperator extends ParseNode {
    SeperatorType type=null;
    public Seperator(SeperatorType type_, String content_) {
      super(content_);
      type=type_;
    }
  }
  public enum ValType {
    Int, Float, Bool, String, Char, Object
  }
  public enum CharType {
    Character, Digit, Operator, Blank, Seperator
  }
  public enum SeperatorType {
    Lparen, Rparen, Lbrace, Rbrace, Lindex, Rindex, Comma
  }
  //int variables will stored as integer,but if checking
  public class Variable {//user created variables.
    Ident ident;
  }
  public static class Processor extends LineCommandProcessor {
    CStyleParser ref;
    public List<Class> type;//ident types are here, these contains type information.
    public List<Block> blocks;//block's children are modified frequently.
    public List<Variable> vars;
    @Override
    public void processCommand(Analyzer analyzer, int line, Command before, Command after) {
      Array list;
    }
    @Override
    public void onReadFinished(Analyzer analyzer) {
    }
    @Override
    public void clear(Analyzer analyzer) {
    }
  }
  static class CommandType extends LineCommandType {
    CStyleParser ref;
    @Override
    public Command getCommand(Analyzer analyzer, int line, String location, String text, String commandName, ArrayList<String> params) {
      return null;
    }//if this is called, error!
    @Override
    public Command getErrorCommand() {
      return ref.new Line();
    }
    @Override
    public Command getEmptyCommand() {
      return ref.new Line();
    }
    @Override
    public void cursorUpWord(CommandScript script, boolean select) {
      //ADD>>
    }
    @Override
    public void cursorDownWord(CommandScript script, boolean select) {
      //ADD>>
    }
  }
  /*
  //token replacement for always :
  Ident[] to Primitives.Array<Ident>
  Ident[Exp2] = Exp2 to Ident.set(Exp1,Exp2)
  Ident[Exp] to Ident.get(Exp)
  Exp+Exp to Primitives.add(Exp,Exp)... and all operators.
  */
  /*
  Warning!! java reflection don't know auto boxing. I need getMatchingMethod(String name,Class classes...) to check if that parameter is int or Integer in O(2^n) time. sucks
  byte,short,int,long,float,double,boolean... no!
  only support int,float,long,double,boolean. no bitwise operators, there are just arithmetic, boolean, assign operators for now. no tenary!
  */
  public static void main(String[] args) {
    CStyleParser p=new CStyleParser();
  }
}