import javax.swing.filechooser.FileSystemView;
import java.nio.channels.FileChannel;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import com.karnos.commandscript.Analyzer;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
TextTransfer textTransfer;
//
//===processing utils===//
String title_prefix="PositionWriter 2.0 | ";
String title_path="";
String title_processing="";
void setTitlePath(String path) {
  title_path=path;
  surface.setTitle(title_prefix+title_path+title_processing);
}
void setTitleProcessing() {
  surface.setTitle(title_prefix+title_path);
}
void setTitleProcessing(String content) {
  title_processing=" - "+content;
  surface.setTitle(title_prefix+title_path+title_processing);
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
String createNewLed() {
  long time = System.currentTimeMillis(); 
  java.text.SimpleDateFormat dayTime = new java.text.SimpleDateFormat("yyyy_MM_dd_");
  return joinPath(path_global, joinPath(path_ledPath, dayTime.format(new java.util.Date(time))+hex((int)(time%86400000))+".led"));
}
String createNewFolder() {
  long time = System.currentTimeMillis();
  java.text.SimpleDateFormat dayTime = new java.text.SimpleDateFormat("yyyy_MM_dd_");
  return joinPath(path_global, joinPath(path_projects, dayTime.format(new java.util.Date(time))+hex((int)(time%86400000))));
}
void saveFileTo(String path, Runnable r) {
  String rename="";
  File file=new File(path);
  if (file.isFile()) {
    int count=0;
    rename=path+".tmp";
    while (!file.renameTo(new File(rename))) {
      rename=path+".tmp"+count;
      count++;
    }
  }
  r.run();
  File tempfile=new File(rename);
  if (tempfile.isFile()) {
    tempfile.delete();//you have no chance to restore it? if I get request, then implement it.
  }
  setStatusR("Saved : "+path);
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
String getCodePath() {
  if (DEVELOPER_BUILD) {
    return joinPath(new File(dataPath("")).getParentFile().getAbsolutePath(), "code");
  } else {
    return new File("code").getAbsolutePath();
  }
}
public static boolean isValidFileName(String name) {
  try {
    java.nio.file.Paths.get(name);
  }
  catch(java.nio.file.InvalidPathException e) {
    return false;
  }
  return true;
}
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory())return file.listFiles();
  return null;
}
String[] listFileNames(String dir) {
  File file=new File(dir);
  if (file.isDirectory()) {
    File[] view=file.listFiles();
    String[] ret=new String[view.length+1];
    ret[0]="/..";
    for (int a=1; a<=view.length; a++) {
      ret[a]=getFileName(view[a-1].getAbsolutePath());
    }
    return ret;
  }
  return new String[]{"/.."};
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
  FileInputStream inputStream=null;
  FileOutputStream outputStream=null;
  FileChannel fcin=null;
  FileChannel fcout=null;
  try {
    inputStream = new FileInputStream(source); 
    outputStream = new FileOutputStream(target);
    fcin = inputStream.getChannel(); 
    fcout = outputStream.getChannel();
    long size = fcin.size();
    fcin.transferTo(0, size, fcout);
  } 
  catch (Exception e) {
    displayError(e);
  } 
  if (inputStream!=null) {
    try {
      inputStream.close();
    }
    catch(Exception e) {
    }
  } 
  if (outputStream!=null) {
    try {
      outputStream.close();
    }
    catch(Exception e) {
    }
  } 
  if (fcin!=null) {
    try {
      fcin.close();
    }
    catch(Exception e) {
    }
  } 
  if (fcout!=null) {
    try {
      fcout.close();
    }
    catch(Exception e) {
    }
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
String readFile(String path) {
  setTitleProcessing("reading "+path+"...");
  BufferedReader read=createReader(path);
  StringBuilder builder = new StringBuilder();
  try {
    String line=read.readLine();
    while (line!=null) {
      builder.append("\n").append(line);
      line=read.readLine();
    }
    builder.delete(0, 1);
  }
  catch(Exception e) {
  }
  try {
    if (read!=null) {
      read.close();
    }
  }
  catch(Exception e) {
  }
  setTitleProcessing();
  return builder.toString();
}
String writeFile(String path, String text) {
  PrintWriter write=null;
  try {
    write=createWriter(path);
    setTitleProcessing("Writing... "+path);
    write.write(text);
    write.flush();
  }
  catch(Exception e) {
    displayError(e);
  }
  if (write!=null) {
    try {
      write.close();
    }
    catch(Exception e) {
    }
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
String ToUnipadLed(LedScript script) {
  StringBuilder builder=new StringBuilder();
  float bpm=120;
  boolean[][] first=new boolean[script.info.buttonX][script.info.buttonY];
  for (int a=0; a<script.info.buttonX; a++) {
    for (int b=0; b<script.info.buttonY; b++) {
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
  PImage image=createImage(script.info.buttonX, script.info.buttonY, ARGB);
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
String GifToLed(String path) {
  //#ADD
  return "";
}
void LedToGif(String path, LedScript script) {
  AnimatedGifEncoder e = new AnimatedGifEncoder();
  e.start(path);
  e.setQuality(1);
  e.setSize(script.info.buttonX, script.info.buttonY);
  //e.setDelay(1000);//#ADD set delay to lcd of every frame
  for (int a=0; a<script.getFrameCount(); a+=1) {
    e.addFrame((java.awt.image.BufferedImage)LedToPng(script, a).getNative());
  }
  e.finish();
}
String MidiToLed(String path) {
  //#ADD
  return "";
}
void LedToMidi(String path, LedScript script) {
  //#ADD
}