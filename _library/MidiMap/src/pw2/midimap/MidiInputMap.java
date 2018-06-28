package pw2.midimap;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.ShortMessage;
public class MidiInputMap {
  MidiInputCommand[] note_on;
  MidiInputCommand[] note_off;
  public void setNoteOn(int note, MidiInputCommand command) {
    if (note_on == null) note_on = new MidiInputCommand[128];
    note_on[note] = command;
  }
  public void setNoteOff(int note, MidiInputCommand command) {
    if (note_off == null) note_off = new MidiInputCommand[128];
    note_off[note] = command;
  }
  public void execute(MidiMessage msg, long timeStamp, Device device) {
    if (msg instanceof ShortMessage) {
      ShortMessage info = (ShortMessage)msg;
      if (info.getCommand() == ShortMessage.NOTE_ON) {
        if (note_on[info.getData1()] != null) note_on[info.getData1()].execute(msg, timeStamp, device);
      } else if (info.getCommand() == ShortMessage.NOTE_OFF) {
        if (note_off[info.getData1()] != null) note_off[info.getData1()].execute(msg, timeStamp, device);
      }
    }
  }
}