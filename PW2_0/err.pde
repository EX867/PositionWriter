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
}
void setStatusR(String text) {
  statusR.text=text;
  statusRchanged=true;
}