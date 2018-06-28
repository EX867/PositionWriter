package pw2.midimap;
import processing.core.PApplet;
import processing.data.XML;

import javax.sound.midi.*;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
public class Device implements Receiver {
  static HashMap<String, InputBehavior> inputMap = new HashMap<>(101);
  static HashMap<String, OutputBehavior> outputMap = new HashMap<>(101);//why this is here?
  public static void addInput(String command, InputBehavior behavior) {
    inputMap.put(command, behavior);
  }
  public static void addOutput(String commandFull, OutputBehavior behavior) {
    outputMap.put(commandFull, behavior);
  }
  //
  public static PApplet applet = null;
  //
  public static final String DEFAULT_DEVICEMAP = "default";
  public static final String DEFAULT_STATE = "default";
  public static String state = DEFAULT_STATE;
  public static ArrayList<Device> devices = new ArrayList<>();
  public static void setBase(PApplet applet_) {
    if (applet == null) {
      applet = applet_;
      //initialize defaults
      Device.addInput("defaultPress", (MidiMessage msg, long timeStamp, Device device, int... params) -> {
        if (params.length == 1) {
          System.out.println("input note : " + params[0]);
        }
      });
    }
  }
  public static String reloadDevices(String path) {//https://stackoverflow.com/questions/6937760/java-getting-input-from-midi-keyboard
    StringBuilder ret = new StringBuilder();
    int count = 0;
    if ((path.endsWith("/") || path.endsWith("\\"))) {
      path = path.substring(0, path.length() - 1);
    }
    MidiDevice device;
    MidiDevice.Info[] MidiDevices = MidiSystem.getMidiDeviceInfo();
    ArrayList<Receiver> MidiReceivers = new ArrayList<>();
    HashMap findIndexByName = new HashMap<String, Integer>();
    System.out.println();
    //
    for (int i = 0; i < MidiDevices.length; i++) {
      try {
        device = MidiSystem.getMidiDevice(MidiDevices[i]);
        String name = device.getDeviceInfo().toString();
        //
        //does the device have any transmitters? - if it does, add it to the device list
        System.out.print("[MidiMap] " + MidiDevices[i]);
        findIndexByName.put(name, (Integer)findIndexByName.getOrDefault(name, -1) + 1);
        //
        //find deviceMap
        String deviceMapPath = path + "/" + name + ".xml";
        if (!new File(deviceMapPath).isFile()) {
          deviceMapPath = path + "/" + DEFAULT_DEVICEMAP + ".xml";
          if (!new File(deviceMapPath).isFile()) {
            ret.append(name).append("(X), ");
            System.out.println(" - deviceMap not exists");
            continue;
          }
        }
        //
        Device d = null;
        if (device.getMaxReceivers() == -1) {
          Receiver receiver = device.getReceiver();
          if (receiver != null) {
            System.out.println(" - out connected");
            ret.append(name).append("(out), ");
            //
            if (d == null) {
              d = new Device(name, (Integer)findIndexByName.get(name));
            }
            d.enableOutput(receiver);
            d.loadOutputMap(deviceMapPath);
            device.open();//???
            continue;//one output device(in java midi device) can't receive input because I don't know other situations.
          }
        }
        Transmitter trans = device.getTransmitter();//if no input available, error is come out from here.
        if (d == null) {
          d = new Device(name, (Integer)findIndexByName.get(name));
        }
        d.enableInput();
        d.loadInputMap(deviceMapPath);
        //
        trans.setReceiver(d);//this is not nessessary (because getTransmitters() contains getTransmitter())
        List<Transmitter> transmitters = device.getTransmitters();//get all transmitters
        for (int j = 0; j < transmitters.size(); j++) {//and for each transmitter
          transmitters.get(j).setReceiver(d);
        }
        device.open();//open each device
        //
        System.out.println(" - in connected");
        ret.append(name).append("(in), ");
      } catch (MidiUnavailableException e) {
        System.out.println(" - Failed!");
      }
    }
    System.out.println();
    if (count == 0) return "No midi devices detected.";
    return ret.toString();
  }
  protected void loadInputMap(String path) throws RuntimeException {//get file path, must be xml.
    stateInputMap.clear();
    if (applet == null) {
      System.out.println("[MidiMap] applet not initialized.");
      return;
    }
    //<index_0> - index(same device index)
    //  <state value="8x8"> - state is just a string
    //    <input code="NOTE_ON" data=21>press:8:8</input>//this is parsed with commandParser (seperate with :)
    //    <output code="NOTE_ON" channel=0 data=21>led:8:8</output>
    //  <state value="0"> - defualt state.
    if (!new File(path).isFile()) {
      throw new RuntimeException("[MidiMap] path is incorrect");
    }
    if (path.endsWith(".xml")) {
      XML deviceXml = applet.loadXML(path);
      XML indexXml = deviceXml.getChild("index_" + sameDeviceIndex);
      if (indexXml == null) {
        indexXml = indexXml.getChild("index_0");
      }
      if (indexXml == null) return;
      //
      XML[] states = indexXml.getChildren("state");
      for (XML xml : states) {
        MidiInputMap map;
        stateInputMap.put(xml.getString("value"), map = new MidiInputMap());//last one is loaded.
        //
        XML[] commands = xml.getChildren("input");
        for (XML command : commands) {
          String code = command.getString("code");
          if (code.equals("NOTE_ON")) {//this means, available commands for this module. this is written for positionwriter...so only i need is note_on and note_off.
            map.setNoteOn(command.getInt("data"), new MidiInputCommand(command.getContent()));
          } else if (code.equals("NOTE_OFF")) {
            map.setNoteOff(command.getInt("data"), new MidiInputCommand(command.getContent()));
          } else {
            continue;//ignore
          }
        }
      }
    }
  }
  protected void loadOutputMap(String path) throws RuntimeException {//get file path, must be xml.
    if (applet == null) return;//sorry...this is not a good idea
    if (!new File(path).isFile()) {
      throw new RuntimeException("[MidiMap] path is incorrect");
    }
    if (path.endsWith(".xml")) {
      XML deviceXml = applet.loadXML(path);
      XML indexXml = deviceXml.getChild("index_" + sameDeviceIndex);
      if (indexXml == null) {
        indexXml = indexXml.getChild("index_0");
      }
      if (indexXml == null) return;
      //
      XML[] states = indexXml.getChildren("state");
      for (XML xml : states) {
        String stateValue = xml.getString("value");
        XML[] commands = xml.getChildren("output");
        for (XML command : commands) {
          String code = command.getString("code");
          int code_ = 0;
          if (code.equals("NOTE_ON")) {//now, there is only note_on for output (because for now, there is only lauchpad to output.
            code_ = ShortMessage.NOTE_ON;
          } else if (code.equals("CONTROL_CHANGE")) {//now, there is only note_on for output (because for now, there is only lauchpad to output.
            code_ = ShortMessage.CONTROL_CHANGE;
          } else {
            continue;//ignore
          }//I will add sysex message later.
          MidiMessage message;
          try {
            //if(code!=SYSEX){SYSEX will be constant
            message = new ShortMessage(code_, command.getInt("channel"), command.getInt("data"), 0);//data2 varies.
            Device.addOutput(/*add state to name*/stateValue + ":" + command.getContent(), new OutputBehavior(message));//direct add.is note_on and note_off.
            //}
          } catch (InvalidMidiDataException e) {
            e.printStackTrace();
          }
        }
      }
    }
  }
  public static void setState(String state_) {//change state, also activate midimap.
    for (Device device : devices) {
      device.setState_(state_);
    }
  }
  //
  HashMap<String, MidiInputMap> stateInputMap = new HashMap<>(101);
  MidiInputMap currentInputMap = null;
  public String name;
  public int sameDeviceIndex = 0;
  protected boolean input = false;
  protected boolean output = false;
  protected javax.sound.midi.Receiver outputReceiver = null;//if not null, this Device can output.
  public Device(String name_, int sameDeviceIndex_) {
    name = name_;
    sameDeviceIndex = sameDeviceIndex_;
    devices.add(this);
  }
  protected void enableOutput(Receiver outputReceiver_) {
    output = true;
    outputReceiver = outputReceiver_;//enable output
  }
  protected void enableInput() {
    input = true;
  }
  protected void setState_(String state_) {
    System.out.println("[MidiMap] " + name + " changed to state " + state_);
    if (stateInputMap.containsKey(state_)) {
      currentInputMap = stateInputMap.get(state_);
    } else if (stateInputMap.containsKey(DEFAULT_STATE)) {//if no state is find, try default state.
      currentInputMap = stateInputMap.get(DEFAULT_STATE);
    } else {//no state is finded...
      currentInputMap = null;
    }
  }
  public void output(String command, int velocity, int... params) {
    StringBuilder builder = new StringBuilder(command);
    for (int i : params) {
      builder.append(":").append(i);
    }
    OutputBehavior outputBehavior = Device.outputMap.get(state + ":" + builder.toString());
    if (outputBehavior == null) {
      outputBehavior = Device.outputMap.get(DEFAULT_STATE + ":" + builder.toString());
    }
    if (outputBehavior != null) {
      outputBehavior.execute(-1, this, velocity);
    }
  }
  public void send(MidiMessage msg, long timeStamp) {
    currentInputMap.execute(msg, timeStamp, this);
  }
  public void close() {
    if (outputReceiver != null) {
      outputReceiver.close();
    }
  }
}
