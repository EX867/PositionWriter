package pw2.element.test;
import beads.AudioContext;
import beads.Sample;
import beads.Static;
import it.sauronsoftware.jave.*;
import kyui.core.Attributes;
import kyui.core.KyUI;
import kyui.element.*;
import kyui.event.MouseEventListener;
import kyui.util.Rect;
import processing.core.PApplet;
import processing.data.XML;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import pw2.beads.KnobAutomation;
import pw2.element.Knob;
import pw2.element.WavEditor;
import sojamo.drop.DropEvent;

import javax.swing.filechooser.FileSystemView;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.util.Arrays;
import java.util.TreeSet;
public class WavCut extends PApplet {

  public static void main(String[] args) {
    PApplet.main("pw2.element.test.WavCut");
  }

  @Override
  public void settings() {
    //size(1500, 600);
    size(displayWidth - 20, displayHeight * 3 / 5 + 60 + 20/*edge*/);
  }

  WavEditor w;
  MouseEventListener evl;
  KnobAutomation cuePoint;
  TextBox option;
  long lastSavedTime;

  @Override
  public void setup() {
    surface.setTitle("wavcut");
    KyUI.start(this, 30, true);
    AudioContext ac=new AudioContext();
    w=new WavEditor("wav");
    //w.snapBpm=140;
    //w.snapOffset=1386.05453381616781;//->???
    w.snapInterval=WavEditor.Beat[7];
    LinearLayout lin1=new LinearLayout("lin1");
    lin1.setDirection(Attributes.Direction.VERTICAL);
    lin1.setMode(LinearLayout.Behavior.STATIC);
    LinearLayout lin2=new LinearLayout("lin2");
    lin2.setDirection(Attributes.Direction.VERTICAL);
    lin2.setMode(LinearLayout.Behavior.STATIC);
    DivisionLayout dv2=new DivisionLayout("dv2");
    dv2.rotation=Attributes.Rotation.RIGHT;
    dv2.value=120;
    DivisionLayout dv=new DivisionLayout("dv");
    dv.rotation=Attributes.Rotation.DOWN;
    RangeSlider s=w.getSlider();
    dv.addChild(w);
    dv.addChild(s);
    dv2.addChild(dv);
    //
    Button b;
    w.snapGridColor=KyUI.Ref.color(167, 132, 21);
    w.snapCursorColor=KyUI.Ref.color(10, 105, 40);
    w.cursorColor=KyUI.Ref.color(10, 155, 40);
    w.setDeletePoint(b=new Button("delete"));
    evl=b.getPressListener();
    //
    lin1.addChild(w.setToggleSnap((ToggleButton)(b=new ToggleButton("snap"))));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="snap\n[P]";
    ((ToggleButton)b).value=true;
    lin1.addChild(w.setToggleAutoscroll((ToggleButton)(b=new ToggleButton("autoscroll"))));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="autoscr\n[O]";
    lin1.addChild(w.setToggleAutomationMode((ToggleButton)(b=new ToggleButton("automation"))));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="addmode\n[A]";
    lin1.addChild(w.setSnapGridPlus(b=new Button("grid+")));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="grid+\n[=]";
    lin1.addChild(w.setSnapGridMinus(b=new Button("grid-")));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="grid-\n[-]";
    lin1.addChild(b=new Button("save"));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="save\n[S]";
    b.setPressListener((e, ind) -> {
      saveCuePoints();
      return false;
    });
    lin1.addChild(b=new Button("cut"));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="cut\n[T]";
    b.setPressListener((e, ind) -> {
      audioCut();
      return false;
    });
    lin2.addChild(b=new Button("rewind"));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="rewind\n[R]";
    b.setPressListener((e, ind) -> {
      w.player.setPosition(w.player.getLoopStartUGen().getValue());
      w.player.pause(false);
      return false;
    });
    w.setUndo(b=new Button("undo"));//lin2.addChild();
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="undo\n[Z]";
    w.setRedo(b=new Button("redo"));//lin2.addChild();
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="redo\n[Y]";
    lin2.addChild(w.setZoomIn(b=new Button("zoomin")));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="zoomin\n]";
    lin2.addChild(w.setZoomOut(b=new Button("zoomout")));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="zoomout\n[";
    lin2.addChild(w.setToggleLoop((ToggleButton)(b=new ToggleButton("loop"))));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="loop\n[L]";
    lin2.addChild(b=new Button("resetloop"));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="resetloop\n[0]";
    b.setPressListener((e, ind) -> {
      if (w.sample != null) {
        w.player.setLoopStart(new Static(ac, 0));
        w.player.setLoopEnd(new Static(ac, Math.max(0, (float)w.sample.getLength())));
        w.invalidate();
      }
      return false;
    });
    lin2.addChild(w.setCopy(b=new Button("copy")));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="copy\n[C]";
    lin2.addChild(w.setPaste(b=new Button("paste")));
    b.rotation=Attributes.Rotation.RIGHT;
    b.text="paste\n[V]";
    //
    KyUI.addDragAndDrop(w, (DropEvent de) -> {
          surface.setTitle("wavcut - start load...");
          if (de.file().isFile()) {
            try {
              String filename=de.file().getAbsolutePath().replace("\\", "/");
              w.setSample(new Sample(filename));
              if (w.sample != null) {
                loadCuePoints(filename);
              }
              surface.setTitle("wavcut");
              return;
            } catch (Exception e) {
              System.out.println("beads error : " + e);
            }
            try {
              if (w.sample == null || !de.file().equals(new java.io.File(w.sample.getFileName()))) {//not loaded : not a wave file. retry.
                surface.setTitle("wavcut - not loaded. retrying...");
                Encoder encoder=new Encoder();
                MultimediaInfo info=encoder.getInfo(de.file());
                if (!Arrays.asList(encoder.getAudioDecoders()).contains(info.getAudio().getDecoder())) {
                  throw new Exception("file is not decodable : load failed");
                }
                System.out.println(info.getAudio().getBitRate() + " " + info.getAudio().getSamplingRate());
                AudioAttributes audio=new AudioAttributes();
                audio.setCodec("pcm_s16le"); // - getAudioEncoders()
                audio.setBitRate(192000);
                audio.setChannels(2);
                audio.setSamplingRate(44100);
                EncodingAttributes attrs=new EncodingAttributes();
                attrs.setFormat("wav");
                attrs.setAudioAttributes(audio);
                String name=de.filePath().substring(de.filePath().replace("\\", "/").lastIndexOf("/") + 1, de.filePath().length());
                if (name.contains(".")) {
                  name=name.substring(0, name.lastIndexOf("."));
                }
                String filename=getDocuments() + "/wavcut/temp/" + name + ".wav";
                File file=new File(filename);
                if (file.isFile()) {
                  try {
                    w.setSample(new Sample(filename));
                    if (w.sample != null) {
                      loadCuePoints(filename);
                    }
                    surface.setTitle("wavcut");
                    return;
                  } catch (Exception e) {
                    System.err.println("load error : " + e);
                    surface.setTitle("cannot loaded file : " + e.toString());
                  }
                } else {
                  encoder.encode(de.file(), file, attrs, new EncoderProgressListener() {
                    @Override
                    public void sourceInfo(MultimediaInfo multimediaInfo) {
                    }

                    @Override
                    public void progress(int i) {
                      if (i % 100 == 0) {
                        surface.setTitle("wavcut - ffmpeg in progress (" + i / 10 + "%)");
                      }
                      if (i == 1000) {
                        try {
                          w.setSample(new Sample(filename));
                          if (w.sample != null) {
                            loadCuePoints(filename);
                          }
                          surface.setTitle("wavcut");
                          return;
                        } catch (Exception e) {
                          System.err.println("load error : " + e);
                          surface.setTitle("cannot loaded file : " + e.toString());
                        }
                      }
                    }

                    @Override
                    public void message(String s) {
                    }
                  });
                }
              }
            } catch (Exception e) {
              System.err.println("ffmpeg error : " + e);
              surface.setTitle("cannot loaded file : " + e.toString());
            }
          }
        }
    );
    DivisionLayout dv3=new DivisionLayout("dv3");
    dv3.rotation=Attributes.Rotation.LEFT;
    dv3.mode=DivisionLayout.Behavior.PROPORTIONAL;
    dv3.value=0.5F;
    dv3.addChild(lin2);
    dv3.addChild(lin1);
    AlterLinearLayout dv_rud=new AlterLinearLayout("dv_rud");
    dv_rud.direction=Attributes.Direction.VERTICAL;
    Knob speedKnob=new Knob("speedKnob");
    speedKnob.label="speed";
    dv_rud.addChild(dv3);
    dv_rud.addChild(speedKnob);
    dv2.addChild(dv_rud);
    DivisionLayout dv4=new DivisionLayout("dv4");
    dv4.padding=10;
    dv4.rotation=Attributes.Rotation.DOWN;
    dv4.value=70;//60;
    AlterLinearLayout lin_bottomMenu=new AlterLinearLayout("lin_bottomMenu");
    lin_bottomMenu.direction=Attributes.Direction.HORIZONTAL;
    TextBox offset=new TextBox("offset", "grid offset (milliseconds)", "1386.0545");
    offset.setNumberOnly(TextBox.NumberType.FLOAT);
    offset.onTextChangeListener=(e) -> {
      w.snapOffset=offset.valueF;
      w.invalidate();
    };
    offset.setText("0");
    TextBox bpm=new TextBox("bpm", "bpm", "140");
    bpm.setNumberOnly(TextBox.NumberType.FLOAT);
    bpm.onTextChangeListener=(e) -> {
      w.snapBpm=bpm.valueF;
      w.invalidate();
    };
    bpm.setText("120");
    option=new TextBox("option", "option", "<chain> <y> <x> <loop count>");
    option.setNumberOnly(TextBox.NumberType.NONE);
    option.onTextChangeListener=(e) -> {
      for (KnobAutomation.Point p : w.selectedPoints) {
        p.option=option.getText();
      }
      w.invalidate();
    };
    option.setText("");
    w.mouseListener=() -> {
      if (w.selectedPoints.size() == 1) {
        option.setText(w.selectedPoints.getFirst().option);
      } else if (w.selectedPoints.size() > 1) {
        for (KnobAutomation.Point p : w.selectedPoints) {
          option.setText(w.selectedPoints.getFirst().option);
          if (!p.option.equals(w.selectedPoints.getFirst().option)) {
            option.setText("");
            break;
          }
        }
      }
    };
    Button autoPlayButton=new Button("autoPlay");
    autoPlayButton.text="auto\nplay";
    autoPlayButton.setPressListener((e, ind) -> {
      saveAutoPlay();
      return false;
    });
    Button keySoundButton=new Button("keySound");
    keySoundButton.text="key\nsound";
    keySoundButton.setPressListener((e, ind) -> {
      saveKeySound();
      return false;
    });
    lin_bottomMenu.interval=5;
    lin_bottomMenu.addChild(offset);
    lin_bottomMenu.addChild(bpm);
    lin_bottomMenu.addChild(option);
    lin_bottomMenu.addChild(autoPlayButton);
    lin_bottomMenu.addChild(keySoundButton);
    //lin_bottomMenu.addChild(speedKnob);
    dv4.addChild(dv2);
    dv4.addChild(lin_bottomMenu);
    KyUI.add(dv4);
    dv4.setPosition(new Rect(0, 0, width, height));
    KyUI.taskManager.executeAll();
    dv_rud.set(dv3, AlterLinearLayout.LayoutType.STATIC, 1);
    dv_rud.set(speedKnob, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1);
    lin_bottomMenu.set(offset, AlterLinearLayout.LayoutType.STATIC, 1);
    lin_bottomMenu.set(bpm, AlterLinearLayout.LayoutType.STATIC, 1);
    lin_bottomMenu.set(option, AlterLinearLayout.LayoutType.STATIC, 1);
    lin_bottomMenu.set(keySoundButton, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1);
    lin_bottomMenu.set(autoPlayButton, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1);
    KyUI.changeLayout();
    KyUI.changeLayout();
    w.initPlayer(ac);
    //String path="C:\\Users\\user\\Documents\\[Projects]\\PositionWriter\\AlsExtractor\\data\\Love_u1.wav";
    //w.setSample(SampleManager.sample(path));
    //w.player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    //GainW g=new GainW(ac, 2);
    //g.addInput(w.player);
    ac.out.addInput(w.player);
    cuePoint=new KnobAutomation(ac, 1);
    cuePoint.setRange(0, 2);
    //new Knob("a", "a").attach(ac, g, g.setGain, 0, 1, 1, 1, false);
    //w.player.addAuto(g.gain);
    speedKnob.attach(ac, w.player, w.player.setSpeed, 0.4, 2, 1, 1, false);
    w.player.addAuto(cuePoint);
    w.automation=cuePoint;//g.gain;
    w.player.pause(true);
    lastSavedTime=System.currentTimeMillis();
    ac.start();
  }

