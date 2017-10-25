import java.util.regex.*;
//patternMatcher.findUpdated=false;
Calculator calculator=new Calculator();
PatternMatcher patternMatcher=new PatternMatcher();
ArrayList<PatternMatcher.Result> findData=new ArrayList<PatternMatcher.Result>();
int findIndex=-1;
enum CharType {
  Undefined, Digit, Letter, Exp, Seperator, Comparator, Operator, Escape
}
enum TokenClass {
  Undefined, End, Word, Constant, Exp, Seperator, Comparator, Operator
}
enum TokenType {
  Undefined, Start, End, Number, N, Lparen, Rparen, Equal, NotEqual, Greater, Lesser, GreatEqual, LessEqual, Or, And, Plus, Minus, Multi, Divide, Modulo, UnaryMinus, UnaryPlus, IfOperator, ElseOperator
}
enum ValueType {
  Error, IntegerType, BooleanType
}
class Calculator {
  class Token {
    String text;//not need!
    TokenType type;
    TokenClass tokenclass;
    int priority;//default 0,++
    Token(TokenType type_, TokenClass tokenclass_) {
      type=type_;
      tokenclass=tokenclass_;
      priority=0;
    }
    Token(TokenType type_, TokenClass tokenclass_, int priority_) {
      type=type_;
      tokenclass=tokenclass_;
      priority=priority_;
    }
    Token(TokenType type_, TokenClass tokenclass_, String text_) {
      type=type_;
      tokenclass=tokenclass_;
      text=text_;
    }
  }
  class Result {
    ValueType type;
    int valueI;
    boolean valueB;
    Result(ValueType type_, int value_) {
      type=type_;
      valueI=value_;
    }
    Result(ValueType type_, boolean value_) {
      type=type_;
      valueB=value_;
    }
  }
  class Identifier {
    String name;
    int value;
    Identifier(String name_, int value_) {
      name=name_;
      value=value_;
    }
  }
  //[ n>5||(n>=4)]
  //( )
  //== != > < >= <= || &&//only can process in "valid"
  //+,-,*,/,%
  //other things are all ignored.
  int index=0;
  char ch='\0';
  String loadedText;
  String currentIdent;
  boolean anyIdent=true;
  ArrayList<Identifier> identifiers=new ArrayList<Identifier>();
  boolean error=false;
  public boolean matches(ArrayList<Token> in) {//must contain more than one N.
    Result res=calculate(in);
    if (res.type==ValueType.BooleanType) {
      return res.valueB;
    } else {
      error=true;
      return false;
    }
  }
  public int returnValue(ArrayList<Token> in) {//must contain more than one N.
    Result res=calculate(in);
    if (res.type==ValueType.IntegerType) {
      return res.valueI;
    } else {
      error=true;
      return 0;
    }
  }
  public void clearIdents() {
    identifiers.clear();
    identifiers.add(new Identifier("index", 0));
  }
  public boolean checkValid() {
    int a=0;
    while (a<identifiers.size()) {
      int b=a+1;
      while (b<identifiers.size()) {
        if (identifiers.get(a).name.equals(identifiers.get(b).name))return false;
        b=b+1;
      }
      a=a+1;
    }
    return true;
  }
  public void setIdent(String name, int value) {
    int a=0;
    while (a<identifiers.size()) {
      if (name.equals(identifiers.get(a).name))identifiers.get(a).value=value;
      a=a+1;
    }
  }
  public void setIdent(int name, int value) {
    identifiers.get(name).value=value;
  }
  public int getIdent(String name) {
    int a=0;
    while (a<identifiers.size()) {
      if (name.equals(identifiers.get(a).name))return identifiers.get(a).value;
      a=a+1;
    }
    return 0;
  }
  public int  getIdent(int name) {
    return identifiers.get(name).value;
  }
  public boolean isIdentExists(String name) {
    int a=0;
    while (a<identifiers.size()) {
      if (name.equals(identifiers.get(a).name))return true;
      a=a+1;
    }
    return false;
  }
  public void printTokens(ArrayList<Token> tokens) {
    print("tokens : ");
    int a=0;
    while (a<tokens.size()) {
      print(tokens.get(a).type.toString()+" - ");
      a=a+1;
    }
    println();
  }
  public Result calculate(ArrayList<Token> tokens) {
    //printTokens(tokens);
    int x=0;
    Stack<Result> result=new Stack<Result>();//result must be 1 number or boolean
    while (x<tokens.size()) {
      Token t=tokens.get(x);
      if (t.type==TokenType.N) {
        result.add(new Result(ValueType.IntegerType, getIdent(t.text)));
      } else if (t.type==TokenType.Number) {
        result.add(new Result(ValueType.IntegerType, int(t.text)));
      } else if (t.type==TokenType.Equal) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type==ValueType.IntegerType) {
          if (a.type!=ValueType.IntegerType)break;
          result.add(new Result(ValueType.BooleanType, a.valueI==b.valueI));
        } else if (b.type==ValueType.BooleanType) {
          if (a.type!=ValueType.BooleanType)break;
          result.add(new Result(ValueType.BooleanType, a.valueB==b.valueB));
        }
      } else if (t.type==TokenType.NotEqual) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type==ValueType.IntegerType) {
          if (a.type!=ValueType.IntegerType)break;
          result.add(new Result(ValueType.BooleanType, a.valueI!=b.valueI));
        } else if (b.type==ValueType.BooleanType) {
          if (a.type!=ValueType.BooleanType)break;
          result.add(new Result(ValueType.BooleanType, a.valueB!=b.valueB));
        }
      } else if (t.type==TokenType.Greater) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type!=ValueType.IntegerType||a.type!=ValueType.IntegerType)break;
        result.add(new Result(ValueType.BooleanType, a.valueI>b.valueI));
      } else if (t.type==TokenType.Lesser) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type!=ValueType.IntegerType||a.type!=ValueType.IntegerType)break;
        result.add(new Result(ValueType.BooleanType, a.valueI<b.valueI));
      } else if (t.type==TokenType.GreatEqual) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type!=ValueType.IntegerType||a.type!=ValueType.IntegerType)break;
        result.add(new Result(ValueType.BooleanType, a.valueI>=b.valueI));
      } else if (t.type==TokenType.LessEqual) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type!=ValueType.IntegerType||a.type!=ValueType.IntegerType)break;
        result.add(new Result(ValueType.BooleanType, a.valueI<=b.valueI));
      } else if (t.type==TokenType.Or) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type!=ValueType.BooleanType||a.type!=ValueType.BooleanType)break;
        result.add(new Result(ValueType.BooleanType, a.valueB||b.valueB));
      } else if (t.type==TokenType.And) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type!=ValueType.BooleanType||a.type!=ValueType.BooleanType)break;
        result.add(new Result(ValueType.BooleanType, a.valueB&&b.valueB));
      } else if (t.type==TokenType.Plus) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type!=ValueType.IntegerType||a.type!=ValueType.IntegerType)break;
        result.add(new Result(ValueType.IntegerType, a.valueI+b.valueI));
      } else if (t.type==TokenType.Minus) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type!=ValueType.IntegerType||a.type!=ValueType.IntegerType)break;
        result.add(new Result(ValueType.IntegerType, a.valueI-b.valueI));
      } else if (t.type==TokenType.Multi) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type!=ValueType.IntegerType||a.type!=ValueType.IntegerType)break;
        result.add(new Result(ValueType.IntegerType, a.valueI*b.valueI));
      } else if (t.type==TokenType.Divide) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type!=ValueType.IntegerType||a.type!=ValueType.IntegerType)break;
        result.add(new Result(ValueType.IntegerType, a.valueI/b.valueI));
      } else if (t.type==TokenType.Modulo) {
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (b.type!=ValueType.IntegerType||a.type!=ValueType.IntegerType)break;
        result.add(new Result(ValueType.IntegerType, a.valueI%b.valueI));
      } else if (t.type==TokenType.UnaryPlus) {
        //skip.nothing to do
      } else if (t.type==TokenType.UnaryMinus) {
        if (result.size()==0)break;
        Result a=result.pop();
        if (a.type!=ValueType.IntegerType)break;
        result.add(new Result(ValueType.IntegerType, -a.valueI));
      } else if (t.type==TokenType.IfOperator) {
        if (result.size()==0)break;
        Result c=result.pop();
        if (result.size()==0)break;
        Result b=result.pop();
        if (result.size()==0)break;
        Result a=result.pop();
        if (a.type!=ValueType.BooleanType||b.type!=ValueType.IntegerType||c.type!=ValueType.IntegerType)break;
        if (a.valueB) {
          result.add(new Result(ValueType.IntegerType, b.valueI));
        } else {
          result.add(new Result(ValueType.IntegerType, c.valueI));
        }
      } else {
        error=true;//internal error
      }
      //Undefined, End, Number, N, Lparen, Rparen, Equal, NotEqual, Greater, Lesser, GreatEqual, LessEqual, Or, And, Plus, Minus, Multi, Divide, Modulo, UnaryMinus, UnaryPlus
      x=x+1;
    }
    /*x=0;
     while (x<result.size()) {
     println(result.get(x).type.toString()+" "+result.get(x).valueI+" "+str(result.get(x).valueB));
     x=x+1;
     }*/
    if (x!=tokens.size())error=true;
    if (result.size()!=1)return new Result(ValueType.Error, 0);
    if (error)return new Result(ValueType.Error, 0);
    return result.get(0);
  }
  ArrayList<Token> ToBackwards(ArrayList<Token> original) {//if error, error=true;
    Stack<Token> operators=new Stack<Token>();
    ArrayList<Token> tokens=new ArrayList<Token>();
    int a=0;
    while (a<original.size()) {
      Token t=original.get(a);
      if (t.type==TokenType.Plus) {
        if (a==0)t.type=TokenType.UnaryPlus;
        else if (original.get(a-1).tokenclass==TokenClass.Seperator||original.get(a-1).tokenclass==TokenClass.Comparator)t.type=TokenType.UnaryPlus;
        if (t.type==TokenType.UnaryPlus)t.priority=5;
      } else if (t.type==TokenType.Minus) {//same
        if (a==0)t.type=TokenType.UnaryMinus;
        else if (original.get(a-1).tokenclass==TokenClass.Seperator||original.get(a-1).tokenclass==TokenClass.Comparator)t.type=TokenType.UnaryMinus;
        if (t.type==TokenType.UnaryMinus)t.priority=5;
      }
      if (t.tokenclass==TokenClass.Word||t.tokenclass==TokenClass.Constant) {
        tokens.add(t);
      } else if (t.type==TokenType.ElseOperator) {
      } else if (t.type==TokenType.Lparen) {
        operators.push(t);
      } else if (t.type==TokenType.Rparen) {
        while (operators.size()>0&&operators.peek().type!=TokenType.Lparen) {
          tokens.add(operators.pop());
        }
        if (operators.size()==0) {
          error=true;//parse error : no matching ) to find.
        } else {
          operators.pop();
        }
      } else {
        while (operators.size()>0&&operators.peek().priority>=t.priority) {
          tokens.add(operators.pop());
        }
        operators.push(t);
      }
      a=a+1;
    }
    while (operators.size()>0) {
      tokens.add(operators.pop());
    }
    return tokens;
  }
  ArrayList<Token> Parse(String text) {//gets string ends with ']' in pattern matcher.
    ArrayList<Token> tokens=new ArrayList<Token>();
    error=false;
    index=-1;//
    loadedText=text;
    currentIdent="";
    ch=nextChar();//
    Token get=NextToken();
    while (get.type!=TokenType.End) {
      if (get.type!=TokenType.Undefined&&get.type!=TokenType.Start)tokens.add(get);
      get=NextToken();
    }
    return ToBackwards(tokens);
  }
  CharType GetCharType(char c) {
    if (c=='\\')return CharType.Escape;
    if ('0'<=c&&c<='9')return CharType.Digit;
    if (c=='('||c==')')return CharType.Seperator;
    if (c=='='||c=='!'||c=='>'||c=='<'||c=='|'||c=='&')return CharType.Comparator;
    if (c=='+'||c=='-'||c=='*'||c=='/'||c=='%'||c=='?'||c==':')return CharType.Operator;
    if (c=='['||c==']')return CharType.Exp;
    else return CharType.Letter;
  }
  Token NextToken () {//Digit, Letter,Seperator, Sign, Escape
    if (ch=='[') {
      ch=nextChar();
      return new Token(TokenType.Start, TokenClass.Undefined);
    }
    if (ch==']')return new Token(TokenType.End, TokenClass.End);
    while (ch==' '||ch=='\n'||ch=='\t')ch=nextChar ();//skip spaces
    if (GetCharType (ch)==CharType.Letter||GetCharType(ch)==CharType.Escape) {//can be keyword or identifier of const!
      String text="";
      while (GetCharType (ch)==CharType.Letter||GetCharType (ch)==CharType.Digit||GetCharType(ch)==CharType.Escape) {
        text+=ch;
        ch=nextChar ();
        if (GetCharType(ch)==CharType.Escape) {
          ch=nextChar();
          if (ch=='0')ch='\0';
          else if (ch=='n')ch='\n';//these 3 are not allowed in textbox.
          else if (ch=='r')ch='\r';
          else if (ch=='t')ch='\t';
          else if (ch=='\\')ch='\\';
          else if (ch=='[')ch='[';
          else if (ch==']')ch=']';
          else return new Token(TokenType.Undefined, TokenClass.Undefined, text);
        }
      }
      if (anyIdent) {
        if (currentIdent.equals("")) {
          currentIdent=text;
          identifiers.add(new Identifier(currentIdent, 0));
        }
        if (text.equals("index"))return new Token(TokenType.N, TokenClass.Word, text);
        else if (text.equals("frame"))return new Token(TokenType.N, TokenClass.Word, text);
        else if (text.equals(currentIdent))return new Token(TokenType.N, TokenClass.Word, text);
        else return new Token(TokenType.Undefined, TokenClass.Undefined, text);
      } else {
        if (isIdentExists(text))return new Token(TokenType.N, TokenClass.Word, text);
        else return new Token(TokenType.Undefined, TokenClass.Undefined, text);
      }
    } else if (GetCharType (ch)==CharType.Digit) {//can be int or float
      String text="";
      while (GetCharType (ch)==CharType.Digit) {
        text+=ch;
        ch=nextChar ();
      }
      return new Token(TokenType.Number, TokenClass.Constant, text);
    } else if (GetCharType (ch)==CharType.Seperator) {
      char text=ch;
      ch=nextChar();
      if (text=='(')return new Token(TokenType.Lparen, TokenClass.Seperator, 0);
      if (text==')')return new Token(TokenType.Rparen, TokenClass.Seperator, 0);
      return new Token(TokenType.Undefined, TokenClass.Undefined, "Seperator");
    } else if (GetCharType (ch)==CharType.Comparator) {
      String text="";
      while (GetCharType (ch)==CharType.Comparator) {
        text+=ch;
        ch=nextChar ();
      }
      if (text.equals("=="))return new Token(TokenType.Equal, TokenClass.Comparator, 2);
      if (text.equals("!="))return new Token(TokenType.NotEqual, TokenClass.Comparator, 2);
      if (text.equals(">"))return new Token(TokenType.Greater, TokenClass.Comparator, 2);
      if (text.equals("<"))return new Token(TokenType.Lesser, TokenClass.Comparator, 2);
      if (text.equals(">="))return new Token(TokenType.GreatEqual, TokenClass.Comparator, 2);
      if (text.equals("<="))return new Token(TokenType.LessEqual, TokenClass.Comparator, 2);
      if (text.equals("||"))return new Token(TokenType.Or, TokenClass.Comparator, 1);
      if (text.equals("&&"))return new Token(TokenType.And, TokenClass.Comparator, 1);
      return new Token(TokenType.Undefined, TokenClass.Undefined, text);
    } else if (GetCharType(ch)==CharType.Operator) {
      String text="";
      while (GetCharType (ch)==CharType.Operator) {
        text+=ch;
        ch=nextChar ();
      }
      if (text.equals("*"))return new Token(TokenType.Multi, TokenClass.Operator, 4);
      if (text.equals("/"))return new Token(TokenType.Divide, TokenClass.Operator, 4);
      if (text.equals("%"))return new Token(TokenType.Modulo, TokenClass.Operator, 4);
      if (text.equals("+")) {//no unary check
        return new Token(TokenType.Plus, TokenClass.Operator, 3);
      }
      if (text.equals("-")) {
        return new Token(TokenType.Minus, TokenClass.Operator, 3);
      }
      if (text.equals("?"))return new Token(TokenType.IfOperator, TokenClass.Operator, 1);
      if (text.equals(":"))return new Token(TokenType.ElseOperator, TokenClass.Operator, 1);
      return new Token(TokenType.Undefined, TokenClass.Undefined, text);
    } else {
      String text=""+ch;
      while (GetCharType (ch)==CharType.Undefined) {
        text+=ch;
        ch=nextChar ();
      }
      return new Token(TokenType.Undefined, TokenClass.Undefined, text);
    }
  }
  char nextChar () {
    index++;
    if (index>=loadedText.length()) {
      error=true;
      return ']';
    }
    return loadedText.charAt(index);
  }
  ArrayList<ArrayList> scripts=new ArrayList<ArrayList>();
  String getRegex(String in) {
    //error=false;
    clearIdents();
    scripts=new ArrayList<ArrayList>();
    anyIdent=true;
    int a=0;
    ArrayList<StringBuilder> ret=new ArrayList<StringBuilder>();
    ret.add(new StringBuilder(""));
    while (a<in.length()) {
      if (in.charAt(a)=='[') {
        StringBuilder scr=new StringBuilder("");
        while (in.charAt(a)!=']') {
          scr.append(in.charAt(a));
          a++;
          if (a>=in.length())return null;//error
        }
        scr.append(']');
        //println("parsing... : "+scr.toString());
        scripts.add(Parse(scr.toString()));
        //println("parsed : "+scr.toString());
        if (currentIdent.equals(""))return null;//in find, must requires one identifier.
        if (ret.get(ret.size()-1).equals("")==false)ret.set(ret.size()-1, new StringBuilder(Pattern.quote(ret.get(ret.size()-1).toString())));
        ret.add(new StringBuilder("(-?\\d+)"));//https://stackoverflow.com/questions/2367381/how-to-extract-numbers-from-a-string-and-get-an-array-of-ints
        ret.add(new StringBuilder(""));
      } else if (in.charAt(a)=='\\') {
        a=a+1;
        char cha='\0';
        if (a>=in.length())return null;//error
        else if (in.charAt(a)=='n')cha='\n';//these 3 are not allowed in textbox.
        else if (in.charAt(a)=='r')cha='\r';
        else if (in.charAt(a)=='t')cha='\t';
        else if (in.charAt(a)=='\\')cha='\\';
        else if (in.charAt(a)=='[')cha='[';
        else if (in.charAt(a)==']')cha=']';
        else error=true;
        if (cha!='\0')ret.get(ret.size()-1).append(cha);
      } else if (in.charAt(a)==']') {
        error=true;
      } else {
        ret.get(ret.size()-1).append(in.charAt(a));
      }
      a=a+1;
    }
    if (ret.get(ret.size()-1).equals("")==false)ret.set(ret.size()-1, new StringBuilder(Pattern.quote(ret.get(ret.size()-1).toString())));
    StringBuilder build=new StringBuilder();
    a=0;
    while (a<ret.size()) {
      build.append(ret.get(a).toString());
      a=a+1;
    }
    identifiers.add(new Identifier("frame", 0));
    if (error)return null;
    if (checkValid()==false)return null;
    return build.toString();
  }
  ArrayList<ArrayList> getScriptsWithoutClear(String in) {
    //if (error)return null;
    currentIdent="index";
    anyIdent=false;
    ArrayList<ArrayList> scripts2=new ArrayList<ArrayList>();
    int a=0;
    while (a<in.length()) {
      if (in.charAt(a)=='[') {
        StringBuilder scr=new StringBuilder("");
        while (in.charAt(a)!=']') {
          scr.append(in.charAt(a));
          a++;
          if (a>=in.length())return null;//error
        }
        scr.append(']');
        //println("parsing... : "+scr.toString());
        scripts2.add(Parse(scr.toString()));
        if (error)return null;
        //println("parsed : "+scr.toString());
      } else if (in.charAt(a)=='\\') {
        a=a+1;
        char cha='\0';
        if (a>=in.length())return null;//error
        else if (in.charAt(a)=='n')cha='\n';//these 3 are not allowed in textbox.
        else if (in.charAt(a)=='r')cha='\r';
        else if (in.charAt(a)=='t')cha='\t';
        else if (in.charAt(a)=='\\')cha='\\';
        else if (in.charAt(a)=='[')cha='[';
        else if (in.charAt(a)==']')cha=']';
        else error=true;
      } else if (in.charAt(a)==']')return null;
      a=a+1;
    }
    return scripts2;
  }
}
class PatternMatcher {
  class Result {
    int startpoint;
    String text;
    int[] args;
    Result(int startpoint_, String text_, int[] args_) {
      startpoint=startpoint_;
      text=text_;
      args=args_;
    }
    String toString() {
      return startpoint+" : "+text;
    }
  }
  Pattern patternFind;
  Pattern patternReplace;
  Matcher matcher;
  boolean error=true;
  boolean errorFind=true;//
  boolean errorReplace=true;//
  boolean findUpdated=false;
  ArrayList<ArrayList> replacer;
  String getRegex(String in, boolean isregex) {
    if (isregex)return calculator.getRegex(in);
    else {
      calculator.clearIdents();
      calculator.scripts=new ArrayList<ArrayList>();
      return Pattern.quote(in);
    }
  }
  boolean registerFind(String pattern_, boolean isregex) {
    error=true;
    errorFind=true;
    if (pattern_==null)return false;
    if (pattern_.equals(""))return false;
    String regex=getRegex(pattern_, isregex);
    if (regex==null) {
      return false;
    }
    error=false;
    printLog("PatternMatcher.register()", "regex : "+regex+" (frame : "+frameCount+")");
    patternFind = Pattern.compile(regex);
    findUpdated=false;
    //if error, there is internal error!
    return true;
  }
  boolean registerReplace(String pattern_, boolean isregex) {
    if (isregex)replacer=new ArrayList<ArrayList>();
    error=true;
    errorReplace=true;
    if (pattern_==null)return false;
    //if (pattern_.equals(""))return false;
    replacer=calculator.getScriptsWithoutClear(pattern_);
    if (replacer==null) {
      println(frameCount+" "+"???");
      return false;
    }
    //if (replacer.size()>=3)calculator.printTokens(replacer.get(2));
    errorReplace=false;
    error=false;
    //if error, there is internal error!
    return true;
  }
  ArrayList<Result> findAll(String text) {
    findUpdated=true;
    if (patternFind==null)error=true;
    ArrayList<Result> ret=new ArrayList<Result>();
    if (error==false) {
      matcher = patternFind.matcher(text);
      while (matcher.find()) {
        Result result=new Result(matcher.start(), matcher.group(), new int[matcher.groupCount()]);
        if (calculator.scripts.size()!=0) {
          int b=1;
          while (b<=matcher.groupCount()) {
            //extract number
            result.args[b-1]=int(matcher.group(b));
            calculator.setIdent(b, result.args[b-1]);//added by order.
            b++;
          }
          //internal error occured...?
          b=0;
          while (b<calculator.scripts.size()) {
            if (calculator.matches(calculator.scripts.get(b))==false)break;
            b=b+1;
          }
          if (b==calculator.scripts.size()) {
            //println("start/"+result.startpoint+" text/"+result.text);
            ret.add(result);
          }
        } else {
          //println("start/"+result.startpoint+" text/"+result.text);
          ret.add(result);
        }
      }
      errorFind=false;
      println("successed! : "+ret.size()+" /time : "+frameCount);
    } else {
      println("failed! : /time : "+frameCount);
    }
    findIndex=min(ret.size()-1, findIndex);
    return ret;
  }
  String replaceAll(String text, String in, ArrayList<Result> results) {
    //reuse same scripts!
    String originalText=text;
    if (errorReplace==false) {
      ArrayList<StringBuilder> build=buildResult(in);
      int offset=0;
      int a=0;
      while (a<results.size()) {
        Result result=results.get(a);
        int b=0;
        while (b<calculator.identifiers.size()-2/*1*//*matcher.groupCount()*/) {//WARNING!!!
          //extract number
          calculator.setIdent(b+1, result.args[b]);//added by order.
          b++;
        }
        calculator.setIdent(0, a);
        calculator.setIdent("frame", analyzer.getFrame(Lines.getLineByIndex(result.startpoint)));
        StringBuilder sb=new StringBuilder("");
        b=0;
        while (b<build.size()-1/*replacer.size()*/) {//WARNING!!!
          sb.append(build.get(b).toString());
          sb.append(calculator.returnValue(replacer.get(b)));//if build.size()==0, skip.
          if (calculator.error) {
            errorReplace=true;
            println("failed! : /time : "+frameCount);
            return originalText;
          }
          b=b+1;
        }
        sb.append(build.get(b).toString());//error???
        text=text.substring(0, result.startpoint+offset)+sb.toString()+text.substring(result.startpoint+result.text.length()+offset, text.length());
        offset=offset+sb.length()-result.text.length();
        a=a+1;
      }
      println("successed! : "+results.size()+" /time : "+frameCount);
    } else {
      errorReplace=true;
      println("failed! : /time : "+frameCount);
    }
    return text;
  }
  ArrayList<StringBuilder> buildResult(String in) {
    int a=0;
    ArrayList<StringBuilder> ret=new ArrayList<StringBuilder>();
    ret.add(new StringBuilder(""));
    while (a<in.length()) {
      if (in.charAt(a)=='[') {
        StringBuilder scr=new StringBuilder("");
        while (in.charAt(a)!=']') {
          scr.append(in.charAt(a));
          a++;
          if (a>=in.length())return null;//error
        }
        //scr.append(']');
        //scripts.add(Parse(scr.toString()));
        //ret.add(new StringBuilder("(-?\\d+)"));//https://stackoverflow.com/questions/2367381/how-to-extract-numbers-from-a-string-and-get-an-array-of-ints
        ret.add(new StringBuilder(""));
      } else if (in.charAt(a)=='\\') {
        a=a+1;
        char cha='\0';
        if (a>=in.length())return null;//error
        else if (in.charAt(a)=='n')cha='\n';//these 3 are not allowed in textbox.
        else if (in.charAt(a)=='r')cha='\r';
        else if (in.charAt(a)=='t')cha='\t';
        else if (in.charAt(a)=='\\')cha='\\';
        else if (in.charAt(a)=='[')cha='[';
        else if (in.charAt(a)==']')cha=']';
        else error=true;
        if (cha!='\0')ret.get(ret.size()-1).append(cha);
      } else {
        ret.get(ret.size()-1).append(in.charAt(a));
      }
      a=a+1;
    }
    return ret;
  }
}
/*
  PatternMatcher m=new PatternMatcher("asd");
 ArrayList<PatternMatcher.Result> res=m.find("asdasasasdfasfsafssgaaasdsasdgfasasdagfascdasdd");
 int a=0;
 while (a<res.size()) {
 println(res.get(a).toString());
 a=a+1;
 }
 */