class TimeMidiMessage implements Comparable<TimeMidiMessage> {
  MidiMessage msg=null;
  long time;
  TimeMidiMessage(MidiMessage msg_, long time_) {
    msg=msg_;
    time=time_;
  }
  @Override public int compareTo(TimeMidiMessage other) {
    int ret=(int)(time-other.time);
    if (ret==0) {
      return 1;
    }
    return ret;
  }
}
void midiCut(String path, XML points) {//saves to split/<midiname>/<count>.mid
  SampleManager.setVerbose(true);
  XML[] events=points.getChildren("Event");
  LinkedList<Double> times=new LinkedList<Double>();
  for (XML e : events) {
    //print(e.getDouble("time")+" ");
    times.add(e.getDouble("time"));
  }
  Sequence sequence=null;
  try {
    sequence= MidiSystem.getSequence(new File(path));
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  if (sequence==null) {
    println("failed!");
    return;
  }
  println();
  Track[] tracks=sequence.getTracks();
  TreeSet<TimeMidiMessage> set=new TreeSet<TimeMidiMessage>();
  for (int t=0; t<tracks.length; t++) {
    for (int i=0; i < tracks[t].size(); i++) {//order messages
      MidiEvent event = tracks[t].get(i);
      set.add(new TimeMidiMessage(event.getMessage(), event.getTick()));
    }
  }
  println(set.size());
  int bpm=140;
  int ind=0;
  midiCount=1;
  //
  try {
    Sequence s = new Sequence(javax.sound.midi.Sequence.PPQ, 480);
    int ppq=s.getResolution();
    Track t=s.createTrack();
    insertTempo(t, 0, bpm);
    //
    long time=0;
    println(sequence.getMicrosecondLength());
    println(set.size());
    while (!set.isEmpty()) {
      TimeMidiMessage m=set.pollFirst();
      double val=m.time*60000/(ppq*bpm);//milliseconds
      while (Math.round(val)>=times.get(ind)) {//#ADD snap
        String filename=dataPath+"/split/midi"+midiCount+".mid";
        println("split midi to "+filename);
        File file=new File(filename);
        if (!file.isFile()) {
          file.getParentFile().mkdirs();
          file.createNewFile();
        }
        FileOutputStream write=new FileOutputStream(file);
        write(s, write);
        s=new Sequence(javax.sound.midi.Sequence.PPQ, 480);
        t=s.createTrack();
        insertTempo(t, 0, bpm);
        time=set.first().time;
        midiCount++;
        ind++;
        println("index : "+ind+" "+set.size());
        if (ind>=times.size()) {
          break;
        }
      }
      t.add(new MidiEvent(m.msg, m.time-time));
      if (ind>=times.size()) {
        break;
      }
    }
    File file=new File(dataPath+"/split/midi"+midiCount+".mid");
    if (!file.isFile()) {
      file.getParentFile().mkdirs();
      file.createNewFile();
    }
    FileOutputStream write=new FileOutputStream(file);
    write(s, write);
    println("index : "+ind+" "+set.size()+" (end)");
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}