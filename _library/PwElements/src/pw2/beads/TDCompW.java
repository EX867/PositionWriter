package pw2.beads;
import beads.*;
import kyui.core.KyUI;
import pw2.element.Knob;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
public class TDCompW extends UGenW {//this is a class for positionwriter only...
  public TDComp ugen;
  public KnobAutomation attack;
  public KnobAutomation release;
  public KnobAutomation knee;
  public KnobAutomation ratio;
  public KnobAutomation threshold;
  public KnobAutomation outputGain;
  public KnobAutomation sideChain;
  protected static Sample emptySample;
  public Parameter setAttack = new Parameter((Object d) -> {
    ugen.setAttack(((Number)d).doubleValue());
  }, (Knob target) -> {
    attack.target = target;
  });
  public Parameter setRelease = new Parameter((Object d) -> {
    ugen.setRelease(((Number)d).doubleValue());
  }, (Knob target) -> {
    release.attach(target);
  });
  public Parameter setKnee = new Parameter((Object d) -> {
    ugen.setKnee(((Number)d).doubleValue());
  }, (Knob target) -> {
    knee.attach(target);
  });
  public Parameter setRatio = new Parameter((Object d) -> {
    ugen.setRatio(((Number)d).doubleValue());
  }, (Knob target) -> {
    ratio.attach(target);
  });
  public Parameter setThreshold = new Parameter((Object d) -> {
    ugen.setThreshold(((Number)d).doubleValue());
  }, (Knob target) -> {
    threshold.attach(target);
  });
  public Parameter setOutputGain = new Parameter((Object d) -> {
    ugen.setOutputGain(((Number)d).floatValue());
  }, (Knob target) -> {
    outputGain.attach(target);
  });
  public SamplePlayer sideChainPlayer;
  public ArrayList<Sample> samples = new ArrayList<>();
  public TDCompW(AudioContext ac, int in) {
    super(ac, in, in);
    if (emptySample == null) {
      emptySample = new Sample(ac.samplesToMs(ac.getBufferSize()), in);
    }
    ugen = new TDComp(ac, in);
    attack = new KnobAutomation(ac, "attack", 1);
    release = new KnobAutomation(ac, "release", 0.5F);
    knee = new KnobAutomation(ac, "knee", 0.1F);
    ratio = new KnobAutomation(ac, "ratio", 2);
    threshold = new KnobAutomation(ac, "threshold", -3);
    outputGain = new KnobAutomation(ac, "outputGain", 1);
    sideChain = new KnobAutomation(ac, "sideChain", 0);
    sideChain.gridOffset = 1;
    sideChain.gridInterval = 0;
    sideChain.setRange(0, 0);//usually,sideChain has no knob mapping.
    sideChainPlayer = new SamplePlayer(ugen.getContext(), 2);
    sideChainPlayer.setKillOnEnd(false);
    sideChain.postCounter = (KnobAutomation.Point p) -> {
      startSample(p.value);
    };
    sideChainPlayer.setEndListener(new Bead() {
      @Override
      protected void messageReceived(Bead bead) {
        sideChainPlayer.setSample(emptySample);
      }
    });
    //addDependent(sideChainPlayer);
    setStartPoint(ugen);
    sideChainPlayer.setSample(emptySample);
    sideChainPlayer.start();
  }
  public void setSideChain(boolean v) {
    if (v) {
      ugen.setSideChain(sideChainPlayer);
    } else {
      ugen.setSideChain(null);
    }
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
    sideChainPlayer.kill();
    super.kill();
  }
  @Override
  protected UGen updateUGens() {
    //update envelopes, like first part of calculate in other ugens
    attack.update();
    release.update();
    threshold.update();
    ratio.update();
    knee.update();
    outputGain.update();
    //
    sideChain.update();
    giveInputTo(ugen);
    updateUGen(ugen);
    return ugen;
  }
  public void startSample(double v) {
    int index = (int)Math.round(v) - 1;//starts from 1.
    if (index >= 0 && index < samples.size()) {
      sideChainPlayer.setSample(samples.get(index));
      sideChainPlayer.reTrigger();
    } else {
      System.out.println("[TDCompW] sample out of range");
    }
  }
  public boolean addSample(String path) {
    if (new File(path).isFile()) {
      try {
        samples.add(new Sample(path));
        sideChain.setRange(0, samples.size());//usually,sideChain has no knob mapping.
        System.out.println("Sample loaded : " + path);
      } catch (Exception e) {
        e.printStackTrace();
        return false;
      }
      return true;
    } else {
      return false;
    }
  }
  public void removeSample(int index) {
    samples.remove(index);
    for (int a = 0; a < sideChain.points.size(); a++) {
      KnobAutomation.Point point = sideChain.points.get(a);
      int i = (int)Math.round(point.value) - 1;
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
    for (int c = 0; c < sideChain.points.size(); c++) {
      KnobAutomation.Point point = sideChain.points.get(c);
      int i = (int)Math.round(point.value) - 1;
      if (i == a) {
        sideChain.changePoint(c, point.position, b);
      } else if (i == b) {
        sideChain.changePoint(c, point.position, a);
      }
    }
  }
  @Override
  public List<KnobAutomation> getAutomations() {
    return Arrays.asList(new KnobAutomation[]{attack, release, knee, threshold, ratio, outputGain, sideChain});
  }
}
