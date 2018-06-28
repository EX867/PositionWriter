package pw2.midimap;
import javax.sound.midi.MidiMessage;
import java.util.HashMap;
public class MidiInputCommand {
  //
  String name;
  int[] params;
  InputBehavior command;
  public MidiInputCommand(String command_) {
    String[] tokens = command_.split(":");
    if (tokens.length == 0) throw new RuntimeException("[MidiMap] command is not correct!!");
    name = tokens[0];
    params = new int[tokens.length - 1];
    for (int a = 0; a < params.length; a++) {
      if (isInt(tokens[a + 1])) params[a] = Integer.parseInt(tokens[a + 1]);
    }
    command = Device.inputMap.get(command_);
    if (command == null) {
      throw new RuntimeException("command not exists!");
    }
  }
  public void execute(MidiMessage msg, long timeStamp, Device device) {
    if (command != null) {
      command.execute(msg, timeStamp, device, params);
    }
  }
  //
  private static boolean isInt(String str) {
    if (str.equals("")) return false;
    if (str.length() > 9) return false;
    if (str.equals("-")) return false;
    int a = 0;
    if (str.charAt(0) == '-') a = 1;
    while (a < str.length()) {
      if (('0' <= str.charAt(a) && str.charAt(a) <= '9') == false) return false;
      a = a + 1;
    }
    return true;
  }
}
