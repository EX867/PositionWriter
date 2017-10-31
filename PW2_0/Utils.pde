import java.awt.datatransfer.*;
import java.awt.Toolkit;
import java.util.*;
static boolean toBoolean (String in) {
  if (in.equals ("true"))return true;
  return false;
}
static boolean isBoolean (String in) {
  if (in.equals ("true")||in.equals("false"))return true;
  return false;
}
public static boolean isInt(String str) {
  if (str.equals("")) return false;
  if (str.length() > 9) return false;
  if (str.equals("-"))return false;
  // just int or float is needed!
  int a = 0;
  if (str.charAt(0) == int('-')) a = 1;
  while (a < str.length()) {
    if ((int('0') <= str.charAt(a) && str.charAt(a) <= int('9')) == false)return false;
    a = a + 1;
  }
  return true;
}
public boolean isRange(String str) {
  if (isInt(str))return true;
  String[] ints=split(str, "~");
  return ints.length==2&&isInt(ints[0])&&isInt(ints[1]);
}
public int getRangeFirst(String str) {
  if (isInt(str))return int(str);
  String[] ints=split(str, "~");
  return int(ints[0]);
}
public int getRangeSecond(String str) {
  if (isInt(str))return int(str);
  String[] ints=split(str, "~");
  return int(ints[1]);
}
public boolean isFraction(String str) {
  String[] ints=split(str, "/");
  return ints.length==2&&isInt(ints[0])&&isInt(ints[1]);
}
public static boolean isNumber(String str) {
  if (str.equals(""))return false;
  char[] chars = str.toCharArray();
  int sz = chars.length;
  boolean hasExp = false;
  boolean hasDecPoint = false;
  boolean allowSigns = false;
  boolean foundDigit = false;
  // deal with any possible sign up front
  int start = (chars[0] == '-') ? 1 : 0;
  if (sz > start + 1) {
    if (chars[start] == '0' && chars[start + 1] == 'x') {
      int i = start + 2;
      if (i == sz) {
        return false; // str == "0x"
      }
      // checking hex (it can't be anything else)
      for (; i < chars.length; i++) {
        if ((chars[i] < '0' || chars[i] > '9')
          && (chars[i] < 'a' || chars[i] > 'f')
          && (chars[i] < 'A' || chars[i] > 'F')) {
          return false;
        }
      }
      return true;
    }
  }
  sz--; // don't want to loop to the last char, check it afterwords
  // for type qualifiers
  int i = start;
  // loop to the next to last char or to the last char if we need another digit to
  // make a valid number (e.g. chars[0..5] = "1234E")
  while (i < sz || (i < sz + 1 && allowSigns && !foundDigit)) {
    if (chars[i] >= '0' && chars[i] <= '9') {
      foundDigit = true;
      allowSigns = false;
    } else if (chars[i] == '.') {
      if (hasDecPoint || hasExp) {
        // two decimal points or dec in exponent   
        return false;
      }
      hasDecPoint = true;
    } else if (chars[i] == 'e' || chars[i] == 'E') {
      // we've already taken care of hex.
      if (hasExp) {
        // two E's
        return false;
      }
      if (!foundDigit) {
        return false;
      }
      hasExp = true;
      allowSigns = true;
    } else if (chars[i] == '+' || chars[i] == '-') {
      if (!allowSigns) {
        return false;
      }
      allowSigns = false;
      foundDigit = false; // we need a digit after the E
    } else {
      return false;
    }
    i++;
  }
  if (i < chars.length) {
    if (chars[i] >= '0' && chars[i] <= '9') {
      // no type qualifier, OK
      return true;
    }
    if (chars[i] == 'e' || chars[i] == 'E') {
      // can't have an E at the last byte
      return false;
    }
    if (chars[i] == '.') {
      if (hasDecPoint || hasExp) {
        // two decimal points or dec in exponent
        return false;
      }
      // single trailing decimal point after non-exponent is ok
      return foundDigit;
    }
    if (!allowSigns
      && (chars[i] == 'd'
      || chars[i] == 'D'
      || chars[i] == 'f'
      || chars[i] == 'F')) {
      return foundDigit;
    }
    if (chars[i] == 'l'
      || chars[i] == 'L') {
      // not allowing L with an exponent
      return foundDigit && !hasExp;
    }
    // last character is illegal
    return false;
  }
  // allowSigns is true iff the val ends in 'E'
  // found digit it to make sure weird stuff like '.' and '1E-' doesn't pass
  return !allowSigns && foundDigit;
}
/*color Colorblend(color a, color b) {
 float oa=alpha(a);
 float na=alpha(b);
 return color(red(a)*(255-na)/255+red(b)*na/255, green(a)*(255-na)/255+green(b)*na/255, blue(a)*(255-na)/255+blue(b)*na/255, oa*(255-na)/255+na);//res.r = dst.r * (1 - src.a) + src.r * src.a
 }*/
