package pw2.beads;
import beads.*;
import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PImage;
public class TDComp extends UGenChain {//Time Domain Compressor, formula is from http://smc2017.aalto.fi/media/materials/proceedings/SMC17_p42.pdf
  double threshold=Math.log10(0.5);
  double ratio=2;//larger than 0. (but control starts with 1<<)
  double knee=0.1;//equal or larger than 0
  double attack=100;//in milliseconds. linear attack
  double release=300;
  float outputGain=1;
  UGen sideChain=null;
  //
  protected int attackInSamples;
  protected int releaseInSamples;
  //
  UGen input;
  public PGraphics graph;//draws graph
  public PGraphics wave;//draws wave
  public boolean canDraw=false;
  //
  boolean triggered;
  int count=0;
  double currentValue=0;
  public TDComp(AudioContext ac, int channels) {
    super(ac, channels, channels);
    attackInSamples=Math.round((float)context.msToSamples(attack));
    releaseInSamples=Math.round((float)context.msToSamples(release));
  }
  @Override
  protected void preFrame() {
    if (sideChain != null) {
      sideChain.update();
    }
    if (ins == 0) {
      return;
    }
    double sideChainRms=0;
    double rmslog;
    if (sideChain == null) {
      sideChainRms=getRMS(bufIn);
    } else {
      sideChainRms=getRMS(sideChain);
    }
    rmslog=Math.log10(sideChainRms);
    if (rmslog > threshold) {//compression start
      if (!triggered) {
        triggered=true;
        count=0;//attack start
      }
    } else if (triggered) {//compression end
      triggered=false;
      count=0;//release start
    }
    for (int a=0; a < bufferSize; a++) {
      float ratio=1;
      if (triggered && count < attackInSamples) {
        ratio=(float)count / attackInSamples;
      } else if (!triggered && count < releaseInSamples) {
        ratio=(float)count / releaseInSamples;
      }
      count++;
      double sum=0;
      for (int c=0; c < bufOut.length; c++) {
        if (triggered) {
          double data=Math.log10(Math.abs(bufIn[c][a]));
          double output=getOutput(rmslog, data);
          sum+=data - output;
          bufOut[c][a]=(float)(Math.signum(bufIn[c][a]) * (Math.min(Math.pow(10, output), Math.max(0, Math.abs(bufIn[c][a]) - currentValue)) * ratio + Math.abs(bufIn[c][a]) * (1 - ratio)));
        } else {
          bufOut[c][a]=(float)(Math.signum(bufIn[c][a]) * (Math.abs(bufIn[c][a]) * ratio + Math.max(0, Math.abs(bufIn[c][a]) - currentValue) * (1 - ratio)));
        }
        bufOut[c][a]*=outputGain;
      }
      if (triggered) {
        currentValue=Math.max(currentValue - 1.0 / releaseInSamples, sum / bufOut.length);
      }
    }
    if (canDraw && graph != null) {
      visualizeGraph(sideChainRms);
    }
    if (canDraw && wave != null) {
      visualizeWave(sideChainRms);
    }
  }
  public double getAttack() {
    return attack;
  }
  public TDComp setAttack(double v) {
    attack=v;
    attackInSamples=Math.round((float)context.msToSamples(attack));
    return this;
  }
  public double getRelase() {
    return release;
  }
  public TDComp setRelease(double v) {
    release=v;
    releaseInSamples=Math.round((float)context.msToSamples(release));
    return this;
  }
  public double getThreshold() {
    return threshold * 20;
  }
  public TDComp setThreshold(double v) {
    threshold=v / 20;
    return this;
  }
  public double getRatio() {
    return ratio;
  }
  public TDComp setRatio(double v) {
    ratio=v;
    return this;
  }
  public double getKnee() {
    return knee;
  }
  public TDComp setKnee(double v) {
    knee=v;
    return this;
  }
  public float getOutputGain() {
    return outputGain;
  }
  public TDComp setOutputGain(float v) {
    outputGain=v;
    return this;
  }
  public UGen getSideChain() {
    return sideChain;
  }
  public TDComp setSideChain(UGen v) {
    sideChain=v;
    return this;
  }
  void visualizeGraph(double sideChainRms) {//size=object.height
    graph.beginDraw();
    graph.stroke(0);
    graph.strokeWeight(4);
    graph.clear();
    float px=0;
    float py=graph.height;
    for (int a=0; a < graph.width; a++) {
      float cx=a;
      double val=Math.log10((double)a / graph.width);
      float cy=graph.height - 500 * (float)Math.pow(10, getOutput(val, val));
      graph.line(px, py, cx, cy);
      px=cx;
      py=cy;
    }
    double output=getRMS(bufOut);
    graph.noFill();
    graph.ellipse((float)output, (float)(graph.height - 500 * Math.pow(10, getOutput(sideChainRms, Math.log10(output)))), 10, 10);
    graph.endDraw();
  }
  void visualizeWave(double sideChainRms) {
    float head=wave.height / 10;
    wave.beginDraw();
    wave.imageMode(PApplet.CORNER);
    wave.image(wave, -1, 0);
    wave.strokeWeight(1);
    wave.stroke(127, 127, 127);
    wave.line(wave.width - 1, 0, wave.width - 1, wave.height);
    double input=getRMS(bufIn);
    double output=getRMS(bufOut);
    wave.stroke(0x7F7F4040);
    wave.line(wave.width - 1, wave.height, wave.width - 1, wave.height + head - (int)(wave.height * input));//input
    wave.stroke(0x7F40407F);
    wave.line(wave.width - 1, wave.height, wave.width - 1, wave.height + head - (int)(wave.height * output));//output
    if (sideChain != null) {
      wave.stroke(0x3F000000);
      wave.line(wave.width - 1, wave.height, wave.width - 1, wave.height + head - (int)(wave.height * sideChainRms));//rms sideChain
    }
    wave.stroke(0xFF000000);
    wave.point(wave.width - 1, wave.height - (int)(wave.height * dbToLin(20 * threshold) + head));//threshold
    wave.stroke(0x3F007F00);
    wave.line(wave.width - 1, head, wave.width - 1, (int)(wave.height * (input - output)) + head);//rms db(sidechain)
    wave.endDraw();
  }
  static double linToDb(double in) {
    return 20 * Math.log10(in);
  }
  static double dbToLin(double in) {
    return Math.pow(10, 0.05 * in);
  }
  PGraphics input(PGraphics display) {
    display.beginDraw();
    display.stroke(0);
    display.strokeWeight(4);
    display.noFill();
    display.clear();
    display.endDraw();
    return display;
  }
  double getOutput(double sideChain, double input) {
    if (2 * (sideChain - threshold) <= -knee) {//left
      return input;
    } else if (2 * (sideChain - threshold) > knee) {//right
      return Math.min(0, input - (sideChain - (threshold + (sideChain - threshold) / ratio)));
    } else {//center
      double a=(sideChain - threshold + knee / 2);
      return Math.min(0, input + (1 / ratio - 1) * a * a / (2 * knee));
    }
  }
  double getRMS(UGen in) {//float[][] buf //https://dsp.stackexchange.com/questions/27221/calculating-rms-crest-factor-for-a-stereo-signal
    float result=0;
    for (int c=0; c < in.getOuts(); c++) {
      for (int i=0; i < bufferSize; i++) {
        result+=(in.getOutBuffer(c)[i] * in.getOutBuffer(c)[i]);
      }
    }
    return Math.sqrt(result / (in.getOuts() * bufferSize));
  }
  double getRMS(float[][] buf) {
    float result=0;
    for (int c=0; c < buf.length; c++) {
      for (int i=0; i < bufferSize; i++) {
        result+=buf[c][i] * buf[c][i];
      }
    }
    return Math.sqrt(result / (buf.length * bufferSize));
  }
}
