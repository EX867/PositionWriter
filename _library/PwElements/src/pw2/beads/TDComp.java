package pw2.beads;
import beads.*;
import processing.core.PApplet;
import processing.core.PGraphics;
public class TDComp extends UGen {//Time Domain Compressor, formula is from http://smc2017.aalto.fi/media/materials/proceedings/SMC17_p42.pdf
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
  public float graphSize=60;
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
  int attackCount=0;
  int releaseCount=0;
  double currentValue=1;
  double maxValue=1;
  public TDComp(AudioContext ac, int channels) {
    super(ac, channels, channels);
    attackInSamples=Math.round((float)context.msToSamples(attack));
    releaseInSamples=Math.round((float)context.msToSamples(release));
  }
  @Override
  public void calculateBuffer() {
    if (sideChain != null) {
      sideChain.update();
    }
    if (ins == 0) {
      return;
    }
    double input=getRMS(bufIn);
    double inputdval;
    double dvallog;
    double dval;
    if (sideChain == null) {
      dval=getDVal(bufIn);
      inputdval=dval;
    } else {
      dval=getDVal(sideChain);
      if (method == Method.PEAK) {
        inputdval=getDVal(bufIn);
      } else {//RMS
        inputdval=input;
      }
    }
    dvallog=Math.log10(dval);
    if (dvallog > threshold - knee / 2) {//compression start
      if (!triggered) {
        triggered=true;
        if (attackCount >= attackInSamples) {
          maxValue=0;
          attackCount=0;//attack start
        }
      }
    } else if (triggered) {//compression end
      triggered=false;
      releaseCount=0;//release start
    }
    for (int a=0; a < bufferSize; a++) {
      double sum=0;
      for (int c=0; c < bufOut.length; c++) {
        if (triggered) {
          double data=Math.log10(Math.abs(bufIn[c][a]));
          sum+=getOutput(dvallog, data) - data;
        }
      }
      double val=Math.pow(10, sum / bufOut.length);
      if (maxValue < val) {
        maxValue=val;
      }
      if (attackCount < attackInSamples) {
        double c=currentValue + (maxValue - currentValue) / (attackInSamples - attackCount);
        if (c < currentValue) {
          currentValue=c;
        }
        releaseCount=0;
      } else {
        if (triggered) {
          releaseCount=0;
        }
        if (releaseInSamples == 0 && triggered) {
          currentValue=val;
        } else {
          if (releaseInSamples > 0 && releaseCount < releaseInSamples - 1) {
            currentValue=Math.min(currentValue + (val - currentValue) / (releaseInSamples - releaseCount), val);
          } else {
            currentValue=1;
          }
        }
      }
      attackCount++;
      releaseCount++;
      for (int c=0; c < bufOut.length; c++) {
        bufOut[c][a]=outputGain * (float)(Math.signum(bufIn[c][a]) * Math.max(0, Math.abs(bufIn[c][a]) * currentValue));
      }
    }
    if (canDraw && graph != null) {
      visualizeGraph(inputdval, dvallog);
    }
    if (canDraw && wave != null) {
      visualizeWave(input, dval);
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
    threshold=v * 0.05;
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
  void visualizeGraph(double input, double dvallog) {//size=object.height
    //linear view. (graphSize to 0db)
    graph.beginDraw();
    graph.stroke(50);
    graph.strokeWeight(2);
    graph.clear();
    float py=graph.height;
    for (int a=1; a < graph.width; a++) {
      double db=graphSize * ((double)a / graph.width - 1) / 20;
      float cy=-graph.height * 20 * (float)getOutput(db, db) / graphSize;
      graph.line(a - 1, py, a, cy);
      py=cy;
    }
    graph.noFill();
    if (sideChain != null) {
      graph.ellipse(graph.width * Math.min(1, 20 * (float)dvallog / graphSize + 1), -graph.height * 20 * (float)getOutput(dvallog, dvallog) / graphSize, 10, 10);
    }
    input=input / 20;
    graph.ellipse(graph.width * Math.min(1, 20 * (float)input / graphSize + 1), -graph.height * 20 * (float)getOutput(dvallog, input) / graphSize, 10, 10);
    graph.endDraw();
  }
  float pt=1;
  void visualizeWave(double input, double dval) {
    float head=wave.height / 10;
    float height=wave.height - head;
    wave.beginDraw();
    wave.imageMode(PApplet.CORNER);
    wave.strokeWeight(1);
    wave.stroke(127, 127, 127);
    wave.image(wave, -1, 0);
    wave.line(wave.width - 1, 0, wave.width - 1, wave.height);
    double output=getRMS(bufOut) / (outputGain * outputGain);
    wave.stroke(0x7F7F4040);
    wave.line(wave.width - 1, wave.height, wave.width - 1, wave.height - (int)(height * input));//input
    wave.stroke(0x7F40407F);
    wave.line(wave.width - 1, wave.height, wave.width - 1, wave.height - (int)(height * output));//output
    if (sideChain != null) {
      wave.stroke(0x3F000000);
      wave.line(wave.width - 1, wave.height, wave.width - 1, wave.height - (int)(height * dval));//sideChain
    }
    wave.stroke(0xFF000000);
    float ct=wave.height - (float)(height * thresholdPow);
    wave.line(wave.width - 1, pt, wave.width - 1, ct);//threshold
    wave.stroke(0x3F007F00);
    if (outputGain != 0) {
      wave.line(wave.width - 1, head, wave.width - 1, (int)(height * (input - output)) + head);//difference
    }
    pt=ct;
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
          sum+=Math.abs(in.getOutBuffer(c)[i]);
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
      return getRMS(buf);
    } else if (method == Method.PEAK) {
      float max=0;
      float sum=0;
      for (int i=0; i < bufferSize; i++) {
        sum=0;
        for (int c=0; c < buf.length; c++) {
          sum+=Math.abs(buf[c][i]);
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
  double getRMS(float[][] buf) {
    float result=0;
    for (int c=0; c < buf.length; c++) {
      for (int i=0; i < bufferSize; i++) {
        result+=buf[c][i] * buf[c][i];
      }
    }
    return Math.sqrt(result / (buf.length * bufferSize));
  }
  float getChannelAverage(float[][] buf, int index) {
    float sum=0;
    for (int c=0; c < buf.length; c++) {
      sum+=buf[c][index];
    }
    return sum / buf.length;
  }
}
