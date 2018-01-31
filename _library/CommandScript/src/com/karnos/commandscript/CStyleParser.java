package com.karnos.commandscript;
public class CStyleParser extends Analyzer {
  //ADD>>
  public CStyleParser(LineCommandType commandType_, LineCommandProcessor processer_) {
    super(commandType_, processer_);
  }
  @Override
  public Command parse(int line, String location_, String text) {
    return commandType.getEmptyCommand();
  }
}
