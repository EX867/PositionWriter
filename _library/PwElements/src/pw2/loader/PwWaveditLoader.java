package pw2.loader;
import processing.data.XML;
import pw2.beads.KnobAutomation;
import pw2.element.WavEditor;
import pw2.element.ugens.AutoFaderControl;
import pw2.element.ugens.TDCompControl;

import java.io.BufferedReader;
import java.util.ArrayList;
public class PwWaveditLoader {
  public static void loadGoldwaveCue(String path, KnobAutomation in) throws NumberFormatException {
    BufferedReader read = kyui.core.KyUI.Ref.createReader(path);
    StringBuilder builder = new StringBuilder();
    try {
      String line = read.readLine();
      while (line != null) {
        builder.append("\n").append(line);
        line = read.readLine();
      }
      builder.delete(0, 1);
    } catch (Exception e) {
    }
    try {
      if (read != null) {
        read.close();
      }
    } catch (Exception e) {
    }
    String[] lines = processing.core.PApplet.split(builder.toString(), "\n");
    /*FILE ...
      TRACK ...
        TITLE ...
        INDEX 01 01:10:33
        minute:seconds:milli
    */
    for (String line : lines) {
      String[] tokens = processing.core.PApplet.split(line.trim(), " ");
      if (tokens.length == 0) {
        continue;
      }
      if (tokens[0].equals("INDEX")) {
        String[] time = processing.core.PApplet.split(tokens[2], ":");
        if (time.length >= 3) {
          in.addPoint((double)((Long.parseLong(time[0]) * 60 + Long.parseLong(time[1])) * 1000 + Long.parseLong(time[2])), 0);//for milliseconds
        } else {//else error.
          System.out.println("PwWaveditLoader : INDEX time length is smaller than 3.");
        }
      }
    }
  }
  static XML addValue(XML in, String name, String value) {
    in.setString(name, value);
    return in;
  }
  static double getValue(KnobAutomation auto) {
    if (auto.target == null) {
      return auto.min;
    } else {
      return auto.target.value;
    }
  }
  public static XML save(TDCompControl comp, AutoFaderControl fader, WavEditor edit) {
    //temp parameters for now, but for forward compatibility, save in specific order(comp->fader, global(sp))
    //save automations,bpm,offset,automations current value with <sample name>.xml inside path.
    /*
    Data
    - Editor bpm="" offst=""
    - - speed value=""
    - - - points value=""
    - - - points value=""
    - Effects
    - - TDCompControl
    - - - attack value=""
    - - - - points value=""
    - - - - points value=""
    - - AutoFaderControl ...
    */
    XML ret = new XML("Data");
    XML editor = ret.addChild("Editor");
    editor.setString("bpm", "" + edit.snapBpm);
    editor.setString("offset", "" + edit.snapOffset);
    for (KnobAutomation auto : edit.player.getAutomations()) {
      auto.insertToXML(addValue(editor.addChild(auto.getName()), "value", "" + getValue(auto)));
    }
    XML effects = ret.addChild("Effects");
    XML compinfo = effects.addChild(TDCompControl.class.getTypeName());
    XML faderinfo = effects.addChild(AutoFaderControl.class.getTypeName());
    for (KnobAutomation auto : comp.comp.getAutomations()) {
      auto.insertToXML(addValue(compinfo.addChild(auto.getName()), "value", "" + getValue(auto)));
    }
    for (KnobAutomation auto : fader.fader.getAutomations()) {
      auto.insertToXML(addValue(faderinfo.addChild(auto.getName()), "value", "" + getValue(auto)));
    }
    return ret;
  }
  public static void load(XML xml, TDCompControl comp, AutoFaderControl fader, WavEditor edit) {
    //load data with editor's sample.
    //this will called after editor.initPlayer and setSample, only once per load.
    //xml is Data.
    XML editor = xml.getChild("Editor");
    XML effects = xml.getChild("Effects");
    edit.snapBpm = editor.getFloat("bpm", 120);
    edit.snapOffset = editor.getFloat("offset", 0);
    XML compinfo = effects.getChild(TDCompControl.class.getTypeName());
    XML faderinfo = effects.getChild(AutoFaderControl.class.getTypeName());
    //set speed
    for (KnobAutomation auto : edit.player.getAutomations()) {
      auto.readFromXML(editor.getChild(auto.getName()));
    }
    //set comp.comp.automation
    for (KnobAutomation auto : comp.comp.getAutomations()) {
      auto.readFromXML(compinfo.getChild(auto.getName()));
    }
    //set fader.fader.automation
    for (KnobAutomation auto : fader.fader.getAutomations()) {
      auto.readFromXML(faderinfo.getChild(auto.getName()));
    }
  }
}