color brighter(color a, float brighter) {
  //if (red(a)==0&&green(a)==0&&blue(a)==0)return (floor(max(0, min(255, brighter))));
  color b=HSBtoRGB((float)hue(a)/255, (float)saturation(a)/255, (float)max(0, min(255, brightness(a)+brighter))/255);
  return color(red(b), green(b), blue(b), alpha(a));
}         
public static int HSBtoRGB(float hue, float saturation, float brightness) {
  int r = 0, g = 0, b = 0;
  if (saturation == 0) {
    r = g = b = (int) (brightness * 255.0f + 0.5f);
  } else {
    float h = (hue - (float)Math.floor(hue)) * 6.0f;
    float f = h - (float)java.lang.Math.floor(h);
    float p = brightness * (1.0f - saturation);
    float q = brightness * (1.0f - saturation * f);
    float t = brightness * (1.0f - (saturation * (1.0f - f)));
    switch ((int) h) {
    case 0:
      r = (int) (brightness * 255.0f + 0.5f);
      g = (int) (t * 255.0f + 0.5f);
      b = (int) (p * 255.0f + 0.5f);
      break;
    case 1:
      r = (int) (q * 255.0f + 0.5f);
      g = (int) (brightness * 255.0f + 0.5f);
      b = (int) (p * 255.0f + 0.5f);
      break;
    case 2:
      r = (int) (p * 255.0f + 0.5f);
      g = (int) (brightness * 255.0f + 0.5f);
      b = (int) (t * 255.0f + 0.5f);
      break;
    case 3:
      r = (int) (p * 255.0f + 0.5f);
      g = (int) (q * 255.0f + 0.5f);
      b = (int) (brightness * 255.0f + 0.5f);
      break;
    case 4:
      r = (int) (t * 255.0f + 0.5f);
      g = (int) (p * 255.0f + 0.5f);
      b = (int) (brightness * 255.0f + 0.5f);
      break;
    case 5:
      r = (int) (brightness * 255.0f + 0.5f);
      g = (int) (p * 255.0f + 0.5f);
      b = (int) (q * 255.0f + 0.5f);
      break;
    }
  }
  return 0xff000000 | (r << 16) | (g << 8) | (b << 0);
}
class IntVector2 {
  int x;
  int y;
  IntVector2() {
    x=0;
    y=0;
  }
  IntVector2(int x_, int y_) {
    x=x_;
    y=y_;
  }
  boolean equals(IntVector2 other) {
    if (other.x==x&&other.y==y)return true;
    return false;
  }
  boolean equals(int x_, int y_) {
    if (x_==x&&y_==y)return true;
    return false;
  }
}
TextTransfer textTransfer;
public final class TextTransfer implements ClipboardOwner {//http://stackoverflow.com/questions/6376975/how-to-paste-from-system-clipboard-content-to-an-arbitrary-window-using-java
  @Override public void lostOwnership(Clipboard aClipboard, Transferable aContents) {
    //do nothing
  }
  public void setClipboardContents( String aString ) {
    StringSelection stringSelection = new StringSelection( aString );
    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    clipboard.setContents( stringSelection, this );
  }

