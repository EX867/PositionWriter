package pw2.beads;
import beads.Bead;

import java.util.function.Consumer;
public abstract class UGenListener extends Bead implements Consumer<float[][]> {//you can also pause and kill it.
  @Override
  public abstract void accept(float[][] bufOut);
}
