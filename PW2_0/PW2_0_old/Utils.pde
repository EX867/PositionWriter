

void drawVel (float x, float y, float w, float h) {
  int a=0;
  textSize(15);
  textAlign(LEFT, CENTER);
  while (a <128) {
    fill (color (k [a]));
    rect(x+((a%8)*(w/8))+(w/16), y+(round (a/8)*(h/16))+(h/32), (w/16), (h/32));
    fill(0);
    text (str (a), x+((a%8)*(w/8))+2, y+(round (a/8)*(h/16))+w/32);
    a=a+1;
  }
  textAlign(CENTER, CENTER);
}
void writeDisplay(String text) {
  writeDisplay(text, false);
}
synchronized void writeDisplay(String text, boolean async) {
  int line=Lines.lines()-1;
  if (InFrameInput) {
    if (keyled_textEditor.current.processer.displayFrame!=DelayPoint.size()-1)line=DelayPoint.get(keyled_textEditor.current.processer.displayFrame+1)-1;
    if (line==-1) {
      line=0;
    }
  }
  keyled_textEditor.insert(Lines.getLine(line).length(), line, text);
  RecordLog();
  if (keyled_textEditor.disabled==false) {
    if (async)keyled_textEditor.registerRender=true;
    else keyled_textEditor.render();
  }
}
void writeDisplayLine(String text) {
  writeDisplayLine(text, false);
}
void writeDisplayLine(String text, boolean async) {
  int line=Lines.lines();
  if (InFrameInput) {
    if (keyled_textEditor.current.processer.displayFrame!=DelayPoint.size()-1)line=DelayPoint.get(keyled_textEditor.current.processer.displayFrame+1);
  }
  keyled_textEditor.addLine(line, text);
  RecordLog();
  if (keyled_textEditor.disabled==false) {
    if (async)keyled_textEditor.registerRender=true;
    else keyled_textEditor.render();
  }
}
//
//