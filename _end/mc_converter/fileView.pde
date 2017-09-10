void mouseWheel(MouseEvent event) {
  FV_sliderPos=FV_sliderPos+event.getCount()*20;
  if (FV_sliderPos<0)FV_sliderPos=0;
  else if (FV_sliderPos>30*max((View.length-5), 0))FV_sliderPos=30*max((View.length-5), 0);
}
String[] View;
int FV_sliderPos=0;
int FV_sliderLength=150;
int colorPress=0;
void ListView() {//hei is 150->150(16->5)
  int a=0;
  if (R) {
    fill(255);
    textSize(12);
    textLeading(11);
    textAlign(LEFT, CENTER);
    while (a<View.length) {
      if (0<=30+30*a-FV_sliderPos&&30+30*a-FV_sliderPos<190) {
        fill(255);
        rect(40, 30*a-FV_sliderPos, 640, 30);
        fill(0);
        text(View[a], 45, 15+30*a-FV_sliderPos);
      }
      a=a+1;
    }
    textAlign(CENTER, CENTER);
  }
  FV_sliderLength=150;
  if (R) {
    fill(0);
    textSize(12);
    noFill();
    rect(680, 0, 20, 150);
    FV_sliderLength=max(1, min(150*5/max(5, View.length), 150));
    fill(255);
    rect(682, 2+FV_sliderPos*5/max(1, View.length), 16, max(FV_sliderLength-4, 4));
  }
  if ((isMouseIsPressed(680, 0, 20, 150)&&colorPress==0)||colorPress==1) {
    sR=true;
    int pos=floor(max(min(mouseY-FV_sliderLength/2, 150-FV_sliderLength), 0));//360-sliderLength/2
    FV_sliderPos=30*max((View.length-5), 0)*pos/max((150-FV_sliderLength), 1);
    colorPress=1;
    fill(0, 50);
    rect(682, 2+FV_sliderPos*5/max(1, View.length), 16, max(FV_sliderLength-4, 4));
  }
}