public void update(float x, float y) {
  x=x/scale;
  y=y/scale;
  if (currentFrame==1) {
    setOverlay(0, 0, Width, Height);
  } else if (currentFrame==2) {
    int tempx=keySoundPad.getButtonXByX((int)x);
    int tempy=keySoundPad.getButtonYByY((int)y);
    if (tempx!=-1&&tempy!=-1) {
      setOverlay(keySoundPad.getButtonBounds(tempx, tempy));
    } else {
      setOverlay(0, 0, Width, Height);
    }
  } else if (currentFrame==11) {//mp3 converter
    UIelement elem=UI[getUIidRev("MP3_INPUT")];
    setOverlay(elem.position.x, elem.position.y, elem.size.x, elem.size.y);
  } else if (currentFrame==19) {//skinedit
    if (skinEditor.getDropAreaItem((int)x, (int)y)!=null) {
      setOverlay(skinEditor.getDropAreaItem((int)x, (int)y).location);
    }
  } else if (currentFrame==3) {
    String name=getFileName(filename);
    if (name.equals("Colors.xml")) {
      loadColors(filename);
    }
  } else if (currentFrame==11) {//mp3 converter
    ((ScrollList)UI[getUIidRev("MP3_INPUT")]).addItem(filename);
  }
}