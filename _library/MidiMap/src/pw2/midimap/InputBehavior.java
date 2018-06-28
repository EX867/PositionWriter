package pw2.midimap;
import javax.sound.midi.MidiMessage;
public interface InputBehavior {//extend this and send parameter
  public void execute(MidiMessage msg, long timeStamp, Device device, int... params);
}
