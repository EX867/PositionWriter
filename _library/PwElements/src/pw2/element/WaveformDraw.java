package pw2.element;
import beads.AudioContext;
import beads.Sample;
import kyui.util.Rect;
import processing.core.PGraphics;
public class WaveformDraw {
  //cache vars
  double length;
  float offsetX;
  double scale;
  Rect pos;
  public void render(PGraphics g, AudioContext ac, Rect pos_, Sample sample, int color, float offsetX_, double scale_, int channel) {
    scale=scale_;
    if (sample == null || scale == 0 || g == null) {
      return;
    }
    length=sample.getLength();
    if (length == 0) {
      return;
    }
    g.stroke(color);
    g.strokeWeight(1);
    offsetX=offsetX_;
    pos=pos_;
    int end=(int)(pos.right - pos.left);
    float hh=(pos.bottom - pos.top) / 2;
    int offsetToSamples=Math.round((float)ac.msToSamples(posToTime(pos.right - pos.left)));
    float[] data=new float[sample.getNumChannels()];
    int pframe=Math.round((float)ac.msToSamples(posToTime(0)));
    for (int a=0; a < end; a++) {
      int frame=Math.round((float)ac.msToSamples(posToTime(a)));
      int interval=Math.max(1, interval=(frame - pframe) / 100);//optimization purpose 200 is fine...
      float max=0;
      float min=0;
      frame=frame-frame % interval;
      for (int b=pframe - pframe % interval; b <= frame; b+=interval) {
        sample.getFrame(b, data);
        if (data[channel] > 0) {
          if (max < data[channel]) {
            max=data[channel];
          }
        } else {
          if (min > data[channel]) {
            min=data[channel];
          }
        }
      }
      g.line(pos.left + a, pos.top + hh, pos.left + a, pos.top + hh - hh * max);
      g.line(pos.left + a, pos.top + hh, pos.left + a, pos.top + hh - hh * min);
      pframe=frame;
    }
  }
  public float timeToPos(double time) {
    return (float)((pos.right - pos.left) * (time / length) * scale - offsetX);
  }
  public double posToTime(float point) {//pos is relative.
    return length * (point + offsetX) / (scale * (pos.right - pos.left));
  }
}
