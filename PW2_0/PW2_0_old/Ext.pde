import java.io.*;
import java.nio.channels.FileChannel;
import java.nio.file.*;
import java.text.SimpleDateFormat;
import sojamo.drop.*;
import java.lang.reflect.Field;
File[] fileList;
void loadPaths(String customPath) {
  String username=getUsername();
  XML XmlData;
  if (customPath.equals(""))XmlData=loadXML("Path.xml");//WARNING!! if Path.xml not exists, program will not work correctly.
  else XmlData=loadXML(customPath);
  XML Data=null;
  if (XmlData!=null)Data=XmlData.getChild("GlobalPath");//
  if (Data==null)GlobalPath=joinPath(getDocuments(), "PositionWriter");
  else GlobalPath=Data.getContent().replace("?", username);
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
boolean loadKeySoundFlag=false;//true if loading
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
              keyled_textEditor.current.processer.displayFrame=0;
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
              keyled_textEditor.loadText(filename, ImageToLed(image));
              frameSlider.skip=false;
              registerRender();
            } else {
              if (de.file().isFile()) {
                String text=readFile(filename).replace("\r\n", "\n").replace("\r", "\n");
                keyled_textEditor.loadText(filename, text);
                registerRender();
              } else if (de.file().isDirectory()) {
                throw new Exception("ignore");
              } else {
                throw new Exception("file not exists : "+filename);
              }
            }
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
              loadKeySoundGlobal(filename);
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
String listFilePaths_history="";
String[] listFilePaths_related(String dir) {
  listFilePaths_history=dir;
  File file = new File(dir);
  dir=dir.replace('\\', '/');
  if (file==null)file=new File(GlobalPath);
  else if (file.isDirectory()==false)new File(dir).mkdirs();
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
String newFile() {
  long time = System.currentTimeMillis(); 
  SimpleDateFormat dayTime = new SimpleDateFormat("yyyy_MM_dd_hh_mm_ss");
  return joinPath(GlobalPath, joinPath(LedSavePath, dayTime.format(new java.util.Date(time))+".txt"));
}
String ext_createFileName() {
  long time = System.currentTimeMillis(); 
  SimpleDateFormat dayTime = new SimpleDateFormat("MMddhhmmss.led");
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
void saveWorkingFile() {
  if (title_edited.equals("*")==false)return;
  String filename=title_filename;
  if (currentFrame==1) {
    String ext=getFileExtension(filename);
    if (ext.equals("png")||ext.equals("jpg")||ext.equals("tga")||ext.equals("gif")) {
      LedToImage(keyled_textEditor.current).save(filename);
    } else {
      writeFile(filename, keyled_textEditor.current.toString());
    }
    loadedOnce_led=true;
  } else if (currentFrame==2) {//only save keysound in keysound_saved/keySound in absolute path
    writeKS(filename, false);
    loadedOnce_keySound=true;
  }
  setStatusR("Saved : "+filename);
  title_edited="";
  surface.setTitle(title_filename+title_edited+title_suffix);
}
void saveWorkingFile_unipad() {
  String filename=title_filename;
  if (currentFrame==1) {
    writeFile(getNotDuplicatedFilename(filename), "\n"+ToUnipadLed(keyled_textEditor.current));
  } else if (currentFrame==2) {//only save keysound in keysound_saved/keySound in absolute path
    if (((TextBox)UI[getUIid("I_PROJECTNAME")]).text.equals("")==false) {
      filename=joinPath(GlobalPath, ProjectsPath+"/"+filterString(((TextBox)UI[getUIid("I_PROJECTNAME")]).text, new String[]{"\\", "/", ":", "*", "?", "\"", "<", ">", "|"}));
    } else {
      filename=joinPath(joinPath(GlobalPath, ProjectsPath), getFileName(title_filename));
      //filename=filename.replace("\\", "/").replace("/"+KeySoundSavePath+"/", "/"+ProjectsPath+"/");
    }
    writeKS(getNotDuplicatedFilename(filename), true);
  }
  //printLog("saveWrite_unipad()", "saved : "+new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new java.util.Date(System.currentTimeMillis()))+" : "+filename);
  setStatusR("Exported : "+filename);
  surface.setTitle(title_filename+title_edited+title_suffix);
}