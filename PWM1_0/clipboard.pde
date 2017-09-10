 boolean LooperPrepared=false;
 String ClipboardPaste() {
   if (LooperPrepared==false){
     Looper.prepare();
     LooperPrepared=true;
   }
   ClipboardManager clip=(ClipboardManager)getSystemService(Context.CLIPBOARD_SERVICE);
   if (clip.hasText()) {
     try {
      return (clip.getText().toString ());
      }catch (Exception e){
        Log=e.toString();
        return "";
      }
    }else {
      return "";
    }
}
 void ClipboardCopy(String s) {
   if (LooperPrepared==false){
     Looper.prepare();
     LooperPrepared=true;
   }
   ClipboardManager clip=(ClipboardManager)getSystemService(Context.CLIPBOARD_SERVICE);
   clip.setText(display.getText());
   //Looper.loop ();
}