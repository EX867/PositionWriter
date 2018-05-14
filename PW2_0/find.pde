//find replace for only led editor.
static final String REGEX_NUMBER="(-?\\d+)";
class FindReplace {
  LinkedList<FindData> findData=new LinkedList<FindData>();
  int findIndex=0;//index iterator for next/prev
  Pattern patternFindRegex;
  FindReplacePattern patternFind;
  FindReplacePattern patternReplace;
  Calculator calculator;
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
        findData.addLast(result);
      }
    }
    calculator.vars.put("index", groupCount);
    calculator.vars.put("frame", groupCount+1);
    findIndex=min(findData.size()-1, findIndex);
  }
  String replaceAll(String replaceText, boolean isRegex, String text) {
    compileReplace(replaceText, isRegex);
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
    //ADD
    //pattern.error=true;
    return pattern;
  }
  boolean isEmpty() {
    return data.size()==0;
  }
}
class Calculator {
  HashMap<String, Integer> vars=new HashMap<String, Integer>(101);//real use in calculation
  Object calculate(Expression exp) {
    //ADD
    return false;
  }
}

class Expression {
  //ADD ast.
}