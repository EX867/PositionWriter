//error handling.pde
Consumer<Throwable> internalError=new Consumer<Throwable>() {
  public void accept(Throwable e) {
    displayError(e);
  }
};
BiConsumer<PrintStream, Throwable> externalError=new BiConsumer<PrintStream, Throwable>() {
  public void accept(PrintStream s, Throwable e) {
    println("macro had an error :");
    displayError(s, e);
  }
};
void displayError(PrintStream writer, Throwable e) {
  writer.println("");
  for (java.lang.StackTraceElement ee : e.getStackTrace()) {
    String str=ee.toString();
    writer.println(str);
  }
  writer.println("Error occurred!");
  writer.println(e.toString());
}
void displayError(String content) {
  displayError(new RuntimeException(content));
}
void displayError(Throwable e) {
  e.printStackTrace();
  KyUI.addLayer(frame_error); 
  PrintStream write=newPrintStream((ConsoleEdit)KyUI.get("err_text"));
  displayError(write, e);
  if (!DEVELOPER_BUILD) {
    PrintWriter writer=createWriter("err.txt");
    for (java.lang.StackTraceElement ee : e.getStackTrace()) {
      writer.println(ee.toString());
    }
    write.flush();
    write.close();
  }
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