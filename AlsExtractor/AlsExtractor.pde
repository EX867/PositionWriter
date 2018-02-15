import javax.sound.midi.*;
import java.io.FileOutputStream;
import beads.*;
void setup() {
  String path="C:/Users/user/Downloads/Love U Project File/Love U Project File/Love U Top Lights/LoveU Top Lights Project/LoveU/LoveU.xml";
  String sample="Love_u.wav";
  dataPath=dataPath("").replace("\\", "/");
  println(dataPath);
  //recursiveSearch(loadXML(path));
  saveCuePoints("C:/Users/user/Documents/LoveU/Samples");
  //audioCut(dataPath+"/"+sample, loadXML("extract/onsets1.xml"));
  midiCut(dataPath+"/extract/midi1.mid", loadXML("extract/onsets1.xml"));

  exit();
}
void draw() {
}
//https://github.com/genedelisa/rockymusic/blob/master/rockymusic-core/src/main/java/com/rockhoppertech/music/midi/js/MIDIUtils.java
void recursiveSearch(XML parent) {
  XML[] children=parent.getChildren();
  for (XML xml : children) {
    if (xml.getName().equals("KeyTracks")) {
      extractKeyTrack(xml);
      //} else if (xml.getName().equals("UserOnsets")) {
      //extractOnsets(xml);
    } else {
      recursiveSearch(xml);
    }
  }
}
int midiCount=1;
int onsetsCount=1;
int progress=0;
String dataPath;
void extractKeyTrack(XML xml) {//save to extract/midi<midiCount>.mid
  int bpm=140;
  XML[] keyTracks=xml.getChildren("KeyTrack");
  try {
    //<MidiKey Value="29" />
    // <MidiNoteEvent Time="14.5" Duration="0.0625" Velocity="49.0000076" OffVelocity="64" IsEnabled="true" />
    Sequence s = new Sequence(javax.sound.midi.Sequence.PPQ, 480);
    int ppq=s.getResolution();
    Track t=s.createTrack();
    insertTempo(t, 0, bpm);
    for (XML keyTrack : keyTracks) {
      XML[] notes=keyTrack.getChild("Notes").getChildren("MidiNoteEvent");
      int note=keyTrack.getChild("MidiKey").getInt("Value");
      for (XML x : notes) {
        ShortMessage on = new ShortMessage();
        ShortMessage off = new ShortMessage();
        long time=(long)(x.getDouble("Time")*ppq);
        long timeEnd=time+(long)(x.getDouble("Duration")*ppq);
        on.setMessage(ShortMessage.NOTE_ON, 0, note, (int)Math.round(x.getDouble("Velocity")));
        off.setMessage(ShortMessage.NOTE_OFF, 0, note, 0);
        t.add(new MidiEvent(on, time));
        t.add(new MidiEvent(off, timeEnd));
        println("add message "+(progress++));
      }
      println("keytrack finished : "+note+" "+(progress++));
    }
    File file=new File(dataPath+"/extract/midi"+midiCount+".mid");
    if (!file.isFile()) {
      file.getParentFile().mkdirs();
      file.createNewFile();
    }
    FileOutputStream write=new FileOutputStream(file);
    write(s, write);
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  midiCount++;
}
void extractOnsets(XML xml) {//save to extract/onsets<onsetsCount>.xml
  //this was not mapping information...
  //UserOnsets
  // <OnsetEvent Time="1.3967800453514738" Energy="0.00400238530710339546" IsVolatile="false" />
  // <OnsetEvent Time="1.6104988662131519" Energy="0.00380863319151103497" IsVolatile="false" />
  XML[] onsets=xml.getChildren("OnsetEvent");
  XML extract=new XML("Data");
  for (XML x : onsets) {
    XML event=extract.addChild("Event");
    event.setString("time", x.getString("Time"));
  }
  PrintWriter writer=createWriter("data/extract/onsets"+onsetsCount+".xml");
  writer.write(extract.format(2));
  writer.flush();
  writer.close();
  onsetsCount++;
}

public static void insertTempo(Track track, long tick, int tempo) {
  int temp = 60000000 / tempo;
  tempo = temp;
  byte[] b = new byte[3];
  int tmp = tempo >> 16;
  b[0] = (byte) tmp;
  tmp = tempo >> 8;
  b[1] = (byte) tmp;
  b[2] = (byte) tempo;

  try {
    MetaMessage message = new MetaMessage();
    // type, data, length, tick
    message.setMessage(0x51, b, b.length);
    MidiEvent event = new MidiEvent(message, tick);
    track.add(event);
  } 
  catch (InvalidMidiDataException e) {
  }
}
public static void write(Sequence sequence, OutputStream os) {
  try {
    int[] types = MidiSystem.getMidiFileTypes(sequence);

    if (MidiSystem.isFileTypeSupported(1, sequence)) {
      if (MidiSystem.write(sequence, 1, os) == -1) {
        throw new IOException("Problems writing to stream");
      }
    } else {
      if (MidiSystem.write(sequence, types[0], os) == -1) {
        throw new IOException("Problems writing to stream");
      }
    }
  } 
  catch (IOException ie) {
    ie.printStackTrace();
  }
}
int getTempo(MetaMessage event) {
  byte[] message = event.getData();
  int mask = 0xFF;
  int bvalue = (message[0] & mask);
  bvalue = (bvalue << 8) + (message[1] & mask);
  bvalue = (bvalue << 8) + (message[2] & mask);
  return 60000000 / bvalue;
}