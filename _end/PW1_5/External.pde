//================================================================================================================================
PrintWriter errorLog=createWriter("error_log.txt");

class FileExport {
  String name;
  int exportOption;
  FileExport(String name_, int exportOption_) {
    name=name_;
    exportOption=exportOption_;
  }
  FileExport(String name_) {
    name=name_;
    exportOption=0;//default, don't change
  }
}


void getPath() {//initialize save path by default, can overwrited by settings
  String[] tokens=split(sketchPath(), "\\");
  globalPath="C:/Users/"+tokens[2]+"/Documents/Karnos/PositionWriter";
  println(globalPath);
}
boolean isAbsolutePath(String path) {
  if (path.contains(":"))return true;
  else return false;
}
ArrayList<FileExport> exports=new ArrayList<FileExport>();
void EX_export() {
  if (Tab==TAB_KEYSOUND) {
    EX_singleExport();
    return;
  }
  int a=0;
  readFrame();
  int len=exports.size();
  if (exports.size()==0) {
    EX_singleExport();
    return;
  }
  if (correctSyntax==true) {
    String LogFull_threaded=display.getText();
    while (a<len) {
      PrintWriter write=createWriter(globalPath+"/export/"+exports.get(0).name);
      write.write(EX_formatLED(Convert(LogFull_threaded, exports.get(0).exportOption, 8, 8)));
      println(exports.get(0).name+" "+exports.get(0).exportOption);
      write.flush();
      write.close();
      exports.remove(0);
      a=a+1;
    }
    if (Language==LC_ENG) Log=EX_ENG_EXPORTED+" (total "+a+")";
    else Log=EX_KOR_EXPORTED+" (total "+a+")";
  } else {
    if (Language==LC_ENG) Log=EX_ENG_SYNTAXINCORRECT;
    else Log=EX_KOR_SYNTAXINCORRECT;
  }
}
void EX_singleExport() {//delete and integrate
  readFrame();
  if (correctSyntax==true) {
    println("single export");
    long time = System.currentTimeMillis(); 
    SimpleDateFormat dayTime = new SimpleDateFormat("yyyy_mm_dd_hh_mm_ss");
    String str = "keyLED/"+dayTime.format(new Date(time)); 
    if (Tab==TAB_LED&&Mode==AUTOPLAY)str="autoPlay";
    else if (Tab==TAB_KEYSOUND) str="keySound";
    else if (Tab==TAB_INFO)str="info";
    PrintWriter write=createWriter(globalPath+"/"+str);
    if (Tab==TAB_LED)write.write(EX_formatLED(display.getText()));
    else if (Tab==TAB_KEYSOUND)write.write(EX_formatKeySound(display.getText()));
    else if (Tab==TAB_INFO)write.write(EX_formatInfo(display.getText()));
    write.flush();
    write.close();
    if (Language==LC_ENG) Log=EX_ENG_EXPORTED;
    else Log=EX_KOR_EXPORTED;
  } else {
    if (Language==LC_ENG) Log=EX_ENG_NOTEXPORTED;
    else Log=EX_KOR_NOTEXPORTED;
  }
}

