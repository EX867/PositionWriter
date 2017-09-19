static final long SAMPLEWAV_MAX_SIZE=(long)1024*1024*200;
static final int SAMPLE_RATE=44100;
static final color OFFCOLOR=0;
static final float DEFAULT_BPM=120;
static final int DEFAULT=0;

static final int AUTOINPUT=1;
static final int MANUALINPUT=2;
static final int RIGHTOFFMODE=4;
static final int CYXMODE=3;

static final int I_SAVE=1;
static final int I_UNDO=2;
static final int I_REDO=3;

//
static final int I_BACKGROUND=1;
static final int I_FOREGROUND=2;
static final int I_TABCOLOR=3;
static final int I_TEXTBACKGROUND=4;
static final int I_TEXTCOLOR=5;
static final int I_PADBACKGROUND=6;
static final int I_PADFOREGROUND=7;
static final int I_PADCHAIN=8;
static final int I_TABC1=9;
static final int I_TABC2=10;
//add text highlight
static final int I_TEXTBOXSELECTION=11;
static final int I_GENERALTEXT=12;
static final int I_KEYWORDTEXT=13;
static final int I_COMMENTTEXT=14;
static final int I_UNITORTEXT=15;
static final int I_OVERLAY=16;

// ========== Others ==========//
static final int AN_PRESS=0;
static final int AN_PRESSED=1;
static final int AN_RELEASE=2;
static final int AN_RELEASED=3;

static final int DS_VEL=1;
static final int DS_HTML=2;

static final int TYPE_BUTTON=1;
static final int TYPE_LABEL=2;
static final int TYPE_DROPDOWN=3;
static final int TYPE_SLIDER=4;
static final int TYPE_DRAGSLIDER=14;
static final int TYPE_TEXTBOX=5;
static final int TYPE_SCROLLLIST=6;
static final int TYPE_TEXTEDITOR=7;
static final int TYPE_COLORPICKER=11;
static final int TYPE_PADBUTTON=9;
static final int TYPE_VELOCITYBUTTON=10;
static final int TYPE_WAVEDITOR=12;
static final int TYPE_VISUALIZER=13;
static final int TYPE_LOGGER=15;
static final int TYPE_INFOVIEWER=16;
//total 15
//...class
//add

//functions
int getTypeId (String in) {
  if (in.equals("TYPE_BUTTON")) {
    return TYPE_BUTTON;
  } else if (in.equals("TYPE_LABEL")) {
    return TYPE_LABEL;
  } else if (in.equals("TYPE_DROPDOWN")) {
    return TYPE_DROPDOWN;
  } else if (in.equals("TYPE_SLIDER")) {
    return TYPE_SLIDER;
  } else if (in.equals("TYPE_DRAGSLIDER")) {
    return TYPE_DRAGSLIDER;
  } else if (in.equals("TYPE_TEXTBOX")) {
    return TYPE_TEXTBOX;
  } else if (in.equals("TYPE_SCROLLLIST")) {
    return TYPE_SCROLLLIST;
  } else if (in.equals("TYPE_TEXTEDITOR")) {
    return TYPE_TEXTEDITOR;
  } else if (in.equals("TYPE_COLORPICKER")) {
    return TYPE_COLORPICKER;
  } else if (in.equals("TYPE_PADBUTTON")) {
    return TYPE_PADBUTTON;
  } else if (in.equals("TYPE_VELOCITYBUTTON")) {
    return TYPE_VELOCITYBUTTON;
  } else if (in.equals("TYPE_WAVEDITOR")) {
    return TYPE_WAVEDITOR;
  } else if (in.equals("TYPE_VISUALIZER")) {
    return TYPE_VISUALIZER;
  } else if (in.equals("TYPE_LOGGER")) {
    return TYPE_LOGGER;
  } else if (in.equals("TYPE_INFOVIEWER")) {
    return TYPE_INFOVIEWER;
  }
  return DEFAULT;
}

static final int S_SELECTALL=1;
static final int S_COPY=2;
static final int S_CUT=3;
static final int S_PASTE=4;
static final int S_UNDO=5;
static final int S_REDO=6;
static final int S_REGISTERQ=7;
static final int S_REGISTERE=8;
static final int S_SAVE=9;
static final int S_EXPORT=10;
static final int S_TRANSPORTL=11;
static final int S_TRANSPORTR=12;
static final int S_PLAY=13;
static final int S_REWIND=14;
static final int S_STOP=15;
static final int S_LOOP=16;
static final int S_OPENFIND=17;
static final int S_RESETFOCUS=18;
static final int S_PRINTQ=19;
static final int S_PRINTE=20;
static final int S_STARTFROMCURSOR=21;
static final int S_AUTOSTOP=22;
static final int S_AUTOINPUTUP=23;
static final int S_AUTOINPUTDOWN=24;
static final int S_AUTOINPUTRIGHT=25;
static final int S_AUTOINPUTLEFT=26;
static final int S_KEYSOUNDCLEAR=27;
static final int S_EXTERNAL=28;
int getFunctionId(String name) {
  if (name.equals("SelectAll"))return S_SELECTALL;
  else if (name.equals("Copy"))return S_COPY;
  else if (name.equals("Cut"))return S_CUT;
  else if (name.equals("Paste"))return S_PASTE;
  else if (name.equals("Undo"))return S_UNDO;
  else if (name.equals("Redo"))return S_REDO;
  else if (name.equals("RegisterQ"))return S_REGISTERQ;
  else if (name.equals("RegisterE"))return S_REGISTERE;
  else if (name.equals("Save"))return S_SAVE;
  else if (name.equals("Export"))return S_EXPORT;
  else if (name.equals("TransportL"))return S_TRANSPORTL;
  else if (name.equals("TransportR"))return S_TRANSPORTR;
  else if (name.equals("Play"))return S_PLAY;
  else if (name.equals("Rewind"))return S_REWIND;
  else if (name.equals("Stop"))return S_STOP;
  else if (name.equals("Loop"))return S_LOOP;
  else if (name.equals("OpenFind"))return S_OPENFIND;
  else if (name.equals("ResetFocus"))return S_RESETFOCUS;
  else if (name.equals("PrintQ"))return S_PRINTQ;
  else if (name.equals("PrintE"))return S_PRINTE;
  else if (name.equals("StartFromCursor"))return S_STARTFROMCURSOR;
  else if (name.equals("AutoStop"))return S_AUTOSTOP;
  else if (name.equals("AutoInputUp"))return S_AUTOINPUTUP;
  else if (name.equals("AutoInputDown"))return S_AUTOINPUTDOWN;
  else if (name.equals("AutoInputRight"))return S_AUTOINPUTRIGHT;
  else if (name.equals("AutoInputLeft"))return S_AUTOINPUTLEFT;
  else if (name.equals("KeySoundClear"))return S_KEYSOUNDCLEAR;
  else return DEFAULT;
}
static final int DIALOG_UPLOAD=1;
static final int DIALOG_UPDATE=2;
static final int DIALOG_DELETE=3;
static final int DIALOG_DOWNLOAD=4;