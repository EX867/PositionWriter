package pw2.midimap;
import processing.core.PApplet;
import processing.data.XML;

import javax.sound.midi.*;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
public class Device implements Receiver {

  static HashMap<String, InputBehavior> inputMap=new HashMap<>(101);
  protected HashMap<String, OutputBehavior> outputMap=new HashMap<>(101);//why this is here?

  public static void addInput(String command, InputBehavior behavior) {
    inputMap.put(command, behavior);
  }

  public void addOutput(String commandFull, OutputBehavior behavior) {
    outputMap.put(commandFull, behavior);
  }

  //
  public static PApplet applet=null;
  //
  public static final String DEFAULT_DEVICEMAP="default";
  public static final String DEFAULT_STATE="default";
  public static ArrayList<Device> devices=new ArrayList<>();

  public static void setBase(PApplet applet_) {
    if (applet == null) {
      applet=applet_;

      Device.addInput("NOTE_ON", (MidiMessage msg, long timeStamp, Device device, int... params) -> {
        if (params.length == 1) {
          //System.out.println("input note : " + params[0]);
        }
      });
    }
  }

  public static String reloadDevices(String path) {
    if (applet == null) {
      System.out.println("[MidiMap] applet not initialized.");

      return "setBase needed";
    }
    if ((path.endsWith("/") || path.endsWith("\\"))) {
      path=path.substring(0, path.length() - 1);
    }
    ArrayList<Receiver> MidiReceivers=new ArrayList<>();

    for (MidiDevice.Info midiDevice : MidiSystem.getMidiDeviceInfo()) {
      try {
        MidiDevice device=MidiSystem.getMidiDevice(midiDevice);
        String name=device.getDeviceInfo().toString();
        System.out.print("[MidiMap] " + midiDevice);

        String deviceMapPath=path + "/" + name + ".xml";
        if (!new File(deviceMapPath).isFile()) {
          deviceMapPath=path + "/" + DEFAULT_DEVICEMAP + ".xml";
          if (!new File(deviceMapPath).isFile()) {
            System.out.println(" - deviceMap not exists");
            continue;
          }
        } else {
          System.out.print(" - (custom devicemap)");
        }

        Device d=Device.getDeviceByName(name);
        if (device.getMaxReceivers() == -1) {
          Receiver receiver=device.getReceiver();
          if (receiver != null) {
            System.out.println(" - out connected");
            //
            if (d == null || d.hasOutput) {
              if (d != null) name=name + "_";//avoid duplicate temp
              d=new Device(name);
            }
            d.enableOutput(receiver);
            d.loadOutputMap(deviceMapPath);
            device.open();
            continue;//one output device(in java midi device) can't receive input because I don't know other situations.
          }
        }

        Transmitter trans=device.getTransmitter();//if no input available, error is come out from here.

        if (d == null || d.hasInput) {
          if (d != null) name=name + "_";//avoid duplicate temp
          d=new Device(name);
        }
        d.enableInput();
        d.loadInputMap(deviceMapPath);
        //
        for (Transmitter t : device.getTransmitters()) {
          t.setReceiver(d);
        }
        device.open();//open each device
        //
        System.out.println(" - in connected");
      } catch (MidiUnavailableException e) {
        System.out.println("->Failed!");
      }
    }
    System.out.println();
    return "midi devices reloaded!";
  }

  protected void loadInputMap(String path) {

    //<state value="8x8"> - state is just a string
    //  <input code="NOTE_ON" data=21>press:8:8</input>//this is parsed with commandParser (seperate with :)
    //  <output code="NOTE_ON" channel=0 data=21>led:8:8</output>
    //<state value="0"> - defualt state.

    if (!path.endsWith(".xml")) {
      throw new RuntimeException("[MidiMap] Not an xml file.");
    }
    stateInputMap.clear();

    for (XML xml : applet.loadXML(path).getChildren("state")) {
      MidiInputMap map=new MidiInputMap();
      stateInputMap.put(xml.getString("value"), map);//last one is loaded

      for (XML command : xml.getChildren("input")) {
        String code=command.getString("code");

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

  protected void loadOutputMap(String path){

    if (!path.endsWith(".xml")) {
      throw new RuntimeException("[MidiMap] Not an xml file.");
    }
    outputMap.clear();

      for (XML xml : applet.loadXML(path).getChildren("state")) {
        String stateValue=xml.getString("value");

        for (XML command : xml.getChildren("output")) {
          String code=command.getString("code");

          int code_=0;
          if (code.equals("NOTE_ON")) {//now, there is only note_on for output (because for now, there is only lauchpad to output.
            code_=ShortMessage.NOTE_ON;
          } else if (code.equals("CONTROL_CHANGE")) {//now, there is only note_on for output (because for now, there is only lauchpad to output.
            code_=ShortMessage.CONTROL_CHANGE;
          } else if (code.equals("NOTE_OFF")) {
            code_=ShortMessage.NOTE_OFF;
          } else {
            continue;//ignore
          }

          try {
            MidiMessage message=new ShortMessage(code_, command.getInt("channel"), command.getInt("data"), 0);//data2 varies
            addOutput(stateValue + ":" + command.getContent(), new OutputBehavior(message));
          } catch (InvalidMidiDataException e) {
            e.printStackTrace();
          }
        }
    }
  }

  public static Device getDeviceByName(String name) {
    for (Device d : devices) {
      if (d.name.equals(name)) {
        return d;
      }
    }
    return null;
  }

  public static void setStateAll(String state_) {//change state, also activate midimap.
    for (Device device : devices) {
      device.setState(state_);
    }
  }

  public void setState(String state_) {
    if (stateInputMap.containsKey(state_)) {
      state=state_;
      System.out.println("[MidiMap] " + name + " changed to state " + state);
      currentInputMap=stateInputMap.get(state);
    } else if (stateInputMap.containsKey(DEFAULT_STATE)) {//if no state is find, try default state.
      state=DEFAULT_STATE;
      System.out.println("[MidiMap] " + name + " changed to state default");
      currentInputMap=stateInputMap.get(DEFAULT_STATE);
    } else {
      System.out.println("[MidiMap] " + name + " state not found");
      currentInputMap=null;
    }
  }

  //
  HashMap<String, MidiInputMap> stateInputMap=new HashMap<>(101);
  MidiInputMap currentInputMap=null;
  public String name;
  public String state=DEFAULT_STATE;
  public boolean hasInput=false;
  public boolean hasOutput=false;
  protected javax.sound.midi.Receiver outputReceiver=null;//if not null, this Device can output.

  public Device(String name_) {
    name=name_;
    devices.add(this);
  }

  protected void enableOutput(Receiver outputReceiver_) {
    hasOutput=true;
    outputReceiver=outputReceiver_;//enable output
  }

  protected void enableInput() {
    hasInput=true;
  }

  public void output(String command, int velocity, int... params) {
    StringBuilder builder=new StringBuilder(command);
    for (int i : params) {
      builder.append(":").append(i);
    }
    OutputBehavior outputBehavior;
    if (stateInputMap.containsKey(state)) {
      outputBehavior=outputMap.get(state + ":" + builder.toString());
    } else {
      outputBehavior=outputMap.get(DEFAULT_STATE + ":" + builder.toString());
    }
    if (outputBehavior != null) {
      outputBehavior.execute(-1, this, velocity);
    }
  }

  public void send(MidiMessage msg, long timeStamp) {
    if (currentInputMap == null) return;
    currentInputMap.execute(msg, timeStamp, this);
  }

  public void close() {
    if (outputReceiver != null) {
      outputReceiver.close();
    }
  }
}