  @Override
  public void keyPressed(KeyEvent e) {
    if (keyPressed) {
      if (KyUI.focus == option) return;
      if (key == ' ') {
        if (w.player.getPosition() == w.player.getLoopEndUGen().getValue()) {
          w.player.setPosition(w.player.getLoopStartUGen().getValue());
          w.player.pause(false);
        } else {
          w.player.pause(!w.player.isPaused());
        }
      }
      if (key == 'a') {
        ToggleButton b=KyUI.<ToggleButton>get2("automation");
        b.onPress();
        b.invalidate();
        b.getPressListener().onEvent(null, 0);
      }
      if (key == 'p') {
        ToggleButton b=KyUI.<ToggleButton>get2("snap");
        b.onPress();
        b.invalidate();
        b.getPressListener().onEvent(null, 0);
      }
      if (key == 'o') {
        Button b=KyUI.<Button>get2("autoscroll");
        b.onPress();
        b.invalidate();
        b.getPressListener().onEvent(null, 0);
      }
      if (key == '=') {
        Button b=KyUI.<Button>get2("grid+");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == '-') {
        Button b=KyUI.<Button>get2("grid-");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == '[') {
        Button b=KyUI.<Button>get2("zoomout");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == ']') {
        Button b=KyUI.<Button>get2("zoomin");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == 'd') {
        evl.onEvent(null, 0);
      }
      if (key == 'z') {
        Button b=KyUI.<Button>get2("undo");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == 'y') {
        Button b=KyUI.<Button>get2("redo");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == 't') {
        Button b=KyUI.<Button>get2("cut");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == 's') {
        Button b=KyUI.<Button>get2("save");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == 'r') {//rewind
        Button b=KyUI.<Button>get2("rewind");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == 'l') {
        Button b=KyUI.<Button>get2("loop");
        b.onPress();
        b.invalidate();
        b.getPressListener().onEvent(null, 0);
      }
      if (key == '0') {
        Button b=KyUI.<Button>get2("resetloop");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == 'c') {
        Button b=KyUI.<Button>get2("copy");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == 'v') {
        Button b=KyUI.<Button>get2("paste");
        b.getPressListener().onEvent(null, 0);
      }
      if (key == '<') {
        w.left(2);
      }
      if (key == '>') {
        w.right(2);
      }
      if (key == 'q' || key == 17) {//processing's limit
        w.addPoint(w.snapTime(
            Math.max(Math.min(w.player.getPosition() + (double)(((java.awt.event.KeyEvent)e.getNative()).getWhen() - System.currentTimeMillis()), w.sample.getLength()), 0)
        ), 1);
        w.automationInvalid=true;
        KyUI.get("wav").invalidate();
      }
    }
  }

