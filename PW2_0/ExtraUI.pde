
void drawInputLine() {
  stroke(0);
  stroke(UIcolors[I_FOREGROUND]);
  int i1=getUIid("I_DEFAULTINPUT");
  int i2=getUIid("I_OLDINPUT");
  int i3=getUIidRev("I_RIGHTOFFMODE");
  int i4=getUIid("I_CYXMODE");
  line(50, UI[i1].position.y, UI[i1].position.x-UI[i1].size.x-40, UI[i1].position.y);
  line(50, UI[i2].position.y, UI[i2].position.x-UI[i2].size.x-40, UI[i2].position.y);
  line(50, UI[i3].position.y, UI[i3].position.x-UI[i3].size.x-40, UI[i3].position.y);
  line(50, UI[i4].position.y, UI[i3].position.x-UI[i4].size.x-40, UI[i4].position.y);
  line(50, UI[i1].position.y, 50, UI[i4].position.y);
  noStroke();
}