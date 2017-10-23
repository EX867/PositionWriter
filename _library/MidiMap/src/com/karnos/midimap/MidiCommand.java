package com.karnos.midimap;
import javax.sound.midi.*;
import java.util.HashMap;
import processing.core.PApplet;
public class MidiCommand {
  protected static final HashMap<String, InputBehavior> inputBehaviors=new HashMap<String, InputBehavior>();
  protected static final HashMap<String, OutputBehavior> outputBehaviors=new HashMap<String, OutputBehavior>();
  public String name;
  public int[] params;
  public static void setBase(PApplet applet_) {//this is for MidiMapDevice, but if this is in there,user have to import MidiMapDevice too.
    MidiMapDevice.applet=applet_;
  }
  public static void setState(String state) {
    MidiMapDevice.state=state;
    for (MidiMapDevice device : MidiMapDevice.devices_array) {
      device.setState(state);
    }
  }
  public MidiCommand(String content) {//inputCommand
    String[] tokens=content.split(":");
    if (tokens.length==0)throw new RuntimeException("[MidiMap] command is not correct!!");
    name=tokens[0];
    params=new int[tokens.length-1];
    for (int a=0; a<params.length; a++) {
      if (isInt(tokens[a+1]))params[a]=Integer.parseInt(tokens[a+1]);
    }
  }
  public static void addInput(String commandName, InputBehavior behavior) {
    inputBehaviors.put(commandName, behavior);//if duplicated, overwrited.
  }
  public static void addOutput(String commandName, OutputBehavior behavior) {
    outputBehaviors.put(commandName, behavior);
  }
  protected void execute(MidiMessage msg, long timeStamp) {
    InputBehavior behavior=inputBehaviors.get(name);
    if (behavior!=null) {//if null, ignore
      behavior.execute(msg, timeStamp, params);
    }
  }
  public static void execute(String commandName, int data2, int... params_) {//fix this later to implement sysex. data1 should changed to other data.
    //get state of midimapdevice directly...(because it's static)
    StringBuilder builder=new StringBuilder(commandName);
    for (int a=0; a<params_.length; a++) {
      builder.append(":").append(params_[a]);
    }
    OutputBehavior behavior=outputBehaviors.get(MidiMapDevice.state+":"+builder.toString());
    if (behavior==null) {
      behavior=outputBehaviors.get(MidiMapDevice.DEFAULT_STATE+":"+builder.toString());
      if (behavior==null) {
        return;//just ignore...
      }
    }
    behavior.execute(data2, -1);//for now, timeStamp is fixed to -1. because I don't need it.
  }
  /*public static void execute(String commandString, int data2) {
  }*/
  public static String reloadDevices(String path){
    return MidiMapDevice.reloadDevices(path);
  }
  public static void main(String[] args){
    System.out.println("MidiCommand class files");
  }
  private static boolean isInt(String str) {
    if (str.equals("")) return false;
    if (str.length() > 9) return false;
    if (str.equals("-"))return false;
    int a = 0;
    if (str.charAt(0) == '-') a = 1;
    while (a < str.length()) {
      if (('0' <= str.charAt(a) && str.charAt(a) <= '9') == false)return false;
      a = a + 1;
    }
    return true;
  }
}
