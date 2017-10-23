package com.karnos.midimap;
import javax.sound.midi.MidiMessage;
public interface InputBehavior {//extend this and send parameter
  public void execute(MidiMessage msg, long timeStamp, int[] params);
}