  @Override
  public void draw() {
    KyUI.render(g);
    w.selectionMode=keyPressed && key == CODED && keyCode == CONTROL;
    if (System.currentTimeMillis() > lastSavedTime + 10000) {//30 seconds
      saveCuePoints();
      lastSavedTime=System.currentTimeMillis();
    }
    stroke(255);
    fill(255);
    text(frameRate, mouseX, mouseY);
  }

  @Override
  public void exit() {
    saveCuePoints();
    super.exit();
  }

  @Override
  protected void handleKeyEvent(KeyEvent event) {
    super.handleKeyEvent(event);
    KyUI.handleEvent(event);
  }

  @Override
  protected void handleMouseEvent(MouseEvent event) {
    super.handleMouseEvent(event);
    KyUI.handleEvent(event);
  }

  XML toXML() {
    XML extract=new XML("Data");
    for (KnobAutomation.Point d : cuePoint.points) {
      XML event=extract.addChild("Event");
      event.setString("time", "" + d.position);
      event.setString("value", "" + d.value);
      event.setString("option", d.option);
    }
    extract.addChild("Bpm").setString("value", "" + w.snapBpm);
    extract.addChild("Offset").setString("value", "" + w.snapOffset);
    return extract;
  }

  void loadCuePoints(String audioname) {
    audioname=audioname.substring(audioname.lastIndexOf("/") + 1, audioname.length());
    cuePoint.points.clear();
    String filename=getDocuments() + "/wavcut/" + audioname + ".xml";
    if (!new File(filename).exists()) {
      filename=getDocuments() + "/wavcut/" + audioname + ".xml.tmp";
      if (!new File(filename).exists()) {
        return;//no cue point save exists.
      }
    }
    XML extract=loadXML(filename);
    XML[] event=extract.getChildren("Event");
    for (XML x : event) {
      cuePoint.addPoint(Double.parseDouble(x.getString("time", "0")), Double.parseDouble(x.getString("value", "1")), x.getString("option", ""));
    }
    XML x=extract.getChild("Bpm");
    if (x != null) {
      w.snapBpm=Float.parseFloat(x.getString("value", "120"));
      KyUI.<TextBox>get2("bpm").setText("" + w.snapBpm);
    }
    x=extract.getChild("Offset");
    if (x != null) {
      w.snapOffset=Float.parseFloat(x.getString("value", "0"));
      KyUI.<TextBox>get2("offset").setText("" + w.snapOffset);
    }
  }

