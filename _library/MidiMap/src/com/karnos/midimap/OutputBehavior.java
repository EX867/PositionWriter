package com.karnos.midimap;
import javax.sound.midi.ShortMessage;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.Receiver;
import javax.sound.midi.InvalidMidiDataException;
public class OutputBehavior {
  Receiver receiver;
  MidiMessage message;
  public OutputBehavior(Receiver receiver_, MidiMessage message_) {
    receiver=receiver_;
    message=message_;
  }
  public void execute(int data2, long timeStamp) {//data2 means just shortmessage...
    if (receiver==null) {
      return;
    }
    ShortMessage message_=(ShortMessage)message;
    try {
      message_.setMessage(message_.getCommand(), message_.getChannel(), message_.getData1(), data2);
      receiver.send(message_, timeStamp);
    }
    catch(InvalidMidiDataException e) {
      //no happens!!
    }
  }
}
