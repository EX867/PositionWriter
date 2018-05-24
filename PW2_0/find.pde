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
        Object value=calculator.calculate(patternFind.expression.get(a));
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
      StringBuilder buildResult=patternReplace.buildResult(calculator.vars, data.vars);
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
          ret.append((String)o);
        } else if (o instanceof Expression) {
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
  ArrayList<Expression> expression=new ArrayList<Expression>();// only contains Expression in data.
  ArrayList<String> varname=new ArrayList<String>();//this is for pattenrFind, it must have one varname per expression.
  boolean error=false;
  StringBuilder buildResult(HashMap<String, Integer> vars, Object[] values) {//integer is values index.
    return new StringBuilder();//FIX
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
        if (escaped.charAt(a+1)=='[') {
          if (tokenType==TEXT) {
            pattern.data.add(token.toString());
            tokenType=TEXT;
            token=new StringBuilder();
            continue;
          } else {//no maching brace is error.
            pattern.error=true;
          }
        } else if (escaped.charAt(a+1)==']') {
          if (tokenType==EXP) {
            Expression exp;
            pattern.data.add(exp=new Expression(token.toString()));
            pattern.expression.add(exp);
            pattern.varname.add(exp.getFirstVarName());
            tokenType=EXP;
            token=new StringBuilder();
            continue;
          } else {
            pattern.error=true;
          }
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
          if (in.charAt(a)=='[') {
            ret.append("\\[");
          } else if (in.charAt(a)==']') {
            ret.append("\\]");//symbol escaped are processed in compile.
          } else if (in.charAt(a)=='n') {
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
class Calculator {
  HashMap<String, Integer> vars=new HashMap<String, Integer>(101);//real use in calculation
  Object calculate(Expression exp) {
    //ADD
    return false;
  }
}

static class Expression {
  public Expression(String text) {
  }
  String getFirstVarName() {
    return "";
    //ADD
  }
  //ADD ast.
}