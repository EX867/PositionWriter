package com.karnos.commandscript.element;
import com.karnos.commandscript.LineCommandProcesser;
import com.karnos.commandscript.LineCommandType;
import com.karnos.commandscript.Script;
import kyui.element.TextEdit;
import kyui.util.Rect;
public class CommandEdit extends TextEdit {
  Script script;//this == content;
  public CommandEdit(String name){
    super(name,new Script(name));
  }
  public void setType(LineCommandType commandType, LineCommandProcesser processer_){

  }
}