  public String getClipboardContents() {
    String res = "";
    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    //odd: the Object param of getContents is not currently used
    Transferable contents = clipboard.getContents(null);
    boolean hasTransferableText = (contents != null) && contents.isDataFlavorSupported(DataFlavor.stringFlavor);
    if ( hasTransferableText ) {
      try {
        res = (String)contents.getTransferData(DataFlavor.stringFlavor);
      }
      catch (UnsupportedFlavorException ex) {
        //highly unlikely since we are using a standard DataFlavor
        System.out.println(ex);
        ex.printStackTrace();
      }
      catch (IOException ex) {
        System.out.println(ex);
        ex.printStackTrace();
      }
    }
    return res;
  }
}
//================================================================================================================================
int inverseK(color c) {
  return kData.get(c);
}
HashMap<Integer, Integer> kData=new HashMap<Integer, Integer>(100);
void setInverseK() {
  for (int a=0; a<k.length; a++) {
    kData.put(k[a], a);
  }
}
color [] k=new color[]{
  #00000000, 
  #ffbdbdbd, 
  #ffeeeeee, 
  #fffafafa, //3
  #fff8bbd0, 
  #ffef5350, //5
  #ffe57373, 
  #ffef9a9a, 

  #fffff3e0, 
  #ffffa726, 
  #ffffb960, //10
  #ffffcc80, 
  #ffffe0b2, 
  #ffffee58, 
  #fffff59d, 
  #fffff9c4, 

  #ffdcedc8, 
  #ff8bc34a, //17
  #ffaed581, 
  #ffbfdf9f, 
  #ff5ee2b0, 
  #ff00ce3c, 
  #ff00ba43, 
  #ff119c3f, 

  #ff57ecc1, 
  #ff00e864, 
  #ff00e05c, 
  #ff00d545, 
  #ff7afddd, 
  #ff00e4c5, 
  #ff00e0b2, 
  #ff01eec6, 

  #ff49efef, 
  #ff00e7d8, 
  #ff00e5d1, 
  #ff01efde, 
  #ff6addff, 
  #ff00dafe, 
  #ff01d6ff, 
  #ff08acdc, 

  #ff73cefe, 
  #ff0d9bf7, 
  #ff148de4, 
  #ff2a77c9, 
  #ff8693ff, 
  #ff2196f3, //45
  #ff4668f6, 
  #ff4153dc, 

  #ffb095ff, 
  #ff8453fd, 
  #ff634acd, 
  #ff5749c5, 
  #ffffb7ff, 
  #ffe863fb, 
  #ffd655ed, 
  #ffd14fe9, 

  #fffc99e3, 
  #ffe736c2, 
  #ffe52fbe, 
  #ffe334b6, 
  #ffed353e, 
  #ffffa726, //61
  #fff4df0b, 
  #ff66bb6a, 

  #ff5cd100, //64
  #ff00d29e, 
  #ff2388ff, 
  #ff3669fd, 
  #ff00b4d0, 
  #ff475cdc, 
  #ffb2bbcd, 
  #ff95a0b2, 

  #fff72737, 
  #ffd2ea7b, 
  #ffc8df10, 
  #ff7fe422, 
  #ff00c931, 
  #ff00d7a6, 
  #ff00d8fc, 
  #ff0b9bfc, 

  #ff585cf5, 
  #ffac59f0, 
  #ffd980dc, 
  #ffb8814a, 
  #ffff9800, 
  #ffabdf22, 
  #ff9ee154, 
  #ff66bb6a, //87

  #ff3bda47, 
  #ff6fdeb9, 
  #ff27dbda, 
  #ff9cc8fd, 
  #ff79b8f7, 
  #ffafafef, 
  #ffd580eb, 
  #fff74fca, 

  #ffea8a1f, 
  #ffdbdb08, 
  #ff9cd60d, 
  #fff3d335, 
  #ffc8af41, 
  #ff00ca69, 
  #ff24d2b0, 
  #ff757ebe, 

  #ff5388db, 
  #ffe5c5a6, 
  #ffe93b3b, 
  #fff9a2a1, 
  #ffed9c65, 
  #ffe1ca72, 
  #ffb8da78, 
  #ff98d52c, 

  #ff626cbd, 
  #ffcac8a0, 
  #ff90d4c2, 
  #ffceddfe, 
  #ffbeccf7, 
  #ffa3b1be, 
  #ffb8c0d2, 
  #ffd2e2f8, 

  #fffe1624, 
  #ffcd2724, 
  #ff9ccc65, //122
  #ff009c1b, 
  #ffffff00, //124
  #ffbeb212, 
  #fff5d01d, //126
  #ffe37829, 
};
void drawIndicator(float x, float y, float w, float h, int thick) {
  noFill();
  stroke(255);
  strokeWeight(thick*2);
  rect(x, y, w, h);
  stroke(0);
  strokeWeight(2);
  rect(x, y, w+thick, h+thick);
  rect(x, y, w-thick, h-thick);
  noStroke();
}

