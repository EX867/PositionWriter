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
  UnipackCommands ledCommands;
  UnipackCommands ksCommands;
  UnipackCommands apCommands;//#ADD
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
    commandType.addCommand(new ParamInfo("start1", Parameter.FIXED), new ParamInfo("line", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("end1", Parameter.FIXED), new ParamInfo("line", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("start2", Parameter.FIXED), new ParamInfo("line", Parameter.INTEGER));
    commandType.addCommand(new ParamInfo("end2", Parameter.FIXED), new ParamInfo("line", Parameter.INTEGER));
    int C_KWD1=0xFF669900;
    int C_KWD2=0xFF3294AA;
    commandType.setKeyword("start1", C_KWD1);
    commandType.setKeyword("end1", C_KWD1);
    commandType.setKeyword("start2", C_KWD2);
    commandType.setKeyword("end2", C_KWD2);
    //
    Processor processor=new Processor();
    edit=new CommandEdit("edit");//.setAnalyzer(commandType, processor);
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
    //    if (event.getAction() == 1) {
    //      println((int)key + " " + keyCode);
    //    }
  }
  @Override
  protected void handleMouseEvent(MouseEvent event) {
    super.handleMouseEvent(event);
    KyUI.handleEvent(event);
  }
  void script_setup() {
    ledCommands=new UnipackCommands();
    //> unipad led commands
    //normal on
    ledCommands.addCommand(new ParamInfo("on", Parameter.FIXED, "o"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("vel", Parameter.INTEGER));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX));
    //mc on
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("vel", Parameter.INTEGER));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX));
    //pulse
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE), new ParamInfo("html", Parameter.HEX), new ParamInfo("p", Parameter.FIXED));
    //mc pulse
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("auto", Parameter.FIXED, "a"), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX), new ParamInfo("vel", Parameter.INTEGER), new ParamInfo("p", Parameter.FIXED));
    ledCommands.addCommand(new ParamInfo("on"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER), new ParamInfo("html", Parameter.HEX), new ParamInfo("p", Parameter.FIXED));
    //normal off
    ledCommands.addCommand(new ParamInfo("off", Parameter.FIXED, "f"), new ParamInfo("y", Parameter.RANGE), new ParamInfo("x", Parameter.RANGE));
    //mc off
    ledCommands.addCommand(new ParamInfo("off"), new ParamInfo("mc"), new ParamInfo("n", Parameter.INTEGER));
    //delay
    ledCommands.addCommand(new ParamInfo("delay", Parameter.FIXED, "d"), new ParamInfo("value", Parameter.INTEGER));
    ledCommands.addCommand(new ParamInfo("delay"), new ParamInfo("fraction", Parameter.STRING));
    //bpm
    ledCommands.addCommand(new ParamInfo("bpm", Parameter.FIXED, "b"), new ParamInfo("value", Parameter.FLOAT));
    //chain
    ledCommands.addCommand(new ParamInfo("chain", Parameter.FIXED, "c"), new ParamInfo("c", Parameter.INTEGER));
    //mapping
    ledCommands.addCommand(new ParamInfo("mapping", Parameter.FIXED, "m"), new ParamInfo("s"), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("n", Parameter.INTEGER));
    ledCommands.addCommand(new ParamInfo("mapping"), new ParamInfo("l"), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("n", Parameter.INTEGER));
    //no autoplay in here because that is not led cmdset.
    //> highlight keywords
    int C_KEYWORD1=0xFF3294AA;
    int C_UNITOR1=0xFF669900;
    int C_UNITOR2=0xFF614793;
    ledCommands.setKeyword("on", C_KEYWORD1);
    ledCommands.setKeyword("o", C_KEYWORD1);
    ledCommands.setKeyword("off", C_KEYWORD1);
    ledCommands.setKeyword("f", C_KEYWORD1);
    ledCommands.setKeyword("delay", C_KEYWORD1);
    ledCommands.setKeyword("d", C_KEYWORD1);
    ledCommands.setKeyword("auto", C_KEYWORD1);
    ledCommands.setKeyword("a", C_KEYWORD1);
    ledCommands.setKeyword("bpm", C_KEYWORD1);
    ledCommands.setKeyword("b", C_KEYWORD1);
    ledCommands.setKeyword("p", C_KEYWORD1);
    ledCommands.setKeyword("chain", C_UNITOR1);
    ledCommands.setKeyword("c", C_UNITOR1);
    ledCommands.setKeyword("mapping", C_UNITOR1);
    ledCommands.setKeyword("m", C_UNITOR1);
    ledCommands.setKeyword("mc", C_UNITOR2);
    ledCommands.setKeyword("s", C_UNITOR2);
    ledCommands.setKeyword("l", C_UNITOR2);
    ledCommands.setKeyword("rnd", C_UNITOR2);
    //#ADD
    //
    ksCommands=new UnipackCommands();
    ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("relative", Parameter.STRING));
    ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("relative", Parameter.STRING), new ParamInfo("loop", Parameter.INTEGER));
    ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("absolute", Parameter.WRAPPED_STRING));
    ksCommands.addCommand(new ParamInfo("kschain", Parameter.INTEGER), new ParamInfo("y", Parameter.INTEGER), new ParamInfo("x", Parameter.INTEGER), new ParamInfo("absolute", Parameter.WRAPPED_STRING), new ParamInfo("loop", Parameter.INTEGER));
  }
  class LedScript extends CommandScript {
    CommandEdit editor;//linked editor
    ArrayList<int[][]> LED;
    Multiset<Integer> DelayPoint;
    Multiset<Integer> BpmPoint;
    Multiset<Integer> ChainPoint;
    LineCommandType cmdset;
    LedProcessor processor;
    boolean bypass=false;//used when speed is required.
    boolean ignoreUnitorCmd=false;
    int displayFrame=0;
    int displayTime=0;
    public LedScript(String name_, CommandEdit editor_) {
      super(name_, null);
      editor=editor_;
      processor=new LedProcessor();
      processor.clear(null);
      if (editor == null) {
        setAnalyzer(new DelimiterParser(ledCommands, processor));
      } else {
        editor.setContent(this);
        editor.setAnalyzer(new DelimiterParser(ledCommands, processor));
      }
    }
    void setCmdSet(LineCommandType cmdset_) {
      cmdset=cmdset_;
      readAll();
    }
    LineCommandType getCmdSet() {
      return cmdset;
    }
    public void readAll() {
      bypass=true;
      super.readAll();
      bypass=false;
      if (processor != null) {
        processor.readAll();//optimization...
      }
    }
    int getFrame(int line) {
      if (line < 0) return 0;
      return DelayPoint.getBeforeIndex(line - 1) - 1;//find frame with delay is meaningless.
    }
    float getBpm(int line) {
      int index=BpmPoint.getBeforeIndex(line - 1) - 1;
      if (index == 0) return 120;
      //assert script.getCommands().get(index) instanceof BpmCommand
      return ((BpmCommand)getCommands().get(index)).value;
    }
    int getDelayValue(int line) {//milliseconds.
      if (line == -1) return 0;
      //assert script.getCommands().get(index) instanceof DelayCommand
      DelayCommand info=(DelayCommand)getCommands().get(line);
      if (info.isFraction) {
        return PApplet.floor((info.up * 2400 / (getBpm(line) * info.down)) * 100);
      } else return info.up;
    }
    int getFrameLength() {
      return DelayPoint.size();
    }
    int getDelayValueByFrame(int frame) {//last frame returns 0.
      if (frame == DelayPoint.size() - 1) {
        return 0;
      }
      return getDelayValue(DelayPoint.get(frame + 1));
    }
    void resize() {//resize to ButtonX,ButtonY.
      analyzer.clear();
      readAll();
    }
    void setTimeByFrame() {
      displayTime=getTimeByFrame(displayFrame);
    }
    void setTimeByFrame(int frame) {
      displayTime=getTimeByFrame(frame);
    }
    int getTimeByFrame(int frame) {
      int time=0;
      for (int a=1; a <= frame; a++) {
        time+=getDelayValue(DelayPoint.get(a));
      }
      return time;
    }
    void setFrameByTime() {
      displayFrame=getFrameByTime(displayTime);
    }
    void setFrameByTime(long time) {
      displayFrame=getFrameByTime(time);
    }
    int getFrameByTime(long time) {
      int sum=0;
      int frame=0;
      for (int a=1; a < DelayPoint.size(); a++) {
        sum=sum + getDelayValue(DelayPoint.get(a));
        if (time < sum) {
          break;
        }
        frame++;
      }
      return frame;
    }
    class LedProcessor extends LineCommandProcessor {
      public LedProcessor() {
        resize();
      }
      public void processCommand(Analyzer analyzer, int line, Command before, Command after) {
        int frame=getFrame(line);
        if (after == null) {
          for (int a=DelayPoint.size() - 1; a > 0 && line < DelayPoint.get(a); a--) {
            DelayPoint.set(a, DelayPoint.get(a) - 1);
          }
          for (int a=BpmPoint.size() - 1; a > 0 && line < BpmPoint.get(a); a--) {
            BpmPoint.set(a, BpmPoint.get(a) - 1);
          }
          for (int a=ChainPoint.size() - 1; a > 0 && line < ChainPoint.get(a); a--) {
            ChainPoint.set(a, ChainPoint.get(a) - 1);
          }
        }//else
        if (before == null) {
          for (int a=DelayPoint.size() - 1; a > 0 && line <= DelayPoint.get(a); a--) {
            DelayPoint.set(a, DelayPoint.get(a) + 1);
          }
          for (int a=BpmPoint.size() - 1; a > 0 && line <= BpmPoint.get(a); a--) {
            BpmPoint.set(a, BpmPoint.get(a) + 1);
          }
          for (int a=ChainPoint.size() - 1; a > 0 && line < ChainPoint.get(a); a--) {
            ChainPoint.set(a, ChainPoint.get(a) + 1);
          }
        }
        if (before != null) {
          if (before instanceof LightCommand) {//includes on and off.
            LightCommand info=(LightCommand)before;
            for (int a=info.x1; a <= info.x2; a++) {
              for (int b=info.y1; b <= info.y2; b++) {
                deleteLedPosition(frame, a, b);//line+(after==null?0:1)
              }
            }
          } else if (before instanceof DelayCommand) {
            int index=DelayPoint.getBeforeIndex(line - 1);
            //assert DelayCommand.get(index)==line
            DelayPoint.remove(index);
            LED.remove(frame);//assert frame>=1
            if (displayFrame > LED.size() - 1) displayFrame--;
          } else if (before instanceof BpmCommand) {
            int index=BpmPoint.getBeforeIndex(line - 1);
            //assert BpmCommand.get(index)==line
            BpmPoint.remove(index);
          } else if (before instanceof ChainCommand) {
            int index=ChainPoint.getBeforeIndex(line - 1);
            //assert ChainCommand.get(index)==line
            ChainPoint.remove(index);
          }
        }
        if (after != null) {
          if (after instanceof UnitorCommand) {
            if (!ignoreUnitorCmd) {//int type_, int line_, int start_, int end_, String location_, String cause_
              addError(new LineError(LineError.WARNING, line, 0, getLine(line).length(), name, "you can't use unitor command in normal led."));
            }
          } else if (after instanceof LightCommand) {//includes on and off.
            LightCommand info=(LightCommand)after;
            for (int a=info.x1; a <= info.x2; a++) {
              for (int b=info.y1; b <= info.y2; b++) {
                insertLedPosition(frame, line + (after == null ? 0 : 1), a, b, info.htmlc);
              }
            }
          } else if (after instanceof DelayCommand) {
            DelayPoint.add(line);
            LED.add(frame + 1, new int[8][8]);
            readFramesLed(frame, 2);
          } else if (after instanceof BpmCommand) {
            BpmPoint.add(line);
          } else if (after instanceof ChainCommand) {
            if (!(cmdset == apCommands || !ignoreUnitorCmd)) {//chain is duplication so add error manually...
              addError(new LineError(LineError.WARNING, line, 0, getLine(line).length(), name, "you can't use chain command in normal led."));
            }
            ChainPoint.add(line);
          }
        }
      }
      void readAll() {
        ArrayList<Command> commands=getCommands();
        //float bpm=DEFAULT_BPM;
        int line=0;
        for (Command cmd : commands) {
          if (cmd instanceof LightCommand) {
            LightCommand data=(LightCommand)cmd;
            for (int a=Math.max(1, data.x1); a <= 8 && a <= data.x2; a++) {
              for (int b=Math.max(1, data.y1); b <= 8 && b <= data.y2; b++) {
                LED.get(LED.size() - 1)[a - 1][b - 1]=data.htmlc;
              }
            }
          } else if (cmd instanceof DelayCommand) {
            LED.add(new int[8][8]);
            for (int a=0; a < 8; a++) {
              for (int b=0; b < 8; b++) {
                LED.get(LED.size() - 1)[a][b]=LED.get(LED.size() - 2)[a][b];
              }
            }
            DelayPoint.add(line);
          } else if (cmd instanceof BpmCommand) {
            BpmPoint.add(line);
          } else if (cmd instanceof ChainCommand) {
            ChainPoint.add(line);
          }//else ignore
          line++;
        }
        displayFrame=Math.min(displayFrame, DelayPoint.size() - 1);
        setTimeByFrame(displayFrame);
      }
      void insertLedPosition(int frame, int line, int x, int y, int c) {
        if (line >= getCommands().size()) return;
        if (0 < x && x <= 8 && 0 < y && y <= 8) {
          ArrayList<Command> commands=getCommands();
          boolean changed=false;
          int toSet=c;
          for (; line < getCommands().size(); line++) {
            Command cmd=commands.get(line);
            if (cmd instanceof LightCommand) {
              LightCommand info=(LightCommand)cmd;
              if (info.x1 <= x && x <= info.x2 && info.y1 <= y && y <= info.y2) {
                toSet=info.htmlc;
                changed=true;
              }
            } else if (cmd instanceof DelayCommand) {
              if (changed == false) {
                LED.get(frame)[x - 1][y - 1]=toSet;
              } else {
                break;
              }
              frame++;
            }
          }
          if (changed == false && line == getCommands().size()) {
            LED.get(frame)[x - 1][y - 1]=toSet;
          }
        }
      }
      void deleteLedPosition(int frame, int x, int y) {
        //if (1 == 1) return;
        if (frame == 0) {
          LED.get(frame)[x - 1][y - 1]=0;
        } else if (frame > 0) {
          LED.get(frame)[x - 1][y - 1]=LED.get(frame - 1)[x - 1][y - 1];
        }
        int max=getCommands().size();
        System.out.println(max + " " + DelayPoint.size() + " " + getCommands().size());
        if (frame < DelayPoint.size() - 1) max=DelayPoint.get(frame + 1);
        System.out.println(max);
        for (int a=DelayPoint.get(frame) + 1; a < max; a++) {
          Command cmd=getCommands().get(a);
          if (cmd instanceof LightCommand) {
            LightCommand info=(LightCommand)cmd;
            if (info.x1 <= x && x <= info.x2 && info.y1 <= y && y <= info.y2) LED.get(frame)[x - 1][y - 1]=info.htmlc;
          }
        }
        insertLedPosition(frame + 1, max, x, y, LED.get(frame)[x - 1][y - 1]);
      }
      void readFramesLed(int frame, int count) {
        if (frame == 0) {
          for (int a=0; a < 8; a++) {
            for (int b=0; b < 8; b++) {
              LED.get(frame)[a][b]=0;
            }
          }
        } else {
          for (int a=0; a < 8; a++) {
            for (int b=0; b < 8; b++) {
              LED.get(frame)[a][b]=LED.get(frame - 1)[a][b];
            }
          }
        }
        int d=DelayPoint.get(frame) + 1;
        count=frame + count;
        ArrayList<Command> commands=getCommands();
        for (; frame <= count && d < getCommands().size(); d++) {//reset
          Command cmd=commands.get(d);//AnalyzeLine(a, "readFrame - read "+count+" frames", Lines.getLine(a));
          if (cmd instanceof LightCommand) {
            LightCommand info=(LightCommand)cmd;
            for (int a=info.x1; a <= info.x2; a++) {
              for (int b=info.y1; b <= info.y2; b++) {
                LED.get(frame)[a - 1][b - 1]=info.htmlc;
              }
            }
          } else if (cmd instanceof DelayCommand) {
            frame++;
            for (int a=0; a < 8; a++) {
              for (int b=0; b < 8; b++) {
                LED.get(frame)[a][b]=LED.get(frame - 1)[a][b];
              }
            }
          }
        }
      }
      public void onReadFinished(Analyzer analyzer) {
      }
      public void clear(Analyzer analyzer) {//analyzer can be null!!
        LED=null;
        DelayPoint=null;
        BpmPoint=null;
        LED=new ArrayList<int[][]>();
        DelayPoint=new Multiset<Integer>();
        BpmPoint=new Multiset<Integer>();
        ChainPoint=new Multiset<Integer>();
        LED.add(new int[8][8]);
        DelayPoint.add(-1);
        BpmPoint.add(-1);
        ChainPoint.add(-1);
      }
    }
  }
  class UnipackCommands extends LineCommandType {
    public Command getCommand(Analyzer analyzer, int line, String location, String text, String commandName, ArrayList<String> params) {
      //add additional errors to analyzer
      KyUI.Ref.println("[line " + line + ", result : " + commandName + "]");//#TEST
      String[] tokens=PApplet.split(commandName, " ");
      int x1=0, x2=0, y1=0, y2=0;
      for (int a=0; a < tokens.length; a++) {
        if (tokens[a].equals("vel")) {
          int vel=Integer.parseInt(params.get(a));
          if (vel < 0 || vel >= 128) {
            analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "velocity is out of range."));
            return getErrorCommand();
          }
        } else if (a > 0 && tokens[a - 1].equals("y") && tokens[a].equals("x")) {//position.
          y1=com.karnos.commandscript.Analyzer.getRangeFirst(params.get(a - 1));
          y2=com.karnos.commandscript.Analyzer.getRangeSecond(params.get(a - 1));
          x1=com.karnos.commandscript.Analyzer.getRangeFirst(params.get(a));
          x2=com.karnos.commandscript.Analyzer.getRangeSecond(params.get(a));
          if (y1 <= 0 || y1 > 8 || x1 <= 0 || x1 > 8 || y2 <= 0 || y2 > 8 || x2 <= 0 || x2 > 8) {
            analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "position is out of range."));
            x1=Math.min(Math.max(1, x1), 8);
            x2=Math.min(Math.max(1, x2), 8);
            y1=Math.min(Math.max(1, y1), 8);
            y2=Math.min(Math.max(1, y2), 8);
          }
        }
      }
      //assert x1!=0 if x,y exists.
      if (commandName.equals("on y x auto vel")) {
        return new OnCommand(x1, x2, y1, y2, color_lp[Integer.parseInt(params.get(4))], Integer.parseInt(params.get(4)));
      } else if (commandName.equals("on y x auto vel p")) {
        return new OnCommand(x1, x2, y1, y2, color_lp[Integer.parseInt(params.get(4))], Integer.parseInt(params.get(4)), true);
      } else if (commandName.equals("on y x vel")) {
        return new OnCommand(x1, x2, y1, y2, color_lp[Integer.parseInt(params.get(3))], Integer.parseInt(params.get(3)));
      } else if (commandName.equals("on y x html vel")) {
        return new OnCommand(x1, x2, y1, y2, KyUI.Ref.color(KyUI.Ref.unhex("FF" + params.get(3))), Integer.parseInt(params.get(4)));
      } else if (commandName.equals("on y x html")) {
        return new OnCommand(x1, x2, y1, y2, KyUI.Ref.color(KyUI.Ref.unhex("FF" + params.get(3))), 0);
      } else if (commandName.equals("on y x auto rnd")) {
        return new OnCommand(x1, x2, y1, y2, 1, 0);
      } else if (commandName.equals("on y x rnd")) {
        return new OnCommand(x1, x2, y1, y2, 1, 0);
      } else if (commandName.equals("on mc n auto vel")) {
        return new McOnCommand(Integer.parseInt(params.get(2)), color_lp[Integer.parseInt(params.get(4))], Integer.parseInt(params.get(4)));
      } else if (commandName.equals("on mc n auto vel p")) {
        return new McOnCommand(Integer.parseInt(params.get(2)), color_lp[Integer.parseInt(params.get(4))], Integer.parseInt(params.get(4)), true);
      } else if (commandName.equals("on mc n vel")) {
        return new McOnCommand(Integer.parseInt(params.get(2)), color_lp[Integer.parseInt(params.get(4))], Integer.parseInt(params.get(3)));
      } else if (commandName.equals("on mc n html vel")) {
        return new McOnCommand(Integer.parseInt(params.get(2)), KyUI.Ref.color(KyUI.Ref.unhex("FF" + params.get(3))), Integer.parseInt(params.get(4)));
      } else if (commandName.equals("on mc n html")) {
        return new McOnCommand(Integer.parseInt(params.get(2)), KyUI.Ref.color(KyUI.Ref.unhex("FF" + params.get(3))), 0);
      } else if (commandName.equals("on mc n auto rnd")) {
        return new McOnCommand(Integer.parseInt(params.get(2)), 1, 0);
      } else if (commandName.equals("on mc n rnd")) {
        return new McOnCommand(Integer.parseInt(params.get(2)), 1, 0);
      } else if (commandName.equals("on y x")) {
        return new ApOnCommand(x1, x2, y1, y2);
      } else if (commandName.equals("off y x")) {
        return new OffCommand(x1, x2, y1, y2);
      } else if (commandName.equals("off mc n")) {
        return new McOffCommand(Integer.parseInt(params.get(2)));
      } else if (commandName.equals("delay value")) {
        int value=Integer.parseInt(params.get(1));
        if (value < 0) {
          analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "delay value is negative."));
          return getErrorCommand();
        }
        return new DelayCommand(value);
      } else if (commandName.equals("delay fraction")) {
        if (1 != 1) {//isFraction(params.get(1))) {
          String[] split=PApplet.split(params.get(1), "/");
          int up=Integer.parseInt(split[0]);
          int down=Integer.parseInt(split[1]);
          if (up * down >= 0) {
            if (down != 0) {
              return new DelayCommand(up, down);
            } else {
              analyzer.addError(new LineError(LineError.ERROR, line, 0, text.length(), location, "divided by 0!"));
              return getErrorCommand();
            }
          } else {
            analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "delay value is negative."));
            return getErrorCommand();
          }
        } else {
          analyzer.addError(new LineError(LineError.ERROR, line, 0, text.length(), location, "delay fraction is incorrect."));
          return getErrorCommand();
        }
      } else if (commandName.equals("bpm value")) {
        float value=Float.parseFloat(params.get(1));
        if (value <= 0) {
          analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "bpm value is 0 or negative."));
          return getErrorCommand();
        }
        return new BpmCommand(value);
      } else if (commandName.equals("chain c")) {
        int c=Integer.parseInt(params.get(1));
        if (c <= 0) {
          analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "chain value is negative."));
          return getErrorCommand();
        }
        return new ChainCommand(c);
      } else if (commandName.equals("mapping s y x n")) {
        int n=Integer.parseInt(params.get(4));
        if (n < 0) {
          analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "mapping value is negative."));
          return getErrorCommand();
        }
        return new MappingCommand(MappingCommand.SOUND, Integer.parseInt(params.get(2)), Integer.parseInt(params.get(1)), n);//sound
      } else if (commandName.equals("mapping l y x n")) {
        int n=Integer.parseInt(params.get(4));
        if (n < 0) {
          analyzer.addError(new LineError(LineError.WARNING, line, 0, text.length(), location, "mapping value is negative."));
          return getErrorCommand();
        }
        return new MappingCommand(MappingCommand.LED, Integer.parseInt(params.get(2)), Integer.parseInt(params.get(1)), n);//sound
      }
      if (commandName.equals("kschain y x relative")) {//#ADD
      } else if (commandName.equals("kschain y x relative loop")) {
      } else if (commandName.equals("kschain y x absolute")) {
      } else if (commandName.equals("kschain y x absolute loop")) {
      }
      return getErrorCommand();
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
  class UnipackCommand implements Command {
    String toUnipadString() {
      return toString();
    }
  }
  class UnitorCommand extends UnipackCommand {
  }
  class LightCommand extends UnipackCommand {
    int x1, x2, y1, y2;
    int vel;
    int htmlc;
    public LightCommand(int x1_, int x2_, int y1_, int y2_, int vel_, int htmlc_) {
      x1=x1_;
      x2=x2_;
      y1=y1_;
      y2=y2_;
      vel=vel_;
      htmlc=htmlc_;
    }
  }
  class OnCommand extends LightCommand {
    boolean pulse;
    public OnCommand(int x1_, int x2_, int y1_, int y2_, int vel_, int htmlc_) {
      super(x1_, x2_, y1_, y2_, vel_, htmlc_);
    }
    public OnCommand(int x1_, int x2_, int y1_, int y2_, int vel_, int htmlc_, boolean pulse_) {//pw supports pulse...
      super(x1_, x2_, y1_, y2_, vel_, htmlc_);
      pulse=pulse_;
    }
    public String toString() {
      String ret="";
      ret="on " + ((y1 == y2) ? y1 + "" : y1 + "~" + y2) + " " + ((x1 == x2) ? x1 + "" : x1 + "~" + x2);
      if (htmlc == 1) ret+=" auto rnd";
      else if (color_lp[vel] != htmlc) ret+=" " + hex(htmlc, 6) + " " + vel;
      else if (vel == 0) ret+=hex(htmlc, 6);
      else ret+=" auto " + vel;
      if (pulse) ret+=" p";
      return ret;
    }
    String toUnipadString() {
      if (pulse || htmlc == 1) return "";
      return toString();
    }
  }
  class OffCommand extends LightCommand {
    public OffCommand(int x1_, int x2_, int y1_, int y2_) {
      super(x1_, x2_, y1_, y2_, 0, 0);
    }
    public String toString() {
      return "off " + ((y1 == y2) ? y1 + "" : y1 + "~" + y2) + " " + ((x1 == x2) ? x1 + "" : x1 + "~" + x2);
    }
  }
  class McOnCommand extends UnitorCommand {
    int n;
    int vel;
    int htmlc;
    boolean pulse;
    public McOnCommand(int n_, int vel_, int htmlc_) {
      n=n_;
      vel=vel_;
      htmlc=htmlc_;
    }
    public McOnCommand(int n_, int vel_, int htmlc_, boolean pulse_) {//pw supports pulse...
      n=n_;
      vel=vel_;
      htmlc=htmlc_;
      pulse=pulse_;
    }
    public String toString() {
      String ret="";
      ret="on mc " + n;
      if (htmlc == 1) ret+=" auto rnd";
      else if (vel == 0) ret+=PApplet.hex(htmlc, 6);
      else ret+=" auto " + vel;
      if (pulse) ret+=" p";
      return ret;
    }
    String toUnipadString() {
      return "";
    }
  }
  class McOffCommand extends UnitorCommand {
    int n;
    public McOffCommand(int n_) {
      n=n_;
    }
    public String toString() {
      return "off mc " + n;
    }
  }
  class ApOnCommand extends LightCommand {
    public ApOnCommand(int x1_, int x2_, int y1_, int y2_) {
      super(x1_, x2_, y1_, y2_, KyUI.Ref.color(255), 3);
    }
    public String toString() {
      return "on " + ((y1 == y2) ? y1 + "" : y1 + "~" + y2) + " " + ((x1 == x2) ? x1 + "" : x1 + "~" + x2);
    }
  }
  class DelayCommand extends UnipackCommand {
    boolean isFraction;
    int up;
    int down;
    public DelayCommand(int value) {
      up=value;
      down=1;
      isFraction=false;
    }
    public DelayCommand(int up_, int down_) {
      up=up_;
      down=down_;
      isFraction=true;
    }
    public String toString() {
      if (isFraction) return "delay " + up;
      return "delay " + up + "/" + down;
    }
    String toUnipadString() {
      if (isFraction) return "";
      return "delay " + up;
    }
    String toUnipadString(float bpm) {
      if (isFraction) return "delay " + floor((up * 2400 / (bpm * down)) * 100);
      return "delay " + up;
    }
  }
  class BpmCommand extends UnipackCommand {
    float value;
    public BpmCommand(float value_) {
      value=value_;
    }
    public String toString() {
      return "bpm " + value;
    }
    String toUnipadString() {
      return "";
    }
  }
  class ChainCommand extends UnipackCommand {
    int c;
    public ChainCommand(int c_) {
      c=c_;
    }
    public String toString() {
      return "chain " + c;
    }
  }
  class MappingCommand extends UnitorCommand {
    static final int SOUND=1;
    static final int LED=2;
    int type;
    int x, y, n;
    public MappingCommand(int type_, int x_, int y_, int n_) {
      type=type_;
      x=x_;
      y=y_;
      n=n_;
    }
    public String toString() {
      if (type == SOUND) return "mapping s " + y + " " + x + " " + n;
      else return "mapping l " + y + " " + x + " " + n;
    }
    String toUnipadString() {
      return "";
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
  static int[] color_lp=new int[128];
}
