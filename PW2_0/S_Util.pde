String ToUnipadLed(Script script) {
  StringBuilder builder=new StringBuilder();
  float bpmv=120;
  boolean[][] first=new boolean[ButtonX][ButtonY];
  for (int a=0; a<ButtonX; a++) {
    for (int b=0; b<ButtonY; b++) {
      first[a][b]=true;
    }
  }
  script.readAll();
  ArrayList<Command> commands=script.getCommands();
  for (Command cmd : commands) {
    UnipackCommand info=(UnipackCommand)cmd;
    if (info instanceof OnCommand) {
      OnCommand info2=(OnCommand)info;
      first[info2.x-1][info2.y-1]=false;
    } else if (info instanceof OffCommand) {
      OffCommand info2=(OffCommand)info;
      for (int b=info2.y1; b<=info2.y2; b++) {
        for (int a=info2.x1; a<=info2.x2; a++) {
          if (first[a-1][b-1]) {
            builder.append("o "+b+" "+a+" auto 0\n");
          }
        }
      }
      first[info2.x-1][info2.y-1]=false;
    }
    builder.append(info.toUnipadString()).append('\n');//includes multi line
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
  ArrayList<UnipackLine> lines=new ArrayList<UnipackLine>();
  script.readAll();
  image.loadPixels();
  ArrayList<Command> commands=script.getCommands();
  for (Command cmd : commands) {
    if (cmd instanceof LightCommand) {
      LightCommand info=(LightCommand)cmd;
      image.pixels[(info.y-1)*image.width+info.x-1]=info.htmlc;
    } else if (cmd instanceof DelayCommand) {
      break;
    }
  }
  image.updatePixels();
  return image;
}