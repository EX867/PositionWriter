import java.io.*;
import java.nio.channels.FileChannel;
import java.nio.file.*;
import java.text.SimpleDateFormat;
import sojamo.drop.*;
import java.lang.reflect.Field;
import javax.swing.filechooser.FileSystemView;
SDrop drop;
File[] fileList;
String getDocuments() {//https://stackoverflow.com/questions/9677692/getting-my-documents-path-in-java
  return FileSystemView.getFileSystemView().getDefaultDirectory().getPath();
}
String getAppData() {//https://stackoverflow.com/questions/1198911/how-to-get-local-application-data-folder-in-java
  //https://gamedev.stackexchange.com/questions/23040/is-there-a-cross-platform-special-directory-i-can-use-for-game-save-files
  if (platform==WINDOWS) {
    return System.getenv("LOCALAPPDATA");
  } else if (platform==LINUX) {
    return System.getProperty("user.home")+"/.local/share/PositionWriter";
  } else {
    return System.getProperty("user.home")+"/PositionWriter";//do not support!!
  }
}
String getUsername() {
  return System.getProperty("user.name");
}
String getDataPath() {
  if (DEVELOPER_BUILD) {
    return new File(joinPath(DEVELOPER_PATH, "data")).getAbsolutePath();
  } else {
    return new File("data").getAbsolutePath();
  }
}
void buildVersion() {
  JSONObject version=new JSONObject();
  version=parseJSONObject(VERSION);
  startText="PositionWriter "+version.getInt("major")+"."+version.getInt("minor")+" "+version.getString("type");
  if (version.getString("type").equals("beta")) {
    startText=startText+" "+version.getInt("build");
  }
  startText=startText+" ("+version.getString("build_date")+" build)";
}
void checkVersion() {
  JSONObject version=new JSONObject();
  version=parseJSONObject(VERSION);
  try {
    String[] lines=loadStrings("https://ex867.github.io/PositionWriter/versionInfo");
    JSONObject beta=parseJSONObject(lines[2].replace("<p>", "").replace("</p>", ""));//fixed 3rd line
    JSONObject production=parseJSONObject(lines[3].replace("<p>", "").replace("</p>", ""));//fixed 4th line
    if (version.getString("type").equals("beta")) {//if production>=current->production, beta>=current->beta
      if (production.getInt("major")==version.getInt("major")) {//only compare if major is same.
        if (production.getInt("minor")>version.getInt("minor")) {
          registerPrepare(getFrameid("F_UPDATE"));
          return;
        } else if (production.getInt("minor")==version.getInt("minor")&&production.getInt("patch")>version.getInt("patch")) {
          registerPrepare(getFrameid("F_UPDATE"));
          return;
        }
      }
      if (beta.getInt("major")==version.getInt("major")) {//only compare if major is same.
        if (beta.getInt("minor")>version.getInt("minor")) {
          registerPrepare(getFrameid("F_UPDATE"));
          return;
        } else if (beta.getInt("minor")==version.getInt("minor")&&beta.getInt("patch")>version.getInt("patch")) {
          registerPrepare(getFrameid("F_UPDATE"));
          return;
        } else if (beta.getInt("minor")==version.getInt("minor")&&beta.getInt("patch")==version.getInt("patch")&&beta.getInt("build")>version.getInt("build")) {
          registerPrepare(getFrameid("F_UPDATE"));
          return;
        }
      }
    } else if (version.getString("type").equals("production")) {//if production>=current->production
      if (production.getInt("major")==version.getInt("major")) {//only compare if major is same.
        if (production.getInt("minor")>version.getInt("minor")) {
          registerPrepare(getFrameid("F_UPDATE"));
          return;
        } else if (production.getInt("minor")==version.getInt("minor")&&production.getInt("patch")>version.getInt("patch")) {
          registerPrepare(getFrameid("F_UPDATE"));
          return;
        }
      }
    }
  }
  catch(Exception e) {
    //there is problem with internet, so ignore.
  }
}
void loadPaths(String customPath) {
  String username=getUsername();
  XML XmlData;
  if (customPath.equals(""))XmlData=loadXML("Path.xml");//WARNING!! if Path.xml not exists, program will not work correctly.
  else XmlData=loadXML(customPath);
  XML Data=null;
  if (XmlData!=null)Data=XmlData.getChild("GlobalPath");//
  if (Data==null)GlobalPath=joinPath(getDocuments(), "PositionWriter");
  else GlobalPath=Data.getContent().replace("?", username);
  printLog("GlobalPath", GlobalPath);
  if (XmlData!=null)Data=XmlData.getChild("autosaved");//
  if (Data==null)AutoSavePath="Autosaved";
  else AutoSavePath=Data.getContent().replace("?", username);
  if (XmlData!=null)Data=XmlData.getChild("led_saved");//
  if (Data==null)LedSavePath="Led_saved";
  else LedSavePath=Data.getContent().replace("?", username);
  if (XmlData!=null)Data=XmlData.getChild("keySound_saved");//
  if (Data==null)KeySoundSavePath="KeySound_saved";
  else KeySoundSavePath=Data.getContent().replace("?", username);
  if (XmlData!=null)Data=XmlData.getChild("projects");//
  if (Data==null)ProjectsPath="Projects";
  else ProjectsPath=Data.getContent().replace("?", username);
  if (XmlData!=null)Data=XmlData.getChild("temp");//
  if (Data==null)TempPath="Temp";
  else TempPath=Data.getContent().replace("?", username);
  if (XmlData!=null)Data=XmlData.getChild("external");//
  if (Data==null)ExternalPath="External";
  else ExternalPath=Data.getContent().replace("?", username);
  if (XmlData!=null)Data=XmlData.getChild("midi");//
  if (Data==null)MidiPath="Midi";
  else MidiPath=Data.getContent().replace("?", username);
}
void External_setup() {
  //load path data
  //String AppdataLocal=joinPath(getAppData(),"PositionWriter/Local/path.txt");
  KeySoundPath=getDocuments();
  WavEditPath=joinPath(GlobalPath, "wavedit");
  //
  loadPaths("");
  //...https://stackoverflow.com/questions/1555658/is-it-possible-in-java-to-access-private-fields-via-reflection
  try {
    Field f= surface.getClass().getDeclaredField("canvas");
    f.setAccessible(true);//Very important, this allows the setting to work.
    drop=new SDrop((java.awt.Canvas)f.get(surface));
    drop.addDropListener(new DropListener() {
      @Override
        public void dragExit() {
        Overlay=null;
      }
      @Override
        public void update(float x, float y) {
        x=x/scale;
        y=y/scale;
        if (currentFrame==1) {
          setOverlay(0, 0, Width, Height);
        } else if (currentFrame==2) {
          int tempx=keySoundPad.getButtonXByX((int)x);
          int tempy=keySoundPad.getButtonYByY((int)y);
          if (tempx!=-1&&tempy!=-1) {
            setOverlay(keySoundPad.getButtonBounds(tempx, tempy));
          } else {
            setOverlay(0, 0, Width, Height);
          }
        } else if (currentFrame==3) {
          setOverlay(0, 0, Width, Height);
        } else if (currentFrame==11) {//mp3 converter
          UIelement elem=UI[getUIidRev("MP3_INPUT")];
          setOverlay(elem.position.x, elem.position.y, elem.size.x, elem.size.y);
        } else if (currentFrame==19) {//skinedit
          if (skinEditor.getDropAreaItem((int)x, (int)y)!=null) {
            setOverlay(skinEditor.getDropAreaItem((int)x, (int)y).location);
          }
        }
      }
      @Override
        public void dropEvent(DropEvent de) {
        Overlay=null;
        float x=de.x()/scale;
        float y=de.y()/scale;
        try {
          String filename=de.file().getAbsolutePath().replace("\\", "/");
          if (filename==null)return;
          if (currentFrame==1) {//keyled
            if (de.file().isFile()&&isImageFile(de.file())) {
              currentLedFrame=0;
              PImage image=loadImage(filename);
              if (image.width>PAD_MAX||image.height>PAD_MAX)return;
              frameSlider.skip=true;
              ((TextBox)UI[getUIid("I_CHAIN")]).value=1;
              ((TextBox)UI[getUIid("I_CHAIN")]).text="1";
              ((TextBox)UI[getUIid("I_BUTTONX")]).value=image.width;
              ((TextBox)UI[getUIid("I_BUTTONX")]).text=str(image.width);
              ((TextBox)UI[getUIid("I_BUTTONY")]).value=image.height;
              ((TextBox)UI[getUIid("I_BUTTONY")]).text=str(image.height);
              L_ResizeData(1, image.width, image.height);
              ((TextEditor)UI[textfieldId]).setText(analyzer.ImageToLed(image));
              frameSlider.skip=false;
              registerRender();
            } else analyzer.loadKeyLedGlobal(filename);
            title_filename=filename;
            title_edited="";
            loadedOnce_led=true;
            surface.setTitle(title_filename+title_edited+title_suffix);
            setStatusR("Loaded : "+title_filename+".");
          } else if (currentFrame==2) {
            File file=new File(filename);
            if (file.isFile()) {
              int ksx=ksX;
              int ksy=ksY;
              int tempx=keySoundPad.getButtonXByX((int)x);
              int tempy=keySoundPad.getButtonYByY((int)y);
              if (tempx!=-1&&tempy!=-1) {
                ksx=tempx;
                ksy=tempy;
              }
              if (isSoundFile(file)) {
                int id=getUIid("I_SOUNDVIEW");
                KS.get(ksChain)[ksx][ksy].loadSound(file.getAbsolutePath().replace("\\", "/"));
                skipRendering=true;
                if (ksx==ksX&&ksy==ksY) {
                  ((ScrollList)UI[id]).setItems(KS.get(ksChain)[ksx][ksy].ksSound.toArray(new String[0]));
                  ((Button)UI[getUIid("T_SOUNDVIEW")]).onRelease();
                }
              } else {
                int id=getUIid("I_LEDVIEW");
                KS.get(ksChain)[ksx][ksy].loadLed(file.getAbsolutePath().replace("\\", "/"));
                skipRendering=true;
                if (ksx==ksX&&ksy==ksY) {
                  ((ScrollList)UI[id]).setItems(KS.get(ksChain)[ksx][ksy].ksLedFile.toArray(new String[0]));
                  ((Button)UI[getUIid("T_LEDVIEW")]).onRelease();
                }
              }
              title_edited="*";
              surface.setTitle(title_filename+title_edited+title_suffix);
              registerRender();
            } else {
              analyzer.loadKeySoundGlobal(filename);
              title_filename=filename;
              title_edited="";
              loadedOnce_keySound=true;
              surface.setTitle(title_filename+title_edited+title_suffix);
            }
            setStatusR("Loaded : "+title_filename+".");
          } else if (currentFrame==3) {
            String name=getFileName(filename);
            if (name.equals("android.jar")) {
              EX_fileCopy(filename, joinPath(joinPath(GlobalPath, ExternalPath), "android.jar"));
              setStatusR("Copied : android.jar");
              registerRender();
            } else if (name.equals("Colors.xml")) {
              loadColors(filename);
              maskImages(UIcolors[I_BACKGROUND]);
              setStatusR("Loaded : Colors.xml");
              registerRender();
            } else if (name.equals("Shortcuts.xml")) {
              loadShortcuts(filename);
              setStatusR("Loaded : Shortcuts.xml");
              registerRender();
            } else if (name.equals("Settings.xml")) {
              loadCustomSettings(filename);
              setStatusR("Loaded : Settings.xml");
              registerRender();
            } else if (name.equals("Paths.xml")) {
              loadPaths(filename);
              setStatusR("Loaded : Paths.xml");
              registerRender();
            }
          } else if (currentFrame==11) {//mp3 converter
            ((ScrollList)UI[getUIidRev("MP3_INPUT")]).addItem(filename);
          } else if (currentFrame==19) {
            File file=new File(filename);
            if (skinEditor.getDropAreaItem((int)x, (int)y)!=null) {
              if (isImageFile(file)) {
                skinEditor.getDropAreaItem((int)x, (int)y).setImage(loadImage(file.getAbsolutePath()));
              }
            }
          }
        }
        catch(Exception e) {
          displayLogError(e);
        }
      }
    }
    );
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory())return file.listFiles();
  return null;
}
String[] listFileNames(String dir) {
  File file=new File(dir);
  if (file==null)return new String [0];
  dir=dir.replace('\\', '/');
  if (file.isDirectory()==false)new File(dir).mkdirs();
  printLog("listFileNames()", "input : "+dir);
  if (file.isDirectory()) {
    File[] view=file.listFiles();
    String[] ret=new String[view.length];
    int a=0;
    while (a<ret.length) {
      ret[a]=getFileName(view[a].getAbsolutePath());
      a=a+1;
    }
    return ret;
  }
  return new String[0];
}
String listFilePaths_history="";
String[] listFilePaths_related(String dir) {
  listFilePaths_history=dir;
  File file = new File(dir);
  dir=dir.replace('\\', '/');
  if (file==null)file=new File(GlobalPath);
  else if (file.isDirectory()==false)new File(dir).mkdirs();
  printLog("listFileNames()", "input : "+dir);
  if (file.isDirectory()) {
    File[] view=file.listFiles();
    int directorynext=0;
    int a=0;
    while (a<view.length) {
      if (view[a].isDirectory()) {
        File temp=view[a];
        view[a]=view[directorynext];
        view[directorynext]=temp;
        directorynext++;
      }
      a=a+1;
    }
    fileList=new File[view.length+1];
    fileList[0]=file.getParentFile();
    if (fileList[0]==null)fileList[0]=file;
    a=0;
    while (a<view.length) {
      fileList[a+1]=view[a];
      a=a+1;
    }
    String[] ret=new String[fileList.length];
    a=1;
    while (a<ret.length) {
      ret[a]=fileList[a].getAbsolutePath();
      a=a+1;
    }
    ret[0]="/..";
    return ret;
  }
  fileList=new File[1];
  fileList[0]=new File(GlobalPath+"path is incorrect!\npath : "+dir);
  return new String[]{"path is incorrect!\npath : "+dir};
}
String[] listFilePaths(String dir) {
  if (new File(dir).isDirectory()==false)new File(dir).mkdirs();
  dir=dir.replace('\\', '/');
  printLog("listFileNames()", "input : "+dir);
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] view=file.listFiles();
    int directorynext=0;
    int a=0;
    while (a<view.length) {
      if (view[a].isDirectory()) {
        File temp=view[a];
        view[a]=view[directorynext];
        view[directorynext]=temp;
        directorynext++;
      }
      a=a+1;
    }
    String[] ret=new String[view.length+1];
    a=1;
    while (a<ret.length) {
      ret[a-1]=view[a].getAbsolutePath();
      a=a+1;
    }
    ret[0]="/..";
    return ret;
  }
  return new String[]{"path is incorrect!\npath : "+dir};
}
String joinPath(String path1, String path2) {// works
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
  //assert filename.contains("/" || "\\")==false
  String[] words;
  words=filename.split("\\.");
  if (words.length>1)return words[words.length-1];
  else return "";
}
String getExtensionElse(String filename) {
  if (filename.equals(""))return "";
  //assert filename.contains("/" || "\\")==false
  String[] words;
  words=split(filename, ".");
  int a=1;
  String ret=words[0];
  while (a<words.length-1) {
    ret=ret+"."+words[a];
    a=a+1;
  }
  return ret;
}
String getFormat(String path) {
  try {
    java.nio.file.Path source = java.nio.file.Paths.get(path);
    if (source==null) {
      return "error!";
    }
    String ret= java.nio.file.Files.probeContentType(source);
    if (ret==null)return "unknown";
    if (ret.equals("null"))return "unknown";
    else return ret;
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  return "unknown";
}
boolean EX_fileCopy(String source, String target) {//http://www.yunsobi.com/blog/406
  surface.setTitle(title_filename+title_edited+title_suffix+" - copying "+source+" to "+target+"...");
  File sourceFile = new File( source );
  FileInputStream inputStream = null;
  FileOutputStream outputStream = null;
  FileChannel fcin = null;
  FileChannel fcout = null;
  boolean ret=true;
  try {
    new File(target).getParentFile().mkdirs();
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
      if (fcout!=null)fcout.close();
    }
    catch(IOException ioe) {
      ret=false;
    }
    try {
      if (fcin!=null)fcin.close();
    }
    catch(IOException ioe) {
      ret=false;
    }
    try {
      if (outputStream!=null)outputStream.close();
    }
    catch(IOException ioe) {
      ret=false;
    }
    try {
      if (inputStream!=null)inputStream.close();
    }
    catch(IOException ioe) {
      ret=false;
    }
  }
  return ret;
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
  surface.setTitle(title_filename+title_edited+title_suffix+" - reading "+path+"...");
  BufferedReader read=createReader(path);
  StringBuilder builder = new StringBuilder();
  String line=read.readLine();
  while (line!=null) {
    builder.append("\n").append(line);
    line=read.readLine();
  }
  builder.delete(0, 1);
  read.close();
  surface.setTitle(title_filename+title_edited+title_suffix);
  return builder.toString();
}
String writeFile(String path, String text) {
  try {
    surface.setTitle(title_filename+title_edited+title_suffix+" - writing "+path+"...");
    PrintWriter write=createWriter(path);
    write.write(text);
    write.flush();
    write.close();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  surface.setTitle(title_filename+title_edited+title_suffix);
  return text;
}
String newFile() {
  long time = System.currentTimeMillis(); 
  SimpleDateFormat dayTime = new SimpleDateFormat("yyyy_MM_dd_hh_mm_ss");
  return joinPath(GlobalPath, joinPath(LedSavePath, dayTime.format(new java.util.Date(time))+".txt"));
}
String newFolder() {
  long time = System.currentTimeMillis(); 
  SimpleDateFormat dayTime = new SimpleDateFormat("yyyy_MM_dd_hh_mm_ss");
  return joinPath(GlobalPath, joinPath(KeySoundSavePath, dayTime.format(new java.util.Date(time))));
}
/* autosave vars */
long autosave_start=0;
void autoSave() {
  if (autoSave==false)return;
  if (currentFrame==1) {
    int interval=((TextBox)UI[autoSaveId]).value*1000;
    if (drawEnd-autosave_start>interval&&drawStart>interval) {
      thread("autoSaveWrite");
      autosave_start=drawEnd;
    }
  }
}
void autoSaveWrite() {
  if (title_edited.equals("*")==false)return;
  String filename=getNotDuplicatedFilename(joinPath(GlobalPath, AutoSavePath), getFileName(title_filename));
  writeFile(filename, Lines.toString());
  printLog("autoSaveWrite()", "autoSaved : "+new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new java.util.Date(System.currentTimeMillis()))+" : "+filename);
  setStatusR("Autosaved : "+filename);
  //status=autosaved;
}
String getNotDuplicatedFilename(String path, String filename) {
  File file=new File(joinPath(path, filename));
  if (file.exists()==false)return joinPath(path, filename);
  int a=1;
  while (file.exists()) {
    file=new File(joinPath(path, getExtensionElse(filename))+"-"+a+"."+getFileExtension(filename));
    a=a+1;
  }
  return joinPath(path, getExtensionElse(filename))+"-"+a+"."+getFileExtension(filename);
}
String getNotDuplicatedFilename(String path) {
  return getNotDuplicatedFilename(new File(path).getParentFile().getAbsolutePath(), getFileName(path));
}
void saveWorkingFile() {
  if (title_edited.equals("*")==false)return;
  String filename=title_filename;
  if (currentFrame==1) {
    String ext=getFileExtension(filename);
    if (ext.equals("png")||ext.equals("jpg")||ext.equals("tga")||ext.equals("gif")) {
      analyzer.LedToImage(Lines.toString()).save(filename);
    } else {
      writeFile(filename, Lines.toString());
    }
    loadedOnce_led=true;
  } else if (currentFrame==2) {//only save keysound in keysound_saved/keySound in absolute path
    analyzer.writeKS(filename, false);
    loadedOnce_keySound=true;
  }
  printLog("saveWrite()", "saved : "+new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new java.util.Date(System.currentTimeMillis()))+" : "+filename);
  setStatusR("Saved : "+filename);
  title_edited="";
  surface.setTitle(title_filename+title_edited+title_suffix);
}
void saveWorkingFile_unipad() {
  String filename=title_filename;
  if (currentFrame==1) {
    writeFile(getNotDuplicatedFilename(filename), "\n"+Lines.toUnipadString());
  } else if (currentFrame==2) {//only save keysound in keysound_saved/keySound in absolute path
    if (((TextBox)UI[getUIid("I_PROJECTNAME")]).text.equals("")==false) {
      filename=joinPath(GlobalPath, ProjectsPath+"/"+filterString(((TextBox)UI[getUIid("I_PROJECTNAME")]).text, new String[]{"\\", "/", ":", "*", "?", "\"", "<", ">", "|"}));
    } else {
      filename=joinPath(joinPath(GlobalPath, ProjectsPath), getFileName(title_filename));
      //filename=filename.replace("\\", "/").replace("/"+KeySoundSavePath+"/", "/"+ProjectsPath+"/");
    }
    analyzer.writeKS(getNotDuplicatedFilename(filename), true);
  }
  printLog("saveWrite_unipad()", "saved : "+new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new java.util.Date(System.currentTimeMillis()))+" : "+filename);
  setStatusR("Exported : "+filename);
  surface.setTitle(title_filename+title_edited+title_suffix);
}
void deleteFile(String file) throws IOException {
  deleteFile(new File(file));
}
void deleteFile(File f) throws IOException {//https://stackoverflow.com/questions/779519/delete-directories-recursively-in-java
  if (f.isDirectory()) {
    for (File c : f.listFiles())
      deleteFile(c);
  }
  if (!f.delete())
    throw new FileNotFoundException("Failed to delete file: " + f);
}

//=======================================================================================================
void openFileExplorer(String path) {
  if (platform==WINDOWS) {//WARNING!!! Windows specific
    //https://stackoverflow.com/questions/15875295/open-a-folder-in-explorer-using-java
    try {
      java.awt.Desktop.getDesktop().open(new File(path));
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  } else if (platform==LINUX) {
  }
}