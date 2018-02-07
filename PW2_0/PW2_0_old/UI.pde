 //<>//
void UI_setup() {
  ((Button)UI[getUIid("I_PATH")]).text=GlobalPath;
  //
  converter.converterPlayer.assign((Slider)UI[getUIid("MP3_PROGRESSBAR")], (Label)UI[getUIid("MP3_TIME")]);
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
  maskImages(UIcolors[I_BACKGROUND]);
}