
void drawFileInfo() {
  boolean canPlay=false;
  if (R) {
    fill(255);
    rect(900, 710, 200, 90);
    textAlign(LEFT, TOP);
    textSize(15);
    fill(0);
  }
  if (SelectedFile2!=-1) {
    String format=getFormat(keySound[Chain][Xpos][Ypos][SelectedFile2]);
    if (R)text("File : "+getFileName(keySound[Chain][Xpos][Ypos][SelectedFile2]), 905, 710);
    if (R)text("Type : "+format, 905, 730);
    if (isPlayable(format)) {
      canPlay=true;
      if (AD_reload) {
        if (isApplyable(keySound[Chain][Xpos][Ypos][SelectedFile2])==false) {
          LogCaution="selected file is not applicable to unipad";
        }
      }
    }
  } else if (SelectedFile!=-1) {
    String format=getFormat(View[SelectedFile].getAbsolutePath());
    if (R)text("File : "+View[SelectedFile].getName(), 905, 710);
    if (R)text("Type : "+format, 905, 730);
    if (isPlayable(format)) {
      canPlay=true;
      if (AD_reload) {
        if (isApplyable(View[SelectedFile].getAbsolutePath())==false) {
          LogCaution="selected file is not applicable to unipad";
        }
      }
    }
  } else if (AD_playingFileName.equals("")==false) {
    fill(100);
    if (R)text("File : "+AD_playingFileName, 905, 710);
    if (R)text("Type : "+AD_playingFileFormat, 905, 730);
  }
  if (R)textAlign(CENTER, CENTER);
  if (R) {
    fill(255);
    rect(900, 750, 200, 50);
    //play button
    fill(255);
    rect(905, 755, 30, 30);
  }
  AD_looping();
  if (canPlay) {
    if (R) {
      strokeWeight(2);
      fill(115, 225, 120);
      triangle(930, 770, 910, 760, 910, 780);
      strokeWeight(1);
    }
    if (isMouseIsPressed(905, 755, 30, 30)) {
      if (colorPress==0) {
        if (SelectedFile2!=-1) {
          if (AD_reload) {
            AD_loadSample(keySound[Chain][Xpos][Ypos][SelectedFile2]);
            AD_playingFileFormat=getFormat(keySound[Chain][Xpos][Ypos][SelectedFile2]);
            AD_playingFileName=getFileName(keySound[Chain][Xpos][Ypos][SelectedFile2]);
            if (player!=null)AD_playingFileLength=player.length();
          }
          AD_play();
        } else if (SelectedFile!=-1) {
          if (AD_reload) {
            AD_loadSample(View[SelectedFile].getAbsolutePath());
            AD_playingFileFormat=getFormat(View[SelectedFile].getAbsolutePath());
            AD_playingFileName=View[SelectedFile].getName();
            if (player!=null)AD_playingFileLength=player.length();
          } 
          AD_play();
        }
        colorPress=-18;
      }
    }
  }
  if (R) {
    //stop button
    fill(255);
    rect(940, 755, 30, 30);
    strokeWeight(2);
    fill(1208, 140, 140);
    rect(945, 760, 20, 20);
  }
  if (isMouseIsPressed(940, 755, 30, 30)) {
    if (colorPress==0) {
      AD_pause();
      colorPress=-19;
    }
  }
  if (R) {
    //play slider
    fill(255);
    strokeWeight(2);
    line(980, 770, 1055, 770);
    strokeWeight(1);
    if (colorPress==-20) rect(max(min(mouseX/scale, 1055), 980)-5, 770-15, 10, 30);
    else if (player!=null)rect(980+75*player.position()/AD_playingFileLength-5, 770-15, 10, 30);
  }
  if ((isMouseIsOn(975, 755, 85, 30)&&colorPress==0)||colorPress==-20) {
    if (mouseState==AN_RELEASE) {
      setPosition(0, 75, floor(max(min(mouseX/scale-980, 75), 0)));
    }
    colorPress=-20;
  }
  if (R) {
    //infinite button
    fill(255);
    rect(1065, 755, 30, 30);
    strokeWeight(2);
    if (AD_loop)fill(0);
    else fill(150);
    text("∞", 1080, 770);
    strokeWeight(1);
  }
  if (isMouseIsPressed(1065, 755, 30, 30)) {
    if (colorPress==0) {
      if (AD_loop)AD_loop=false;
      else AD_loop=true;
      colorPress=-21;
    }
  }
}