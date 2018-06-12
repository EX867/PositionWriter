package pw2.loader;
import processing.data.XML;
import pw2.element.WavEditor;
import pw2.element.ugens.AutoFaderControl;
import pw2.element.ugens.TDCompControl;

import java.io.BufferedReader;
import java.util.ArrayList;
public class PwWaveditLoader {
  public static ArrayList<Double> loadGoldWaveCue(String path) {
    ArrayList<Double> ret = new ArrayList<>();
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
    */
    for (String line : lines) {
      String[] tokens = processing.core.PApplet.split(line, " ");
      if (tokens[0].equals("INDEX")) {
        String time = tokens[2];
        //ADD>>ret.add(parseTime(time));
      }
    }
    return ret;
  }
  public static void save(TDCompControl comp, AutoFaderControl fader, WavEditor editor, String path) {
    //save automations,bpm,offset,automations current value with <sample name>.xml inside path.
    XML ret = new XML("Data");
  }
  public static void load(TDCompControl comp, AutoFaderControl fader, WavEditor editor) {
    //load data with editor's sample.
    //this will called after editor.initPlayer and setSample, only once per load.
  }
}
