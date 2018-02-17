import beads.*;
//ModPlayer wavplayer;
Visualizer visualizer;
class EnvPoint {
  int time;//follows sample rate
  float value;
}
ArrayList<EnvPoint> volumep=new ArrayList<EnvPoint>();
ArrayList<EnvPoint> panp=new ArrayList<EnvPoint>();
ArrayList<EnvPoint> pitchp=new ArrayList<EnvPoint>();
ArrayList<EnvPoint> speedp=new ArrayList<EnvPoint>();
public static enum UGenType {
  UNDEFINED, SIMPLETOOL, TIMESTRETCHER,
}
class UGenParameter {
  //AudioProsessor UGen;//pointer to change values->differs from type.
  UGenType type;
  public UGenParameter(UGenType type_/*, UGen UGen*/) {
    type=type_;
  }
}
UGenParameter createNewParameter(UGenType type, UGen UGen) {
  if (type==UGenType.SIMPLETOOL) {
    return new SimpleToolParameter(type, UGen);
  }
  return new UGenParameter(UGenType.UNDEFINED);
}
//UGens
public class SimpleTool extends UGenChain {//contains gain,pan control.
  Gain gain;
  Panner panner;
  public SimpleTool(AudioContext ac) {
    super(ac, 2, 2);
    gain=new Gain(ac, 2);
    panner=new Panner(ac);
    drawFromChainInput(gain);
    int a=0;
    while (a<outs) {
      addToChainOutput(a, panner);
      a=a+1;
    }
  }
}
public class SimpleToolParameter extends UGenParameter {
  SimpleTool ugen;
  private double gain;
  private double pan;
  SimpleToolParameter(UGenType type_, UGen ugen_) {
    super(type_);
    ugen=(SimpleTool)ugen_;
    gain=1.0;
    pan=1.0;
  }
  void setGain(double value) {
    gain=value;
    //procesor.setGain(vale);
    //,,,,
  }
  void setPan(double value) {
    pan=value;
  }
}
//String midiToLed(String path) {
//}