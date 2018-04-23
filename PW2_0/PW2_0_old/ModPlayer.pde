//be.tarsos.examples.Player code modified.
public class ModPlayer {
  private String loadedPath;
  //ugens
  AudioContext ac;
  private SamplePlayer samplePlayer;
  Sample sample;
  Gain g;
  public ArrayList<UGen> ugens=new ArrayList<UGen>();//you can change ugen orders.you can add other ugens like reverb and pan phaser RubberBandUGen ect...
  public ArrayList<UGenParameter> parameters=new ArrayList<UGenParameter>();//this is where parameters are stored.
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