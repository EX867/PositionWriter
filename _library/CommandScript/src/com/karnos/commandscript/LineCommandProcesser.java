package com.karnos.commandscript;
public abstract class LineCommandProcesser {
  public LineCommandProcesser() {
  }
  public abstract void processCommand(int line, Command before, Command after);
  public abstract void onReadFinished();
  public abstract void clear();
}
