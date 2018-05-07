import antlr.Token;
import java.io.ByteArrayInputStream;
import java.io.PrintStream;
import pw2.macro.*;
public static class PW2_0Param {
  public PW2_0 sketch;
  public String tab;//I originally passed MacroTab here, but It seems it is unsafe. instead if that, send macro's name to identify it.
  public PrintStream console;
  public PW2_0Param(PW2_0 sketch_, String tab_, PrintStream console_) {
    sketch=sketch_;
    tab=tab_;
    console=console_;
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
  ((ImageButton)KyUI.get("m_run")).setPressListener(new MouseEventListener() {
    public boolean onEvent(MouseEvent e, int index) {
      final CommandEdit editor=currentMacro.editor;
      if (editor.getText().isEmpty()) {
        return false;
      }
      final ConsoleEdit console=currentMacro.console;
      final MacroTab macro=currentMacro;
      final PrintStream stream=new PrintStream(new OutputStream() {
        public void write(int b) throws IOException {
          if (b=='\n') {
            console.addLine("");
          } else {
            console.insert(((Object)((char)b)).toString());
          }
          console.invalidate();
        }
      }
      );
      final String[] paths=getClassPaths();
      new Thread(new Runnable() {
        public void run() {
          //println((Object[])paths);
          try {//you not have to save before run, really.
            saveMacro(macro);//save first.
          }
          catch(Exception e) {
          }
          try {
            PwMacroRun.run(PwMacroApi.class, "NewMacro", editor.getText(), new PW2_0Param(PW2_0.this, macro.file.getAbsolutePath(), stream), stream, macro.getBuildPath(), paths);//so build path is parent/src and bin.
            stream.close();
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
public class MacroTab {
  File file;//null.
  CommandEdit editor;
  ConsoleEdit console;
  boolean changed=false;
  long lastSaveTime=System.currentTimeMillis();
  private boolean tabchanged=false;
  MacroTab(String name, CommandEdit editor_, ConsoleEdit console_) {
    file=new File(name);
    editor=editor_;
    console=console_;
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
  protected PrintStream __console;
  public String name;//this is originlly "__this".
  //paivate vars are not part of api.
  private Analyzer __analyzer;
  public class SimpleFile {
    public File file;
    public void write(String text) {
      __parent.writeFile(file.getAbsolutePath(), text);
    }
    public String read() {
      return __parent.readFile(file.getAbsolutePath());
    }
    public List<Command> delimitParse(LineCommandProcessor proc, LineCommandType type) {
      __analyzer= new DelimiterParser(type, proc);//re calculate...because file can be change.
      __analyzer.readAll((ArrayList<String>)Arrays.asList(PApplet.split(read(), '\n')));
      return __analyzer.lines;
    }
    public Multiset<LineError> delimitParseError(LineCommandProcessor proc, LineCommandType type) {
      __analyzer= new DelimiterParser(type, proc);
      __analyzer.readAll((ArrayList<String>)Arrays.asList(PApplet.split(read(), '\n')));
      return __analyzer.errors;
    }
  }
  //you can do no constructor
  @Override
    public final void initialize(Object param) {
    __parent=((PW2_0Param)param).sketch;
    __console=((PW2_0Param)param).console;
    name=((PW2_0Param)param).tab;
  }
  public void println(Object o) {
    __console.println(o);
  }
  public void print(Object o) {
    __console.print(o);
  }
  public void send(MidiDevice device, byte note, byte vel) {
    //device.sendMessage();
  }
}
/*
void setup(){
 goto a; // no use
 SimpleFile file; // api class
 name; //api variable
 initialize(); // api method
 someMethod(); // method
 int a; // keyword
 if (a == 0) // block statement
 file.delimitParse(PW2_0.ledCommands,new LedProcessor());
 __parent.doNotUseThis();
 }
 void function(){
 println("do something");
 }
 */