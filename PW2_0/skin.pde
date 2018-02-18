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
  TextBox skin_package;
  TextBox skin_version;
  TextBox skin_title;
  TextBox skin_author;
  TextBox skin_description;
  TextBox skin_appname;
  ColorButton skin_text1;
  ImageButton skin_build;
  ImageButton skin_exit;
  public SkinEditView(String name, Rect pos_) {
    super(name);
    pos=pos_;
    addChild(skin_background=new ImageDrop("skin_background", new Rect(30, 15, 180, 115)));
    //left
    addChild(skin_btn=new ImageDrop("skin_btn", new Rect(20, 160, 100, 240)));
    addChild(skin_btnPressed=new ImageDrop("skin_btnPressed", new Rect(20, 260, 100, 340)));
    addChild(skin_cover=new ImageDrop("skin_cover", new Rect(20, 360, 100, 440)));
    addChild(skin_coverMiddle=new ImageDrop("skin_coverMiddle", new Rect(20, 460, 100, 540)));
    //right
    addChild(skin_chain=new ImageDrop("skin_chain", new Rect(1360, 160, 1440, 240)));
    addChild(skin_chainSelected=new ImageDrop("skin_chainSelected", new Rect(1360, 260, 1440, 340)));
    addChild(skin_chainNext=new ImageDrop("skin_chainNext", new Rect(1360, 360, 1440, 440)));
    //controls
    addChild(skin_play=new ImageDrop("skin_play", new Rect(260, 30, 340, 110)));
    addChild(skin_playPressed=new ImageDrop("skin_playPressed", new Rect(360, 30, 440, 110)));
    addChild(skin_pause=new ImageDrop("skin_pause", new Rect(460, 30, 540, 110)));
    addChild(skin_pausePressed=new ImageDrop("skin_pausePressed", new Rect(560, 30, 640, 110)));
    addChild(skin_prev=new ImageDrop("skin_prev", new Rect(660, 30, 740, 110)));
    addChild(skin_prevPressed=new ImageDrop("skin_prevPressed", new Rect(760, 30, 840, 110)));
    addChild(skin_next=new ImageDrop("skin_next", new Rect(860, 30, 940, 110)));
    addChild(skin_nextPressed=new ImageDrop("skin_nextPressed", new Rect(960, 30, 1040, 110)));
    //
    addChild(skin_themeIcon=new ImageDrop("skin_themeIcon", new Rect(1220, 20, 1320, 120)));
    addChild(skin_appIcon=new ImageDrop("skin_appIcon", new Rect(1340, 20, 1440, 120)));
    //load image
    addChild(skin_package=new TextBox("skin_package", new Rect(35, 865, 205, 935), " ...theme. ", "test").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_version=new TextBox("skin_version", new Rect(215, 865, 335, 935), " Version ", "1.0.0").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_title=new TextBox("skin_title", new Rect(345, 865, 535, 935), " Title ", "Test skin").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_author=new TextBox("skin_author", new Rect(545, 865, 735, 935), " Author ", "User").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_description=new TextBox("skin_description", new Rect(745, 865, 1135, 935), " Description ", "asdf asdf").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_appname=new TextBox("skin_appname", new Rect(1145, 865, 1335, 935), " App name ", "Test skin").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_text1=new ColorButton("skin_text1", new Rect(20, 570, 80, 630)));
    addChild(skin_build=new ImageButton("skin_build", new Rect(1345, 865, 1435, 935)));
    addChild(skin_exit=new ImageButton("skin_exit", new Rect(1385, 795, 1435, 845)));
    skin_exit.image=loadImage("exit.png");
    skin_build.image=loadImage("run.png");
    skin_background.image=loadImage("external/skin/playbg.png");
    skin_btn.image=loadImage("external/skin/btn.png");
    skin_btnPressed.image=loadImage("external/skin/btn_.png");
    skin_cover.image=loadImage("external/skin/phantom.png");
    skin_coverMiddle.image=loadImage("external/skin/phantom_.png");
    skin_chain.image=loadImage("external/skin/chain.png");
    skin_chainSelected.image=loadImage("external/skin/chain_.png");
    skin_chainNext.image=loadImage("external/skin/chain__.png");
    skin_play.image=loadImage("external/skin/play.png");
    skin_playPressed.image=loadImage("external/skin/play_.png");
    skin_pause.image=loadImage("external/skin/pause.png");
    skin_pausePressed.image=loadImage("external/skin/pause_.png");
    skin_prev.image=loadImage("external/skin/prev.png");
    skin_prevPressed.image=loadImage("external/skin/prev_.png");
    skin_next.image=loadImage("external/skin/next.png");
    skin_nextPressed.image=loadImage("external/skin/next_.png");
    skin_themeIcon.image=loadImage("external/skin/theme_ic.png");
    skin_appIcon.image=loadImage("external/skin/appicon.png");
    skin_build.scaled=true;
    skin_build.padding=7;
    skin_text1.setPressListener(new ColorButton.OpenColorPickerEvent(skin_text1));
    onLayout();
    skin_exit.setPressListener(new MouseEventListener() {
      public boolean onEvent(MouseEvent e, int index) {
        KyUI.removeLayer();
        return false;
      }
    }
    );
    skin_package.setText("test");
    skin_package.setDescription("com.kimjisub.launchpad.theme.test");
    skin_package.setTextChangeListener(new EventListener() {
      public void onEvent(Element e) {
        TextBox t=(TextBox)e;
        String text=t.getText();
        t.setDescription("com.kimjisub.launchpad.theme."+text);
        t.error=!isValidPackageName(text);
      }
    }
    );
    skin_appname.setText("Test skin");
    skin_appname.setTextChangeListener(new EventListener() {
      public void onEvent(Element e) {
        TextBox t=(TextBox)e;
        t.error=t.getContent().empty();
      }
    }
    );
    skin_build.setDescription("build start");
    skin_build.setPressListener(new MouseEventListener() {
      public boolean onEvent(MouseEvent e, int index) {
        KyUI.addLayer(frame_log);
        build_windows(skin_package.getText(), skin_appname.getText(), skin_author.getText(), skin_description.getText(), skin_title.getText(), skin_version.getText(), skin_text1.c);
        return false;
      }
    }
    );
  }
  @Override
    public boolean mouseEvent(MouseEvent e, int index) {
    PVector mouse=new PVector(KyUI.mouseGlobal.getLast().x, KyUI.mouseGlobal.getLast().y);
    mouse.sub((pos.left+pos.right)/2, (pos.top+pos.bottom)/2);
    mouse.mult(1/0.95F);
    mouse.sub(new PVector(-528, -90));
    mouse.mult(1/0.35F);
    if (e.getAction()==MouseEvent.PRESS&&new Rect(-90, -90, 90, 90).contains(mouse.x, mouse.y)) {
      if (play)play=false;
      else play=true;
      invalidate();
    }
    return false;
  }
  @Override
    public void render(PGraphics g) {
    g.strokeWeight(5);
    PVector mouse=new PVector(KyUI.mouseGlobal.getLast().x, KyUI.mouseGlobal.getLast().y);
    g.pushMatrix();
    g.imageMode(CENTER);
    g.translate((pos.left+pos.right)/2, (pos.top+pos.bottom)/2);
    mouse.sub((pos.left+pos.right)/2, (pos.top+pos.bottom)/2);
    g.scale(0.95F);
    mouse.mult(1/0.95F);
    g.fill(color(21, 31, 42));//unipad defualt background
    g.rect(-1280/2, -720/2, 1280/2, 720/2);
    if (skin_background.image!=null) {
      g.pushMatrix();
      g.scale((float)1280/skin_background.image.width, (float)720/skin_background.image.height);
      g.image(skin_background.image, 0, 0);
      g.popMatrix();
    }
    g.image(back, 0, 0);//test
    PVector mouse2=new PVector(mouse.x, mouse.y);
    g.pushMatrix();
    g.scale((float)684/(180*info.buttonX), (float)684/(180*info.buttonY));//change values if they are incorrect.
    mouse2.x=mouse2.x/((float)684/(180*info.buttonX));
    mouse2.y=mouse2.y/((float)684/(180*info.buttonY));
    boolean coverv=(info.buttonX%2==0)&&(info.buttonY%2==0);
    for (int b=0; b<info.buttonY; b++) {
      for (int a=0; a<info.buttonX; a++) {
        float x=-((float)info.buttonX-1)*90+a*180;
        float y=-((float)info.buttonY-1)*90+b*180;
        g.pushMatrix();
        g.translate(x, y);
        if (mousePressed&&new Rect(x-90, y-90, x+90, y+90).contains(mouse2.x, mouse2.y)) {
          g.scale((float)180/skin_btnPressed.image.width, (float)180/skin_btnPressed.image.height);
          g.image(skin_btnPressed.image, 0, 0);
        } else {
          g.scale((float)180/skin_btn.image.width, (float)180/skin_btn.image.height);
          g.image(skin_btn.image, 0, 0);
        }
        g.popMatrix();
        g.pushMatrix();
        g.translate(x, y);
        if (coverv) {
          if (a==info.buttonX/2-1&&b==info.buttonY/2-1) {
            g.scale((float)180/skin_coverMiddle.image.width, (float)180/skin_coverMiddle.image.height);
            g.image(skin_coverMiddle.image, 0, 0);
          } else if (a==info.buttonX/2&&b==info.buttonY/2-1) {
            g.scale((float)180/skin_coverMiddle.image.width, (float)180/skin_coverMiddle.image.height);
            g.rotate(radians(90));
            g.image(skin_coverMiddle.image, 0, 0);
          } else if (a==info.buttonX/2&&b==info.buttonY/2) {
            g.scale((float)180/skin_coverMiddle.image.width, (float)180/skin_coverMiddle.image.height);
            g.rotate(radians(180));
            g.image(skin_coverMiddle.image, 0, 0);
          } else if (a==info.buttonX/2-1&&b==info.buttonY/2) {
            g.scale((float)180/skin_coverMiddle.image.width, (float)180/skin_coverMiddle.image.height);
            g.rotate(radians(-90));
            g.image(skin_coverMiddle.image, 0, 0);
          } else {
            g.scale((float)180/skin_cover.image.width, (float)180/skin_cover.image.height);
            g.image(skin_cover.image, 0, 0);
          }
        } else {
          g.scale((float)180/skin_cover.image.width, (float)180/skin_cover.image.height);
          g.image(skin_cover.image, 0, 0);
        }
        g.popMatrix();
      }
      //chain(full 8)
      if (b<8) {
        g.pushMatrix();
        float x=-((float)info.buttonX-1)*90+info.buttonY*180;
        float y=-((float)info.buttonY-1)*90+b*180;
        g.translate(x, y);
        if (mousePressed&&new Rect(x-90, y-90, x+90, y+90).contains(mouse2.x, mouse2.y)) {
          g.scale((float)180/skin_chainNext.image.width, (float)180/skin_chainNext.image.height);
          g.image(skin_chainNext.image, 0, 0);
        } else {
          if (b==0) {
            g.scale((float)180/skin_chainSelected.image.width, (float)180/skin_chainSelected.image.height);
            g.image(skin_chainSelected.image, 0, 0);
          } else {
            g.scale((float)180/skin_chain.image.width, (float)180/skin_chain.image.height);
            g.image(skin_chain.image, 0, 0);
          }
        }
        g.popMatrix();
      }
    }
    g.popMatrix();
    g.translate(-528, -90);
    mouse.sub(-528, -90);
    g.scale(0.35F);
    mouse.mult(1/0.35F);
    g.pushMatrix();
    g.translate(-180, 0);
    if (mousePressed&&new Rect(-270, -90, -90, 90).contains(mouse.x, mouse.y)) {
      g.scale((float)180/skin_prevPressed.image.width, (float)180/skin_prevPressed.image.height);
      g.image(skin_prevPressed.image, 0, 0);
    } else {
      g.scale((float)180/skin_prev.image.width, (float)180/skin_prev.image.height);
      g.image(skin_prev.image, 0, 0);
    }
    g.popMatrix();
    if (mousePressed&&new Rect(-90, -90, 90, 90).contains(mouse.x, mouse.y)) {
      g.pushMatrix();
      if (play) {
        g.scale((float)180/skin_playPressed.image.width, (float)180/skin_playPressed.image.height);
        g.image(skin_playPressed.image, 0, 0);
      } else {
        g.scale((float)180/skin_pausePressed.image.width, (float)180/skin_pausePressed.image.height);
        g.image(skin_pausePressed.image, 0, 0);
      }
      g.popMatrix();
    } else {
      //if (mousePressed&&new Rect(-90, -90, 90, 90).contains(mouse.x, mouse.y)) {
      g.pushMatrix();
      if (play) {
        g.scale((float)180/skin_play.image.width, (float)180/skin_play.image.height);
        g.image(skin_play.image, 0, 0);
      } else {
        g.scale((float)180/skin_pause.image.width, (float)180/skin_pause.image.height);
        g.image(skin_pause.image, 0, 0);
      }
      g.popMatrix();
      //}
    }
    g.pushMatrix();
    g.translate(180, 0);
    if (mousePressed&&new Rect(90, -90, 270, 90).contains(mouse.x, mouse.y)) {
      g.scale((float)180/skin_nextPressed.image.width, (float)180/skin_nextPressed.image.height);
      g.image(skin_nextPressed.image, 0, 0);
    } else {
      g.scale((float)180/skin_next.image.width, (float)180/skin_next.image.height);
      g.image(skin_next.image, 0, 0);
    }
    g.popMatrix();
    g.popMatrix();
    g.noStroke();
  }
  void maskImage1(color c) {//masks text1
    back=loadImage("skinback.png");
    back.loadPixels();
    for (int a=0; a<back.pixels.length; a++) {
      back.pixels[a]=color(red(c), green(c), blue(c), max(0, alpha(back.pixels[a])+alpha(c)-255));
    }
    back.updatePixels();
  }
}