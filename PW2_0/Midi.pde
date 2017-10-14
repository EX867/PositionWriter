public static class MidiMapDevice implements javax.sound.midi.Receiver {//this module ignores channel.
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
      XML xml__=xml_.getChild("index_"+str(index));
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
      XML xml__=xml_.getChild("index_"+str(index));
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
    println("[MidiMap] "+name+" changed to state "+state_);
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
}
public static class MidiMap {//link int (midi data1) -> MidiCommands
  String state;
  MidiCommand[] note_on;
  MidiCommand[] note_off;
  public MidiMap(String state_) {
    state=state_;//find when state changed.
    println("[MidiMap] new MidiMap created : "+state);
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
public static/*delete*/ class MidiCommand {
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
  public static void execute(String commandString, int data2) {
  }
}
public static /*delete*/interface InputBehavior {//extend this and send parameter
  public void execute(MidiMessage msg, long timeStamp, int[] params);
}
public static /*delete*/class OutputBehavior {
  javax.sound.midi.Receiver receiver;
  MidiMessage message;
  public OutputBehavior(javax.sound.midi.Receiver receiver_, MidiMessage message_) {
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

void reloadMidiDevices() {//https://stackoverflow.com/questions/6937760/java-getting-input-from-midi-keyboard
  String path=joinPath(GlobalPath, MidiPath);
  MidiDevice device;
  MidiDevice.Info[] MidiDevices = MidiSystem.getMidiDeviceInfo();
  ArrayList<javax.sound.midi.Receiver> MidiReceivers=new ArrayList<javax.sound.midi.Receiver>();
  HashMap inmap=new HashMap<String, Integer>();
  HashMap outmap=new HashMap<String, Integer>();
  for (int i = 0; i < MidiDevices.length; i++) {
    try {
      device = MidiSystem.getMidiDevice(MidiDevices[i]);
      //does the device have any transmitters? - if it does, add it to the device list
      println("[MidiMap] Checking "+MidiDevices[i]+"...");
      if (outmap.containsKey(device.getDeviceInfo().toString())==false)outmap.put(device.getDeviceInfo().toString(), 0);
      if (inmap.containsKey(device.getDeviceInfo().toString())==false)inmap.put(device.getDeviceInfo().toString(), 0);

      String path_=joinPath(path, device.getDeviceInfo().toString()+".xml");//check if this device is supported...
      if (new File(path_).isFile()==false) {
        println(" - Ignored");
        continue;
      }

      if (device.getMaxReceivers()==-1) {
        javax.sound.midi.Receiver receiver=device.getReceiver();
        if (receiver!=null) {
          println(" - out connected");
          MidiMapDevice d=MidiMapDevice.enableOutput(device.getDeviceInfo().toString(), path_, receiver, (Integer)outmap.get(device.getDeviceInfo().toString()));
          device.open();
          outmap.put(device.getDeviceInfo().toString(), (Integer)outmap.get(device.getDeviceInfo().toString())+1);//index++
          continue;//one output device(in java midi device) can't receive input because I don't know other situations.
        }
      }

      Transmitter trans = device.getTransmitter();//if no input available, error is come out from here.
      MidiMapDevice d=MidiMapDevice.enableInput(device.getDeviceInfo().toString(), path_, (Integer)inmap.get(device.getDeviceInfo().toString()));

      trans.setReceiver(d);//this is not nessessary (because getTransmitters() contains getTransmitter())
      List<Transmitter> transmitters = device.getTransmitters();//get all transmitters
      for (int j = 0; j<transmitters.size(); j++) {//and for each transmitter
        transmitters.get(j).setReceiver(d);
      }

      device.open();//open each device

      MidiReceivers.add(d);//to detect input devices
      inmap.put(device.getDeviceInfo().toString(), (Integer)inmap.get(device.getDeviceInfo().toString())+1);//index++
      println(" - in connected");
    } 
    catch (MidiUnavailableException e) {
      println(" - Failed!");
    }
  }
  if (MidiReceivers.size()>0) {
    int a=1;
    String sum=((MidiMapDevice)MidiReceivers.get(0)).name;
    while (a<MidiReceivers.size()) {
      sum=sum+", "+((MidiMapDevice)MidiReceivers.get(0)).name;
      a=a+1;
    }
    setStatusR("Devices : "+sum);
  } else {
    setStatusR("No midi devices detected.");
  }
}
String midiToLed(String path) {
  String ret="//"+getFileName(path);
  try {
    Sequence sequence = MidiSystem.getSequence(new File(path));
    Track[] tracks=sequence.getTracks();
    for (int t=0; t<tracks.length; t++) {
      Track track=tracks[t];//usually,first track is meta track.
      //It will make tracks.length sequences and while reading, it will merge all tracks.
      //convert tick to delay...
      for (int i=0; i < track.size(); i++) {
        MidiEvent event = track.get(i);
        System.out.print("@" + event.getTick() + " - ");
        MidiMessage message_ = event.getMessage();
        if (message_ instanceof ShortMessage) {
          ShortMessage message=(ShortMessage)message_;
          println("ShortMessage : "+message.getCommand()+" "+message.getData1()+" "+message.getData2());
        } else if (message_ instanceof MetaMessage) {
          MetaMessage message=(MetaMessage)message_;
          if (message.getType()==0x58) {//Time Signature
            int numerator=message.getData()[0];
            int denominator=message.getData()[1];
            int ticksPerClick=message.getData()[2];
            int notes32PerQuarter=message.getData()[3];
            println("Time Signature : "+numerator+"/"+denominator+" "+ticksPerClick+"-"+notes32PerQuarter);
          } else if (message.getType()==0x51) {//Set Tempo
            long bpm=60000000/(256*256*message.getData()[0]+256*message.getData()[1]+message.getData()[2]);
            println("Set Tempo : "+bpm);
          }
        }
      }
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  return ret;
}