static class UnipackInfo {
  String title="";
  String producerName="";
  int buttonX=8;
  int buttonY=8;
  int chain=8;
  //no landscape anymore...!
  boolean squareButton=true;
  boolean updated=false;
  @Override
    public String toString() {
    String ret="";
    ret+="title="+title+"\n";
    ret+="producerName="+producerName+"\n";
    ret+="buttonX="+buttonX+"\n";
    ret+="buttonY="+buttonY+"\n";
    ret+="chain="+chain+"\n";
    ret+="squareButton="+str(squareButton)+"\n";
    ret+="landscape=true\n";
    ret+="updated"+str(updated);
    return ret;
  }
  String toUncloudString() {
    String ret="";
    ret+="title="+title+"\n";
    ret+="producerName="+producerName+"\n";
    ret+="buttonX="+buttonX+"\n";
    ret+="buttonY="+buttonY+"\n";
    ret+="chain="+chain+"\n";
    return ret;
  }
  public static UnipackInfo loadUnipackInfo(String filename, String text) {
    UnipackInfo ret=new UnipackInfo();
    String[] lines=split(text, "\n");
    for (int a=0; a<lines.length; a++) {
      InfoLine result=AnalyzeInfo(lines[a]);
      if (result==null)continue;
      if (result.type==InfoLine.TITLE) {
        ret.title=result.value;
      } else if (result.type==InfoLine.PRODUCERNAME) {
        ret.producerName=result.value;
      } else if (result.type==InfoLine.BUTTONX) {
        ret.buttonX=int(result.value);
      } else if (result.type==InfoLine.BUTTONY) {
        ret.buttonY=int(result.value);
      } else if (result.type==InfoLine.CHAINNUMBER) {
        ret.chain=int(result.value);
      } else if (result.type==InfoLine.SQUAREBUTTON) {
        ret.squareButton=toBoolean(result.value);
      } else if (result.type==InfoLine.UPDATED) {
        ret.updated=toBoolean(result.value);
      }
    }
    return ret;
  }
}
static class InfoLine {
  static final int TITLE=1;
  static final int PRODUCERNAME=2;
  static final int BUTTONX=3;
  static final int BUTTONY=4;
  static final int CHAINNUMBER=5;
  static final int SQUAREBUTTON=6;
  static final int UPDATED=7;
  int type;
  String value;
  public InfoLine(int type_, String value_) {
    type=type_;
    value=value_;
  }
}
static InfoLine AnalyzeInfo(String text) {
  String[] tokens = split(text, "=");
  String temp="";
  if (tokens.length>1)temp=tokens[1];
  for (int a=2; a<tokens.length; a++) {
    temp=temp+"="+tokens[a];
  }
  if (tokens.length>0) {
    if (tokens[0].equals("title")) return new InfoLine(InfoLine.TITLE, temp);
    else if (tokens[0].equals("producerName")) return new InfoLine(InfoLine.PRODUCERNAME, temp);
    else if (tokens[0].equals("buttonX")) {
      if (tokens.length==2) {
        if (Analyzer.isInt(tokens[1]))return new InfoLine(InfoLine.BUTTONX, tokens[1]);
      }
    } else if (tokens[0].equals("buttonY")) {
      if (tokens.length==2) {
        if (Analyzer.isInt(tokens[1]))return new InfoLine(InfoLine.BUTTONY, tokens[1]);
      }
    } else if (tokens[0].equals("chain")) {
      if (tokens.length==2) {
        if (Analyzer.isInt(tokens[1]))return new InfoLine(InfoLine.CHAINNUMBER, tokens[1]);
      }
    } else if (tokens[0].equals("squareButton")) {
      if (tokens.length==2) {
        if (Analyzer.isBoolean(tokens[1]))return new InfoLine(InfoLine.SQUAREBUTTON, tokens[1]);
      }
    } else if (tokens[0].equals("updated")) {
      if (tokens.length==2) {
        if (Analyzer.isInt(tokens[1]))return new InfoLine(InfoLine.UPDATED, tokens[1]);
      }
    }
  }
  return null;
}