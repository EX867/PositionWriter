package com.karnos.commandscript;
import kyui.core.KyUI;
import kyui.editor.Attribute;
import kyui.element.RangeSlider;
import kyui.element.TextEdit;
import kyui.util.ColorExt;
import kyui.util.HideInEditor;
import kyui.util.Rect;
import processing.core.PGraphics;

import java.util.ArrayList;
import java.util.HashMap;
public class CommandEdit extends TextEdit {
  private Rect cacheRect=new Rect();
  public CommandScript script;//this == content;
  private HashMap<String, Integer> keywords;
  @Attribute(type=Attribute.COLOR)
  public int errorColor;
  @Attribute(type=Attribute.COLOR)
  public int warningColor;
  @Attribute(type=Attribute.COLOR)
  public int commentColor;
  protected ArrayList<MarkRange> markRanges;
  public static class MarkRange {// slider marker is startLine.
    public int color;
    public int startLine=0;//include
    public int endLine=0;//exclude
    public MarkRange(int color_) {
      color=color_;
    }
    public boolean isActive() {
      return startLine < endLine;
    }
  }
  public static interface TextRenderer {
    public void render(PGraphics g, String text, int line, CommandEdit cmd);
  }
  public TextRenderer textRenderer=new TextRenderer() {
    @Override
    public void render(PGraphics g, String text, int line, CommandEdit cmd) {
      String[] tokens=CommandScript.split(text, " ");
      float width=0;
      for (String token : tokens) {
        g.fill(keywords.getOrDefault(token, textColor));
        token=token + " ";
        g.text(token, width + pos.left + lineNumSize + padding, pos.top + (line + 0.5F) * textSize - offsetY + padding);
        width=width + g.textWidth(token);
      }
    }
  };
  public CommandEdit(String name) {
    super(name, new CommandScript(name, null));
    keywords=LineCommandType.DEFAULT_TYPE.keywords;
    script=(CommandScript)content;
    markRanges=new ArrayList<>();
    errorColor=0xFF9E0A0A;
    commentColor=0xFF828282;
    warningColor=0xFFCABB12;
    super.setSlider(new MarkingRangeSlider(name + ":slider"));
  }
  public void setContent(CommandScript sc) {
    content=sc;
    script=sc;
  }
  @Override
  public void setSlider(RangeSlider slider_) {
    //do nothing
  }
  public RangeSlider getSlider() {
    return slider;
  }
  public CommandEdit setAnalyzer(Analyzer analyzer) {
    script.setAnalyzer(analyzer);
    keywords=script.analyzer.getCommandType().keywords;
    return this;
  }
  public void drawLine(PGraphics g, String text, int line) {
    textRenderer.render(g, text, line, this);
  }
  @Override
  public void render(PGraphics g) {
    //no draw slider...
    //draw basic form
    g.fill(bgColor);
    pos.render(g);
    //setup text
    g.textAlign(KyUI.Ref.LEFT, KyUI.Ref.CENTER);
    g.textFont(textFont);
    g.textSize(Math.max(1, textSize));
    g.textLeading(textSize / 2);
    int start=offsetToLine(offsetY - padding);
    int end=offsetToLine(offsetY + pos.bottom - pos.top - padding);
    g.fill(lineNumBgColor);
    cacheRect.set(pos.left, pos.top, pos.left + lineNumSize, pos.bottom);
    cacheRect.render(g);
    for (MarkRange range : markRanges) {
      if (range.isActive() && start < range.endLine && end >= range.startLine) {
        g.fill(range.color);
        g.rect(pos.left, pos.top + padding + range.startLine * textSize - offsetY, pos.left + lineNumSize, pos.top + padding + range.endLine * textSize - offsetY);
      }
    }
    cacheRect.set(pos.left, pos.top, pos.right, pos.bottom);
    //iterate lines
    g.fill(selectionColor);
    if (content.hasSelection()) {
      for (int a=Math.max(0, start - 1); a < content.lines() && a < end + 1; a++) {
        //draw selection
        String selectionPart=content.getSelectionPart(a);
        if (!selectionPart.isEmpty()) {
          if (selectionPart.charAt(selectionPart.length() - 1) == '\n') {
            g.rect(pos.left + g.textWidth(content.getSelectionPartBefore(a)) + lineNumSize + padding, pos.top + a * textSize - offsetY + padding, pos.right - padding, pos.top + (a + 1) * textSize - offsetY + padding);
          } else {
            float selectionBefore=g.textWidth(content.getSelectionPartBefore(a));
            g.rect(pos.left + selectionBefore + lineNumSize + padding, pos.top + a * textSize - offsetY + padding, pos.left + selectionBefore + g.textWidth(selectionPart) + lineNumSize + padding, pos.top + (a + 1) * textSize - offsetY + padding);
          }
        }
      }
    }
    if (content.empty()) {
      g.fill(hintColor);
      g.text(hint, pos.left + lineNumSize + padding, pos.top + 0.5F * textSize - offsetY + padding);
    } else {
      for (int a=Math.max(0, start - 1); a < content.lines() && a < end + 1; a++) {
        int index=content.getLine(a).indexOf("//");
        boolean comment=true;
        if (index == -1) {
          comment=false;
          index=content.getLine(a).length();
        }
        drawLine(g, content.getLine(a).substring(0, index), a);
        if (comment) {
          g.fill(commentColor);
          g.text(content.getLine(a).substring(index, content.getLine(a).length()), g.textWidth(content.getLine(a).substring(0, index)) + pos.left + lineNumSize + padding, pos.top + (a + 0.5F) * textSize - offsetY + padding);
        }
      }
    }
    for (int a=Math.max(0, start - 1); a < content.lines() && a < end + 1; a++) {
      LineError error=script.getFirstError(a);
      if (error != null) {
        underlineError(g, error, a);
      }
    }
    g.fill(textColor);
    //draw text (no comment in normal textEditor implementation
    if (KyUI.focus == this) {
      if (cursorOn) {
        if (start <= content.line && content.line <= end) {
          g.fill(textColor);
          float cursorOffsetX=g.textWidth("|") / 2;
          String line=content.getLine(content.line);
          if (line.length() >= content.point) {//FIX>>?????????????????
            g.text("|", pos.left + g.textWidth(line.substring(0, content.point)) + lineNumSize + padding - cursorOffsetX, pos.top + (content.line + 0.5F) * textSize - offsetY + padding);
          }
        }
      }
    }
    g.textAlign(KyUI.Ref.RIGHT, KyUI.Ref.CENTER);
    g.textFont(KyUI.fontMain);
    g.textSize(Math.max(1, textSize));
    g.textLeading(textSize / 2);
    for (int a=Math.max(0, start - 1); a < end + 1; a++) {
      if (a < content.lines()) {
        g.fill(lineNumColor);
      } else {
        g.fill(ColorExt.brighter(lineNumColor, -150));
      }
      g.text(a + "", pos.left + lineNumSize - padding, pos.top + (a + 0.5F) * textSize - offsetY + padding);
    }
    g.textAlign(KyUI.Ref.CENTER, KyUI.Ref.CENTER);
    g.noStroke();
  }
  protected void underlineError(PGraphics g, LineError error, int line) {
    if (error.type == LineError.ERROR) {
      g.stroke(errorColor);
    } else if (error.type == LineError.WARNING) {
      g.stroke(warningColor);
    }
    g.strokeWeight(2);
    g.line(pos.left + lineNumSize + padding, pos.top + padding + (line + 1.1F) * textSize - offsetY, pos.left + lineNumSize + padding + g.textWidth(content.getLine(line)), pos.top + padding + (line + 1.1F) * textSize - offsetY);
    g.noStroke();
  }
  public MarkRange addMarkRange(int color) {
    MarkRange m=new MarkRange(color);
    markRanges.add(m);
    return m;
  }
  @HideInEditor
  class MarkingRangeSlider extends RangeSlider {
    public MarkingRangeSlider(String name) {
      super(name);
    }
    @Override
    public void render(PGraphics g) {
      super.render(g);
      g.strokeWeight(2);
      for (LineError error : script.getErrors()) {
        if (error.type == LineError.ERROR) {
          markLine(g, errorColor, error.line);
        } else if (error.type == LineError.WARNING) {
          markLine(g, warningColor, error.line);
        }
      }
      for (MarkRange mark : markRanges) {
        markLine(g, mark);
      }
      g.noStroke();
    }
    protected void markLine(PGraphics g, MarkRange m) {
      if (!m.isActive()) {
        return;
      }
      markLine(g, m.color, m.startLine);
    }
    protected void markLine(PGraphics g, int c, int line) {
      g.stroke((c >> 16) & 0xFF, (c >> 8) & 0xFF, c & 0xFF, 255);
      float total=Math.max(getTotalSize(), CommandEdit.this.pos.bottom - CommandEdit.this.pos.top);
      int offset=CommandEdit.this.padding + CommandEdit.this.textSize * line;
      float p=0;
      slider.setOffset(getTotalSize(), offsetY);
      if (total != 0) p=(pos.bottom - pos.top) * offset / total;
      p+=sliderLength / 2;
      g.line(pos.left, pos.top + p, pos.right, pos.top + p);
    }
  }
  @Override
  public boolean isRecordPoint(char c) {
    return c == ' ' || c == '\n' || c == script.getAnalyzer().seperator;
  }
  @Override
  public void recordHistory() {
    //System.out.println("recorded : " + KyUI.frameCount);
    script.recorder.recordLog();
  }
}