String EX_formatLED(String in) {//place autos
  //assert syntax is correct
  String[] lines=split(in, "\n");
  String ret="";
  int a=0;
  int len=lines.length;
  String[] tlines;
  while (a<len) {
    if (lines[a].equals("") ||lines[a].length()<=1) {
    } else if (lines[a].length()>=2 &&lines[a].substring(0, 2).equals("//")) {
    } else {
      tlines=split(lines[a], " ");
      if (tlines[0].equals("filename")||tlines[0].equals("bpm")) {
        if (tlines[0].equals("bpm")) {
          Bpm=float(tlines[1]);
        }
      } else {
        if ((tlines[0].equals("on") || tlines[0].equals("o"))&&(!((tlines[3].equals("auto")||tlines[3].equals("a"))&&tlines[3].length()!=6))) ret=ret+"\n"+tlines[0]+" "+tlines[1]+" "+tlines[2]+" auto "+tlines[3];
        else if (tlines[0].equals("delay")||tlines[0].equals("d")) {
          String[] isdivided=split(tlines[1], "/");
          if (isdivided.length==2) {
            int value=floor((int(isdivided[0])*2400/(Bpm*int(isdivided[1])))*100);
            ret=ret+"\n"+tlines[0]+" "+value;
          } else {
            ret=ret+"\n"+tlines[0]+" "+tlines[1];
          }
        } else ret=ret+"\n"+lines[a];
      }
    }
    a=a+1;
  }
  return ret;
}
String EX_formatKeySound(String in) {
  //assert syntax is correct
  String[] lines=split(in, "\n");
  String ret="";
  int a=0;
  int len=lines.length;
  String[] tokens;
  while (a<len) {
    if (lines[a].equals("") ||lines[a].length()<=1) {
    } else if (lines[a].length()>=2 &&lines[a].substring(0, 2).equals("//")) {
    } else {
      tokens=split(lines[a], "\"");
      ret=ret+"\n"+tokens[0];
      String filen=tokens[1];
      String name=getFileName(filen);
      ret=ret+name;
      if (isAbsolutePath(filen)&&filen.substring(0, keySoundPath.length()).equals(keySoundPath)==false) {
        if (keySoundPath.contains("\\"))EX_fileCopy(filen, keySoundPath+"\\"+name);
        else EX_fileCopy(filen, keySoundPath+"/"+name);
      }
      if (tokens[2].equals("")==false) ret=ret+" "+tokens[2];
    }
    a=a+1;
  }
  return ret;
}
String EX_formatInfo(String in) {
  //assert syntax is correct
  String ret="title="+info.Title+"\nproducerName="+info.Producer+"\nbuttonX="+info.ButtonX+"\nbuttonY="+info.ButtonY+"\nchain="+info.Chain+"\nsquareButton="+str(info.SquareButton)+"\nlandscape="+str(info.Landscape);
  return ret;
}
void EX_loadIni() {
  try {
    BufferedReader read=createReader("setup.ini");
    version=read.readLine();
    println(version);
    bit=int(read.readLine());
    println(str(bit));
    read.close();
    String[] tokens;
    read=createReader("shortcut.ini");
    tokens=split(read.readLine(), "=");
    ON=tokens[1].charAt(0);
    tokens=split(read.readLine(), "=");
    OFF=tokens[1].charAt(0);
    tokens=split(read.readLine(), "=");
    DELAY=tokens[1].charAt(0);
    tokens=split(read.readLine(), "=");
    AUTO=tokens[1].charAt(0);
    tokens=split(read.readLine(), "=");
    FILENAME=tokens[1].charAt(0);
    tokens=split(read.readLine(), "=");
    BPM=tokens[1].charAt(0);
    tokens=split(read.readLine(), "=");
    RECENT_NUMBER_1=tokens[1].charAt(0);
    tokens=split(read.readLine(), "=");
    RECENT_NUMBER_2=tokens[1].charAt(0);
    read.close();
    read=createReader("configure.ini");
    tokens=split(read.readLine(), "=");
    AUTOSAVE_TIME=int(tokens[1])*1000;
    read.close();
  }
  catch(Exception e) {
    errorLog.write(e.toString());
    errorLog.flush();
    Log=e.toString();
    sR=true;
  }
}

void NT_checkVersion() {
  //String lines[];// = loadStrings(versionInfo);
  try {
    String data="";
    println(data);
    if (data.equals(version)==false) {//MODIFY
      Log=NT_ENG_NEWVERSION;
      //link(downloadLink);
    } else Log=NT_ENG_LATEST;
  }
  catch(Exception e) {
    if (Language==LC_ENG) Log=NT_ENG_NOTCONNECTED;
    else Log=NT_KOR_NOTCONNECTED;
    errorLog.write(e.toString());
    errorLog.flush();
    //Log=e.toString();
    sR=true;
  }
}
void EX_autoSaveThread_time() {
  long time = System.currentTimeMillis(); 
  String text=display.getText();
  SimpleDateFormat dayTime = new SimpleDateFormat("yyyy_mm_dd_hh_mm_ss");
  String str = dayTime.format(new Date(time));
  PrintWriter write=createWriter(globalPath+"/autoSave/autoSave"+Tab+"_"+str+".txt");
  write.write(text);
  write.flush();
  write.close();
}
void EX_autoSave(String theme, String in) {
  long time = System.currentTimeMillis(); 
  SimpleDateFormat dayTime = new SimpleDateFormat("yyyy_mm_dd_hh_mm_ss");
  String str = dayTime.format(new Date(time));
  PrintWriter write=createWriter(globalPath+"/autoSave/"+theme+Tab+"_"+str+".txt");
  write.write(in);
  write.flush();
  write.close();
}
void EX_listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    View=file.listFiles();
  }
}
String getFileName(String path) {
  String[] words;
  if (path.contains("\\"))words=split(path, "\\");
  else words=split(path, "/");
  return words[words.length-1];
}
String getFormat(String path) {
  try {
    Path source = Paths.get(path);
    if (source==null) {
      Log="source path is null";
      return "error!";
    }
    String ret= Files.probeContentType(source);
    if (ret.equals("null"))return "unknown";
    else return ret;
  }
  catch(Exception e) {
    Log="getFormat() "+e.toString();
    sR=true;
  }
  return "unknown";
}
void EX_fileCopy(String source, String target) {//http://www.yunsobi.com/blog/406
  File sourceFile = new File( source );
  FileInputStream inputStream = null;
  FileOutputStream outputStream = null;
  FileChannel fcin = null;
  FileChannel fcout = null;
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
  } 
  finally {
    try {
      fcout.close();
    }
    catch(IOException ioe) {
    }
    try {
      fcin.close();
    }
    catch(IOException ioe) {
    }
    try {
      outputStream.close();
    }
    catch(IOException ioe) {
    }
    try {
      inputStream.close();
    }
    catch(IOException ioe) {
    }
  }
}