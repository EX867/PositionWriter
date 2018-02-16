package com.karnos.commandscript.test;
import com.karnos.commandscript.*;
import kyui.core.Attributes;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.element.DivisionLayout;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.event.KeyEvent;
import processing.event.MouseEvent;

import java.util.ArrayList;
public class Test extends PApplet {
  CommandEdit.MarkRange range1;
  CommandEdit.MarkRange range2;
  CommandEdit edit;
  public static void main(String[] args) {
    PApplet.main("com.karnos.commandscript.test.Test");
  }
  public void settings() {
    size(500, 500);
  }
  public void setup() {
    //        Main.editorSetupFinishListener=() -> {
    //          try {
    //            ElementLoader.loadClass(CommandEdit.class);
    //          } catch (Exception e) {
    //            e.printStackTrace();
    //          }
    //        };
    //        kyui.editor.Main.main(new String[0]);
    //variations are only assigned once.
    //script_setup();
    KyUI.start(this);
    //ElementLoader.loadOnStart();
    CommandType commandType=new CommandType();
    //    //> unipad led commands
    //    //normal on
    //    commandType.addCommand(new ParamInfo("on", Parameter.FIXED, "o"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("vel", Parameter.INTEGER));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX));
    //    //mc on
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("vel", Parameter.INTEGER));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX));
    //    //pulse
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("p", Parameter.FIXED));
    //    //mc pulse
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    //    commandType.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX), new ParamInfo("p", Parameter.FIXED));
    //    //normal off
    //    commandType.addCommand(new ParamInfo("off", Parameter.FIXED, "f"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE));
    //    //mc off
    //    commandType.addCommand(new ParamInfo("off"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER));
    //    //delay
    //    commandType.addCommand(new ParamInfo("delay", Parameter.FIXED, "d"), new ParamInfo("value", Parameter.INTEGER));
    //    commandType.addCommand(new ParamInfo("delay"), new ParamInfo("fraction", Parameter.STRING));
    //    //bpm
    //    commandType.addCommand(new ParamInfo("bpm", Parameter.FIXED, "b"), new ParamInfo("value", Parameter.FLOAT));
    //    //chain
    //    commandType.addCommand(new ParamInfo("chain", Parameter.FIXED, "c"), new ParamInfo("c", Parameter.INTEGER));
    //    //mapping
    //    commandType.addCommand(new ParamInfo("mapping", Parameter.FIXED, "m"), new ParamInfo("s"), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("n", Parameter.INTEGER));
    //    commandType.addCommand(new ParamInfo("mapping"), new ParamInfo("l"), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("n", Parameter.INTEGER));
    //    //no autoplay in here because that is not led cmdset.
    //    //> highlight keywords
    //    int C_KEYWORD1=0xFF3294AA;
    //    int C_UNITOR1=0xFF669900;
    //    int C_UNITOR2=0xFF614793;
    //    commandType.setKeyword("on", C_KEYWORD1);
    //    commandType.setKeyword("o", C_KEYWORD1);
    //    commandType.setKeyword("off", C_KEYWORD1);
    //    commandType.setKeyword("f", C_KEYWORD1);
    //    commandType.setKeyword("delay", C_KEYWORD1);
    //    commandType.setKeyword("d", C_KEYWORD1);
    //    commandType.setKeyword("auto", C_KEYWORD1);
    //    commandType.setKeyword("a", C_KEYWORD1);
    //    commandType.setKeyword("bpm", C_KEYWORD1);
    //    commandType.setKeyword("b", C_KEYWORD1);
    //    commandType.setKeyword("p", C_KEYWORD1);
    //    commandType.setKeyword("chain", C_UNITOR1);
    //    commandType.setKeyword("c", C_UNITOR1);
    //    commandType.setKeyword("mapping", C_UNITOR1);
    //    commandType.setKeyword("m", C_UNITOR1);
    //    commandType.setKeyword("mc", C_UNITOR2);
    //    commandType.setKeyword("s", C_UNITOR2);
    //    commandType.setKeyword("l", C_UNITOR2);
    //    commandType.setKeyword("rnd", C_UNITOR2);
    Analyzer.debug=true;
    commandType.addCommand(new ParamInfo("start1", Parameter.FIXED), new ParamInfo("line", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("end1", Parameter.FIXED), new ParamInfo("line", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("start2", Parameter.FIXED), new ParamInfo("line", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("end2", Parameter.FIXED), new ParamInfo("line", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("a", Parameter.FIXED), new ParamInfo("aa", Parameter.WRAPPED_STRING));
    commandType.addCommand(new ParamInfo("a", Parameter.FIXED), new ParamInfo("bb", Parameter.STRING));
    int C_KWD1=0xFF669900;
    int C_KWD2=0xFF3294AA;
    commandType.setKeyword("start1", C_KWD1);
    commandType.setKeyword("end1", C_KWD1);
    commandType.setKeyword("start2", C_KWD2);
    commandType.setKeyword("end2", C_KWD2);
    //
    Processor processor=new Processor();
    edit=new CommandEdit("edit");//.setAnalyzer(commandType, processor);
    edit.setAnalyzer(new DelimiterParser(commandType, new Processor()));
    range1=edit.addMarkRange(0x3FFF0000);
    range2=edit.addMarkRange(0x3F0000FF);
    DivisionLayout layout=new DivisionLayout("layout");
    layout.value=24;
    layout.setPosition(new Rect(0, 0, 500, 500));
    layout.rotation=Attributes.Rotation.RIGHT;
    layout.addChild(edit);
    layout.addChild(edit.getSlider());
    KyUI.add(layout);
    KyUI.changeLayout();
    CommandScript.READ_THRESHOLD=1;
    //final LedScript currentLedEditor=new LedScript("LedFileName", edit);
    //edit.setContent(currentLedEditor);
    //    CommandScript script=new CommandScript("LedEditor", null, null).setAnalyzer(commandType, processor);
    //    script.addLine_("on 6 5 auto 2");
    //    script.addLine_("o 6 5 auto 2");
    //    script.addLine_("o 5 4 a 2");
    //    script.addLine_("on 2 3 1");
    //    script.addLine_("on mc 4 3");
    //    script.addLine_("on mc 2 auto 2");
    //    script.addLine_("on 1~3 3~6 auto 2");
    //    script.addLine_("o 4~5 2~6 4");
    //    script.addLine_("off 2 4");
    //    script.addLine_("f 2 4");
    //    script.addLine_("delay 5");
    //    script.addLine_("delay 2/3");
    //    script.addLine_("bpm 2.5");
    //    script.addLine_("chain 2");
    //    script.addLine_("m s 2 4 6");
    //    script.addLine_("o 2 2 2 2");
    //    script.addLine_("off 2 s");
    //    System.out.println("//===result===//");
    //    System.out.println(script.toString());
    //    for (LineError e : script.getErrors()) {
    //      System.out.println(e.toString());
    //    }
    KyUI.addShortcut(new KyUI.Shortcut("undo", true, false, false, 26, java.awt.event.KeyEvent.VK_Z, (Element e) -> {
      if (e instanceof CommandEdit) {
        CommandEdit t=(CommandEdit)e;
        t.script.undo();
        t.invalidate();
      }
    }));
    KyUI.addShortcut(new KyUI.Shortcut("redo", true, false, false, 25, java.awt.event.KeyEvent.VK_Y, (Element e) -> {
      if (e instanceof CommandEdit) {
        CommandEdit t=(CommandEdit)e;
        t.script.redo();
        t.invalidate();
      }
    }));
  }
  public void draw() {
    KyUI.render(g);
  }
  class CommandType extends LineCommandType {
    @Override
    public Command getCommand(Analyzer analyzer, int line, String location, String text, String commandName, ArrayList<String> params) {
      System.out.println("[result] " + commandName);
      if (commandName.equals("start1 line")) {
        return new StartCommand(range1, Integer.parseInt(params.get(1)));
      } else if (commandName.equals("end1 line")) {
        return new EndCommand(range1, Integer.parseInt(params.get(1)));
      } else if (commandName.equals("start2 line")) {
        return new StartCommand(range2, Integer.parseInt(params.get(1)));
      } else if (commandName.equals("end2 line")) {
        return new EndCommand(range2, Integer.parseInt(params.get(1)));
      }
      return getEmptyCommand();
      //return getErrorCommand();
    }
    @Override
    public Command getErrorCommand() {
      return new ErrorCommand();
    }
    @Override
    public Command getEmptyCommand() {
      return new EmptyCommand();
    }
    @Override
    public void cursorUpWord(CommandScript script, boolean select) {
    }
    @Override
    public void cursorDownWord(CommandScript script, boolean select) {
    }
  }
  class Processor extends LineCommandProcessor {
    @Override
    public void processCommand(Analyzer analyzer, int line, Command before, Command after) {
      //if (before == null) System.out.println("[out] " + line + " added " + after.toString());
      //else if (after == null) System.out.println("[out] " + line + " deleted " + before.toString());
      //else System.out.println("[out] " + line + " changed from " + before.toString() + " to " + after.toString());
      getSurface().setTitle("editor - " + analyzer.getProgress() + "/" + analyzer.getTotal());
    }
    @Override
    public void onReadFinished(Analyzer analyzer) {
      getSurface().setTitle("editor");
      //set title progress to 0 etc...
    }
    @Override
    public void clear(Analyzer analyzer) {
    }
  }
  class StartCommand implements Command {
    CommandEdit.MarkRange r;
    int val;
    public StartCommand(CommandEdit.MarkRange r_, int val_) {
      r=r_;
      val=val_;
    }
    @Override
    public String toString() {
      return "start - start from" + val;
    }
  }
  class EndCommand implements Command {
    CommandEdit.MarkRange r;
    int val;
    public EndCommand(CommandEdit.MarkRange r_, int val_) {
      r=r_;
      val=val_;
    }
    @Override
    public String toString() {
      return "start - start from" + val;
    }
  }
  @Override
  protected void handleKeyEvent(KeyEvent event) {
    super.handleKeyEvent(event);
    KyUI.handleEvent(event);
    if (event.getAction() == 1) {
      // println((int)key + " " + keyCode);
      if (event.getKey() == 19 && event.getKeyCode() == java.awt.event.KeyEvent.VK_S) {
        edit.addLine(0, "asfd");
      }
    }
  }
  @Override
  protected void handleMouseEvent(MouseEvent event) {
    super.handleMouseEvent(event);
    KyUI.handleEvent(event);
  }
  public Command getErrorCommand() {
    return new ErrorCommand();
  }
  public Command getEmptyCommand() {
    return new EmptyCommand();
  }
  public void cursorUpWord(CommandScript script, boolean select) {
    //#ADD
  }
  public void cursorDownWord(CommandScript script, boolean select) {
    //#ADD
  }
}
class ErrorCommand implements Command {
  public String toString() {
    return "";
  }
}
class EmptyCommand implements Command {
  public String toString() {
    return "";
  }
}
