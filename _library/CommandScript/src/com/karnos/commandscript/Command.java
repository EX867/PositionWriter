package com.karnos.commandscript;
public interface Command {
  public static Command DEFAULT_COMMAND=new Command() {
    @Override
    public String toString() {
      return "Default Command";
    }
  };
}
