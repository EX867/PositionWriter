XML layout_led_frame_xml;
XML layout_wv_frame_xml;
XML layout_m_frame_xml;
public void ui_attachSlider(CommandEdit e) {
  e.parents.get(0).addChild(e.getSlider());
  e.updateSlider();
}
public void ui_attachSlider(ConsoleEdit e) {
  e.parents.get(0).addChild(e.getSlider());
  e.updateSlider();
}
void ui_textValueRange(TextBox t, int min, int max) {
  if (t.valueI<min||t.valueI>max) {
    t.error=true;
    t.valueI=max(min(t.valueI, max), min);
  } else {
    t.error=false;
  }
}
void setInfoLed(UnipackInfo info_) {
  info.buttonX=info_.buttonX;
  info.buttonY=info_.buttonY;
  ((TextBox)KyUI.get("set_buttony")).setText(info_.buttonX+"");
  ((TextBox)KyUI.get("set_buttonx")).setText(info_.buttonY+"");
}