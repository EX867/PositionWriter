package com.karnos.commandscript;
import java.util.ArrayList;
public abstract class LineCommandProcesser {
  public abstract Command buildCommand(String commandName,ArrayList<String> params);
  public abstract void processCommand(int line,Command before,Command after);
}