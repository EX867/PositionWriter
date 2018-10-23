package pw2.element;
import beads.AudioContext;
import beads.Sample;
import kyui.util.Rect;
import processing.core.PGraphics;
import processing.core.PImage;
public class WaveformDraw {
  //cache vars
  double length;
  float offsetX;
  double scale;
  Rect pos;
  public void render(PImage g, AudioContext ac, Rect pos_, Sample sample, int color, float offsetX_, double scale_, int channel) {
    scale = scale_;
    if (sample == null || scale == 0 || g == null) {
      return;
    }
    length = sample.getLength();
    if (length == 0) {
      return;
    }
    //g.stroke(color);
    //g.strokeWeight(1);
    offsetX = offsetX_;
    pos = pos_;
    int end = (int)(pos.right - pos.left);
    float hh = (pos.bottom - pos.top) / 2;
    int offsetToSamples = (int)Math.round(ac.msToSamples(posToTime(pos.right - pos.left)));
    float[] data = new float[sample.getNumChannels()];
    int pframe = (int)Math.round(Math.floor(ac.msToSamples(posToTime(0))));
    int interval = (int)Math.max(1, Math.round(ac.msToSamples(posToTime(1) - posToTime(0))) / 256);//optimization purpose 200 is fine...
    for (int a = 0; a < end; a++) {
      int frame = (int)Math.round(Math.floor(ac.msToSamples(posToTime(a))));
      float max = 0;
      float min = 0;
      frame = (frame / interval) * interval;
      //frame = frame - frame % interval;
      for (int b = pframe - pframe % interval; b <= frame; b += interval) {
        sample.getFrame(b, data);
        if (data[channel] > 0) {
          if (max < data[channel]) {
            max = data[channel];
          }
        } else {
          if (min > data[channel]) {
            min = data[channel];
          }
        }
      }
      for (int y = (int)(pos.top + hh - hh * max); y < pos.top + hh - hh * min; y++) {
        g.pixels[(int)(g.width * y + (pos.left + a))] = color;
      }
      pframe = frame;
    }
  }
  public float timeToPos(double time) {
    return (float)((pos.right - pos.left) * (time / length) * scale - offsetX);
  }
  public double posToTime(float point) {//pos is relative.
    return length * (point + offsetX) / (scale * (pos.right - pos.left));
  }
}
