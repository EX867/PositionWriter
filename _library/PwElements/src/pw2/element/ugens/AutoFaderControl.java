package pw2.element.ugens;
import beads.AudioContext;
import beads.Sample;
import beads.SamplePlayer;
import kyui.core.Attributes;
import kyui.core.Element;
import kyui.core.KyUI;
import kyui.core.MirrorView;
import kyui.element.*;
import pw2.beads.AutoFaderW;
import pw2.beads.KnobAutomation;
import pw2.element.Knob;
import pw2.element.UGenViewer;
import pw2.element.WavEditor;

import javax.swing.filechooser.FileSystemView;
public class AutoFaderControl extends UGenViewer {
  //views
  public Knob preCount;
  public Knob postCount;
  public TextBox path;
  public Button export;
  public ToggleButton exportMode;//toggle normal<->overlay fade
  public Button previous;//FIX>> change to imagebutton
  public Button center;
  public Button next;
  public WavEditor view;//but don't use view.player please...
  //
  protected DivisionLayout layout;
  protected DivisionLayout dvl;
  protected DivisionLayout dvr;
  protected DivisionLayout dvlu;
  protected AlterLinearLayout dvld;
  protected AlterLinearLayout dv;
  protected DivisionLayout sliderLayout;
  //
  public AutoFaderW fader;
  public AutoFaderControl(String name) {
    super(name);
    layout=new DivisionLayout(name + ":layout");
    layout.mode=DivisionLayout.Behavior.PROPORTIONAL;
    layout.value=0.5F;
    layout.addChild(dvl=new DivisionLayout(name + ":dvl"));
    layout.addChild(dvr=new DivisionLayout(name + ":dvr"));
    dvl.rotation=Attributes.Rotation.DOWN;
    dvl.value=60;
    dvl.addChild(dvlu=new DivisionLayout(name + ":dvlu"));
    dvl.addChild(dvld=new AlterLinearLayout(name + ":dvld"));
    dvlu.rotation=Attributes.Rotation.RIGHT;
    dvlu.mode=DivisionLayout.Behavior.PROPORTIONAL;
    dvlu.value=0.5F;
    dvlu.addChild(preCount=new Knob(name + ":preCount", "preCount"));
    dvlu.addChild(postCount=new Knob(name + ":postount", "postCount"));
    dvld.addChild(path=new TextBox(name + ":path"));
    dvld.addChild(exportMode=new ToggleButton(name + ":exportMode"));
    dvld.addChild(export=new Button(name + ":export"));
    dvld.padding=2;
    path.setText(getDocuments());
    path.hint=export.text;
    path.title="Export path";
    export.text="Export";
    exportMode.text="Nor\nmal";
    exportMode.value=true;
    dvr.rotation=Attributes.Rotation.DOWN;
    dvr.value=60;
    dvr.addChild(sliderLayout=new DivisionLayout(name + ":sliderLayout"));
    dvr.addChild(dv=new AlterLinearLayout(name=":dv"));
    sliderLayout.rotation=Attributes.Rotation.DOWN;
    sliderLayout.value=30;
    sliderLayout.addChild(view=new WavEditor(name + ":view"));
    sliderLayout.addChild(view.getSlider());
    Element interval1;
    Element interval2;
    dv.addChild(previous=new Button(name + ":previous"));
    dv.addChild(interval1=new Element(name + ":interval1"));
    dv.addChild(center=new Button(name + ":center"));
    dv.addChild(interval2=new Element(name + ":interval2"));
    dv.addChild(next=new Button(name + ":next"));
    previous.text="Prev";
    center.text="Center";
    next.text="Next";
    addChild(layout);
    KyUI.taskManager.executeAll();
    dvld.set(path, AlterLinearLayout.LayoutType.STATIC, 1);
    dvld.set(exportMode, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1);
    dvld.set(export, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1.5F);
    dv.set(previous, AlterLinearLayout.LayoutType.DYNAMIC, 1);
    dv.set(interval1, AlterLinearLayout.LayoutType.STATIC, 1);
    dv.set(center, AlterLinearLayout.LayoutType.DYNAMIC, 1);
    dv.set(interval2, AlterLinearLayout.LayoutType.STATIC, 1);
    dv.set(next, AlterLinearLayout.LayoutType.DYNAMIC, 1);
  }
  static String getDocuments() {
    return FileSystemView.getFileSystemView().getDefaultDirectory().getPath();
  }
  public AutoFaderControl initialize(AutoFaderW fader_) {
    fader=fader_;
    AudioContext ac=fader.getContext();
    view.initPlayer(ac);
    //    preCount.attach(ac, fader, fader.setPreCount, 0, 50, 20, 20, false);
    //    postCount.attach(ac, fader, fader.setPostCount, 0, 50, 20, 20, false);;
    preCount.attach(ac, fader, fader.setPreCount, 0, 50, 10, 10, false);
    postCount.attach(ac, fader, fader.setPostCount, 0, 50, 5, 5, false);
    view.automation=fader.cuePoint;
    return this;
  }
  @Override
  public void onLayout() {
    dvlu.padding=(int)(pos.bottom - pos.top) / 10;
    layout.setPosition(pos.clone());
    layout.onLayout();
  }
  public KnobAutomation getCuePoint() {
    return fader.cuePoint;
  }
  public void setSample(Sample sample) {//call when every new sample loaded. but in pw, waveditor loads only one files!
    view.setSample(sample);
  }
  public void setAsMirror(WavEditor e) {
    SamplePlayer p=view.player;
    view.player=e.player;
    setSample(e.sample);
    p.kill();
  }
}