  void saveCuePoints() {//documents/wavcut/<wav_title.wav>.xml
    if (w.sample == null) {
      return;
    }
    new Thread(() -> {
      XML extract=toXML();
      String filename=w.sample.getFileName().replace("\\", "/");
      filename=filename.substring(filename.lastIndexOf("/") + 1, filename.length());
      String realfilename=getDocuments() + "/wavcut/" + filename + ".xml";
      surface.setTitle("wavcut - saving..." + realfilename);
      PrintWriter writer=createWriter(realfilename + ".tmp");
      writer.write(extract.format(2));
      writer.flush();
      writer.close();
      new File(realfilename).delete();
      new File(realfilename + ".tmp").renameTo(new File(realfilename));
      new File(realfilename + ".tmp").delete();
      //surface.setTitle("wavcut");
      surface.setTitle("wavcut - saved " + realfilename);
    }).start();
  }

  void saveAutoPlay() {
    if (w.sample == null || cuePoint.points.isEmpty()) {
      return;
    }
    new Thread(() -> {
      StringBuilder autoPlay=new StringBuilder();
      Sample sample=w.sample;
      String path=getDocuments() + "/wavcut/" + getFileName(sample.getFileName()) + " autoPlay";

      int count=0;
      //before first cue point
      if (cuePoint.points.get(0).position > 0) {//skip first audio split file information, but insert delay.
        KnobAutomation.Point p=cuePoint.points.get(0);

        int position=0;
        int duration=(int)Math.round(cuePoint.points.get(0).position);

//        String splitFileName=xxxx.format(count) + ".wav";
//        count++;

        autoPlay.append("d ").append(duration).append('\n');
      }
      //after first cue point
      for (int a=0; a < cuePoint.points.size(); a++) {
        KnobAutomation.Point p=cuePoint.points.get(a);

        int position=Math.max(0, (int)Math.round(p.position));
        int duration;
        if (a + 1 < cuePoint.points.size()) {
          duration=Math.max(0, (int)Math.round(cuePoint.points.get(a + 1).position)) - position;
        } else {
          duration=(int)Math.round(sample.getLength()) - position;
        }
        if (duration <= 0) {
          continue;
        }

//        String splitFileName=xxxx.format(count) + ".wav";
//        count++;

        String[] tokens=PApplet.split(cuePoint.points.get(a).option, " ");
        if (tokens.length >= 3) {
          autoPlay.append("t ").append(tokens[1]).append(" ").append(tokens[2]).append('\n');
        }

        autoPlay.append("d ").append(duration).append('\n');
      }

      surface.setTitle("wavcut - saving..." + path);
      safeOverwrite(path, autoPlay.toString());
      surface.setTitle("wavcut - saved " + path);
      openFileExplorer(getDocuments() + "/wavcut/");
    }).start();
  }

