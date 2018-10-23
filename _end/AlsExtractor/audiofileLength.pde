import java.util.Collections;
import java.util.List;
ArrayList<Double> getCuePoints(String path) {//folder, milliseconds
  List<File> files=java.util.Arrays.asList(new File(path).listFiles());
  Collections.sort(files, new java.util.Comparator<File>() {
    public int compare(File a, File b) {
      return a.getName().compareTo(b.getName());
    }
  }
  );
  ArrayList<Double> points=new ArrayList<Double>();
  points.ensureCapacity(files.size());
  double acc=0;
  for (File file : files) {
    Sample sample=SampleManager.sample(file.getAbsolutePath());
    double len=sample.samplesToMs(sample.getNumFrames());
    SampleManager.removeSample(sample);
    println("len : "+len+" (acc : "+acc+")");
    acc=acc+len;
    points.add(acc);
  }
  println(points.size());
  return points;
}
void saveCuePoints(String path) {//extract/onsets1.xml
  ArrayList<Double> points=getCuePoints(path);
  XML extract=new XML("Data");
  for (Double d : points) {
    XML event=extract.addChild("Event");
    event.setString("time", ""+d);
  }
  PrintWriter writer=createWriter("data/extract/onsets"+onsetsCount+".xml");
  writer.write(extract.format(2));
  writer.flush();
  writer.close();
  onsetsCount++;
}