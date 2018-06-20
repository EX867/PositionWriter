package pw2.beads;
import beads.*;
import kyui.util.TaskManager;
import pw2.element.Knob;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.*;
import java.util.function.BiConsumer;
public class AutoControlSamplePlayer extends SamplePlayer implements UGenWInterface {
  TaskManager tm = new TaskManager();//for parameter adjustment
  boolean gui = true;
  //public ArrayList<UGen> ugensBefore = new ArrayList<UGen>();
  //public ArrayList<UGen> outputs = new ArrayList<>();//I need reflection to get outputs, but I can also manually add it.
  public ArrayList<KnobAutomation> autos = new ArrayList<>();
  public Runnable onUpdate = () -> {//need it...
  };
  public KnobAutomation speed;
  public UGenW.Parameter setSpeed = new UGenW.Parameter((Object d) -> {
    speed.setValue(((Number)d).floatValue());
  }, (Knob target) -> {
    speed.attach(target);
  });
  public AutoControlSamplePlayer(AudioContext ac, int i) {
    super(ac, i);
    speed = new KnobAutomation(ac, "speed", 1);
    autos.add(speed);
    setRate(speed);
  }
  public AutoControlSamplePlayer(AudioContext ac, Sample s) {
    super(ac, s);
    speed = new KnobAutomation(ac, "speed", 1);
    autos.add(speed);
    setRate(speed);
  }
  public void addAuto(KnobAutomation a) {
    synchronized (this) {
      autos.add(a);
    }
  }
  @Override
  public void setLoopEnd(UGen u) {
    //    for (KnobAutomation a : autos) {
    //      a.setLoopEnd(u.getValue());
    //    }
    super.setLoopEnd(u);
  }
  @Override
  public void setLoopStart(UGen u) {
    //    for (KnobAutomation a : autos) {
    //      a.setLoopStart(u.getValue());
    //    }
    super.setLoopStart(u);
  }
  //  @Override
  //  public void setPosition(UGen u) {
  //    for (KnobAutomation a : autos) {
  //      a.setPosition(u.getValue());
  //    }
  //    super.setPosition(u);
  //  }
  @Override
  public void setLoopType(LoopType l) {
    super.setLoopType(l);
    //    if (loopType == LoopType.NO_LOOP_FORWARDS || loopType == LoopType.NO_LOOP_BACKWARDS) {
    //      for (KnobAutomation a : autos) {
    //        a.setLoop(false);
    //      }
    //    } else {//all is loop.
    //      for (KnobAutomation a : autos) {
    //        a.setLoop(true);
    //      }
    //    }
  }
  @Override
  public void calculateBuffer() {
    tm.executeAll();
    super.calculateBuffer();
    synchronized (this) {
      for (int a = 0; a < autos.size(); a++) {//disable KnobAutomation's position control ability! (synchronize with me)
        //or you later optimize this to only do this at setPosition.
        if (autos.get(a).isDeleted()) {
          autos.remove(a);
          a--;
        } else {
          autos.get(a).setPosition(position);
          autos.get(a).setLoopEnd(getLoopEndUGen().getValue());//don't forget to do this every sample change if you set auto's loops in set event.
        }
      }
    }
    if (gui) {
      onUpdate.run();
    }
  }
  public void addInputTo(UGen out) {//sampleplayer cannot add input.
    out.addInput(this);
    //outputs.add(out);
  }
  protected void calculateNextPosition(int i) {//this is pasted from sampleplayer
    super.calculateNextPosition(i);
    if (loopType == LoopType.NO_LOOP_FORWARDS) {//FIX not working properly due to floating point operation error
      loopStart = loopStartEnvelope.getValue(0, i);
      loopEnd = loopEndEnvelope.getValue(0, i);
      if ((float)position > Math.max(loopStart, loopEnd)) {
        position = Math.max(loopStart, loopEnd);
        pause(true);
      }
    }
  }
  //this->ugens[0]->ugens[1]->...->contxet.out
  public void construct(UGen[] ugens) {
    if (ugens.length == 0) {
      return;
    }
    UGen after = this;
    for (UGen ugen : ugens) {
      ugen.addInput(after);
      after = ugen;
    }
    context.out.addInput(ugens[ugens.length - 1]);
  }
  /*
  input -> ugenBefore[0] -> ugenBefore[1] -> ... -> this
  */
  //  public List<KnobAutomation> addUGenAndGetAutos(UGen u) {
  //    return addUGenAndGetAutos(0, u);
  //    return addUGenAndGetAutos(ugensBefore.size(), u);
  //  }
  //  public List<KnobAutomation> addUGenAndGetAutos(int index, UGen u) {//add ugen to before ugen list.
  //    if (index == 0) {
  //      for (UGen output : outputs) {
  //        if (ugensBefore.size() == 0) {
  //          output.removeAllConnections(this);
  //        } else {
  //          output.removeAllConnections(ugensBefore.get(0));
  //        }
  //      }
  //      for (UGen output : outputs) {
  //        output.addInput(u);
  //      }
  //      if (ugensBefore.size() == 0) {
  //        u.addInput(this);
  //      } else {
  //        u.addInput(ugensBefore.get(0));
  //      }
  //    } else if (index == ugensBefore.size()) {
  //      removeAllConnections(ugensBefore.get(ugensBefore.size() - 1));
  //      ugensBefore.get(ugensBefore.size() - 1).addInput(u);
  //      u.addInput(this);
  //    } else {
  //      ugensBefore.get(index).removeAllConnections(ugensBefore.get(index - 1));
  //      ugensBefore.get(index - 1).addInput(u);
  //      u.addInput(ugensBefore.get(index));
  //    }
  //    ugensBefore.add(index, u);
  //    if (u instanceof UGenWInterface) {
  //      return ((UGenWInterface)u).getAutomations();
  //    }
  //    return new ArrayList<>();
  //  }
  //    } else {
  //      after = ugensBefore.get(index + 1);
  //    }
  //    if (index == 0) {
  //      for (UGen output : outputs) {
  //        output.removeAllConnections(remove);
  //      }
  //      for (UGen output : outputs) {
  //        output.addInput(after);
  //      }
  //    } else {
  //      ugensBefore.get(index - 1).removeAllConnections(remove);
  //      ugensBefore.get(index - 1).addInput(after);
  //    }
  //    remove.removeAllConnections(after);
  //    if (list != null && remove instanceof UGenW) {
  //      ((UGenW)remove).removeAutomationsFrom(list);
  //    }
  //    return ugensBefore.remove(index);
  //    return null;
  //  }
  //  public void reorderUGens(int a, int b) {
  //    if (a == b) {
  //      return;
  //    }
  //    if (b < a) {
  //      int temp = a;
  //      a = b;
  //      b = temp;
  //    }
  //    UGen bb = removeUGenAndAutos(b, null);
  //    UGen aa = removeUGenAndAutos(a, null);
  //    addUGenAndGetAutos(a, bb);
  //    addUGenAndGetAutos(b, aa);
  //  }
  @Override public void changeParameter(UGenW.Parameter task, Double value) {
    tm.addTask(task.setter, value);
  }
  public List<KnobAutomation> getAutomations() {
    return Arrays.asList(new KnobAutomation[]{speed});
  }
  @Override public void setGui(boolean value) {
    gui = value;
    for (UGen u : context.out.getConnectedInputs()) {
      if (u instanceof UGenWInterface && ((UGenWInterface)u).getGui() != gui) {//prevent feedback loop
        ((UGenWInterface)u).setGui(gui);
      }
    }
  }
  boolean resetCheck = false;
  public void reset() {
    if (resetCheck) {
      return;
    }
    resetCheck = true;
    for (UGen u : context.out.getConnectedInputs()) {
      if (u instanceof UGenWInterface) {//prevent feedback loop
        ((UGenWInterface)u).reset();
      }
    }
    resetCheck = false;
  }
  @Override public boolean getGui() {
    return gui;
  }
  public Sample makeProcessedSample(BiConsumer<Long, Long> progressListener) {
    UGen rateUGen = getRateUGen();
    setRate(new Static(context, 1));
    setGui(false);
    for (KnobAutomation auto : autos) {
      auto.setGui(false);
    }
    //
    Sample s = new Sample(sample.getLength() + context.samplesToMs(bufferSize), 2, context.getSampleRate());//stereo fixed, same length.(fix needed. effect can extend sample length. maybe this need heavy modification)
    RecordToSample r = new RecordToSample(context, s) {
      int count = 0;
      @Override public void calculateBuffer() {
        super.calculateBuffer();
        count++;
        if (count % 16 == 0) {//call every 16 buffers recorded.
          kyui.core.KyUI.taskManager.addTask((o) -> {//give this to ui thread
            progressListener.accept(getNumFramesRecorded(), s.getNumFrames());
          }, null);
        }
      }
    };
    context.stop();//stop before run nonrealtime
    //setup chain
    //    Gain g = new Gain(context, 2, 0.5F);
    //    r.addInput(g);
    //    context.out.addDependent(r);
    //    Set<UGen> ugens = context.out.getConnectedInputs();
    //    context.out.clearInputConnections();
    //    for (UGen ugen : ugens) {
    //      g.addInput(ugen);
    //    }
    r.addInput(context.out);
    context.out.addDependent(r);
    //
    r.setKillListener(new Bead() {
      @Override protected void messageReceived(Bead bead) {
        System.out.println("[makeProcessedSample] context.stop");
        context.stop();
      }
    });
    UGen loopEnd_ = getLoopEndUGen();
    setLoopStart(new Static(context, 0));
    setLoopEnd(new Static(context, Float.MAX_VALUE));
    r.reset();
    r.start();
    reset();
    start();
    //    context.reset();
    //    context.start();
    //    try {
    //      Thread.sleep(2000);
    //    } catch (Exception e) {
    //    }
    Thread audioThread = null;
    try {
      audioThread = (Thread)audioThreadField.get(context.getAudioIO());
    } catch (IllegalAccessException e) {//not happen
    }
    try {
      audioThread.join();
    } catch (InterruptedException e) {
    }
    context.runNonRealTime();
    progressListener.accept(s.getNumFrames(), s.getNumFrames());
    setLoopEnd(loopEnd_);
    setRate(rateUGen);
    setGui(true);
    for (KnobAutomation auto : autos) {
      auto.setGui(true);
    }
    //reset chain
    //    g.clearInputConnections();
    //    context.out.clearInputConnections();
    //    for (UGen ugen : ugens) {
    //      context.out.addInput(ugen);
    //    }
    //
    System.out.println("[makeProcessedSample] sample out");
    Sample s_ = new Sample(sample.getLength());
    float[][] buffer = new float[s.getNumChannels()][(int)sample.getNumFrames()];
    s.getFrames(bufferSize, buffer);//????????????//FIX bufferSize delay problem
    s_.putFrames(0, buffer);
    context.reset();
    context.start();
    //force change sample file name!
    java.lang.reflect.Field filename = null;
    try {
      filename = Sample.class.getDeclaredField("filename");
      filename.set(s_, sample.getFileName());
    } catch (Exception e) {
    }
    return s_;
  }
  static Field audioThreadField;
  static {
    try {
      audioThreadField = JavaSoundAudioIO.class.getDeclaredField("audioThread");
      audioThreadField.setAccessible(true);
    } catch (Exception e) {//not happen
    }
  }
}