  static DecimalFormat xxxx=new DecimalFormat("0000");

  void saveKeySound() {
    if (w.sample == null || cuePoint.points.isEmpty()) {
      return;
    }
    new Thread(() -> {
      StringBuilder keySound=new StringBuilder();
      Sample sample=w.sample;

      int count=0;
      if (cuePoint.points.get(0).position > 0) {
        String splitFileName=xxxx.format(count) + ".wav";
        count++;
      }
      for (int a=0; a < cuePoint.points.size(); a++) {
        KnobAutomation.Point p=cuePoint.points.get(a);

        int position=Math.max(0, (int)Math.round(p.position));
        int duration;
        if (a + 1 < cuePoint.points.size()) {
          duration=Math.max(0, (int)Math.round(cuePoint.points.get(a + 1).position)) - position;
        } else {
          duration=(int)Math.round(sample.getLength()) - position;
        }
        if (duration <= 0) {
          continue;
        }

        String splitFileName=xxxx.format(count) + ".wav";
        count++;

        String[] tokens=PApplet.split(p.option, " ");
        if (tokens.length >= 3) {
          keySound.append(tokens[0]).append(" ").append(tokens[1]).append(" ").append(tokens[2]).append(" ").append(splitFileName);
          if (tokens.length >= 4) {
            keySound.append(" ").append(tokens[3]);
          }
          keySound.append('\n');
        }
      }

      String path=getDocuments() + "/wavcut/" + getFileName(sample.getFileName()) + " keySound";
      surface.setTitle("wavcut - saving..." + path);
      safeOverwrite(path, keySound.toString());
      surface.setTitle("wavcut - saved " + path);
      openFileExplorer(getDocuments() + "/wavcut/");
    }).start();
  }

