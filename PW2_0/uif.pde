void ui_attachSlider(CommandEdit e) {
  e.parents.get(0).addChild(e.getSlider());
  e.parents.get(0).onLayout();
}
void ui_attachSlider(ConsoleEdit e) {
  e.parents.get(0).addChild(e.getSlider());
  e.parents.get(0).onLayout();
}