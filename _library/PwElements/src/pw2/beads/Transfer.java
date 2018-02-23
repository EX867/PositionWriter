package pw2.beads;
import beads.AudioContext;
import beads.Plug;
import beads.UGen;
public class Transfer extends UGen {
  public Transfer(AudioContext ac, int in, int out) {
    super(ac, in, out);
  }
  @Override
  public void calculateBuffer() {
    if (outs == 0) {
      return;
    }
    int max=Math.max(ins, outs);
    for (int a=0; a < max; a++) {
      bufOut[a % bufOut.length]=bufIn[a % bufIn.length];
    }
  }
}
