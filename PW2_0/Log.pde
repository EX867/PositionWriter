boolean printerror=false;
boolean adderror=true;
class Error {
  static final int ERROR=1;
  static final int WARNING=2;
  int code;
  int type;
  int line;
  String process;
  String content;
  Error(int code_, int type_, int line_, String process_, String content_) {
    code=code_;
    type=type_;
    line=line_;
    process=process_;
    content=content_;
  }
  @Override
    String toString() {
    if (type==ERROR)return "Error! (line "+line+" ,"+process+") : "+content;//not showing code(for removing)
    if (type==WARNING)return "Warning! (line "+line+" ,"+process+") : "+content;
    return "";
  }
  void print() {
    if (printerror)println(toString());
  }
}
ArrayList<Error> error=new ArrayList<Error>();
ArrayList<String> log=new ArrayList<String>();
boolean ignoreCapacity=false;
int LogCapacity=1000;
void printLog(String local, String content) {
  println("["+local+"] : "+content);
}
void printError(int code, int line, String name, String text) {
  if (adderror==false)return;
  Error temp=new Error(code, Error.ERROR, line, name, text);
  error.add(getFirstErrorInLine(line), temp);//insert in line.(usually, warning added before error.)
  temp.print();
}
void printError(int code, int line, String name, String data, String text) {
  if (adderror==false)return;
  if (data.length()>=20) data=data.substring(0, 17)+"...";
  Error temp=new Error(code, Error.ERROR, line, name, "\""+data+"\" "+text);
  error.add(getFirstErrorInLine(line), temp);//insert in line.(usually, warning added before error.)
  temp.print();
}
void printWarning(int code, int line, String name, String text) {
  if (adderror==false)return;
  Error temp=new Error(code, Error.WARNING, line, name, text);
  error.add(getFirstErrorInLine(line), temp);//insert in line.(usually, warning added before error.)
  temp.print();
}
void printWarning(int code, int line, String name, String data, String text) {
  if (adderror==false)return;
  if (data.length()>=20) data=data.substring(0, 17)+"...";
  Error temp=new Error(code, Error.WARNING, line, name, "\""+data+"\" "+text);
  error.add(getFirstErrorInLine(line), temp);//insert in line.(usually, warning added before error.)
  temp.print();
}
int getFirstErrorInLine(int line) {//first error, second warning. if no results, return first line of next line error.
  int a=0;
  int err=-1;
  int war=-1;
  while (a<error.size()) {//#binarysearch!!!!!(called in textEditor.render())
    if (error.get(a).line==line) {
      if (error.get(a).type==Error.ERROR) {
        if (err==-1)err=a;
      } else if (error.get(a).type==Error.WARNING) {
        if (war==-1)war=a;
      }
    } else if (error.get(a).line>line) {
      if (err==-1&&war==-1)return a;
      else if (err!=-1)return err;
      else return war;
    }
    a=a+1;
  }
  if (err==-1&&war==-1)return a;
  else if (err!=-1)return err;
  else return war;
}
void getFirstErrorOrWarningInLine(int line) {//name is dirty...
  //#binarysearch!!!!!!!
}
void removeErrors(int line) {
  int a=0;//#binarysearch use getfirst...
  while (a<error.size()) {
    if (error.get(a).line==line) {
      //println("removeError : "+a);
      error.remove(a);
    } else if (error.get(a).line>line)break;
    else a=a+1;
  }
}
void removeErrorsWithCode(int code1, int code2) {//default 1
  int a=0;
  while (a<error.size()) {
    if (error.get(a).code==code1||error.get(a).code==code2)error.remove(a);
    else a=a+1;
  }
}

//
void displayLogError(String content) {
  Logger logger=(Logger)UI[getUIidRev("ERROR_LOG")];
  logger.logs.add(content);
  registerPrepare(getFrameid("F_ERROR"));
}
void displayLogError(Exception e) {
  if (e.toString().contains("ignore")) {
    printLog("displayLogError()", "error ignored ("+e.toString()+")");
    return;
  }
  Logger logger=(Logger)UI[getUIidRev("ERROR_LOG")];
  for (java.lang.StackTraceElement ee : e.getStackTrace()) {
    String str=ee.toString();
    logger.logs.add(str);
  }
  logger.logs.add("Error! Load Failed!");
  logger.logs.add(e.toString());
  e.printStackTrace();
  registerPrepare(getFrameid("F_ERROR"));
}
//
boolean statusLchanged=false;
boolean statusRchanged=false;
int displayingError=-1;
void setStatusL(String text) {
  if (statusL.text.equals(text)==false)statusLchanged=true;
  statusL.text=text;
}
void setStatusR(String text) {
  statusR.text=text;
  statusRchanged=true;
}