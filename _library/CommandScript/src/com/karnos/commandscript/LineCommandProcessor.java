package com.karnos.commandscript;
public abstract class LineCommandProcessor {
  public static LineCommandProcessor DEFAULT_PROCESSOR=new LineCommandProcessor() {
    @Override
    public void processCommand(Analyzer analyzer, int line, Command before, Command after) {
    }
    @Override
    public void onReadFinished(Analyzer analyzer) {
    }
    @Override
    public void clear(Analyzer analyzer) {
    }
  };
  public LineCommandProcessor() {
  }
  public abstract void processCommand(Analyzer analyzer, int line, Command before, Command after);
  public abstract void onReadFinished(Analyzer analyzer);
  public abstract void clear(Analyzer analyzer);
}