  void audioCut() {//save files to documents/wavcut/<wav_title.wav>/<count>.wav
    if (w.sample == null || cuePoint.points.isEmpty()) {
      return;
    }
    new Thread(() -> {
      surface.setTitle("wavcut - start cut...");
      Sample sample=w.sample;
      String path=getDocuments() + "/wavcut/" + getFileName(sample.getFileName()) + "/";

      int count=0;
      //before first cue point
      if (cuePoint.points.get(0).position > 0) {
        KnobAutomation.Point p=cuePoint.points.get(0);

        int position=0;
        int duration=msToSample(sample, cuePoint.points.get(0).position);

        String splitFileName=xxxx.format(count) + ".wav";
        count++;

        float[][] buffer=new float[sample.getNumChannels()][duration];
        sample.getFrames(position, buffer);
        String[] tokens=PApplet.split(p.option, " ");
        Sample split=new Sample(sample.samplesToMs(duration), sample.getNumChannels(), sample.getSampleRate());
        split.putFrames(0, buffer);

        File file=new File(path + splitFileName);
        println("save audio : " + file.getAbsolutePath() + " length : " + split.getLength() / 1000 + " start : " + position + " end : " + (position + duration));
        try {
          if (!file.isFile()) {
            file.getParentFile().mkdirs();
            file.createNewFile();
          }
          surface.setTitle("wavcut - saved..." + file.getAbsolutePath().replace("\\", "/") + " (" + (0) + "/" + (cuePoint.points.size() + 1) + ")");
          split.write(file.getAbsolutePath());
        } catch (IOException e) {
          e.printStackTrace();
        }
      }
      //after first cue point
      for (int a=0; a < cuePoint.points.size(); a++) {
        KnobAutomation.Point p=cuePoint.points.get(a);

        int position=Math.max(0, msToSample(sample, p.position));
        int duration;
        if (a + 1 < cuePoint.points.size()) {
          duration=Math.max(0, msToSample(sample, cuePoint.points.get(a + 1).position)) - position;
        } else {
          duration=msToSample(sample, sample.getLength()) - position;
        }
        if (duration <= 0) {
          continue;
        }

        String splitFileName=xxxx.format(count) + ".wav";
        count++;

        float[][] buffer=new float[sample.getNumChannels()][duration];
        sample.getFrames(position, buffer);
        String[] tokens=PApplet.split(p.option, " ");
        Sample split=new Sample(sample.samplesToMs(duration), sample.getNumChannels(), sample.getSampleRate());
        split.putFrames(0, buffer);

        File file=new File(path + splitFileName);
        println("save audio : " + file.getAbsolutePath() + " length : " + split.getLength() / 1000 + " start : " + position + " end : " + (position + duration));
        try {
          if (!file.isFile()) {
            file.getParentFile().mkdirs();
            file.createNewFile();
          }
          surface.setTitle("wavcut - saved..." + file.getAbsolutePath().replace("\\", "/") + " (" + (a + 1) + "/" + (cuePoint.points.size() + 1) + ")");
          split.write(file.getAbsolutePath());
        } catch (IOException e) {
          e.printStackTrace();
        }
      }

      surface.setTitle("wavcut");
      openFileExplorer(path);
    }).start();
  }

  int msToSample(Sample sample, double in) {
    return (int)Math.floor(sample.msToSamples(in));
  }

  void safeOverwrite(String path, String text) {
    PrintWriter writer=createWriter(path + ".tmp");
    writer.write(text);
    writer.flush();
    writer.close();
    new File(path).delete();
    new File(path + ".tmp").renameTo(new File(path));
    new File(path + ".tmp").delete();
  }

  String getFileName(String path) {
    path=path.replace("\\", "/");
    return path.substring(path.lastIndexOf("/") + 1, path.length());
  }

  String getDocuments() {
    return FileSystemView.getFileSystemView().getDefaultDirectory().getPath();
  }

  void openFileExplorer(String path) {//#platform_specific
    if (platform == WINDOWS) {//https://stackoverflow.com/questions/15875295/open-a-folder-in-explorer-using-java
      try {
        java.awt.Desktop.getDesktop().open(new File(path));
      } catch (Exception e) {
        e.printStackTrace();
        surface.setTitle(e.toString());
      }
    } else if (platform == LINUX) {
    }
  }
}
