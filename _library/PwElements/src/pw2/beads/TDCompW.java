package pw2.beads;
import beads.AudioContext;
import beads.Sample;
import beads.SamplePlayer;
import beads.UGen;
import beads.UGenW;
import pw2.element.Knob;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
public class TDCompW extends UGenW {//this is a class for positionwriter only...
  public TDComp ugen;
  public KnobAutomation attack;
  public KnobAutomation release;
  public KnobAutomation knee;
  public KnobAutomation ratio;
  public KnobAutomation threshold;
  public KnobAutomation outputGain;
  public KnobAutomation sideChain;
  public Parameter setAttack=new Parameter((Object d) -> {
    ugen.setAttack(((Number)d).doubleValue());
  }, (Knob target) -> {
    attack.target=target;
  });
  public Parameter setRelease=new Parameter((Object d) -> {
    ugen.setRelease(((Number)d).doubleValue());
  }, (Knob target) -> {
    release.attach(target);
  });
  public Parameter setKnee=new Parameter((Object d) -> {
    ugen.setKnee(((Number)d).doubleValue());
  }, (Knob target) -> {
    knee.attach(target);
  });
  public Parameter setRatio=new Parameter((Object d) -> {
    ugen.setRatio(((Number)d).doubleValue());
  }, (Knob target) -> {
    ratio.attach(target);
  });
  public Parameter setThreshold=new Parameter((Object d) -> {
    ugen.setThreshold(((Number)d).doubleValue());
  }, (Knob target) -> {
    threshold.attach(target);
  });
  public Parameter setOutputGain=new Parameter((Object d) -> {
    ugen.setOutputGain(((Number)d).floatValue());
  }, (Knob target) -> {
    outputGain.attach(target);
  });
  public SamplePlayer sideChainPlayer;
  public ArrayList<Sample> samples=new ArrayList<>();
  public TDCompW(AudioContext ac, int in) {
    super(ac, in, in);
    ugen=new TDComp(ac, in);
    attack=new KnobAutomation(ac, 1);
    release=new KnobAutomation(ac, 0.5F);
    knee=new KnobAutomation(ac, 0.1F);
    ratio=new KnobAutomation(ac, 2);
    threshold=new KnobAutomation(ac, -3);
    outputGain=new KnobAutomation(ac, 1);
    sideChain=new KnobAutomation(ac, 0);
    sideChainPlayer=new SamplePlayer(ac, 2);
    sideChainPlayer.setKillOnEnd(false);
    sideChain.gridOffset=1;
    sideChain.gridInterval=0;
    sideChain.setRange(0,0);//usually,sideChain has no knob mapping.
    ugen.setSideChain(sideChainPlayer);
    sideChain.postCounter=(KnobAutomation.Point p) -> {
      startSample(p.value);
    };
    setStartPoint(ugen);
    sideChainPlayer.start();
  }
  @Override
  public void kill() {
    ugen.kill();
    sideChain.kill();
    attack.kill();
    release.kill();
    threshold.kill();
    ratio.kill();
    knee.kill();
    outputGain.kill();
    super.kill();
  }
  @Override
  protected UGen updateUGens() {
    giveInputTo(ugen);
    sideChain.update();
    ugen.update();
    return ugen;
  }
  public void startSample(double v) {
    int index=(int)Math.round(v) - 1;//starts from 1.
    if (index >= 0 && index < samples.size()) {
      sideChainPlayer.setSample(samples.get(index));
      sideChainPlayer.reTrigger();
    } else {
      System.out.println("[TDCompW] sample out of range");
    }
  }
  public void addSample(String path) {
    if (new File(path).isFile()) {
      try {
        samples.add(new Sample(path));
        sideChain.setRange(0,samples.size());//usually,sideChain has no knob mapping.
        System.out.println("Sample loaded : " + path);
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
  public void removeSample(int index) {
    samples.remove(index);
    for (int a=0; a < sideChain.points.size(); a++) {
      KnobAutomation.Point point=sideChain.points.get(a);
      int i=(int)Math.round(point.value) - 1;
      if (i > index) {
        sideChain.changePoint(a, point.position, i - 1);
      } else if (i == index) {
        sideChain.removePoint(a);
        a--;
      }
    }
  }
  public void reorderSample(int a, int b) {
    Collections.swap(samples, a, b);
    for (int c=0; c < sideChain.points.size(); c++) {
      KnobAutomation.Point point=sideChain.points.get(c);
      int i=(int)Math.round(point.value) - 1;
      if (i == a) {
        sideChain.changePoint(c, point.position, b);
      } else if (i == b) {
        sideChain.changePoint(c, point.position, a);
      }
    }
  }
}
