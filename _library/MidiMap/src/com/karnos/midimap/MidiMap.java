package com.karnos.midimap;
import javax.sound.midi.ShortMessage;
import javax.sound.midi.MidiMessage;
public class MidiMap {//link int (midi data1) -> MidiCommands
  String state;
  MidiCommand[] note_on;
  MidiCommand[] note_off;
  public MidiMap(String state_) {
    state=state_;//find when state changed.
    System.out.println("[MidiMap] new MidiMap created : "+state);
  }
  public void setNoteOn(int data, MidiCommand command) {//data1 works like trigger...
    if (note_on==null)note_on=new MidiCommand[128];
    note_on[data]=command;
  }
  public void setNoteOff(int data, MidiCommand command) {
    if (note_off==null)note_off=new MidiCommand[128];
    note_off[data]=command;
  }
  public void execute(MidiMessage msg, long timeStamp) {
    if (msg instanceof ShortMessage) {
      ShortMessage info=(ShortMessage)msg;
      if (info.getCommand()==ShortMessage.NOTE_ON) {
        //println("note on : "+info.getChannel()+"/"+info.getData1()+" "+info.getData2());
        if (note_on[info.getData1()]!=null)note_on[info.getData1()].execute(msg, timeStamp);
      } else if (info.getCommand()==ShortMessage.NOTE_OFF) {
        //println("note off : "+info.getChannel()+"/"+info.getData1()+" "+info.getData2());
        if (note_off[info.getData1()]!=null)note_off[info.getData1()].execute(msg, timeStamp);
      }
    }
  }
}
