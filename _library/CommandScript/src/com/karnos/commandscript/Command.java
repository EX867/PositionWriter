package com.karnos.commandscript;
public interface Command {
  public static Command DEFAULT_COMMAND=new Command() {
    @Override
    public void execute(long time) {
      System.out.println("Command executed in : " + time);
    }
    @Override
    public String toString() {
      return "Default Command";
    }
  };
  public void execute(long time);
}
