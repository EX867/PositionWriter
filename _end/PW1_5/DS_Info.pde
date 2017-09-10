Info info=new Info();
class Info {
  int Focused=0;
  String Title="Enter Title";
  String Producer="Enter Producer";
  int Chain=1;
  int ButtonX=8;
  int ButtonY=8;
  boolean Landscape=true;
  boolean SquareButton=true;
  void drawUI() {//title maker chain x y landscape square
    if (R==false)return;
    fill(225);
    stroke(0);
    rect(200, 0, 700, 420);
    fill(255);
    rect(0, 0, 200, 420);
    rect(900, 0, 200, 800);
    line(0, 60, 900, 60);
    line(0, 120, 900, 120);
    line(0, 180, 900, 180);
    line(0, 240, 900, 240);
    line(0, 300, 900, 300);
    line(0, 360, 900, 360);
    //
    line(200, 0, 200, 800);
    strokeWeight(3);
    fill(0, 70);
    if (Focused==0) {
    } else if (Focused==1) rect(0, 0, 900, 60);
    else if (Focused==2) rect(0, 60, 900, 60);
    else if (Focused==3) rect(0, 120, 900, 60);
    else if (Focused==4) rect(0, 180, 900, 60);
    else if (Focused==5) rect(0, 240, 900, 60);
    else if (Focused==6) rect(0, 300, 900, 60);
    else if (Focused==7) rect(0, 360, 900, 60);
    fill(0);
    text("Title", 100, 30);
    text("Producer", 100, 90);
    text("X", 100, 150);
    text("Y", 100, 210);
    text("Chain", 100, 270);
    text("SquareButton", 100, 330);
    text("Landscape", 100, 390);
    textAlign(LEFT, CENTER);
    if (Focused==1&&frameCount%40<20)text(Title+"|", 220, 30);
    else text(Title, 220, 30);
    if (Focused==2&&frameCount%40<20)text(Producer+"|", 220, 90);
    else text(Producer, 220, 90);
    if (Focused==3&&frameCount%40<20)text(ButtonX+"|", 220, 150);
    else text(ButtonX, 220, 150);
    if (Focused==4&&frameCount%40<20)text(ButtonY+"|", 220, 210);
    else text(ButtonY, 220, 210);
    if (Focused==5&&frameCount%40<20)text(Chain+"|", 220, 270);
    else text(Chain, 220, 270);
    if (Focused==6&&frameCount%40<20)text(str(SquareButton)+"|", 220, 330);
    else text(str(SquareButton), 220, 330);
    if (Focused==7&&frameCount%40<20)text(str(Landscape)+"|", 220, 390);
    else text(str(Landscape), 220, 390);
    textAlign(CENTER, CENTER);
  }
  void interactUI() {
    if (frameCount%40==0||frameCount%40==20)sR=true;
    if (isMouseIsPressed(0, 0, 900, 60)&&colorPress==0) {
      Focused=1;
      colorPress=1;
    } else if (isMouseIsPressed(0, 60, 900, 60)&&colorPress==0) {
      Focused=2;
      colorPress=1;
    } else if (isMouseIsPressed(0, 120, 900, 60)&&colorPress==0) {
      Focused=3;
      colorPress=1;
    } else if (isMouseIsPressed(0, 180, 900, 60)&&colorPress==0) {
      Focused=4;
      colorPress=1;
    } else if (isMouseIsPressed(0, 240, 900, 60)&&colorPress==0) {
      Focused=5;
      colorPress=1;
    } else if (isMouseIsPressed(0, 300, 900, 60)&&colorPress==0) {
      Focused=6;
      colorPress=1;
    } else if (isMouseIsPressed(0, 360, 900, 60)&&colorPress==0) {
      Focused=7;
      colorPress=1;
    }
  }
  void update() {
  }
}