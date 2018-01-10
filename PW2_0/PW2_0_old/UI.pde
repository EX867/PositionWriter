 //<>//
void UI_setup() {
  UI_load();
  setShortcutData();
  setUIcolorsData();
  selectedColorType=DS_VEL;
  ((Button)UI[getUIid("I_PATH")]).text=GlobalPath;
  autoSave=((Button)UI[getUIid("I_AUTOSAVE")]).value;
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
    ((ScrollList)UI[getUIid("MP3_CODEC")]).setItems((String[])new it.sauronsoftware.jave.Encoder().getAudioEncoders());
    ((ScrollList)UI[getUIid("MP3_FORMAT")]).setItems((String[])new it.sauronsoftware.jave.Encoder().getSupportedEncodingFormats());
    ((Button)UI[getUIid("INITIAL_HOWTOUSE")]).text=readFile("versionText");
  }
  catch(Exception e) {
  }
  //
  skinEditor=(SkinEditView)UI[getUIidRev("SKIN_EDIT")];
  skinEditor.setComponents((TextBox)UI[getUIidRev("SKIN_PACKAGE")], (TextBox)UI[getUIidRev("SKIN_TITLE")], (TextBox)UI[getUIidRev("SKIN_AUTHOR")], (TextBox)UI[getUIidRev("SKIN_DESCRIPTION")], (TextBox)UI[getUIidRev("SKIN_APPNAME")], (Button)UI[getUIidRev("SKIN_TEXT1")]);
  // === Custom settings load === //
  loadCustomSettings("");
  maskImages(UIcolors[I_BACKGROUND]);
  //---
  Frames[currentFrame].prepare();
}
void loadCustomSettings(String customPath) {
  String datapath=getDataPath();
  if (customPath.equals("")&&new File(joinPath(datapath, "Settings.xml")).exists()==false) {
    //change totally initial(first launch) scale to initialScale on here...
    ((Slider)UI[getUIid("I_RESOLUTION")]).valueF=initialScale;
    scale=initialScale;
    surface.setSize(floor(initialWidth*scale), floor(initialHeight*scale));
    setSize(floor(initialWidth*scale), floor(initialHeight*scale));
    popMatrix();
    popMatrix();
    pushMatrix();
    scale(scale);
    pushMatrix();
    registerRender();
    return;
  }
  XML XmlData;
  if (customPath.equals(""))XmlData=loadXML("Settings.xml");
  else XmlData=loadXML(customPath);
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
    surface.setSize(floor(initialWidth*scale), floor(initialHeight*scale));
    setSize(floor(initialWidth*scale), floor(initialHeight*scale));
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
  Data=XmlData.getChild("I_CYXMODE");
  if (Data!=null) {
    ((Button)UI[getUIid("I_CYXMODE")]).value=toBoolean(Data.getString("value"));
    if (toBoolean(Data.getString("value"))==true) {//FIX!!!
    }
  }
  Data=XmlData.getChild("I_OLDINPUT");
  if (Data!=null) {
    ((Button)UI[getUIid("I_OLDINPUT")]).value=toBoolean(Data.getString("value"));
    if (toBoolean(Data.getString("value"))==true) {
    }
  }
  Data=XmlData.getChild("I_RIGHTOFFMODE");
  if (Data!=null) {
    ((Button)UI[getUIid("I_RIGHTOFFMODE")]).value=toBoolean(Data.getString("value"));
    if (toBoolean(Data.getString("value"))==true) {
    }
  }
  Data=XmlData.getChild("I_DEFAULTINPUT");
  if (Data!=null) {
    ((Button)UI[getUIid("I_DEFAULTINPUT")]).value=toBoolean(Data.getString("value"));//default
    if (toBoolean(Data.getString("value"))==true) {
      Mode=AUTOINPUT;
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
    ignoreMc=toBoolean(Data.getString("value"));
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