import javax.swing.filechooser.FileSystemView;
import java.nio.channels.FileChannel;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import com.karnos.commandscript.Analyzer;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import javax.sound.midi.*;
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
public String addLinebreaks(String input, int maxLineLength) {//https://stackoverflow.com/questions/7528045/large-string-split-into-lines-with-maximum-length-in-java
  java.util.StringTokenizer tok = new java.util.StringTokenizer(input, " ");
  StringBuilder output = new StringBuilder(input.length());
  int lineLen = 0;
  while (tok.hasMoreTokens()) {
    String word = tok.nextToken();
    if (lineLen + word.length() > maxLineLength) {
      output.append("\n");
      lineLen = 0;
    } else {
      output.append(" ");
    }
    output.append(word);
    lineLen += word.length();
  }
  return output.toString();
}
//
//===PW saving files===//
String createNewLed() {
  long time = System.currentTimeMillis(); 
  java.text.SimpleDateFormat dayTime = new java.text.SimpleDateFormat("yyyy_MM_dd_");
  return joinPath(path_global, joinPath(path_led, dayTime.format(new java.util.Date(time))+hex((int)(time%86400000))+".led"));
}
String createNewKs() {
  long time = System.currentTimeMillis();
  java.text.SimpleDateFormat dayTime = new java.text.SimpleDateFormat("yyyy_MM_dd_");
  return joinPath(path_global, joinPath(path_projects, dayTime.format(new java.util.Date(time))+hex((int)(time%86400000))));
}
String createNewMacro() {
  long time = System.currentTimeMillis(); 
  java.text.SimpleDateFormat dayTime = new java.text.SimpleDateFormat("yyyy_MM_dd_");
  String macroName=dayTime.format(new java.util.Date(time))+hex((int)(time%86400000));
  return joinPath(path_global, joinPath(path_macro, macroName+"/"+macroName+".pwm"));
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
String getClassPath() {
  //System.getProperty("java.class.path");//this will give you real file names...
  if (DEVELOPER_BUILD) {
    ClassLoader loader = this.getClass().getClassLoader();
    return new File(loader.getResource(getClass().getTypeName()+".class").getFile()).getParentFile().getAbsolutePath();//only works in processing.
  } else {
    return new File(getClass().getResource("").getFile()).getAbsolutePath();
  }
}
String[] getClassPaths() {
  String[] ss=split(System.getProperty("java.class.path"), ";");
  ArrayList<String> list=new ArrayList<String>();
  for (String s : ss) {
    if (new File(s).exists()) {
      list.add(s);
    }
  }
  list.add(System.getProperty("java.home")+"/lib/rt.jar");
  return list.toArray(new String[]{});
}
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
boolean isLedFile(File file) {//.led
  String ext=getFileExtension(file.getName());
  if (ext.equals("led")||ext.equals("mid"))return true;
  if (isImageFile(file))return true;
  return false;
}
boolean isMacroFile(File file) {//.led
  String ext=getFileExtension(file.getName());
  if (ext.equals("pwm"))return true;
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
String ToUnipadLedOptimize(LedScript script) {
  StringBuilder builder=new StringBuilder();
  TreeMap<Integer, Integer> htmlToVel=new TreeMap<Integer, Integer>();
  for (int a=0; a<color_lp.length; a++) {
    htmlToVel.put(color_lp[a], a);
  }
  for (int c=0; c<script.LED.size(); c++) {
    if (c!=0) {//test indifferernce
      for (int b=0; b<script.info.buttonY; b++) {
        for (int a=0; a<script.info.buttonX; a++) {
          if (script.LED.get(c)[a][b]!=script.LED.get(c-1)[a][b]) {
            if (script.LED.get(c)[a][b]==COLOR_RND) {
              continue;
            }
            Integer vel=htmlToVel.get(script.LED.get(c)[a][b]);
            if (script.LED.get(c)[a][b]==COLOR_OFF||(vel!=null&&((int)vel)==0)) {
              builder.append("f "+(b+1)+" "+(a+1)).append('\n');
            } else if (vel==null) {
              builder.append("o "+(b+1)+" "+(a+1)+" "+hex(script.LED.get(c)[a][b], 6).toUpperCase()).append('\n');
            } else {                
              builder.append("o "+(b+1)+" "+(a+1)+" a "+vel).append('\n');
            }
          }
        }
      }
    } else {
      for (int b=0; b<script.info.buttonY; b++) {
        for (int a=0; a<script.info.buttonX; a++) {
          if (script.LED.get(c)[a][b]==COLOR_RND) {
            continue;
          }
          if (script.LED.get(c)[a][b]!=COLOR_OFF) {
            Integer vel=htmlToVel.get(script.LED.get(c)[a][b]);
            if (vel==null) {
              builder.append("o "+(b+1)+" "+(a+1)+" "+hex(script.LED.get(c)[a][b], 6).toUpperCase()).append('\n');
            } else if (((int)vel)!=0) {
              builder.append("o "+(b+1)+" "+(a+1)+" a "+vel).append('\n');
            }
          }
        }
      }
    }
    if (c!=script.LED.size()-1) {
      builder.append("d "+script.getDelayValue(script.DelayPoint.get(c+1))).append('\n');//includes multi line
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
class TimeMidiMessage implements Comparable<TimeMidiMessage> {
  MidiMessage msg=null;
  long time;
  TimeMidiMessage(MidiMessage msg_, long time_) {
    msg=msg_;
    time=time_;
  }
  @Override public int compareTo(TimeMidiMessage other) {
    int ret=(int)(time-other.time);
    if (ret==0) {
      return 1;
    }
    return ret;
  }
}
String MidiToLed(String path) {//default changed to 10x10...
  //String ret="//"+getFileName(path);
  Sequence sequence=null;
  try {
    sequence= MidiSystem.getSequence(new File(path));
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  if (sequence==null) {
    return "";
  }
  Track[] tracks=sequence.getTracks();
  TreeSet<TimeMidiMessage> set=new TreeSet<TimeMidiMessage>();
  for (int t=0; t<tracks.length; t++) {
    for (int i=0; i < tracks[t].size(); i++) {//order messages
      MidiEvent event = tracks[t].get(i);
      set.add(new TimeMidiMessage(event.getMessage(), event.getTick()));
    }
  }
  ArrayList<Command> cmds=new ArrayList<Command>();
  cmds.ensureCapacity(set.size());
  int bpm=120;
  int ppq=sequence.getResolution();
  while (!set.isEmpty()) {
    TimeMidiMessage m=set.pollFirst();
    if (m.msg instanceof ShortMessage) {
      ShortMessage msg=(ShortMessage)m.msg;//no note on with velocity 0 in here...
      int x=lpProMidiToLedPosX(msg.getData1());
      int y=lpProMidiToLedPosY(msg.getData1());
      if (msg.getCommand()==ShortMessage.NOTE_ON) {
        cmds.add(new OnCommand(x, x, y, y, color_lp[msg.getData2()], msg.getData2()));
      } else if (msg.getCommand()==ShortMessage.NOTE_OFF) {
        cmds.add(new OffCommand(x, x, y, y));
      }
    } else if (m.msg instanceof MetaMessage) {
      MetaMessage message=(MetaMessage)m.msg;
      if (message.getType()==0x58) {//Time Signature
        //int numerator=message.getData()[0], denominator=round(pow(2, message.getData()[1])), ticksPerClick=message.getData()[2], notes32PerQuarter=message.getData()[3];
        //println("Time Signature : "+numerator+"/"+denominator+" "+ticksPerClick+"-"+notes32PerQuarter);
      } else if (message.getType()==0x51) {
        bpm=getTempo(message);
        println("bpm : "+bpm);
        cmds.add(new BpmCommand(bpm));
      }
    }
    if (!set.isEmpty()) {
      if (set.first().time>m.time) {
        double val=(set.first().time-m.time)*60000/(ppq*bpm);//milliseconds
        //println(val);
        IntVector2 fr=toFraction((double)(set.first().time-m.time)/(4*ppq), 1024);
        //println((double)(set.first().time-m.time)/(4*ppq)+" "+set.first().time+" "+m.time);
        cmds.add(new DelayCommand(abs(fr.x), abs(fr.y)));
      }
    }
  }
  StringBuilder builder=new StringBuilder();
  builder.append(cmds.get(0).toString());
  for (int a=0; a < cmds.size(); a++) {
    builder.append("\n").append(cmds.get(a).toString());
  }
  return builder.toString();
}
void LedToMidi(String path, LedScript script) {
  //#ADD
}
int lpMidiToLedPosX(int dat1) {
  return dat1%10+1;
}
int lpMidiToLedPosY(int dat1) {
  return 9-dat1/10+1;
}
int lpProMidiToLedPosX(int dat1) {
  if (dat1>=36&&dat1<=99) {
    if (dat1<68) {
      return (dat1-4)%4+2;
    } else {
      return 6+(dat1-4)%4;
    }
  }
  if (100<=dat1&&dat1<=107) {//right top->down
    return 10;
  } else if (107<=dat1&&dat1<=115) {//left top->down
    return 1;
  } else if (116<=dat1&&dat1<=123) {//bottom left->right
    return dat1-114;
  } else if (28<=dat1&&dat1<=35) {//top right-left
    return dat1-26;
  }
  return 0;
}
int lpProMidiToLedPosY(int dat1) {
  if (dat1>=36&&dat1<=99) {
    return 9-((dat1-36)/4)%8;
  }
  if (100<=dat1&&dat1<=107) {
    return dat1-98;
  } else if (108<=dat1&&dat1<=115) {
    return dat1-106;
  } else if (116<=dat1&&dat1<=123) {
    return 10;
  } else if (28<=dat1&&dat1<=35) {
    return 1;
  }
  return 0;
}
public static IntVector2 toFraction(double d, int factor) {//https://stackoverflow.com/questions/5968636/converting-a-float-into-a-string-fraction-representation
  StringBuilder sb = new StringBuilder();
  if (d < 0) {
    sb.append('-');
    d = -d;
  }
  long l = (long) d;
  d -= l;
  double error = Math.abs(d);
  int bestDenominator = 1;
  for (int i=2; i<=factor; i++) {
    double error2 = Math.abs(d - (double) Math.round(d * i) / i);
    if (error2 < error) {
      error = error2;
      bestDenominator = i;
    }
  }
  IntVector2 ret=new IntVector2((int)(l+Math.round(d * bestDenominator)), bestDenominator);
  //if(ret.x==0&&d>0){//for near-0 value...
  //  return new IntVector2(1,factor);
  //}
  return ret;
}
int getTempo(MetaMessage event) {
  byte[] message = event.getData();
  int mask = 0xFF;
  int bvalue = (message[0] & mask);
  bvalue = (bvalue << 8) + (message[1] & mask);
  bvalue = (bvalue << 8) + (message[2] & mask);
  return 60000000 / bvalue;
}