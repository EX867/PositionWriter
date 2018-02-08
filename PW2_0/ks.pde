import beads.Sample;
import beads.SampleManager;
import beads.AudioContext;
import beads.SamplePlayer;
class KsSession {//
  LightThread light;
  String projectName;
  UnipackInfo info;
  LedScript autoPlay;//#ADD
  AudioContext ksac=new AudioContext();
  SamplePlayer player;
  ArrayList<KsButton[][]> KS;
}
class SampleCounter {
  Sample sample;
  int loopCount;
  String path;
  public SampleCounter(String path_) {
    path=path_;
    sample=SampleManager.sample(path);
  }
}
class KsButton {
  ArrayList<LedCounter> led;
  ArrayList<SampleCounter> sound;
  int ledIndex;
  int soundIndex;
}