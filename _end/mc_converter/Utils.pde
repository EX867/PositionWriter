import java.util.*;
import java.awt.datatransfer.*;
import java.awt.Toolkit;
import java.io.*;
import java.nio.channels.FileChannel;
/**
 * <p>Checks whether the String a valid Java number.</p>
 *
 * <p>Valid numbers include hexadecimal marked with the <code>0x</code>
 * qualifier, scientific notation and numbers marked with a type
 * qualifier (e.g. 123L).</p>
 *
 * <p><code>Null</code> and empty String will return
 * <code>false</code>.</p>
 *
 * @param str  the <code>String</code> to check
 * @return <code>true</code> if the string is a correctly formatted number
 */
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
void printError(int level, int line, String name, String text) {
  if (level==1) {
    error.add("Error! (line "+line+" ,"+name+") : "+text);
    println("Error! (line "+line+" ,"+name+") : "+text);
  } else if (level==2) {
    warning.add("Warning! (line "+line+" ,"+name+") : "+text);
    println("Warning! (line "+line+" ,"+name+") : "+text);
  }
}
void printError(int level, int line, String name, String data, String text) {
  if (data.length()>=9) {
    data=data.substring(0, 6)+"...";
  }
  if (level==1) {
    error.add("Error! (line "+line+" ,"+name+") : \""+data+"\" "+text);
    println("Error! (line "+line+" ,"+name+") : \""+data+"\" "+text);
  } else if (level==2) {
    warning.add("Warning! (line "+line+" ,"+name+") : \""+data+"\" "+text);
    println("Warning! (line "+line+" ,"+name+") : \""+data+"\" "+text);
  }
}
Process process;
void ResultPopup() {//pass params to exe. error, warning,result
  try {
    String path=dataPath+"data/ListViewer/application.windows64/ListViewer.exe";
    path=path.replace("/", "\\");
    print(path+" ");
    //process=launch(path, "views=3 error="+listToString(error)+" warning="+listToString(warning)+" result="+listToString(result));
    //process=new ProcessBuilder(path, "views=3 error="+listToString(error)+" warning="+listToString(warning)+" result="+listToString(result)).start();
    process=Runtime.getRuntime().exec(path+" views=3");
  }
  catch(Exception e) {
    println(e);
  }
  println("ListViewer executed!");
}
String listToString(ArrayList<String> in) {//join with \n
  int a=1;
  int len=in.size();
  String ret="";
  if (len!=0) {
    ret=in.get(0);
    while (a<len) {
      ret=ret+"\n"+in.get(a);
      a=a+1;
    }
  }
  return ret;
}

File[] EX_listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    return file.listFiles();
  }
  return null;
}
boolean isMouseIsPressed(int x, int y, int w, int h) {
  if (mousePressed==true&&mouseButton==LEFT&&(x<mouseX)&&(mouseX<(x+w))&&(y<mouseY)&&(mouseY<(y+h))) {
    sR=true;
    return true;
  }
  return false;
}
PImage img_result;
PImage img_error;
PImage img_warning;
PImage img_back;
void loadImages() {
  img_result=loadImage("result.png");
  img_error=loadImage("error.png");
  img_warning=loadImage("warning.png");
  img_back=loadImage("back.png");
}

//===================================
//http://stackoverflow.com/questions/6376975/how-to-paste-from-system-clipboard-content-to-an-arbitrary-window-using-java
public final class TextTransfer implements ClipboardOwner {
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
//=================================
boolean isAbsolutePath(String path) {
  if (path.contains(":"))return true;
  else return false;
}
boolean EX_fileCopy(String source, String target) {//http://www.yunsobi.com/blog/406
  File sourceFile = new File( source );
  FileInputStream inputStream = null;
  FileOutputStream outputStream = null;
  FileChannel fcin = null;
  FileChannel fcout = null;
  boolean ret=true;
  try {
    inputStream = new FileInputStream(sourceFile);
    outputStream = new FileOutputStream(target);
    fcin = inputStream.getChannel();
    fcout = outputStream.getChannel();
    long size = fcin.size();
    fcin.transferTo(0, size, fcout);
  } 
  catch (Exception e) {
    e.printStackTrace();
    ret=false;
  } 
  finally {
    try {
      fcout.close();
    }
    catch(IOException ioe) {
      ret=false;
    }
    try {
      fcin.close();
    }
    catch(IOException ioe) {
      ret=false;
    }
    try {
      outputStream.close();
    }
    catch(IOException ioe) {
      ret=false;
    }
    try {
      inputStream.close();
    }
    catch(IOException ioe) {
      ret=false;
    }
  }
  return ret;
}