void loadPaths(String customPath) {
  String username=getUsername();
  XML XmlData;
  if (customPath.equals(""))XmlData=loadXML("Path.xml");//WARNING!! if Path.xml not exists, program will not work correctly.
  else XmlData=loadXML(customPath);
  XML Data=null;
  if (XmlData!=null)Data=XmlData.getChild("GlobalPath");//
  if (Data==null)GlobalPath=joinPath(getDocuments(), "PositionWriter");
  else GlobalPath=Data.getContent().replace("?", username);
}
boolean loadKeySoundFlag=false;//true if loading
void External_setup() {
  //
  loadPaths("");
  //...https://stackoverflow.com/questions/1555658/is-it-possible-in-java-to-access-private-fields-via-reflection
  try {
    Field f= surface.getClass().getDeclaredField("canvas");
    f.setAccessible(true);//Very important, this allows the setting to work.
    drop=new SDrop((java.awt.Canvas)f.get(surface));
    drop.addDropListener(new DropListener() {
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
            if (name.equals("Colors.xml")) {
              loadColors(filename);
              maskImages(UIcolors[I_BACKGROUND]);
              setStatusR("Loaded : Colors.xml");
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