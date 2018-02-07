//error handling.pde
void displayError(String content) {
  displayError(new RuntimeException(content));
}
void displayError(Exception e) {
  e.printStackTrace();
  ArrayList<String> logs=new ArrayList<String>();
  logs.add("");
  for (java.lang.StackTraceElement ee : e.getStackTrace()) {
    String str=ee.toString();
    logs.add(str);
  }
  logs.add("Error occurred!");
  logs.add(e.toString());
  //#ADD add error layer
}
void log(String tag, String content) {
  println("["+tag+"] : "+content);
}
boolean statusLchanged=false;
boolean statusRchanged=false;
LineError displayingError=null;
void setStatusL(String text) {
  if (statusL.text.equals(text)==false)statusLchanged=true;
  statusL.text=text;
  statusL.invalidate();
}
void setStatusR(String text) {
  int thr=30;
  if (text.length()>thr) {
    int index=text.indexOf(":");
    text=text.substring(0, index+1)+"\n"+text.substring(index+1, text.length());
  }
  statusR.text=text;
  statusRchanged=true;
  statusR.invalidate();
}