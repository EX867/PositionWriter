public class MidiMapDevice implements javax.sound.midi.Receiver {//this module ignores channel.
  public static final String DEFAULT_STATE="default";

  public String name;//device's name.
  public int index;//starts from 0.
  public String state=DEFAULT_STATE;//you don't need to parase this

  public ArrayList<MidiMap> midiMaps;
  MidiMap midiMap;//current activated midimap.

  public MidiMapDevice(String name_, String mapFile, int index_)throws RuntimeException {
    name=name_;
    index=index_;//this have to allow you can change this later...but I did not implemented yet.
    midiMaps=new ArrayList<MidiMap>();
    loadMap(mapFile, index_);
    changeState(DEFAULT_STATE);
  }
  protected void loadMap(String path, int index) throws RuntimeException {//get file path, must be xml.
    //<index_0> - index
    //  <state value="8x8"> - state is just a string
    //    <input code="NOTE_ON" data=21>press:8:8</input>//this is parsed with commandParser (seperate with :)
    //  <state value="0"> - defualt state.
    if (new File(path).isFile()==false) {
      throw new RuntimeException("[MidiMap] path is incorrect");
    }
    if (getFileExtension(path).equals("xml")) {
      XML xml_=loadXML(path);
      XML xml__=xml_.getChild("index_"+str(index));
      if (xml__==null) {
        xml__=xml_.getChild("index_0");
        if (xml__==null)return;
      }
      XML[] states=xml__.getChildren("state");
      for (XML xml : states) {
        MidiMap map=new MidiMap(xml.getString("value"));
        midiMaps.add(map);
        XML[] commands=xml.getChildren("input");
        for (XML command : commands) {
          String code=command.getString("code");
          if (code.equals("NOTE_ON")) {//this means, available commands for this module. this is written for positionwriter...so only i need is note_on and note_off.
            map.setNoteOn(command.getInt("data"), new MidiCommand(command.getContent()));
          } else if (code.equals("NOTE_OFF")) {
            map.setNoteOff(command.getInt("data"), new MidiCommand(command.getContent()));
          } else {
            //ignore
          }
        }
      }
    }
  }
  public void changeState(String state_)throws IllegalStateException {//change state, also activate midimap.
    state=state_;
    for (MidiMap map : midiMaps) {
      if (state.equals(map.state)) {
        midiMap=map;
        return;
      }
    }
    for (MidiMap map : midiMaps) {//if no state is find, try default state.
      if (state.equals(DEFAULT_STATE)) {
        midiMap=map;
        return;
      }
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
public class MidiMap {//link int (midi data1) -> MidiCommands
  String state;
  MidiCommand[] note_on;
  MidiCommand[] note_off;
  public MidiMap(String state_) {
    state=state_;//find when state changed.
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
  protected static final HashMap<String, CommandBehavior> behaviors=new HashMap<String, CommandBehavior>();
  public String name;
  public int[] params;
  public MidiCommand(String content) {
    String[] tokens=content.split(":");
    if (tokens.length==0)throw new RuntimeException("[MidiMap] command is not correct!!");
    name=tokens[0];
    params=new int[tokens.length-1];
    for (int a=0; a<params.length; a++) {
      if (isInt(tokens[a+1]))params[a]=Integer.parseInt(tokens[a+1]);
    }
  }
  public static void addBehavior(String commandName, CommandBehavior behavior) {
    behaviors.put(commandName, behavior);//if duplicated, overwrited.
  }
  public final void execute(MidiMessage msg, long timeStamp) {
    CommandBehavior behavior=behaviors.get(name);
    if (behavior!=null) {//if null, ignore
      behavior.execute(msg, timeStamp, params);
    }
  }
}
public static /*delete*/interface CommandBehavior {//extend this and send parameter
  public void execute(MidiMessage msg, long timeStamp, int[] params);
}
MidiDevice.Info[] MidiDevices;
ShortMessage sendMidiOut=new ShortMessage();
javax.sound.midi.Receiver SystemReceiver;
void reloadMidiDevices() {//https://stackoverflow.com/questions/6937760/java-getting-input-from-midi-keyboard
  String path=joinPath(GlobalPath, MidiPath);
  MidiDevice device;
  MidiDevices = MidiSystem.getMidiDeviceInfo();
  ArrayList<javax.sound.midi.Receiver> MidiReceivers=new ArrayList<javax.sound.midi.Receiver>();
  HashMap map=new HashMap<String, Integer>();
  for (int i = 0; i < MidiDevices.length; i++) {
    try {
      device = MidiSystem.getMidiDevice(MidiDevices[i]);
      //does the device have any transmitters? - if it does, add it to the device list
      print("[MidiMap] Checking "+MidiDevices[i]+"...");
      if (map.containsKey(device.getDeviceInfo().toString())==false)map.put(device.getDeviceInfo().toString(), 0);

      if (device.getMaxReceivers()==-1) {
        if (device.getDeviceInfo().toString().contains("Launch")) {//test
          SystemReceiver=device.getReceiver();
          if (SystemReceiver!=null) {
            device.open();
            println(" - out connected");
            continue;
          }
        }
      }

      List<Transmitter> transmitters = device.getTransmitters();//get all transmitters

      String path_=joinPath(path, device.getDeviceInfo().toString()+".xml");//check if this device is supported...
      if (new File(path_).isFile()==false) {
        println(" - Ignored");
        continue;
      }
      MidiMapDevice d=new MidiMapDevice(device.getDeviceInfo().toString(), path_, (Integer)map.get(device.getDeviceInfo().toString()));

      for (int j = 0; j<transmitters.size(); j++) {//and for each transmitter
        transmitters.get(j).setReceiver(d);
      }
      Transmitter trans = device.getTransmitter();
      trans.setReceiver(d);
      device.open();//open each device
      MidiReceivers.add(d);
      map.put(device.getDeviceInfo().toString(), (Integer)map.get(device.getDeviceInfo().toString())+1);
      println(" - Success!");
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
void sendMidiOut() {
  SystemReceiver.send(sendMidiOut, -1);
}