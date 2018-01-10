




class SkinEditView extends UIelement {
  ArrayList<InnerDropArea> areas=new ArrayList<InnerDropArea>();
  //test
  PImage back=loadImage("skinback.png");
  boolean play=true;
  TextBox packageEdit;
  TextBox titleEdit;
  TextBox authorEdit;
  TextBox descriptionEdit;
  TextBox appnameEdit;
  Button textColorEdit;
  public SkinEditView( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    areas.add(new InnerDropArea(new Rect(100, 60, 80, 45), skin_background));//i failed to make this in proper way. I have to use gui library(2)!!
    //left
    areas.add(new InnerDropArea(new Rect(50, 200, 40, 40), skin_btn));
    areas.add(new InnerDropArea(new Rect(50, 300, 40, 40), skin_btnPressed));
    areas.add(new InnerDropArea(new Rect(50, 400, 40, 40), skin_cover));
    areas.add(new InnerDropArea(new Rect(50, 500, 40, 40), skin_coverMiddle));
    //right
    areas.add(new InnerDropArea(new Rect(1370, 200, 40, 40), skin_chain));
    areas.add(new InnerDropArea(new Rect(1370, 300, 40, 40), skin_chainSelected));
    areas.add(new InnerDropArea(new Rect(1370, 400, 40, 40), skin_chainNext));
    //controls
    areas.add(new InnerDropArea(new Rect(300, 60, 40, 40), skin_play));
    areas.add(new InnerDropArea(new Rect(400, 60, 40, 40), skin_playPressed));
    areas.add(new InnerDropArea(new Rect(500, 60, 40, 40), skin_pause));
    areas.add(new InnerDropArea(new Rect(600, 60, 40, 40), skin_pausePressed));
    areas.add(new InnerDropArea(new Rect(700, 60, 40, 40), skin_prev));
    areas.add(new InnerDropArea(new Rect(800, 60, 40, 40), skin_prevPressed));
    areas.add(new InnerDropArea(new Rect(900, 60, 40, 40), skin_next));
    areas.add(new InnerDropArea(new Rect(1000, 60, 40, 40), skin_nextPressed));
    //
    areas.add(new InnerDropArea(new Rect(1230, 60, 50, 50), skin_themeIcon));
    areas.add(new InnerDropArea(new Rect(1350, 60, 50, 50), skin_appIcon));
  }
  void setComponents(TextBox a, TextBox b, TextBox c, TextBox d, TextBox e, Button f) {
    packageEdit=a;
    titleEdit=b;
    authorEdit=c;
    descriptionEdit=d;
    appnameEdit=e;
    textColorEdit=f;
  }
  @Override
    boolean react() {
    if (super.react()==false)return false;//LOG_LOG
    PVector mouse=new PVector(MouseX, MouseY);
    mouse.sub(position);
    mouse.mult(1/0.95F);
    mouse.sub(new PVector(-528, -90));
    mouse.mult(1/0.35F);
    if (mouseState==AN_PRESS||mouseState==AN_RELEASE)render();//it is so inefficient so I need to use gui library!!
    if (mouseState==AN_PRESS&&new Rect(0, 0, 90, 90).includes(mouse.x, mouse.y)) {
      if (play)play=false;
      else play=true;
    }
    return false;
  }
  @Override
    void render() {
    int a=0;
    strokeWeight(5);
    while (a<areas.size()) {
      areas.get(a).location.render(UIcolors[I_BACKGROUND], UIcolors[I_FOREGROUND]);
      pushMatrix();
      translate(areas.get(a).location.position.x, areas.get(a).location.position.y);
      scale(areas.get(a).location.size.x*2/areas.get(a).image.width, areas.get(a).location.size.y*2/areas.get(a).image.height);
      image(areas.get(a).image, 0, 0);
      popMatrix();
      a=a+1;
    }
    //draw image
    PVector mouse=new PVector(MouseX, MouseY);
    pushMatrix();
    translate(position.x, position.y);
    mouse.sub(position);
    scale(0.95F);
    mouse.mult(1/0.95F);
    fill(color(21, 31, 42/*unipad defualt background*/));
    rect(0, 0, 1280/2, 720/2);
    //
    pushMatrix();
    scale((float)1280/skin_background.width, (float)720/skin_background.height);
    image(skin_background, 0, 0);
    popMatrix();
    image(back, 0, 0);//test
    PVector mouse2=new PVector(mouse.x, mouse.y);
    pushMatrix();
    scale((float)684/(180*ButtonX), (float)684/(180*ButtonY));//change values if they are incorrect.
    mouse2.x=mouse2.x/((float)684/(180*ButtonX));
    mouse2.y=mouse2.y/((float)684/(180*ButtonY));
    boolean coverv=(ButtonX%2==0)&&(ButtonY%2==0);
    int b=0;
    while (b<ButtonY) {
      a=0;
      while (a<ButtonY) {
        float x=-((float)ButtonX-1)*90+a*180;
        float y=-((float)ButtonY-1)*90+b*180;
        pushMatrix();
        translate(x, y);
        if (mousePressed&&new Rect(x, y, 90, 90).includes(mouse2.x, mouse2.y)) {
          scale((float)180/skin_btnPressed.width, (float)180/skin_btnPressed.height);
          image(skin_btnPressed, 0, 0);
        } else {
          scale((float)180/skin_btn.width, (float)180/skin_btn.height);
          image(skin_btn, 0, 0);
        }
        popMatrix();
        pushMatrix();
        translate(x, y);
        if (coverv) {
          if (a==ButtonX/2-1&&b==ButtonY/2-1) {
            scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
            image(skin_coverMiddle, 0, 0);
          } else if (a==ButtonX/2&&b==ButtonY/2-1) {
            scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
            rotate(radians(90));
            image(skin_coverMiddle, 0, 0);
          } else if (a==ButtonX/2&&b==ButtonY/2) {
            scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
            rotate(radians(180));
            image(skin_coverMiddle, 0, 0);
          } else if (a==ButtonX/2-1&&b==ButtonY/2) {
            scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
            rotate(radians(-90));
            image(skin_coverMiddle, 0, 0);
          } else {
            scale((float)180/skin_cover.width, (float)180/skin_cover.height);
            image(skin_cover, 0, 0);
          }
        } else {
          scale((float)180/skin_cover.width, (float)180/skin_cover.height);
          image(skin_cover, 0, 0);
        }
        popMatrix();
        a=a+1;
      }
      //chain(full 8)
      if (b<8) {
        pushMatrix();
        float x=-((float)ButtonX-1)*90+a*180;
        float y=-((float)ButtonY-1)*90+b*180;
        translate(x, y);
        if (mousePressed&&new Rect(x, y, 90, 90).includes(mouse2.x, mouse2.y)) {
          scale((float)180/skin_chainNext.width, (float)180/skin_chainNext.height);
          image(skin_chainNext, 0, 0);
        } else {
          if (b==0) {
            scale((float)180/skin_chainSelected.width, (float)180/skin_chainSelected.height);
            image(skin_chainSelected, 0, 0);
          } else {
            scale((float)180/skin_chain.width, (float)180/skin_chain.height);
            image(skin_chain, 0, 0);
          }
        }
        popMatrix();
      }
      b=b+1;
    }
    popMatrix();
    translate(-528, -90);
    mouse.sub(new PVector(-528, -90));
    scale(0.35F);
    mouse.mult(1/0.35F);
    pushMatrix();
    translate(-180, 0);
    if (mousePressed&&new Rect(-180, 0, 90, 90).includes(mouse.x, mouse.y)) {
      scale((float)180/skin_prevPressed.width, (float)180/skin_prevPressed.height);
      image(skin_prevPressed, 0, 0);
    } else {
      scale((float)180/skin_prev.width, (float)180/skin_prev.height);
      image(skin_prev, 0, 0);
    }
    popMatrix();
    if (mousePressed&&new Rect(0, 0, 90, 90).includes(mouse.x, mouse.y)) {
      pushMatrix();
      if (play) {
        scale((float)180/skin_playPressed.width, (float)180/skin_playPressed.height);
        image(skin_playPressed, 0, 0);
      } else {
        scale((float)180/skin_pausePressed.width, (float)180/skin_pausePressed.height);
        image(skin_pausePressed, 0, 0);
      }
      popMatrix();
    } else {
      //if (mousePressed&&new Rect(0, 0, 90, 90).includes(mouse.x, mouse.y)) {
      pushMatrix();
      if (play) {
        scale((float)180/skin_play.width, (float)180/skin_play.height);
        image(skin_play, 0, 0);
      } else {
        scale((float)180/skin_pause.width, (float)180/skin_pause.height);
        image(skin_pause, 0, 0);
      }
      popMatrix();
      //}
    }
    pushMatrix();
    translate(180, 0);
    if (mousePressed&&new Rect(180, 0, 90, 90).includes(mouse.x, mouse.y)) {
      scale((float)180/skin_nextPressed.width, (float)180/skin_nextPressed.height);
      image(skin_nextPressed, 0, 0);
    } else {
      scale((float)180/skin_next.width, (float)180/skin_next.height);
      image(skin_next, 0, 0);
    }
    popMatrix();
    popMatrix();
    noStroke();
  }
  InnerDropArea getDropAreaItem(int x, int y) {
    int a=0;
    while (a<areas.size()) {
      if (areas.get(a).location.includes(x, y)) {
        return areas.get(a);
      }
      a=a+1;
    }
    return null;
  }
  class InnerDropArea {
    Rect location;//chaos of chaos!!
    PImage image;
    InnerDropArea(Rect location_, PImage image_) {
      location=location_;
      image=image_;
    }
    void setImage(PImage image_) {
      if (image==skin_appIcon) {
        skin_appIcon=image_;
      } else if (image==skin_themeIcon) {
        skin_themeIcon=image_;
      } else if (image==skin_btn) {
        skin_btn=image_;
      } else if (image==skin_btnPressed) {
        skin_btnPressed=image_;
      } else if (image==skin_chain) {
        skin_chain=image_;
      } else if (image==skin_chainSelected) {
        skin_chainSelected=image_;
      } else if (image==skin_chainNext) {
        skin_chainNext=image_;
      } else if (image==skin_play) {
        skin_play=image_;
      } else if (image==skin_playPressed) {
        skin_playPressed=image_;
      } else if (image==skin_pause) {
        skin_pause=image_;
      } else if (image==skin_pausePressed) {
        skin_pausePressed=image_;
      } else if (image==skin_prev) {
        skin_prev=image_;
      } else if (image==skin_prevPressed) {
        skin_prevPressed=image_;
      } else if (image==skin_next) {
        skin_next=image_;
      } else if (image==skin_nextPressed) {
        skin_nextPressed=image_;
      } else if (image==skin_background) {
        skin_background=image_;
      } else if (image==skin_cover) {
        skin_cover=image_;
      } else if (image==skin_coverMiddle) {
        skin_coverMiddle=image_;
      }
      image=image_;
    }
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