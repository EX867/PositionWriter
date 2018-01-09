import javax.swing.filechooser.FileSystemView;
import java.nio.channels.FileChannel;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import com.karnos.commandscript.Analyzer;
TextTransfer textTransfer;
//
//===processing utils===//
String title_prefix="PositionWriter 2.0 | ";
String title_path="";
String title_edited="";
String title_processing="";
void setTitlePath(String path) {
  title_path=path;
  surface.setTitle(title_prefix+title_path+title_edited+title_processing);
}
void setTitleProcessing() {
  setTitleProcessing("");
}
void setTitleProcessing(String content) {
  title_processing=" - "+content;
  surface.setTitle(title_prefix+title_path+title_edited+title_processing);
}
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
//
//===other===//
static boolean toBoolean (String in) {
  if (in.equals ("true"))return true;
  return false;
}
boolean isFraction(String str) {
  String[] ints=split(str, "/");
  return ints.length==2&&Analyzer.isInt(ints[0])&&Analyzer.isInt(ints[1]);
}
String filterString(String original, String[] filter) {
  for (String a : filter) {
    original=original.replace(a, "");
  }
  return original;
}
boolean isValidPackageName(String content) {
  String[] tokens=split(content, ".");
  for (String token : tokens) {
    if (token.equals("")||Analyzer.isInt(token.substring(0, 1)))return false;
    token=token.replaceAll("[a-zA-Z0-9_]", "");
    if (token.equals("")==false)return false;
  }
  return true;
}
//
//===PW saving files===//
void autoSave(String path, String text) {
  if (!title_edited.equals("*"))return;
  writeFile(getNotDuplicatedFilename(path), text);
}
//
//===Color utils===//
//color Colorblend(color a, color b) {
//  float oa=alpha(a);
//  float na=alpha(b);
//  return color(red(a)*(255-na)/255+red(b)*na/255, green(a)*(255-na)/255+green(b)*na/255, blue(a)*(255-na)/255+blue(b)*na/255, oa*(255-na)/255+na);//res.r = dst.r * (1 - src.a) + src.r * src.a
//}
//
void imageChangeColor(PImage image, int c) {
  if (image!=null) {
    image.loadPixels();
    for (int a=0; a<image.pixels.length; a++) {
      image.pixels[a]=color(red(c), green(c), blue(c), alpha(image.pixels[a]));
    }
    image.updatePixels();
  }
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
    return other.x==x&&other.y==y;
  }
  boolean equals(int x_, int y_) {
    return x_==x&&y_==y;
  }
  void set(int x_, int y_) {
    x=x_;
    y=y_;
  }
}
//===Directory utils===//
String getDocuments() {
  return FileSystemView.getFileSystemView().getDefaultDirectory().getPath();
}
String getAppData() {
  if (platform==WINDOWS) {
    return System.getenv("LOCALAPPDATA");
  } else if (platform==LINUX) {
    return System.getProperty("user.home")+"/.local/share/PositionWriter";
  } else {
    return System.getProperty("user.home")+"/PositionWriter/AppData";//do not support!!
  }
}
String getUsername() {
  return System.getProperty("user.name");
}
String getDataPath() {
  if (DEVELOPER_BUILD) {
    return dataPath("");
  } else {
    return new File("data").getAbsolutePath();
  }
}
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory())return file.listFiles();
  return null;
}
String[] listFileNames(String dir) {
  File file=new File(dir);
  dir=dir.replace('\\', '/');
  if (file.isDirectory()==false)new File(dir).mkdirs();
  if (file.isDirectory()) {
    File[] view=file.listFiles();
    String[] ret=new String[view.length];
    for (int a=0; a<ret.length; a++) {
      ret[a]=getFileName(view[a].getAbsolutePath());
    }
    return ret;
  }
  return new String[0];
}
String joinPath(String path1, String path2) {
  path1 = path1.trim();
  path1 = path1.replace('\\', '/');
  path2 = path2.trim();
  path2 = path2.replace('\\', '/');
  if (path1.equals("")) {
    if (path2.equals("")) return "";
    return path2;
  } else {
    if (path2.equals("")) return path1;
  }
  if (path2.charAt(0) == '/') path2 = path2.substring(1);
  if (path1.charAt(path1.length() - 1) == '/') path1 = path1.substring(0, path1.length() - 1);
  return path1 + "/" + path2;
}
String getFileName(String path) {
  String[] words;
  path=path.replace('\\', '/');
  words=split(path, "/");
  return words[words.length-1];
}
String changeFormat(String filename, String format) {
  return getExtensionElse(filename)+"."+format;
}
static String getFileExtension(String filename) {
  if (filename.equals(""))return "";
  String[] words;
  words=filename.split("\\.");
  if (words.length>1)return words[words.length-1];
  else return "";
}
String getExtensionElse(String filename) {
  if (filename.equals(""))return "";
  String[] words;
  words=split(filename, ".");
  String ret=words[0];
  for (int a=1; a<words.length-1; a++) {
    ret=ret+"."+words[a];
  }
  return ret;
}
String getFormat(String path) {
  try {
    java.nio.file.Path source = java.nio.file.Paths.get(path);
    if (source==null) {
      return "unknown";
    }
    String ret= java.nio.file.Files.probeContentType(source);
    if (ret==null||ret.equals("null")) {
      return "unknown";
    }
    return ret;
  }
  catch(Exception e) {
    displayError(e);
  }
  return "unknown";
}
void copyFile(String source, String target) {//http://www.yunsobi.com/blog/406
  setTitleProcessing("copying "+source+" to "+target+"...");
  new File(target).getParentFile().mkdirs();
  try (FileInputStream inputStream = new FileInputStream(source); 
  FileOutputStream outputStream = new FileOutputStream(target);
  FileChannel fcin = inputStream.getChannel(); 
  FileChannel fcout = outputStream.getChannel();
  ) {
    long size = fcin.size();
    fcin.transferTo(0, size, fcout);
  } 
  catch (Exception e) {
    displayError(e);
  } 
  setTitleProcessing();
}
boolean isSoundFile(File file) {
  String format=getFormat(file.getAbsolutePath());
  if (format.equals("audio/wav")||format.equals("audio/x-wav")||format.equals("audio/mpeg3")||format.equals("audio/x-mpeg-3")) {
    return true;
  }
  return false;
}
boolean isImageFile(File file) {//.gif, .jpg, .tga, .png
  String ext=getFileExtension(file.getName());
  if (ext.equals("gif")||ext.equals("jpg")||ext.equals("tga")||ext.equals("png"))return true;
  return false;
}
String readFile(String path) throws Exception {
  setTitleProcessing("reading "+path+"...");
  BufferedReader read=createReader(path);
  StringBuilder builder = new StringBuilder();
  String line=read.readLine();
  while (line!=null) {
    builder.append("\n").append(line);
    line=read.readLine();
  }
  builder.delete(0, 1);
  read.close();
  setTitleProcessing();
  return builder.toString();
}
String writeFile(String path, String text) {
  try (PrintWriter write=createWriter(path);
  ) {
    setTitleProcessing("writing "+path+"...");
    write.write(text);
    write.flush();
  }
  catch(Exception e) {
    displayError(e);
  }
  setTitleProcessing();
  return text;
}
String getNotDuplicatedFilename(String path) {
  if (!new File(path).exists()) {
    return path;
  } else {
    File file=new File(path);
    int a=1;
    while (file.exists()) {
      file=new File(getExtensionElse(path)+"-"+a+"."+getFileExtension(path));
      a=a+1;
    }
    return file.getAbsolutePath();
  }
}
void deleteFile(String file) {
  deleteFile(new File(file));
}
boolean deleteFile(File f) {
  if (f.isDirectory()) {
    for (File c : f.listFiles())
      deleteFile(c);
  }
  return f.delete();
}
void openFileExplorer(String path) {//#platform_specific
  if (platform==WINDOWS) {//https://stackoverflow.com/questions/15875295/open-a-folder-in-explorer-using-java
    try {
      java.awt.Desktop.getDesktop().open(new File(path));
    }
    catch(Exception e) {
      displayError(e);
    }
  } else if (platform==LINUX) {
  }
}
//===Copy and paste===//
public final class TextTransfer implements java.awt.datatransfer.ClipboardOwner {//http://stackoverflow.com/questions/6376975/how-to-paste-from-system-clipboard-content-to-an-arbitrary-window-using-java
  @Override public void lostOwnership(java.awt.datatransfer.Clipboard aClipboard, java.awt.datatransfer.Transferable aContents) {
    //do nothing
  }
  public void setClipboardContents( String aString ) {
    java.awt.datatransfer.StringSelection stringSelection = new java.awt.datatransfer.StringSelection( aString );
    java.awt.datatransfer.Clipboard clipboard = java.awt.Toolkit.getDefaultToolkit().getSystemClipboard();
    clipboard.setContents( stringSelection, this );
  }
  public String getClipboardContents() {
    String res = "";
    java.awt.datatransfer.Clipboard clipboard = java.awt.Toolkit.getDefaultToolkit().getSystemClipboard();
    //odd: the Object param of getContents is not currently used
    java.awt.datatransfer.Transferable contents = clipboard.getContents(null);
    boolean hasTransferableText = (contents != null) && contents.isDataFlavorSupported(java.awt.datatransfer.DataFlavor.stringFlavor);
    if ( hasTransferableText &&contents!=null) {
      try {
        res = (String)contents.getTransferData(java.awt.datatransfer.DataFlavor.stringFlavor);
      }
      catch (java.awt.datatransfer.UnsupportedFlavorException ex) {
        //highly unlikely since we are using a standard DataFlavor
        ex.printStackTrace();
      }
      catch (IOException ex) {
        ex.printStackTrace();
      }
    }
    return res;
  }
}
//
//===Unipad utils===//
color [] color_lp=new color[]{
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
String ToUnipadLed(LedScript script) {
  StringBuilder builder=new StringBuilder();
  float bpm=120;
  boolean[][] first=new boolean[info.buttonX][info.buttonY];
  for (int a=0; a<info.buttonX; a++) {
    for (int b=0; b<info.buttonY; b++) {
      first[a][b]=true;
    }
  }
  script.readAll();
  ArrayList<Command> commands=script.getCommands();
  for (Command cmd : commands) {
    if (cmd instanceof UnipackCommand) {
      UnipackCommand data1=(UnipackCommand)cmd;
      if (data1 instanceof OnCommand) {
        OnCommand data2=(OnCommand)data1;
        for (int b=data2.y1; b<=data2.y2; b++) {
          for (int a=data2.x1; a<=data2.x2; a++) {
            first[a-1][b-1]=false;
          }
        }
      } else if (data1 instanceof OffCommand) {
        OffCommand data2=(OffCommand)data1;
        for (int b=data2.y1; b<=data2.y2; b++) {
          for (int a=data2.x1; a<=data2.x2; a++) {
            if (first[a-1][b-1]) {
              builder.append("o "+b+" "+a+" auto 0\n");
            }
            first[a-1][b-1]=false;
          }
        }
      } else if (data1 instanceof BpmCommand) {
        bpm=((BpmCommand)data1).value;
      }
      if (data1 instanceof DelayCommand) {
        builder.append(((DelayCommand)data1).toUnipadString(bpm)).append('\n');//includes multi line
      } else if (data1 instanceof ChainCommand) {
      } else builder.append(data1.toUnipadString()).append('\n');//includes multi line
    }
  }
  return builder.toString();
}
String PngToLed(PImage image) {
  image.loadPixels();
  StringBuilder str=new StringBuilder();
  for (int a=0; a<image.pixels.length; a++) {
    str.append("on "+str(a/image.width+1)+" "+str(a%image.width+1)+" "+hex(image.pixels[a], 6)+"\n");
  }
  image=null;
  return str.toString();
}
PImage LedToPng(LedScript script, int frame) {
  PImage image=createImage(info.buttonX, info.buttonY, ARGB);
  script.readAll();
  image.loadPixels();
  ArrayList<Command> commands=script.getCommands();
  int cnt=0;
  for (Command cmd : commands) {
    if (cnt==frame) {
      if (cmd instanceof LightCommand) {
        LightCommand info=(LightCommand)cmd;
        for (int b=info.y1; b<=info.y2; b++) {
          for (int a=info.x1; a<=info.x2; a++) {
            image.pixels[(b-1)*image.width+a-1]=info.htmlc;
          }
        }
      }
    } 
    if (cmd instanceof DelayCommand) {
      if (cnt==frame) {
        break;
      }
    }
  }
  image.updatePixels();
  return image;
}
String GifToLed() {
  //#ADD
  return "";
}
void LedToGif(String path, LedScript script) {
  AnimatedGifEncoder e = new AnimatedGifEncoder();
  e.start(path);
  e.setQuality(1);
  e.setSize(info.buttonX, info.buttonY);
  //e.setDelay(1000);//#ADD set delay to lcd of every frame
  for (int a=0; a<script.getFrameLength(); a++) {
    e.addFrame((java.awt.image.BufferedImage)LedToPng(script, a).getNative());
  }
  e.finish();
}
String MidiToLed() {
  //#ADD
  return "";
}
File LedToMidi() {
  //#ADD
  return null;
}