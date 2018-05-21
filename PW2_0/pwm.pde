import antlr.Token;
import java.io.ByteArrayInputStream;
import java.io.PrintStream;
import pw2.macro.*;
public static class PW2_0Param {
  public PW2_0 sketch;
  public String tab;//I originally passed MacroTab here, but It seems it is unsafe. instead if that, send macro's name to identify it.
  public PrintStream console;
  public InputStream input;
  public String param;
  public PW2_0Param(PW2_0 sketch_, String tab_, PrintStream console_, InputStream input_, String param_) {
    sketch=sketch_;
    tab=tab_;
    console=console_;
    input=input_;
    param=param_;
  }
}
void macro_setup() {
  ((TabLayout)KyUI.get("m_filetabs")).tabSelectListener=new ItemSelectListener() {
    public void onEvent(int index) {
      selectMacroTab(index-1);
    }
  };
  ((TabLayout)KyUI.get("m_filetabs")).tabRemoveListener=new ItemSelectListener() {
    public void onEvent(int index) {
      macroTabs.remove(index);
      if (macroTabs.size()==0) {
        //instead of adding new tab, just set current to null. it can be done becauase waveditor has no extra sharing state.
        selectMacroTab(-1);
      }
      macro_filetabs.localLayout();
    }
  };
  ((TabLayout)KyUI.get("m_filetabs")).addTabListener=new EventListener() {
    public void onEvent(Element e) {
      addMacroTab(createNewMacro());
    }
  };
  ((ImageToggleButton)KyUI.get("m_findreplace")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      KyUI.get("m_dv5").setEnabled(((ImageToggleButton)KyUI.get("m_findreplace")).value);
      KyUI.get("m_dv3").localLayout();
      return false;
    }
  }
  );
  //((ImageButton)KyUI.get("m_stop")).setPressListener(new MouseEventListener() {
  //  public boolean onEvent(MouseEvent e, int index) {
  //    //you can't do anything!! don't use thread.stop().
  //    return false;
  //  }
  //}
  //);
  final TextBox changetitle_edit=((TextBox)KyUI.get("changetitle_edit"));
  final ImageButton changetitle_exit=((ImageButton)KyUI.get("changetitle_exit"));
  ((ImageButton)KyUI.get("m_changetitle")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      if (currentMacro==null) {
        return false;
      }
      externalFrame=MACRO_CHANGETITLE;
      KyUI.addLayer(frame_changetitle);
      changetitle_edit.setText(getFileName(currentMacro.file.getAbsolutePath()));
      final String before=currentMacro.file.getAbsolutePath();
      changetitle_edit.onTextChangeListener=new EventListener() {
        public void onEvent(Element e) {
          String text=changetitle_edit.getText();
          boolean er=!isValidFileName(text);
          if (text.contains("/")||text.contains("\\")||text.contains(" ")) {
            er=true;
          }
          File[] files=new File(joinPath(path_global, path_macro)).listFiles();
          text=getExtensionElse(text);
          for (File f : files) {//anti duplication
            if (getExtensionElse(getFileName(f.getAbsolutePath())).equals(text)) {
              er=true;
              break;
            }
          }
          changetitle_edit.error=er;
        }
      };
      changetitle_exit.setPressListener(new MouseEventListener() {
        public boolean onEvent(MouseEvent e, int index) {
          if (!changetitle_edit.error) {
            String text=changetitle_edit.getText();
            currentMacro.file=new File(joinPath(path_global, path_macro+"/"+getExtensionElse(text)+"/"+text));
            String after=currentMacro.file.getAbsolutePath();
            if (!before.equals(after)) {
              if (!currentMacro.file.isFile()&&currentMacro.editor.script.empty()) {
                currentMacro.setChanged(false, true);
              } else {
                currentMacro.setChanged(true, true);
              }
            }
            KyUI.removeLayer();
            externalFrame=NONE;
          }
          return false;
        }
      }
      );
      return false;
    }
  }
  );
  ((ImageButton)KyUI.get("m_run")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      if (currentMacro==null) {
        return false;
      }
      final CommandEdit editor=currentMacro.editor;
      if (editor.getText().isEmpty()) {//not null
        return false;
      }
      final MacroTab macro=currentMacro;
      final String[] paths=getClassPaths();
      final ConsoleInputStream input=macro.newInputStream();
      final PrintStream stream=macro.newPrintStream(input);
      new Thread(new Runnable() {
        public void run() {
          //println((Object[])paths);
          try {//you not have to save before run, really.
            saveMacro(macro);//save first.
          }
          catch(Exception e) {
          }
          try {
            //default run with no paramters
            PwMacroRun.run(PwMacroApi.class, macro.getTitle(), macro.getText(), new PW2_0Param(PW2_0.this, macro.file.getAbsolutePath(), stream, input, ""), stream, macro.getBuildPath(), paths, true);//so build path is parent/src and bin.        
            stream.close();
            macro.onMacroEnd();
          }
          catch(Exception ee) {
            ee.printStackTrace();//here comes script errors.
            //ADD redirect to coe.
          }
        }
      }
      ).start();
      return false;
    }
  }
  );
  final Slider ratio=((Slider)KyUI.get("m_ratio"));
  ratio.setMin(0);
  ratio.setMax(1);
  ratio.setAdjustListener(new EventListener() {
    public void onEvent(Element e) {
      if (currentMacro!=null) {
        final DivisionLayout m_dv=((DivisionLayout)currentMacro.editor.parents.get(0).parents.get(0));
        m_dv.value=1-ratio.value;
        m_dv.localLayout();
      }
    }
  }
  );
}
public class ConsoleInputStream extends InputStream {
  StringBuilder buffer=new StringBuilder();//commands go into here. and clear on print.
  public int available() {
    if (buffer==null) {
      return 0;
    }
    return buffer.length();
  }
  public int read() {
    if (buffer==null) {
      return -1;
    }
    //println("blocked...");
    while (buffer.length()==0) {
      try {
        Thread.sleep(1);
      }
      catch(InterruptedException e) {
      }
      //return 0;
    }
    char ret=buffer.charAt(0);
    print("returned "+ret);
    buffer.delete(0, 1);
    println(" /size : "+buffer.length());
    return ret;
  }
  public void clear() {
    if (buffer!=null&&buffer.length()>0) {
      buffer=new StringBuilder();
    }
  }
  public void close() {
    buffer=null;
  }
}
public class MacroTab {
  File file;
  CommandEdit editor;//nullable.
  ConsoleEdit console;
  boolean changed=false;
  long lastSaveTime=System.currentTimeMillis();
  private boolean tabchanged=false;
  Consumer<String> originalCommandProcessor;
  MacroTab(String name, CommandEdit editor_, ConsoleEdit console_) {
    file=new File(name);
    editor=editor_;
    console=console_;
  }
  MacroTab(String name, ConsoleEdit console_) {
    file=new File(name);
    console=console_;
  }
  PrintStream newPrintStream(final ConsoleInputStream input) {
    return new PrintStream(new OutputStream() {
      public void write(int b) throws IOException {
        if (b=='\n') {
          console.addLine("");
        } else {
          console.insert(((Object)((char)b)).toString());
        }
        //if (input!=null) {
        //  input.clear();
        //}
        console.invalidate();
      }
    }
    );
  }
  ConsoleInputStream newInputStream() {
    if (originalCommandProcessor==null) {
      originalCommandProcessor=console.processor;
    }
    final ConsoleInputStream input=new ConsoleInputStream();
    console.processor=new Consumer<String>() {
      public void accept(String s) {
        if (input.buffer!=null) {
          input.buffer.append(s);
          input.buffer.append('\n');
        }
      }
    };
    return input;
  }
  void onMacroEnd() {//close not do anything...?
    console.processor=originalCommandProcessor;
    originalCommandProcessor=null;
  }
  String getTitle() {
    return getExtensionElse(getFileName(file.getAbsolutePath()));
  }
  String getText() {
    if (editor==null) {
      return readFile(file.getAbsolutePath());
    } else {
      return editor.getText();
    }
  }
  void setChanged(boolean v, boolean force) {
    if (v) {
      if (!tabchanged||force) {
        int index=macroTabs.indexOf(this);
        if (index>=0) {
          macro_filetabs.setTabName(index, getFileName(file.getAbsolutePath())+"*");
        }
        tabchanged=true;
        macro_filetabs.invalidate();
      }
      changed=true;
    } else {
      if (tabchanged||force) {
        int index=macroTabs.indexOf(this);
        if (index>=0) {
          macro_filetabs.setTabName(index, getFileName(file.getAbsolutePath()));
        }
        tabchanged=false;
        macro_filetabs.invalidate();
      }
      changed=false;
    }
  }
  String getBuildPath() {
    return  file.getParentFile().getAbsolutePath();
  }
  String getClassPath() {
    return joinPath(file.getParentFile().getAbsolutePath(), "bin");
  }
}
MacroTab addMacroTab(final String filename) {//no null filename!
  TabLayout tabs=((TabLayout)KyUI.get("m_filetabs"));
  Element e=tabs.addTabFromXmlPath(getFileName(filename), layout_m_frame_xml, "layout_m_frame.xml", null);
  KyUI.taskManager.executeAll();//add elements
  final CommandEdit editor=(CommandEdit)e.children.get(0).children.get(0).children.get(0);
  final ConsoleEdit console=(ConsoleEdit)e.children.get(0).children.get(1).children.get(0);
  ui_attachSlider(editor);
  ui_attachSlider(console);
  editor.textFont=KyUI.fontMain;
  editor.commentEnabled=false;
  editor.textRenderer=new PwHighlighter(editor, PwMacroApi.class);
  final MacroTab tab=new MacroTab(filename, editor, console);
  console.textSize=15;//??
  macroTabs.add(tab);
  tabs.onLayout();
  tabs.onLayout();//?? again,
  KyUI.get("m_frame").onLayout();
  tabs.selectTab(macroTabs.size());
  editor.setTextChangeListener(new EventListener() {
    public void onEvent(Element e) {
      //ADD get errors!! and...
      tab.setChanged(true, false);
    }
  }
  );
  editor.keyEventPost=new BiConsumer<TextEdit, KeyEvent>() {// some code for auto indent/dedent
    public void accept(TextEdit edit_, KeyEvent e) {
      CommandEdit edit=(CommandEdit)edit_;
      if (edit.script.line-1>=0&&edit.script.line-1<edit.script.lines()) {
        if (e.getKey()=='\n') {
          if (edit.getLine(edit.script.line-1).endsWith("{")) {
            edit.script.insert("  ");
            edit.script.point+=2;
          } else {
            String line=edit.getLine(edit.script.line-1);
            int count=0;
            for (count=0; count<line.length(); count++) {
              if (line.charAt(count)!=' ') {
                break;
              }
            }
            if (count>0) {
              String insert="";
              for (int a=0; a<count; a++) {
                insert=insert+" ";
              }
              edit.script.insert(insert);
              edit.script.point+=insert.length();
            }
          }
        } else if (e.getKey()=='}') {//dedent 2
          String line=edit.getLine(edit.script.line);
          if (line.endsWith("  }")) {
            edit.script.delete(edit.script.line, edit.script.point-3, edit.script.line, edit.script.point);
            edit.script.point=edit.script.point-3;
            edit.script.insert("}");
            edit.script.point=edit.script.point+1;
          }
        }
      }
    }
  };
  return tab;
}
void addMacroFileTab(String filename) {
  for (int a=0; a<macroTabs.size(); a++) {//anti duplication
    MacroTab t=macroTabs.get(a);
    if (t.file.equals(new File(filename))) {
      ((TabLayout)KyUI.get("m_filetabs")).selectTab(a+1);
      return;
    }
  }
  MacroTab tab=addMacroTab(filename);
  tab.editor.insert(0, 0, readLed(filename));
  tab.setChanged(false, false);
}
void selectMacroTab(int index) {
  if (index<0||index>=macroTabs.size()) {
    currentMacro=null;
    //KyUI.get("m_text").setEnabled(true);
  } else {
    currentMacro=macroTabs.get(index);
    Slider ratio=((Slider)KyUI.get("m_ratio"));
    ratio.set(1-((DivisionLayout)currentMacro.editor.parents.get(0).parents.get(0)).value);
  }
  KyUI.get("m_dv4").localLayout();
}
void saveMacro(final MacroTab macro) { 
  if (macro.changed) {
    final String filename=macro.file.getAbsolutePath();
    saveFileTo(filename, new Runnable() {
      public void run() {
        writeFile(filename, macro.editor.getText());
      }
    }
    );
    macro.setChanged(false, false);
    macro.lastSaveTime=new File(filename).lastModified();
  }
}
// default presets :
// - mc converter with gui
// - remove unitor commands
//- api : led utils
public static class PwMacroApi extends PwMacro {
  protected PW2_0 __parent;//you can['t] use it...
  protected PrintStream out;
  protected InputStream in;
  public String name;//this is originlly "__this".
  public String param;
  //private vars are not part of api.
  public class Led {
    LedScript led;
    public Led(LedScript led_) {
      led=led_;
    }
  }
  //you can do no constructor
  @Override
    public final void initialize(Object param) {
    __parent=((PW2_0Param)param).sketch;
    out=((PW2_0Param)param).console;
    in=((PW2_0Param)param).input;
    name=((PW2_0Param)param).tab;
    this.param=((PW2_0Param)param).param;
  }
  @Override
    public void exit() {
    try {
      in.close();
    }
    catch(IOException e) {
    }
  }
  public void println(Object o) {
    out.println(o);
  }
  public void print(Object o) {
    out.print(o);
  }
  public void writeFile(String path, String text) {
    __parent.writeFile(path, text);
  }
  public String readFile(String path) {
    return __parent.readFile(path);
  }
  public Led led(String text) {
    return new Led(__parent.loadLedScript(__parent.createNewLed(), text));
  }
  public void send(MidiDevice device, byte note, byte vel) {
    //device.sendMessage();
  }
}