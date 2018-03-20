package pw2.beads;
import beads.AudioContext;
import beads.Glide;
import beads.Static;
import beads.UGen;
import com.karnos.commandscript.Multiset;
import kyui.util.Task;
import kyui.util.TaskManager;
import pw2.element.Knob;

import java.util.function.Consumer;
public class KnobAutomation extends Glide {
  TaskManager tm=new TaskManager();
  final double EPSILON=Double.longBitsToDouble(971l << 52);//https://stackoverflow.com/questions/25180950/java-double-epsilon
  public static float GLIDE_TIME=1;
  public static class Point implements Comparable<Point> {
    public double value;
    public double position;
    public Point(double position_, double value_) {
      value=value_;
      position=position_;
    }
    @Override
    public int compareTo(Point o) {
      if (position > o.position) {
        return 1;
      } else if (position < o.position) {
        return -1;
      }
      return 0;
    }
  }
  Knob target;
  protected double max=1;
  protected double min=0;//used when no target specified
  public Multiset<Point> points;//but read only, use changePoint or addPoint when modifying this
  Point cachePoint=new Point(0, 0);
  double position=0;//in milliseconds...
  boolean loop=false;
  protected UGen loopStartEnvelope;
  protected UGen loopEndEnvelope;
  protected float loopStart;
  protected float loopEnd;
  protected double positionIncrement;
  private int index;
  //notifies to counters
  public Consumer<Point> preCounter;
  public Consumer<Point> postCounter;
  public double preCount=0;
  public double postCount=0;
  public KnobAutomation(AudioContext ac, float currentValue) {
    super(ac, currentValue, GLIDE_TIME);
    points=new Multiset<Point>();
    loopStartEnvelope=new Static(context, 0.0f);
    loopEndEnvelope=new Static(context, 0.0f);
    positionIncrement=context.samplesToMs(1);
    preCount=ac.samplesToMs(1);
    postCount=ac.samplesToMs(1);
  }
  public KnobAutomation attach(Knob target_) {
    target=target_;
    max=target.max;
    min=target.min;
    return this;
  }
  public float map(double v) {//map v with min and max to 1-0 (to show in screen)
    //assert max>min
    if (target == null) {
      return (float)((max - v) / (max - min));
    } else {
      return (float)((target.max - v) / (target.max - target.min));
    }
  }
  public double unmap(float p) {
    //assert max>min
    if (target == null) {
      return max - (max - min) * p;
    } else {
      return target.max - (target.max - target.min) * p;
    }
  }
  public KnobAutomation setRange(double min_, double max_) {//only works when no target specified.
    if (target != null) {
      max=max_;
      min=min_;
    }
    return this;
  }
  public Point addPoint(double pos, double value) {
    Point p=new Point(pos, value);
    synchronized (points) {
      points.add(p);
    }
    return p;
  }
  public void removePoint(int index) {
    synchronized (points) {
      points.remove(index);
    }
  }
  public void removePoint(Point point) {
    int index=0;
    synchronized (points) {
      for (Point p : points) {
        if (p == point) {
          break;
        }
        index++;
      }
      removePoint(index);
    }
  }
  public Point changePoint(int index, double pos, double value) {
    Point p=points.get(index);
    synchronized (points) {
      points.remove(index);
      p.position=pos;
      p.value=value;
      points.add(p);
    }
    return p;
  }
  public Point changePoint(Point point, double pos, double value) {
    //FIX it with making indexOf function in cmdscript.multiset
    synchronized (points) {
      int index=0;
      for (Point p : points) {
        if (p == point) {
          break;
        }
        index++;
      }
      if (index == points.size()) {
        return null;//error! error! error!
      }
      return changePoint(index, pos, value);
    }
  }
  Task loopChangeTask=(Object o) -> {//o instanceof boolean
    loop=(boolean)o;
  };
  public void setLoop(boolean v) {
    tm.addTask(loopChangeTask, v);
  }
  public double getPosition() {
    return position;
  }
  public void setPosition(double position) {
    this.position=position;
  }
  public void setLoopStart(float value) {
    this.loopStartEnvelope=new Static(context, value);
  }
  public void setLoopEnd(float value) {
    this.loopEndEnvelope=new Static(context, value);
  }
  public double getLength() {
    if (points.size() == 0) {
      return 0;
    } else {
      return points.get(points.size() - 1).position;
    }
  }
  @Override
  public void calculateBuffer() {//use same loop algorithm with beads's SamplePlayer. because I need to synchronized this with SamplePlayer...
    synchronized (points) {
      tm.executeAll();
      if (points.size() == 0) {
        super.calculateBuffer();
      } else if (target != null && target.hold()) {
        super.calculateBuffer();
        for (int i=0; i < bufferSize; i++) {
          calculateNextPosition(i);//also check loop in here...
        }
      } else {
        loopStartEnvelope.update();
        loopEndEnvelope.update();
        for (int i=0; i < bufferSize; i++) {
          bufOut[0][i]=(float)getValueIn();//get position's frame
          calculateNextPosition(i);//check loop
        }
        if (target != null) {
          target.adjust(target.getInv.apply((double)bufOut[0][bufferSize - 1]));
        }
      }
    }
  }
  protected double getValueIn() {//a and b should between position. if check fails, re calculate index.  assert points.size()>0
    if (index + 1 < points.size() && index >= 0) {
      if (points.get(index + 1).position <= position) {//check if index is too small
        index++;
        //System.out.println("1 : " + index);
      }
    }
    if (index >= 0 && index + 1 < points.size()) {
      if (points.get(index).position > position || points.get(index + 1).position <= position) {
        cachePoint.position=position;
        index=points.getBeforeIndex(cachePoint) - 1;
        //System.out.println("2 : " + index + " " + position + " " + points.get(index).position);
      }
    } //else if (index >= 0 && index < points.size() && points.get(index).position > position) {//also re-calculate, but this is on last index.
    cachePoint.position=position;
    index=points.getBeforeIndex(cachePoint) - 1;
    //System.out.println("3 : " + index + " " + position);
    //}
    if (index >= points.size()) {
      index=points.size() - 1;
    }
    //and notifies to counter
    if (preCounter != null && index >= -1 && index + 1 < points.size() && points.get(index + 1).position > position && preCount + EPSILON > points.get(index + 1).position - position) {
      preCounter.accept(points.get(index + 1));
    }
    if (postCounter != null && index >= 0 && index < points.size() && position > points.get(index).position && position - points.get(index).position < postCount + EPSILON) {
      postCounter.accept(points.get(index));
    }
    //and then finally calculate real value.
    if (index >= 0 && index + 1 < points.size()) {//if in range...
      Point aa=points.get(index);//update.
      Point bb=points.get(index + 1);
      if (aa.position == bb.position) {
        return aa.position;//random value(?)
      }
      //assert aa.pos<position<bb.pos
      return (aa.value * (bb.position - position) + bb.value * (position - aa.position)) / (bb.position - aa.position);
    }
    if (index < 0) {
      return points.get(0).value;
    }
    return points.get(points.size() - 1).value;//no!
  }
  protected void calculateNextPosition(int i) {
    if (loop) {
      loopStart=loopStartEnvelope.getValue(0, i);
      loopEnd=loopEndEnvelope.getValue(0, i);
      position+=positionIncrement;
      if (position > Math.max(loopStart, loopEnd)) {
        position=Math.min(loopStart, loopEnd);
        cachePoint.position=position;
        index=points.getBeforeIndex(cachePoint) - 1;
        //System.out.println("4 : " + index);
      }
    } else {
      position+=positionIncrement;
      //if (position > sample.getLength() || position < 0)atEnd();
    }
  }
}
