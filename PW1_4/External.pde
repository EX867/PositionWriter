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
ArrayList<FileExport> exports=new ArrayList<FileExport>();
void EX_export() {
  int a=0;
  int len=exports.size();
  readFrame();
  if (exports.size()==0)EX_singleExport();
  else {
    if (correctSyntax==true) {
      String LogFull_threaded=display.getText();
      while (a<len) {
        PrintWriter write=createWriter("export/"+exports.get(0).name);
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
}
void EX_singleExport() {//deprecated
  if (correctSyntax==true) {
    long time = System.currentTimeMillis(); 
    SimpleDateFormat dayTime = new SimpleDateFormat("yyyy_mm_dd_hh_mm_ss");
    String str = dayTime.format(new Date(time));
    if (Mode==AUTOPLAY)str="autoPlay";
    PrintWriter write=createWriter("export/"+str);
    write.write(EX_formatLED(display.getText()));
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
  return ret.substring(1, ret.length());//remove one \n
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
  String lines[];// = loadStrings(versionInfo);
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
String lastAutosaved="//===EX867_Position_Writer===//";
void EX_autoSaveThread_time() {
  String text=display.getText();
  if (text.trim().equals("")==false&&text.equals(lastAutosaved)==false&&text.equals("//===EX867_Position_Writer===//")==false) {
    long time = System.currentTimeMillis(); 
    SimpleDateFormat dayTime = new SimpleDateFormat("yyyy_MM_dd_hh_mm_ss");
    String str = dayTime.format(new Date(time));
    PrintWriter write=createWriter("autoSave/autoSave_"+str+".txt");
    write.write(text);
    write.flush();
    write.close();
    lastAutosaved=text;
  }
}
void EX_autoSave(String theme, String in) {
  if (in.trim().equals("")==false&&in.equals(lastAutosaved)==false&&in.equals("//===EX867_Position_Writer===//")==false) {
    long time = System.currentTimeMillis(); 
    SimpleDateFormat dayTime = new SimpleDateFormat("yyyy_MM_dd_hh_mm_ss");
    String str = dayTime.format(new Date(time));
    PrintWriter write=createWriter("autoSave/"+theme+"_"+str+".txt");
    write.write(in);
    write.flush();
    write.close();
    lastAutosaved=in;
  }
}