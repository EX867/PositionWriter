package com.karnos.commandscript;
public class EndBlockStyleParser extends Analyzer {
  //ADD>>
  public EndBlockStyleParser(LineCommandType commandType_, LineCommandProcessor processer_) {
    super(commandType_, processer_);
  }
  @Override
  public Command parse(int line, String location_, String text) {
    return commandType.getEmptyCommand();
  }
}
