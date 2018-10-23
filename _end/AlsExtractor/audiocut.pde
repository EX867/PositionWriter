import java.util.TreeSet;
import java.util.LinkedList;
void audioCut(String path, XML onsets) {//saves to split/<audioname>/<count>.wav
  println(new File(path).getAbsolutePath());
  SampleManager.setVerbose(true);
  Sample sample=SampleManager.sample(path);//, sample
  String filename=path.substring(path.lastIndexOf("/"), path.length());
  XML[] events=onsets.getChildren("Event");
  println(sample.getNumFrames());
  TreeSet<Integer> times=new TreeSet<Integer>();
  for (XML e : events) {
    times.add((int)Math.floor(sample.msToSamples(Double.parseDouble(e.getString("time"))*1000)));
  }
  int start=0;
  int count=1;
  while (!times.isEmpty()) {
    int time=times.pollFirst();
    float[][] buffer=new float[sample.getNumChannels()][time-start];
    sample.getFrames(start, buffer);
    Sample split=new Sample(sample.samplesToMs(time-start), sample.getNumChannels(), sample.getSampleRate());
    split.putFrames(0, buffer);
    try {
      File file=new File(dataPath+"/split/"+filename+"/"+count+".wav");
      if (!file.isFile()) {
        file.getParentFile().mkdirs();
        file.createNewFile();
      }
      println("save audio : "+file.getAbsolutePath() +" length : "+split.getLength()/1000+" start : "+start+" end : "+time);
      split.write(file.getAbsolutePath());
    }
    catch(IOException e) {
      e.printStackTrace();
    }
    count++;
    start=time;
  }
}
int index=1;
void playResult() {
  final ArrayList<Sample> samples=new ArrayList<Sample>();
  File[] files=new File("C:/Users/user/Documents/[Projects]/PositionWriter/AlsExtractor/data/split/Love_u.wav").listFiles();
  samples.ensureCapacity(files.length);
  for (int a=1; a<=files.length; a++) {
    samples.add(SampleManager.sample(files[a-1].getAbsolutePath()));
  }
  java.util.Collections.sort(samples, new java.util.Comparator<Sample>() {
    public int compare(Sample a, Sample b) {
      return Integer.parseInt(a.getFileName().substring(a.getFileName().replace("\\", "/").lastIndexOf("/")+1, a.getFileName().length()-4))-Integer.parseInt(b.getFileName().substring(b.getFileName().replace("\\", "/").lastIndexOf("/")+1, b.getFileName().length()-4));
    }
  }
  );
  AudioContext ac=new AudioContext();
  final SamplePlayer player=new SamplePlayer(ac, samples.get(0).getNumChannels());
  ac.out.addInput(player);
  player.setSample(samples.get(0));
  player.setKillOnEnd(false);
  println(samples.get(0).getFileName());
  player.setEndListener(new Bead() {
    protected void messageReceived(Bead b) {
      if (index<samples.size()) {
        println(samples.get(index).getFileName());
        player.setSample(samples.get(index));
        player.setPosition(0);
        index++;
        player.start();
      }
    }
  }
  );
  player.start();
  ac.start();
}