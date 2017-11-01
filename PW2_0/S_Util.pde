String ToUnipadLed(Script script) {
  StringBuilder builder=new StringBuilder();
  float bpm=120;
  boolean[][] first=new boolean[ButtonX][ButtonY];
  for (int a=0; a<ButtonX; a++) {
    for (int b=0; b<ButtonY; b++) {
      first[a][b]=true;
    }
  }
  script.readAll();
  ArrayList<Command> commands=script.getCommands();
  for (Command cmd : commands) {
    if (cmd instanceof UnipackCommand) {
      UnipackCommand info=(UnipackCommand)cmd;
      if (info instanceof OnCommand) {
        OnCommand info2=(OnCommand)info;
        for (int b=info2.y1; b<=info2.y2; b++) {
          for (int a=info2.x1; a<=info2.x2; a++) {
            first[a-1][b-1]=false;
          }
        }
      } else if (info instanceof OffCommand) {
        OffCommand info2=(OffCommand)info;
        for (int b=info2.y1; b<=info2.y2; b++) {
          for (int a=info2.x1; a<=info2.x2; a++) {
            if (first[a-1][b-1]) {
              builder.append("o "+b+" "+a+" auto 0\n");
            }
            first[a-1][b-1]=false;
          }
        }
      } else if (info instanceof BpmCommand) {
        bpm=((BpmCommand)info).value;
      }
      if (info instanceof DelayCommand) {
        builder.append(((DelayCommand)info).toUnipadString(bpm)).append('\n');//includes multi line
      } else if (info instanceof ChainCommand) {
      } else builder.append(info.toUnipadString()).append('\n');//includes multi line
    }
  }
  return builder.toString();
}
String ImageToLed(PImage image) {
  image.loadPixels();
  StringBuilder str=new StringBuilder();
  for (int a=0; a<image.pixels.length; a++) {
    str.append("on "+str(a/image.width+1)+" "+str(a%image.width+1)+" "+hex(image.pixels[a], 6)+"\n");
  }
  image=null;
  return str.toString();
}
PImage LedToImage(Script script) {
  PImage image=createImage(ButtonX, ButtonY, ARGB);
  script.readAll();
  image.loadPixels();
  ArrayList<Command> commands=script.getCommands();
  for (Command cmd : commands) {
    if (cmd instanceof LightCommand) {
      LightCommand info=(LightCommand)cmd;
      for (int b=info.y1; b<=info.y2; b++) {
        for (int a=info.x1; a<=info.x2; a++) {
          image.pixels[(b-1)*image.width+a-1]=info.htmlc;
        }
      }
    } else if (cmd instanceof DelayCommand) {
      break;
    }
  }
  image.updatePixels();
  return image;
}