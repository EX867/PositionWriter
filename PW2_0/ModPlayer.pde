//be.tarsos.examples.Player code modified.
public class ModPlayer implements StateReturner, SliderUpdater {
  private String loadedPath;
  //ugens
  AudioContext ac;
  private SamplePlayer samplePlayer;
  Sample sample;
  Gain g;
  public ArrayList<UGen> ugens=new ArrayList<UGen>();//you can change ugen orders.you can add other ugens like reverb and pan phaser RubberBandUGen ect...
  public ArrayList<UGenParameter> parameters=new ArrayList<UGenParameter>();//this is where parameters are stored.
  //
  Slider slider;
  Label time;
  //
  public double length;
  public boolean loop=false;
  public double loopStart=0;
  public double loopEnd=0;
  public boolean fileLoaded=false;
  public ModPlayer() {
    ac=new AudioContext();
    g = new Gain(ac, 2, 1);
    ac.out.addInput(g);
    ac.start();
    //addUGen(0, UGenType.SIMPLETOOL, new SimpleTool(ac));//initial(0)
  } 
  public void load(String path) {
    eject();
    try {
      sample = SampleManager.sample(path);
      samplePlayer=new SamplePlayer(ac, sample);
      g.addInput(samplePlayer);
      loadedPath=path;
      fileLoaded=true;
      length= sample.getLength();
      samplePlayer.setPosition(0);
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }
  public void eject() {
    loadedPath = "";
    fileLoaded=false;
    stop();
  }
  @Override
    public String getState() {
    if (samplePlayer==null)return "0/0";
    return floor((float)samplePlayer.getPosition())+"/"+floor((float)length);
  }
  @Override
    public void setValue(float value) {
    if (samplePlayer==null)return;
    samplePlayer.setPosition((double)value);
    time.update();
  }
  @Override
    public float getValue() {
    if (samplePlayer==null)return 0;
    return (float)getPosition();
  }
  @Override
    public float getMin() {
    return 0;
  }
  @Override
    public float getMax() {
    return (float)length;
  }
  public void assign(Slider slider_, Label label_) {
    slider=slider_;
    time=label_;
    time.setTextUpdater(this);
    slider.setUpdater(this);
  }
  public void addUGen(int index, UGenType type, UGen ugen) {
    if (index<0)return;
    if (index==ugens.size()) {//linked with ac.out
      if (index==0) {
        ac.out.removeConnection(0, g, 0);
        ac.out.removeConnection(0, g, 1);
        ac.out.removeConnection(1, g, 0);
        ac.out.removeConnection(1, g, 1);
      } else if (index==0) {
        ac.out.removeConnection(0, ugens.get(index-1), 0);
        ac.out.removeConnection(0, ugens.get(index-1), 1);
        ac.out.removeConnection(1, ugens.get(index-1), 0);
        ac.out.removeConnection(1, ugens.get(index-1), 1);
      }
      ugen.addInput(g);
      ac.out.addInput(ugen);
    } else if (index==0) {//linked with g
      ugens.get(index).removeConnection(0, g, 0);
      ugens.get(index).removeConnection(0, g, 1);
      ugens.get(index).removeConnection(1, g, 0);
      ugens.get(index).removeConnection(1, g, 1);
      ugen.addInput(g);
    } else {
      //linkedlist
    }
    ugens.add(index, ugen);
    parameters.add(index, createNewParameter(type, ugen));
    ((ScrollList)UI[getUIidRev("I_SIGNALCHAIN")]).addItem(type.toString());
    //printLog("ModPlayer.addUGen()", "added : "+index+" , ugen= "+type.toString());
  }
  public void removeUGen(int index) {
    // linkedlist
    ugens.remove(index);
    parameters.remove(index);
  }
  public void reorderUGen(int index, int moveCount) {
    if (moveCount<-index||moveCount>ugens.size()-index)throw new RuntimeException("Invalid control! Internal error occured!");
    //
  }
  public double getPosition() {
    return samplePlayer.getPosition();
  }
  public void play() {
    if (getPosition()>=length)samplePlayer.setPosition(0);
    play(getPosition());
  }
  public void play(double startTime) {
    if (samplePlayer==null) {
      //println("things went wrong!");
      return;
    }
    if (playerState==PAUSE) {
      samplePlayer.pause(false);//time ignored
      //printLog("ModPlayer.play()", "restarted!");
    }
    samplePlayer.start((float)startTime);
    //printLog("ModPlayer.play()", "started! : "+startTime);
    playerState=PLAY;
  }
  public void pause() {
    samplePlayer.pause(true);
    playerState=PAUSE;
  }
  public void stop() {
    if (samplePlayer==null)return;
    samplePlayer.reset();
    pause();
    playerState=STOP;
    samplePlayer.setPosition(0);
  }
  public void loop(boolean loop_) {
    loop=loop_;
    if (samplePlayer==null)return;
    if (loop) {
      samplePlayer.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    } else {
      samplePlayer.setLoopType(SamplePlayer.LoopType.NO_LOOP_FORWARDS);
    }
  }
  public void setLoopStart(double start) {
    loopStart=start;
    if (samplePlayer==null)return;
    samplePlayer.setLoopStart(new Static(ac, (float)start));
  }
  public void setLoopEnd(double end) {
    loopEnd=end;
    if (samplePlayer==null)return;
    samplePlayer.setLoopEnd(new Static(ac, (float)end));
  }
  int playerState=STOP;
  static final int STOP=0;
  static final int PLAY=1;
  static final int PAUSE=2;
}