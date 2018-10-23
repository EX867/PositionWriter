package pw2.midimap;
import javax.sound.midi.InvalidMidiDataException;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.ShortMessage;
public class OutputBehavior {
  MidiMessage message;
  public OutputBehavior(MidiMessage message_) {
    message = message_;
  }
  public void execute(long timeStamp, Device device, int velocity) {//first, and only one parameter is data2.
    if (device.outputReceiver == null) {
      return;
    }
    ShortMessage message_ = (ShortMessage)message;
    try {
      System.out.println("send "+message_.getData1()+" "+message_.getData2());//debug
      message_.setMessage(message_.getCommand(), message_.getChannel(), message_.getData1(), velocity);
      device.outputReceiver.send(message_, timeStamp);
    } catch (InvalidMidiDataException e) {
      //no happens!!
    }
  }
}