void drawVel (float x, float y, float w, float h) {
  int a=0;
  textSize(15);
  textAlign(LEFT, CENTER);
  while (a <128) {
    fill (color (k [a]));
    rect(x+((a%8)*(w/8))+(w/16), y+(round (a/8)*(h/16))+(h/32), (w/16), (h/32));
    fill(0);
    text (str (a), x+((a%8)*(w/8))+2, y+(round (a/8)*(h/16))+w/32);
    a=a+1;
  }
  textAlign(CENTER, CENTER);
}
void writeDisplay(String text) {
  writeDisplay(text, false);
}
synchronized void writeDisplay(String text, boolean async) {
  int line=Lines.lines()-1;
  if (InFrameInput) {
    if (currentLedFrame!=DelayPoint.size()-1)line=DelayPoint.get(currentLedFrame+1)-1;
    if (line==-1) {
      line=0;
    }
  }
  ((TextEditor)UI[textfieldId]).insert(Lines.getLine(line).length(), line, text);
  RecordLog();
  if (UI[textfieldId].disabled==false) {
    if (async)UI[textfieldId].registerRender=true;
    else UI[textfieldId].render();
  }
}
void writeDisplayLine(String text) {
  writeDisplayLine(text, false);
}
void writeDisplayLine(String text, boolean async) {
  int line=Lines.lines();
  if (InFrameInput) {
    if (currentLedFrame!=DelayPoint.size()-1)line=DelayPoint.get(currentLedFrame+1);
  }
  ((TextEditor)UI[textfieldId]).addLine(line, text);
  RecordLog();
  if (UI[textfieldId].disabled==false) {
    if (async)UI[textfieldId].registerRender=true;
    else UI[textfieldId].render();
  }
}
void UndoLog() {
  Lines.undo();
  if (UI[textfieldId].disabled==false)UI[textfieldId].render();
}
void RedoLog() {//Lines!
  Lines.redo();
  if (UI[textfieldId].disabled==false)UI[textfieldId].render();
}

//===================================================================
String filterString(String original, String[] filter) {
  for (String a : filter) {
    original=original.replace(a, "");
  }
  return original;
}
boolean isValidPackageName(String content) {
  String[] tokens=split(content, ".");
  for (String token : tokens) {
    if (token.equals("")||isInt(token.substring(0, 1)))return false;
    token=token.replaceAll("[a-zA-Z0-9_]", "");
    if (token.equals("")==false)return false;
  }
  return true;
}
//
void displayLogError(String content) {
  Logger logger=(Logger)UI[getUIidRev("ERROR_LOG")];
  logger.logs.add("");
  logger.logs.add(content);
  registerPrepare(getFrameid("F_ERROR"));
}
void displayLogError(Exception e) {
  if (e.toString().contains("ignore")) {
    printLog("displayLogError()", "error ignored ("+e.toString()+")");
    return;
  }
  Logger logger=(Logger)UI[getUIidRev("ERROR_LOG")];
  logger.logs.add("");
  for (java.lang.StackTraceElement ee : e.getStackTrace()) {
    String str=ee.toString();
    logger.logs.add(str);
  }
  logger.logs.add("Error! Load Failed!");
  logger.logs.add(e.toString());
  e.printStackTrace();
  registerPrepare(getFrameid("F_ERROR"));
}
//
boolean statusLchanged=false;
boolean statusRchanged=false;
int displayingError=-1;
void setStatusL(String text) {
  if (statusL.text.equals(text)==false)statusLchanged=true;
  statusL.text=text;
}
void setStatusR(String text) {
  statusR.text=text;
  statusRchanged=true;
}