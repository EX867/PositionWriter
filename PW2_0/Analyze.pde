
  void onLED(UnipackLine info, int x, int y, int frame) {
    if (0>info.vel||info.vel>127)LED.get(frame)[x-1][y-1]=OFFCOLOR;
    else if (info.hasHtml)LED.get(frame)[x-1][y-1]=info.html;
    else if (info.hasVel)LED.get(frame)[x-1][y-1]=k[info.vel];
  }
  void offLED(UnipackLine info, int x, int y, int frame) {//DELETE
    LED.get(frame)[x-1][y-1]=OFFCOLOR;
  }
  class UnipackLine {
    static final int TITLE=11;
    static final int PRODUCERNAME=12;
    static final int BUTTONX=13;
    static final int BUTTONY=14;
    static final int CHAINNUMBER=15;
    static final int LANDSCAPE=16;
    static final int SQUAREBUTTON=17;
    static final int UPDATED=18;
  //keysound
  //autoPlay
  UnipackInfo getEmptyUnipackInfo() {
    return new UnipackInfo();
  }
  public class UnipackInfo {
    boolean valid=true;
    String title="";
    String producerName="";
    int buttonX=8;
    int buttonY=8;
    int chain=3;
    boolean landscape=true;
    boolean squareButton=true;
    boolean updated=false;
    public UnipackInfo() {
    }
    @Override
      String toString() {
      String ret="";
      ret+="title="+title+"\n";
      ret+="producerName="+producerName+"\n";
      ret+="buttonX="+buttonX+"\n";
      ret+="buttonY="+buttonY+"\n";
      ret+="chain="+chain+"\n";
      ret+="squareButton="+str(squareButton)+"\n";
      ret+="landscape="+str(landscape)+"\n";
      ret+="updated"+str(updated);
      return ret;
    }
    String uncloud_toString() {
      String ret="";
      ret+="title="+title+"\n";
      ret+="producerName="+producerName+"\n";
      ret+="buttonX="+buttonX+"\n";
      ret+="buttonY="+buttonY+"\n";
      ret+="chain="+chain+"\n";
      return ret;
    }
  }
  public UnipackInfo getUnipackInfo(String filename, String text) {
    UnipackInfo ret=new UnipackInfo();
    boolean[] check = new boolean[7];
    int a=0;
    while (a<7) {
      check[a]=false;
      a++;
    }
    String[] lines=split(text, "\n");
    a=0;
    while (a<lines.length) {
      UnipackLine result=AnalyzeLine(a, filename, lines[a]);
      if (result.Type==UnipackLine.TITLE) {
        ret.title=result.value;
        check[0]=true;
      } else if (result.Type==UnipackLine.PRODUCERNAME) {
        ret.producerName=result.value;
        check[1]=true;
      } else if (result.Type==UnipackLine.BUTTONX) {
        ret.buttonX=int(result.value);
        check[2]=true;
      } else if (result.Type==UnipackLine.BUTTONY) {
        ret.buttonY=int(result.value);
        check[3]=true;
      } else if (result.Type==UnipackLine.CHAINNUMBER) {
        ret.chain=int(result.value);
        check[4]=true;
      } else if (result.Type==UnipackLine.LANDSCAPE) {
        ret.landscape=toBoolean(result.value);
        check[5]=true;
      } else if (result.Type==UnipackLine.SQUAREBUTTON) {
        ret.squareButton=toBoolean(result.value);
        check[6]=true;
      } else if (result.Type==UnipackLine.UPDATED) {
        ret.updated=toBoolean(result.value);
      }
      a=a+1;
    }
    a=0;
    while (a<7) {
      if (a==5)a++;
      if (check[a]==false)ret.valid=false;
      a=a+1;
    }
    return ret;
  }
  public UnipackLine AnalyzeLine(int line, String filename, String in) {//if cyxmode, post filtered.
    if (in==null)return null;
    int a=1;
    while (a<in.length()) {
      if (in.charAt(a-1)=='/'&&in.charAt(a)=='/') {
        in=in.substring(0, a-1);
        break;
      }
      a=a+1;
    }
    in = in.trim();
    String[] tokens = split(in, " ");
    boolean mc=false;
    if (in.equals(""))return new UnipackLine(filename, DEFAULT);
    if (tokens[0].equals("on") || tokens[0].equals("o")) {
      if (tokens.length == 4) {
        if (tokens[1].equals("mc")) {
          mc=true;
          if (isInt(tokens[2])) {
            if (1<=int(tokens[2])&&int(tokens[2])<=32==false)printWarning(2, line, filename, tokens[2], "mc number is out of range.");
            if (tokens[3].equals("rnd")) {
              return new UnipackLine(filename, UnipackLine.ON, true, int(tokens[2]), 0, false, true, 0, RNDCOLOR);
            } else if (isInt(tokens[3])) {
              if (0 <= Integer.parseInt(tokens[3]) && Integer.parseInt(tokens[3]) <= 127==false)printWarning(2, line, filename, in, "velocity number is out of range.");
              return new UnipackLine(filename, UnipackLine.ON, true, int(tokens[2]), 0, true, false, int(tokens[3]), 0);
            } else if (isHex(tokens[3]))return new UnipackLine(filename, UnipackLine.ON, true, int(tokens[2]), 0, false, true, 0, color(unhex(""+tokens[3].charAt(0)+tokens[3].charAt(1)), unhex(""+tokens[3].charAt(2)+tokens[3].charAt(3)), unhex(""+tokens[3].charAt(4)+tokens[3].charAt(5))));
            else printError(2, line, filename, in, "velocity number or html color is incorrect!");
          } else printError(2, line, filename, in, "mc number is not integer!");
        } else {
          if (isRange(tokens[1]) && isRange(tokens[2])) {
            int y=getRangeFirst(tokens[1]);
            int y2=getRangeSecond(tokens[1]);
            int x=getRangeFirst(tokens[2]);
            int x2=getRangeSecond(tokens[2]);
            if (y<=0||y>ButtonY||x<=0||x>ButtonX||y2<=0||y2>ButtonY||x2<=0||x2>ButtonX)printWarning(2, line, filename, in, "button number is out of range.");
            if (tokens[3].equals("rnd")) {
              return new UnipackLine(filename, UnipackLine.ON, false, x, y, x2, y2, false, true, 0, RNDCOLOR);
            } else if (isInt(tokens[3])) {
              if (0 <= int(tokens[3]) && int(tokens[3]) <= 127==false)printWarning(2, line, filename, in, "velocity number is out of range.");
              return new UnipackLine(filename, UnipackLine.ON, false, x, y, x2, y2, true, false, int(tokens[3]), 0);
            } else if (isHex(tokens[3]))return new UnipackLine(filename, UnipackLine.ON, false, x, y, x2, y2, false, true, 0, color(unhex(""+tokens[3].charAt(0)+tokens[3].charAt(1)), unhex(""+tokens[3].charAt(2)+tokens[3].charAt(3)), unhex(""+tokens[3].charAt(4)+tokens[3].charAt(5))));
            else printError(2, line, filename, tokens[3], "velocity number or html color is incorrect!");
          } else printError(2, line, filename, in, "x or y number is not integer or range!");
        }//end else
      } else if (tokens.length == 5) {
        if (tokens[1].equals("mc")) {
          mc=true;
          if (isInt(tokens[2])) {
            if (1<=int(tokens[2])&&int(tokens[2])<=32==false)printWarning(2, line, filename, tokens[2], "mc number is out of range.");
            if (tokens[3].equals("auto") || tokens[3].equals("a")) {
              if (tokens[4].equals("rnd")) {
                return new UnipackLine(filename, UnipackLine.ON, true, int(tokens[2]), 0, false, true, 0, RNDCOLOR);
              } else if (isInt(tokens[4])) {
                if (0 <= Integer.parseInt(tokens[4]) && Integer.parseInt(tokens[4]) <= 127==false) printWarning(2, line, filename, tokens[4], "velocity number is out of range.");
                return new UnipackLine(filename, UnipackLine.ON, true, int(tokens[2]), 0, true, false, int(tokens[4]), 0);
              } else printError(2, line, filename, tokens[4], "velocity number is not integer!");
            } else {
              if (isHex(tokens[3])) {
                if (isInt(tokens[4])) {
                  if (0 <= Integer.parseInt(tokens[4]) && Integer.parseInt(tokens[4]) <= 127==false)printWarning(2, line, filename, tokens[4], "velocity number is out of range.");
                  return new UnipackLine(filename, UnipackLine.ON, false, int(tokens[2]), 0, true, true, int(tokens[4]), color(unhex(""+tokens[3].charAt(0)+tokens[3].charAt(1)), unhex(""+tokens[3].charAt(2)+tokens[3].charAt(3)), unhex(""+tokens[3].charAt(4)+tokens[3].charAt(5))));
                } else printError(2, line, filename, tokens[4], "velocity number is not integer!");
              } else printError(2, line, filename, tokens[3], "html color is not correct hex number!");
            }//end else
          } else printError(2, line, filename, tokens[2], "mc number is not a integer!");
        } else {
          if (isRange(tokens[1]) && isRange(tokens[2])) {
            int y=getRangeFirst(tokens[1]);
            int y2=getRangeSecond(tokens[1]);
            int x=getRangeFirst(tokens[2]);
            int x2=getRangeSecond(tokens[2]);
            if (y<=0||y>ButtonY||x<=0||x>ButtonX||y2<=0||y2>ButtonY||x2<=0||x2>ButtonX)printWarning(2, line, filename, in, "button number is out of range.");
            if (tokens[3].equals("auto") || tokens[3].equals("a")) {
              if (tokens[4].equals("rnd")) {
                return new UnipackLine(filename, UnipackLine.ON, false, x, y, x2, y2, false, true, 0, RNDCOLOR);
              } else if (isInt(tokens[4])) {
                if (0 <= int(tokens[4]) && int(tokens[4]) <= 127==false)printWarning(2, line, filename, tokens[4], "velocity number is out of range.");
                return new UnipackLine(filename, UnipackLine.ON, false, x, y, x2, y2, true, false, int(tokens[4]), 0);
              } else printError(2, line, filename, tokens[4], "velocity number is not integer!");
            } else {
              if (isHex(tokens[3])) {
                if (isInt(tokens[4])) {
                  if (0 <= int(tokens[4]) && int(tokens[4]) <= 127==false)printWarning(2, line, filename, tokens[4], "velocity number is out of range.");
                  return new UnipackLine(filename, UnipackLine.ON, false, x, y, x2, y2, true, true, int(tokens[4]), color(unhex(""+tokens[3].charAt(0)+tokens[3].charAt(1)), unhex(""+tokens[3].charAt(2)+tokens[3].charAt(3)), unhex(""+tokens[3].charAt(4)+tokens[3].charAt(5))));
                } else printError(2, line, filename, tokens[4], "velocity number is not integer!");
              } else printError(2, line, filename, tokens[3], "html color is not correct hex number!");
            }//end else
          } else printError(2, line, filename, in, "x or y number is not integer or range!");
        }//end else
      } else if (tokens.length == 3) {//(autoPlay) - post filtered
        if (tokens[1].equals("mc")) {
          mc=true;
          if (isInt(tokens[2])) {
            if (1<=int(tokens[2])&&int(tokens[2])<=32==false)printWarning(3, line, filename, tokens[2], "mc number is out of range.");
            return new UnipackLine(filename, UnipackLine.APON, true, int(tokens[2]), 0, false, false, 0, OFFCOLOR+1);
          } else printError(3, line, filename, tokens[2], "mc number is not integer!");
        } else {
          if (isRange(tokens[1]) && isRange(tokens[2])) {
            int y=getRangeFirst(tokens[1]);
            int y2=getRangeSecond(tokens[1]);
            int x=getRangeFirst(tokens[2]);
            int x2=getRangeSecond(tokens[2]);
            if (y<=0||y>ButtonY||x<=0||x>ButtonX||y2<=0||y2>ButtonY||x2<=0||x2>ButtonX)printWarning(2, line, filename, in, "button number is out of range.");
            return new UnipackLine(filename, UnipackLine.APON, false, x, y, x2, y2, false, false, 0, OFFCOLOR+1);
          } else printError(3, line, filename, in, "x or y number is not integer!");
        }//end else
      } else printError(1, line, filename, in, "on command expects [on y x auto...] or [on y x html...].");
    } else if (tokens[0].equals("off") || tokens[0].equals("f")) {
      if (tokens.length == 3) {
        if (tokens[1].equals("mc")) {
          mc=true;
          if (isInt(tokens[2])) {
            if (1<=int(tokens[2])&&int(tokens[2])<=32==false)printWarning(1, line, filename, tokens[2], "mc number is out of range.");
            return new UnipackLine(filename, UnipackLine.OFF, true, int(tokens[2]), 0, false, false, 0, 0);
          } else printError(1, line, filename, tokens[2], "mc number is not integer!");
        } else {
          if (isRange(tokens[1]) && isRange(tokens[2])) {
            int y=getRangeFirst(tokens[1]);
            int y2=getRangeSecond(tokens[1]);
            int x=getRangeFirst(tokens[2]);
            int x2=getRangeSecond(tokens[2]);
            if (y<=0||y>ButtonY||x<=0||x>ButtonX||y2<=0||y2>ButtonY||x2<=0||x2>ButtonX)printWarning(2, line, filename, in, "button number is out of range.");
            return new UnipackLine(filename, UnipackLine.OFF, false, x, y, x2, y2, false, false, 0, 0);
          } else printError(1, line, filename, in, "x or y number is not integer!");
        }//end else
      } else printError(1, line, filename, in, "off command expects [off y x] or [off mc n].");
    } else if (tokens[0].equals("delay") || tokens[0].equals("d")) {
      if (tokens.length == 2) {
        String[] isdivided = split(tokens[1], "/");
        if (isdivided.length == 2) {
          if (BpmPoint.size()==0)printWarning(1, line, filename, in, "you must set bpm before using delay fraction command. defalut bpm is 120.");
          else if (BpmPoint.get(0)>line)printWarning(1, line, filename, in, "you must set bpm before using delay fraction command. defalut bpm is 120.");
          if (isInt(isdivided[0]) && isInt(isdivided[1])) {
            if (Integer.parseInt(isdivided[1]) * Integer.parseInt(isdivided[0]) >= 0) {
              if (int(isdivided[1])!=0) {
                if (Integer.parseInt(isdivided[0]) == 0)printWarning(1, line, filename, in, "delay number is 0.");
                return new UnipackLine(filename, UnipackLine.DELAY, false, int(isdivided[0]), int(isdivided[1]), true, true, 0, 0);
              } else printError(1, line, filename, in, "divided by 0!");
            } else printError(1, line, filename, in, "delay number must be greater than 0.");
          } else printError(1, line, filename, in, "delay number fraction is incorrect.");
        } else if (isdivided.length == 1) {
          if (isInt(isdivided[0])) {
            if (int(isdivided[0])>=0) {
              if (int(isdivided[0])==0)printWarning(1, line, filename, in, "delay number is 0.");
              return new UnipackLine(filename, UnipackLine.DELAY, false, int(isdivided[0]), 0, true, false, 0, 0);
            } else printError(1, line, filename, in, "delay number must be greater than 0.");
          } else printError(1, line, filename, in, "delay number is not integer!");
        } else printError(1, line, filename, in, "delay number fraction is incorrect.");
      } else printError(1, line, filename, in, "delay command expects [delay time] or [delay a/b].");
    } else if (tokens[0].equals("chain") || tokens[0].equals("c")) {//post filtered in ledEditor.
      if (tokens.length == 2) {
        if (isInt(tokens[1]))return new UnipackLine(filename, UnipackLine.CHAIN, false, int(tokens[1]), 0, true, false, 0, 0);
        else printError(1, line, filename, in, "chain number is not integer!");
      } else printError(1, line, filename, in, "chain command expects [chain c].");
    } else if (tokens[0].equals("mapping")||tokens[0].equals("m")) {
      if (tokens.length==5) {
        if (tokens[2].equals("mc")) {
          if (isInt(tokens[3])) {
            if (int(tokens[3])<=0||int(tokens[3])>32)printWarning(2, line, filename, in, "mc number is out of range.");
            if (isInt(tokens[4])) {
              if (int(tokens[4])<0)printWarning(2, line, filename, in, "mapping index number out of range.");
              if (tokens[1].equals("s")) {
                return new UnipackLine(filename, UnipackLine.MAPPING, true, int(tokens[3]), 0, true, false, int(tokens[4]), 0);
              } else if (tokens[1].equals("l")) {
                return new UnipackLine(filename, UnipackLine.MAPPING, true, int(tokens[3]), 0, false, false, int(tokens[4]), 0);
              } else printError(2, line, filename, in, "only 's' and 'l' can be used in option.");
            } else printError(2, line, filename, in, "mapping index number must be a integer.");
          } else printError(2, line, filename, in, "mapping index number must be a integer.");
        } else if (isInt(tokens[2]) && isInt(tokens[3])) {
          if (int(tokens[2])<=0||int(tokens[2])>ButtonY||int(tokens[3])<=0||int(tokens[3])>ButtonX)printWarning(2, line, filename, in, "button number is out of range.");
          if (isInt(tokens[4])) {
            if (int(tokens[4])<0)printWarning(2, line, filename, in, "mapping index number out of range.");
            if (tokens[1].equals("s")) {
              return new UnipackLine(filename, UnipackLine.MAPPING, false, int(tokens[3]), int(tokens[2]), true, false, int(tokens[4]), 0);
            } else if (tokens[1].equals("l")) {
              return new UnipackLine(filename, UnipackLine.MAPPING, false, int(tokens[3]), int(tokens[2]), false, false, int(tokens[4]), 0);
            } else printError(2, line, filename, in, "only 's' and 'l' can be used in option.");
          } else printError(2, line, filename, in, "mapping index number must be a integer.");
        }
      } else printError(2, line, filename, in, "mapping command expects [mapping [s|l] y x n].");
    } else if (tokens[0].equals("filename")) {
      printError(1, line, filename, in, "filename command is not supported in PositionWriter 2.0.");
      if (tokens.length == 5||tokens.length == 6) {// [filename c y x loop] || [filename c y x loop option] || [filename c y x loop multi]
      } else if (tokens.length == 7) {//[filename c y x loop multi default]
        if (tokens[5].length() > 0) {
          if (tokens[6].equals("default") || tokens[6].equals("d") || tokens[6].equals("0")||tokens[6].equals("L-R") || tokens[6].equals("1")||tokens[6].equals("U-D") || tokens[6].equals("2")||tokens[6].equals("90-R") || tokens[6].equals("3")||tokens[6].equals("180-R") || tokens[6].equals("180-L") || tokens[6].equals("4")||tokens[6].equals("90-L") || tokens[6].equals("5")||tokens[6].equals("Y=X") || tokens[6].equals("6")||tokens[6].equals("Y=-X") || tokens[6].equals("7")) {
            return new UnipackLine(filename, DEFAULT);
          } else printError(1, line, filename, in, "filename command is incorrect.");
        } else printError(1, line, filename, in, "filename command is incorrect.");
      } else printError(1, line, filename, in, "filename command is incorrect.");
    } else if (tokens[0].equals("bpm")||tokens[0].equals("b")) {
      if (tokens.length == 2) {
        if (isNumber(tokens[1])) {
          if (int(tokens[1])<=0)printError(1, line, filename, in, "bpm number must be greater than 0!");
          else return new UnipackLine(filename, UnipackLine.BPM, float(tokens[1]));
        } else printError(1, line, filename, in, "bpm number is not a number!");
      } else printError(1, line, filename, in, "bpm command expects [bpm n].");
    } else if (isInt(tokens[0])) {// c y x filename [loop] (keysound) - post filtered.
      if (tokens.length>3) {
        if (int(tokens[1])<=0&&int(tokens[1])>Chain)printWarning(1, line, filename, in, "chain number is out of range.");
        if (isInt(tokens[1]) && isInt(tokens[2])) {
          if (int(tokens[1])<=0||int(tokens[1])>ButtonY||int(tokens[2])<=0||int(tokens[2])>ButtonX)printWarning(1, line, filename, in, "button number is out of range.");
          String[] ttokens = split(in, "\"");
          if (ttokens.length == 3) {
            ttokens[1] = ttokens[1].trim();// make error...?
            ttokens[2] = ttokens[2].trim();// make error...?
            if (ttokens[2].length() == 0)return new UnipackLine(filename, UnipackLine.KEYSOUND, int(tokens[0]), int(tokens[2]), int(tokens[1]), ttokens[1], true, 1);
            else if (isInt(ttokens[2])) {
              if (int(ttokens[2])<0)printWarning(1, line, filename, ttokens[2], "loop number is negative");
              return new UnipackLine(filename, UnipackLine.KEYSOUND, int(tokens[0]), int(tokens[2]), int(tokens[1]), ttokens[1], true, int(ttokens[2]));
            } else printError(1, line, filename, in, "incorrect keysound command.");
          } else if (ttokens.length == 1) {
            if (tokens.length == 4)return new UnipackLine(filename, UnipackLine.KEYSOUND, int(tokens[0]), int(tokens[2]), int(tokens[1]), tokens[3], false, 1);
            else if (tokens.length == 5) {
              if (isInt(tokens[4])) {
                if (int(tokens[4])<0)printWarning(1, line, filename, tokens[4], "loop number is negative");
                return new UnipackLine(filename, UnipackLine.KEYSOUND, int(tokens[0]), int(tokens[2]), int(tokens[1]), tokens[3], false, int(tokens[4]));
              } else printError(1, line, filename, tokens[4], "loop number is not a number!");
            } else printError(1, line, filename, in, "incorrect keysound command.");
          } else printError(1, line, filename, in, " must be closed with .");
        } else printError(1, line, filename, in, "x or y number is not integer!");
      } else printError(1, line, filename, in, "keysound command expects [c y x filename] or [c y x filename loop].");
    } else {
      tokens = split(in, "=");
      a=2;
      String temp="";
      if (tokens.length>1)temp=tokens[1];
      while (a<tokens.length) {
        temp=temp+"="+tokens[a];
        a=a+1;
      }
      if (tokens.length>0) {
        if (tokens[0].equals("title")) return new UnipackLine(filename, UnipackLine.TITLE, temp);
        else if (tokens[0].equals("producerName")) return new UnipackLine(filename, UnipackLine.PRODUCERNAME, temp);
        else if (tokens[0].equals("buttonX")) {
          if (tokens.length==2) {
            if (isInt(tokens[1]))return new UnipackLine(filename, UnipackLine.BUTTONX, tokens[1]);
            else printError(1, line, filename, in, "buttonX is not integer.");
          } else printError(1, line, filename, in, "buttonX is not integer.");
        } else if (tokens[0].equals("buttonY")) {
          if (tokens.length==2) {
            if (isInt(tokens[1]))return new UnipackLine(filename, UnipackLine.BUTTONY, tokens[1]);
            else printError(1, line, filename, in, "buttonY is not integer.");
          } else printError(1, line, filename, in, "buttonY is not integer.");
        } else if (tokens[0].equals("chain")) {
          if (tokens.length==2) {
            if (isInt(tokens[1]))return new UnipackLine(filename, UnipackLine.CHAINNUMBER, tokens[1]);
            else printError(1, line, filename, in, "chain is not integer.");
          } else printError(1, line, filename, in, "chain is not integer.");
        } else if (tokens[0].equals("landscape")) {
          if (tokens.length==2) {
            if (isBoolean(tokens[1]))return new UnipackLine(filename, UnipackLine.LANDSCAPE, tokens[1]);
            else printError(1, line, filename, in, "landscape is not boolean.");
          } else printError(1, line, filename, in, "landscape is not boolean.");
        } else if (tokens[0].equals("squareButton")) {
          if (tokens.length==2) {
            if (isBoolean(tokens[1]))return new UnipackLine(filename, UnipackLine.SQUAREBUTTON, tokens[1]);
            else printError(1, line, filename, in, "squareButton is not boolean.");
          } else printError(1, line, filename, in, "squareButton is not boolean.");
        } else if (tokens[0].equals("updated")) {
          if (tokens.length==2) {
            if (isInt(tokens[1]))return new UnipackLine(filename, UnipackLine.UPDATED, tokens[1]);
            else printError(1, line, filename, in, "updated is not boolean.");
          } else printError(1, line, filename, in, "updated is not boolean.");
        } else printError(1, line, filename, in, "unknown command.");
      }
    }
    return new UnipackLine(filename, DEFAULT, mc);
  }
  //============================================================================================================================================
  void readFrameLed(int frame, int count) {
    if (frame==0) {
      int b=0;
      while (b<ButtonX) {
        int c=0;
        while (c<ButtonY) {
          LED.get(frame)[b][c]=OFFCOLOR;
          apLED.get(frame)[b][c]=false;
          c=c+1;
        }
        b=b+1;
      }
    } else {
      int b=0;
      while (b<ButtonX) {
        int c=0;
        while (c<ButtonY) {
          LED.get(frame)[b][c]=LED.get(frame-1)[b][c];
          apLED.get(frame)[b][c]=apLED.get(frame-1)[b][c];
          c=c+1;
        }
        b=b+1;
      }
    }
    int d=DelayPoint.get(frame)+1;
    count=frame+count;
    while (frame<=count&&d<Lines.lines()) {//reset
      UnipackLine info=uLines.get(d);//AnalyzeLine(a, "readFrame - read "+count+" frames", Lines.getLine(a));
      if (info.mc) {
        d++;
        continue;
      }
      if (info.Type==UnipackLine.ON) {
        if (0<info.x&&info.x<=ButtonX&&0<info.y&&info.y<=ButtonY&&0<info.x2&&info.x2<=ButtonX&&0<info.y2&&info.y2<=ButtonY) {
          for (int a=info.x; a<=info.x2; a++) {
            for (int b=info.y; b<=info.y2; b++) {
              onLED(info, a, b, frame);
            }
          }
        }
      } else if (info.Type==UnipackLine.OFF) {
        if (0<info.x&&info.x<=ButtonX&&0<info.y&&info.y<=ButtonY&&0<info.x2&&info.x2<=ButtonX&&0<info.y2&&info.y2<=ButtonY) {
          for (int a=info.x; a<=info.x2; a++) {
            for (int b=info.y; b<=info.y2; b++) {
              offLED(info, a, b, frame);
              offApLED(info, a, b, frame);
            }
          }
        }
      } else if (info.Type==UnipackLine.DELAY) {
        frame++;
        int b=0;
        while (b<ButtonX) {
          int c=0;
          while (c<ButtonY) {
            LED.get(frame)[b][c]=LED.get(frame-1)[b][c];
            apLED.get(frame)[b][c]=apLED.get(frame-1)[b][c];
            c=c+1;
          }
          b=b+1;
        }
      } else if (info.Type==UnipackLine.APON) {
        if (0<info.x&&info.x<=ButtonX&&0<info.y&&info.y<=ButtonY&&0<info.x2&&info.x2<=ButtonX&&0<info.y2&&info.y2<=ButtonY) {
          for (int a=info.x; a<=info.x2; a++) {
            for (int b=info.y; b<=info.y2; b++) {
              onApLED(info, a, b, frame);
            }
          }
        }
      }
      d++;
    }
  }
  void readFrameLedPosition(int frame, int line, int x, int y, color c, UnipackLine toset) {//assert line is in frame.
    if (line>=Lines.lines())return;
    line=line+1;
    if (0<x&&x<=ButtonX&&0<y&&y<=ButtonY) {
      UnipackLine temp=new UnipackLine("", DEFAULT);
      if (toset!=null)temp=toset;//dirty too.
      boolean changed=false;
      UnipackLine info;
      while (line<Lines.lines()) {//reset
        info=uLines.get(line);
        if (!info.mc) {
          if (info.Type==UnipackLine.ON) {
            if (info.x<=x&&x<=info.x2&&info.y<=y&&y<=info.y2) {
              changed=true;
              temp=info;
            }
          } else if (info.Type==UnipackLine.OFF) {
            if (info.x<=x&&x<=info.x2&&info.y<=y&&y<=info.y2) {
              changed=true;
              temp=info;
            }
          } else if (info.Type==UnipackLine.DELAY) {
            if (changed==false) {
              if (temp.Type==UnipackLine.ON)onLED (temp, x, y, frame);
              else if (temp.Type==UnipackLine.OFF) offLED (temp, x, y, frame);
              else if (temp.Type==DEFAULT) {//dirty!
                LED.get(frame)[x-1][y-1]=c;
              }
            } else {
              break;
            }
            frame++;
          }
        }
        line++;
      }
      if (changed==false&&line==Lines.lines()) {
        if (temp.Type==UnipackLine.ON)onLED (temp, x, y, frame);
        else if (temp.Type==UnipackLine.OFF) offLED (temp, x, y, frame);
        else if (temp.Type==DEFAULT) {//dirty!
          LED.get(frame)[x-1][y-1]=c;
        }
      }
    }
  }
  void eraseLedPosition(int frame, int line, int x, int y, boolean skip) {
    if (0<x&&x<=ButtonX&&0<y&&y<=ButtonY) {
      int a=DelayPoint.get (frame)+1;
      if (frame==0) {
        LED.get(frame)[x-1][y-1]=OFFCOLOR;
      } else {
        LED.get (frame)[x-1][y-1]=LED.get (frame-1)[x-1][y-1];
      }
      UnipackLine info;
      int max=Lines.lines();
      if (frame<DelayPoint.size()-1)max=DelayPoint.get(frame+1);
      while (a <max) {
        if (skip&&a==line) {//skip line to erase.
        } else {
          info=uLines.get(a);
          if (!info.mc) {
            if (info.Type==UnipackLine.ON) {
              if (info.x<=x&&x<=info.x2&&info.y<=y&&y<=info.y2) onLED (info, x, y, frame);
            } else if (info.Type==UnipackLine.OFF) {
              if (info.x<=x&&x<=info.x2&&info.y<=y&&y<=info.y2) offLED (info, x, y, frame);
            }
          }
        }
        a=a+1;
      }
      readFrameLedPosition (frame+1, max, x, y, LED.get (frame)[x-1][y-1], null);
    }
  }
  void readAll(ArrayList<String> lines) {
    clear();
    float bpm=120;
    int d=0;
    while (d<lines.size()) {
      adderror=true;
      UnipackLine line=AnalyzeLine(d, "readFrame", lines.get(d));
      adderror=false;
      uLines.add(line);
      if (line.Type==UnipackLine.ON) {
        if (0<line.x&&line.x<=ButtonX&&0<line.y&&line.y<=ButtonY&&0<line.x2&&line.x2<=ButtonX&&0<line.y2&&line.y2<=ButtonY) {
          for (int a=line.x; a<=line.x2; a++) {
            for (int b=line.y; b<=line.y2; b++) {
              onLED(line, a, b, LED.size()-1);
            }
          }
        }
      } else if (line.Type==UnipackLine.APON) {
        if (0<line.x&&line.x<=ButtonX&&0<line.y&&line.y<=ButtonY&&0<line.x2&&line.x2<=ButtonX&&0<line.y2&&line.y2<=ButtonY) {
          for (int a=line.x; a<=line.x2; a++) {
            for (int b=line.y; b<=line.y2; b++) {
              onApLED(line, a, b, apLED.size()-1);
            }
          }
        }
      } else if (line.Type==UnipackLine.OFF) {
        if (0<line.x&&line.x<=ButtonX&&0<line.y&&line.y<=ButtonY&&0<line.x2&&line.x2<=ButtonX&&0<line.y2&&line.y2<=ButtonY) {
          for (int a=line.x; a<=line.x2; a++) {
            for (int b=line.y; b<=line.y2; b++) {
              offLED(line, a, b, LED.size()-1);
              offApLED(line, a, b, apLED.size()-1);
            }
          }
        }
      } else if (line.Type==UnipackLine.DELAY) {
        LED.add(new color[ButtonX][ButtonY]);
        apLED.add(new boolean[ButtonX][ButtonY]);
        int b=0;
        while (b<ButtonX) {
          int c=0;
          while (c<ButtonY) {
            LED.get(LED.size()-1)[b][c]=LED.get(LED.size()-2)[b][c];
            apLED.get(apLED.size()-1)[b][c]=apLED.get(apLED.size()-2)[b][c];
            c=c+1;
          }
          b=b+1;
        }
        DelayPoint.add(d);
      } else if (line.Type==UnipackLine.BPM) {
        BpmPoint.add(d);
      } else if (line.Type==UnipackLine.CHAIN) {
        apChainPoint.add(d);
      }//else ignore
      d=d+1;
    }
    currentLedFrame=min(currentLedFrame, DelayPoint.size()-1);
    setTimeByFrame();
  }
  boolean loadLedFile(String path, ArrayList<UnipackLine> led, ArrayList<Integer> delayv) {//assert is file.
    try {
      return parseLed(readFile(path), led, delayv);
    }
    catch(Exception e) {
      e.printStackTrace();
      return false;
    }
  }
  boolean parseLed(String alltext, ArrayList<UnipackLine> led, ArrayList<Integer> delayv) {
    led.clear();
    delayv.clear();
    String[] lines=split(alltext, "\n");
    int a=0;
    float  bpmv=120;
    while (a<lines.length) {
      UnipackLine line=AnalyzeLine(a, "LoadLedFile", lines[a]);
      if (line.Type==UnipackLine.ON) {
        led.add(line);
      } else if (line.Type==UnipackLine.OFF) {
        led.add(line);
      } else if (line.Type==UnipackLine.DELAY) {
        if (line.hasHtml)floor((line.x*2400/(bpmv*line.y))*100);
        else delayv.add(line.x);//ms
        led.add(line);
      } else if (line.Type==UnipackLine.BPM) {
        bpmv=line.valueF;
      } else if (line.Type==UnipackLine.CHAIN) {
        led.add(line);
      } else if (line.Type==UnipackLine.MAPPING) {
        led.add(line);
      }
      a=a+1;
    }
    //return readFrame(split(readFile(path), "\n"), led, delayv, new ArrayList<Integer>(), new ArrayList<Integer>(), new ArrayList<UnipackLine>(), false);
    return true;
  }
  ArrayList<UnipackLine> loadKeySound(String path) throws Exception {
    ArrayList<UnipackLine> ret=new ArrayList<UnipackLine>();
    String alltext=readFile(path);
    String[] lines=split(alltext, "\n");
    int a=0;
    while (a<lines.length) {
      UnipackLine line=AnalyzeLine(a, "LoadLedFile", lines[a]);
      if (line.Type==UnipackLine.KEYSOUND) {
        ret.add(line);
      }
      a=a+1;
    }
    return ret;
  }
  boolean loadKeyLedFlag =false;//true if loading
  void loadKeyLedGlobal(String filename) throws Exception {
    if (loadKeyLedFlag)return;//ignore
    File file=new File(filename);
    if (file.isFile()) {
      loadKeyLedFlag=true;
      String text;
      try {
        text=readFile(filename).replace("\r\n", "\n").replace("\r", "\n");
      }
      catch(Exception e) {
        loadKeyLedFlag=false;
        throw e;
      }
      if (text!=null) {//???
        currentLedFrame=0;
        frameSlider.skip=true;
        ((TextEditor)UI[textfieldId]).setText(text);
        frameSlider.skip=false;
        registerRender();
      }
      loadKeyLedFlag=false;
    } else if (file.isDirectory()) {
      throw new Exception("ignore");
    } else {
      throw new Exception("file not exists : "+filename);
    }
  }
  boolean loadKeySoundFlag=false;//true if loading
  void loadKeySoundGlobal(String filename) throws Exception {
    if (loadKeySoundFlag)return;//ignore
    File file=new File(filename);
    println(filename);
    if (file.isDirectory()) {//and exists
      try {
        loadKeySoundFlag=true;
        println("load start");
        File infof=new File(joinPath(filename, "info"));
        File keySoundf=new File(joinPath(filename, "keySound"));
        File soundsf=new File(joinPath(filename, "sounds"));
        File keyLEDf=new File(joinPath(filename, "keyLED"));
        File projectf=new File(joinPath(filename, ".project"));
        if (infof.isFile()) {
          println("load info "+infof.getAbsolutePath());
          UnipackInfo info=getUnipackInfo(infof.getAbsolutePath(), readFile(infof.getAbsolutePath()));
          if (info.valid) {
            ((TextBox)UI[getUIid("I_TITLE")]).text=info.title;
            ((TextBox)UI[getUIid("I_PRODUCERNAME")]).text=info.producerName;
            ((TextBox)UI[getUIid("I_BUTTONX")]).value=info.buttonX;
            ((TextBox)UI[getUIid("I_BUTTONX")]).text=""+info.buttonX;
            ((TextBox)UI[getUIid("I_BUTTONY")]).value=info.buttonY;
            ((TextBox)UI[getUIid("I_BUTTONY")]).text=""+info.buttonY;
            ((TextBox)UI[getUIid("I_CHAIN")]).value=info.chain;
            ((TextBox)UI[getUIid("I_CHAIN")]).text=""+info.chain;
            ((Button)UI[getUIid("I_LANDSCAPE")]).value=info.landscape;
            ((Button)UI[getUIid("I_SQUAREBUTTONS")]).value=info.squareButton;
            ButtonX=info.buttonX;
            ButtonY=info.buttonY;
            Chain=info.chain;
          } else {//ignore
            //throw new Exception("info is not correct");
            ButtonX=8;
            ButtonY=8;
            Chain=8;
          }
          MidiCommand.setState(ButtonX+"x"+ButtonY);
          keyLedPad.before=new color[ButtonX][ButtonY];
          keySoundPad.before=new color[ButtonX][ButtonY];
        } else {
          throw new Exception("info is not a file : "+infof.getAbsolutePath());
        }
        I_ResetKs();
        if (keySoundf.isFile()) {//soundsf.isDirectory()
          println("load sound "+soundsf.getAbsolutePath());
          ArrayList<Analyzer.UnipackLine> lines=analyzer.loadKeySound(keySoundf.getAbsolutePath());
          int a=0;
          while (a<lines.size()) {
            Analyzer.UnipackLine line=lines.get(a);
            if (0<line.x&&line.x<=ButtonX&&0<line.y&&line.y<=ButtonY&&0<line.chain&&line.chain<=Chain) {
              File soundfile;
              if (line.absolute) {
                soundfile=new File(line.filename);
              } else {
                soundfile=new File(joinPath(soundsf.getAbsolutePath(), line.filename));
              }
              if (isSoundFile(soundfile)) {
                println("load : "+soundfile.getAbsolutePath());
                if (KS.get(line.chain-1)[line.x-1][line.y-1].loadSound(soundfile.getAbsolutePath().replace("\\", "/"))) {
                  KS.get(line.chain-1)[line.x-1][line.y-1].ksSoundLoop.set(KS.get(line.chain-1)[line.x-1][line.y-1].ksSoundLoop.size()-1, line.loop);
                }
              }
            }
            a=a+1;
          }
        } else {
          throw new Exception("keySound is not a file : "+keySoundf.getAbsolutePath());
        }
        if (keyLEDf.isDirectory()) {
          println("load led "+keyLEDf.getAbsolutePath());
          int a=0;
          File[] files=keyLEDf.listFiles();
          //already sorted by abc
          int c=-1;
          int x=-1;
          int y=-1;
          int loop=1;
          while (a<files.length) {
            String[] tokens=split(getExtensionElse(getFileName(files[a].getAbsolutePath())), " ");
            if (tokens.length>3) {
              if (isInt(tokens[0])&&isInt(tokens[1])&&isInt(tokens[2])&&isInt(tokens[3])) {
                c=int(tokens[0]);
                x=int(tokens[2]);
                y=int(tokens[1]);
                loop=int(tokens[3]);
                if (0<x&&x<=ButtonX&&0<y&&y<=ButtonY&&0<c&&c<=Chain) {
                  println("load : "+files[a].getAbsolutePath());
                  if (KS.get(c-1)[x-1][y-1].loadLed(files[a].getAbsolutePath().replace("\\", "/"))) {
                    KS.get(c-1)[x-1][y-1].ksLedLoop.set(KS.get(c-1)[x-1][y-1].ksLedLoop.size()-1, loop);
                  }
                  //set loop!//#add
                }
              }
            }
            a=a+1;
          }
        } else if (keyLEDf.isFile()) {
          println("load led(file) "+keyLEDf.getAbsolutePath());
          ArrayList<Analyzer.UnipackLine> lines=analyzer.loadKeySound(keyLEDf.getAbsolutePath());
          int a=0;
          while (a<lines.size()) {
            Analyzer.UnipackLine line=lines.get(a);
            if (0<line.x&&line.x<=ButtonX&&0<line.y&&line.y<=ButtonY&&0<line.chain&&line.chain<=Chain) {
              if (line.absolute) {
                File ledfile=new File(line.filename);
                if (ledfile.isFile()) {
                  println("load : "+ledfile.getAbsolutePath());
                  KS.get(line.chain-1)[line.x-1][line.y-1].loadLed(ledfile.getAbsolutePath().replace("\\", "/"));
                }
              }//else ignore(error)
            }
            a=a+1;
          }
        } else {
          //throw new Exception("keyLED not exists : "+keyLEDf.getAbsolutePath()); - just ignore
        }
        if (projectf.isFile()) {
          ((TextBox)UI[getUIid("I_PROJECTNAME")]).text=readFile(projectf.getAbsolutePath());
        } else {
          ((TextBox)UI[getUIid("I_PROJECTNAME")]).text=getFileName(filename);
        }
        ksX=0;
        ksY=0;
        ksChain=0;
        ((ScrollList)UI[getUIid("I_SOUNDVIEW")]).setItems(KS.get(ksChain)[ksX][ksY].ksSound.toArray(new String[0]));
        ((ScrollList)UI[getUIid("I_LEDVIEW")]).setItems(KS.get(ksChain)[ksX][ksY].ksLedFile.toArray(new String[0]));
        registerRender();
        loadKeySoundFlag=false;
      }
      catch(Exception e) {
        loadKeySoundFlag=false;
        throw e;
      }
    } else if (file.isFile()) {
      throw new Exception("ignore");
    } else {
      throw new Exception("folder not exists : "+filename);
    }
  }
  ArrayList<String> toUnipadLed(ArrayList<String> in) {
    return toUnipadLed(in.toArray(new String[0]));
  }
  ArrayList<String> toUnipadLed(String[] in) {
    ArrayList<String> ret=new ArrayList<String>();
    int c=0;
    float bpmv=120;
    boolean[][] first=new boolean[ButtonX][ButtonY];
    for (int a=0; a<ButtonX; a++) {
      for (int b=0; b<ButtonY; b++) {
        first[a][b]=true;
      }
    }
    while (c<in.length) {
      UnipackLine line=AnalyzeLine(c, "ExportLedFile", in[c]);
      if (line.Type==UnipackLine.ON) {//
        if (line.mc) {
          if (ignoreMc) {
            if (line.hasHtml&&line.hasVel) {
              ret.add("o mc "+line.x+" "+hex(line.html, 6)+" "+line.vel);
            } else if (line.hasVel) {
              ret.add("o mc "+line.x+" a "+line.vel);
            } else if (line.hasHtml) {
              ret.add("o mc "+line.x+" "+hex(line.html, 6));
            }//else ignore
          }
        } else {
          if (line.hasHtml&&line.hasVel) {
            for (int b=line.y; b<=line.y2; b++) {
              for (int a=line.x; a<=line.x2; a++) {
                ret.add("o "+b+" "+a+" "+hex(line.html, 6)+" "+line.vel);
              }
            }
          } else if (line.hasVel) {
            for (int b=line.y; b<=line.y2; b++) {
              for (int a=line.x; a<=line.x2; a++) {
                ret.add("o "+b+" "+a+" a "+line.vel);
              }
            }
          } else if (line.hasHtml) {
            for (int b=line.y; b<=line.y2; b++) {
              for (int a=line.x; a<=line.x2; a++) {
                ret.add("o "+b+" "+a+" "+hex(line.html, 6));
              }
            }
          }//else ignore
        }
        if (line.mc==false) {
          first[line.x-1][line.y-1]=false;
        }
      } else if (line.Type==UnipackLine.OFF) {//
        if (line.mc) {//[off mc n]
          if (ignoreMc)ret.add("f mc "+line.x);
        } else {//[off y x n]
          for (int b=line.y; b<=line.y2; b++) {
            for (int a=line.x; a<=line.x2; a++) {
              if (first[a-1][b-1]) {
                ret.add("o "+b+" "+a+" auto 0");
              }
              ret.add("f "+b+" "+a);
            }
          }
        }
        if (line.mc==false) {
          first[line.x-1][line.y-1]=false;
        }
      } else if (line.Type==UnipackLine.DELAY) {
        if (line.hasHtml) {//bpm
          ret.add("d "+floor((line.x*2400/(bpmv*line.y))*100));
        } else {//ms
          ret.add("d "+line.x);
        }
      } else if (line.Type==UnipackLine.BPM) {
        bpmv=line.valueF;
      } else if (ignoreMc) {
        if (line.Type==UnipackLine.CHAIN) {
          ret.add("c "+line.x);
        } else if (line.Type==UnipackLine.MAPPING) {
          if (line.hasVel)ret.add("m s "+line.y+" "+line.x+" "+line.vel);
          else ret.add("m l "+line.y+" "+line.x+" "+line.vel);
        }
      }//else ignore.
      c=c+1;
    }
    return ret;
  }
  void readKS(String path) {//set KS instance to asdf. loades sound file too.
    I_ResetKs();//erase original data - WARNING!
  }
  void writeKS(String path, boolean canonical) {//write "keySound" file and copy sounds/led. path is project path.
    //new File(joinPath(path,"sounds")).mkdirs();
    //setting canonical to true copies all sounds and led, and
    String text="";
    String ledtext="";
    int a=0;
    while (a<KS.size()) {
      int b=0;
      while (b<KS.get(a).length) {
        int c=0;
        while (c<KS.get(a)[b].length) {
          int d=0;
          while (d<KS.get(a)[b][c].ksSound.size()) {
            if (canonical) {
              text=text+"\n"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" "+getFileName(KS.get(a)[b][c].ksSound.get(d)).replace(" ", "_")+" "+KS.get(a)[b][c].ksSoundLoop.get(d);
            } else {
              text=text+"\n"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" \""+KS.get(a)[b][c].ksSound.get(d)+"\" "+KS.get(a)[b][c].ksSoundLoop.get(d);
            }
            d=d+1;
          }
          d=0;
          if (canonical) {
            while (d<KS.get(a)[b][c].ksSound.size()) {
              EX_fileCopy(KS.get(a)[b][c].ksSound.get(d), joinPath(path, "sounds/"+getFileName(KS.get(a)[b][c].ksSound.get(d)).replace(" ", "_")));
              d=d+1;
            }
            d=0;
            while (d<KS.get(a)[b][c].ksLedFile.size()) {//not just copy, clear and rename.
              try {
                writeFile(joinPath(path, "keyLED/"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" "+KS.get(a)[b][c].ksLedLoop.get(d)+" "+str(char(d+'a'))), Lines.toString(toUnipadLed(split(readFile(KS.get(a)[b][c].ksLedFile.get(d)), "\n"))));
              }
              catch(Exception e) {
                e.printStackTrace();
              }
              d=d+1;
            }
          } else {
            while (d<KS.get(a)[b][c].ksLedFile.size()) {
              ledtext=ledtext+"\n"+str(a+1)+" "+str(c+1)+" "+str(b+1)+" \""+KS.get(a)[b][c].ksLedFile.get(d)+"\" "+KS.get(a)[b][c].ksLedLoop.get(d);
              d=d+1;
            }
          }
          c=c+1;
        }
        b=b+1;
      }
      a=a+1;
    }
    UnipackInfo info=new UnipackInfo();
    info.title=((TextBox)UI[getUIid("I_TITLE")]).text;
    if (info.title.equals(""))info.title="untitled";
    info.producerName=((TextBox)UI[getUIid("I_PRODUCERNAME")]).text;
    if (info.producerName.equals(""))info.producerName="made by "+getUsername()+", made with PositionWriter.";
    info.buttonX=int(((TextBox)UI[getUIid("I_BUTTONX")]).value);
    info.buttonY=int(((TextBox)UI[getUIid("I_BUTTONY")]).value);
    info.chain=int(((TextBox)UI[getUIid("I_CHAIN")]).value);
    info.landscape=((Button)UI[getUIid("I_LANDSCAPE")]).value;
    info.squareButton=((Button)UI[getUIid("I_SQUAREBUTTONS")]).value;
    try {
      writeFile(joinPath(path, "keySound"), text);
      if (canonical==false)writeFile(joinPath(path, "keyLED"), ledtext);
      writeFile(joinPath(path, "info"), info.toString());
      if (canonical==false) {
        if (((TextBox)UI[getUIid("I_PROJECTNAME")]).text.equals("")==false) {
          writeFile(joinPath(path, ".project"), filterString(((TextBox)UI[getUIid("I_PROJECTNAME")]).text, new String[]{"\\", "/", ":", "*", "?", "\"", "<", ">", "|"}));
        } else {
          writeFile(joinPath(path, ".project"), filterString(getFileName(title_filename), new String[]{"\\", "/", ":", "*", "?", "\"", "<", ">", "|"}));
        }
      }
    }
    catch(Exception e) {
      e.printStackTrace();//failed!
    }
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
  PImage LedToImage(String text) {
    PImage image=createImage(ButtonX, ButtonY, ARGB);
    ArrayList<UnipackLine> lines=new ArrayList<UnipackLine>();
    parseLed(text, lines, new ArrayList<Integer>());
    image.loadPixels();
    for (int a=0; a<lines.size(); a++) {
      if (lines.get(a).Type==UnipackLine.ON) {
        if (lines.get(a).hasHtml)image.pixels[(lines.get(a).y-1)*image.width+lines.get(a).x-1]=lines.get(a).html;
        else image.pixels[(lines.get(a).y-1)*image.width+lines.get(a).x-1]=k[lines.get(a).vel];
      } else if (lines.get(a).Type==UnipackLine.OFF) {
        image.pixels[(lines.get(a).y-1)*image.width+lines.get(a).x-1]=OFFCOLOR;
      } else if (lines.get(a).Type==UnipackLine.DELAY) {
        break;
      }
    }
    image.updatePixels();
    return image;
  }
}