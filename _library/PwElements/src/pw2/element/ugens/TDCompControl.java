package pw2.element.ugens;
import beads.AudioContext;
import kyui.core.Attributes;
import kyui.core.KyUI;
import kyui.element.*;
import kyui.util.Rect;
import pw2.beads.TDCompW;
import pw2.element.*;
public class TDCompControl extends UGenViewer {
  //views
  protected DivisionLayout layout;
  protected AlterLinearLayout lin;
  protected VUMeter meter;//
  public Knob[] knob;
  protected LinearLayout knob1;//
  protected LinearLayout knob2;//
  protected TDCompWave wave;
  protected TDCompGraph graph;
  protected DivisionLayout buttons;
  protected ToggleButton sideChain;
  protected ToggleButton showList;
  protected LinearList samples;
  //
  public TDCompW comp;
  public TDCompControl(String name) {
    super(name);
    knob=new Knob[6];
    layout=new DivisionLayout(name + ":layout");
    layout.addChild(lin=new AlterLinearLayout(name + ":lin"));
    layout.addChild(samples=new LinearList(name + ":samples"));
    layout.rotation=Attributes.Rotation.RIGHT;
    buttons=new DivisionLayout(name + ":buttons");
    buttons.mode=DivisionLayout.Behavior.PROPORTIONAL;
    buttons.value=0.5F;
    buttons.rotation=Attributes.Rotation.UP;
    buttons.addChild(sideChain=new ToggleButton(name + ":sideChain"));
    sideChain.rotation=Attributes.Rotation.RIGHT;
    sideChain.text="SIDECHAIN";
    buttons.addChild(showList=new ToggleButton(name + ":showList"));
    showList.rotation=Attributes.Rotation.RIGHT;
    showList.text="SAMPLES";
    samples.setFixedSize(50);
    samples.reorderListener=(Integer a, Integer b) -> {
      comp.reorderSample(a, b);
      return true;
    };
    sideChain.setPressListener((e, index) -> {
      if (comp != null) {
        comp.setSideChain(sideChain.value);
      }
      return false;
    });
    showList.setPressListener((e, index) -> {
      samples.setEnabled(showList.value);
      localLayout();
      return false;
    });
    samples.setEnabled(false);
    addChild(layout);
  }
  //ADD file dragAndDrop to list, element draganddrop to list
  //ADD delete button!!!
  //ADD bypass button!!!
  //ADD fix linearlayout issues!!!

  public TDCompControl initialize(TDCompW comp_) {
    comp=comp_;
    sideChain.value=false;
    AudioContext ac=comp.getContext();
    lin.addChild(meter=new VUMeter(getName() + ":meter").attach(comp));
    lin.addChild(knob1=new LinearLayout(getName() + ":knob1"));
    lin.addChild(knob2=new LinearLayout(getName() + ":knob2"));
    knob1.setDirection(Attributes.Direction.VERTICAL);
    knob1.setMode(LinearLayout.Behavior.STATIC);
    knob2.setDirection(Attributes.Direction.VERTICAL);
    knob2.setMode(LinearLayout.Behavior.STATIC);
    knob1.addChild(knob[0]=new Knob(getName() + ":threshold", "Threshold").attach(ac, comp, comp.setThreshold, -60, 0, -6, -6, false));
    knob2.addChild(knob[1]=new Knob(getName() + ":ratio", "Ratio").attach(ac, comp, comp.setRatio, 1, 12, 2, 2, false));
    knob1.addChild(knob[2]=new Knob(getName() + ":attack", "Attack").attach(ac, comp, comp.setAttack, 0, 1000, 100, 100, false));
    knob2.addChild(knob[3]=new Knob(getName() + ":release", "Release").attach(ac, comp, comp.setRelease, 0, 1000, 300, 300, false));
    knob1.addChild(knob[4]=new Knob(getName() + ":knee", "Knee").attach(ac, comp, comp.setKnee, 0, 1, 0.1, 0.1, false));
    knob2.addChild(knob[5]=new Knob(getName() + ":gain", "Gain").attach(ac, comp, comp.setOutputGain, 0, 2, 1, 1, false));
    lin.addChild(wave=new TDCompWave(getName() + ":wave").attach(comp));
    lin.addChild(graph=new TDCompGraph(getName() + ":graph").attach(comp));
    lin.addChild(buttons);
    comp.sideChain.setLoop(false);
    KyUI.taskManager.executeAll();
    lin.set(meter, AlterLinearLayout.LayoutType.FIXED, 40);
    lin.set(knob1, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1 / 3F);
    lin.set(knob2, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1 / 3F);
    lin.set(wave, AlterLinearLayout.LayoutType.STATIC, 1);//value do not affect layout
    lin.set(graph, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1);
    lin.set(buttons, AlterLinearLayout.LayoutType.OPPOSITE_RATIO, 1 / 6F);
    return this;
  }
  @Override
  public void onLayout() {
    layout.setPosition(pos.clone());
    layout.value=(pos.bottom - pos.top) / 2;
    samples.setPosition(new Rect(pos.right - layout.value, pos.top, pos.right, pos.bottom));
    layout.onLayout();
  }
  public void addSample(String path) {
    samples.addItem(path.substring(path.replace("\\", "/").lastIndexOf("/") + 1, path.length()));
    comp.addSample(path);
  }
  public void removeSample(int index) {
    comp.removeSample(index);
    samples.removeItem(index);
  }
}
