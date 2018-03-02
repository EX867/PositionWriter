package pw2.beads;
import beads.*;
import processing.core.PApplet;
import processing.core.PGraphics;
public class TDComp extends UGenChain {//Time Domain Compressor, formula is from http://smc2017.aalto.fi/media/materials/proceedings/SMC17_p42.pdf
  enum Method {
    RMS, PEAK
  }
  double threshold=Math.log10(0.5);
  double ratio=2;//larger than 0. (but control starts with 1<<)
  double knee=0.1;//equal or larger than 0
  double attack=100;//in milliseconds. linear attack
  double release=300;
  float outputGain=1;
  UGen sideChain=null;
  Method method=Method.PEAK;
  //
  protected int attackInSamples;
  protected int releaseInSamples;
  float thresholdPow=0.5F;
  //
  UGen input;
  public PGraphics graph;//draws graph
  public PGraphics wave;//draws wave
  public boolean canDraw=false;
  //
  boolean triggered;
  int count=0;
  double currentValue=0;
  double pcurrentValue=0;
  public TDComp(AudioContext ac, int channels) {
    super(ac, channels, channels);
    attackInSamples=Math.round((float)context.msToSamples(attack));
    releaseInSamples=Math.round((float)context.msToSamples(release));
  }
  double[] output=new double[2];
  @Override
  protected void preFrame() {
    if (sideChain != null) {
      sideChain.update();
    }
    if (ins == 0) {
      return;
    }
    double dvallog;
    double dval;
    if (sideChain == null) {
      dval=getDVal(bufIn);
    } else {
      dval=getDVal(sideChain);
    }
    dvallog=Math.log10(dval);
    if (dvallog > threshold - knee / 2) {//compression start
      if (!triggered) {
        triggered=true;
        count=0;//attack start
      }
    } else if (triggered) {//compression end
      triggered=false;
      count=0;//release start
    }
    for (int a=0; a < bufferSize; a++) {
      double sum=0;
      for (int c=0; c < bufOut.length; c++) {
        if (triggered) {
          double data=Math.log10(Math.abs(bufIn[c][a]));
          output[c]=getOutput(dvallog, data);
          sum+=data - output[c];
        }
      }
      if (triggered) {
        if (count < attackInSamples) {//FIX
          double c=(sum / bufOut.length) * (count / attackInSamples);
          if (c > currentValue) {
            currentValue=c;
          }
        }else{
          double c=currentValue * (releaseInSamples - 1) / releaseInSamples;
          double d=sum / bufOut.length;
          if (c > d) {
            currentValue=c;
          } else {
            currentValue=d;
          }
        }
      } else {
        if (releaseInSamples > 0 && count < releaseInSamples - 1) {
          currentValue=Math.max(currentValue * (releaseInSamples - count - 1) / (releaseInSamples - count), 0);
        } else {
          currentValue=0;
        }
      }
      count++;
      for (int c=0; c < bufOut.length; c++) {
        float absInput=Math.abs(bufIn[c][a]);
        if (triggered) {
          bufOut[c][a]=(float)(Math.signum(bufIn[c][a]) * Math.min(Math.pow(10, output[c]), Math.max(0, absInput - currentValue)));
        } else {
          bufOut[c][a]=(float)(Math.signum(bufIn[c][a]) * Math.max(0, absInput - currentValue));
        }
        bufOut[c][a]*=outputGain;
      }
    }
    if (canDraw && graph != null) {
      visualizeGraph(dval, dvallog);
    }
    if (canDraw && wave != null) {
      visualizeWave(dval);
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
    thresholdPow=(float)Math.pow(10, threshold);
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
  void visualizeGraph(double dval, double dvallog) {//size=object.height
    graph.beginDraw();
    graph.stroke(50);
    graph.strokeWeight(2);
    graph.clear();
    float py=graph.height;
    for (int a=1; a < graph.width; a++) {
      double val=Math.log10((double)a / graph.width);
      float cy=graph.height - graph.height * (float)Math.pow(10, getOutput(val, val));
      graph.line(a - 1, py, a, cy);
      py=cy;
    }
    graph.noFill();
    graph.ellipse(graph.width * Math.min(1, (float)dval), graph.height * (1 - (float)Math.pow(10, getOutput(dvallog, dvallog))), 10, 10);
    graph.endDraw();
  }
  void visualizeWave(double dval) {
    float head=wave.height / 10;
    wave.beginDraw();
    wave.imageMode(PApplet.CORNER);
    wave.image(wave, -1, 0);
    wave.strokeWeight(1);
    wave.stroke(127, 127, 127);
    wave.line(wave.width - 1, 0, wave.width - 1, wave.height);
    double input=getDVal(bufIn);
    double output=getDVal(bufOut);
    wave.stroke(0x7F7F4040);
    wave.line(wave.width - 1, wave.height, wave.width - 1, wave.height + head - (int)(wave.height * input));//input
    wave.stroke(0x7F40407F);
    wave.line(wave.width - 1, wave.height, wave.width - 1, wave.height + head - (int)(wave.height * output));//output
    if (sideChain != null) {
      wave.stroke(0x3F000000);
      wave.line(wave.width - 1, wave.height, wave.width - 1, wave.height + head - (int)(wave.height * dval));//rms sideChain
    }
    wave.stroke(0xFF000000);
    wave.point(wave.width - 1, wave.height - (int)(wave.height * thresholdPow + head));//threshold
    wave.stroke(0x3F007F00);
    wave.line(wave.width - 1, head, wave.width - 1, (int)(wave.height * (input - output)) + head);//rms db(sidechain)
    wave.endDraw();
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
  double getDVal(UGen in) {
    if (method == Method.RMS) {//https://dsp.stackexchange.com/questions/27221/calculating-rms-crest-factor-for-a-stereo-signal
      float result=0;
      for (int c=0; c < in.getOuts(); c++) {
        for (int i=0; i < bufferSize; i++) {
          result+=(in.getOutBuffer(c)[i] * in.getOutBuffer(c)[i]);
        }
      }
      return Math.sqrt(result / (in.getOuts() * bufferSize));
    } else if (method == Method.PEAK) {
      float max=0;
      float sum=0;
      for (int i=0; i < bufferSize; i++) {
        sum=0;
        for (int c=0; c < in.getOuts(); c++) {
          sum+=in.getOutBuffer(c)[i];
        }
        sum=sum / in.getOuts();
        if (max < sum) {
          max=sum;
        }
      }
      return max;
    }
    return 0;//no!
  }
  double getDVal(float[][] buf) {
    if (method == Method.RMS) {
      float result=0;
      for (int c=0; c < buf.length; c++) {
        for (int i=0; i < bufferSize; i++) {
          result+=buf[c][i] * buf[c][i];
        }
      }
      return Math.sqrt(result / (buf.length * bufferSize));
    } else if (method == Method.PEAK) {
      float max=0;
      float sum=0;
      for (int i=0; i < bufferSize; i++) {
        sum=0;
        for (int c=0; c < buf.length; c++) {
          sum+=buf[c][i];
        }
        sum=sum / buf.length;
        if (max < sum) {
          max=sum;
        }
      }
      return max;
    }
    return 0;//no!
  }
}
