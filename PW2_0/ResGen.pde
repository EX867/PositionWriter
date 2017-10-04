void generateSettings() {
  String text="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n";
  text+="  <I_AUTOSAVE value=\""+str(((Button)UI[getUIid("I_AUTOSAVE")]).value)+"\"></I_AUTOSAVE>\n";
  text+="  <I_AUTOSAVETIME value=\""+((TextBox)UI[getUIid("I_AUTOSAVETIME")]).value+"\"></I_AUTOSAVETIME>\n";
  text+="  <I_RESOLUTION value=\""+((Slider)UI[getUIid("I_RESOLUTION")]).valueF+"\"></I_RESOLUTION>\n";
  text+="  <I_RELOADINSTART value=\""+str(((Button)UI[getUIid("I_RELOADINSTART")]).value)+"\"></I_RELOADINSTART>\n";
  text+="  <I_TEXTSIZE value=\""+((TextBox)UI[getUIid("I_TEXTSIZE")]).value+"\"></I_TEXTSIZE>\n";
  text+="  <I_STARTFROM value=\""+str(((Button)UI[getUIid("I_STARTFROM")]).value)+"\"></I_STARTFROM>\n";
  text+="  <I_AUTOSTOP value=\""+str(((Button)UI[getUIid("I_AUTOSTOP")]).value)+"\"></I_AUTOSTOP>\n";
  text+="  <I_DEFAULTINPUT value=\""+str(((Button)UI[getUIid("I_DEFAULTINPUT")]).value)+"\"></I_DEFAULTINPUT>\n";
  text+="  <I_OLDINPUT value=\""+str(((Button)UI[getUIid("I_OLDINPUT")]).value)+"\"></I_OLDINPUT>\n";
  text+="  <I_RIGHTOFFMODE value=\""+str(((Button)UI[getUIid("I_RIGHTOFFMODE")]).value)+"\"></I_RIGHTOFFMODE>\n";
  text+="  <I_CYXMODE value=\""+str(((Button)UI[getUIid("I_CYXMODE")]).value)+"\"></I_CYXMODE>\n";
  text+="  <I_LANGUAGE value=\""+((DropDown)UI[getUIid("I_LANGUAGE")]).selection+"\"></I_LANGUAGE>\n";
  text+="  <I_DESCRIPTIONTIME value=\""+((TextBox)UI[getUIid("I_DESCRIPTIONTIME")]).value+"\"></I_DESCRIPTIONTIME>\n";
  text+="  <I_IGNOREMC value=\""+str(((Button)UI[getUIid("I_IGNOREMC")]).value)+"\"></I_IGNOREMC>\n";
  boolean lastloadled=((Button)UI[getUIid("I_RELOADINSTART")]).value;
  boolean lastloadkeySound=lastloadled;
  if (loadedOnce_led==false)lastloadled=false;
  if (loadedOnce_keySound==false)lastloadkeySound=false;
  if (currentFrame==1)title_keyledfilename=title_filename;
  else if (currentFrame==2)title_keysoundfoldername=title_filename;
  if (lastloadled)text+="  <keyLED load=\"true\">"+title_keyledfilename+"</keyLED>\n";
  else text+="  <keyLED load=\"false\"></keyLED>\n";
  if (lastloadkeySound)text+="  <keySound load=\"true\">"+title_keysoundfoldername+"</keySound>\n";
  else text+="  <keySound load=\"false\"></keySound>";
  text+="</Data>";
  try {
    writeFile("data/Settings.xml", text);
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
void generateShortcuts() {
  String text="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n";
  int a=1;
  while (a<Shortcuts.length) {
    text+=Shortcuts[a].toXmlString()+"\n";
    a=a+1;
  }
  text+="</Data>";
  try {
    writeFile("data/Shortcuts.xml", text);
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
void generateColors() {
  String text="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n";
  text+="  <element id=\"0\" a=\"255\" r=\"255\" g=\"255\" b=\"255\">DEFAULT</element>\n";
  text+="  <element id=\"1\" a=\""+alpha(UIcolors[I_BACKGROUND])+"\" r=\""+red(UIcolors[I_BACKGROUND])+"\" g=\""+green(UIcolors[I_BACKGROUND])+"\" b=\""+blue(UIcolors[I_BACKGROUND])+"\">I_BACKGROUND</element>\n";
  text+="  <element id=\"2\" a=\""+alpha(UIcolors[I_FOREGROUND])+"\" r=\""+red(UIcolors[I_FOREGROUND])+"\" g=\""+green(UIcolors[I_FOREGROUND])+"\" b=\""+blue(UIcolors[I_FOREGROUND])+"\">I_FOREGROUND</element>\n";
  text+="  <element id=\"3\" a=\""+alpha(UIcolors[I_TABCOLOR])+"\" r=\""+red(UIcolors[I_TABCOLOR])+"\" g=\""+green(UIcolors[I_TABCOLOR])+"\" b=\""+blue(UIcolors[I_TABCOLOR])+"\">I_TABCOLOR</element>\n";
  text+="  <element id=\"4\" a=\""+alpha(UIcolors[I_TEXTBACKGROUND])+"\" r=\""+red(UIcolors[I_TEXTBACKGROUND])+"\" g=\""+green(UIcolors[I_TEXTBACKGROUND])+"\" b=\""+blue(UIcolors[I_TEXTBACKGROUND])+"\">I_TEXTBACKGROUND</element>\n";
  text+="  <element id=\"5\" a=\""+alpha(UIcolors[I_TEXTCOLOR])+"\" r=\""+red(UIcolors[I_TEXTCOLOR])+"\" g=\""+green(UIcolors[I_TEXTCOLOR])+"\" b=\""+blue(UIcolors[I_TEXTCOLOR])+"\">I_TEXTCOLOR</element>\n";
  text+="  <element id=\"6\" a=\""+alpha(UIcolors[I_PADBACKGROUND])+"\" r=\""+red(UIcolors[I_PADBACKGROUND])+"\" g=\""+green(UIcolors[I_PADBACKGROUND])+"\" b=\""+blue(UIcolors[I_PADBACKGROUND])+"\">I_PADBACKGROUND</element>\n";
  text+="  <element id=\"7\" a=\""+alpha(UIcolors[I_PADFOREGROUND])+"\" r=\""+red(UIcolors[I_PADFOREGROUND])+"\" g=\""+green(UIcolors[I_PADFOREGROUND])+"\" b=\""+blue(UIcolors[I_PADFOREGROUND])+"\">I_PADFOREGROUND</element>\n";
  text+="  <element id=\"8\" a=\""+alpha(UIcolors[I_PADCHAIN])+"\" r=\""+red(UIcolors[I_PADCHAIN])+"\" g=\""+green(UIcolors[I_PADCHAIN])+"\" b=\""+blue(UIcolors[I_PADCHAIN])+"\">I_PADCHAIN</element>\n";
  text+="  <element id=\"9\" a=\""+alpha(UIcolors[I_TABC1])+"\" r=\""+red(UIcolors[I_TABC1])+"\" g=\""+green(UIcolors[I_TABC1])+"\" b=\""+blue(UIcolors[I_TABC1])+"\">I_TABC1</element>\n";
  text+="  <element id=\"10\" a=\""+alpha(UIcolors[I_TABC2])+"\" r=\""+red(UIcolors[I_TABC2])+"\" g=\""+green(UIcolors[I_TABC2])+"\" b=\""+blue(UIcolors[I_TABC2])+"\">I_TABC2</element>\n";
  text+="  <element id=\"11\" a=\""+alpha(UIcolors[I_TEXTBOXSELECTION])+"\" r=\""+red(UIcolors[I_TEXTBOXSELECTION])+"\" g=\""+green(UIcolors[I_TEXTBOXSELECTION])+"\" b=\""+blue(UIcolors[I_TEXTBOXSELECTION])+"\">I_TEXTBOXSELECTION</element>\n";
  text+="  <element id=\"12\" a=\""+alpha(UIcolors[I_GENERALTEXT])+"\" r=\""+red(UIcolors[I_GENERALTEXT])+"\" g=\""+green(UIcolors[I_GENERALTEXT])+"\" b=\""+blue(UIcolors[I_GENERALTEXT])+"\">I_GENERALTEXT</element>\n";
  text+="  <element id=\"13\" a=\""+alpha(UIcolors[I_KEYWORDTEXT])+"\" r=\""+red(UIcolors[I_KEYWORDTEXT])+"\" g=\""+green(UIcolors[I_KEYWORDTEXT])+"\" b=\""+blue(UIcolors[I_KEYWORDTEXT])+"\">I_KEYWORDTEXT</element>\n";
  text+="  <element id=\"14\" a=\""+alpha(UIcolors[I_COMMENTTEXT])+"\" r=\""+red(UIcolors[I_COMMENTTEXT])+"\" g=\""+green(UIcolors[I_COMMENTTEXT])+"\" b=\""+blue(UIcolors[I_COMMENTTEXT])+"\">I_COMMENTTEXT</element>\n";
  text+="  <element id=\"15\" a=\""+alpha(UIcolors[I_UNITORTEXT])+"\" r=\""+red(UIcolors[I_UNITORTEXT])+"\" g=\""+green(UIcolors[I_UNITORTEXT])+"\" b=\""+blue(UIcolors[I_UNITORTEXT])+"\">I_UNITORTEXT</element>\n";
  text+="  <element id=\"16\" a=\""+alpha(UIcolors[I_OVERLAY])+"\" r=\""+red(UIcolors[I_OVERLAY])+"\" g=\""+green(UIcolors[I_OVERLAY])+"\" b=\""+blue(UIcolors[I_OVERLAY])+"\">I_OVERLAY</element>\n";
  text+="  <element id=\"17\" a=\""+alpha(UIcolors[I_UNITORTEXT2])+"\" r=\""+red(UIcolors[I_UNITORTEXT2])+"\" g=\""+green(UIcolors[I_UNITORTEXT2])+"\" b=\""+blue(UIcolors[I_UNITORTEXT2])+"\">I_UNITORTEXT2</element>\n";
  text+="  <element id=\"18\" a=\""+alpha(UIcolors[I_TABC3])+"\" r=\""+red(UIcolors[I_TABC3])+"\" g=\""+green(UIcolors[I_TABC3])+"\" b=\""+blue(UIcolors[I_TABC3])+"\">I_TABC3</element>\n";
  text+="</Data>";
  try {
    writeFile("data/Colors.xml", text);
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}