import ddf.minim.*;
import javax.sound.sampled.AudioFormat;
Minim minim;
AudioPlayer player;
boolean AD_reload=true;
boolean AD_loop=false;
boolean AD_started=false;

String AD_playingFileFormat="";
String AD_playingFileName="";
int AD_playingFileLength=0;

void CF_initAudio() {
  minim = new Minim(this);
}
void AD_clearMemory(){
  if(player!=null){
    player.close();
    player=null;
  }
}
void AD_loadSample(String path) {
  if (player!=null)if (player.isPlaying())player.pause();
  if (player!=null) {
    player.close();
  }
  player = minim.loadFile(path);
  AD_reload=false;
  //println(player.getFormat().getEncoding()+" "+player.getFormat().getSampleRate());
}
void setPosition(int start, int end, int pos) {
  if (player==null)return;
  int position = AD_playingFileLength*(pos-start)/(end-start);
  player.cue( position );
  AD_started=false;
}

void AD_pause() {
  if (player==null)return;
  if (player.isPlaying()) {
    player.pause();
  }
  AD_started=false;
}
void AD_play() {
  if (player==null)return;
  if (player.isPlaying())player.rewind();
  player.play();
  AD_started=true;
}
void AD_looping() {
  if (player==null)return;
  if (AD_started&&player.position()==AD_playingFileLength&&AD_loop==false) {
    player.rewind();
    player.pause();
    AD_started=false;
  }
  if (AD_loop&&player.position()==player.length()) {
    player.rewind();
    player.play();
  }
}
boolean isApplyable(String path) {
  String input=getFormat(path);
  if (input.equals("audio/wav")||input.equals("audio/x-wav")) {
    AudioSample sample=null;
    File file=new File(path);
    if (file.length()>SAMPLEWAV_MAX_SIZE) {
      Log="file is too big";
      return false;
    }
    sample=minim.loadSample(path);
    if (sample.equals(null))return false;
    AudioFormat.Encoding encoding=sample.getFormat().getEncoding();
    Float samplerate=sample.getFormat().getSampleRate();
    sample.close();
    if (encoding.equals(AudioFormat.Encoding.PCM_SIGNED)&&samplerate==44100.0)return true;
  }
  return false;
}
boolean isPlayable(String input) {//nio probe
  //audio/wav
  //audio/x-wav
  //audio/aiff
  //audio/x-aiff
  //audio/basic
  //audio/x-au
  //audio/x-adpcm
  //audio/mpeg3
  //audio/x-mpeg-3
  if (input.equals("audio/wav")||input.equals("audio/x-wav")||input.equals("audio/aiff")||input.equals("audio/x-aiff")||input.equals("audio/basic")||input.equals("audio/x-au")||input.equals("audio/x-adpcm")||input.equals("audio/mpeg3")||input.equals("audio/x-mpeg-3")||input.equals("audio/mpeg")||input.equals("audio/x-mpeg"))return true;
  return false;
}

//int loopBegin;
//int loopEnd;

//void draw() {
//  background(0);
//  fill(255);  
//  text("Loop Count: " + snip.loopCount(), 5, 20);
//  text("Looping: " + snip.isLooping(), 5, 40);
//  text("Playing: " + snip.isPlaying(), 5, 60);
//  int p = snip.position();
//  int l = snip.length();
//  text("Position: " + p, 5, 80);
//  text("Length: " + l, 5, 100);
//  float x = map(p, 0, l, 0, width);
//  stroke(255);
//  line(x, height/2 - 50, x, height/2 + 50);
//  float lbx = map(loopBegin, 0, snip.length(), 0, width);
//  float lex = map(loopEnd, 0, snip.length(), 0, width);
//  stroke(0, 255, 0);
//  line(lbx, 0, lbx, height);
//  stroke(255, 0, 0);
//  line(lex, 0, lex, height);
//}

//void mousePressed() {
//  int ms = (int)map(mouseX, 0, width, 0, snip.length());
//  if ( mouseButton == RIGHT ) {
//    snip.setLoopPoints(loopBegin, ms);
//    loopEnd = ms;
//  } else {
//    snip.setLoopPoints(ms, loopEnd);
//    loopBegin = ms;
//  }
//}

//void keyPressed() {
//  snip.loop(2);
//}