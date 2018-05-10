class FindReplace {
  LinkedList<FindData> findData=new LinkedList<FindDat>();
  int findIndex=0;//index iterator for next/prev
  Pattern patternFindRegex;
  FindReplacePattern patternFind;
  FindReplacePattern patternReplace;
  void compileFind(String findText, boolean isRegex, String text) {//use this in change find text.
    patternFindRegex = Pattern.compile(getRegex(findText, isRegex));
    if (isRegex) {
      patternFind=FindReplacePattern.compile(findText);
    } else {
      patternFind=new FindReplacePattern();
      patternFind.data.add(findText);
    }
    findAll(text);
  }
  private void compileReplace(String replaceText, boolean isRegex) {
    if (isRegex) {
      patternReplace=FindReplacePattern.compile(replaceText);
    } else {
      patternReplace=new FindReplacePattern();
      patternReplace.data.add(replaceText);
    }
  }
  void changeText(String text) {//use this in change text.
    findAll(text);
  }
  private void findAll(String text) {
    findData.clear();
    calculator.vars.clear();
    if (findText.isEmpty()) {
      return;
    }
    Matcher matcher = patternFindRegex.matcher(text);
    while (matcher.find()) {
      FindData result=new FindData(matcher.start(), matcher.group(), matcher.groupCount());
      boolean match=true;
      for (int a=1; a<=matcher.groupCount(); a++) {// get variable values
        result.vars[a-1]=Integer.parseInt(matcher.group(a));
        calculator.vars.put("ADD : get it from findtext", result.vars[a-1]);
      }
      for (int a=1; a<=matcher.groupCount(); a++) {// expression result is true?
        if (!calculator.calculate(patternFind.expression.get(a))) {
          match=false;
        }
      }
      if (match) {
        findData.addLast(result);
      }
    }
    findIndex=min(ret.size()-1, findIndex);
  }
  String replaceAll(String replaceText, String isRegex, String text) {
    compileReplace(replaceText, isRegex);
    //ADD replace
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
        calculator.setIdent("frame", currentLedEditor.getFrame(keyled_textEditor.current.getLineByIndex(result.startpoint)));
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
      return Pattern.quote(in);
    }
  }
}
class FindData {
  int start;
  int end;
  String text;
  int[] vars;
  public FindData(int start_, String text_, int count) {
    start=start_;
    text=text_;
    end=start+text.length();
    vars=new int[count];
  }
}
class FindReplacePattern {
  LinkedList<Object> data=new LinkedList<Object>();// contains String and Expression
  ArrayList<Expression> expression=new ArrayList<Expression>();// only contains Expression in data.
  ArrayList<Variable> vars=new ArrayList<Variable>();//put variable values if needed.
  String buildResult(HashMap<String, Variable> vars) {
  }
  static FindReplacePattern compile(String text) {
  }
}
class Calculator {
  HashMap<String, Variable> vars=new HashMap<String, Variable>(101);//real use in calculation
  Object calculate(Expression exp) {
  }
}

class Expression {
}
class Variable {
  String name;
  Object value;
}