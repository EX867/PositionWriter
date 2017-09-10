Frame[] Frames; //<>//
String[] Framenames;
int Description_current;
boolean Description_enabled=false;
UIelement[] UI;
String[] UInames;
color[] UIcolors;
String[] UIcolornames;
Shortcut[] Shortcuts;
int tempColor;//used when changing color
//data
//runtime
int currentFrame=0;
int currentTabGlobal=1;
int currentTabKeyLed=3;
int currentTabKeySound=1;
int currentTabSettings=1;
int currentTabWavList=1;
int currentTabAuto=1;
//
int focus=0;
//scale variables
float scale=1;
float MouseX=0;
float MouseY=0;
PVector MouseClick=new PVector(0, 0);
//state variables
int mouseState=AN_RELEASED;
int mouseFrame=0;
boolean keyState=false;
boolean keyInit=false;
int keyFrame=0;
int keyInterval=100;//indicates double click.(keyInterval<DOUBLE_CLICK)
List<Long> reflectedPressedKeys;
int keyCount=0;
int pkeyCount=0;
static final int DOUBLE_CLICK=20;
int doubleClicked=0;
float doubleClickDist=100;
boolean shiftPressed=false;
boolean ctrlPressed=false;
boolean altPressed=false;
boolean skipRendering=false;
//dnd
int draggedListId=-1;//stores last dragged list. so selection -1 check needed.
void createMissingFiles() {
  String datapath="";
  if (DEVELOPER_BUILD) {
    datapath=new File(joinPath(DEVELOPER_PATH, "data")).getAbsolutePath();
  } else {
    datapath=new File("data").getAbsolutePath();
  }
  if (new File(joinPath(datapath, "Path.xml")).exists()==false) {
    EX_fileCopy(joinPath(datapath, "Path_default.xml"), joinPath(datapath, "Path.xml"));
  }
  if (new File(joinPath(datapath, "Settings.xml")).exists()==false) {
    EX_fileCopy(joinPath(datapath, "Settings_default.xml"), joinPath(datapath, "Settings.xml"));
  }
  if (new File(joinPath(datapath, "Colors.xml")).exists()==false) {
    EX_fileCopy(joinPath(datapath, "Colors_default.xml"), joinPath(datapath, "Colors.xml"));
  }
  if (new File(joinPath(datapath, "Shortcuts.xml")).exists()==false) {
    EX_fileCopy(joinPath(datapath, "Shortcuts_default.xml"), joinPath(datapath, "Shortcuts.xml"));
  }
}
void UI_load() {
  // ========= get XML data ========== //
  //load other external data
  XML XmlData=loadXML("Colors.xml");
  XML[] Datas=XmlData.getChildren("element");
  UIcolors=new color[Datas.length];
  UIcolornames=new String[Datas.length];
  int a=0;
  while (a<Datas.length) {
    int id=Datas[a].getInt("id");
    UIcolors[id]=color(int(Datas[a].getFloat("r")), int(Datas[a].getFloat("g")), int(Datas[a].getFloat("b")), int(Datas[a].getFloat("a")));
    UIcolornames[id]=Datas[a].getContent();
    a=a+1;
  }
  // ========= get XML data ========== //
  XmlData=loadXML("MidiInput.xml");
  MidiStart=XmlData.getChild("Start").getInt("value", MidiStart);
  MidiInterval=XmlData.getChild("Interval").getInt("value", MidiInterval);
  if (MidiInterval<0)MidiInterval=max(1, abs(MidiInterval));
  MidiScale=XmlData.getChild("Scale").getInt("value", MidiScale);
  // ========= get XML data ========== //
  XmlData=loadXML("Shortcuts.xml");
  XML[] internals=XmlData.getChildren("internal");
  XML[] externals=XmlData.getChildren("external");
  Shortcuts=new Shortcut[internals.length+externals.length+1];
  a=0;
  Datas=internals;
  //Shortcut(int ID_,String name_, int FunctionId_, boolean ctrl_, boolean alt_, boolean shift_, int key_, int keyCode_, String textEditor_, int frame_,String text_) {
  while (a<internals.length) {
    int id=Datas[a].getInt("id");
    Shortcuts[id]=new Shortcut(id, Datas[a].getContent(), getFunctionId(Datas[a].getContent()), toBoolean(Datas[a].getString("ctrl")), toBoolean(Datas[a].getString("alt")), toBoolean(Datas[a].getString("shift")), Datas[a].getInt("key"), Datas[a].getInt("keycode"), Datas[a].getString("textEditor"), Datas[a].getInt("frame"), "", "", Datas[a].getString("description", ""));
    a=a+1;
  }
  a=0;
  Datas=externals;
  while (a<externals.length) {
    int id=Datas[a].getInt("id");//#return
    Shortcuts[id]=new Shortcut(id, Datas[a].getContent(), S_EXTERNAL, toBoolean(Datas[a].getString("ctrl")), toBoolean(Datas[a].getString("alt")), toBoolean(Datas[a].getString("shift")), Datas[a].getInt("key"), Datas[a].getInt("keycode"), Datas[a].getString("textEditor"), 1, Datas[a].getString("mode"), Datas[a].getString("text"), Datas[a].getString("description", ""));
    a=a+1;
  }
  // ========= get XML data ========== //
  XmlData=loadXML("Default.xml");
  XML Data=XmlData.getChild("Frames");
  Datas=Data.getChildren("element");
  Frames=new Frame[Datas.length+1];
  Framenames=new String[Datas.length+1];
  Frames[DEFAULT]=new Frame(DEFAULT, "", -10, -10, 10, 10);
  Framenames[DEFAULT]="";
  a=0;
  while (a<Datas.length) {
    int id=Datas[a].getInt("id");
    Framenames[id]=Datas[a].getContent();
    a=a+1;
  }
  //Framenames=sort(Framenames);
  a=0;
  while (a<Datas.length) {
    int id=Datas[a].getInt("id");
    Frames[id]=new Frame(id, Datas[a].getContent(), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"));
    a=a+1;
  }
  Data=XmlData.getChild("UIelements");
  Datas=Data.getChildren("element");
  UI=new UIelement[Datas.length+1];
  UInames=new String[Datas.length+1];
  UI[DEFAULT]=new UIelement(DEFAULT, DEFAULT, "", "", -10, -10, 10, 10);
  UInames[DEFAULT]="";
  a=0;
  while (a<Datas.length) {
    int id=Datas[a].getInt("id");
    UInames[id]=Datas[a].getContent();
    a=a+1;
  }
  //UInames=sort(UInames);
  a=0;
  while (a<Datas.length) {
    int id=Datas[a].getInt("id");
    int Type=getTypeId (Datas [a].getString ("type"));
    if (Type==TYPE_BUTTON) {
      if (Datas[a].hasAttribute("value")) {
        if (Datas[a].hasAttribute("image")) {
          UI[id]=new Button(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getString("image"), toBoolean (Datas[a].getString ("value")));
        } else if (Datas[a].hasAttribute("text")) {
          UI[id]=new Button(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getString("text"), Datas[a].getInt("textsize", 1), toBoolean (Datas[a].getString ("value")));
        }
      } else {
        if (Datas[a].hasAttribute("image")) {
          UI[id]=new Button(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getString("image"));
        } else if (Datas[a].hasAttribute("color")) {
          UI[id]=new Button(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), unhex(Datas[a].getString("color")));
        } else if (Datas[a].hasAttribute("text")) {
          UI[id]=new Button(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getString("text"), Datas[a].getInt("textsize", 1));
        }
      }
      if (Datas[a].hasAttribute("vertical")) {
        if (toBoolean(Datas[a].getString("vertical"))) {
          ((Button)UI[id]).vertical=true;
        }
      }
    } else if (Type==TYPE_LABEL) {
      UI[id]=new Label(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getString("text"), Datas[a].getInt("textsize", 1));
    } else if (Type==TYPE_DROPDOWN) {
      UI[id]=new DropDown(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getInt("textsize", 1), Datas[a].getInt("defaultSelection", 0));
    } else if (Type==TYPE_SLIDER) {
      if (Datas[a].getString("variable").equals("int")) {
        UI[id]=new Slider(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getInt("min"), Datas[a].getInt("max"), Datas[a].getInt("value", 0));
      } else if (Datas[a].getString("variable").equals("float")) {
        UI[id]=new Slider(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getFloat("min"), Datas[a].getFloat("max"), Datas[a].getFloat("value", 0));
      }
    } else if (Type==TYPE_DRAGSLIDER) {
      UI[id]=new DragSlider(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getInt("follow"));
    } else if (Type==TYPE_TEXTBOX) {
      if (Datas[a].hasAttribute("title")) {
        if (Datas[a].hasAttribute("value")) {
          UI[id]=new TextBox(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getString("title"), Datas[a].getInt("value"), Datas[a].getString("hint"), Datas[a].getInt("textsize", 1));
        } else if (Datas[a].hasAttribute("text")) {
          UI[id]=new TextBox(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getString("title"), Datas[a].getString("text"), Datas[a].getString("hint"), Datas[a].getInt("textsize", 1));
        }
      } else {
        if (Datas[a].hasAttribute("value")) {
          UI[id]=new TextBox(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getInt("value"), Datas[a].getString("hint"), Datas[a].getInt("textsize", 1));
        } else if (Datas[a].hasAttribute("text")) {
          UI[id]=new TextBox(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getString("text"), Datas[a].getString("hint"), Datas[a].getInt("textsize", 1));
        }
      }
    } else if (Type==TYPE_SCROLLLIST) {
      UI[id]=new ScrollList(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getInt("textsize", 1), toBoolean(Datas[a].getString("reorderable")));
    } else if (Type==TYPE_TEXTEDITOR) { 
      UI[id]=new TextEditor(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"));
    } else if (Type==TYPE_COLORPICKER) {
      UI[id]=new ColorPicker(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"));
    } else if (Type==TYPE_PADBUTTON) {
      UI[id]=new PadButton(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"));
    } else if (Type==TYPE_VELOCITYBUTTON) {
      UI[id]=new VelocityButton(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"));
    } else if (Type==TYPE_WAVEDITOR) {
      UI[id]=new WaveEditor(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"));
    } else if (Type==TYPE_VISUALIZER) {
      UI[id]=new Visualizer(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"));
    } else if (Type==TYPE_LOGGER) {
      UI[id]=new Logger(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"), Datas[a].getInt("textsize"));
    } else {
      UI[id]=new UIelement(id, getTypeId (Datas [a].getString ("type")), Datas[a].getContent(), Datas[a].getString("description"), Datas[a].getInt("x"), Datas[a].getInt("y"), Datas[a].getInt("w"), Datas[a].getInt("h"));
    }
    a=a+1;
  }
  // ========= get XML data ========== //
  Data=XmlData.getChild("FrameData");
  a=1;
  while (a<Frames.length) {
    String line=Data.getChild(Frames[a].name).getContent();
    String[] lines=split(line, "|");
    int b=0;
    while (b<lines.length) {
      lines[b]=lines[b].trim();
      if (lines.equals("")==false) {
        Frames[a].uiIds.add(getUIid(lines[b]));
      }
      b=b+1;
    }
    a=a+1;
  }
}
void getPressedKeysCount() {
  pkeyCount=keyCount;
  keyCount=reflectedPressedKeys.size();
}
void UI_setup() {
  try {
    Field pressedKeys;
    pressedKeys = PApplet.class.getDeclaredField("pressedKeys");
    pressedKeys.setAccessible(true);
    reflectedPressedKeys = (List<Long>) pressedKeys.get(this);
  } 
  catch (Exception e) {
    e.printStackTrace();
    // Critical error!!!
  }

  UI_load();
  setShortcutData();
  setUIcolorsData();
  //disable things and set.
  currentFrame=getFrameid("F_KEYLED");
  velnumId=getUIid("I_VELNUM");
  htmlselId=getUIid("I_HTMLSEL");
  textfieldId=getUIid("I_TEXTFIELD");
  frameSlider=(Slider)UI[getUIid("I_FRAMESLIDER")];
  frameSliderLoop=(DragSlider)UI[getUIid("I_FRAMESLIDERLOOP")];
  timeLabel=(Label)UI[getUIid("I_TIME1")];
  autoSaveId=getUIid("I_AUTOSAVETIME");
  statusL=(Label)UI[getUIid("STATUS_BAR_L")];
  statusR=(Label)UI[getUIid("STATUS_BAR_R")];
  keyLedPad=(PadButton)UI[getUIid("KEYLED_PAD")];
  keySoundPad=(PadButton)UI[getUIid("KEYSOUND_PAD")];
  UI[velnumId].disabled=true;
  UI[htmlselId].disabled=true;
  ((ColorPicker)UI[htmlselId]).setTextBoxes(getUIid("I_HTMLR"), getUIid("I_RECENT1"));
  ((ColorPicker)UI[htmlselId]).disableTextBoxes(true);
  ((ColorPicker)UI[getUIidRev("PC_HTMLSEL")]).setTextBoxes(getUIid("PC_HTMLR"), getUIid("PC_RECENT1"));
  selectedColorType=DS_VEL;
  UI[getUIid("I_UICOLORS")].disabled=true;
  UI[getUIid("I_LEDVIEW")].disabled=true;
  ((Button)UI[getUIid("I_PATH")]).text=GlobalPath;
  autoSave=((Button)UI[getUIid("I_AUTOSAVE")]).value;
  //
  findId=getUIidRev("I_FINDTEXTBOX");
  replaceId=getUIidRev("I_REPLACETEXTBOX");
  UI[findId].disabled=true;
  UI[replaceId].disabled=true;
  UI[getUIidRev("I_NEXTFIND")].disabled=true;
  UI[getUIidRev("I_PREVIOUSFIND")].disabled=true;
  UI[getUIidRev("I_CALCULATE")].disabled=true;
  UI[getUIidRev("I_REPLACEALL")].disabled=true;
  ((TextEditor)UI[textfieldId]).shortenY=UI[textfieldId].position.y-40;//WARNING!!!
  ((TextEditor)UI[textfieldId]).shortenSY=UI[textfieldId].size.y-40;//WARNING!!!
  ((TextEditor)UI[textfieldId]).originalY=UI[textfieldId].position.y;
  ((TextEditor)UI[textfieldId]).originalSY=UI[textfieldId].size.y;
  // ========= hardcoded data ========== //
  ((ScrollList)UI[getUIidRev("I_SIGNALCHAIN")]).setItems(new String[]{"WAVE"});
  ((ScrollList)UI[getUIidRev("I_EFFECTORS")]).setItems(new String[]{"SIMPLE EDIT TOOL", "TIME STRETCHER"});
  UI[getUIidRev("I_CUTPOINT")].disabled=true;
  UI[getUIidRev("T_SIGNALCHAIN")].disabled=true;
  UI[getUIidRev("T_AUTOMATION")].disabled=true;
  UI[getUIidRev("I_SIGNALCHAIN")].disabled=true;
  UI[getUIidRev("I_EFFECTORS")].disabled=true;
  UI[getUIidRev("I_AUTOMATION")].disabled=true;
  //
  userMacro1=((Button)UI[getUIid("I_NUMBER1")]).text.replace("\\n", "\n");
  userMacro2=((Button)UI[getUIid("I_NUMBER2")]).text.replace("\\n", "\n");
  converter.converterPlayer.assign((Slider)UI[getUIid("MP3_PROGRESSBAR")], (Label)UI[getUIid("MP3_TIME")]);
  UI[getUIidRev("KS_LOOP")].disabled=true;
  //
  ((ScrollList)UI[getUIid("I_FILEVIEW1")]).setItems(listFilePaths_related(KeySoundPath));
  //
  ((TextBox)UI[getUIidRev("MP3_OUTPUT")]).text=joinPath(GlobalPath, "editor");
  try {
    ((ScrollList)UI[getUIid("MP3_CODEC")]).setItems((String[])new Encoder().getAudioEncoders());
    ((ScrollList)UI[getUIid("MP3_FORMAT")]).setItems((String[])new Encoder().getSupportedEncodingFormats());
  }
  catch(Exception e) {
  }
  // === Custom settings load === //
  loadCustomSettings();
  //---
  Frames[currentFrame].prepare();
}
void loadCustomSettings() {
  XML XmlData=loadXML("Settings.xml");
  XML Data;
  Data=XmlData.getChild("I_AUTOSAVE");
  if (Data!=null) {
    ((Button)UI[getUIid("I_AUTOSAVE")]).value=toBoolean(Data.getString("value"));
    autoSave=toBoolean(Data.getString("value"));
  }
  Data=XmlData.getChild("I_AUTOSAVETIME");
  if (Data!=null) {
    ((TextBox)UI[getUIid("I_AUTOSAVETIME")]).value=Data.getInt("value");
    ((TextBox)UI[getUIid("I_AUTOSAVETIME")]).text=""+Data.getInt("value");
  }
  Data=XmlData.getChild("I_RESOLUTION");
  if (Data!=null) {
    ((Slider)UI[getUIid("I_RESOLUTION")]).valueF=Data.getFloat("value");
    scale=Data.getFloat("value");
    if (scale<=0)scale=1;
    surface.setSize(floor(1420*scale), floor(920*scale));
    setSize(floor(1420*scale), floor(920*scale));
    popMatrix();
    popMatrix();
    pushMatrix();
    scale(scale);
    pushMatrix();
    registerRender();
  }
  Data=XmlData.getChild("I_RELOADINSTART");
  if (Data!=null) {
    ((Button)UI[getUIid("I_RELOADINSTART")]).value=toBoolean(Data.getString("value"));
  }
  Data=XmlData.getChild("I_TEXTSIZE");
  if (Data!=null) {
    ((TextBox)UI[getUIid("I_TEXTSIZE")]).value=Data.getInt("value");
    ((TextBox)UI[getUIid("I_TEXTSIZE")]).text=""+Data.getInt("value");
  }
  Data=XmlData.getChild("I_STARTFROM");
  if (Data!=null) {
    ((Button)UI[getUIid("I_STARTFROM")]).value=toBoolean(Data.getString("value"));
    startFrom=toBoolean(Data.getString("value"));
  }
  Data=XmlData.getChild("I_AUTOSTOP");
  if (Data!=null) {
    ((Button)UI[getUIid("I_AUTOSTOP")]).value=toBoolean(Data.getString("value"));
    autoStop=toBoolean(Data.getString("value"));
  }
  Data=XmlData.getChild("I_DEFAULTINPUT");
  if (Data!=null) {
    ((Button)UI[getUIid("I_DEFAULTINPUT")]).value=toBoolean(Data.getString("value"));//default
  }
  Data=XmlData.getChild("I_OLDINPUT");
  if (Data!=null) {
    ((Button)UI[getUIid("I_OLDINPUT")]).value=toBoolean(Data.getString("value"));
    if (toBoolean(Data.getString("value"))==true) {
      Mode=MANUALINPUT;
    }
  }
  Data=XmlData.getChild("I_CYXMODE");
  if (Data!=null) {
    ((Button)UI[getUIid("I_CYXMODE")]).value=toBoolean(Data.getString("value"));
    if (toBoolean(Data.getString("value"))==true) {
      Mode=CYXMODE;
    }
  }
  Data=XmlData.getChild("I_LANGUAGE");
  if (Data!=null) {
    ((DropDown)UI[getUIid("I_LANGUAGE")]).selection=Data.getInt("value");
  }
  Data=XmlData.getChild("I_DESCRIPTIONTIME");
  if (Data!=null) {
    ((TextBox)UI[getUIid("I_DESCRIPTIONTIME")]).value=Data.getInt("value");
    ((TextBox)UI[getUIid("I_DESCRIPTIONTIME")]).text=""+Data.getInt("value");
  }
  Data=XmlData.getChild("I_IGNOREMC");
  if (Data!=null) {
    ((Button)UI[getUIid("I_IGNOREMC")]).value=toBoolean(Data.getString("value"));
  }
  Data=XmlData.getChild("keyLED");
  if (Data!=null) {
    loadedOnce_led=toBoolean(Data.getString("load"));
    if (loadedOnce_led)title_keyledfilename=Data.getContent();
  }
  Data=XmlData.getChild("keySound");
  if (Data!=null) {
    loadedOnce_keySound=toBoolean(Data.getString("load"));
    if (loadedOnce_keySound)title_keysoundfoldername=Data.getContent();
  }
}
boolean renderRegistered=false;
void registerRender() {
  renderRegistered=true;
}
boolean prepareRegistered=false;
int prepareId=0;
void registerPrepare(int id) {
  prepareId=id;
  prepareRegistered=true;
}
void UI_update() {
  Frames[currentFrame].update();
  skipRendering=false;
  if (Description_enabled)UI[Description_current].description.render();
  if (statusLchanged)statusL.render();
  if (statusRchanged)statusR.render();
  setStatusL("");
  if (prepareRegistered) {
    int focusbefore=focus;
    UI[focusbefore].skip=true;
    focus=DEFAULT;
    UI[focusbefore].resetFocus();
    UI[focusbefore].skip=false;
    Frames[prepareId].prepare(currentFrame);
    prepareRegistered=false;
  }
  if (renderRegistered) {
    Frames[currentFrame].render();
    renderRegistered=false;
  }
}
void getMouseState() {
  MouseX=mouseX/scale-Frames[currentFrame].position.x+Frames[currentFrame].size.x;
  MouseY=mouseY/scale-Frames[currentFrame].position.y+Frames[currentFrame].size.y;
  if (mousePressed) {
    if (mouseState==AN_PRESS)mouseState=AN_PRESSED;
    if (mouseState==AN_RELEASE||mouseState==AN_RELEASED) {
      if (keyInterval<DOUBLE_CLICK&&doubleClicked==1) {
        doubleClicked=2;
      } else {
        doubleClicked=0;
      }
      keyInterval=frameCount-keyFrame;
      mouseState=AN_PRESS;
      keyFrame=frameCount;
      doubleClickDist=dist(MouseClick.x, MouseClick.y, MouseX, MouseY);
      MouseClick.x=MouseX;
      MouseClick.y=MouseY;
    }
  } else {
    if (mouseState==AN_RELEASE) {
      mouseState=AN_RELEASED;
      draggedListId=-1;//dirty code...
    }
    if (mouseState==AN_PRESS||mouseState==AN_PRESSED) {
      mouseState=AN_RELEASE;
    }
  }
}
void keyPressed_main() {
  //println("keys "+str(int(key))+" "+str(int(keyCode))+" "+str(ctrlPressed)+" "+str(shiftPressed)+" "+frameCount);
  if (key==CODED&&keyCode==SHIFT) {
    shiftPressed=true;
    //if (shiftPressed==false)printLog("event", "shiftPressed + "+frameCount);
  } else if (key==CODED&&keyCode==CONTROL) {
    ctrlPressed=true;
    //if (ctrlPressed==false)printLog("event", "ctrlPressed + "+frameCount);
  } else if (key==CODED&&keyCode==ALT) {
    altPressed=true;
    //if (altPressed==false)printLog("event", "altPressed + "+frameCount);
  } else {
    if (keyState==false) {
      keyFrame=frameCount;
      if (key==CODED&&keyCode==LEFT) cursorLeft();
      if (key==CODED&&keyCode==RIGHT)cursorRight();
      if (key==CODED&&keyCode==UP) cursorUp();
      if (key==CODED&&keyCode==DOWN)cursorDown();
    }
    keyState=true;
    if (keyInit) {
      if (frameCount-keyFrame>0) keyState=false;
    } else {
      if (frameCount-keyFrame>20) {
        keyState=false;
        keyInit=true;
      }
    }
  }
  if (key == ESC) {
    key = 0;  // Fools! don't let them escape!
  }
}
void keyReleased() {
  keyState=false;
  keyInit=false;
  if (key==CODED&&keyCode==SHIFT)shiftPressed=false;
  if (key==CODED&&keyCode==CONTROL)ctrlPressed=false;
  if (key==CODED&&keyCode==ALT)altPressed=false;
}
boolean shortcutExcept() {
  if (UI[focus].Type!=TYPE_TEXTEDITOR&&UI[focus].Type!=TYPE_TEXTBOX)return true;
  return false;
}
void keyTyped() {
  pushMatrix();
  scale(scale);
  pushMatrix();
  translate(Frames[currentFrame].position.x-Frames[currentFrame].size.x, Frames[currentFrame]. position.y-Frames[currentFrame].size.y);
  if (UI[focus].Type==TYPE_TEXTBOX)((TextBox)UI[focus]).keyTyped();
  if (UI[focus].Type==TYPE_TEXTEDITOR)((TextEditor)UI[focus]).keyTyped();
  editable_keyTyped();
  keyState=false;
  popMatrix();
  popMatrix();
}
void mouseWheel(MouseEvent e) {
  if (UI[focus].Type==TYPE_TEXTEDITOR)((TextEditor)UI[focus]).mouseWheel(e);
  else if (UI[focus].Type==TYPE_SCROLLLIST)((ScrollList)UI[focus]).mouseWheel(e);
  if (UI[focus].Type==TYPE_LOGGER)((Logger)UI[focus]).mouseWheel(e);
}
void cursorLeft() {
  if (UI[focus].Type==TYPE_TEXTBOX)((TextBox)UI[focus]).cursorLeft();
  else if (UI[focus].Type==TYPE_TEXTEDITOR)((TextEditor)UI[focus]).cursorLeft();
}
void cursorRight() {
  if (UI[focus].Type==TYPE_TEXTBOX)((TextBox)UI[focus]).cursorRight();
  else if (UI[focus].Type==TYPE_TEXTEDITOR)((TextEditor)UI[focus]).cursorRight();
}
void cursorUp() {
  if (UI[focus].Type==TYPE_TEXTEDITOR)((TextEditor)UI[focus]).cursorUp();
}
void cursorDown() {
  if (UI[focus].Type==TYPE_TEXTEDITOR)((TextEditor)UI[focus]).cursorDown();
}
boolean isMouseOn(float x, float y, float w, float h) {//RADIUS
  if (x-w<MouseX&&MouseX<x+w&&y-h<MouseY&&MouseY<y+h)return true;
  return false;
}
boolean isMousePressed(float x, float y, float w, float h) {
  if (mousePressed&&mouseButton==LEFT&&x-w<MouseX&&MouseX<x+w&&y-h<MouseY&&MouseY<y+h)return true;
  return false;
}
boolean isMousePressedRight(float x, float y, float w, float h) {
  if (mousePressed&&mouseButton==RIGHT&&x-w<MouseX&&MouseX<x+w&&y-h<MouseY&&MouseY<y+h)return true;
  return false;
}
class Frame {
  int ID;
  String name;
  ArrayList<Integer> uiIds=new ArrayList<Integer>();
  PVector position;
  PVector size;
  //
  int beforeFrame=0;
  public Frame() {
    ID=DEFAULT;
    position=new PVector(0, 0);
    size=new PVector(10, 10);
  }
  public Frame(int ID_, String name_, int x_, int y_, int w_, int h_) {
    ID=ID_;
    name=name_;
    position=new PVector(x_, y_);
    size=new PVector(w_, h_);
  }
  Object returnValue() {
    switch(ID) {//specify id code here
    case DEFAULT:
      break;
    }
    return null;
  }
  void update() {
    int a=0;
    while (a<uiIds.size()) {
      UI[uiIds.get(a)].react();
      a=a+1;
    }
  }
  void returnBack() {
    if (beforeFrame==0)exit();
    popMatrix();
    fill(0, 100);
    rect(position.x, position.y, size.x, size.y);
    pushMatrix();
    translate(position.x-size.x, position.y-size.y);
    if (Frames[beforeFrame].beforeFrame==0)Frames[beforeFrame].prepare();
    else Frames[beforeFrame].prepare(Frames[beforeFrame].beforeFrame);
  }
  void prepare() {
    prepare(0);
  }
  void prepare(int beforeFrame_) {
    beforeFrame=beforeFrame_;
    //printLog("Frame.prepare()", "prepare new frame : "+ID);
    if (currentFrame==ID) {
      render();
      return;
    }
    doubleClicked=0;
    if (currentFrame==1) {
      title_keyledfilename=title_filename;
      title_keylededited=title_edited;
      surface.setTitle(title_filename+title_edited+title_suffix);
    } else if (currentFrame==2) { 
      title_keysoundfoldername=title_filename;
      title_keysoundedited=title_edited;
      surface.setTitle(title_filename+title_edited+title_suffix);
    }
    currentFrame=ID;
    popMatrix();
    fill(0, 100);
    if (beforeFrame!=0)rect(Frames[beforeFrame].position.x, Frames[beforeFrame].position.y, Frames[beforeFrame].size.x, Frames[beforeFrame].size.y);
    pushMatrix();
    translate(position.x-size.x, position.y-size.y);
    if (name.equals("F_KEYLED")) {
      currentTabGlobal=ID;
      title_filename=title_keyledfilename;
      title_edited=title_keylededited;
      surface.setTitle(title_filename+title_edited+title_suffix);
    } else if (name.equals("F_KEYSOUND")) {
      currentTabGlobal=ID;
      title_filename=title_keysoundfoldername;
      title_edited=title_keysoundedited;
      surface.setTitle(title_filename+title_edited+title_suffix);
    } else if (name.equals("F_SETTINGS")) {
      currentTabGlobal=ID;
    } else if (name.equals("F_WAVEDIT")) {
      currentTabGlobal=ID;
    }
    render();
    /*switch(ID) {
     case F_LEDEDIT:
     break;
     case F_KEYSOUND:
     break;
     case F_SETTINGS:
     break;
     case F_WAVEDIT:
     break;
     case F_EXPORT:
     break;
     case F_FIND:
     break;
     case F_PICKCOLOR:
     break;
     case F_INFO:
     break;
     }*/
  }
  void render() {
    if (skipRendering)return;
    //printLog("Frame.render()", "rendered : "+ID);
    popMatrix();
    fill(UIcolors[I_BACKGROUND]);
    rect(position.x, position.y, size.x, size.y);
    pushMatrix();
    translate(position.x-size.x, position.y-size.y);
    int a=0;
    while (a<uiIds.size()) {
      if (UI[uiIds.get(a)].disabled==false)UI[uiIds.get(a)].render();
      a=a+1;
    }
    if (name.equals("F_KEYSOUND")) {
    } else if (name.equals("F_SETTINGS")) {
      drawInputLine();
    } else if (name.equals("F_WAVEDIT")) {
    }
  }
}
class Description {
  PVector position=new PVector();
  String content;
  boolean movable=true;
  Description(String content_) {
    content=content_;
  }
  void move(float mouseX_, float mouseY_) {
    if (movable) {
      textFont(fontRegular);
      position.x=mouseX_;
      position.y=mouseY_;
      textSize(15);
      if (position.x+ textWidth(content)/2+10>Width)position.x=Width-textWidth(content)/2-10;
      else if (position.x- textWidth(content)/2-10<0)position.x=textWidth(content)/2+10;
      if (position.y+ 15+10>Height)position.y=Height-15-10;
      else if (position.y- 15-10<0)position.y=15+10;
      movable=false;
      textFont(fontBold);
    }
  }
  void render() {
    if (content.equals (""))return;
    textFont(fontRegular);
    textSize(15);
    stroke(0);
    strokeWeight(1);
    fill(255, 150);
    rect(position.x, position.y, textWidth(content)/2+4, 15);
    fill(0);
    text(content, position.x, position.y);
    noStroke();
    textFont(fontBold);
  }
}

// === UI ELEMENTS === //
class UIelement {
  public int ID;
  public int Type;
  public String name;
  public Description description;
  protected PVector position;
  protected PVector size;
  //runtime
  public boolean disabled;
  protected long firstOn;
  protected long firstPress;
  protected boolean entered;
  protected boolean pressed;
  protected boolean descriptionShowed;
  boolean registerRender;
  public boolean skip=false;
  public UIelement(int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    ID=ID_;
    Type=Type_;
    name=name_;
    description=new Description(description_);
    position=new PVector(x_, y_);
    size=new PVector(w_, h_);
    disabled=false;
    firstOn=0;
    firstPress=0;
  }
  boolean react() {//render in react. if reacted - return true
    if (mouseState==AN_RELEASED)pressed=false;
    if (disabled)return false;
    firstOn=firstOn+drawInterval;
    if (isMouseOn(position.x, position.y, size.x, size.y)) {
      if (entered==false) {
        //printLog("UI.react()", "UI "+name+" entered");
        if (skipRendering==false)render ();
      }
      entered=true;
      if (mouseState==AN_PRESS) {
        pressed=true;
        if (skipRendering==false)render ();
        //printLog ("UI.react ()", "UI "+name+" pressed.");
        disableDescription();
        firstOn=0;
      } else if (mouseState==AN_RELEASE) {
        if (pressed) {//disable enter!
          int tempfocus=focus;
          focus=ID;
          UI[tempfocus].render();
          //printLog("focus", ID+"");
        }
        firstPress=0;
        //printLog("UI.react()", "UI "+name+" released");
        if (skipRendering==false)render ();
      } else if (mouseState==AN_PRESSED) {
        firstPress+=drawInterval;
      }
      if (mousePressed==false&&firstOn>((TextBox)UI[getUIid("I_DESCRIPTIONTIME")]).value) {
        description.move(MouseX, MouseY);
        if (descriptionShowed==false) {
          Description_current=ID;
          Description_enabled=true;
          //Frames[currentFrame].render();
          descriptionShowed=true;
        }
      }
    } else {
      resetFocus();
    }
    if (registerRender) {
      render();
      registerRender=false;
    }
    return true;
  }
  protected void disableDescription() {
    Description_enabled=false;
    description.movable=true;
    if (descriptionShowed) {
      Frames[currentFrame].render();
      skipRendering=true;
    }
    descriptionShowed=false;
  }
  void resetFocus() {
    if (entered==true) {
      //printLog("UI.react()", "UI "+name+" mouse out");
      if (skipRendering==false)render ();
    }
    entered=false;
    firstOn=0;
    firstPress=0;
    if (Description_current==ID) {
      disableDescription();
      Description_current=DEFAULT;
    }
  }
  void render() {
  }
}
protected int getUIid(String name) {
  if (name.equals("")) return 0;
  int a=1;
  while (a<UInames.length) {
    if (name.equals(UInames[a]))return a;
    a=a+1;
  }
  return 0;
  /*int low = 1;
   int high = UInames.length - 1;
   int mid;
   while (low <= high) {
   mid = (low + high) / 2;
   int res = name.compareTo(UInames[mid]);
   if (res < 0) high = mid - 1;
   else if (res > 0) low = mid + 1;
   else return mid;
   }*/
}
int getUIidRev(String name) {//used in wavedit...
  if (name.equals("")) return 0;
  int a=UInames.length-1;
  while (a>0) {
    if (name.equals(UInames[a]))return a;
    a=a-1;
  }
  return 0;
}
protected int getFrameid(String name) {
  if (name.equals("")) return 0;
  if (Framenames==null)return -1;
  int a=1;
  while (a<Framenames.length) {
    if (name.equals(Framenames[a]))return a;
    a=a+1;
  }
  return 0;
}
public interface StateReturner {
  public String getState();
}
public interface SliderUpdater {
  public float getValue();
  public float getMin();
  public float getMax();
  public void setValue(float value);
}
// === shortcuts === //
Shortcut tempShortcut=new Shortcut();
class Shortcut {
  static final int TEXTEDITOR_ONLY=1;
  static final int TEXTEDITOR_EXCEPT=2;
  static final int GLOBAL=0;
  boolean ctrl=false;
  boolean alt=false;
  boolean shift=false;
  int keyn=-1;
  int keyCoden=0;
  int frame=0;
  int textEditor=GLOBAL;
  //
  int ID=0;
  String name="DEFAULT";
  int FunctionId=DEFAULT;
  String modetext="";
  int[] modes=new int[0];
  String text="";//for externals
  String nameextend="";
  Shortcut() {
    name="";
  }
  Shortcut(int ID_, String name_, int FunctionId_, boolean ctrl_, boolean alt_, boolean shift_, int key_, int keyCode_, String textEditor_, int frame_, String mode_, String text_, String nameextend_) {
    ID=ID_;
    name=name_;
    FunctionId=FunctionId_;
    ctrl=ctrl_;
    alt=alt_;
    shift=shift_;
    keyn=key_;
    keyCoden=keyCode_;
    if (textEditor_.equals("true"))textEditor=TEXTEDITOR_ONLY;
    else if (textEditor_.equals("false"))textEditor=TEXTEDITOR_EXCEPT;
    frame=frame_;
    modetext=mode_.trim();
    if (modetext.length()>0) {
      String[] tempmodes=split(modetext, "|");
      modes=new int[tempmodes.length];
      int a=0;
      while (a<tempmodes.length) {
        if (tempmodes[a].equals("AutoInput"))modes[a]=AUTOINPUT;
        else if (tempmodes[a].equals("ManualInput"))modes[a]=MANUALINPUT;
        else if (tempmodes[a].equals("CyxMode"))modes[a]=CYXMODE;
        else modes[a]=-1;
        a=a+1;
      }
    }
    text=text_.replace("\\n", "\n").replace("\\t", "\t").replace("\\r", "\r").replace("\\\\", "\\");
    nameextend=nameextend_;
  }
  boolean isPressed(boolean ctrl_, boolean alt_, boolean shift_, int key_, int keyCode_, boolean shortcutExcept, int frame_) {
    if (keyn==ESC)return false;
    boolean ret=true;
    if (key_!=keyn)ret=false;
    //else if (keyCode_!=keyCoden)ret=false;
    else if (frame!=0&&(frame!=currentFrame))ret=false;
    else if ((textEditor==TEXTEDITOR_ONLY&&shortcutExcept))ret=false;
    else if ((textEditor==TEXTEDITOR_EXCEPT&&shortcutExcept==false))ret=false;
    else if ((ctrl&&ctrl_==false)||(ctrl==false&&ctrl_))ret=false;
    else if ((alt&&alt_==false)||(alt==false&&alt_))ret=false;
    else if ((shift&&shift_==false)||(shift==false&&shift_))ret=false;//key includes shift.
    if (modes.length>0) {
      int a=0;
      boolean pass=false;
      while (a<modes.length) {
        if (modes[a]==Mode)pass=true;
        a=a+1;
      }
      if (pass==false)return false;
    }
    return ret;
  }
  @Override
    String toString() {
    String ret="";
    if (text.equals("")==false)ret+="[p] ";
    if (nameextend.equals(""))ret+=name+"   [";
    else ret+=nameextend+"   [";
    if (ctrl)ret+="Ctrl+";
    if (alt)ret+="Alt+";
    if (shift)ret+="Shift+";
    if (keyn=='\t')ret+="Tab";
    else if (keyn==' ')ret+="Space";
    else if (keyn==ENTER)ret+="Enter";
    else if (keyn==UP)ret+="Up";
    else if (keyn==DOWN)ret+="Down";
    else if (keyn==RIGHT)ret+="Right";
    else if (keyn==LEFT)ret+="Left";
    else if (keyn==BACKSPACE)ret+="Backspace";
    else if (keyn==DELETE)ret+="Delete";
    else if (keyn==ESC)ret+="ESC (None)";
    else if (keyn==CODED)ret+="Coded";
    else ret+=str(char(keyn));
    ret+=" ("+str(int(keyn))+")] ";
    ret+=text.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r");
    return ret+"   ";
  }
  String toXmlString() {
    String texteditor="neutral";
    if (textEditor==TEXTEDITOR_ONLY)texteditor="true";
    else if (textEditor==TEXTEDITOR_EXCEPT)texteditor="false";
    String desc="";
    if (nameextend.equals("")==false)desc=" description=\""+nameextend+"\"";
    if (FunctionId==S_EXTERNAL) {
      //<external id="33" ctrl="false" shift="false" alt="false" key="1" keycode="0" textEditor="false" mode="ManualInput" text="\on">On</external>
      return "  <external id=\""+ID+"\" ctrl=\""+str(ctrl)+"\" shift=\""+str(shift)+"\" alt=\""+str(alt)+"\" key=\""+keyn+"\" keycode=\""+keyCoden+"\" textEditor=\""+texteditor+"\" mode=\""+modetext+"\" text=\""+text.replace("\\", "\\\\").replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r")+"\""+desc+">"+name+"</external>";
    } else {
      //<internal id="1" ctrl="true" shift="false" alt="false" key="97" keycode="0" frame="0" textEditor="true">SelectAll</internal>
      return "  <internal id=\""+ID+"\" ctrl=\""+str(ctrl)+"\" shift=\""+str(shift)+"\" alt=\""+str(alt)+"\" key=\""+keyn+"\" keycode=\""+keyCoden+"\" frame=\""+frame+"\" textEditor=\""+texteditor+"\""+desc+">"+name+"</internal>";
    }
  }
}
void setShortcutData() {
  int a=1;
  ArrayList<String> items=new ArrayList<String>();
  while (a<Shortcuts.length) {
    items.add(Shortcuts[a].toString());
    a=a+1;
  }
  ((ScrollList)UI[getUIid("I_SHORTCUTS")]).setItems(items.toArray(new String[0]));
}
void setUIcolorsData() {
  int a=1;
  ArrayList<String> items=new ArrayList<String>();
  while (a<UIcolors.length) {
    items.add(UIcolornames[a]+" : ");
    a=a+1;
  }
  ((ScrollList)UI[getUIid("I_UICOLORS")]).setItems(items.toArray(new String[0]));
}