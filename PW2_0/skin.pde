class SkinEditView extends Element {
  //test
  PImage back=loadImage("skinback.png");
  boolean play=true;
  TextBox packageEdit;
  TextBox titleEdit;
  TextBox authorEdit;
  TextBox descriptionEdit;
  TextBox appnameEdit;
  Button textColorEdit;
  ImageDrop skin_background;
  ImageDrop skin_btn;
  ImageDrop skin_btnPressed;
  ImageDrop skin_cover;
  ImageDrop skin_coverMiddle;
  ImageDrop skin_chain;
  ImageDrop skin_chainSelected;
  ImageDrop skin_chainNext;
  ImageDrop skin_play;
  ImageDrop skin_playPressed;
  ImageDrop skin_pause;
  ImageDrop skin_pausePressed;
  ImageDrop skin_prev;
  ImageDrop skin_prevPressed;
  ImageDrop skin_next;
  ImageDrop skin_nextPressed;
  ImageDrop skin_themeIcon;
  ImageDrop skin_appIcon;
  public SkinEditView(String name) {
    super(name);
    addChild(skin_background=new ImageDrop("skin_background", new Rect(100, 60, 80, 45)));
    //left
    addChild(skin_btn=new ImageDrop("skin_btn", new Rect(50, 200, 40, 40)));
    addChild(skin_btnPressed=new ImageDrop("skin_btnPressed", new Rect(50, 300, 40, 40)));
    addChild(skin_cover=new ImageDrop("skin_cover", new Rect(50, 400, 40, 40)));
    addChild(skin_coverMiddle=new ImageDrop("skin_coverMiddle", new Rect(50, 500, 40, 40)));
    //right
    addChild(skin_chain=new ImageDrop("skin_chain", new Rect(1370, 200, 40, 40)));
    addChild(skin_chainSelected=new ImageDrop("skin_chainSelected", new Rect(1370, 300, 40, 40)));
    addChild(skin_chainNext=new ImageDrop("skin_chainNext", new Rect(1370, 400, 40, 40)));
    //controls
    addChild(skin_play=new ImageDrop("skin_play", new Rect(300, 60, 40, 40)));
    addChild(skin_playPressed=new ImageDrop("skin_playPressed", new Rect(400, 60, 40, 40)));
    addChild(skin_pause=new ImageDrop("skin_pause", new Rect(500, 60, 40, 40)));
    addChild(skin_pausePressed=new ImageDrop("skin_pausePressed", new Rect(600, 60, 40, 40)));
    addChild(skin_prev=new ImageDrop("skin_prev", new Rect(700, 60, 40, 40)));
    addChild(skin_prevPressed=new ImageDrop("skin_prevPressed", new Rect(800, 60, 40, 40)));
    addChild(skin_next=new ImageDrop("skin_next", new Rect(900, 60, 40, 40)));
    addChild(skin_nextPressed=new ImageDrop("skin_nextPressed", new Rect(1000, 60, 40, 40)));
    //
    addChild(skin_themeIcon=new ImageDrop("skin_themeIcon", new Rect(1230, 60, 50, 50)));
    addChild(skin_appIcon=new ImageDrop("skin_appIcon", new Rect(1350, 60, 50, 50)));
    //load image
    //x="100" y="860" w="65" h="35" description="com.kimjisub.launchpad.theme.test" title="...theme." text="test" hint="test" numberonly="false" textsize="20">SKIN_PACKAGE
    //x="235" y="860" w="60" h="35" title="Version" text="" hint="1.0.0" numberonly="false" textsize="20">SKIN_VERSION
    //x="400" y="860" w="95" h="35" title="Title" text="" hint="Test Skin" numberonly="false" textsize="20">SKIN_TITLE
    //x="600" y="860" w="95" h="35" title="Author" text="" hint="User" numberonly="false" textsize="20">SKIN_AUTHOR
    //x="900" y="860" w="195" h="35" title="Description" text="" hint="Description" numberonly="false" textsize="20">SKIN_DESCRIPTION
    //x="1200" y="860" w="95" h="35" description="App name can't be empty!" title="App name" text="" hint="Test Skin" numberonly="false" textsize="20">SKIN_APPNAME
    //x="50" y="600" w="30" h="30" description="text color" color="FFFFFFFF">SKIN_TEXT1
    //x="1350" y="860" w="45" h="35" description="build skin!" image="I_CONVERT.png">SKIN_BUILD
    //x="1370" y="780" w="25" h="25" description="exit frame" image="I_EXIT.png">SKIN_EXIT
  }
  //boolean react() {
  //  PVector mouse=new PVector(MouseX, MouseY);
  //  mouse.sub(position);
  //  mouse.mult(1/0.95F);
  //  mouse.sub(new PVector(-528, -90));
  //  mouse.mult(1/0.35F);
  //  if (mouseState==AN_PRESS&&new Rect(0, 0, 90, 90).includes(mouse.x, mouse.y)) {
  //    if (play)play=false;
  //    else play=true;
  //  }
  //  return false;
  //}
  //void render() {
  //  strokeWeight(5);
  //  //draw image
  //  PVector mouse=new PVector(MouseX, MouseY);
  //  pushMatrix();
  //  translate(position.x, position.y);
  //  mouse.sub(position);
  //  scale(0.95F);
  //  mouse.mult(1/0.95F);
  //  fill(color(21, 31, 42/*unipad defualt background*/));
  //  rect(0, 0, 1280/2, 720/2);
  //  //
  //  pushMatrix();
  //  scale((float)1280/skin_background.width, (float)720/skin_background.height);
  //  image(skin_background, 0, 0);
  //  popMatrix();
  //  image(back, 0, 0);//test
  //  PVector mouse2=new PVector(mouse.x, mouse.y);
  //  pushMatrix();
  //  scale((float)684/(180*ButtonX), (float)684/(180*ButtonY));//change values if they are incorrect.
  //  mouse2.x=mouse2.x/((float)684/(180*ButtonX));
  //  mouse2.y=mouse2.y/((float)684/(180*ButtonY));
  //  boolean coverv=(ButtonX%2==0)&&(ButtonY%2==0);
  //  int b=0;
  //  while (b<ButtonY) {
  //    a=0;
  //    while (a<ButtonY) {
  //      float x=-((float)ButtonX-1)*90+a*180;
  //      float y=-((float)ButtonY-1)*90+b*180;
  //      pushMatrix();
  //      translate(x, y);
  //      if (mousePressed&&new Rect(x, y, 90, 90).includes(mouse2.x, mouse2.y)) {
  //        scale((float)180/skin_btnPressed.width, (float)180/skin_btnPressed.height);
  //        image(skin_btnPressed, 0, 0);
  //      } else {
  //        scale((float)180/skin_btn.width, (float)180/skin_btn.height);
  //        image(skin_btn, 0, 0);
  //      }
  //      popMatrix();
  //      pushMatrix();
  //      translate(x, y);
  //      if (coverv) {
  //        if (a==ButtonX/2-1&&b==ButtonY/2-1) {
  //          scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
  //          image(skin_coverMiddle, 0, 0);
  //        } else if (a==ButtonX/2&&b==ButtonY/2-1) {
  //          scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
  //          rotate(radians(90));
  //          image(skin_coverMiddle, 0, 0);
  //        } else if (a==ButtonX/2&&b==ButtonY/2) {
  //          scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
  //          rotate(radians(180));
  //          image(skin_coverMiddle, 0, 0);
  //        } else if (a==ButtonX/2-1&&b==ButtonY/2) {
  //          scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
  //          rotate(radians(-90));
  //          image(skin_coverMiddle, 0, 0);
  //        } else {
  //          scale((float)180/skin_cover.width, (float)180/skin_cover.height);
  //          image(skin_cover, 0, 0);
  //        }
  //      } else {
  //        scale((float)180/skin_cover.width, (float)180/skin_cover.height);
  //        image(skin_cover, 0, 0);
  //      }
  //      popMatrix();
  //      a=a+1;
  //    }
  //    //chain(full 8)
  //    if (b<8) {
  //      pushMatrix();
  //      float x=-((float)ButtonX-1)*90+a*180;
  //      float y=-((float)ButtonY-1)*90+b*180;
  //      translate(x, y);
  //      if (mousePressed&&new Rect(x, y, 90, 90).includes(mouse2.x, mouse2.y)) {
  //        scale((float)180/skin_chainNext.width, (float)180/skin_chainNext.height);
  //        image(skin_chainNext, 0, 0);
  //      } else {
  //        if (b==0) {
  //          scale((float)180/skin_chainSelected.width, (float)180/skin_chainSelected.height);
  //          image(skin_chainSelected, 0, 0);
  //        } else {
  //          scale((float)180/skin_chain.width, (float)180/skin_chain.height);
  //          image(skin_chain, 0, 0);
  //        }
  //      }
  //      popMatrix();
  //    }
  //    b=b+1;
  //  }
  //  popMatrix();
  //  translate(-528, -90);
  //  mouse.sub(new PVector(-528, -90));
  //  scale(0.35F);
  //  mouse.mult(1/0.35F);
  //  pushMatrix();
  //  translate(-180, 0);
  //  if (mousePressed&&new Rect(-180, 0, 90, 90).includes(mouse.x, mouse.y)) {
  //    scale((float)180/skin_prevPressed.width, (float)180/skin_prevPressed.height);
  //    image(skin_prevPressed, 0, 0);
  //  } else {
  //    scale((float)180/skin_prev.width, (float)180/skin_prev.height);
  //    image(skin_prev, 0, 0);
  //  }
  //  popMatrix();
  //  if (mousePressed&&new Rect(0, 0, 90, 90).includes(mouse.x, mouse.y)) {
  //    pushMatrix();
  //    if (play) {
  //      scale((float)180/skin_playPressed.width, (float)180/skin_playPressed.height);
  //      image(skin_playPressed, 0, 0);
  //    } else {
  //      scale((float)180/skin_pausePressed.width, (float)180/skin_pausePressed.height);
  //      image(skin_pausePressed, 0, 0);
  //    }
  //    popMatrix();
  //  } else {
  //    //if (mousePressed&&new Rect(0, 0, 90, 90).includes(mouse.x, mouse.y)) {
  //    pushMatrix();
  //    if (play) {
  //      scale((float)180/skin_play.width, (float)180/skin_play.height);
  //      image(skin_play, 0, 0);
  //    } else {
  //      scale((float)180/skin_pause.width, (float)180/skin_pause.height);
  //      image(skin_pause, 0, 0);
  //    }
  //    popMatrix();
  //    //}
  //  }
  //  pushMatrix();
  //  translate(180, 0);
  //  if (mousePressed&&new Rect(180, 0, 90, 90).includes(mouse.x, mouse.y)) {
  //    scale((float)180/skin_nextPressed.width, (float)180/skin_nextPressed.height);
  //    image(skin_nextPressed, 0, 0);
  //  } else {
  //    scale((float)180/skin_next.width, (float)180/skin_next.height);
  //    image(skin_next, 0, 0);
  //  }
  //  popMatrix();
  //  popMatrix();
  //  noStroke();
  //}
  void maskImage1(color c) {//masks text1
    back=loadImage("skinback.png");
    back.loadPixels();
    for (int a=0; a<back.pixels.length; a++) {
      back.pixels[a]=color(red(c), green(c), blue(c), max(0, alpha(back.pixels[a])+alpha(c)-255));
    }
    back.updatePixels();
  }
}