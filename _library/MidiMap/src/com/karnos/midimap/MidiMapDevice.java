package com.karnos.midimap;
import javax.sound.midi.*;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;
import java.io.File;
import processing.data.XML;
import processing.core.PApplet;
public class MidiMapDevice implements Receiver {//this module ignores channel.
  protected static PApplet applet;//to use PApplet functions...(this is very bad idea) -
  protected static final HashMap<String, MidiMapDevice> devices=new HashMap<String, MidiMapDevice>();
  protected static final ArrayList<MidiMapDevice> devices_array=new ArrayList<MidiMapDevice>();

  public static final String DEFAULT_STATE="default";
  public static String state=DEFAULT_STATE;//you don't need to parse this

  public String name;//device's name.
  public int index;//starts from 0.

  protected boolean input=false;
  protected boolean output=false;

  protected HashMap<String, MidiMap> midiMaps;
  protected MidiMap midiMap;//current activated midimap.

  protected javax.sound.midi.Receiver outputReceiver=null;//if not null, this MapDevice can output.

  protected static MidiMapDevice createDevice(String name_, int index_) {//name is (device name):(index).
    String indexedName=name_+":"+index_;
    if (devices.containsKey(indexedName))return devices.get(indexedName);
    devices.put(indexedName, new MidiMapDevice(indexedName));
    MidiMapDevice d=devices.get(indexedName);
    devices_array.add(d);
    return d;
  }
  protected MidiMapDevice(String name_) {
    name=name_;
    midiMaps=new HashMap<String, MidiMap>();
  }
  public static MidiMapDevice enableInput(String name_, String mapFile, int index_) {
    MidiMapDevice d=createDevice(name_, index_);
    d.enableInput(mapFile);
    d.index=index_;//this have to allow you can change this later...but I did not implemented yet.
    d.input=true;
    return d;
  }
  protected void enableInput(String mapFile)throws RuntimeException {
    loadInputMap(mapFile, index);
    setState(state);
  }
  public static MidiMapDevice enableOutput(String name_, String mapFile, javax.sound.midi.Receiver outputReceiver_, int index_) {
    MidiMapDevice d=createDevice(name_, index_);
    d.enableOutput(mapFile, outputReceiver_);
    d.index=index_;
    d.output=true;
    return d;
  }
  protected void enableOutput(String mapFile, javax.sound.midi.Receiver outputReceiver_) {
    outputReceiver=outputReceiver_;//enable output
    loadOutputMap(mapFile, index);
    setState(state);
  }
  protected void loadInputMap(String path, int index) throws RuntimeException {//get file path, must be xml.
    if (applet==null)return;//sorry...this is not a good idea
    //<index_0> - index
    //  <state value="8x8"> - state is just a string
    //    <input code="NOTE_ON" data=21>press:8:8</input>//this is parsed with commandParser (seperate with :)
    //    <output code="NOTE_ON" channel=0 data=21>led:8:8</output>
    //  <state value="0"> - defualt state.
    if (new File(path).isFile()==false) {
      throw new RuntimeException("[MidiMap] path is incorrect");
    }
    if (getFileExtension(path).equals("xml")) {
      XML xml_=applet.loadXML(path);
      XML xml__=xml_.getChild("index_"+index);
      if (xml__==null) {
        xml__=xml_.getChild("index_0");
        if (xml__==null)return;
      }
      XML[] states=xml__.getChildren("state");
      for (XML xml : states) {
        if (midiMaps.containsKey(xml.getString("value"))==false) {
          midiMaps.put(xml.getString("value"), new MidiMap(xml.getString("value")));
        }
        MidiMap map=midiMaps.get(xml.getString("value"));
        XML[] commands=xml.getChildren("input");
        for (XML command : commands) {
          String code=command.getString("code");
          if (code.equals("NOTE_ON")) {//this means, available commands for this module. this is written for positionwriter...so only i need is note_on and note_off.
            map.setNoteOn(command.getInt("data"), new MidiCommand(command.getContent()));
          } else if (code.equals("NOTE_OFF")) {
            map.setNoteOff(command.getInt("data"), new MidiCommand(command.getContent()));
          } else {
            continue;//ignore
          }
        }
      }
    }
  }
  protected void loadOutputMap(String path, int index) throws RuntimeException {//get file path, must be xml.
    if (applet==null)return;//sorry...this is not a good idea
    if (new File(path).isFile()==false) {
      throw new RuntimeException("[MidiMap] path is incorrect");
    }
    if (getFileExtension(path).equals("xml")) {
      XML xml_=applet.loadXML(path);
      XML xml__=xml_.getChild("index_"+index);
      if (xml__==null) {
        xml__=xml_.getChild("index_0");
        if (xml__==null)return;
      }
      XML[] states=xml__.getChildren("state");
      for (XML xml : states) {
        String stateValue=xml.getString("value");
        //if (midiMaps.containsKey(xml.getString("value"))==false) {
        //  midiMaps.put(new MidiMap(xml.getString("value")));
        //}
        //MidiMap map=midiMaps.get(xml.getString("value"));
        XML[] commands=xml.getChildren("output");
        for (XML command : commands) {
          String code=command.getString("code");
          int code_=0;
          if (code.equals("NOTE_ON")) {//now, there is only note_on for output (because for now, there is only lauchpad to output.
            code_=ShortMessage.NOTE_ON;
          } else if (code.equals("CONTROL_CHANGE")) {//now, there is only note_on for output (because for now, there is only lauchpad to output.
            code_=ShortMessage.CONTROL_CHANGE;
          } else {
            continue;//ignore
          }//I will add sysex message later.
          MidiMessage message;
          try {
            //if(code!=SYSEX){SYSEX will be constant
            message=new ShortMessage(code_, command.getInt("channel"), command.getInt("data"), 0);//data2 varies.
            MidiCommand.addOutput(/*add state to name*/stateValue+":"+command.getContent(), new OutputBehavior(outputReceiver, message));//direct add.is note_on and note_off.
            //}
          }
          catch(InvalidMidiDataException e) {
            e.printStackTrace();
          }
        }
      }
    }
  }
  public void setState(String state_)throws IllegalStateException {//change state, also activate midimap.
    System.out.println("[MidiMap] "+name+" changed to state "+state_);
    if (midiMaps.containsKey(state_)) {
      midiMap=midiMaps.get(state_);
      return;
    } else if (midiMaps.containsKey(DEFAULT_STATE)) {//if no state is find, try default state.
      midiMap=midiMaps.get(DEFAULT_STATE);
      return;
    }
    //no state is finded...
    throw new IllegalStateException("default state is not available.");
  }
  public void send(MidiMessage msg, long timeStamp) {
    midiMap.execute(msg, timeStamp);
  }
  public void close() {
  }
  static String reloadDevices(String path) {//https://stackoverflow.com/questions/6937760/java-getting-input-from-midi-keyboard
    String ret="";
    int count=0;
    path=path.trim().replace('\\','/');
    if(path.length()>0&&path.charAt(path.length()-1)=='/'){
      path=path.substring(0,path.length()-1);
    }
    MidiDevice device;
    MidiDevice.Info[] MidiDevices = MidiSystem.getMidiDeviceInfo();
    ArrayList<Receiver> MidiReceivers=new ArrayList<Receiver>();
    HashMap inmap=new HashMap<String, Integer>();
    HashMap outmap=new HashMap<String, Integer>();
    System.out.println();
    for (int i = 0; i < MidiDevices.length; i++) {
      try {
        device = MidiSystem.getMidiDevice(MidiDevices[i]);
        String name=device.getDeviceInfo().toString();
        //does the device have any transmitters? - if it does, add it to the device list
        System.out.print("[MidiMap] Checking "+MidiDevices[i]+"...");
        if (outmap.containsKey(name)==false)outmap.put(name, 0);
        if (inmap.containsKey(name)==false)inmap.put(name, 0);

        String path_=path+"/"+name+".xml";//check if this device is supported...
        if (new File(path_).isFile()==false) {
          ret+=name+"(X), ";
          System.out.println(" - Ignored");
          continue;
        }

        if (device.getMaxReceivers()==-1) {
          Receiver receiver=device.getReceiver();
          if (receiver!=null) {
            System.out.println(" - out connected");
            ret+=name+"(out), ";
            MidiMapDevice d=MidiMapDevice.enableOutput(name, path_, receiver, (Integer)outmap.get(name));
            device.open();
            outmap.put(name, (Integer)outmap.get(name)+1);//index++
            continue;//one output device(in java midi device) can't receive input because I don't know other situations.
          }
        }

        Transmitter trans = device.getTransmitter();//if no input available, error is come out from here.
        MidiMapDevice d=MidiMapDevice.enableInput(name, path_, (Integer)inmap.get(name));

        trans.setReceiver(d);//this is not nessessary (because getTransmitters() contains getTransmitter())
        List<Transmitter> transmitters = device.getTransmitters();//get all transmitters
        for (int j = 0; j<transmitters.size(); j++) {//and for each transmitter
          transmitters.get(j).setReceiver(d);
        }

        device.open();//open each device

        MidiReceivers.add(d);//to detect input devices
        inmap.put(name, (Integer)inmap.get(name)+1);//index++
        ret+=name+"(in), ";
        System.out.println(" - in connected");
      }
      catch (MidiUnavailableException e) {
        System.out.println(" - Failed!");
      }
    }
    System.out.println();
    if (count==0)return "No midi devices detected.";
    return ret;
  }
  private static String getFileExtension(String filename) {
    if (filename.equals(""))return "";
    String[] words;
    words=filename.split("\\.");
    if (words.length>1)return words[words.length-1];
    else return "";
  }
}
