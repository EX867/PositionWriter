AudioContext globalAc;
SamplePlayer globalSamplePlayer;
LightThread globalKsLedPlayer;
void au_setup() {
  globalAc=new AudioContext();
  globalSamplePlayer=new SamplePlayer(globalAc, 2);
  globalSamplePlayer.setKillOnEnd(false);
  globalAc.out.addInput(globalSamplePlayer);
  //globalSamplePlayer.setEndListener(new Bead() {
  //  public void messageReceived(Bead message) {
  //    //globalAc.stop();
  //  }
  //}
  //);
  globalKsLedPlayer=new LightThread();
  Thread thr=new Thread(globalKsLedPlayer);
  globalKsLedPlayer.thread=thr;
  thr.start();
}
void globalSamplePlayerPlay(String path) {//use for temporary play files
  try {
    globalSamplePlayer.setSample(new Sample(path));
    //println("play : "+globalSamplePlayer.getSample().getFileName());
    if (!globalAc.isRunning()) {
      globalAc.start();
    }
    globalSamplePlayer.setPosition(0);
    globalSamplePlayer.start();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
void globalKsLedPlayerPlay(LedScript script) {
  script.displayPad=ks_pad;
  globalKsLedPlayer.start(globalKsLedPlayer.addTrack(script), 0);
}