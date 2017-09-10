String Convert(String in, int op, int w, int h) {
  if (op<=0)return in;//assert op>0. 0 is for bypass
  String ret="";
  String[] lines=split(in, "\n");
  String error="";
  int a=0;
  while (a<lines.length) {
    //assert no multiple spaces
    String[] tokens=split(lines[a], " ");
    if (tokens[0].equals("on")||tokens.equals("o")||tokens.equals("off")||tokens.equals("f")) {
      ret=ret+"\n"+tokens[0];
      if (op==1) {//Left-Right
        ret=ret+" "+tokens[1]+" "+str(w+1-int(tokens[2]));
      } else if (op==2) {//Up-Down
        ret=ret+" "+str(h+1-int(tokens[1]))+" "+tokens[2];
      } else if (op==3) {//90-Right
        if (w==h) ret=ret+" "+tokens[2]+" "+str(w+1-int(tokens[1]));
        else {
          error="width and height are not same";
          break;
        }
      } else if (op==4) {//180-Right||180-Left
        ret=ret+" "+str(h+1-int(tokens[1]))+" "+str(w+1-int(tokens[2]));
      } else if (op==5) {//90-Left
        if (w==h)ret=ret+" "+str(h+1-int(tokens[2]))+" "+tokens[1];
        else {
          error="width and height are not same";
          break;
        }
      } else if (op==6) {//Y=X
        if (w==h)ret=ret+" "+str(h+1-int(tokens[2]))+" "+str(w+1-int(tokens[1]));
        else {
          error="width and height are not same";
          break;
        }
      } else if (op==7) {//Y=-X
        if (w==h)ret=ret+" "+tokens[2]+" "+tokens[1];
        else {
          error="width and height are not same";
          break;
        }
      }
      int c=3;
      while (c<tokens.length) {//add all tokens
        ret=ret+" "+tokens[c];
        c=c+1;
      }
    } else {//add all tokens
      int c=0;
      ret=ret+"\n"+tokens[0];
      while (c<tokens.length) {
        ret=ret+" "+tokens[c];
        c=c+1;
      }
    }
    a=a+1;
  }
  if (error!="")return "error";
  return ret;
}
String Replace(String in) {
  String ret="";
  return ret;
}