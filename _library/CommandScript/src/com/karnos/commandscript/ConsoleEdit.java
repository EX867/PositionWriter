package com.karnos.commandscript;
import kyui.core.KyUI;
import kyui.element.RangeSlider;
import kyui.element.TextEdit;
import kyui.util.EditorString;
import processing.core.PApplet;
import processing.event.KeyEvent;

import java.util.function.Consumer;
public class ConsoleEdit extends TextEdit {
  protected int editingLine=0;
  public String header=">> ";
  public Consumer<String> processor=(String s) -> {
    if (s.equals("cls")) {
      clearScreen();
    }
  };
  public ConsoleEdit(String name) {
    super(name);
    content=new EditorString() {
      @Override
      public void delete(int i, int i1, int i2, int i3) {//do not allow user to erase things!
        if (i > editingLine || i2 < editingLine) {
          return;
        }
        if (i < editingLine) {
          i=editingLine;
          i1=header.length();
        } else {
          i1=Math.max(header.length(), i1);
        }
        if (i2 > editingLine) {
          i2=editingLine;
          i3=content.getLine(editingLine).length();
        } else {
          i3=Math.max(header.length(), i3);
        }
        super.delete(i, i1, i2, i3);
      }
      @Override
      public String deleteBefore(boolean word) {//EditorString's delete
        if (point <= header.length() || line != editingLine) {
          return "";
        }
        String ret="";
        if (word) {
          boolean isSpace=false;
          String before=getLine(line);
          StringBuilder sb=new StringBuilder();
          if (isSpaceChar(getLine(line).charAt(point - 1))) isSpace=true;
          while (getLine(line).length() > 0 && point > header.length()) {
            if (((isSpace && isSpaceChar(getLine(line).charAt(point - 1)) == false)) || (!isSpace && isSpaceChar(getLine(line).charAt(point - 1)))) break;
            sb.append(getLine(line).charAt(point - 1));
            setLine(line, getLine(line).substring(0, point - 1) + getLine(line).substring(Math.min(point, getLine(line).length()), getLine(line).length()));
            point--;
          }
          ret=sb.reverse().toString();
        } else {
          String before=getLine(line);
          ret="" + l.get(line).charAt(point - 1);
          setLine(line, getLine(line).substring(0, point - 1) + getLine(line).substring(point, getLine(line).length()));
          cursorLeft(false, false);
        }
        maxpoint=point;
        return ret;
      }
    };
    super.setSlider(new RangeSlider(name + ":slider"));
    content.setLine(0, header);
  }
  @Override
  public void keyTyped(KeyEvent e) {
    if (KyUI.focus == this) {
      if (e.getKey() == '\b') {
        super.keyTyped(e);
        if (content.line == editingLine && content.point < header.length()) {
          content.point=header.length();
        }
        return;
      }
      if (e.getKey() != PApplet.CODED && (content.line != editingLine || content.point < header.length())) {
        return;
      }
      if (e.getKey() == '\n') {
        if (processor != null) {
          processor.accept(content.getLine(editingLine).substring(header.length(), content.getLine(editingLine).length()));
        }
        addLine_(content.lines(), header);
        content.line=editingLine;
        content.point=header.length();
        invalidate();
        return;
      }
      super.keyTyped(e);
    }
  }
  public void insert(int point_, int line_, String text) {
    if (point_ < header.length() || line_ != editingLine) {
      return;
    }
    content.insert(point_, line_, text);
    moveTo(line_);
    updateSlider();
  }
  public void addLine(int line_, String text) {
    //do nothing
  }
  public ConsoleEdit addLine(String text) {
    content.insert(content.lines() - 1, getLine(content.lines() - 1).length(), text);
    content.insert(content.lines() - 1, getLine(content.lines() - 1).length(), "\n" + header);
    editingLine=content.lines() - 1;
    moveTo(editingLine+blankLines);
    return this;
  }
  private void addLine_(int line_, String text) {
    content.addLine(line_, text);
    moveTo(line_);
    updateSlider();
    editingLine++;
  }
  public void setText(String text) {
    super.setText(text);
    if (content.getLine(content.lines() - 1).isEmpty()) {
      editingLine=content.lines() - 1;
      content.setLine(editingLine, header);
    } else {
      editingLine=content.lines();
      content.addLine(editingLine, header);
    }
  }
  public void clearScreen() {
    super.setText(header);
    editingLine=content.lines() - 1;
  }
  @Override
  public String getText() {
    return "";//ignore.
    //return super.getText();
  }
  public RangeSlider getSlider() {
    return slider;
  }
}