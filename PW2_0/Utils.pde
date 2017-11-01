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
  0x00000000, 
  0xffbdbdbd, 
  0xffeeeeee, 
  0xfffafafa, //3
  0xfff8bbd0, 
  0xffef5350, //5
  0xffe57373, 
  0xffef9a9a, 

  0xfffff3e0, 
  0xffffa726, 
  0xffffb960, //10
  0xffffcc80, 
  0xffffe0b2, 
  0xffffee58, 
  0xfffff59d, 
  0xfffff9c4, 

  0xffdcedc8, 
  0xff8bc34a, //17
  0xffaed581, 
  0xffbfdf9f, 
  0xff5ee2b0, 
  0xff00ce3c, 
  0xff00ba43, 
  0xff119c3f, 

  0xff57ecc1, 
  0xff00e864, 
  0xff00e05c, 
  0xff00d545, 
  0xff7afddd, 
  0xff00e4c5, 
  0xff00e0b2, 
  0xff01eec6, 

  0xff49efef, 
  0xff00e7d8, 
  0xff00e5d1, 
  0xff01efde, 
  0xff6addff, 
  0xff00dafe, 
  0xff01d6ff, 
  0xff08acdc, 

  0xff73cefe, 
  0xff0d9bf7, 
  0xff148de4, 
  0xff2a77c9, 
  0xff8693ff, 
  0xff2196f3, //45
  0xff4668f6, 
  0xff4153dc, 

  0xffb095ff, 
  0xff8453fd, 
  0xff634acd, 
  0xff5749c5, 
  0xffffb7ff, 
  0xffe863fb, 
  0xffd655ed, 
  0xffd14fe9, 

  0xfffc99e3, 
  0xffe736c2, 
  0xffe52fbe, 
  0xffe334b6, 
  0xffed353e, 
  0xffffa726, //61
  0xfff4df0b, 
  0xff66bb6a, 

  0xff5cd100, //64
  0xff00d29e, 
  0xff2388ff, 
  0xff3669fd, 
  0xff00b4d0, 
  0xff475cdc, 
  0xffb2bbcd, 
  0xff95a0b2, 

  0xfff72737, 
  0xffd2ea7b, 
  0xffc8df10, 
  0xff7fe422, 
  0xff00c931, 
  0xff00d7a6, 
  0xff00d8fc, 
  0xff0b9bfc, 

  0xff585cf5, 
  0xffac59f0, 
  0xffd980dc, 
  0xffb8814a, 
  0xffff9800, 
  0xffabdf22, 
  0xff9ee154, 
  0xff66bb6a, //87

  0xff3bda47, 
  0xff6fdeb9, 
  0xff27dbda, 
  0xff9cc8fd, 
  0xff79b8f7, 
  0xffafafef, 
  0xffd580eb, 
  0xfff74fca, 

  0xffea8a1f, 
  0xffdbdb08, 
  0xff9cd60d, 
  0xfff3d335, 
  0xffc8af41, 
  0xff00ca69, 
  0xff24d2b0, 
  0xff757ebe, 

  0xff5388db, 
  0xffe5c5a6, 
  0xffe93b3b, 
  0xfff9a2a1, 
  0xffed9c65, 
  0xffe1ca72, 
  0xffb8da78, 
  0xff98d52c, 

  0xff626cbd, 
  0xffcac8a0, 
  0xff90d4c2, 
  0xffceddfe, 
  0xffbeccf7, 
  0xffa3b1be, 
  0xffb8c0d2, 
  0xffd2e2f8, 

  0xfffe1624, 
  0xffcd2724, 
  0xff9ccc65, //122
  0xff009c1b, 
  0xffffff00, //124
  0xffbeb212, 
  0xfff5d01d, //126
  0xffe37829, 
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
    if (keyled_textEditor.current.processer.displayFrame!=DelayPoint.size()-1)line=DelayPoint.get(keyled_textEditor.current.processer.displayFrame+1)-1;
    if (line==-1) {
      line=0;
    }
  }
  keyled_textEditor.insert(Lines.getLine(line).length(), line, text);
  RecordLog();
  if (keyled_textEditor.disabled==false) {
    if (async)keyled_textEditor.registerRender=true;
    else keyled_textEditor.render();
  }
}
void writeDisplayLine(String text) {
  writeDisplayLine(text, false);
}
void writeDisplayLine(String text, boolean async) {
  int line=Lines.lines();
  if (InFrameInput) {
    if (keyled_textEditor.current.processer.displayFrame!=DelayPoint.size()-1)line=DelayPoint.get(keyled_textEditor.current.processer.displayFrame+1);
  }
  keyled_textEditor.addLine(line, text);
  RecordLog();
  if (keyled_textEditor.disabled==false) {
    if (async)keyled_textEditor.registerRender=true;
    else keyled_textEditor.render();
  }
}
void UndoLog() {
  Lines.undo();
  if (keyled_textEditor.disabled==false)keyled_textEditor.render();
}
void RedoLog() {//Lines!
  Lines.redo();
  if (keyled_textEditor.disabled==false)keyled_textEditor.render();
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
LineError displayingError=null;
void setStatusL(String text) {
  if (statusL.text.equals(text)==false)statusLchanged=true;
  statusL.text=text;
}
void setStatusR(String text) {
  statusR.text=text;
  statusRchanged=true;
}