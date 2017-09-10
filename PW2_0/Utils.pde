import java.awt.datatransfer.*;
import java.awt.Toolkit;
import java.util.*;
boolean toBoolean (String in) {
  if (in.equals ("true"))return true;
  return false;
}
boolean isBoolean (String in) {
  if (in.equals ("true")||in.equals("false"))return true;
  return false;
}
public boolean isInt(String str) {
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
boolean isHex(String in) {
  if (in.length() != 6) return false;
  String aaa = in;
  aaa = aaa.replace('a', '0');
  aaa = aaa.replace('b', '0');
  aaa = aaa.replace('c', '0');
  aaa = aaa.replace('d', '0');
  aaa = aaa.replace('e', '0');
  aaa = aaa.replace('f', '0');
  aaa = aaa.replace('A', '0');
  aaa = aaa.replace('B', '0');
  aaa = aaa.replace('C', '0');
  aaa = aaa.replace('D', '0');
  aaa = aaa.replace('E', '0');
  aaa = aaa.replace('F', '0');
  aaa = aaa.trim();
  if (isInt(aaa) == false) return false;
  if (16777216 <= unhex(in) || unhex(in) < 0) return false;
  return true;
}
/*color Colorblend(color a, color b) {
 float oa=alpha(a);
 float na=alpha(b);
 return color(red(a)*(255-na)/255+red(b)*na/255, green(a)*(255-na)/255+green(b)*na/255, blue(a)*(255-na)/255+blue(b)*na/255, oa*(255-na)/255+na);//res.r = dst.r * (1 - src.a) + src.r * src.a
 }*/
color brighter(color a, float brighter) {
  //if (red(a)==0&&green(a)==0&&blue(a)==0)return (floor(max(0, min(255, brighter))));
  return HSBtoRGB((float)hue(a)/255, (float)saturation(a)/255, (float)max(0, min(255, brightness(a)+brighter))/255);
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
color [] k=new color[]{
  #000000, 
  #bdbdbd, 
  #eeeeee, 
  #fafafa, //3
  #f8bbd0, 
  #ef5350, //5
  #e57373, 
  #ef9a9a, 

  #fff3e0, 
  #ffa726, 
  #ffb960, //10
  #ffcc80, 
  #ffe0b2, 
  #ffee58, 
  #fff59d, 
  #fff9c4, 

  #dcedc8, 
  #8bc34a, //17
  #aed581, 
  #bfdf9f, 
  #5ee2b0, 
  #00ce3c, 
  #00ba43, 
  #119c3f, 

  #57ecc1, 
  #00e864, 
  #00e05c, 
  #00d545, 
  #7afddd, 
  #00e4c5, 
  #00e0b2, 
  #01eec6, 

  #49efef, 
  #00e7d8, 
  #00e5d1, 
  #01efde, 
  #6addff, 
  #00dafe, 
  #01d6ff, 
  #08acdc, 

  #73cefe, 
  #0d9bf7, 
  #148de4, 
  #2a77c9, 
  #8693ff, 
  #2196f3, //45
  #4668f6, 
  #4153dc, 

  #b095ff, 
  #8453fd, 
  #634acd, 
  #5749c5, 
  #ffb7ff, 
  #e863fb, 
  #d655ed, 
  #d14fe9, 

  #fc99e3, 
  #e736c2, 
  #e52fbe, 
  #e334b6, 
  #ed353e, 
  #ffa726, //61
  #f4df0b, 
  #66bb6a, 

  #5cd100, //64
  #00d29e, 
  #2388ff, 
  #3669fd, 
  #00b4d0, 
  #475cdc, 
  #b2bbcd, 
  #95a0b2, 

  #f72737, 
  #d2ea7b, 
  #c8df10, 
  #7fe422, 
  #00c931, 
  #00d7a6, 
  #00d8fc, 
  #0b9bfc, 

  #585cf5, 
  #ac59f0, 
  #d980dc, 
  #b8814a, 
  #ff9800, 
  #abdf22, 
  #9ee154, 
  #66bb6a, //87

  #3bda47, 
  #6fdeb9, 
  #27dbda, 
  #9cc8fd, 
  #79b8f7, 
  #afafef, 
  #d580eb, 
  #f74fca, 

  #ea8a1f, 
  #dbdb08, 
  #9cd60d, 
  #f3d335, 
  #c8af41, 
  #00ca69, 
  #24d2b0, 
  #757ebe, 

  #5388db, 
  #e5c5a6, 
  #e93b3b, 
  #f9a2a1, 
  #ed9c65, 
  #e1ca72, 
  #b8da78, 
  #98d52c, 

  #626cbd, 
  #cac8a0, 
  #90d4c2, 
  #ceddfe, 
  #beccf7, 
  #a3b1be, 
  #b8c0d2, 
  #d2e2f8, 

  #fe1624, 
  #cd2724, 
  #9ccc65, //122
  #009c1b, 
  #ffff00, //124
  #beb212, 
  #f5d01d, //126
  #e37829, 
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
// ========== LOG ========== //
void addLog(Difference in) {
  if (in.before!=null&&in.before.equals(in.after)==false)BeforeLog.add(in);
  else if (in.after!=null&&in.after.equals(in.before)==false)BeforeLog.add(in);
}
class Difference {
  int index=0;
  int line;
  String before;
  String after;
  int cursorLine;
  int cursorPoint;
  Difference(int line_, String before_, String after_) {
    line=line_;
    before=before_;
    after=after_;
    cursorLine=Lines.line;//for text editor
    cursorPoint=Lines.cursor;
  }
  Difference setIndex(int index_) {
    index=index_;
    return this;
  }
  String toString() {
    return index+" "+line+" / "+before+" / "+after;
  }
}
static final int LOGHISTORY_SIZE=5000;//just AfterLog size.
int log_nextIndex=0;//
ArrayList<Difference> BeforeLog=new ArrayList<Difference>();
ArrayList<Difference> AfterLog=new ArrayList<Difference>();//real log.
ArrayList<Difference> RedoStack=new ArrayList<Difference>();
void RecordLog() {
  ShiftLog();
}
void ShiftLog() {//just add data to last.
  RedoStack.clear();//clears stack on input.
  if (BeforeLog.size()==0)return;
  int a=0;
  int index;
  if (AfterLog.size()==0)index=0;
  else index=AfterLog.get(AfterLog.size()-1).index;
  index++;
  while (a<BeforeLog.size()) {
    AfterLog.add(BeforeLog.get(a).setIndex(index));
    if (AfterLog.size()>LOGHISTORY_SIZE) {
      AfterLog.remove(0);
    }
    a=a+1;
  }
  BeforeLog.clear();
}
void UndoLog() {//Lines!
  if (BeforeLog.size()!=0)ShiftLog();
  if (AfterLog.size()<=2)return;
  int index=AfterLog.get(AfterLog.size()-1).index;
  //println(index);
  int a=AfterLog.size()-1;
  while (a>0&&AfterLog.get(AfterLog.size()-1).index==index) {
    if (AfterLog.get(a).before==null) {//found index
      Lines.deleteLineWithoutRecord(AfterLog.get(a).line);
    } else if (AfterLog.get(a).after==null) {
      Lines.addLineWithoutRecord(AfterLog.get(a).line, AfterLog.get(a).before);
    } else {
      Lines.setLineWithoutRecord(AfterLog.get(a).line, AfterLog.get(a).before);
    }
    Lines.line=AfterLog.get(a-1).cursorLine;
    Lines.cursor=AfterLog.get(a-1).cursorPoint;
    RedoStack.add(AfterLog.get(a));
    AfterLog.remove(a);
    a=AfterLog.size()-1;
  }
  if (UI[textfieldId].disabled==false)UI[textfieldId].render();
}
void RedoLog() {//Lines!
  if (RedoStack.size()==0)return;
  int a=RedoStack.size()-1;
  int index=RedoStack.get(a).index;
  //println(index);
  while (a>=0&&RedoStack.get(RedoStack.size()-1).index==index) {
    if (RedoStack.get(a).before==null) {
      Lines.addLineWithoutRecord(RedoStack.get(a).line, RedoStack.get(a).after);
    } else if (RedoStack.get(a).after==null) {
      Lines.deleteLineWithoutRecord(RedoStack.get(a).line);
    } else {
      Lines.setLineWithoutRecord(RedoStack.get(a).line, RedoStack.get(a).after);
    }
    Lines.line=RedoStack.get(a).cursorLine;
    Lines.cursor=RedoStack.get(a).cursorPoint;
    AfterLog.add(RedoStack.get(a));
    RedoStack.remove(a);
    a=RedoStack.size()-1;
  }
  if (UI[textfieldId].disabled==false)UI[textfieldId].render();
}

//===================================================================
String filterString(String original, String[] filter) {
  for (String a : filter) {
    original=original.replace(a, "");
  }
  return original;
}