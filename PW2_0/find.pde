static HashMap<String, MultiFunction<?>> functions=new HashMap<String, MultiFunction<?>>(37);//number is random prime number...
@SuppressWarnings("unused")
  void findReplace_setup() {
  new MultiFunction<Integer>("min", Integer.class, Integer.class) {
    public Integer apply(Object... in) {
      return Math.min((int)in[0], (int)in[1]);
    }
  };
  new MultiFunction<Integer>("max", Integer.class, Integer.class) {
    public Integer apply(Object... in) {
      return Math.max((int)in[0], (int)in[1]);
    }
  };
  new MultiFunction<Object>("if", Boolean.class, Object.class, Object.class) {
    public Object apply(Object... in) {
      if ((boolean)in[0]) {
        return in[1];
      } else {
        return in[2];
      }
    }
  };
  SyntaxNode.setup_charType();
}
//
class NormalFindReplace {
  ArrayList<FindData> findData=new ArrayList<FindData>();
  int findIndex=-1;//index iterator for next/prev
  Pattern patternFind;
  String patternReplace;
  boolean textChanged=false;//if true, do findall in next/previous.
  void compileFind(String findText, boolean isRegex, String text) {//use this in change find text.
    if (findText.isEmpty()) {
      patternFind=null;
    } else {
      if (isRegex) {
        patternFind=Pattern.compile(findText);
      } else {
        patternFind=Pattern.compile(Pattern.quote(findText));
      }
    }
    findAll(text);
  }
  @SuppressWarnings("unused")
    void compileReplace(String replaceText, boolean isRegex) {
    patternReplace=replaceText;
    //if (isRegex) {
    //  patternReplace=replaceText;
    //} else {
    //  patternReplace=Pattern.quote(replaceText);
    //}
  }
  void changeText(String text) {//use this in change text.
    findAll(text);
  }
  private void findAll(String text) {
    findData.clear();
    if (patternFind==null) {
      return;
    }
    Matcher matcher = patternFind.matcher(text);
    while (matcher.find()) {
      FindData result=new FindData(matcher.start(), matcher.group(), 0);//one more space for frame and index.
      findData.add(result);
    }
    findIndex=min(findData.size()-1, findIndex);
    //println("matches : "+findData.size());
    textChanged=true;
  }
  String replaceAll(String text) {
    //compileReplace(replaceText, isRegex);
    if (patternFind==null||patternReplace==null) {
      return text;
    }
    return patternFind.matcher(text).replaceAll(patternReplace);
  }
}
//find replace for only led editor.
static final String REGEX_NUMBER="(-?\\d+)";
class LedFindReplace {
  ArrayList<FindData> findData=new ArrayList<FindData>();
  int findIndex=-1;//index iterator for next/prev
  Pattern patternFindRegex;
  FindReplacePattern patternFind;
  FindReplacePattern patternReplace;
  boolean textChanged=false;//if true, do findall in next/previous.
  Calculator calculator=new Calculator();
  void compileFind(String findText, boolean isRegex, String text) {//use this in change find text.
    patternFindRegex = Pattern.compile(getRegex(findText, isRegex));
    if (isRegex) {
      patternFind=FindReplacePattern.compile(findText);
    } else {
      patternFind=FindReplacePattern.compile(FindReplacePattern.quote(findText));
    }
    findAll(text);
  }
  void compileReplace(String replaceText, boolean isRegex) {
    if (isRegex) {
      patternReplace=FindReplacePattern.compile(replaceText);
    } else {
      patternReplace=FindReplacePattern.compile(FindReplacePattern.quote(replaceText));
    }
  }
  void changeText(String text) {//use this in change text.
    findAll(text);
  }
  private void findAll(String text) {
    findData.clear();
    if (patternFind==null) {
      return;
    }
    calculator.vars.clear();
    if (patternFind.isEmpty()) {
      return;
    }
    if (patternFind.error) {
      return;
    }
    Matcher matcher = patternFindRegex.matcher(text);
    int groupCount=0;
    while (matcher.find()) {
      FindData result=new FindData(matcher.start(), matcher.group(), (groupCount=matcher.groupCount())+2);//one more space for frame and index.
      boolean match=true;
      for (int a=1; a<=matcher.groupCount(); a++) {// get variable values
        result.vars[a-1]=Integer.parseInt(matcher.group(a));
        calculator.vars.put(patternFind.varname.get(a-1), a-1);//vars equal index number
      }
      for (int a=1; a<=matcher.groupCount(); a++) {// expression result is true?
        Object value=calculator.calculate(patternFind.expression.get(a-1), result.vars);
        if (value instanceof Boolean&& value.equals(false)) {
          match=false;
        }
      }
      if (match) {
        findData.add(result);
      }
    }
    calculator.vars.put("index", groupCount);
    calculator.vars.put("frame", groupCount+1);
    findIndex=min(findData.size()-1, findIndex);
    //println("matches : "+findData.size());
    textChanged=true;
  }
  String replaceAll(String text) {
    if (patternFind==null||patternReplace==null) {
      return text;
    }
    //compileReplace(replaceText, isRegex);
    if (patternFind.error||patternReplace.error) {
      return text;
    }
    StringBuilder ret=new StringBuilder(text);
    int offset=0;
    for (int a=0; a<findData.size(); a++) {
      FindData data=findData.get(a);
      //set index and frame.
      data.vars[data.vars.length-2]=a;//index
      data.vars[data.vars.length-1]=currentLedEditor.getFrame(currentLedEditor.getLineByIndex(data.start));
      StringBuilder buildResult=patternReplace.buildResult(calculator, data.vars);
      ret.replace(data.start+offset, data.start+offset+data.text.length(), buildResult.toString());
      offset=offset+buildResult.length()-data.text.length();
    }
    return ret.toString();
  }
  private String getRegex(String findText, boolean isRegex) {
    if (isRegex) {
      StringBuilder ret=new StringBuilder();
      FindReplacePattern p=FindReplacePattern.compile(findText);
      for (Object o : p.data) {
        if (o instanceof String) {
          ret.append(Pattern.quote((String)o));
        } else if (o instanceof SyntaxNode) {
          ret.append(REGEX_NUMBER);
        }
      }
      return ret.toString();
    } else {
      return Pattern.quote(findText);
    }
  }
}
class FindData {
  int start;
  int end;
  String text;
  Object[] vars;
  public FindData(int start_, String text_, int count) {
    start=start_;
    text=text_;
    end=start+text.length();
    vars=new Object[count];
  }
}
static class FindReplacePattern {
  static int TEXT=1;
  static int EXP=2;
  LinkedList<Object> data=new LinkedList<Object>();// contains String and Expression
  ArrayList<SyntaxNode> expression=new ArrayList<SyntaxNode>();// only contains Expression in data.
  ArrayList<String> varname=new ArrayList<String>();//this is for pattenrFind, it must have one varname per expression.
  boolean error=false;
  StringBuilder buildResult(Calculator c, Object[] values) {//integer is values index.
    //c.vars has set.
    StringBuilder ret=new StringBuilder();
    for (Object o : data) {
      if (o instanceof String) {
        ret.append((String)o);
      } else {// if(o instanceof SyntaxNode){
        ret.append(c.calculate((SyntaxNode)o, values).toString());
      }
    }
    return ret;
  }
  static FindReplacePattern compile(String text) {
    if (text.isEmpty()) {
      return new FindReplacePattern();
    }
    FindReplacePattern pattern=new FindReplacePattern();
    String escaped=pattern.escape(text);
    StringBuilder token=new StringBuilder();
    int tokenType=TEXT;
    for (int a=0; a<escaped.length(); a++) {
      if (escaped.charAt(a)=='\\'&&a+1<escaped.length()) {
        if (escaped.charAt(a+1)=='['||escaped.charAt(a+1)==']') {
          a++;
        }
      } else if (escaped.charAt(a)=='[') {
        if (tokenType==TEXT) {
          pattern.data.add(token.toString());
          tokenType=EXP;
          token=new StringBuilder();
          continue;
        } else {//no maching brace is error.
          pattern.error=true;
        }
      } else if (escaped.charAt(a)==']') {
        if (tokenType==EXP) {
          SyntaxNode exp;
          pattern.data.add(exp=SyntaxNode.compile(token.toString()));
          if (exp.type==SyntaxNode.Type.Error) {
            pattern.error=true;
          }
          pattern.expression.add(exp);
          pattern.varname.add(exp.getFirstVarName());
          tokenType=TEXT;
          token=new StringBuilder();
          continue;
        } else {
          pattern.error=true;
        }
      }
      token.append(escaped.charAt(a));
    }
    if (tokenType==TEXT) {//last must be text.
      pattern.data.add(token.toString());
    } else {//no maching brace is error.
      pattern.error=true;
    }
    return pattern;
  }
  boolean isEmpty() {
    return data.size()==0;
  }
  static String quote(String in) {//replace [ ] to \[ \]
    StringBuilder ret=new StringBuilder();
    for (int a=0; a<in.length(); a++) {
      if (in.charAt(a)=='['||in.charAt(a)==']') {
        ret.append('\\');
      }
      ret.append(in.charAt(a));
    }
    return ret.toString();
  }
  String escape(String in) {
    StringBuilder ret=new StringBuilder();
    for (int a=0; a<in.length(); a++) {
      if (in.charAt(a)=='\\') {
        a++;
        if (a<in.length()) {
          if (in.charAt(a)=='n') {
            ret.append('\n');
          } else if (in.charAt(a)=='r') {
            ret.append('\r');
          } else if (in.charAt(a)=='t') {
            ret.append('\t');
          } else if (in.charAt(a)=='f') {
            ret.append('\f');
          } else if (in.charAt(a)=='b') {
            ret.append('\b');
          } else if (in.charAt(a)=='\\') {
            ret.append('\\');
          } else {
            ret.append(in.charAt(a));//else treat there is no escape character instead making error.
          }
          //no string escapes here (only space characters and meta symbols escape)
        } else {
          error=true;
        }
      } else {
        ret.append(in.charAt(a));
      }
    }
    return ret.toString();
  }
}
//
//1+2 -> (+ 1 2) op val val
//(1+2)*3 -> (* (+ 1 2) 3)
//max(1,2+3) -> (max 1 (+ 2 3))
//
static class SyntaxNode {
  static enum OpType {
    Error, None, Function, Seperator, //,
      Plus, Minus, Multi, Divide/*,Pow*/, Mod, 
      //+ - * / ^ % 
      Equal, NotEq, Great, Less, GreatEq, LessEq, 
      //== != > < >= <=
      And, Or, 
      UnaryMinus, UnaryPlus //processed on parsing
      //&& ||
      //no tenary operator
  }
  static int[] OpPriority=new int[]{0, 0, 0, 1, 
    5, 5, 6, 6, 6, 
    4, 4, 4, 4, 4, 4, 
    3, 3, 
    2, 2};
  static int getPriority(OpType op) {
    return OpPriority[op.ordinal()];
  }
  static int getParameterCount(SyntaxNode n) {
    if (n.operator==OpType.UnaryPlus||n.operator==OpType.UnaryMinus) {
      return 1;
    } else if (n.operator==OpType.None||n.operator==OpType.Error) {
      return 0;
    } else if (n.operator==OpType.Function) {
      if (functions.containsKey(n.text)) {
        return functions.get(n.text).parameterCount;
      } else {
        n.type=Type.Error;
        return 0;
      }
    } else {
      return 2;
    }
  }
  static enum CharType {
    None, Op, LParen, RParen, Comma//->end?
      //ex) +- is operator : equal to unary minus
  }
  static enum Type {
    Error, IntVal, BoolVal, Ident, Op
  }
  static final SyntaxNode LParen=new SyntaxNode("(", OpType.None);//used in parsing, not stored in ast.
  static final SyntaxNode RParen=new SyntaxNode(")", OpType.None);
  static final SyntaxNode Comma=new SyntaxNode("*", OpType.Seperator);
  static CharType[] charType=new CharType[128];//else = 
  static void setup_charType() {
    for (int a=0; a<charType.length; a++) {
      charType[0]=CharType.None;
    }
    charType[',']=CharType.Comma;
    charType['(']=CharType.LParen;
    charType[')']=CharType.RParen;
    charType['+']=CharType.Op;
    charType['-']=CharType.Op;
    charType['*']=CharType.Op;
    charType['/']=CharType.Op;
    charType['%']=CharType.Op;
    charType['=']=CharType.Op;
    charType['!']=CharType.Op;
    charType['>']=CharType.Op;
    charType['<']=CharType.Op;
    charType['&']=CharType.Op;
    charType['|']=CharType.Op;
  }
  static CharType getCharType(char in) {
    if (in<charType.length) {
      return charType[in];
    } else {
      return CharType.None;
    }
  }
  Type type=Type.Error;//default
  OpType operator=OpType.Function;
  ArrayList<SyntaxNode> nodes=new ArrayList<SyntaxNode>();
  String firstVar=null;//fill it in root.
  String text;
  public SyntaxNode() {
  }
  public SyntaxNode(String text_, OpType unaryType) {
    text=text_;
    type=Type.Op;
    operator=unaryType;
  }
  public SyntaxNode(String text_, LinkedList<SyntaxNode> processUnary) {//one token input. no exp/error
    text=text_;
    if (Analyzer.isInt(text)) {
      type=Type.IntVal;
    } else if (Analyzer.isBoolean(text)) {
      type=Type.BoolVal;
    } else if (getCharType(text.charAt(0))==CharType.Op) {
      type=Type.Op;
      if (!text.equals("-")&&text.endsWith("-")) {
        text=text.substring(0, text.length()-1);
        processUnary.addLast(new SyntaxNode("-", OpType.UnaryMinus));
      } else if (!text.equals("+")&&text.endsWith("+")) {
        text=text.substring(0, text.length()-1);
        processUnary.addLast(new SyntaxNode("-", OpType.UnaryPlus));
      }
      if (text.equals("+")) {
        operator=OpType.Plus;
      } else if (text.equals("+")) {
        operator=OpType.Plus;
      } else if (text.equals("-")) {
        operator=OpType.Minus;
      } else if (text.equals("*")) {
        operator=OpType.Multi;
      } else if (text.equals("/")) {
        operator=OpType.Divide;
      } else if (text.equals("%")) {
        operator=OpType.Mod;
      } else if (text.equals("==")) {
        operator=OpType.Equal;
      } else if (text.equals("!=")) {
        operator=OpType.NotEq;
      } else if (text.equals(">")) {
        operator=OpType.Great;
      } else if (text.equals("<")) {
        operator=OpType.Less;
      } else if (text.equals(">=")) {
        operator=OpType.GreatEq;
      } else if (text.equals("<=")) {
        operator=OpType.LessEq;
      } else if (text.equals("&&")) {
        operator=OpType.And;
      } else if (text.equals("||")) {
        operator=OpType.Or;
      } else {
        operator=OpType.Error;
      }
    } else {
      type=Type.Ident;//you can use anything
    }
  }
  public SyntaxNode(SyntaxNode... nodes_) {
    nodes.addAll(Arrays.asList(nodes_));
  }
  static SyntaxNode compile(String text) {//this object is root node.
    SyntaxNode root=new SyntaxNode();
    root.type=Type.Op;
    root.operator=OpType.None;
    if (text.isEmpty()) {
      root.type=Type.Error;
    } else {
      LinkedList<SyntaxNode> tokens_infix=new LinkedList<SyntaxNode>();
      {//first, lexing.
        StringBuilder token=new StringBuilder();
        CharType charType=CharType.None;//hide
        CharType pCharType;
        int a=0;
        token.append(text.charAt(a));
        charType=getCharType(text.charAt(a));
        for (a++; a<text.length(); a++) {
          pCharType=charType;
          charType=getCharType(text.charAt(a));
          if (pCharType!=charType) {
            if (token.toString().equals("(")) {
              if (!tokens_infix.isEmpty()&&tokens_infix.getLast().type==Type.Ident) {
                tokens_infix.getLast().type=Type.Op;
                tokens_infix.getLast().operator=OpType.Function;
              }
              tokens_infix.add(LParen);
            } else if (token.toString().equals(")")) {
              println("added rparen");
              tokens_infix.add(RParen);
            } else if (token.toString().equals(",")) {
              tokens_infix.add(Comma);
            } else {
              SyntaxNode added;
              tokens_infix.add(added=new SyntaxNode(token.toString(), tokens_infix));
              if (added.type==Type.Op&&added.operator==OpType.Error) {
                root.type=Type.Error;
              }
            }
            token=new StringBuilder();
          }
          token.append(text.charAt(a));
        }
        if (token.toString().equals("(")) {
          if (!tokens_infix.isEmpty()&&tokens_infix.getLast().type==Type.Ident) {
            tokens_infix.getLast().type=Type.Op;
            tokens_infix.getLast().operator=OpType.Function;
          }
          tokens_infix.add(LParen);
        } else if (token.toString().equals(")")) {
          println("added rparen");
          tokens_infix.add(RParen);
        } else if (token.toString().equals(",")) {
          tokens_infix.add(Comma);
        } else {
          SyntaxNode added;
          tokens_infix.add(added=new SyntaxNode(token.toString(), tokens_infix));
          if (added.type==Type.Op&&added.operator==OpType.Error) {
            root.type=Type.Error;
          }
        }
      }
      LinkedList<SyntaxNode> tokens_postfix=new LinkedList<SyntaxNode>();
      {//second, change to postfix.
        //FIX : rparen is added to opstack and tokens_postfix. 
        LinkedList<SyntaxNode> parenStack=new LinkedList<SyntaxNode>();
        LinkedList<SyntaxNode> opStack=new LinkedList<SyntaxNode>();
        while (!tokens_infix.isEmpty()) {
          SyntaxNode process=tokens_infix.pollFirst();
          if (process==LParen) {
            opStack.addLast(process);
            parenStack.addLast(process);
          } else if (process==RParen) {
            if (parenStack.isEmpty()) {
              root.type=Type.Error;
            } else {
              parenStack.removeLast();
            }
            flushOpStack(tokens_postfix, opStack, getPriority(process.operator));
          } else if (process.type==Type.Op) {
            if (process.operator==OpType.Function) {
              opStack.addLast(process);
              if (!tokens_infix.isEmpty()&&tokens_infix.getFirst()==LParen) {
                tokens_infix.removeFirst();//ignore one LParen, function will closed with RParen.
                parenStack.addLast(process);
              } else {
                root.type=Type.Error;
              }
            } else {//unary minus  and plus -> auto?
              flushOpStack(tokens_postfix, opStack, getPriority(process.operator));
              if (process!=Comma) {
                opStack.addLast(process);
              }
            }
          } else {//val or ident
            tokens_postfix.addLast(process);
          }
        }
        flushOpStack(tokens_postfix, opStack, -1);
        if (!opStack.isEmpty()) {
          root.type=Type.Error;
        }
      }
      for (SyntaxNode n : tokens_postfix) {
        println(n.text);
      }
      println("========");
      //if expression have error, we cant build tree.
      if (root.type==Type.Error) {
        return root;
      }
      {//third, get first var name.
        for (SyntaxNode n : tokens_postfix) {
          if (n.type==Type.Ident) {
            root.firstVar=n.text;
            break;
          }
        }
      }
    build_tree:
      {//last, build tree.
        LinkedList<SyntaxNode> stack=new LinkedList<SyntaxNode>();
        while (!tokens_postfix.isEmpty()) {//last 1 will be added to root, start point.
          SyntaxNode process=tokens_postfix.pollFirst();
          if (process.type==Type.Op) {
            int parameterCount=getParameterCount(process);
            if (process.type==Type.Error) {
              root.type=Type.Error;
              break build_tree;
            }
            for (int a=0; a<parameterCount; a++) {
              if (stack.isEmpty()) {
                root.type=Type.Error;
                break build_tree;
              }
              process.nodes.add(stack.pollLast());
            }
          }
          stack.addLast(process);
        }
        if (stack.size()==1) {
          root.nodes.add(stack.getLast());
        } else {
          root.type=Type.Error;
        }
      }
    }
    return root;
  }
  static void flushOpStack(LinkedList<SyntaxNode> tokens_postfix, LinkedList<SyntaxNode> opStack, int priority) {//move until opStack.priority is smaller than priority.
    while (!opStack.isEmpty()&&getPriority(opStack.getLast().operator)>=priority) {
      SyntaxNode process=opStack.pollLast();
      if (process!=LParen) {
        tokens_postfix.addLast(process);
      }
      if (getPriority(process.operator)==0) {//only pop one 0 priority ops.
        break;
      }
    }
  }
  String getFirstVarName() {
    return firstVar;
  }
}
static String toString(Class[] in) {
  StringBuilder ret=new StringBuilder("(");
  if (in.length!=0) {
    ret.append(in[0].toString());
    for (int a=1; a<in.length; a++) {
      ret.append(", ");
      ret.append(in[a].toString());
    }
  }
  return ret.append(")").toString();
}
static String toClassString(Object[] in) {
  StringBuilder ret=new StringBuilder("(");
  if (in.length!=0) {
    ret.append(in[0].getClass().getSimpleName());
    for (int a=1; a<in.length; a++) {
      ret.append(", ");
      ret.append(in[a].getClass().getSimpleName());
    }
  }
  return ret.append(")").toString();
}
static abstract class MultiFunction<ReturnType> {
  int parameterCount;
  Class[] paramClass;
  MultiFunction(String name, Class... paramClass_) {
    functions.put(name, this);
    paramClass=paramClass_;
    parameterCount=paramClass.length;
  }
  public abstract ReturnType apply(Object... params);//match with java.util.function.Function
  public ReturnType execute(Object... in) {
    for (int a=0; a<parameterCount; a++) {
      if (!paramClass[a].isAssignableFrom(in[a].getClass())) {
        throw new RuntimeException("type mismatch : required "+PW2_0.toString(paramClass)+" received "+toClassString(in));
      }
    }
    return apply(in);
  }
}
class Calculator {
  HashMap<String, Integer> vars=new HashMap<String, Integer>(101);//real use in calculation
  Object calculate(SyntaxNode exp, Object[] values) {
    return calculate(exp, values, new LinkedList<Object>());
  }
  Object calculate(SyntaxNode exp, Object[] values, LinkedList<Object> stack) {
    if (exp.type==SyntaxNode.Type.IntVal) {
      return Integer.parseInt(exp.text);
    } else if (exp.type==SyntaxNode.Type.BoolVal) {
      return exp.text.startsWith("t");//true
    } else if (exp.type==SyntaxNode.Type.Ident) {
      return values[vars.get(exp.text)];//ADD existence check
    } else {//only op.
      for (SyntaxNode n : exp.nodes) {
        stack.addLast(calculate(n, values, stack));
      }
      //ADD operate
      return 0;
    }
  }
}