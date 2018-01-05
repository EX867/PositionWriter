package com.karnos.commandscript;
import kyui.element.TextEdit;
public class CommandEdit extends TextEdit {
  public CommandScript script;//this == content;
  public CommandEdit(String name) {
    super(name, new CommandScript(name, null, null));
    script=(CommandScript)content;
  }
  public CommandEdit setAnalyzer(LineCommandType commandType, LineCommandProcessor processor) {
    script.setAnalyzer(commandType, processor);
    return this;
  }
}
