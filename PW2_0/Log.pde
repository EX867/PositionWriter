
//
void displayLogError(String content) {
  Logger logger=(Logger)UI[getUIidRev("ERROR_LOG")];
  logger.logs.add("");
  logger.logs.add(content);
  registerPrepare(getFrameid("F_ERROR"));
}
void displayLogError(Exception e) {
  if (e.toString().contains("ignore")) {
    printLog("displayLogError()", "error ignored ("+e.toString()+")");
    return;
  }
  Logger logger=(Logger)UI[getUIidRev("ERROR_LOG")];
  logger.logs.add("");
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